class SolutionsController < ApplicationController
  before_action :authenticate_user!

  def create
    @post = current_user.posts.find(params[:post_id])
    @solution = @post.solutions.build(solution_params)
    if @solution.save
      redirect_to post_path(@post), notice: "解決策が投稿されました。"
    else
      redirect_to post_path(@post), alert: "解決策の投稿に失敗しました。"
    end
  end

  private
  def solution_params
    params.require(:solution).permit(:solution, :url)
  end
end
