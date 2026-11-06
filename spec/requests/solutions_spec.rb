require 'rails_helper'

RSpec.describe "Solutions", type: :request do
  describe "POST /posts/:post_id/solutions" do
    it "他ユーザーの投稿に解決策を投稿できない" do
      user1 = FactoryBot.create(:user)
      user2 = FactoryBot.create(:user)
      post = FactoryBot.create(:post, user: user1)

      sign_in user2
      post "/posts/#{post.id}/solutions", params: { solution: { solution: "解決策の内容", url: "https://example.com" } }

      expect(response).to have_http_status(404)
      expect(post.solutions.count).to eq(0)
    end
  end
end
