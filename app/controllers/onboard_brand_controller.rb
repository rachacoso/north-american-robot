class OnboardBrandController < ApplicationController

  before_action do
    check_usertype("brand")
  end  

  def one
    @brand = @current_user.brand
  end

  def two
    @brand = @current_user.brand
    @sectors = @brand.sectors rescue nil
    @channels = @brand.channels rescue nil
    @new_channel_capacity = ChannelCapacity.new 
  end

  def three
    @brand = @current_user.brand 
  end


  def four
    @brand = @current_user.brand
    @current_products = @brand.products.where(current: true) rescue nil
    @past_products = @brand.products.where(current: false) rescue nil
    @new_product = Product.new
  end

  def five
    @brand = @current_user.brand
    @press_hits = @brand.press_hits rescue nil
    @new_press_hit = PressHit.new
    @trade_shows = @brand.trade_shows rescue nil
    @new_trade_show = TradeShow.new  
  end

  def six
    @brand = @current_user.brand
    @channel_capacities = @brand.channel_capacities rescue nil
  end


  def seven
    @brand = @current_user.brand
    @export_countries = @brand.export_countries rescue nil
    @new_export_country = ExportCountry.new 
  end

  def eight
    @brand = @current_user.brand
    @patents = @brand.patents rescue nil
    @new_patent = Patent.new   
    @trademarks = @brand.trademarks rescue nil
    @new_trademark = Trademark.new
    @compliances = @brand.compliances rescue nil
    @new_compliance = Compliance.new    
  end


  private
  def check_usertype(type)
    if @current_user.type? != type
      redirect_to dashboard_url
    end
  end

end
