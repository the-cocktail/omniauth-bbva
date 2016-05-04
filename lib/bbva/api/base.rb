require 'httparty'
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
          begin
            response  = RestClient.get url, :content_type => "application/json", :Authorization => "jwt #{@token}"
            JSON.parse(response)["data"].with_indifferent_access
          rescue Exception => e
            []
          end
        end

        def perform_post_httparty
          url = "https://apis.bbva.com/money-transfers-sbx/v1/me/transfers"
          opts = {
            body: body.to_json,
            :headers => { 
              "Authorization" => "Basic #{Base64.strict_encode64("#{@client_id}:#{@secret}")}",
              "Content-Type" => "application/json"
            }
          }
          HTTParty.post(url,opts)
        end


        def perform_post path, body
          url = "https://apis.bbva.com/money-transfers-sbx/v1/me/transfers"
          binding.pry
          RestClient.post url,
          {:body => body},
            :content_type => "application/json",
            :Authorization => "Basic #{Base64.strict_encode64("#{@client_id}:#{@secret}")}"   
        end



    end

  end
end