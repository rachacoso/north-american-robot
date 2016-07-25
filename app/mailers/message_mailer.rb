class MessageMailer < ActionMailer::Base
  default from: "Landing International <info@landingintl.com>"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.password_reset.subject
  #

  def self.send_simple_messages(message)  
    recipient = Brand.find(message.recipient) || Distributor.find(message.recipient) || Retailer.find(message.recipient)
    recipient_emails = recipient.users.pluck(:email)
    simple_message(email: recipient_emails,message: message,recipient_name: recipient.company_name,cc: false).deliver
    simple_message(email: message.sender_email,message: message,recipient_name: recipient.company_name,cc: true).deliver
    simple_message(email: 'info@landingintl.com',message: message,recipient_name: recipient.company_name,cc: false).deliver
  end
  def simple_message(email:, message:, recipient_name:, cc:)
    @message = message
    @cc = cc
    @recipient_name = recipient_name
    mail :to => email, :subject => "Landing International: Message Sent from #{message.sender} to #{recipient_name}"
  end

end
