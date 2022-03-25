class KeycloakController < ApplicationController
 ## initialize global keycloak variables
  def initialize

    @keycloak_client_id         = "ruby-demo"
    @keycloak_client_secret     = "0805a3e5-c384-4bb5-aa68-cc118e1eb3af"
    @keycloak_redirect_uri      = "http://localhost:3000/keycloak-callback"
    @keycloak_authorization_url = "http://localhost:8080/auth/realms/oidc_demo/protocol/openid-connect/auth"
    @keycloak_token_url         = "http://localhost:8080/auth/realms/oidc_demo/protocol/openid-connect/token"
    @keycloak_attributes_url    = "http://localhost:8080/auth/realms/oidc_demo/protocol/openid-connect/userinfo"


    @oauth_client = OAuth2::Client.new(@keycloak_client_id, @keycloak_client_secret, :authorize_url => @keycloak_authorization_url, :token_url => @keycloak_token_url)
  end

  # LOGIN 
  def login
    redirect_to @oauth_client.auth_code.authorize_url(:redirect_uri => @keycloak_redirect_uri)
  end

# The OAuth callback
  def oauth_callback
      
    # Make a call to exchange the authorization_code for an access_token
    auth_code = @oauth_client.auth_code.get_token(params[:code], :redirect_uri => @keycloak_redirect_uri)

    @token = auth_code.to_hash[:access_token]

    uri = URI.parse("#{@keycloak_attributes_url}")
      request = Net::HTTP::Get.new(uri)                                
      request["Authorization"] = "Bearer #{@token}"
    
      req_options = {
      use_ssl: uri.scheme == "https",
    }
    
      response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request(request)
      end

    #simple rendering User Attributes JSON
    render json: (response.body)

    # # Index.html.erb (sanity check)
    # render :index

    # # Simple Hello Message (Sanity Check)
    # render json: {message: "Hello"}

  end

  # LOGOUT of current session (Work in Progress-15Mar22)
  def logout

    # # First attempt at LOGOUT using Keycloak Post
    # HTTP.post("http://localhost:8080/auth/realms/oidc_demo/protocol/openid-connect/logout?redirect_uri=encodedRedirectUri ")

    # # Second attempt at Logout
    # uri = URI('http://localhost:8080/auth/realms/oidc_demo/protocol/openid-connect/logout?redirect_uri=encodedRedirectUri')
    # res = Net::HTTP.post_form(uri)

    # Reset Rails session
    reset_session

    redirect_to root_url
  end



end


