class PostsController < ApplicationController
  before_action :set_post, only: [:show, :edit, :update, :destroy]

  # GET /posts/favorite
  def favorite
    @posts = Post.where(liked: true)
  end

  # GET /posts/:post_id/commentator
  def commentator
    @post = Post.find(params[:id])
    @commentator_name = @post.commentator_name
  end

  # GET /posts
  def index
    # the Javascript fetch() points to '/posts?f=""', with params[:f]="" not nil,
    # and is served by "posts#index":
    if params[:f].present?
      #puts params[:f].present? #=> in the logs 
    # after clic, render this as text since fetch() receives .txt
      @posts = Post.all
      render partial: 'posts/posts', locals: {posts: @posts}, layout: false
    else
    #   # on page load, show nothing
      @posts = []
    end
  end

  def display_articles
      @posts = Post.all 
      respond_to :js
  end

  # GET /posts/:id
  def show
    @post = Post.find(params[:id])
    @comment = Comment.new(post: @post)
  end

  # GET /posts/new
  def new
    @post = Post.new
  end

  # GET /posts/:id/edit
  def edit
    @post = Post.find(params[:id])
  end

  # POST /posts
  def create
    @post = Post.new(post_params)
    respond_to do |format|
      if @post.save
        format.html { redirect_to @post, notice: 'Post was successfully created.' }
        format.json { render :show, status: :created, location: @post }
      else
        format.html { render :new }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /posts/:id
  def update
    @post = Post.find(params[:id])
    respond_to do |format|
      if @post.update(post_params)
        format.html { redirect_to @post, notice: 'Post was successfully updated.' }
        format.json { render :show, status: :ok, location: @post }
      else
        format.html { render :edit }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/:id
  def destroy
    @post = Post.find(params[:id])
    @post.comments.destroy_all #<=> dependent: :destroy in the model
    @post.destroy
    respond_to do |format|
      format.js
      format.html { redirect_to posts_url, notice: 'Post was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post
      @post = Post.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def post_params
      params.require(:post).permit(:title, :body)
    end
end
