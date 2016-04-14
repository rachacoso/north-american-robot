class User
  include Mongoid::Document
	include ActiveModel::SecurePassword 	# this, along with the 
																				# 'has_secure_password' below
																				# enables all the pwd hashing  
  before_create { generate_token(:auth_token) }
  before_create { generate_token(:email_confirmation_token) }

  field :email, type: String
  field :auth_token, type: String
  field :password_digest, type: String
  field :administrator, type: Mongoid::Boolean
  field :last_login, type: DateTime
  # for password reset
	field :password_reset_token, type: String 
	field :password_reset_sent_at, type: DateTime
	# for email confirmation
	field :email_confirmed, type: Mongoid::Boolean, default: false
	field :email_confirmation_token, type: String

	# PAYONEER/ARMOR
	field :armor_user_id, type: String

	validates :email, presence: true, uniqueness: true

	has_secure_password

	has_one :contact, as: :contactable, dependent: :destroy
	accepts_nested_attributes_for :contact

	# add errors from contact validation (NOTE: currently the only contact validation is for phone number)
	validate do |user|
		user.contact.errors.full_messages.each do |msg|
			errors[:phone] = "#{msg}"
		end
	end

	# child of a DISTRIBUTOR or BRAND
	belongs_to :distributor
	belongs_to :brand
	belongs_to :retailer

	# v2 brand/retailer/distributor relation
	belongs_to :company, polymorphic: true

	# V2 ORDERING to identify who created order
	has_many :orders

	# to identify who created messages
	has_many :messages

	# to identify who initiated matches
	has_many :matches



	scope :is_subscriber, ->{where(subscriber: true)}

  def generate_token(column)
    begin
      self[column] = SecureRandom.urlsafe_base64
    end while User.where(column => self[column]).exists?
  end

	def type?
		if self.brand
			return "brand"
		elsif self.distributor
			return "distributor"
		elsif self.retailer
			return "retailer"
		elsif self.administrator
			return "administrator"
		end
	end

	def type_inverse?
		if self.brand
			return "distributor"
		elsif self.distributor
			return "brand"
		elsif self.retailer
			return "brand"
		elsif self.administrator
			return nil
		end
	end

	def subscriber?
		u = self.distributor || self.brand || self.retailer
		if u.subscriber
			return true
		else
			return false
		end
	end

	def can_order
		d_or_r = self.distributor || self.retailer
		if d_or_r && d_or_r.company_name.present?
			return true
		end
	end

	def get_parent
		return self.send(self.type?)
	end
  
	def send_password_reset(share_id)
	  generate_token(:password_reset_token)
	  self.password_reset_sent_at = Time.zone.now
	  save!
	  UserMailer.password_reset(self, share_id).deliver
	end
  
	def initial_setup(type)
		if ['distributor','brand','retailer'].include? type # restrict to only allowed values
			# createusertype = "create_" + type
			# self.send(createusertype) # create relation
			eval("self.#{type} = #{type.capitalize}.new")
			# prepopulate contact info with user info (user can change later)
			new_company = self.send(type)
			new_company.create_address
			new_company.contacts << Contact.new(
				firstname: self.contact.firstname,
				lastname: self.contact.lastname,
				email: self.email
			)
			# v2 brand/retailer/distributor relation
			self.company = new_company
			self.save!
			UserMailer.registration_confirmation(self).deliver unless self.administrator
		end
	end

	def resend_confirmation
		if !self.email_confirmation_token
			generate_token(:email_confirmation_token)
			save!(:validate => false)
		end
		UserMailer.registration_confirmation(self).deliver
	end

	def confirm_email
    self.email_confirmed = true
    self.email_confirmation_token = nil
    save!(:validate => false)
		UserMailer.send_new_user_notification(self) unless self.administrator
	end

# ARMOR PAYMENTS METHODS

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
