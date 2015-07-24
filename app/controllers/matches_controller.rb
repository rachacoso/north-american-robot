class MatchesController < ApplicationController

  before_action :match_display, only: [:index, :index_conversations, :index_saved_matches]

  def index

    if @current_user.brand #IS A BRAND
      @profile = @current_user.brand

      ### Full match set is all brands in the Distributor's sectors minus any countries that have not declared a country 
      ### or Countries of Distribution
      ### (will be updated to be all countries with completed profiles)
      @all_matches = Distributor.activated.in(sector_ids: @profile.sector_ids).not_in(export_countries: [nil,[]], country_of_origin: nil, company_name: ["",nil])
      # exclude any that are in contact already
      @all_matches = @all_matches.not_in(_id: @profile.matches.pluck(:distributor_id)) 
      if params[:country]
        countries_map = get_countries()
        @country = params[:country]
        @matches = @all_matches.in("export_countries.country" => countries_map[@country])
        @country_proper = countries_map[@country]
        if params[:tag]
          tag = Tag.where(name: params[:tag], taggable_type: 'Distributor').pluck(:taggable_id)
          @matches = @matches.in(:id => tag)
          @tag = params[:tag]
        end
      elsif params[:tag]
        tag = Tag.where(name: params[:tag], taggable_type: 'Distributor').pluck(:taggable_id)
        @matches = @all_matches.in(:id => tag)
        @tag = params[:tag]
      else
        @matches = @all_matches
      end

      #set ordering
      @matches = @matches.order_by(:rating.desc, :completeness.desc, :last_login.desc, :country.asc, :company_name.asc)

      #pagination
      if params[:page]
        @matches = @matches.page(params[:page]).per(20)
      else
        @matches = @matches.page(1).per(20)
      end

    else #IS A DISTRIBUTOR
      @profile = @current_user.distributor

      ### Full match set is all brands in the Distributor's sectors minus any countries that have not declared a country 
      ### (will be updated to be all countries with completed profiles)
      # @all_matches = Brand.in(sector_ids: @profile.sector_ids).excludes(country_of_origin: "")
      match_set = Brand.activated.not_in(company_name: ["",nil], sector_ids: [nil,[]])
      # exclude any that are in contact already
      all_matches = match_set.not_in(_id: @profile.matches.pluck(:brand_id))

      if params[:sector]
        @sector = params[:sector]
        @matches = all_matches.in(sector_ids: @sector)
        if params[:tag]
          tag = Tag.where(name: params[:tag], taggable_type: 'Brand').pluck(:taggable_id)
          @matches = all_matches.in(:id => tag)
          @tag = params[:tag]
        end
      elsif params[:tag]
        tag = Tag.where(name: params[:tag], taggable_type: 'Brand').pluck(:taggable_id)
        @matches = all_matches.in(:id => tag)
        @tag = params[:tag]
      else
        @matches = all_matches
      end

      #set ordering
      @matches = @matches.order_by(:completeness.desc, :last_login.desc, :company_name.asc)

      #pagination
      if params[:page]
        @matches = @matches.page(params[:page]).per(20)
      else
        @matches = @matches.page(1).per(20)
      end

    end

  end

  def index_saved_matches
  
    @profile = @current_user.brand || @current_user.distributor
    @matches = @profile.saved_matches.uniq

    if @current_user.brand
      countries_map = get_countries()
      @matches = Hash.new
      countries_map.each do |short,long|
        @matches[long] = Distributor.in("export_countries.country" => long).order_by(:rating.desc, :completeness.desc, :country.asc, :company_name.asc).find(@profile.saved_match_ids)
      end     
      # @matches = @matches.order_by(:rating.desc, :completeness.desc, :country.asc, :company_name.asc)
      # @matches = @matches.sort_by{ |m| [m.rating, m.completeness, m.country_of_origin, m.company_name] }.reverse!
      # @matches = Distributor.order_by(:rating.desc, :completeness.desc, :country.asc, :company_name.asc).find(@profile.saved_match_ids)
    
    elsif @current_user.distributor
      sectors_map = get_sectors()
      @matches = Hash.new
      sectors_map.each do |name, id|
        @matches[name] = Brand.in(:sector_ids => id).order_by(:completeness.desc, :company_name.asc).find(@profile.saved_match_ids)
      end   

    end

  end 

  def index_contacted_matches # matches you contacted

    @profile = @current_user.brand || @current_user.distributor

    case @current_user.type?
    when "distributor"
      @matches_waiting = Brand.find(@profile.matches.contacted_by_me_waiting.pluck(:brand_id))
      @matches_accepted = Brand.find(@profile.matches.contacted_by_me_accepted.pluck(:brand_id))
    when "brand"
      @matches_waiting = Distributor.find(@profile.matches.contacted_by_me_waiting.pluck(:distributor_id))
      @matches_accepted = Distributor.find(@profile.matches.contacted_by_me_accepted.pluck(:distributor_id))    
    end


  end

  def index_incoming_matches # matches contacting you

    @profile = @current_user.brand || @current_user.distributor

    case @current_user.type?
    when "distributor"
      @matches_waiting = Brand.find(@profile.matches.contacting_me_waiting.pluck(:brand_id))
      @matches_accepted = Brand.find(@profile.matches.contacting_me_accepted.pluck(:brand_id))
    when "brand"
      @matches_waiting = Distributor.find(@profile.matches.contacting_me_waiting.pluck(:distributor_id))  
      @matches_accepted = Distributor.find(@profile.matches.contacting_me_accepted.pluck(:distributor_id))
    end

  end  

  def index_conversations # ALL matches in contact

    @profile = @current_user.brand || @current_user.distributor
    
    case @current_user.type?
    when "distributor"
      # @matches_incoming_waiting = Brand.find(@profile.matches.contacting_me_waiting.pluck(:brand_id))
      # @matches_outgoing_waiting = Brand.find(@profile.matches.contacted_by_me_waiting.pluck(:brand_id))
      # @matches_accepted = Brand.find(@profile.matches.accepted.pluck(:brand_id))
      # @matches_accepted_outgoing = Brand.find(@profile.matches.contacted_by_me_accepted.pluck(:brand_id))
      # @matches_accepted_incoming = Brand.find(@profile.matches.contacting_me_accepted.pluck(:brand_id))

      sectors_map = get_sectors()
      @matches_incoming_waiting = Hash.new
      sectors_map.each do |name, id|
        @matches_incoming_waiting[name] = Brand.in(:sector_ids => id).order_by(:completeness.desc, :company_name.asc).find(@profile.matches.contacting_me_waiting.pluck(:brand_id))
      end   

      @matches_outgoing_waiting = Hash.new
      sectors_map.each do |name, id|
        @matches_outgoing_waiting[name] = Brand.in(:sector_ids => id).order_by(:completeness.desc, :company_name.asc).find(@profile.matches.contacted_by_me_waiting.pluck(:brand_id))
      end   

      @matches_accepted = Hash.new
      sectors_map.each do |name, id|
        @matches_accepted[name] = Brand.in(:sector_ids => id).order_by(:completeness.desc, :company_name.asc).find(@profile.matches.accepted.pluck(:brand_id))
      end


    when "brand"

      countries_map = get_countries()
      # @matches_incoming_waiting = Distributor.find(@profile.matches.contacting_me_waiting.pluck(:distributor_id))
      # @matches_outgoing_waiting = Distributor.find(@profile.matches.contacted_by_me_waiting.pluck(:distributor_id)) 
      # @matches_accepted = Distributor.find(@profile.matches.accepted.pluck(:distributor_id))
      
      @matches_incoming_waiting = Hash.new
      countries_map.each do |short,long|
        @matches_incoming_waiting[long] = Distributor.in("export_countries.country" => long).find(@profile.matches.contacting_me_waiting.pluck(:distributor_id))
      end

      @matches_outgoing_waiting = Hash.new
      countries_map.each do |short,long|
        @matches_outgoing_waiting[long] = Distributor.in("export_countries.country" => long).find(@profile.matches.contacted_by_me_waiting.pluck(:distributor_id))  
      end     
      
      @matches_accepted = Hash.new
      countries_map.each do |short,long|
        @matches_accepted[long] = Distributor.in("export_countries.country" => long).find(@profile.matches.accepted.pluck(:distributor_id))
      end

      @matches_accepted_outgoing = Distributor.find(@profile.matches.contacted_by_me_accepted.pluck(:distributor_id))
      @matches_accepted_incoming = Distributor.find(@profile.matches.contacting_me_accepted.pluck(:distributor_id))
            
    end

  end


  def gallery

    if @current_user.type? == "distributor"
      @gallery = ProductPhoto.where(photographable_type: "Product")
    else
      redirect_to all_matches_url
    end

  end

  def save_match

    if params[:match_id]
      @mid = params[:match_id]
      u = @current_user.distributor || @current_user.brand
      if @current_user.distributor 
        match = Brand.find(@mid)
        u.saved_matches << match
        u.save!
      else # is a brand
        match = Distributor.find(@mid)
        u.saved_matches << match
        u.save!
      end
    end 
   
    respond_to do |format|
      format.html
      format.js
    end 

  end


  def unsave_match

    if params[:match_id]
      u = @current_user.distributor || @current_user.brand
      @mid = params[:match_id]
      match = u.saved_matches.find(@mid)
      u.saved_matches.delete(match)
      u.save!
    end 

    if params[:remove]
      @remove = params[:remove]
      @profile = @current_user.brand || @current_user.distributor
      @matches = @profile.saved_matches.uniq
    end

    respond_to do |format|
      format.html
      format.js
    end     

  end 

  def view_match

    if @current_user.distributor 
      @match = Brand.find(params[:match_id])
      @stage = @current_user.distributor.matches.where(brand_id: params[:match_id]).first.stage rescue nil
      @messages = @current_user.distributor.matches.where(brand_id: @match.id).first.messages.order_by(:c_at.desc) rescue nil
      # @gallery = Array.new
      @product_list = @match.products.pluck(:id)
      @product_photos = ProductPhoto.where(:photographable_id.in => @product_list)
      @brand_photos = @match.brand_photos
      @gallery = @product_photos.concat @brand_photos

    else # is a brand
      @match = Distributor.find(params[:match_id])
      @stage = @current_user.brand.matches.where(distributor_id: params[:match_id]).first.stage rescue nil
      @messages = @current_user.brand.matches.where(distributor_id: @match.id).first.messages.order_by(:c_at.desc) rescue nil
      @brands_list = @match.distributor_brands.pluck(:id)
      @gallery = ProductPhoto.where(:photographable_id.in => @brands_list)
    end

    
    @referrer = params[:referrer]

  end 



  def contact_match

    if params[:match_id] && !params[:m].blank?
      new_match = Match.new
      if @current_user.distributor 
        u = @current_user.distributor
        @match = Brand.find(params[:match_id])
        icb = "distributor"
      else # is a brand
        u = @current_user.brand
        @match = Distributor.find(params[:match_id])
        icb = "brand"
      end

      new_match.initial_contact_by = icb
      new_match.accepted = false

      if !params[:m].blank?
        new_match.intro_message = params[:m]
      else
        new_match.intro_message = "#{u.company_name} would like to work with you."
      end

      u.matches << new_match
      @match.matches << new_match

      # get new data for the page refresh [NEED TO REFACTOR]
      if @current_user.distributor
        @messages = @current_user.distributor.matches.where(brand_id: @match.id).first.messages rescue nil
      else # is a brand
        @messages = @current_user.brand.matches.where(distributor_id: @match.id).first.messages rescue nil
      end     

    else 

      if @current_user.distributor 
        @match = Brand.find(params[:match_id])
      else # is a brand
        @match = Distributor.find(params[:match_id])
      end
      
    end


    redirect_to view_match_url(@match.id, "na")
    # respond_to do |format|
    #   format.html
    #   format.js
    # end

  end

  def search
    if @query = params[:q]
      if @current_user.brand
        @profile = @current_user.brand      
        all_matches = Distributor.in(sector_ids: @profile.sector_ids).excludes(country_of_origin: "", export_countries: nil)
      else
        @profile = @current_user.distributor      
        all_matches = Brand.in(sector_ids: @profile.sector_ids).excludes(country_of_origin: "")
      end
      @matches = all_matches.where(company_name:  /#{@query}/i )
    end

    respond_to do |format|
      format.html
      format.js
    end

  end

  def quick_view

    if params[:match_id]

      @match = Distributor.find(params[:match_id]) || Brand.find(params[:match_id])
    end

    respond_to do |format|
      format.html
      format.js
    end

  end

# CONVERSATIONS ACTIONS

  def accept_match
    if params[:id]
      @brand_or_distributor = @current_user.get_parent
      @match = @brand_or_distributor.matches.find(params[:id])
      @match.accepted = true
      @match.save!
      @profile = @match.send(@current_user.type_inverse?)
    end
    respond_to do |format|
      format.html
      format.js
    end  
  end

  def match_stage_update

    stages = ['contact','propose','prepare','order']
    @brand_or_distributor = @current_user.get_parent

    if params[:id]
      match = @brand_or_distributor.matches.find(params[:id])
      if !match.brand_proceed_to_next_stage && !match.distributor_proceed_to_next_stage
        match.send("#{@current_user.type?}_proceed_to_next_stage=", true)
        match.save!
      elsif match.brand_proceed_to_next_stage || match.distributor_proceed_to_next_stage
        current_stage = match.stage
        current_stage_index = stages.index(current_stage)
        unless current_stage_index == stages.length - 1 # i.e. is last stage
          next_stage = stages[current_stage_index + 1]
          match.stage = next_stage
          match.brand_proceed_to_next_stage = false
          match.distributor_proceed_to_next_stage = false
          match.save!
        end
      end

      @profile = match.send(@current_user.type_inverse?)
      @stage = match.stage
      @messages = match.messages rescue nil
      @match = match
      @current_stage = current_stage_index
   
    end

    respond_to do |format|
      format.html
      format.js
    end

  end

  def match_stage_view

    if !params[:id].blank? && !params[:stage].blank?
      @brand_or_distributor = @current_user.send(@current_user.type?)
      if @current_user.brand
        @match = @brand_or_distributor.matches.find(params[:id]).distributor
        @messages = @brand_or_distributor.matches.where(distributor_id: @match.id).first.messages.order_by(:c_at.asc) rescue nil
      elsif @current_user.distributor
        @match = @brand_or_distributor.matches.find(params[:id]).brand
        @messages = @brand_or_distributor.matches.where(brand_id: @match.id).first.messages.order_by(:c_at.asc) rescue nil
      end
      if ['contact','propose','prepare','order'].include? params[:stage]
        @stage = params[:stage]
      end     
    end

    respond_to do |format|
      format.html
      format.js
    end 

  end

  def match_share
    if (params[:share_list_docs] || params[:share_list_fields]) && params[:match_id]
      
      b_or_d = @current_user.brand || @current_user.distributor

      shared_docs_list = {}
      shared_fields_list = {}
      if params[:share_list_docs]
        params[:share_list_docs].each do |k,v|
          if doc = LibraryDocument.find(v)
            shared_docs_list[doc.filename] = doc.file.url
          end 
        end
      end
      if params[:share_list_fields]
        params[:share_list_fields].each do |k,v|
          unless v.blank?
            shared_fields_list[k] = v
          end
        end
      end

      docs_message_text = "<h3>#{b_or_d.company_name} has shared the following documents:</h3>"
      fields_message_text = "<h3>#{b_or_d.company_name} has shared the following information:</h3>"

      if !shared_docs_list.blank?
        shared_docs_list.each do |filename,url|
          docs_message_text += "<h4><strong><a href='#{url}'>#{filename}</a></strong></h4>"
        end
      end

      if !shared_fields_list.blank?
        shared_fields_list.each do |k,v|
          if k == "cbox"
            v.each do |kk,vv|
              fields_message_text += "<h4><strong>#{kk.gsub(/_/, " ").split.map(&:capitalize)*' '}:</strong></h4>"
              vv.each do |kkk,vvv|
                fields_message_text += "<p> #{kkk}</p>"
              end
            end
          else 
            fields_message_text += "<h4><strong>#{k.gsub(/_/, " ").split.map(&:capitalize)*' '}:</strong></h4><p> #{v}</p>"
          end
        end
      end

      unless shared_docs_list.blank? && shared_fields_list.blank?
        message_text = ""
        shared_docs_list.blank? ? "" : message_text += "#{docs_message_text}".html_safe
        shared_fields_list.blank? ? "" : message_text += "#{fields_message_text}".html_safe
        create_message(params[:match_id], message_text)
      end

    end


    mm = b_or_d.matches
    @m = mm.find(params[:match_id])

    # set flag to signal they've shared
    @m.send("#{@current_user.type?}_shared_propose=", true)
    @m.save!

    @messages = @m.messages.order_by(:c_at.asc)
    @stage = @m.stage
    @profile = @m.send(@current_user.type_inverse?)

    respond_to do |format|
      format.html
      format.js
    end 

  end



  private

  def get_countries

    countries_map = {
      "brazil" => "Brazil",
      "china" => "China",
      "india" => "India",
      "russia" => "Russia",
      "korea" => "South Korea",
      "uk" => "United Kingdom"
    }   

    return countries_map

  end

  def get_sectors

    sectors_map = Hash.new
    Sector.all.each do |sector|
      sectors_map[sector.name] = sector.id
    end

    return sectors_map

  end

  def match_display
    if params[:list_style]
      @list_style = params[:list_style]
    end
  end

  def create_message(match_id, text)

      user = @current_user.distributor || @current_user.brand
      mm = user.matches
      m = mm.find(match_id)
      m.messages << Message.new(recipient: @current_user.type_inverse?, text: text, stage: m.stage, read: false)
      m.save!
      # @messages = m.messages.order_by(:c_at.asc)
      # @stage = m.stage

  end

end