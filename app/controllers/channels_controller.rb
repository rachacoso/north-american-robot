class ChannelsController < ApplicationController
  
  before_action :administrators_only

	def create

		newchannel = Channel.new
		newchannel.name = params[:channel][:name]
		newchannel.description = params[:channel][:description]

		if newchannel.valid?
			newchannel.save!
			redirect_to admin_url
		else
			redirect_to admin_url, :flash => { :channel_error => newchannel.errors.messages } # error name is the downcase of model class name
		end

	end

	def destroy
		channel = Channel.find(params[:id])
		channel.destroy
		redirect_to admin_url

	end

	def update

		c = Channel.find(params[:id])
		c.name = params[:channel][:name]
		c.description = params[:channel][:description]
		c.save
		redirect_to admin_url

	end

  private
  
  def administrators_only
    unless @current_user.administrator
      redirect_to dashboard_url
    end
  end

end