require 'rails_helper'

RSpec.describe MessagesController, type: :controller do

  describe "GET #create" do
    it "returns http success" do
      get :create
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #index" do
    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #all_messages" do
    it "returns http success" do
      get :all_messages
      expect(response).to have_http_status(:success)
    end
  end

end
