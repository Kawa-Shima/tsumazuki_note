require 'rails_helper'

RSpec.describe "PublicPosts", type: :request do
  describe "GET /public_posts" do
    it "ログイン中なら公開投稿一覧を表示できる" do
      user = FactoryBot.create(:user)
      sign_in user

      get "/public_posts"

      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /public_posts/:id" do
    it "ログイン中なら公開投稿詳細を表示できる" do
      user = FactoryBot.create(:user)
      sign_in user

      post = FactoryBot.create(:post, is_public: true)

      get "/public_posts/#{post.id}"

      expect(response).to have_http_status(:ok)
    end
  end
end
