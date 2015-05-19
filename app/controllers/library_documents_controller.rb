class LibraryDocumentsController < ApplicationController

	def index

	end

	def create
		if params[:library_document]
			newfile = params[:library_document][:file]
		end

		if newfile.nil?
			flash[:error] = "Sorry, Please choose a file to upload"
		else
			new_document = LibraryDocument.new(file: newfile)
			user = @current_user.brand || @current_user.distributor
			if new_document.valid?
				user.library_documents << new_document
			else
				flash[:error] = "Sorry, we're unable to upload that file - Must be a PDF, DOC or XLS file under 1MB"
			end
		end
		redirect_to :back
	end

	def destroy
		document_to_delete = LibraryDocument.find(params[:id])
		document_to_delete.destroy
		redirect_to :back

	end



end