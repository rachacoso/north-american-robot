# Preview all emails at http://landing.dev/rails/mailers/order_mailer
class OrderMailerPreview < ActionMailer::Preview

  # Preview this email at http://landing.dev/rails/mailers/order_mailer/send_submitted_order_orderer
  def send_submitted_order_orderer
    order = Order.where(status: "submitted").first
    OrderMailer.send_order(
      order: order, 
      status: "submitted_orderer", 
      email: order.user.email, # send to buyer
      subject: "Congratulations! You submitted an order on Landing!",
      title: "Order Submitted"
      )
  end
  # Preview this email at http://landing.dev/rails/mailers/order_mailer/send_submitted_order_brand
  def send_submitted_order_brand
    order = Order.where(status: "submitted").first
    OrderMailer.send_order(
      order: order, 
      status: "submitted_brand", 
      email: "orders@landingintl.com", # send to buyer
      subject: "Good News! You have a new order request on Landing!",
      title: "Order Submitted"
      )
  end

	# Preview this email at http://landing.dev/rails/mailers/order_mailer/send_pending_order
  def send_pending_order
    order = Order.where(status: "pending").first
    OrderMailer.send_order(
      order: order,
      status: "pending",
      email: order.user.email, # send to orderer email (using the order creator's email in this case)
      subject: "Yippee! Your order has been approved.",
      title: "Order Pending Approval and Payment"
      )
  end


# Preview this email at http://landing.dev/rails/mailers/order_mailer/send_paid_order
  def send_paid_order
    order = Order.where(status: "paid").first
    OrderMailer.send_order(
      order: order,
      status: "paid",
      email: "orders@landingintl.com", # send to brand/landing (currently just sending to Landing)
      subject: "Yay! Get ready to ship!",
      title: "Order Paid"
      )
  end

# Preview this email at http://landing.dev/rails/mailers/order_mailer/send_shipped_order
  def send_shipped_order
    order = Order.where(status: "shipped").first
    OrderMailer.send_order(
      order: order,
      status: "shipped",
      email: order.user.email, # send to orderer
      subject: "Hooray! Your beauty products are on their way! ",
      title: "Order Shipped"
      )
  end

# Preview this email at http://landing.dev/rails/mailers/order_mailer/send_delivered_orderer
  def send_delivered_orderer
    order = Order.where(status: "delivered").first
    OrderMailer.send_order(
      order: order,
      status: "delivered_orderer",
      email: order.user.email, # send to orderer
      subject: "Woohoo! Your order was delivered.",
      title: "Order Delivered"
      )
  end

# Preview this email at http://landing.dev/rails/mailers/order_mailer/send_delivered_brand
  def send_delivered_brand
    order = Order.where(status: "delivered").first
    OrderMailer.send_order(
      order: order,
      status: "delivered_brand",
      email: "orders@landingintl.com", # send to brand/landing (currently just sending to Landing)
      subject: "Nice Job! Your order was delivered.",
      title: "Order Delivered"
      )
  end

# Preview this email at http://landing.dev/rails/mailers/order_mailer/send_completed_order
  def send_completed_order
    order = Order.where(status: "completed").first
    OrderMailer.send_order(
      order: order,
      status: "completed",
      email: "orders@landingintl.com", # send to brand/landing (currently just sending to Landing)
      subject: "Woohoo! Your payment has been released!",
      title: "Order Payment Released"
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