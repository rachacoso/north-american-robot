class SubsectorsController < ApplicationController
  before_action :administrators_only

  def create
  	if params[:subsector][:sid] && params[:subsector][:name]
  		s = Sector.find(params[:subsector][:sid])
  		s.subsectors << Subsector.new(name: params[:subsector][:name])
  	end

		if s.valid?
			s.save!
			redirect_to admin_url
		else
			redirect_to admin_url, :flash => { :subsector_error => s.errors.messages }  # error name is the downcase of model class name
		end

  end

  def update
		s = Subsector.find(params[:id])
		s.update(sector_parameters)
		s.save
		redirect_to admin_url
  end

  def destroy
		d = Subsector.find(params[:id])
		d.destroy
		redirect_to admin_url  	
  end

 private
  
  def administrators_only
    unless @current_user.administrator
      redirect_to dashboard_url
    end
  end

  def sector_parameters
    params.require(:subsector).permit(
			:name
		)
	end
	 
end
