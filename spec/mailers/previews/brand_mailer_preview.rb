# Preview all emails at http://landing.dev/rails/mailers/order_mailer
class BrandMailerPreview < ActionMailer::Preview

  # Preview this email at http://landing.dev/rails/mailers/brand_mailer/subscriber_notice_awaiting_approval
  def subscriber_notice_awaiting_approval
    BrandMailer.subscriber_notice(
        user: Brand.find_by(company_name: 'Brand Nine').users.first,
        stage: 'awaiting_approval'
      )
  end

  # Preview this email at http://landing.dev/rails/mailers/brand_mailer/subscriber_notice_awaiting_payment
  def subscriber_notice_awaiting_payment
    BrandMailer.subscriber_notice(
        user: Brand.find_by(company_name: 'Brand Nine').users.first,
        stage: 'awaiting_payment'
      )
  end

  # Preview this email at http://landing.dev/rails/mailers/brand_mailer/subscriber_notice_subscription_paid
  def subscriber_notice_subscription_paid
    BrandMailer.subscriber_notice(
        user: Brand.find_by(company_name: 'Brand Nine').users.first,
        stage: 'subscription_paid'
      )
  end
end