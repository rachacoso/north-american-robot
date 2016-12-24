class InventoryAdjustmentMailer < ActionMailer::Base
  default from: "Landing International <info@landingintl.com>"
  add_template_helper(ApplicationHelper)
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.password_reset.subject
  #


  def send_notice(type:,adjustment:,previous_data: nil, subject:,title:,email: 'info@landingintl.com')
    @type = type
    @adjustment = adjustment
    @previous_data = previous_data
    @title = title
    @link = inventory_adjustments_url
    mail :to => email, :subject => subject
  end

end
