module Api
  module V1
    class UserController < ApplicationController
      skip_before_action :require_authentication
      skip_before_action :verify_authenticity_token

      def profile
        token = extract_bearer_token

        unless token
          render json: { error: "No token provided" }, status: :unauthorized
          return
        end

        begin
          introspection_result = HydraService.introspect_token(token)
          Rails.logger.info "Introspection result: #{introspection_result}"

          unless introspection_result["active"]
            render json: { error: "Invalid or expired token" }, status: :unauthorized
            return
          end

          user_email = introspection_result["sub"]
          user = User.find_by(email_address: user_email)

          unless user
            render json: { error: "User not found" }, status: :not_found
            return
          end

          render json: {
            name: user.name,
            email: user.email_address
          }

        rescue => e
          Rails.logger.error "API Error: #{e.message}"
          render json: { error: "Service unavailable" }, status: :service_unavailable
        end
      end

      private

      def extract_bearer_token
        auth_header = request.headers["Authorization"]
        return nil unless auth_header

        match = auth_header.match(/^Bearer\s+(.+)$/i)
        match[1] if match
      end
    end
  end
end
