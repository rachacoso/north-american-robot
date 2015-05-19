class ProductPhotosController < ApplicationController


	def create
		if params[:product_photo]
			newfile = params[:product_photo][:photo]
		end

		if newfile.nil?
			flash[:error] = "Sorry, Please choose a file to upload"
		else
			newphoto = ProductPhoto.new(photo: newfile)
			if @current_user.brand
				product = @current_user.brand.products.find(params[:product_id])
			else 
				product = @current_user.distributor.distributor_brands.find(params[:product_id])
			end
			if newphoto.valid?
				product.product_photos << newphoto
			else
				flash[:error] = "Sorry, we're unable to upload that file"
			end
		end
		go_to_redirect(params[:product_id])
	end

	def destroy
		photo_to_delete = ProductPhoto.find(params[:id])	
		parent = photo_to_delete.photographable
		photo_to_delete.destroy
		go_to_redirect(parent.id.to_s)

	end


	private
	def go_to_redirect(redir = nil)

		if @current_user.distributor

			if params[:ob] 
				if redir
					redirect_to onboard_distributor_five_url + "#a-" + redir, :flash => { :make_active => redir }
				else
					redirect_to onboard_distributor_five_url
				end
			else
				if redir
					redirect_to distributor_url + "#a-" + redir, :flash => { :make_active => redir }
				else
					redirect_to distributor_url
				end
			end

		else

			if params[:ob]
				if redir
					redirect_to onboard_brand_four_url + "#a-" + redir, :flash => { :make_active => redir }
				else
					redirect_to onboard_brand_four_url
				end		 
			else
				if redir
					redirect_to brand_url + "#a-" + redir, :flash => { :make_active => redir }
				else
					redirect_to brand_url
				end				
			end	

		end

	end	


end