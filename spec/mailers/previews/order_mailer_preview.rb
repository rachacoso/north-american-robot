# Preview all emails at http://landing.dev/rails/mailers/order_mailer
class OrderMailerPreview < ActionMailer::Preview

  # Preview this email at http://landing.dev/rails/mailers/order_mailer/send_submitted_order
  def send_submitted_order
    # OrderMailer.send_submitted_order(Order.where(status: "submitted").first)
    order = Order.where(status: "submitted").first
    OrderMailer.send_order(
      order: order, 
      status: "submitted", 
      email: "order@landingintl.com", # send to brand/landing (currently just sending to Landing)
      subject: "Landing International: Order Submitted"
      )
  end

	# Preview this email at http://landing.dev/rails/mailers/order_mailer/send_pending_order
  def send_pending_order
    # OrderMailer.send_pending_order(Order.where(status: "pending").first)
    order = Order.where(status: "pending").first
    OrderMailer.send_order(
      order: order, 
      status: "pending", 
      email: order.user.email, # send to orderer email (using the order creator's email in this case)
      subject: "Landing International: Order Updated"
      )
  end



end