class PagesController < ApplicationController
    def show
      if valid_page?
        # for submenu
        @brand_chunk = Subsector.where(sector_id: Sector.where(name: 'Beauty / Personal Care').first.id).uniq { |p| p.name }.sort_by { |p| p.name }
        render template: "pages/#{params[:page]}"
      else
        render file: "public/404.html", status: :not_found
      end
    end

    private
    def valid_page?
      File.exist?(Pathname.new(Rails.root + "app/views/pages/#{params[:page]}.html.erb"))
    end
end