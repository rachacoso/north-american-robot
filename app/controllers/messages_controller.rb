class MessagesController < ApplicationController

	def create

		unless params[:message][:text].blank?
			user = @current_user.distributor || @current_user.brand
			mm = user.matches
			m = mm.find(params[:match_id])
			m.messages << Message.new(recipient: @current_user.type_inverse?, text: params[:message][:text], stage: m.stage, read: false)
			@messages = m.messages

			# mark as accepted if this is first communication
			if params[:message][:new_contact]
				m.accepted = true
				m.save!
			end

			# for messages list rendering [NEED TO REFACTOR AND CLARIFY NAMING -- TOO CONFUSING -- i.e. LOOK AT MESSAGE_LIST and MESSAGE_LIST_ALL in shared]
			if @current_user.distributor
				@match = m.brand
			else
				@match = m.distributor
			end

			@new_contact_messages = mm.where(accepted: false, initial_contact_by: @current_user.type_inverse?).count
			@stage = m.stage

		end

	  respond_to do |format|
	    format.html
	    format.js
	  end 

	end

	def index
		u = @current_user.brand || @current_user.distributor
		@matches = u.matches
		@unread_list = Array.new
		@matches.each do |m|
			if m.messages.where(read: false, recipient: @current_user.type?).exists?
				@unread_list << m
			end
		end
		@new_requests_list = @matches.where(accepted: false, initial_contact_by: @current_user.type_inverse?)

  	if params[:list_style]
  		@list_style = params[:list_style]
  	end

		@unread_list_for_match_list = @unread_list.map{|a| a.send(@current_user.type_inverse?)}
		@new_requests_list_for_match_list = @new_requests_list.map{|a| a.send(@current_user.type_inverse?)}

	end

	def all_messages

		if !params[:match_id].blank? && !params[:stage].blank?
			user = @current_user.distributor || @current_user.brand
			match = user.matches.find(params[:match_id])		
			@messages = match.messages
			if ['contact','prepare','terms','order'].include? params[:stage]
				@stage = params[:stage]
			else
				@stage = match.stage
			end
		end

	  respond_to do |format|
	    format.html
	    format.js
	  end 

	end


end