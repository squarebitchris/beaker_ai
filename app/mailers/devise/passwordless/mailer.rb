# frozen_string_literal: true

module Devise
  module Passwordless
    class Mailer < Devise::Mailer
      def magic_link(record, token, remember_me, opts = {})
        @token = token
        @remember_me = remember_me
        @scope_name = Devise::Mapping.find_scope!(record)
        devise_mail(record, :magic_link, opts)
      end
    end
  end
end

