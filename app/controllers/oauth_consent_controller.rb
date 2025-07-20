class OauthConsentController < ApplicationController
  skip_before_action :require_authentication
  protect_from_forgery with: :exception

  # 11. Hydraから同意画面リダイレクト GET /oauth/consent?challenge=...
  def show
    challenge = params[:consent_challenge]

    if challenge.blank?
      render plain: "Expected a consent challenge to be set but received none.", status: :bad_request
      return
    end

    begin
      @consent_request = HydraService.get_consent_request(challenge)
      @challenge = challenge

      # 12. ユーザーへ同意画面表示
      if @consent_request["skip"] || @consent_request.dig("client", "skip_consent")
        accept_params = {
          grant_scope: @consent_request["requested_scope"],
          grant_access_token_audience: @consent_request["requested_access_token_audience"],
          session: {
            access_token: {},
            id_token: {}
          }
        }

        result = HydraService.accept_consent_request(challenge, accept_params)
        redirect_to result["redirect_to"], allow_other_host: true
        nil
      end

    rescue => e
      render plain: "Error: #{e.message}", status: :internal_server_error
    end
  end

  # 13. POST /oauth/consent (スコープ許可)
  def create
    challenge = params[:challenge]

    if params[:submit] == "Deny access"
      reject_params = {
        error: "access_denied",
        error_description: "The resource owner denied the request"
      }

      begin
        result = HydraService.reject_consent_request(challenge, reject_params)
        redirect_to result["redirect_to"], allow_other_host: true
      rescue => e
        render plain: "Error: #{e.message}", status: :internal_server_error
      end
      return
    end

    grant_scope = params[:grant_scope]
    grant_scope = [ grant_scope ] unless grant_scope.is_a?(Array)
    grant_scope = grant_scope.compact_blank

    begin
      consent_request = HydraService.get_consent_request(challenge)

      accept_params = {
        grant_scope: grant_scope,
        grant_access_token_audience: consent_request["requested_access_token_audience"],
        session: {
          access_token: {},
          id_token: {}
        },
        remember: params[:remember] == "1",
        remember_for: 3600
      }

      # 14. Hydraへ同意承認送信 POST /oauth2/auth/requests/consent/accept
      result = HydraService.accept_consent_request(challenge, accept_params)
      redirect_to result["redirect_to"], allow_other_host: true

    rescue => e
      render plain: "Error: #{e.message}", status: :internal_server_error
    end
  end
end
