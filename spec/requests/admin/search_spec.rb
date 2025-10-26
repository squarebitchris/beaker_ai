require 'rails_helper'

RSpec.describe 'Admin::Search', type: :request do
  let(:admin_user) { create(:user, email: 'admin@example.com', admin: true) }
  let(:regular_user) { create(:user, email: 'user@example.com', admin: false) }

  before do
    sign_in admin_user
  end

  describe 'GET /admin/search' do
    context 'as admin' do
      context 'with query parameter' do
        it 'searches businesses by name' do
          business = create(:business, name: "Acme Corp")

          get admin_search_path, params: { q: "Acme" }

          expect(response).to have_http_status(:success)
          expect(response.body).to include("Acme Corp")
        end

        it 'searches businesses by stripe_customer_id' do
          business = create(:business, stripe_customer_id: "cus_test123")

          get admin_search_path, params: { q: "cus_test123" }

          expect(response).to have_http_status(:success)
          expect(response.body).to include(business.name)
        end

        it 'searches users by email' do
          user = create(:user, email: "john@example.com")

          get admin_search_path, params: { q: "john@example" }

          expect(response).to have_http_status(:success)
          expect(response.body).to include("j***@example.com")
        end

        it 'searches users with normalized email query' do
          user = create(:user, email: "john@example.com")

          # Search with different casing and formatting
          get admin_search_path, params: { q: "John@EXAMPLE" }

          expect(response).to have_http_status(:success)
          expect(response.body).to include("j***@example.com")
        end

        it 'searches trials by phone' do
          trial = create(:trial, phone_e164: "+15551234567")

          get admin_search_path, params: { q: "5551234567" }

          expect(response).to have_http_status(:success)
          expect(response.body).to include(mask_phone(trial.phone_e164))
        end

        it 'searches trials by business_name' do
          trial = create(:trial, business_name: "Test HVAC", phone_e164: "+15559876543")

          get admin_search_path, params: { q: "Test HVAC" }

          expect(response).to have_http_status(:success)
          expect(response.body).to include("Test HVAC")
        end

        it 'searches calls by phone number' do
          call = create(:call, to_e164: "+15551234567", from_e164: "+15559876543")

          get admin_search_path, params: { q: "5551234567" }

          expect(response).to have_http_status(:success)
          expect(response.body).to include(mask_phone(call.to_e164))
        end

        it 'masks PII in results (email)' do
          user = create(:user, email: "john@example.com")

          get admin_search_path, params: { q: "john" }

          # Should NOT show full email
          expect(response.body).not_to include("john@example.com")
          # Should show masked email
          expect(response.body).to include("j***@example.com")
        end

        it 'masks PII in results (phone)' do
          trial = create(:trial, phone_e164: "+15551234567")

          get admin_search_path, params: { q: "5551234567" }

          # Should NOT show full phone
          expect(response.body).not_to include("+15551234567")
          # Should show masked phone
          expect(response.body).to include("***-***-4567")
        end

        it 'shows no results message when nothing found' do
          get admin_search_path, params: { q: "nonexistent12345" }

          expect(response).to have_http_status(:success)
          expect(response.body).to include('No results found')
        end
      end

      context 'without query parameter' do
        it 'returns empty search form' do
          get admin_search_path

          expect(response).to have_http_status(:success)
          expect(response.body).to include('Search')
          expect(response.body).to include('Search by email, phone, name, or ID')
        end
      end
    end

    context 'as non-admin' do
      before do
        sign_in regular_user
      end

      it 'redirects to root with alert' do
        get admin_search_path, params: { q: "test" }

        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to include("Access denied")
      end
    end
  end

  private

  def mask_phone(phone)
    digits = phone.gsub(/\D/, "")
    last_four = digits[-4..-1]
    "***-***-#{last_four}"
  end
end
