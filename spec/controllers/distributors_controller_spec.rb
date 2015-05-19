require 'rails_helper'

RSpec.describe DistributorsController, type: :controller do

  describe "GET #edit" do
    it "returns http success" do
      get :edit
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #public_profile" do
    it "returns http success" do
      get :public_profile
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #full_profile" do
    it "returns http success" do
      get :full_profile
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #update" do
    it "returns http success" do
      get :update
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #validationupdate" do
    it "returns http success" do
      get :validationupdate
      expect(response).to have_http_status(:success)
    end
  end

end
