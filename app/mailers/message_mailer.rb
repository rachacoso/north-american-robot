class MessageMailer < ActionMailer::Base
  default from: "Landing International <info@landingintl.com>"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.password_reset.subject
  #

  def self.send_simple_messages(message)  
    simple_message(message.sender_email,message,true).deliver
    simple_message('info@landingintl.com',message,false).deliver
  end
  def simple_message(email, message, cc)
    @message = message
    @cc = cc
    mail :to => email, :subject => "Landing International: Message Sent from #{message.sender} to #{message.recipient}"
  end

end
