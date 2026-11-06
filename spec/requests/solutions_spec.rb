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

  describe "PATCH /posts/:post_id/solutions/:id" do
    it "他ユーザーの投稿の解決策を編集できない" do
      user1 = FactoryBot.create(:user)
      user2 = FactoryBot.create(:user)
      post = FactoryBot.create(:post, user: user1)
      solution = FactoryBot.create(:solution, post: post, solution: "元の解決策の内容", url: "https://example.com")

      sign_in user2
      patch "/posts/#{post.id}/solutions/#{solution.id}", params: { solution: { solution: "更新された解決策の内容", url: "https://example.com/updated" } }

      expect(response).to have_http_status(404)
      solution.reload
      expect(solution.solution).to eq("元の解決策の内容")
      expect(solution.url).to eq("https://example.com")
    end
  end
end
