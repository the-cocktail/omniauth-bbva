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


          #User Accounts information (index or show)
          def accounts id=nil
            data = perform_get(id ? "#{ACCOUNTS_PATH}/#{id}" : ACCOUNTS_PATH)
            id ? (data[:account] || {}) : (data[:accounts] || [])
          end

          def transactions account_id
            data = perform_get("#{ACCOUNTS_PATH}/#{account_id}/transactions")
            data[:accountTransactions]  || []
          end

          #User Accounts information
          def identity
            data = perform_get(IDENTITY_PATH)
            data[:client] || {}
          end

          #User Cards information (index or show)
          def cards id=nil
            data = perform_get(id ? "#{CARDS_PATH}/#{id}" : CARDS_PATH)
            id ? (data[:card] || {}) : (data[:cards] || [])
          end

        
        end
      end
    
    end
  end
end