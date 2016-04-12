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
	field :armor_account_id, type: String

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

	def allows_armor_signup
		if self.email_confirmed
			allow = true
			armor_errors = []
			if self.contact.firstname.blank?
				allow = false
				armor_errors << "First Name"
			end
			if self.contact.lastname.blank?
				allow = false
				armor_errors << "Last Name"
			end
			if self.contact.phone.blank?
				allow = false
				armor_errors << "Phone"
			end
			if self.company.company_name.blank?
				allow = false
				armor_errors << "Company Name"
			end
			if self.company.address.address1.blank?
				allow = false
				armor_errors << "Address"
			end
			if self.company.address.city.blank?
				allow = false
				armor_errors << "City/Town/Department"
			end
			if self.company.address.state.blank?
				allow = false
				armor_errors << "State/Provice/Region/County"
			end
			if self.company.address.postcode.blank?
				allow = false
				armor_errors << "Zip/Postcode"
			end
			if self.company.address.country.blank?
				allow = false
				armor_errors << "Country"
			end
			if allow
				return true, nil
			else
				return false, armor_errors
			end
		end
	end
end
