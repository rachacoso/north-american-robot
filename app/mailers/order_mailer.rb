class OrderMailer < ActionMailer::Base
  default from: "Landing International <info@landingintl.com>"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.password_reset.subject
  #
  def submit_order(order)
    @order = order
    mail :to => 'sarah@landingintl.com', :subject => "Landing International: Order Submitted"
  end
end
