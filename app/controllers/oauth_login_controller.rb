class OauthLoginController < ApplicationController
  skip_before_action :require_authentication
  protect_from_forgery with: :exception

  # Hydraからログイン画面リダイレクト GET /oauth/login?challenge=...
  def show
    challenge = params[:login_challenge]

    if challenge.blank?
      render plain: "Expected a login challenge to be set but received none.", status: :bad_request
      return
    end

    begin
      @login_request = HydraService.get_login_request(challenge)
      @challenge = challenge

      # ユーザーへログイン画面表示
      if @login_request["skip"]
        accept_params = {
          subject: @login_request["subject"]
        }

        result = HydraService.accept_login_request(challenge, accept_params)
        redirect_to result["redirect_to"], allow_other_host: true
        return
      end

      @hint = @login_request.dig("oidc_context", "login_hint") || ""

    rescue => e
      render plain: "Error: #{e.message}", status: :internal_server_error
    end
  end

  # POST /oauth/login (email, password)
  def create
    challenge = params[:challenge]

    if params[:submit] == "Deny access"
      reject_params = {
        error: "access_denied",
        error_description: "The resource owner denied the request"
      }

      begin
        result = HydraService.reject_login_request(challenge, reject_params)
        redirect_to result["redirect_to"], allow_other_host: true
      rescue => e
        render plain: "Error: #{e.message}", status: :internal_server_error
      end
      return
    end

    user = User.find_by(email_address: params[:email])

    unless user&.authenticate(params[:password])
      @challenge = challenge
      @error = "メールアドレスまたはパスワードが正しくありません"
      render :show
      return
    end

    begin
      accept_params = {
        subject: user.email_address,
        remember: params[:remember] == "1",
        remember_for: 3600,
        acr: "0"
      }

      # Hydraへログイン承認送信 POST /oauth2/auth/requests/login/accept
      result = HydraService.accept_login_request(challenge, accept_params)
      redirect_to result["redirect_to"], allow_other_host: true

    rescue => e
      Rails.logger.error "Login error: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      render plain: "Error: #{e.message}", status: :internal_server_error
    end
  end
end
