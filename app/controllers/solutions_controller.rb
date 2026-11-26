class SolutionsController < ApplicationController
  before_action :authenticate_user!

  def new
    @post = Post.where(user_id: current_user.id).or(Post.where(is_public: true)).find(params[:post_id])
    @solution = @post.solutions.build
  end

  def create
    @post = Post.where(user_id: current_user.id).or(Post.where(is_public: true)).find(params[:post_id])
    @solution = @post.solutions.build(solution_params)
    @solution.user = current_user
    if @solution.save
      if @post.user_id == current_user.id
        redirect_to post_path(@post), notice: "解決策が投稿されました。"
      else
        redirect_to public_post_path(@post), notice: "解決策が投稿されました。"
      end
    else
      if @post.user_id == current_user.id
        redirect_to post_path(@post), alert: "解決策の投稿に失敗しました。"
      else
        redirect_to public_post_path(@post), alert: "解決策の投稿に失敗しました。"
      end
    end
  end

  def edit
    @post = Post.where(user_id: current_user.id).or(Post.where(is_public: true)).find(params[:post_id])
    @solution = @post.solutions.where(user_id: current_user.id).find(params[:id])
  end

  def update
    @post = Post.where(user_id: current_user.id).or(Post.where(is_public: true)).find(params[:post_id])
    @solution = @post.solutions.where(user_id: current_user.id).find(params[:id])
    if @solution.update(solution_params)
      if @post.user_id == current_user.id
        redirect_to post_path(@post), notice: "解決策が更新されました。"
      else
        redirect_to public_post_path(@post), notice: "解決策が更新されました。"
      end
    else
      flash.now[:alert] = "解決策の更新に失敗しました。"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @post = Post.where(user_id: current_user.id).or(Post.where(is_public: true)).find(params[:post_id])
    @solution = @post.solutions.where(user_id: current_user.id).find(params[:id])
    @solution.destroy
     if @post.user_id == current_user.id
      redirect_to post_path(@post), notice: "解決策が削除されました。"
     else
      redirect_to public_post_path(@post), notice: "解決策が削除されました。"
     end
  end

  private
  def solution_params
    params.require(:solution).permit(:solution, :url)
  end
end
