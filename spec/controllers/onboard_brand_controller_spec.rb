require 'rails_helper'

RSpec.describe OnboardBrandController, type: :controller do

  describe "GET #one" do
    it "returns http success" do
      get :one
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #two" do
    it "returns http success" do
      get :two
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #three" do
    it "returns http success" do
      get :three
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #four" do
    it "returns http success" do
      get :four
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #five" do
    it "returns http success" do
      get :five
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #six" do
    it "returns http success" do
      get :six
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #seven" do
    it "returns http success" do
      get :seven
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #eight" do
    it "returns http success" do
      get :eight
      expect(response).to have_http_status(:success)
    end
  end

end
