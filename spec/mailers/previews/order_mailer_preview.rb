# Preview all emails at http://localhost:3000/rails/mailers/order_mailer
class OrderMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/order_mailer/send_submitted_order
  def send_submitted_order
    OrderMailer.send_submitted_order(Order.where(status: "submitted").first)
  end


end