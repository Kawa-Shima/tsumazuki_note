class SolutionsController < ApplicationController
  before_action :authenticate_user!

  def new
    @post = current_user.posts.find(params[:post_id])
    @solution = @post.solutions.build
  end

  def create
    @post = current_user.posts.find(params[:post_id])
    @solution = @post.solutions.build(solution_params)
    if @solution.save
      redirect_to post_path(@post), notice: "解決策が投稿されました。"
    else
      redirect_to post_path(@post), alert: "解決策の投稿に失敗しました。"
    end
  end

  def edit
    @post = current_user.posts.find(params[:post_id])
    @solution = @post.solutions.find(params[:id])
  end

  def update
    @post = current_user.posts.find(params[:post_id])
    @solution = @post.solutions.find(params[:id])
    if @solution.update(solution_params)
      redirect_to post_path(@post), notice: "解決策が更新されました。"
    else
      flash.now[:alert] = "解決策の更新に失敗しました。"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @post = current_user.posts.find(params[:post_id])
    @solution = @post.solutions.find(params[:id])
    @solution.destroy
    redirect_to post_path(@post), notice: "解決策が削除されました。"
  end

  private
  def solution_params
    params.require(:solution).permit(:solution, :url)
  end
end
