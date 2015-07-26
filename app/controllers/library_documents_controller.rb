class LibraryDocumentsController < ApplicationController

	def index
		user = @current_user.brand || @current_user.distributor
		@documents_all = user.library_documents
		@documents_products_list = user.library_documents.where(type: 'Products List')
		@documents_fob_pricing = user.library_documents.where(type: 'FOB Pricing')
		@documents_tiered_pricing_schedule = user.library_documents.where(type: 'Tiered Pricing Schedule')
		@documents_certification_information = user.library_documents.where(type: 'Certification Information')
		@documents_patent_information = user.library_documents.where(type: 'Patent Information')
		@documents_testing_information = user.library_documents.where(type: 'Testing Information')
		@documents_ingredient_or_materials_list = user.library_documents.where(type: 'Ingredient or Materials List')
	end

	def create
		if params[:library_document]
			newfile = params[:library_document][:file]
		end

		if newfile.nil?
			flash[:error] = "Sorry, Please choose a file to upload"
		else
			if ['Products List','FOB Pricing','Tiered Pricing Schedule','Certification Information','Patent Information','Testing Information','Ingredient or Materials List'].include? params[:document_type]
				doc_type = params[:document_type]
				new_document = LibraryDocument.new(file: newfile, type: doc_type)
				user = @current_user.brand || @current_user.distributor
				if new_document.valid?
					user.library_documents << new_document
				else
					flash[:error] = "Sorry, we're unable to upload that file - Must be a PDF, DOC or XLS file under 1MB"
				end
			else
				flash[:error] = "Sorry, there was a problem with the Document Type"
			end

		end
		redirect_to library_documents_url
	end

	def update
		@id = params[:id]
		library_document = LibraryDocument.find(@id)
		library_document.update(library_document_parameters)
		respond_to do |format|
			format.html
			format.js
		end
	end

	def destroy
		document_to_delete = LibraryDocument.find(params[:id])
		document_to_delete.destroy
		redirect_to :back
	end

	private

	def library_document_parameters

		params.require(:library_document).permit(
			:filename
			)

	end


end