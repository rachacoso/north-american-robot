class User
  include Mongoid::Document
	include ActiveModel::SecurePassword 	# this, along with the 
																				# 'has_secure_password' below
																				# enables all the pwd hashing  
	include LandingArmorPayments::User

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
	# for ordering under minimum
	field :can_submit_under_minimum, type: Mongoid::Boolean


	validates :email, presence: true, uniqueness: true

	has_secure_password

	has_one :contact, as: :contactable, dependent: :destroy
	accepts_nested_attributes_for :contact

	# child of a DISTRIBUTOR or BRAND
	belongs_to :distributor
	belongs_to :brand
	belongs_to :retailer

	# add errors from contact validation (NOTE: currently the only contact validation is for phone number)
	validate do |user|
		user.contact.errors.full_messages.each do |msg|
			errors[:phone] = "#{msg}"
		end
	end

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
		if u.subscription_expiration > Date.today
			return true
		else
			return false
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
  
	def can_order?
	# return true if self.armor_user_id  && self.company_type != "Brand"
		if  self.company_type != "Brand" && # is not a brand
			self.company.company_name.present? && # has company name entered
			self.company.payment_terms_valid? && # is 'prepay' or has approved net terms
			self.company.margin_valid? # has a margin at 50% or below or has approved other margin
			return true 
		end
	end

	def initial_setup(type:, company_name: nil, website: nil)
		# if ['distributor','brand','retailer'].include? type # restrict to only allowed values
			# createusertype = "create_" + type
			# self.send(createusertype) # create relation
			# eval("self.#{type} = #{type.capitalize}.new")
			# prepopulate contact info with user info (user can change later)
		case type
		when "brand"
			new_company = self.build_brand
			new_company.company_name = company_name
			new_company.website = website
		when "retailer"
			new_company = self.build_retailer
		when "distributor"
			new_company = self.build_distributor
		end
		# new_company = self.send(type)
		new_company.create_address
		new_company.contacts << Contact.new(
			firstname: self.contact.firstname,
			lastname: self.contact.lastname,
			email: self.email
		)
		# v2 brand/retailer/distributor relation
		self.company = new_company
		if self.save!
			UserMailer.registration_confirmation(self).deliver unless self.administrator
		end
		# end
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

end
