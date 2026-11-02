require 'rails_helper'

RSpec.describe "Posts", type: :request do
  describe "GET /new" do
    it "未ログインの場合、ログイン画面へリダイレクトされる" do
      get "/posts/new"
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
