# frozen_string_literal: true

require "rails_helper"

RSpec.describe Webhooks::Vapi::CallProcessor do
  let!(:trial) { create(:trial, :active, vapi_assistant_id: "asst_123456") }
  let(:webhook_event) { create(:webhook_event, :vapi) }
  let(:processor) { described_class.new(webhook_event) }

  describe "#process" do
    context "with valid call.ended event" do
      let(:webhook_event) do
        create(:webhook_event,
          provider: "vapi",
          event_id: "call_abc123",
          event_type: "call.ended",
          payload: {
            "type" => "call.ended",
            "call" => {
              "id" => "call_abc123",
              "status" => "ended",
              "duration" => 120,
              "recordingUrl" => "https://storage.vapi.ai/recordings/call_abc123.mp3",
              "transcript" => "Agent: Hello, how can I help you?\nCustomer: I need a quote for a new AC unit.",
              "cost" => 0.15,
              "startedAt" => "2025-01-26T10:30:00Z",
              "endedAt" => "2025-01-26T10:32:00Z",
              "to" => "+15551234567",
              "functionCalls" => [
                {
                  "name" => "capture_lead",
                  "parameters" => {
                    "name" => "John Smith",
                    "phone" => "555-123-4567",
                    "email" => "john@example.com",
                    "intent" => "quote_request",
                    "notes" => "Needs quote for new AC unit"
                  }
                }
              ]
            },
            "assistant" => {
              "id" => "asst_123456"
            }
          })
      end

      it "creates a Call record for the trial" do
        expect { processor.process }.to change(Call, :count).by(1)
      end

      it "associates Call with Trial via polymorphic callable" do
        processor.process
        call = Call.last
        expect(call.callable).to eq(trial)
        expect(call.callable_type).to eq("Trial")
      end

      it "sets all call attributes correctly" do
        processor.process

        call = Call.last
        expect(call.direction).to eq("outbound_trial")
        expect(call.status).to eq("completed")
        expect(call.duration_seconds).to eq(120)
        expect(call.recording_url).to eq("https://storage.vapi.ai/recordings/call_abc123.mp3")
        expect(call.transcript).to include("Agent: Hello")
        expect(call.transcript).to include("Customer: I need a quote")
        expect(call.vapi_cost).to eq(0.15)
        expect(call.started_at).to be_a(Time)
        expect(call.ended_at).to be_a(Time)
      end

      it "classifies intent from function calls as lead_intake" do
        processor.process
        call = Call.last
        expect(call.intent).to eq("lead_intake")
      end

      context "with scheduling function call" do
        let(:webhook_event) do
          create(:webhook_event,
            provider: "vapi",
            event_id: "call_schedule123",
            event_type: "call.ended",
            payload: {
              "type" => "call.ended",
              "call" => {
                "id" => "call_schedule123",
                "status" => "ended",
                "duration" => 90,
                "functionCalls" => [
                  {
                    "name" => "offer_times",
                    "parameters" => {
                      "times" => [ "Monday 2pm", "Tuesday 10am" ]
                    }
                  }
                ]
              },
              "assistant" => {
                "id" => "asst_123456"
              }
            })
        end

        it "classifies as scheduling" do
          processor.process
          call = Call.last
          expect(call.intent).to eq("scheduling")
        end
      end

      it "increments trial.calls_used counter" do
        expect(trial.calls_used).to eq(0)
        processor.process
        trial.reload
        expect(trial.calls_used).to eq(1)
      end

      it "broadcasts turbo stream updates to trial channel" do
        # Mock ActionCable.server.broadcast
        allow(ActionCable.server).to receive(:broadcast).and_call_original

        processor.process

        # Verify broadcast was called with the correct stream name
        expect(ActionCable.server).to have_received(:broadcast).with(
          "trial:#{trial.id}",
          a_string_including("trial_calls")
        )
      end

      it "extracts lead data from functionCalls" do
        processor.process

        # Get the specific call by vapi_call_id to avoid transaction rollback issues
        call = Call.find_by(vapi_call_id: "call_abc123")
        expect(call).to be_present

        extracted_lead = call.extracted_lead
        # JSONB stores keys as strings, access with string keys
        expect(extracted_lead["name"]).to eq("John Smith")
        expect(extracted_lead["phone"]).to eq("555-123-4567")
        expect(extracted_lead["email"]).to eq("john@example.com")
        expect(extracted_lead["intent"]).to eq("quote_request")
        expect(extracted_lead["notes"]).to eq("Needs quote for new AC unit")
      end

      it "handles function calls with missing data gracefully" do
        # Create a new webhook event with modified payload
        new_webhook_event = create(:webhook_event,
          provider: "vapi",
          event_id: "call_modified123",
          event_type: "call.ended",
          payload: {
            "type" => "call.ended",
            "call" => {
              "id" => "call_modified123",
              "duration" => 120,
              "functionCalls" => [
                {
                  "name" => "capture_lead",
                  "parameters" => {
                    "name" => "Jane Doe",
                    "phone" => nil,
                    "email" => nil,
                    "intent" => "info"
                  }
                }
              ]
            },
            "assistant" => {
              "id" => "asst_123456"
            }
          })

        processor = described_class.new(new_webhook_event)
        processor.process

        call = Call.find_by(vapi_call_id: "call_modified123")
        expect(call).to be_present

        extracted_lead = call.extracted_lead
        # JSONB stores keys as strings
        expect(extracted_lead["name"]).to eq("Jane Doe")
        expect(extracted_lead["intent"]).to eq("info")
        expect(extracted_lead["phone"]).to be_nil
        expect(extracted_lead["email"]).to be_nil
      end
    end

    context "with duplicate vapi_call_id" do
      let!(:existing_call) do
        create(:call, vapi_call_id: "call_abc123", callable: trial)
      end

      let(:webhook_event) do
        create(:webhook_event,
          provider: "vapi",
          event_id: "call_abc123",
          event_type: "call.ended",
          payload: {
            "type" => "call.ended",
            "call" => {
              "id" => "call_abc123",
              "status" => "ended",
              "duration" => 120
            },
            "assistant" => {
              "id" => "asst_123456"
            }
          })
      end

      it "does not create a duplicate Call record" do
        expect { processor.process }.not_to change(Call, :count)
      end

      it "does not increment calls_used twice for the same call" do
        trial.update!(calls_used: 1) # Simulate existing call already counted

        expect { processor.process }.not_to change { trial.reload.calls_used }
      end
    end

    context "with non-call.ended events" do
      let(:webhook_event) do
        create(:webhook_event,
          provider: "vapi",
          event_type: "call.started",
          payload: {
            "type" => "call.started",
            "call" => {
              "id" => "call_abc123",
              "status" => "started"
            },
            "assistant" => {
              "id" => "asst_123456"
            }
          })
      end

      it "does not create a Call record" do
        expect { processor.process }.not_to change(Call, :count)
      end

      it "does not increment calls_used" do
        expect { processor.process }.not_to change { trial.reload.calls_used }
      end
    end

    context "with missing assistant_id" do
      let(:webhook_event) do
        create(:webhook_event,
          provider: "vapi",
          payload: {
            "type" => "call.ended",
            "call" => {
              "id" => "call_abc123",
              "duration" => 120
            },
            "assistant" => {
              "id" => "asst_nonexistent"
            }
          })
      end

      it "does not create a Call record" do
        expect { processor.process }.not_to change(Call, :count)
      end

      it "logs a warning" do
        expect(Rails.logger).to receive(:warn).with(/No trial found for assistant_id/)
        processor.process
      end
    end

    context "with missing call data" do
      let(:webhook_event) do
        create(:webhook_event,
          provider: "vapi",
          payload: {
            "type" => "call.ended",
            "call" => nil,
            "assistant" => {
              "id" => "asst_123456"
            }
          })
      end

      it "does not create a Call record" do
        expect { processor.process }.not_to change(Call, :count)
      end
    end

    context "with malformed timestamps" do
      let(:webhook_event) do
        create(:webhook_event,
          provider: "vapi",
          payload: {
            "type" => "call.ended",
            "call" => {
              "id" => "call_abc123",
              "duration" => 120,
              "startedAt" => "invalid-timestamp",
              "endedAt" => "also-invalid"
            },
            "assistant" => {
              "id" => "asst_123456"
            }
          })
      end

      it "still creates the Call record" do
        expect { processor.process }.to change(Call, :count).by(1)
      end

      it "sets nil for invalid timestamps" do
        processor.process

        call = Call.last
        expect(call.started_at).to be_nil
        expect(call.ended_at).to be_nil
      end
    end

    context "with missing functionCalls array" do
      let(:webhook_event) do
        create(:webhook_event,
          provider: "vapi",
          payload: {
            "type" => "call.ended",
            "call" => {
              "id" => "call_abc123",
              "duration" => 120
            },
            "assistant" => {
              "id" => "asst_123456"
            }
          })
      end

      it "creates Call with empty extracted_lead hash" do
        processor.process

        call = Call.last
        expect(call.extracted_lead).to eq({})
      end
    end

    context "with race condition (concurrent processing)" do
      let(:webhook_event) do
        create(:webhook_event,
          provider: "vapi",
          event_id: "call_abc123",
          event_type: "call.ended",
          payload: {
            "type" => "call.ended",
            "call" => {
              "id" => "call_abc123",
              "duration" => 120
            },
            "assistant" => {
              "id" => "asst_123456"
            }
          })
      end

      it "handles RecordNotUnique error gracefully" do
        # Create a call first so find_or_initialize_by will find it
        create(:call, vapi_call_id: "call_abc123", callable: trial)

        # Mock find_or_initialize_by to return a new call
        new_call = Call.new
        allow(Call).to receive(:find_or_initialize_by).and_return(new_call)
        allow(new_call).to receive(:save!).and_raise(ActiveRecord::RecordNotUnique.new("Duplicate key"))

        # Mock find_by to return the existing call
        existing_call = Call.find_by!(vapi_call_id: "call_abc123")
        allow(Call).to receive(:find_by).and_return(existing_call)

        # Should not raise an error
        expect { processor.process }.not_to raise_error

        # Should not increment calls_used since the call already existed
        trial.reload
        expect(trial.calls_used).to eq(0) # Not incremented from the duplicate
      end
    end

    context "when processing fails" do
      let(:webhook_event) do
        create(:webhook_event,
          provider: "vapi",
          event_id: "call_abc123",
          event_type: "call.ended",
          payload: {
            "type" => "call.ended",
            "call" => {
              "id" => "call_abc123",
              "duration" => 120
            },
            "assistant" => {
              "id" => "asst_123456"
            }
          })
      end

      before do
        allow_any_instance_of(Call).to receive(:save!).and_raise(StandardError, "Database error")
      end

      it "captures exception in Sentry" do
        expect(Sentry).to receive(:capture_exception).with(
          an_instance_of(StandardError),
          extra: hash_including(webhook_event_id: webhook_event.id, vapi_call_id: "call_abc123")
        )

        expect { processor.process }.to raise_error(StandardError)
      end

      it "logs the error" do
        allow(Sentry).to receive(:capture_exception)
        expect(Rails.logger).to receive(:error).with(/Error processing Vapi call webhook/)

        expect { processor.process }.to raise_error(StandardError)
      end
    end
  end
end
