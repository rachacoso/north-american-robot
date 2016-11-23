class ChannelCapacitiesController < ApplicationController

	def create
		u = @current_user.distributor || @current_user.brand

		cname = params[:channel_capacity][:custom_channel_name]
		# ccap = params[:channel_capacity][:capacity]

		cchannel = u.channel_capacities.find_or_create_by(custom_channel_name: cname, channel_id: 0)
		# cchannel.capacity = ccap
		cchannel.save

		# update COMPLETENESS
		if @current_user.distributor
			u.update_completeness
		end


		respond_to do |format|
			format.html
			format.js
		end

		# if @current_user.distributor
		# 	if params[:ob]
		# 		redirect_to onboard_distributor_five_url
		# 	else
		# 		redirect_to distributor_url
		# 	end
		# else
		# 	if params[:ob]
		# 		redirect_to onboard_brand_four_url
		# 	else
		# 		redirect_to brand_url
		# 	end
		# end




	end

	def update
		u = @current_user.distributor || @current_user.brand
		u.channel_capacities.find(params[:id]).update!(channel_capacity_parameters)

		# update COMPLETENESS
		if @current_user.distributor
			u.update_completeness
		end

		if @current_user.distributor
			if params[:ob]
				redirect_to onboard_distributor_five_url
			else
				redirect_to distributor_url
			end			
		else
			if params[:ob]
				redirect_to onboard_brand_four_url
			else
				redirect_to brand_url
			end
		end		

	end

	def bulkupdate
		u = @current_user.distributor || @current_user.brand
		cc = u.channel_capacities
		params[:channel_capacity][:bulk_ids].each do |k,v|
			# try to find the id (custom channel) or find under channel_id (preset channel)
			if bu = cc.find(k) rescue false
				bu.capacity  = v
				bu.save
			else
				bu = cc.where(channel_id: k).first
				bu.capacity = v
				bu.save
			end
		end

		# update COMPLETENESS
		if @current_user.distributor
			u.update_completeness
		end

		if @current_user.distributor
			if params[:ob]
				redir = onboard_distributor_five_url
			elsif params[:redirect_anchor]
				redir = distributor_url + "#" + params[:redirect_anchor] 
			else
				redir = distributor_url
			end		
		else
			if params[:ob]
				redir = onboard_brand_seven_url
			elsif params[:redirect_anchor]
				redir = brand_url + "#" + params[:redirect_anchor] 
			else
				redir = brand_url
			end
		end		

		respond_to do |format|
			format.html { redirect_to redir }
			format.js
		end

	end

	def destroy

		d = ChannelCapacity.find(params[:id])
		d.destroy

		# update COMPLETENESS
		if @current_user.distributor
			u.update_completeness
		end


		respond_to do |format|
			format.html
			format.js
		end		
		# if @current_user.distributor
		# 	if params[:ob]
		# 		redirect_to onboard_distributor_three_a_url
		# 	else
		# 		redirect_to distributor_url
		# 	end			
		# else
		# 	if params[:ob]
		# 		redirect_to onboard_brand_three_a_url
		# 	else
		# 		redirect_to brand_url
		# 	end
		# end


	end


  private
  def channel_capacity_parameters
    params.require(:channel_capacity).permit(
			:channel_id,
			:capacity
		)
	end		
end