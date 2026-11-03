class PostsController < ApplicationController
  before_action :authenticate_user!
  def new
    @post = current_user.posts.build
  end

  def create
    @post = current_user.posts.build(post_params)
    if @post.save
      redirect_to mypage_path, notice: "投稿が作成されました。"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def index
    @posts = current_user.posts
  end

  private
  def post_params
    params.require(:post).permit(:title, :content, :date)
  end
end
