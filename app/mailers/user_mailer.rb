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
    mail :to => user.email, :subject => "Landing International: Password Set/Reset"
  end


  def registration_confirmation(user)
    @user = user
    mail :to => user.email, :subject => "Landing International: Email Confirmation"
  end

  # def create_notification(user)
  #   @user = user
  #   mail :to => 'roberto@landingintl.com, sarah@landingintl.com', :subject => "Landing International: New User Created"
  # end

  def self.send_new_user_notification(user)
    emails = ['roberto@landingintl.com', 'sarah@landingintl.com']
    emails.each do |email|
      new_user_notification(email,user).deliver
    end
  end

  def new_user_notification(email, user)
    @user = user
    mail :to => email, :subject => "Landing International: New User Created"

  end

end
