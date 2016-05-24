module LandingArmorPayments
  
  module User
    extend ActiveSupport::Concern

    included do
      field :armor_user_id, type: String
      field :armor_email, type: String
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
      
      client = LandingArmorClient.new

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
        "email_confirmed" => false,
        "agreed_terms" => true
      }

      if client.create_account(account_data)
        if client.account_id.present?
          self.company.armor_account_id = client.account_id # set company armor_account_id
          if client.get_user_info(self.company.armor_account_id) #set user armor_user_id and armor_email
            self.armor_user_id = client.user_id
            self.armor_email = client.user_email
            self.save!
            self.company.save!
          else
            self.errors[:base] << client.errors
          end
        else
          self.errors[:base] << "Unable to save Armor Account ID (err: 1)"  
        end
      else
        self.errors[:base] << client.errors
      end

    end

  end



  module Company
    extend ActiveSupport::Concern

    included do
      field :armor_account_id, type: String
    end

    def can_sell?
      return true if self.armor_account_id
    end
  end

  module Order
    extend ActiveSupport::Concern

    included do
      field :armor_seller_user_id, type: String
      field :armor_seller_account_id, type: String
      field :armor_buyer_user_id, type: String
      field :armor_order_id, type: String
    end

    def api_create_order

      client = LandingArmorClient.new

      account_id = self.armor_seller_account_id # The account_id of the seller
      order_data = {
        "seller_id" => self.armor_seller_user_id, # The user_id of the seller
        "buyer_id" => self.armor_buyer_user_id, # The user_id of the buyer
        "amount" => self.total_price,
        "summary" => "Goods order. Buyer: #{self.orderer_company_name} Seller: #{self.brand_company_name}",
        "payees" => [
          {
            "user_id" => 160405184951,
            "amount" => self.subtotal_price * 0.01, # 8 percent of the cost of goods
            "message" => "Hello, Landing! Here's your cut.",
            "role" => "broker"
          }
        ] 
        # "description" => "An escrow for goods order for use as an example.",
        # "invoice_num" => "12345",
        # "purchase_order_num" => "67890",
        # "message" => "Hello, Example Buyer! Thank you for your example goods order."
      }
      if client.create_order(account_id, order_data)
        self.armor_order_id = client.order_id
        self.save!
      else
        self.errors[:base] << client.errors
      end
    end

    def api_get_payment_url(user)

      client = LandingArmorClient.new

      account_id = user.company.armor_account_id # The account_id of the user viewing payment instructions (the buyer for the order)
      user_id = user.armor_user_id # The user_id of the user viewing the payment instructions
      auth_data = {
        'uri' => "/accounts/#{self.armor_seller_account_id}/orders/#{self.armor_order_id}/paymentinstructions",
        'action' => 'view'
      }
      
      if client.get_payment_url(account_id, user_id, auth_data)
        return client.url
      else
        self.errors[:base] << client.errors
      end

    end

  end


  class LandingArmorClient
    require 'armor_payments'

    def initialize
      should_use_sandbox = true
      @client = ArmorPayments::API.new ENV["ARMOR_KEY"], ENV["ARMOR_SECRET"], should_use_sandbox
    end

    def create_account(account_data)
      response = @client.accounts.create(account_data)
      return parse_response(response, "account_id")
    end
    def account_id
      return @account_id
    end

    def get_user_info(account_id)
      response = @client.accounts.users(account_id).all
      if parse_response_user(response, "user_id") && parse_response_user(response, "email")
        return true
      else
        return false
      end
    end
    def user_id
      return @user_id
    end
    def user_email
      return @email
    end

    def create_order(account_id, order_data)
      response = @client.orders(account_id).create(order_data) # Store result.order_id in the local DB
      return parse_response(response, "order_id")
    end
    def order_id
      return @order_id
    end

    def get_payment_url(account_id, user_id, auth_data)
      response = @client.accounts.users(account_id).authentications(user_id).create(auth_data)
      return parse_response(response, "url")
    end
    def url
      return @url
    end

    def errors
      return @errors
    end

    private

    def parse_response(response, item)
      case response.status.to_i
      when 200 #OK
        varname = "@#{item}"
        value = response.data[:body][item]
        self.instance_variable_set varname, value
        return true
      else # all other statuses
        @errors = "Response Status: #{response.status} - #{response.data[:body]['errors']}"
        return false
      end
    end

    def parse_response_user(response, item)
      case response.status.to_i
      when 200 #OK
        varname = "@#{item}"
        value = response.data[:body][0][item]
        self.instance_variable_set varname, value
        return true
      else # all other statuses
        @errors = "Response Status: #{response.status} - #{response.data[:body]['errors']}"
        return false
      end
    end

  end

end