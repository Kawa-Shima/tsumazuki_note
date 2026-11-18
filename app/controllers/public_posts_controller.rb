class PublicPostsController < ApplicationController
  before_action :authenticate_user!

  def index
    @posts = Post.where(is_public: true)
  end

  def show
     @posts = Post.where(is_public: true)
     @post = @posts.find(params[:id])
  end
end
