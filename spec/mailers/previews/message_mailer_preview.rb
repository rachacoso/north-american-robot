# Preview all emails at http://localhost:3000/rails/mailers/message_mailer
class MessageMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/message_mailer/send_message
  def send_message
  	message = Message.new(
			sender: "Test Retailer",
			sender_email: "test@email.com",
			recipient: "Company Name",
			text: "Testing one two threee..."
			)
    MessageMailer.simple_message('info@landingintl.com', message, false)
  end

	# Preview this email at http://localhost:3000/rails/mailers/message_mailer/send_message
 def send_message_cc
  	message = Message.new(
			sender: "Test Retailer",
			sender_email: "test@email.com",
			recipient: "Company Name",
			text: "Testing one two threee..."
			)
    MessageMailer.simple_message('sender@sender.com', message, true)
  end

end