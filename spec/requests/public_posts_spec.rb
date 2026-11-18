require 'rails_helper'

RSpec.describe "PublicPosts", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/public_posts/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/public_posts/show"
      expect(response).to have_http_status(:success)
    end
  end

end
