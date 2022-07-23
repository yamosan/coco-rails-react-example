class PostsController < ApplicationController
  before_action :set_my_post, only: %i[update destroy]
  before_action :set_post, only: %i[show]

  # GET /posts
  def index
    @posts = Post.all

    render json: @posts
  end

  # GET /posts/1
  def show
    render json: @post
  end

  # POST /posts
  def create
    @my_post = Post.new(**post_params, user_id: @current_user.id)

    if @my_post.save
      render json: @my_post, status: :created, location: @my_post
    else
      render json: @my_post.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /posts/1
  def update
    if @my_post.update(post_params)
      render json: @my_post
    else
      render json: @my_post.errors, status: :unprocessable_entity
    end
  end

  # DELETE /posts/1
  def destroy
    @my_post.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_post
    @post = Post.find(params[:id])
  end

  def set_my_post
    @my_post = @current_user.posts.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def post_params
    params.require(:post).permit(:title, :content)
  end
end
