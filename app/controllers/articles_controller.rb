class ArticlesController < ApplicationController

	before_action :administrators_only
	before_action :get_article, only: [:show, :edit, :update, :destroy]

	def index
		@articles = Article.all
		@article = Article.new
	end

	def create

		@article = Article.new(headline: "NEW ARTICLE #{Time.now}", article_type: params[:type].to_i)

    if @article.save
      redirect_to @article, notice: "#{@article.headline} was successfully created."
    else
      redirect_to articles_url, notice: "UNABLE TO CREATE ARTICLE"
    end

	end

	def show
		
	end

	def edit

	end

	def update

    if @article.update(article_params)
     redirect_to @article, notice: "#{@article.headline} was successfully updated."
    else
      render :edit
    end

	end

	def destroy
		n = "#{@article.headline} was successfully deleted."
		@article.destroy
		redirect_to articles_url, notice: n
	end


  private

  def get_article
  	@article = Article.find(params[:id])
  end
  
  def administrators_only
    unless @current_user.administrator
      redirect_to dashboard_url
    end
  end

  def article_params
    params.require(:article).permit(
			:headline,
			:author,
			:body,
			:date,
			:article_type,
			:active
		)
	end	

end