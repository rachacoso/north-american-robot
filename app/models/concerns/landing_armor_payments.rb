module LandingArmorPayments
  
  module User
    extend ActiveSupport::Concern

    included do
      field :armor_user_id, type: String
      field :armor_email, type: String
      scope :with_armor_user_id, ->{where(:armor_user_id.ne => nil)}
    end

    def can_order?
      return true if self.armor_user_id  && self.company_type != "Brand"
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
      
      armoraccount = LandingArmorAccount.new

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

      # create armor account
      armoraccount.create(account_data)
      if armoraccount.errors.any?
        self.errors[:base] << armoraccount.errors.full_messages
      else
        if armoraccount.account_id.present?
          self.company.armor_account_id = armoraccount.account_id # set company armor_account_id
          #get user armor_user_id and armor_email
          armoraccount.get_user_info(self.company.armor_account_id)
          if armoraccount.errors.any? # if errors in getting user info
            self.errors[:base] << armoraccount.errors.full_messages
          else
            #set user armor_user_id and armor_email
            self.armor_user_id = armoraccount.user_id
            self.armor_email = armoraccount.email
            self.save!
            self.company.save!
          end
        else
          self.errors[:base] << "Unable to save Armor Account ID (err: 1)"  
        end
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
      field :armor_seller_email, type: String
      field :armor_seller_account_id, type: String
      field :armor_buyer_user_id, type: String
      field :armor_buyer_email, type: String
      field :armor_buyer_account_id, type: String
      field :armor_order_id, type: String
      field :armor_shipment_id, type: String
      field :armor_other_shipper, type: String # name of other shipper if not in Armor List
      field :armor_shipment_tracking_number, type: String
      field :armor_shipment_description, type: String
    end

    def api_create_order

      armororder = LandingArmorOrder.new

      account_id = self.armor_seller_account_id # The account_id of the seller
      order_data = {
        "seller_id" => self.armor_seller_user_id, # The user_id of the seller
        "buyer_id" => self.armor_buyer_user_id, # The user_id of the buyer
        "amount" => self.total_price,
        "summary" => "Landing International. Purchase of goods from #{self.brand_company_name} by #{self.orderer_company_name}",
        # "payees" => [
        #   {
        #     "user_id" => 160423016973,
        #     "amount" => self.subtotal_price * 0.02, # 8 percent of the cost of goods
        #     "message" => "Hello, Landing International! Here's your 8% fee share.",
        #     "role" => "broker"
        #   }
        # ]
        # "description" => "An escrow for goods order for use as an example.",
        # "invoice_num" => "12345",
        # "purchase_order_num" => "67890",
        # "message" => "Hello, Example Buyer! Thank you for your example goods order."
      }

      armororder.create(account_id, order_data)

      if armororder.errors.any?
        self.errors[:base] << armororder.errors.full_messages
      else
        self.armor_order_id = armororder.order_id
        self.save!
      end

    end

    def api_get_payment_url(user)

      armororder = LandingArmorOrder.new

      account_id = user.company.armor_account_id # The account_id of the user viewing payment instructions (the buyer for the order)
      user_id = user.armor_user_id # The user_id of the user viewing the payment instructions
      auth_data = {
        'uri' => "/accounts/#{self.armor_seller_account_id}/orders/#{self.armor_order_id}/paymentinstructions",
        'action' => 'view'
      }
      
      armororder.get_payment_info(account_id, user_id, auth_data)

      if armororder.errors.any?
        self.errors[:base] << armororder.errors.full_messages
      else
        return armororder.url
      end

    end

    def api_add_shipment_info(carrier_id:,tracking_id:,description:,other_shipper:)
      armororder = LandingArmorOrder.new
      account_id = self.armor_seller_account_id
      order_id = self.armor_order_id
      action_data = {
        "user_id" => self.armor_seller_user_id, # The user_id of the user shipping the goods (usually the seller on the order)     
        "carrier_id" => carrier_id,
        "tracking_id" => tracking_id,
        "description" => description
      }
      armororder.add_shipment_info(account_id, order_id, action_data)
      if armororder.errors.any?
        self.errors[:base] << armororder.errors.full_messages
      else
        self.armor_shipment_id = armororder.shipment_id
        self.armor_other_shipper = other_shipper if other_shipper.present?
        self.armor_shipment_tracking_number = tracking_id
        self.armor_shipment_description = description
        self.status = "shipped"
        self.save!
      end
    end

    def api_get_shippers
      armorshippers = LandingArmorShippers.new
      armorshippers.get_list
      if armorshippers.errors.any?
        self.errors[:base] << armorshippers.errors.full_messages
      else
        return armorshippers.list
      end
    end

  end


  class LandingArmorClient
    extend ActiveModel::Naming
    require 'armor_payments'
    attr_reader   :errors

    def initialize
      @errors = ActiveModel::Errors.new(self)
      should_use_sandbox = true
      # @client =  ArmorPayments::API.new ENV["ARMOR_KEY"], ENV["ARMOR_SECRET"], should_use_sandbox
      @client =  ArmorPayments::API.new Rails.configuration.armor_payments[:key], Rails.configuration.armor_payments[:secret], should_use_sandbox
    end

    protected

    def parse_response(response, item)
      case response.status.to_i
      when 200 #OK
        varname = "@#{item}"
        value = response.data[:body][item]
        self.instance_variable_set varname, value
      else # all other statuses
        self.errors[:base] << "Response Status: #{response.status} - Headers:#{response.headers} Errors:#{response.data[:body]['errors']}"
      end
    end

    def parse_response_user(response, item)
      case response.status.to_i
      when 200 #OK
        varname = "@#{item}"
        value = response.data[:body][0][item]
        self.instance_variable_set varname, value
      else # all other statuses
        self.errors[:base] << "Response Status: #{response.status} - #{response.data[:body]['errors']}"
      end
    end
  end

  class LandingArmorAccount < LandingArmorClient
    attr_reader :account_id, :user_id, :email

    def create(account_data)
      response = @client.accounts.create(account_data)
      parse_response(response, "account_id")
    end

    def get_user_info(account_id)
      response = @client.accounts.users(account_id).all
      parse_response_user(response, "user_id")
      parse_response_user(response, "email")
    end

  end

  class LandingArmorOrder < LandingArmorClient
    attr_reader :url, :order_id, :shipment_id

    def create(account_id, order_data)
      response = @client.orders(account_id).create(order_data) # Store result.order_id in the local DB
      parse_response(response, "order_id")
    end

    def get_payment_info(account_id, user_id, auth_data)
      response = @client.accounts.users(account_id).authentications(user_id).create(auth_data)
      parse_response(response, "url")
    end

    def add_shipment_info(account_id, order_id, action_data)
      response = @client.orders(account_id).shipments(order_id).create(action_data)
      parse_response(response, "shipment_id")
    end

  end

  class LandingArmorShippers < LandingArmorClient
    attr_reader :list
    def get_list
      response = @client.shipmentcarriers.all
      case response.status.to_i
      when 200 #OK
        varname = "@list"
        value = response.data[:body]
        self.instance_variable_set varname, value
      else # all other statuses
        self.errors[:base] << "Response Status: #{response.status} - #{response.data[:body]['errors']}"
      end
    end

  end
end