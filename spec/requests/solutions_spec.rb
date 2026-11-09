require "rails_helper"

RSpec.describe "Solutions", type: :request do
  let(:owner) { FactoryBot.create(:user) }
  let(:other_user) { FactoryBot.create(:user) }
  let!(:own_post) { FactoryBot.create(:post, user: owner) }

  describe "POST /posts/:post_id/solutions" do
    let(:solution_params) do
      {
        solution: {
          solution: "設定を変更して解決した",
          url: "https://example.com/reference"
        }
      }
    end

    it "自分の投稿に解決策と参考URLを登録できる" do
      sign_in owner

      expect {
        post post_solutions_path(own_post), params: solution_params
      }.to change(Solution, :count).by(1)

      created_solution = Solution.last
      expect(created_solution.post_id).to eq(own_post.id)
      expect(created_solution.solution).to eq("設定を変更して解決した")
      expect(created_solution.url).to eq("https://example.com/reference")
      expect(response).to redirect_to(post_path(own_post))
    end

    it "解決策が空の場合は登録できない" do
      sign_in owner
      solution_params[:solution][:solution] = ""

      expect {
        post post_solutions_path(own_post), params: solution_params
      }.not_to change(Solution, :count)

      expect(response).to redirect_to(post_path(own_post))
      expect(flash[:alert]).to eq("解決策の投稿に失敗しました。")
    end

    it "他ユーザーの投稿には登録できない" do
      sign_in other_user

      expect {
        post post_solutions_path(own_post), params: solution_params
      }.not_to change(Solution, :count)

      expect(response).to have_http_status(:not_found)
    end

    it "未ログインでは登録できない" do
      expect {
        post post_solutions_path(own_post), params: solution_params
      }.not_to change(Solution, :count)

      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "登録済みの解決策" do
    let!(:saved_solution) do
      FactoryBot.create(
        :solution,
        post: own_post,
        solution: "元の解決策",
        url: "https://example.com/original"
      )
    end

    describe "GET /posts/:id" do
      it "投稿詳細に解決策と参考URLが表示される" do
        sign_in owner
        get post_path(own_post)

        expect(response).to have_http_status(:ok)
        expect(response.body).to include(saved_solution.solution)
        expect(response.body).to include(saved_solution.url)
      end
    end

    describe "PATCH /posts/:post_id/solutions/:id" do
      let(:solution_params) do
        {
          solution: {
            solution: "更新後の解決策",
            url: "https://example.com/updated"
          }
        }
      end

      it "自分の解決策と参考URLを更新できる" do
        sign_in owner
        patch post_solution_path(own_post, saved_solution), params: solution_params

        expect(response).to redirect_to(post_path(own_post))
        saved_solution.reload
        expect(saved_solution.solution).to eq("更新後の解決策")
        expect(saved_solution.url).to eq("https://example.com/updated")
      end

      it "解決策が空の場合は更新されず、エラーが表示される" do
        sign_in owner
        solution_params[:solution][:solution] = ""
        patch post_solution_path(own_post, saved_solution), params: solution_params

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("解決策の更新に失敗しました。")
        saved_solution.reload
        expect(saved_solution.solution).to eq("元の解決策")
        expect(saved_solution.url).to eq("https://example.com/original")
      end

      it "他ユーザーの解決策を更新できない" do
        sign_in other_user
        patch post_solution_path(own_post, saved_solution), params: solution_params

        expect(response).to have_http_status(:not_found)
        saved_solution.reload
        expect(saved_solution.solution).to eq("元の解決策")
        expect(saved_solution.url).to eq("https://example.com/original")
      end

      it "未ログインでは更新できない" do
        patch post_solution_path(own_post, saved_solution), params: solution_params

        expect(response).to redirect_to(new_user_session_path)
        saved_solution.reload
        expect(saved_solution.solution).to eq("元の解決策")
        expect(saved_solution.url).to eq("https://example.com/original")
      end
    end

    describe "DELETE /posts/:post_id/solutions/:id" do
      it "選んだ解決策だけを削除し、投稿とほかの解決策は残る" do
        remaining_solution = FactoryBot.create(
          :solution,
          post: own_post,
          solution: "残す解決策"
        )
        sign_in owner

        expect {
          delete post_solution_path(own_post, saved_solution)
        }.to change(Solution, :count).by(-1)

        expect(response).to redirect_to(post_path(own_post))
        expect(Solution.exists?(saved_solution.id)).to be false
        expect(Solution.exists?(remaining_solution.id)).to be true
        expect(Post.exists?(own_post.id)).to be true
      end

      it "他ユーザーの解決策を削除できない" do
        sign_in other_user

        expect {
          delete post_solution_path(own_post, saved_solution)
        }.not_to change(Solution, :count)

        expect(response).to have_http_status(:not_found)
        expect(Solution.exists?(saved_solution.id)).to be true
      end

      it "未ログインでは削除できない" do
        expect {
          delete post_solution_path(own_post, saved_solution)
        }.not_to change(Solution, :count)

        expect(response).to redirect_to(new_user_session_path)
        expect(Solution.exists?(saved_solution.id)).to be true
      end
    end
  end
end
