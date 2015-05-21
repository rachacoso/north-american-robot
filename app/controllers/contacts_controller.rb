class ContactsController < ApplicationController

	# before_action :set_parameters

  def create

			u = @current_user.send(@current_user.type?)
			u.contacts.create!(contact_parameters)


	  respond_to do |format|
		  format.html
		  format.js
	  end  	
  end

  def update

	  respond_to do |format|
		  format.html
		  format.js
	  end  	
  end

  def destroy

  	@brand_or_distributor = @current_user.get_parent

  	if @brand_or_distributor.contacts.count > 1
	  	contact = Contact.find(params[:id])
			@brand_or_distributor.contacts.delete(contact)	  	
	  	# contact.destroy
	  end

	  respond_to do |format|
		  format.html
		  format.js
	  end  	
  end

  private

  def contact_parameters
    params.require(:contact).permit(
			:firstname,
			:lastname,
			:title,
			:phone,
			:email
		)
	end

  # def set_parameters
  # 	if params[:c]
  # 		@contact_id = params[:c]
  # 	end
  # end
end
