class KeyRetailersController < ApplicationController
  
  before_action :administrators_only

	def create
		c = KeyRetailer.new
		c.update(key_retailer_parameters)
		# c.name = params[:key_retailer][:name]

		if c.valid?
			c.save!
			redirect_to admin_url
		else
			redirect_to admin_url, :flash => { :key_retailer_error => c.errors.messages }  # error name is the downcase of model class name
		end

	end

	def destroy
		d = KeyRetailer.find(params[:id])
		d.destroy
		redirect_to admin_url
		
	end

	def update
		c = KeyRetailer.find(params[:id])
		c.update(key_retailer_parameters)
		c.save
		redirect_to admin_url
	end

  private
  
  def administrators_only
    unless @current_user.administrator
      redirect_to dashboard_url
    end
  end

  def key_retailer_parameters
    params.require(:key_retailer).permit(
			:name
		)
	end
  
end