class OrderMailer < ActionMailer::Base
  default from: "Landing International <info@landingintl.com>"
  add_template_helper(OrderItemsHelper)
  add_template_helper(ApplicationHelper)
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.password_reset.subject
  #

  def send_submitted_order(order)
    @order = order
    mail :to => 'orders@landingintl.com', :subject => "Landing International: Order Submitted"
  end

  def send_order(order:,status:,email: 'orders@landingintl.com',subject:)
    @order = order
    @status = status
    @link = order_url(order)
    # if ['submitted','approved','paid'].include? status
    #   @link = admin_order_view_url(order)
    # elsif ['pending','shipped'].include? status
      # @link = order_url(order)
    # end
    mail :to => email, :subject => subject
  end

end
