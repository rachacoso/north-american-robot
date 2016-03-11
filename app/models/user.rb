class User
  include Mongoid::Document
	include ActiveModel::SecurePassword 	# this, along with the 
																				# 'has_secure_password' below
																				# enables all the pwd hashing  
  before_create { generate_token(:auth_token) }

  field :email, type: String
  field :auth_token, type: String
  field :password_digest, type: String
  field :administrator, type: Mongoid::Boolean
  field :last_login, type: DateTime
  # for password reset
	field :password_reset_token, type: String 
	field :password_reset_sent_at, type: DateTime

	validates :email, presence: true, uniqueness: true

	has_secure_password

	has_one :contact, as: :contactable, dependent: :destroy
	accepts_nested_attributes_for :contact

	# child of a DISTRIBUTOR or BRAND
	belongs_to :distributor
	belongs_to :brand
	belongs_to :retailer

	accepts_nested_attributes_for :brand
	accepts_nested_attributes_for :distributor
	accepts_nested_attributes_for :retailer

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

	def get_parent
		return self.send(self.type?)
	end
  
	def send_password_reset(share_id)
	  generate_token(:password_reset_token)
	  self.password_reset_sent_at = Time.zone.now
	  save!
	  UserMailer.password_reset(self, share_id).deliver
	end
  
end
