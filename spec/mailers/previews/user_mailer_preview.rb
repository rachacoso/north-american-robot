# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/user_mailer/password_reset
  def password_reset
    UserMailer.password_reset(User.first,nil)
  end

  # Preview this email at http://localhost:3000/rails/mailers/user_mailer/password_reset_shared
  def password_reset_shared
    UserMailer.password_reset(User.first,Brand.first.id)
  end

end
