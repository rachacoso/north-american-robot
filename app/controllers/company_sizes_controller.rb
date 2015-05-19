class CompanySizesController < ApplicationController
  
	def create

		newcs = CompanySize.new
		newcs.name = params[:company_size][:name]

		if newcs.valid?
			newcs.save!
			redirect_to admin_url
		else
			redirect_to admin_url, :flash => { :channel_error => newcs.errors.messages } # error name is the downcase of model class name
		end

	end

	def destroy
		cs = CompanySize.find(params[:id])
		cs.destroy
		redirect_to admin_url

	end

	def update

		cs = CompanySize.find(params[:id])
		cs.name = params[:company_size][:name]
		cs.save
		redirect_to admin_url

	end


end