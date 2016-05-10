class OrderMailer < ActionMailer::Base
  add_template_helper(OrderItemsHelper)
  default from: "Landing International <info@landingintl.com>"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.password_reset.subject
  #
  def send_order(order)
    @order = order
    mail :to => 'orders@landingintl.com', :subject => "Landing International: Order Submitted"
  end
end
