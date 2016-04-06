# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/user_mailer/password_reset
  def password_reset
		user = User.new
		user.generate_token(:password_reset_token)
		UserMailer.password_reset(user,nil)
  end

  # Preview this email at http://localhost:3000/rails/mailers/user_mailer/password_reset_shared
  def password_reset_shared
		user = User.new
		user.generate_token(:password_reset_token)
		UserMailer.password_reset(user,Brand.first.id)
  end

	# Preview this email at http://localhost:3000/rails/mailers/user_mailer/new_user_notification
  def new_user_notification
		UserMailer.new_user_notification('test@test.com',User.where(:administrator => nil).first)
  end

	# Preview this email at http://localhost:3000/rails/mailers/user_mailer/registration_confirmation
  def registration_confirmation
		user = User.new
		user.generate_token(:email_confirmation_token)
		UserMailer.registration_confirmation(user)
  end


end
