require "rails_helper"

RSpec.describe "Mypages", type: :request do
  describe "GET /show" do
    it "未ログインの場合、ログイン画面に遷移する" do
      get "/mypage/show"
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
