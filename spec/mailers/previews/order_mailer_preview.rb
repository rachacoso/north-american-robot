# Preview all emails at http://landing.dev/rails/mailers/order_mailer
class OrderMailerPreview < ActionMailer::Preview

  # Preview this email at http://landing.dev/rails/mailers/order_mailer/send_submitted_order
  def send_submitted_order
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
    order = Order.where(status: "pending").first
    OrderMailer.send_order(
      order: order,
      status: "pending",
      email: order.user.email, # send to orderer email (using the order creator's email in this case)
      subject: "Landing International: Order Updated"
      )
  end

# Preview this email at http://landing.dev/rails/mailers/order_mailer/send_approved_order
  def send_approved_order
    order = Order.where(status: "approved").first
    OrderMailer.send_order(
      order: order,
      status: "approved",
      email: "order@landingintl.com", # send to brand/landing (currently just sending to Landing)
      subject: "Landing International: Order Approved"
      )
  end

# Preview this email at http://landing.dev/rails/mailers/order_mailer/send_paid_order
  def send_paid_order
    order = Order.where(status: "paid").first
    OrderMailer.send_order(
      order: order,
      status: "paid",
      email: "order@landingintl.com", # send to brand/landing (currently just sending to Landing)
      subject: "Landing International: Order Payment in Escrow"
      )
  end

# Preview this email at http://landing.dev/rails/mailers/order_mailer/send_shipped_order
  def send_shipped_order
    order = Order.where(status: "shipped").first
    OrderMailer.send_order(
      order: order,
      status: "shipped",
      email: order.user.email, # send to brand/landing (currently just sending to Landing)
      subject: "Landing International: Order Shipped"
      )
  end

# Preview this email at http://landing.dev/rails/mailers/order_mailer/send_delivered_order
  def send_delivered_order
    order = Order.where(status: "delivered").first
    OrderMailer.send_order(
      order: order,
      status: "delivered",
      email: order.user.email, # send to brand/landing (currently just sending to Landing)
      subject: "Landing International: Order Delivered"
      )
  end

# Preview this email at http://landing.dev/rails/mailers/order_mailer/send_completed_order
  def send_completed_order
    order = Order.where(status: "completed").first
    OrderMailer.send_order(
      order: order,
      status: "completed",
      email: order.user.email, # send to brand/landing (currently just sending to Landing)
      subject: "Landing International: Order Payment Released from Escrow"
      )
  end

# Preview this email at http://landing.dev/rails/mailers/order_mailer/send_error_order
  def send_error_order
    order = Order.where(status: "error").first
    OrderMailer.send_order(
      order: order,
      status: "error",
      email: order.user.email, # send to brand/landing (currently just sending to Landing)
      subject: "Landing International: Order Error/Dispute"
      )
  end

end