class ConversationsController < ApplicationController

	def share
		if (params[:share_list_docs] || params[:share_list_fields]) && params[:match_id]
			
			b_or_d = @current_user.brand || @current_user.distributor

			shared_docs_list = {}
			shared_fields_list = {}
			if params[:share_list_docs]
				params[:share_list_docs].each do |k,v|
					if doc = LibraryDocument.find(v)
						shared_docs_list[doc.filename] = doc.file.url
					end 
				end
			end
			if params[:share_list_fields]
				params[:share_list_fields].each do |k,v|
					unless v.blank?
						shared_fields_list[k] = v
					end
				end
			end

			docs_message_text = "<h3>#{b_or_d.company_name} has shared the following documents:</h3>"
			fields_message_text = "<h3>#{b_or_d.company_name} has shared the following information:</h3>"

			if !shared_docs_list.blank?
				shared_docs_list.each do |filename,url|
					docs_message_text += "<h4><strong><a href='#{url}'>#{filename}</a></strong></h4>"
				end
			end

			if !shared_fields_list.blank?
				shared_fields_list.each do |k,v|
					if k == "cbox"
						v.each do |kk,vv|
							fields_message_text += "<h4><strong>#{kk.gsub(/_/, " ").split.map(&:capitalize)*' '}:</strong></h4>"
							vv.each do |kkk,vvv|
								fields_message_text += "<p> #{kkk}</p>"
							end
						end
					else 
						fields_message_text += "<h4><strong>#{k.gsub(/_/, " ").split.map(&:capitalize)*' '}:</strong></h4><p> #{v}</p>"
					end
				end
			end

			unless shared_docs_list.blank? && shared_fields_list.blank?
				message_text = ""
				shared_docs_list.blank? ? "" : message_text += "#{docs_message_text}".html_safe
				shared_fields_list.blank? ? "" : message_text += "#{fields_message_text}".html_safe
				create_message(params[:match_id], message_text)
			end

		end


		mm = b_or_d.matches
		@m = mm.find(params[:match_id])

		# set flag to signal they've shared
		@m.send("#{@current_user.type?}_shared_propose=", true)
		@m.save!

		@messages = @m.messages.order_by(:c_at.asc)
		@stage = @m.stage
		@profile = @m.send(@current_user.type_inverse?)

    respond_to do |format|
      format.html
      format.js
    end 

	end



	private

	def create_message(match_id, text)

			user = @current_user.distributor || @current_user.brand
			mm = user.matches
			m = mm.find(match_id)
			m.messages << Message.new(recipient: @current_user.type_inverse?, text: text, stage: m.stage, read: false)
			m.save!
			# @messages = m.messages.order_by(:c_at.asc)
			# @stage = m.stage

	end

end