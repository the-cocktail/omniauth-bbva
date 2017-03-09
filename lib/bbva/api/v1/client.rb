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
          # Account Structure
          # account.id            Account identifier. For example : ES0182002000000000500000000332046493XXXXXXXXX
          # account.alias         Assigned alias for the account (if any)
          # account.type          This code maps the account type. There are two possible values: [01: Cuenta corriente, 02: Cuenta crédito]
          # account.number        Last 4 digits of account's ccc
          # account.balance       Account current balance. Example: 5215.2
          # account.currency      Currency for this account. Example: EUR
          # account.formats.iban  Account iban number. Example: 01824000002000000000179829
          # account.formats.ccc   Account ccc number. Example: 01824000610201798298
          def accounts id=nil
            data = perform_get(id ? "#{ACCOUNTS_PATH}/#{id}" : ACCOUNTS_PATH)
            id ? (data[:account] || {}) : (data[:accounts] || [])
          end

          #Account transaction information
          # Response's body fields for "data" node
          # Field Description
          # accountTransactions This field is an array of account transactions objects
          # accountTransactions[X].id                   Transaction identifier
          # accountTransactions[X].accountNumber        CCC of the account
          # accountTransactions[X].date                 Date when the transaction has been executed. Important Currently, the time is always 00:00:00.000Z
          # accountTransactions[X].amount               Money amount involved in the transaction
          # accountTransactions[X].currency             Currency
          # accountTransactions[X].description          Description asociated to the transaction
          # accountTransactions[X].category             Category
          # accountTransactions[X].category.id          Category identifier
          # accountTransactions[X].category.name        Human name for this category
          # accountTransactions[X].subCategory          Subcategory
          # accountTransactions[X].subCategory.id       Subcategory identifier
          # accountTransactions[X].subCategory.name     Human name for this subcategory
          # accountTransactions[X].clientNotes[Y].text  Note created by the Client
          # accountTransactions[X].clientNotes[Y].date  Date when the note was created
          # accountTransactions[X].attachedInfo[Y].name Name of the attached file
          # accountTransactions[X].attachedInfo[Y].type Type of the attached file
          # accountTransactions[X].attachedInfo[Y].size Size of the attached file
          # accountTransactions[X].attachedInfo[Y].date Date of the attached file
          def transactions account_id
            data = perform_get("#{ACCOUNTS_PATH}/#{account_id}/transactions")
            data[:accountTransactions]  || []
          end

          #User Accounts information
          # Response's body fields for "data" node.
          # Field Description
          # client.id                        External unique identifier for the client and application performing the request
          # client.name                      Client's name
          # client.surname                   Client's surname
          # client.secondSurname             Client's second surname (this field is optional)
          # client.idDocument                Client's identity document
          # client.birthdate                 Client's birthdate
          # client.address.additionalData    Additional data for client's address
          # client.address.door              Door for client's address
          # client.address.floor             Floor for client's address
          # client.address.locality          Locality for client's address
          # client.address.stairwell         Stairwell for client's address
          # client.address.state             State for client's address
          # client.address.streetName        Street name for client's address
          # client.address.streetNumber      Street number for client's address
          # client.address.streetType        Street type for client's address
          # client.address.zipcode           Zipcode for client's address
          # client.contactInfo.email         Client's email
          # client.contactInfo.phone         Client's phone
          def identity
            data = perform_get(IDENTITY_PATH)
            data[:client] || {}
          end

          #User Cards information (index or show)
          # Response's body fields for "data" node
          # Field Description
          # cards This field is an array of card objects
          # cards[X].id Card          identifier. Example : ES0182061600000000000000000022705730XXXXXXXXX
          # cards[X].alias            Assigned alias for the card. Example: MyAlias
          # cards[X].type             This code maps the card type. There are 3 possible values: [01: Debit Card, 02: Credit Card, 03: Prepaid Card]
          # cards[X].number           Last four account number digits. Example : 9147
          # cards[X].availableBalance Available balance on card. Example: 24
          # cards[X].postedBalance    Posted balance on card (pending for consolidation).
          # cards[X].currency         Currency for this card. Example: EUR
          # cards[X].status           Current status of card. Example : U
          # cards[X].limits           Limits established for the card (atm, pos, credit). Example: {credit,3000}
          # cards[X].description      Card description. Example: WALLET CARD
          # cards[X].links            Related links for this card
          def cards id=nil
            data = perform_get(id ? "#{CARDS_PATH}/#{id}" : CARDS_PATH)
            id ? (data[:card] || {}) : (data[:cards] || [])
          end

          # hasPreApprovedLoan                    Indicates if the client has pre-approved loan. Possible values: [true, false]
          # loanInstallments                      List of loan installments
          # loanInstallments[X].id                Type of loan installment. Possible values: [SHORT, MEDIUM, LONG]
          # loanInstallments[X].period            Wrapper node for period values
          # loanInstallments[X].period.min        Minimum period. Example: 12
          # loanInstallments[X].period.max        Maximum period. Example: 96
          # loanInstallments[X].period.timeUnit   Time unit. Example: MONTH
          # loanInstallments[X].amount            Wrapper node for amount values
          # loanInstallments[X].amount.min        Minimum amount. Example: 1500
          # loanInstallments[X].amount.max        Maximum amount. Example: 30000
          # loanInstallments[X].amount.currency   Currency used for amount fields. Example: EUR

          def loans
            url = "#{LOANS_PATH}/pre-approved"
            data = perform_get(url)
            data || {}
          end

        end
      end

    end
  end
end
