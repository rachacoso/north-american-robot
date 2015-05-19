require 'rails_helper'

RSpec.describe MatchesController, type: :controller do

  describe "GET #index" do
    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #index_saved_matches" do
    it "returns http success" do
      get :index_saved_matches
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #index_contacted_matches" do
    it "returns http success" do
      get :index_contacted_matches
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #index_incoming_matches" do
    it "returns http success" do
      get :index_incoming_matches
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #index_conversations" do
    it "returns http success" do
      get :index_conversations
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #gallery" do
    it "returns http success" do
      get :gallery
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #save_match" do
    it "returns http success" do
      get :save_match
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #unsave_match" do
    it "returns http success" do
      get :unsave_match
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #view_match" do
    it "returns http success" do
      get :view_match
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #contact_match" do
    it "returns http success" do
      get :contact_match
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #search" do
    it "returns http success" do
      get :search
      expect(response).to have_http_status(:success)
    end
  end

end
