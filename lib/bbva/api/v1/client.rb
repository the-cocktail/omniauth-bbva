require "bbva/api/v1/services"
require 'bbva/api/base'

module Bbva
  module Api
    module V1

      def self.included(base)
        base.extend Bbva
      end

      module Bbva
        class Client < Base

          def initialize(options = {})
            super
          end

          def refresh_token
            super TOKEN_PATH
          end

          def refresh_token_old
            super TOKEN_PATH
          end

          #User Accounts information (index or show)
          def accounts id=nil
            perform_get(id ? "#{ACCOUNTS_PATH}/#{id}" : ACCOUNTS_PATH)
          end

          def transactions account_id
            perform_get("#{ACCOUNTS_PATH}/#{account_id}/transactions")
          end

          #User Accounts information
          def identity
            perform_get(IDENTITY_PATH)
          end

          #User Cards information (index or show)
          def cards id=nil
            perform_get(id ? "#{CARDS_PATH}/#{id}" : CARDS_PATH)
          end

          # def transfer
          #   body = {
          #     "transfer": {
          #       "accountId": "ES0182002000000000000000000040773403XXXXXXXXX",
          #       "remoteAccount": {
          #         "name": "Yanis Varoufakis",
          #         "number": "ES8101822082180000012345",
          #         "type": "iban"    
          #       },
          #       "value": {
          #         "amount": "100.01",
          #         "currency": "EUR"
          #       },
          #       "expensesType": {
          #         "id": "A"
          #       },
          #       "description": "Send money to Varoufakis"
          #     }
          #   }
          #   perform_post("me/transfers", body) 
          # end          
        end
      end
    
    end
  end
end