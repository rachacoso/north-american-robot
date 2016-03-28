# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/user_mailer/password_reset
  def password_reset
		user = User.first
		user.generate_token(:password_reset_token)
		user.save!
		UserMailer.password_reset(user,nil)
  end

  # Preview this email at http://localhost:3000/rails/mailers/user_mailer/password_reset_shared
  def password_reset_shared
		user = User.first
		user.generate_token(:password_reset_token)
		user.save!
		UserMailer.password_reset(User.first,Brand.first.id)
  end

	# Preview this email at http://localhost:3000/rails/mailers/user_mailer/new_user_notification
  def new_user_notification
		UserMailer.new_user_notification('test@test.com',User.where(:administrator => nil).first)
  end


end
