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

  def show
    @post = current_user.posts.find(params[:id])
  end

  def edit
    @post = current_user.posts.find(params[:id])
    @post.tag_names = @post.tags.pluck(:name).join(", ")
  end

  def update
    @post = current_user.posts.find(params[:id])
    if @post.update(post_params)
      redirect_to mypage_path, notice: "投稿が更新されました。"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @post = current_user.posts.find(params[:id])
    @post.destroy
    redirect_to posts_path, notice: "投稿が削除されました。"
  end

  private
  def post_params
    params.require(:post).permit(:title, :content, :date, :category, :tag_names)
  end
end
