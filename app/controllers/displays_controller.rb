class DisplaysController < ApplicationController
  
	def create
		newdisplay = Display.new
		newdisplay.background_color = params[:display][:background_color]
		newdisplay.background_photo = params[:display][:background_photo]
		newdisplay.default_product_photo = params[:display][:default_product_photo]

		if newdisplay.valid?
			newdisplay.save!
			redirect_to admin_url
		else
			redirect_to admin_url, :flash => { :display_error => newdisplay.errors.messages }
		end

	end

	def destroy
		display = Display.find(params[:id])
		display.destroy
		redirect_to admin_url

	end

	def update
		display = Display.find(params[:id])

		if params[:photo]
			if params[:photo] == "background"
				display.background_photo = nil
			elsif params[:photo] == "product"
				display.default_product_photo = nil
			end
		else		
			display.update(display_parameters)		
		end


		if display.valid?
			display.save!
			redirect_to admin_url
		else
			redirect_to admin_url, :flash => { :display_error => display.errors.messages }
		end

	end


  private
  def display_parameters
    params.require(:display).permit(
			:background_color,
			:background_photo,
			:default_product_photo
		)
	end 


end