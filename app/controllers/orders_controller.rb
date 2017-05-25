class OrdersController < ApplicationController

	before_action only: [:index] do
		check_subscription(area: 'restricted')
	end
	before_action :set_order, only: [:show, :edit, :update, :destroy, :submit, :pending, :approve, :decline_approval, :shipment, :paid, :delivered, :armor_disabled_delivered, :armor_disabled_completed, :complete, :ship_date, :cancel_date]

	#setting of paid only done for testing & by admin only
	before_action :administrators_only, only: [:paid, :delivered, :complete]

	def orders_search
		@orders = []
		@filters = params[:filters]
		@show_complete = true if params[:show_completed] == "1"
		if params[:query_general_search].present?
			q = params[:query_general_search]
			q.tr!('$','')
			@search_type = 'general_search'
			orders_set = @show_complete ? @current_user.company.orders : ( @current_user.brand ? @current_user.company.orders.in_progress : @current_user.company.orders.active)
			@orders = orders_set.set_filters(filters: params[:filters]).order_search(query: [q], type: @search_type, show_completed: @show_complete, user: @current_user)
		else
			orders = @show_complete ? @current_user.company.orders : ( @current_user.brand ? @current_user.company.orders.in_progress : @current_user.company.orders.active)
			@orders = orders.set_filters(filters: params[:filters])
		end
	end

	def index

		if company_id = params[:company_id] #with company filter

			@profile = @current_user.company
			type = Brand.find(company_id) ? "brand" : "other"

			@current_orders = @profile.orders.of_company(company_id: company_id, type: type).current.count unless @current_user.brand
			@submitted_orders = @profile.orders.of_company(company_id: company_id, type: type).submitted.count
			@pending_orders = @profile.orders.of_company(company_id: company_id, type: type).pending.count
			@approved_orders = @profile.orders.of_company(company_id: company_id, type: type).approved.count
			@paid_orders = @profile.orders.of_company(company_id: company_id, type: type).paid.count
			@shipped_orders = @profile.orders.of_company(company_id: company_id, type: type).shipped.count
			@delivered_orders = @profile.orders.of_company(company_id: company_id, type: type).delivered.count
			@completed_orders = @profile.orders.of_company(company_id: company_id, type: type).completed.count
			@error_orders = @profile.orders.of_company(company_id: company_id, type: type).error.count
			@disputed_orders = @profile.orders.of_company(company_id: company_id, type: type).disputed.count
			# @active_orders = @profile.orders.of_company(company_id: company_id, type: type).active.count
			@active_orders = @current_user.brand ? @profile.orders.of_company(company_id: company_id, type: type).active_brand.count : @profile.orders.of_company(company_id: company_id, type: type).active.count
			if f = params[:f]
				if [
					"current", 
					"submitted", 
					"pending", 
					"approved",
					"paid",
					"shipped",
					"delivered",
					"disputed",
					"error",
					"completed",
					"active"
					].include? f
					if f == "current" && @current_user.brand
						@orders = nil
					elsif f == "active" && @current_user.brand
						@orders = @profile.orders.of_company(company_id: company_id, type: type).active_brand.order_by(:c_at => 'desc')
					else
						@orders = @profile.orders.of_company(company_id: company_id, type: type).send(f).order_by(:c_at => 'desc')
					end
					@filter = f
				else
					@orders = @current_user.brand ? @profile.orders.of_company(company_id: company_id, type: type).active_brand.order_by(:c_at => 'desc') : @profile.orders.of_company(company_id: company_id, type: type).active.order_by(:c_at => 'desc')
					@filter = "active"
				end		
			else
				@orders = @current_user.brand ? @profile.orders.of_company(company_id: company_id, type: type).active_brand.order_by(:c_at => 'desc') : @profile.orders.of_company(company_id: company_id, type: type).active.order_by(:c_at => 'desc')
				@filter = "active"
			end

			@company_filter = company_id

		else # no company filter

			@profile = @current_user.company
			@current_orders = @profile.orders.current.count unless @current_user.brand
			@submitted_orders = @profile.orders.submitted.count
			@pending_orders = @profile.orders.pending.count
			@approved_orders = @profile.orders.approved.count
			@paid_orders = @profile.orders.paid.count
			@shipped_orders = @profile.orders.shipped.count
			@delivered_orders = @profile.orders.delivered.count
			@completed_orders = @profile.orders.completed.count
			@error_orders = @profile.orders.error.count
			@disputed_orders = @profile.orders.disputed.count
			# @active_orders = @profile.orders.active.count
			@active_orders = @current_user.brand ? @profile.orders.active_brand.count : @profile.orders.active.count
			if f = params[:f]
				if [
					"current", 
					"submitted", 
					"pending", 
					"approved",
					"paid",
					"shipped",
					"delivered",
					"disputed",
					"error",
					"completed",
					"active"
					].include? f
					if f == "current" && @current_user.brand
						@orders = nil
					elsif f == "active" && @current_user.brand
						@orders = @profile.orders.active_brand.order_by(:c_at => 'desc')
					else
						@orders = @profile.orders.send(f).order_by(:c_at => 'desc')
					end
					@filter = f
				else
					@orders = @current_user.brand ? @profile.orders.active_brand.order_by(:c_at => 'desc') : @profile.orders.active.order_by(:c_at => 'desc')
					@filter = "active"
				end		
			else
				@orders = @current_user.brand ? @profile.orders.active_brand.order_by(:c_at => 'desc') : @profile.orders.active.order_by(:c_at => 'desc')
				@filter = "active"
			end

		end

	end


	def show_calculator
		@order = @current_user.company.orders.find(params[:id])
	end

	def show
		unless @order.viewable_by? @current_user
			redirect_to root_url
		end
		
		@brand = @order.brand
		@orderer = @order.orderer

		if @order.status == "approved"
			if @order.armor_enabled?
				url = @order.api_get_payment_url
				unless @order.errors.any?
					@armor_payment_instructions_url = url
				end
			else
				list = @order.api_get_shippers
				unless @order.errors.any?
					@armor_shippers_list = list
				end
			end
		elsif @order.status == "paid"
			# if @order.armor_enabled?
				list = @order.api_get_shippers
				unless @order.errors.any?
					@armor_shippers_list = list
				end
			# end
		elsif @order.status == "delivered"
			if @order.armor_enabled?
				url = @order.api_get_release_payment_url
				unless @order.errors.any?
					@armor_payment_release_payment_url = url
				end
				disputeurl = @order.api_get_dispute_url
				unless @order.errors.any?
					@armor_payment_dispute_url = disputeurl
				end
			end
		elsif @order.status == "disputed"
			disputeurl = @order.api_get_dispute_status_url(company: @current_user.company, user: @current_user)
			unless @order.errors.any?
				@armor_payment_dispute_url = disputeurl
			end
		end
	end

	def destroy
		brand = @order.brand
		@order.destroy
		redirect_to view_brand_url(brand), status: 303 and return
	end

	def submit
		if @order.meets_minimum(user: @current_user)
			# @order.armor_update # update any missing armor info
			if params[:confirm].to_i == 1
				@order.submission(user: @current_user)
			end
		else
			@order_under_minimum = true
		end
		respond_to do |format|
			format.html  { redirect_to order_url(@order) }
			format.js
		end
	end

	def pending
		# @order.armor_update # update any missing armor info
		if params[:confirm].to_i == 1
			@order.pending(user: @current_user)
			if @order.errors.any?
				flash.now[:notice] = @order.errors.full_messages
			end
		end
		respond_to do |format|
			format.html  { redirect_to order_url(@order) }
			format.js
		end
	end

	def approve
		if params[:confirm].to_i == 1
			@order.approval
			if @order.errors.any?
				flash.now[:notice] = @order.errors.full_messages
			end
		end
		respond_to do |format|
			format.html  { redirect_to order_url(@order) }
			format.js
		end
	end

	def decline_approval
		if params[:confirm].to_i == 1
			if params[:requests].blank?
				flash.now[:error] = "Sorry, please enter any change requests!"
			else
				@order.decline_approval(requests: params[:requests], user: @current_user)
				if @order.errors.any?
					flash.now[:notice] = @order.errors.full_messages
				end
			end
		end
		respond_to do |format|
			format.html  { redirect_to order_url(@order) }
			format.js
		end
	end

	def complete
		if params[:confirm].to_i == 1
			@order.completed_no_armor
			if @order.errors.any?
				flash.now[:notice] = @order.errors.full_messages
			else
				@success = true
				sleep(5) #pause to allow update of status from webhook
			end
		end
		respond_to do |format|
			format.html  { redirect_to order_url(@order) }
			format.js
		end
	end

	def shipment

			@order.api_add_shipment_info(
				carrier_id: params[:shipper_id],
				carrier_name: params[:shipper_name],
				tracking_id: params[:armor_shipment_tracking_number],
				description: params[:armor_shipment_description],
				other_shipper: params[:armor_other_shipper]
				)
			if @order.errors.any?
				flash.now[:error] = "Sorry, there was an error submitting your shipment details. <br> #{@order.errors.full_messages}"
				@armor_shippers_list = @order.api_get_shippers
				render :show
			else
				sleep(5) if @order.armor_enabled? #pause to allow update of status from webhook
				redirect_to order_url(@order)
			end

	end

	# FOR TESTING ARMOR ONLY
	def paid
		if params[:confirm].to_i == 1
			if @order.armor_enabled?
				@order.api_testing_set_to_paid
			else #is a prepay order
				@order.prepay_mark_as_paid
			end
			if @order.errors.any?
				flash.now[:notice] = @order.errors.full_messages
			else
				@success = true
				sleep(5) if @order.armor_enabled? #pause to allow update of status from webhook if armor
			end
		end
		respond_to do |format|
			format.html  { redirect_to order_url(@order) }
			format.js
		end
	end

	def delivered
		if params[:confirm].to_i == 1
			@order.api_testing_set_to_delivered
			if @order.errors.any?
				flash.now[:notice] = @order.errors.full_messages
			else
				@success = true
				sleep(5) #pause to allow update of status from webhook
			end
		end
		respond_to do |format|
			format.html  { redirect_to order_url(@order) }
			format.js
		end
	end

	def armor_disabled_delivered
		if params[:confirm].to_i == 1
			@order.delivered
			@success = true
		end
		respond_to do |format|
			format.html  { redirect_to order_url(@order) }
			format.js
		end
	end

	def armor_disabled_completed
		if params[:confirm].to_i == 1
			@order.completed_no_armor
			@success = true
		end
		respond_to do |format|
			format.html  { redirect_to order_url(@order) }
			format.js
		end
	end

	def update
		
		# add ship/cancel dates
		if params[:order][:ship_date]
			if params[:order][:ship_date].present?
				params[:order][:ship_date] = Date.strptime(params[:order][:ship_date], '%m-%d-%Y') 
			end
			@updated = "Ship Date"
			@render_this = "date_update"
		end
		if params[:order][:cancel_date]
			if params[:order][:cancel_date].present?
				params[:order][:cancel_date] = Date.strptime(params[:order][:cancel_date], '%m-%d-%Y')
			end
			@updated = "Cancel Date"
			@render_this = "date_update"
		end
		if params[:order][:ship_to_us_date]
			if params[:order][:ship_to_us_date].present?
				params[:order][:ship_to_us_date] = Date.strptime(params[:order][:ship_to_us_date], '%m-%d-%Y')
			end
			@updated = "Ship to U.S. Date"
			@render_this = "date_update"
		end
		if params[:order][:estimated_payment_date]
			if params[:order][:estimated_payment_date].present?
				params[:order][:estimated_payment_date] = Date.strptime(params[:order][:estimated_payment_date], '%m-%d-%Y')
			end
			@updated = "Estimated Payment Date"
			@render_this = "date_update"
		end

		if params[:order][:discount]
			@render_this = "discount"
		end

		# add comment
		if params[:order][:comment] && params[:order][:comment][:text]
			@order.comments.create(text: params[:order][:comment][:text], author: @current_user.type?, order_status: @order.status)
			@render_this = "comment"
		end

		# address update
		if params[:order][:shipping_address_attributes].present?
			@render_this = "shipping_address"
		end

		if ["sent","received","awaiting","paid"].include? params[:order][:post_delivery_status]
			@order.update_inventory
		end

		@order.update(order_params)
		if !@order.save
			# flash.now[:error] = "Sorry, Discount must be a number between 0 and 100"
			flash.now[:error] = @order.errors.full_messages
		end

		# default render if none set
		@render_this ||= "update"

		respond_to do |format|
			format.html  { redirect_to order_url(@order) }
			format.js { render @render_this }
		end
	end

	private

	def set_order
		if @current_user.administrator
			@order = Order.find(params[:id])
		else
			@order = @current_user.company.orders.find(params[:id])
		end
	end

	def order_params
		params.require(:order).permit(
			:discount,
			:ship_to_name,
			:ship_date,
			:ship_to_us_date,
			:cancel_date,
			:estimated_payment_date,
			:brand_order_reference_id,
			:orderer_order_reference_id,
			:post_delivery_status,
			:landing_commission,
			:landing_fulfillment_services,
			shipping_address_attributes: [
			  :address1,
			  :address2,
			  :city,
			  :state,
			  :postcode,
			  :country
			],
			comment_attributes: [
				:text,
				:author
			]
		)
	end

  # def save_ship_date(date, order)
  #   unless date.empty?
  #     order.ship_date = Date.strptime(date, '%m-%d-%Y')
  #     order.save!
  #   end 
  # end
  # def save_cancel_date(date, order)
  #   unless date.empty?
  #     order.cancel_date = Date.strptime(date, '%m-%d-%Y')
  #     order.save!
  #   end 
  # end

end