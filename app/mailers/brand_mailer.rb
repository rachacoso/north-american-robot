class BrandMailer < ActionMailer::Base
	default from: "Landing International <info@landingintl.com>"

	def subscriber_notice(brand:, stage:)
		@stage = stage
		@brand = brand
		@user = @brand.users.first
		case @stage
		when "awaiting_approval"
			subject = "Thanks for Signing Up!"
		when "awaiting_payment"
			subject = "You're Approved!"
		when "subscription_paid"
			subject = "Welcome to the Landing International Marketplace!"
		end
		mail :to => @user.email, :subject => subject
	end
	def awaiting_approval_admin_notice(user:)

		mail :to => 'chloe@landingintl.com', :subject => "PLEASE APPROVE: #{user.brand.company_name} (#{user.brand.display_subscriber_account_number})"
	end
end