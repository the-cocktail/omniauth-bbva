require 'httparty'
require 'rest-client'
module Bbva
  module Api
    
    class Base
      include HTTParty
      attr_accessor :token, :secret, :code, :refresh_token, :client_id

      def initialize(options = {})
        options.each do |key, value|
          instance_variable_set("@#{key}", value)
        end
        yield(self) if block_given?
      end

      def credentials
        {
          secret:         secret,
          code:           code,
          token:          token,
          refresh_token:  refresh_token,
          client_id:      client_id
        }
      end

      def refresh_token path
        refresh_token_path = "#{path}?grant_type=refresh_token"
        RestClient.post refresh_token_path,
        {:refresh_token => @refresh_token},
          :Authorization => "Basic #{Base64.strict_encode64("#{@client_id}:#{@secret}")}"   
      end

      private
      
        def perform_get url
            response  = RestClient.get url, :content_type => "application/json", :Authorization => "jwt #{@token}"
            JSON.parse(response)["data"].with_indifferent_access
        end

    end

  end
end