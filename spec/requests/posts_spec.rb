require 'rails_helper'

RSpec.describe "Posts", type: :request do
  describe "GET /new" do
    it "未ログインの場合、ログイン画面へリダイレクトされる" do
      get "/posts/new"
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "DELETE /posts/:id" do
    it "他ユーザーの投稿を削除できない" do
      user1 = FactoryBot.create(:user)
      user2 = FactoryBot.create(:user)
      post = FactoryBot.create(:post, user: user1)

      sign_in user2
      delete "/posts/#{post.id}"

      expect(response).to have_http_status(404)
      expect(Post.exists?(post.id)).to be true
    end
  end

  describe "PATCH /posts/:id" do
    it "他ユーザーが投稿のステータスを変更できない" do
      user1 = FactoryBot.create(:user)
      user2 = FactoryBot.create(:user)
      post = FactoryBot.create(:post, user: user1, status: "unresolved")

      sign_in user2
      patch "/posts/#{post.id}", params: { post: { status: "resolved" } }

      expect(response).to have_http_status(404)
      expect(post.reload.status).to eq("unresolved")
    end
  end
end
