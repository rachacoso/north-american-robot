class SectorsController < ApplicationController
  
  before_action :administrators_only

	def create
		c = Sector.new
		c.update(sector_parameters)
		# c.name = params[:sector][:name]

		if c.valid?
			c.save!
			redirect_to admin_url
		else
			redirect_to admin_url, :flash => { :sector_error => c.errors.messages }  # error name is the downcase of model class name
		end

	end

	def destroy
		d = Sector.find(params[:id])
		d.destroy
		redirect_to admin_url
		
	end

	def update
		c = Sector.find(params[:id])
		c.update(sector_parameters)
		c.save
		redirect_to admin_url
	end

  private
  
  def administrators_only
    unless @current_user.administrator
      redirect_to dashboard_url
    end
  end

  def sector_parameters
    params.require(:sector).permit(
			:name
		)
	end
  
end