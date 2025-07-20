class HydraService
  include HTTParty

  base_uri ENV.fetch("HYDRA_ADMIN_URL", "http://127.0.0.1:5445")

  def self.get_login_request(challenge)
    response = get("/oauth2/auth/requests/login", {
      query: { login_challenge: challenge }
    })
    handle_response(response)
  end

  def self.accept_login_request(challenge, params)
    response = put("/oauth2/auth/requests/login/accept", {
      query: { login_challenge: challenge },
      body: params.to_json,
      headers: { "Content-Type" => "application/json" }
    })
    handle_response(response)
  end

  def self.reject_login_request(challenge, params)
    response = put("/oauth2/auth/requests/login/reject", {
      query: { login_challenge: challenge },
      body: params.to_json,
      headers: { "Content-Type" => "application/json" }
    })
    handle_response(response)
  end

  def self.get_consent_request(challenge)
    response = get("/oauth2/auth/requests/consent", {
      query: { consent_challenge: challenge }
    })
    handle_response(response)
  end

  def self.accept_consent_request(challenge, params)
    response = put("/oauth2/auth/requests/consent/accept", {
      query: { consent_challenge: challenge },
      body: params.to_json,
      headers: { "Content-Type" => "application/json" }
    })
    handle_response(response)
  end

  def self.reject_consent_request(challenge, params)
    response = put("/oauth2/auth/requests/consent/reject", {
      query: { consent_challenge: challenge },
      body: params.to_json,
      headers: { "Content-Type" => "application/json" }
    })
    handle_response(response)
  end

  def self.introspect_token(token)
    response = post("/oauth2/introspect", {
      body: { token: token },
      headers: { "Content-Type" => "application/x-www-form-urlencoded" }
    })
    handle_response(response)
  end

  private

  def self.handle_response(response)
    if response.success?
      response.parsed_response
    else
      raise "Hydra API error: #{response.code} - #{response.body}"
    end
  end
end
