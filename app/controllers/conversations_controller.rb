class ConversationsController < ApplicationController

	def share
		if params[:share_list] && params[:match_id]
			
			b_or_d = @current_user.brand || @current_user.distributor
			shared_docs_list = {}
			if @current_user.brand
				params[:share_list].each do |k,v|
					doc = LibraryDocument.find(v)
					shared_docs_list[doc.filename] = doc.file.url
				end
			elsif @current_user.distributor
				params[:share_list].each do |k,v|
					unless v.blank?
						shared_docs_list[k] = v
					end
				end
			end
			doc_message_text = ""
			if @current_user.brand
				shared_docs_list.each do |filename,url|
					doc_message_text += "<h4><strong><a href='#{url}'>#{filename}</a></strong></h4>"
				end
				info_type = "files"
				not_nil = true
			elsif @current_user.distributor
				not_nil = false
				shared_docs_list.each do |k,v|
					not_nil = v.blank? ? false : true
					doc_message_text += "<h4><strong>#{k.gsub(/_/, " ").capitalize}:</strong></h4><p> #{v}</p>"
				end
				info_type = "information"
			end

			if not_nil
				message_text = "
				#{b_or_d.company_name} has shared the following #{info_type}:<br>
				#{doc_message_text}
				".html_safe
				create_message(params[:match_id], message_text)
			end

		end


		mm = b_or_d.matches
		m = mm.find(params[:match_id])
		@messages = m.messages.order_by(:c_at.asc)
		@stage = m.stage

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