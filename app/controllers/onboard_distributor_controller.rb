class OnboardDistributorController < ApplicationController
  
  before_action do
    check_usertype("distributor")
  end  

  def one

    @distributor = @current_user.distributor

  end

  def two

    @distributor = @current_user.distributor
    @export_countries = @distributor.export_countries rescue nil
    @new_export_country = ExportCountry.new 

  end

  def three

    @distributor = @current_user.distributor

  end

  def four

    @distributor = @current_user.distributor

  end

  def five

    @distributor = @current_user.distributor

    @current_brands = @distributor.distributor_brands.where(current: true) rescue nil
    @past_brands = @distributor.distributor_brands.where(current: false) rescue nil
    @new_brand = DistributorBrand.new

  end

  def six

    @distributor = @current_user.distributor

    @trade_shows = @distributor.trade_shows rescue nil
    @new_trade_show = TradeShow.new

  end


  private
  def check_usertype(type)
    if @current_user.type? != type
      redirect_to dashboard_url
    end
  end


end