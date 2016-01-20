class TrendsController < ApplicationController
  
  before_action :administrators_only

	def create
		c = Trend.new
		c.update(trend_parameters)
		# c.name = params[:trend][:name]

		if c.valid?
			c.save!
			redirect_to admin_url
		else
			redirect_to admin_url, :flash => { :trend_error => c.errors.messages }  # error name is the downcase of model class name
		end

	end

	def destroy
		d = Trend.find(params[:id])
		d.destroy
		redirect_to admin_url
		
	end

	def update
		c = Trend.find(params[:id])
		c.update(trend_parameters)
		c.save
		redirect_to admin_url
	end

  private
  
  def administrators_only
    unless @current_user.administrator
      redirect_to dashboard_url
    end
  end

  def trend_parameters
    params.require(:trend).permit(
			:name
		)
	end
  
end