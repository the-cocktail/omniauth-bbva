require "oauth2"
require "omniauth"
require "securerandom"
require "socket"       # for SocketError
require "timeout"      # for Timeout::Error

module OmniAuth
  module Strategies
    # Authentication strategy for connecting with APIs constructed using
    # the [OAuth 2.0 Specification](http://tools.ietf.org/html/draft-ietf-oauth-v2-10).
    # You must generally register your application with the provider and
    # utilize an application id and secret in order to authenticate using
    # OAuth 2.0.

    #DEFAULT SANDBOX URI
    SBX_SITE          = 'https://connect.bbva.com'
    SBX_AUTH_URL      = 'https://connect.bbva.com/sandboxconnect'
    SBX_TOKEN_URL     = 'https://connect.bbva.com/token'
    SBX_REDIRECT_URI  = 'http://localhost:3000/auth/bbva/callback'

    #DEFAULT PRODUCTION URI
    PRO_SITE          = 'https://connect.bbva.com'
    PRO_AUTH_URL      = 'https://connect.bbva.com/sandboxconnect'
    PRO_TOKEN_URL     = 'https://connect.bbva.com/token'
    PRO_REDIRECT_URI  = 'http://localhost:3000/auth/bbva/callback'

    class Bbva
      include OmniAuth::Strategy

      def self.inherited(subclass)
        OmniAuth::Strategy.included(subclass)
      end

      args [:client_id, :client_secret, :opts]

      option :client_id, nil
      option :client_secret, nil
      option :opts, nil
      option :client_options, {}
      option :authorize_params, {}
      option :authorize_options, [:scope]
      option :token_params, {}
      option :token_options, []
      option :auth_token_params, {}
      option :provider_ignores_state, false

      attr_accessor :access_token

      def client
        ::OAuth2::Client.new(options.client_id, options.client_secret, deep_symbolize(options.client_options))
      end

      credentials do
        hash = {"token" => access_token.token}
        hash.merge!("refresh_token" => access_token.refresh_token) if access_token.expires? && access_token.refresh_token
        hash.merge!("expires_at" => access_token.expires_at) if access_token.expires?
        hash.merge!("expires" => access_token.expires?)
        hash.merge!("code" => request.params["code"])
        hash
      end

      #Setup client_options
      def setup_phase
        if options.environment == 'production'
          options.client_options.site           = options.site          || PRO_SITE
          options.client_options.authorize_url  = options.authorize_url || PRO_AUTH_URL
          options.client_options.token_url      = options.token_url     || PRO_TOKEN_URL
          options.client_options.redirect_uri   = options.redirect_uri  || PRO_REDIRECT_URI
        else
          options.client_options.site           = options.site          || SBX_SITE
          options.client_options.authorize_url  = options.authorize_url || SBX_AUTH_URL
          options.client_options.token_url      = options.token_url     || SBX_TOKEN_URL
          options.client_options.redirect_uri   = options.redirect_uri  || SBX_REDIRECT_URI
        end
      end

      def request_phase
        redirect client.auth_code.authorize_url({:redirect_uri => callback_url}.merge(authorize_params))
      end

      def authorize_params
        options.authorize_params[:state] = SecureRandom.hex(24)
        params = options.authorize_params.merge(options_for("authorize"))
        if OmniAuth.config.test_mode
          @env ||= {}
          @env["rack.session"] ||= {}
        end
        session["omniauth.state"] = params[:state]
        params
      end


      def token_params
        options.token_params.merge(options_for("token"))
      end


      def callback_phase

        error = request.params["error_reason"] || request.params["error"]
        if error
          fail!(error, CallbackError.new(request.params["error"], request.params["error_description"] || request.params["error_reason"], request.params["error_uri"]))
        # elsif !options.provider_ignores_state && (request.params["state"].to_s.empty? || request.params["state"] != session.delete("omniauth.state"))
        #   fail!(:csrf_detected, CallbackError.new(:csrf_detected, "CSRF detected (missing or incorrect 'state' )"))
        else
          self.access_token = build_access_token
          self.access_token = access_token.refresh! if access_token.expired?
          super
        end
      rescue ::OAuth2::Error, CallbackError => e
        fail!(:invalid_credentials, e)
      rescue ::Timeout::Error, ::Errno::ETIMEDOUT => e
        fail!(:timeout, e)
      rescue ::SocketError => e
        fail!(:failed_to_connect, e)
      end

    protected

      def build_access_token
        verifier    = request.params["code"]
        basic_auth  = build_basic_auth
        client.auth_code.get_token(verifier, 
          :redirect_uri => client.options[:redirect_uri], 
          :headers => {'Authorization' => basic_auth})
      end


      def build_basic_auth
        "Basic #{Base64.strict_encode64("#{client.id}:#{client.secret}")}"
      end

      def deep_symbolize(options)
        hash = {}
        options.each do |key, value|
          hash[key.to_sym] = value.is_a?(Hash) ? deep_symbolize(value) : value
        end
        hash
      end

      def options_for(option)
        hash = {}
        options.send(:"#{option}_options").select { |key| options[key] }.each do |key|
          hash[key.to_sym] = options[key]
        end
        hash
      end

      # An error that is indicated in the OAuth 2.0 callback.
      # This could be a `redirect_uri_mismatch` or other
      class CallbackError < StandardError
        attr_accessor :error, :error_reason, :error_uri

        def initialize(error, error_reason = nil, error_uri = nil)
          self.error = error
          self.error_reason = error_reason
          self.error_uri = error_uri
        end

        def message
          [error, error_reason, error_uri].compact.join(" | ")
        end
      end
    end
  end
end

OmniAuth.config.add_camelization "bbva", "Bbva"
