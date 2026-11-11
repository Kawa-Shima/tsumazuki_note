require 'rails_helper'

RSpec.describe "Posts", type: :request do
  describe "GET /posts" do
    let(:user) { FactoryBot.create(:user) }

    let!(:rails_post) do
      FactoryBot.create(
        :post,
        user: user,
        title: "Rails login error",
        content: "Session configuration failed",
        category: :rails,
        status: :unresolved,
        tag_names: "認証, 設定"
      )
    end

    let!(:ruby_post) do
      FactoryBot.create(
        :post,
        user: user,
        title: "Ruby array error",
        content: "Array mapping failed",
        category: :ruby,
        status: :resolved,
        tag_names: "設定"
      )
    end

    let!(:docker_post) do
      FactoryBot.create(
        :post,
        user: user,
        title: "Docker startup error",
        content: "Container startup failed",
        category: :docker,
        status: :unresolved,
        tag_names: "環境構築"
      )
    end

    let!(:other_post) do
      FactoryBot.create(
        :post,
        title: "Rails private record",
        content: "Session configuration and Array mapping failed",
        category: :rails,
        status: :unresolved,
        tag_names: "認証, 設定"
      )
    end

    it "自分の投稿だけが一覧に表示される" do
      sign_in user
      get "/posts"

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(rails_post.title)
      expect(response.body).to include(ruby_post.title)
      expect(response.body).to include(docker_post.title)
      expect(response.body).not_to include(other_post.title)
    end

    it "タイトルを大文字・小文字を区別せず部分一致で検索できる" do
      sign_in user
      get "/posts", params: { q: { title_i_cont: "rails" } }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(rails_post.title)
      expect(response.body).not_to include(ruby_post.title)
      expect(response.body).not_to include(docker_post.title)
      expect(response.body).not_to include(other_post.title)
    end

    it "内容を部分一致で検索できる" do
      sign_in user
      get "/posts", params: { q: { content_i_cont: "mapping" } }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(ruby_post.title)
      expect(response.body).not_to include(rails_post.title)
      expect(response.body).not_to include(docker_post.title)
      expect(response.body).not_to include(other_post.title)
    end

    it "カテゴリで絞り込める" do
      sign_in user
      get "/posts", params: {
        q: { category_eq: Post.categories.fetch("rails") }
      }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(rails_post.title)
      expect(response.body).not_to include(ruby_post.title)
      expect(response.body).not_to include(docker_post.title)
      expect(response.body).not_to include(other_post.title)
    end

    it "タグで絞り込める" do
      sign_in user
      get "/posts", params: { q: { tags_name_eq: "設定" } }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(rails_post.title)
      expect(response.body).to include(ruby_post.title)
      expect(response.body).not_to include(docker_post.title)
      expect(response.body).not_to include(other_post.title)
    end

    it "未解決の投稿で絞り込める" do
      sign_in user
      get "/posts", params: {
        q: { status_eq: Post.statuses.fetch("unresolved") }
      }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(rails_post.title)
      expect(response.body).to include(docker_post.title)
      expect(response.body).not_to include(ruby_post.title)
      expect(response.body).not_to include(other_post.title)
    end

    it "複数の検索条件を組み合わせられる" do
      sign_in user
      get "/posts", params: {
        q: {
          title_i_cont: "error",
          content_i_cont: "failed",
          category_eq: Post.categories.fetch("rails"),
          tags_name_eq: "設定",
          status_eq: Post.statuses.fetch("unresolved")
        }
      }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(rails_post.title)
      expect(response.body).not_to include(ruby_post.title)
      expect(response.body).not_to include(docker_post.title)
      expect(response.body).not_to include(other_post.title)
    end

    it "検索条件を空にすると自分の投稿がすべて表示される" do
      sign_in user

      get "/posts", params: {
        q: { category_eq: Post.categories.fetch("rails") }
      }
      expect(response.body).not_to include(ruby_post.title)

      get "/posts", params: {
        q: {
          title_i_cont: "",
          content_i_cont: "",
          category_eq: "",
          tags_name_eq: "",
          status_eq: ""
        }
      }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(rails_post.title)
      expect(response.body).to include(ruby_post.title)
      expect(response.body).to include(docker_post.title)
      expect(response.body).not_to include(other_post.title)
    end

    it "該当する投稿がない場合はメッセージを表示する" do
      sign_in user
      get "/posts", params: {
        q: { title_i_cont: "存在しないキーワード" }
      }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("つまずきがありません。")
      expect(response.body).not_to include(rails_post.title)
      expect(response.body).not_to include(ruby_post.title)
      expect(response.body).not_to include(docker_post.title)
      expect(response.body).not_to include(other_post.title)
    end

    it "未ログインでは一覧を表示できない" do
      get "/posts"

      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "GET /posts/:id" do
    it "自分の投稿詳細を表示できる" do
      user = FactoryBot.create(:user)
      post = FactoryBot.create(:post, user: user)
      sign_in user

      get "/posts/#{post.id}"

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(post.title)
    end

    it "他ユーザーの投稿詳細は表示できない" do
      user1 = FactoryBot.create(:user)
      user2 = FactoryBot.create(:user)
      post = FactoryBot.create(:post, user: user1)

      sign_in user2
      get "/posts/#{post.id}"

      expect(response).to have_http_status(404)
    end

    it "未ログインでは投稿詳細を表示できない" do
      post = FactoryBot.create(:post)
      get "/posts/#{post.id}"

      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "POST /posts" do
    it "ログイン中なら正しい内容で投稿できる" do
      user = FactoryBot.create(:user)
      sign_in user

      post_params = {
        post: {
          title: "Test Post",
          content: "This is a test post.",
          date: Date.current
        }
      }

      expect {
        post "/posts", params: post_params
      }.to change(Post, :count).by(1)

      expect(response).to redirect_to(posts_path)
      expect(Post.last.user_id).to eq(user.id)
    end

    it "タイトルが空なら投稿を保存できない" do
      user = FactoryBot.create(:user)
      sign_in user

      post_params = {
        post: {
          title: "",
          content: "This is a test post.",
          date: Date.current
        }
      }

      expect { post "/posts", params: post_params }.not_to change(Post, :count)
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "未ログインでは投稿を登録できない" do
      post_params = {
        post: {
          title: "Test Post",
          content: "This is a test post.",
          date: Date.current
        }
      }

      expect { post "/posts", params: post_params }.not_to change(Post, :count)
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "PATCH /posts/:id" do
    it "自分の投稿にカテゴリとタグを設定できる" do
      user = FactoryBot.create(:user)
      post = FactoryBot.create(:post, user: user)

      sign_in user
      patch "/posts/#{post.id}", params: {
        post: {
          category: "rails",
          tag_names: "認証, 設定"
        }
      }

      expect(response).to redirect_to(post_path(post))
      post.reload
      expect(post.category).to eq("rails")
      expect(post.tags.pluck(:name)).to match_array([ "認証", "設定" ])
    end

    it "自分の投稿を未解決・解決済みに切り替えられる" do
      user = FactoryBot.create(:user)
      post = FactoryBot.create(:post, user: user, status: :unresolved)

      sign_in user
      patch "/posts/#{post.id}", params: { post: { status: "resolved" } }

      expect(response).to redirect_to(post_path(post))
      expect(post.reload.status).to eq("resolved")

      patch "/posts/#{post.id}", params: { post: { status: "unresolved" } }

      expect(response).to redirect_to(post_path(post))
      expect(post.reload.status).to eq("unresolved")
    end

    it "自分の投稿を更新できる" do
      user = FactoryBot.create(:user)
      post = FactoryBot.create(:post, user: user)
      sign_in user
      patch "/posts/#{post.id}", params: {
        post: {
          title: "更新後のタイトル",
          content: "更新後の内容"
        }
      }

      expect(post.reload.title).to eq("更新後のタイトル")
      expect(post.content).to eq("更新後の内容")
      expect(response).to redirect_to(post_path(post))
    end

    it "タイトルを空にすると更新されない" do
      user = FactoryBot.create(:user)
      post = FactoryBot.create(:post, user: user)
      sign_in user
      original_title = post.title
      patch "/posts/#{post.id}", params: { post: { title: "" } }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(post.reload.title).to eq(original_title)
    end

    it "他ユーザーの投稿のタイトルと内容を更新できない" do
      owner = FactoryBot.create(:user)
      other_user = FactoryBot.create(:user)
      post = FactoryBot.create(
        :post,
        user: owner,
        title: "元のタイトル",
        content: "元の内容"
      )

      sign_in other_user
      patch "/posts/#{post.id}", params: {
        post: {
          title: "変更したタイトル",
          content: "変更した内容"
        }
      }

      expect(response).to have_http_status(:not_found)
      post.reload
      expect(post.title).to eq("元のタイトル")
      expect(post.content).to eq("元の内容")
    end

    it "未ログインでは投稿を更新できない" do
      post = FactoryBot.create(
        :post,
        title: "元のタイトル",
        content: "元の内容"
      )

      patch "/posts/#{post.id}", params: {
        post: {
          title: "変更したタイトル",
          content: "変更した内容"
        }
      }

      expect(response).to redirect_to(new_user_session_path)
      post.reload
      expect(post.title).to eq("元のタイトル")
      expect(post.content).to eq("元の内容")
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

    it "自分の投稿を削除できる" do
      user = FactoryBot.create(:user)
      post = FactoryBot.create(:post, user: user)

      sign_in user

      expect {
        delete "/posts/#{post.id}"
      }.to change(Post, :count).by(-1)

      expect(Post.exists?(post.id)).to be false
    end

    it "未ログインでは投稿を削除できない" do
      post = FactoryBot.create(:post)

      expect {
        delete "/posts/#{post.id}"
      }.not_to change(Post, :count)

      expect(response).to redirect_to(new_user_session_path)
      expect(Post.exists?(post.id)).to be true
    end
  end
end
