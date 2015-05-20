require 'rails_helper'

RSpec.describe AdminController, type: :controller do

  describe "GET #index" do
    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #new_bulk_upload" do
    it "returns http success" do
      get :new_bulk_upload
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #do_bulk_upload" do
    it "returns http success" do
      get :do_bulk_upload
      expect(response).to have_http_status(:success)
    end
  end

end
