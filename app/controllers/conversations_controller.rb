class ConversationsController < ApplicationController

	def share
		if params[:documents_list] && params[:match_id]
			b_or_d = @current_user.brand || @current_user.distributor
			# this_match = b_or_d.matches.find(params[:match_id])
			shared_docs_list = {}
			params[:documents_list].each do |k,v|
				doc = LibraryDocument.find(v)
				shared_docs_list[doc.filename] = doc.file.url
			end

			doc_message_text = ""
			shared_docs_list.each do |filename,url|
				doc_message_text += "<a href='#{url}'>#{filename}</a><br>"
			end
			message_text = "
			#{b_or_d.company_name} has shared the following files with you:<br>
			#{doc_message_text}
			".html_safe

			create_message(params[:match_id], message_text)

		end

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
			@messages = m.messages.order_by(:c_at.asc)
			@stage = m.stage

	end

end