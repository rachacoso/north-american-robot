class UserMailer < ActionMailer::Base
  default from: "Landing International <info@landingintl.com>"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.password_reset.subject
  #
  def password_reset(user, share_id)
    @user = user
    @share_id = share_id
    mail :to => user.email, :subject => "Password Reset"
  end
end
