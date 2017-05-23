class BrandMailer < ActionMailer::Base
	default from: "Landing International <info@landingintl.com>"

	def subscriber_notice(brand:, stage:)
		@stage = stage
		@brand = brand
		@user = @brand.users.first
		case @stage
		when "awaiting_approval"
			email = @user.email
			subject = "Landing International: Thanks for Signing Up!"
		when "approval_alert"
			email = 'chloe@landingintl.com'
			subject = "PLEASE APPROVE: #{brand.company_name} (#{brand.display_subscriber_account_number})"
		when "awaiting_payment"
			email = @user.email
			subject = "Landing International: You're Approved!"
		when "subscription_paid"
			email = @user.email
			subject = "Landing International: Welcome to the Marketplace!"
		end
		mail :to => email, :subject => subject
	end
end