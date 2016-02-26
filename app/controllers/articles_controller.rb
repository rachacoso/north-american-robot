class ArticlesController < ApplicationController

	skip_before_action :require_login, only: [:public_view]
	before_action :administrators_only, except: [:public_view]
	before_action :get_article, only: [:show, :edit, :update, :destroy, :featured_brand, :delete_featured_brand, :public_view]

	def public_view

		# for submenu
		@brand_chunk = Subsector.where(sector_id: Sector.where(name: 'Beauty / Personal Care').first.id).uniq { |p| p.name }.sort_by { |p| p.name }

		# for find links
		@trends = Trend.all.sort_by { |p| p.name }
		@key_retailers = KeyRetailer.all.sort_by { |p| p.name }

	end

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

	def featured_brand

		unless params[:fb_id].blank?
			brand = Brand.find(params[:fb_id])
			@article.brands << brand
		end

	  respond_to do |format|
	    format.js
	  end 

	end

	def delete_featured_brand
		unless params[:fb_id].blank?
			brand = Brand.find(params[:fb_id])
			@article.brands.delete(brand)
		end

	  respond_to do |format|
	    format.js
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