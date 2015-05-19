require 'rails_helper'

RSpec.describe "Landingappv2s", type: :request do
  describe "GET /" do
    it "displays the root page" do
      visit root_path
      # expect(response).to have_http_status(200)
      expect(page).to have_content "Sign Up..."
    end
  end
end
