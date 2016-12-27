# Preview all emails at http://landing.dev/rails/mailers/order_mailer
class InventoryAdjustmentMailerPreview < ActionMailer::Preview

  # Preview this email at http://landing.dev/rails/mailers/inventory_adjustment_mailer/request
  def request
    adjustment = InventoryAdjustment.where(type: "requested").first
    InventoryAdjustmentMailer.send_notice(
      adjustment: adjustment, 
      type: "request", 
      email: adjustment.product.brand.users.pluck(:email), # send to brand
      subject: "Landing International has requested an inventory shipment",
      title: "Inventory Request"
      )
  end

  # Preview this email at http://landing.dev/rails/mailers/inventory_adjustment_mailer/request_updated
  def request_updated
    adjustment = InventoryAdjustment.where(type: "requested").first
    previous_data = { 
      units: 250, 
      comment: "here are the old comments", 
      associated_shipments: adjustment.associated_shipments, 
      complete: adjustment.complete? 
    }
    InventoryAdjustmentMailer.send_notice(
      adjustment: adjustment, 
      type: "request_updated", 
      previous_data: previous_data,
      email: adjustment.product.brand.users.pluck(:email), # send to brand
      subject: "Landing International has updated an inventory shipment request",
      title: "Inventory Request Updated"
      )
  end

  # Preview this email at http://landing.dev/rails/mailers/inventory_adjustment_mailer/shipment
  def shipment
    adjustment = InventoryAdjustment.where(type: "shipment").first
    InventoryAdjustmentMailer.send_notice(
      adjustment: adjustment, 
      type: "shipment", 
      email: "info@landingintl.com", # send to brand
      subject: "#{adjustment.product.brand.company_name} has sent an inventory shipment",
      title: "Inventory Shipment"
      )
  end

  # Preview this email at http://landing.dev/rails/mailers/inventory_adjustment_mailer/shipment_updated
  def shipment_updated
    adjustment = InventoryAdjustment.where(type: "shipment").first
    previous_data = { 
      units: 250, 
      comment: "here are the old comments", 
      ship_date: DateTime.now - 3.days,
      associated_requests: adjustment.associated_requests,
      associated_received_shipments: adjustment.associated_received_shipments
    }
    InventoryAdjustmentMailer.send_notice(
      adjustment: adjustment, 
      type: "shipment_updated", 
      previous_data: previous_data,
      email: "info@landingintl.com", # send to brand
      subject: "#{adjustment.product.brand.company_name} has updated an inventory shipment",
      title: "Inventory Shipment Updated"
      )
  end

end