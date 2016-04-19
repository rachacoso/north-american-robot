# Preview all emails at http://localhost:3000/rails/mailers/order_mailer
class OrderMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/order_mailer/send_submitted_order
  def send_submitted_order
    OrderMailer.send_submitted_order(Order.where(status: "submitted").first)
  end

	# Preview this email at http://landing.dev/rails/mailers/order_mailer/send_pending_order
  def send_pending_order
    OrderMailer.send_pending_order(Order.where(status: "pending").first)
  end

end