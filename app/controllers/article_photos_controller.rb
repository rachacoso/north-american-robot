class ArticlePhotosController < ApplicationController
	before_action :set_article, only: [:create, :destroy]

	def create
		if params[:article_photo]
			newfile = params[:article_photo][:photo]
		end

		if newfile.nil?
			flash[:error] = "Sorry, Please choose a file to upload"
		else
			newphoto = ArticlePhoto.new(photo: newfile)
			if newphoto.valid?
				@article.article_photos << newphoto
			else
				flash[:error] = "Sorry, we're unable to upload that file"
			end
		end

		redirect_to @article

	end

	def destroy
		photo_to_delete = ArticlePhoto.find(params[:id])
		photo_to_delete.destroy

		redirect_to @article

	end

	private

	def set_article
		@article = Article.find(params[:article_id])
	end

end
