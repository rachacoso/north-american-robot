class BrandPhotosController < ApplicationController
	def create
		if params[:brand_photo]
			newfile = params[:brand_photo][:photo]
		end

		if newfile.nil?
			flash[:error] = "Sorry, Please choose a file to upload"
		else
			newphoto = BrandPhoto.new(photo: newfile)
			if newphoto.valid?
				@current_user.brand.brand_photos << newphoto
			else
				flash[:error] = "Sorry, we're unable to upload that file"
			end
		end

		if params[:ob]
			redirect_to onboard_brand_five_url(:anchor => 'a-brand-photos')
		else
			redirect_to brand_url(:anchor => 'a-brand-photos')
		end

	end

	def destroy
		photo_to_delete = BrandPhoto.find(params[:id])
		photo_to_delete.destroy

		if params[:ob]
			redirect_to onboard_brand_five_url(:anchor => 'a-brand-photos')
		else
			redirect_to brand_url(:anchor => 'a-brand-photos')
		end

	end
end
