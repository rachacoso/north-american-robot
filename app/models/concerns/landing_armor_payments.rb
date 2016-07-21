module LandingArmorPayments
  
  module User
    extend ActiveSupport::Concern

    included do
      field :armor_user_id, type: String
      field :armor_email, type: String
      scope :with_armor_user_id, ->{where(:armor_user_id.ne => nil)}
    end

    def can_order?
      # return true if self.armor_user_id  && self.company_type != "Brand"
      return true if self.company_type != "Brand" && self.company.company_name.present? #only can order if is not a brand and has company name entered
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
        "email_confirmed" => true,
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
      field :disable_armor_payments, type: Mongoid::Boolean
      field :armor_account_id, type: String
      field :armor_bank_info_complete, type: Mongoid::Boolean, default: false
    end

    def can_sell?
      # return true if self.armor_account_id
      return true if self.company_name.present?
    end

    def set_armor_bank
      self.armor_bank_info_complete = true
      self.save!
    end

    def api_get_bank_account_setup_url(armor_account_id:, armor_user_id:)
      armoraccount = LandingArmorAccount.new
      account_id = armor_account_id # The account_id of the user adding bank details
      user_id = armor_user_id # The user_id of the user adding bank details
      auth_data = {
        "uri" => "/accounts/#{account_id}/bankaccounts",
        "action" => "create"
      }
      armoraccount.get_bank_account_setup_url(account_id, user_id, auth_data)
      if armoraccount.errors.any?
        self.errors[:base] << armoraccount.errors.full_messages
      else
        return armoraccount.url
      end
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
      field :armor_shipment_carrier_name, type: String
      field :armor_shipment_tracking_number, type: String
      field :armor_shipment_description, type: String
      field :armor_dispute_id, type: String
      scope :without_armor_account, ->{where(:armor_seller_account_id => nil)}
      scope :with_armor_account, ->{where(:armor_seller_account_id.ne => nil)}
    end

    def armor_enabled?
      return true if self.armor_buyer_account_id.present?
    end
    def api_create_order

      armororder = LandingArmorOrder.new

      account_id = self.armor_seller_account_id # The account_id of the seller
      order_data = {
        "seller_id" => self.armor_seller_user_id, # The user_id of the seller
        "buyer_id" => self.armor_buyer_user_id, # The user_id of the buyer
        "amount" => self.total_price,
        "summary" => "Landing International Marketplace: Purchase of goods from #{self.brand_company_name} by #{self.orderer_company_name}",
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

    def api_add_shipment_info(carrier_id:,carrier_name:,tracking_id:,description:,other_shipper:)
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
        self.armor_shipment_carrier_name = carrier_name
        self.armor_shipment_tracking_number = tracking_id
        self.armor_shipment_description = description
        self.shipped
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


    def api_get_release_payment_url

      armororder = LandingArmorOrder.new

      account_id = self.armor_buyer_account_id # The account_id of the buyer for the order 
      user_id = self.armor_buyer_user_id # The user_id of the buyer for the order 
      auth_data = {
        'uri' => "/accounts/#{self.armor_seller_account_id}/orders/#{self.armor_order_id}",
        'action' => 'release' 
      } 

      armororder.get_url(account_id, user_id, auth_data)

      if armororder.errors.any?
        self.errors[:base] << armororder.errors.full_messages
      else
        return armororder.url
      end

    end

    def api_get_dispute_url

      armororder = LandingArmorOrder.new

      account_id = self.armor_buyer_account_id # The account_id of the buyer for the order 
      user_id = self.armor_buyer_user_id # The user_id of the buyer for the order 
      auth_data = {
        'uri' => "/accounts/#{self.armor_seller_account_id}/orders/#{self.armor_order_id}/createdispute",
        'action' => 'view' 
      }

      armororder.get_url(account_id, user_id, auth_data)

      if armororder.errors.any?
        self.errors[:base] << armororder.errors.full_messages
      else
        return armororder.url
      end

    end

    def api_get_dispute_status_url(company:,user:)

      armororder = LandingArmorOrder.new

      account_id = company.armor_account_id # The account_id of the viewer
      user_id = user.armor_user_id # The user_id of the viewer
      auth_data = {
        'uri' => "/accounts/#{self.armor_seller_account_id}/orders/#{self.armor_order_id}/disputes/#{self.armor_dispute_id}",
        'action' => 'view'
      }

      armororder.get_url(account_id, user_id, auth_data)

      if armororder.errors.any?
        self.errors[:base] << armororder.errors.full_messages
      else
        return armororder.url
      end

    end

    #FOR TESTING ONLY
    def api_testing_set_to_paid
      armororder = LandingArmorOrder.new
      account_id = self.armor_seller_account_id
      order_id = self.armor_order_id
      action_data = {
        "action" => "add_payment",
        "confirm" => true,
        "source_account_id" => self.armor_buyer_account_id, # The account_id of the party making the payment
        "amount" => self.total_price 
      }
      armororder.set_to_paid(account_id, order_id, action_data)
      if armororder.errors.any?
        self.errors[:base] << armororder.errors.full_messages
      end
    end

    def api_testing_set_to_delivered
      armororder = LandingArmorOrder.new
      account_id = self.armor_seller_account_id
      order_id = self.armor_order_id
      action_data = {
        "action" => "delivered",
        "confirm" => true
      }
      armororder.set_to_delivered(account_id, order_id, action_data)
      if armororder.errors.any?
        self.errors[:base] << armororder.errors.full_messages
      end
    end

  end


  class LandingArmorClient
    extend ActiveModel::Naming
    require 'armor_payments'
    attr_reader   :errors

    def initialize
      @errors = ActiveModel::Errors.new(self)
      if Rails.env.production?
        should_use_sandbox = false
      else
        should_use_sandbox = true
      end
      @client =  ArmorPayments::API.new Rails.configuration.armor_payments[:key], Rails.configuration.armor_payments[:secret], should_use_sandbox
    end

    protected

    def parse_response(response, item=nil)
      case response.status.to_i
      when 200 #OK
        if item.present?
          varname = "@#{item}"
          value = response.data[:body][item]
          self.instance_variable_set varname, value
        end
      else # all other statuses
        self.errors[:base] << "Response Status: #{response.status} - Errors:#{response.data[:body]['errors']}"
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
    attr_reader :account_id, :user_id, :email, :url

    def create(account_data)
      response = @client.accounts.create(account_data)
      parse_response(response, "account_id")
    end

    def get_user_info(account_id)
      response = @client.accounts.users(account_id).all
      parse_response_user(response, "user_id")
      parse_response_user(response, "email")
    end

    def get_bank_account_setup_url(account_id, user_id, auth_data)
      response = @client.accounts.users(account_id).authentications(user_id).create(auth_data)
      parse_response(response, "url")
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

    def get_url(account_id, user_id, auth_data)
      response = @client.accounts.users(account_id).authentications(user_id).create(auth_data)
      parse_response(response, "url")
    end

    def set_to_paid(account_id, order_id, action_data)
      response = @client.orders(account_id).update(order_id, action_data)
      parse_response(response)
    end

    def set_to_delivered(account_id, order_id, action_data)
      response = @client.orders(account_id).update(order_id, action_data)
      parse_response(response)
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