class ContactsController < ApplicationController

	# before_action :set_parameters

  def new

  	@new_contact = Contact.new
  	
	  respond_to do |format|
		  format.html
		  format.js
	  end
  end

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

  	contact = Contact.find(params[:id])
  	contact.destroy
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
