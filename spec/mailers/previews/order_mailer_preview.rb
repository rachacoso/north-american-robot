# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class OrderMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/order_mailer/send_order
  def send_order
    OrderMailer.send_order(Order.where(status: "submitted").first)
  end


end