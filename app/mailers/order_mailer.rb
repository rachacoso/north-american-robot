class OrderMailer < ActionMailer::Base
  add_template_helper(OrderItemsHelper)
  default from: "Landing International <info@landingintl.com>"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.password_reset.subject
  #
  def send_submitted_order(order)
    @order = order
    mail :to => 'orders@landingintl.com', :subject => "Landing International: Order Submitted"
  end

  def send_pending_order(order)
    @order = order
    # send to orderer email (using the order creator's email in this case)
    mail :to => order.user.email, :subject => "Landing International: Order Updated"
  end

end
