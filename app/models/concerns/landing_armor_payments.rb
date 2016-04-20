module LandingArmorPayments
  

  module Order
    extend ActiveSupport::Concern

    included do
      field :armor_seller_user_id, type: String
      field :armor_seller_account_id, type: String
      field :armor_buyer_user_id, type: String
      field :armor_order_id, type: String
    end

    def api_create_order
      should_use_sandbox = true
      client = ArmorPayments::API.new ENV["ARMOR_KEY"], ENV["ARMOR_SECRET"], should_use_sandbox
      account_id = self.armor_seller_account_id # The account_id of the seller
      order_data = {
        "seller_id" => self.armor_seller_user_id, # The user_id of the seller
        "buyer_id" => self.armor_buyer_user_id, # The user_id of the buyer
        "amount" => self.total_price,
        "summary" => "Goods order. Buyer: #{self.orderer_company_name} Seller: #{self.brand_company_name}"
        # "description" => "An escrow for goods order for use as an example.",
        # "invoice_num" => "12345",
        # "purchase_order_num" => "67890",
        # "message" => "Hello, Example Buyer! Thank you for your example goods order."
      }
      response = client.orders(account_id).create(order_data) # Store result.order_id in the local DB
      case response.status
      when 200 #OK
        order_id = response.data[:body]["order_id"]
        return true, order_id
      else # all other statuses
        # errors = response.data[:body]["errors"]
        return false, response
      end
    end
  end

  module Company
    extend ActiveSupport::Concern

    included do
      field :armor_account_id, type: String
    end

    def api_get_bank_details_form(user)
      require 'armor_payments'
      should_use_sandbox = true
      client = ArmorPayments::API.new ENV["ARMOR_KEY"], ENV["ARMOR_SECRET"], should_use_sandbox

      account_id = self.armor_account_id # The account_id of the user adding bank details
      user_id = user.armor_user_id # The user_id of the user adding bank details

      auth_data = {     
        'uri' => "/accounts/#{self.armor_account_id}/bankaccounts",
        'action' => 'create' 
      }
      response = client.accounts.users(account_id).authentications(user_id).create(auth_data)

      case response.status
      when 200 #OK
        url = response.data[:body]["url"]
        return true, url
      when 400 #ERROR
        errors = response.data[:body]["errors"]
        return false, errors
      end
    end

    def can_sell?
      return true if self.armor_account_id
    end
  end

  module User
    extend ActiveSupport::Concern

    included do
      field :armor_user_id, type: String
      scope :with_armor_user_id, ->{where(:armor_user_id.ne => nil)}
    end

    def can_order?
      return true if self.armor_user_id
    end

    def allows_armor_signup
      if self.email_confirmed
        allow = true
        armor_missing = []
        armor_errors = Hash.new
        if self.company.company_name.blank?
          allow = false
          armor_missing << "Company Name"
        end
        if self.company.address.address1.blank?
          allow = false
          armor_missing << "Address"
        end
        if self.company.address.city.blank?
          allow = false
          armor_missing << "City/Town/Department"
        end
        if self.company.address.state.blank?
          allow = false
          armor_missing << "State/Provice/Region/County"
        end
        if self.company.address.in_us && self.company.address.state.present? && !self.company.address.state_2_test
          allow = false
          armor_errors[:state] = "#{self.company.address.state} not a US state"
        end
        if self.company.address.postcode.blank?
          allow = false
          armor_missing << "Zip/Postcode"
        end
        if self.company.address.country.blank?
          allow = false
          armor_missing << "Country"
        end
        if self.company.address.country.present? && !self.company.address.country_2
          allow = false
          armor_errors[:country] = "#{self.company.address.country} is not a valid Country"
        end
        if self.contact.firstname.blank?
          allow = false
          armor_missing << "First Name"
        end
        if self.contact.lastname.blank?
          allow = false
          armor_missing << "Last Name"
        end
        if self.contact.phone.blank?
          allow = false
          armor_missing << "Phone"
        end
        if allow
          return true, nil
        else
          return false, armor_missing, armor_errors
        end
      end
    end

    def api_create_armor_payments_account
      require 'armor_payments'
      should_use_sandbox = true
      client = ArmorPayments::API.new ENV["ARMOR_KEY"], ENV["ARMOR_SECRET"], should_use_sandbox

      account_data = {
        "company" => "#{self.company.company_name}",
        "user_name" => "#{self.contact.firstname} #{self.contact.lastname} ",
        "user_email" => "#{self.email}",
        "user_phone" => "#{self.contact.phone.phony_formatted(format: '+%{cc} %{trunk}%{ndc}%{local}', :local_spaces => '')}",
        "address" => "#{self.company.address.address1} #{self.company.address.address2}",
        "city" => "#{self.company.address.city}",
        "state" => "#{self.company.address.state_2}",
        "zip" => "#{self.company.address.postcode}",
        "country" => "#{self.company.address.country_2.downcase}",
        "email_confirmed" => true,
        "agreed_terms" => true
      }

      response = client.accounts.create(account_data)

      case response.status.to_i
      when 200 #OK
        new_account_id = response.data[:body]["account_id"]
        # set company.armor_account_id
        if new_account_id.present?
          self.company.armor_account_id = new_account_id
          self.company.save!
          # set user.armor_user_id
          success, ap_user_id = self.api_get_armor_payments_user_id
          if success
            self.armor_user_id = ap_user_id
            self.save!
          else
            return false, "Couldn't save User ID"
          end
          return true, nil
        else
          return false, "Couldn't save Account ID or User ID"
        end
      when 400 #ERROR
        errors = response.data[:body]["errors"]
        return false, errors
      end
    end

    def api_get_armor_payments_user_id
      require 'armor_payments'
      if self.company.armor_account_id
        should_use_sandbox = true
        client = ArmorPayments::API.new ENV["ARMOR_KEY"], ENV["ARMOR_SECRET"], should_use_sandbox
        account_id = self.company.armor_account_id
        response = client.accounts.users(account_id).all

        case response.status
        when 200 #OK
          new_user_id = response.data[:body][0]["user_id"]
          return true, new_user_id
        when 400 #ERROR
          errors = response.data[:body]["errors"]
          return false, errors
        end
      end
    end

  end
end