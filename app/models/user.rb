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

	validates :email, presence: true, uniqueness: true

	has_secure_password

	has_one :contact, as: :contactable, dependent: :destroy
	accepts_nested_attributes_for :contact

	# child of a DISTRIBUTOR or BRAND
	belongs_to :distributor
	belongs_to :brand

	# has_one :brand, dependent: :destroy
	# has_one :distributor, dependent: :destroy

	accepts_nested_attributes_for :contact
	# accepts_nested_attributes_for :brand
	# accepts_nested_attributes_for :distributor

	scope :is_subscriber, ->{where(subscriber: true)}

  def generate_token(column)
    begin
      self[column] = SecureRandom.urlsafe_base64
    end while User.where(column => self[column]).exists?
  end

	def type?
		if self.brand
			return "brand"
		else
			return "distributor"
		end
	end

	def type_inverse?
		if self.brand
			return "distributor"
		else
			return "brand"
		end
	end

	def subscriber?
		u = self.distributor || self.brand
		if u.subscriber
			return true
		else
			return false
		end
	end
  
end
