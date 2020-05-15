class CommentsController < ApplicationController
  before_action :set_comment, only: [:show, :edit, :update, :destroy]
  before_action :set_post # all actions, whether for query string or routing

  # before nest: GET /comments
  # after nest: GET post/:post_id/comments
  def index
    # @comments = Comment.all
    @post = Post.find(params[:post_id]) # <=> before_action :set_post
    @comments = @post.comments
  end

  # GET posts/:post_id/comments/:id
  def show
    @post = Post.find(params[:post_id]) # <=> before_action :set_post
    @comment = Comment.find(params[:id])
  end

  # before nest: GET /comments/new
  # after nest: GET post/:post_id/comments/new
  def new
    # @comment = Comment.new
    @post = Post.find(params[:post_id]) # <=> before_action :set_post
    @comment = @post.comments.build
  end

  # before nest: GET /comments/1/edit
  # after nest: GET posts/:post_id/comments/:id
  def edit
    @post = Post.find(params[:post_id]) # <=> before_action :set_post
    @comment = Comment.find(params[:id])

  end

  # before nest: POST /comments
  # after nest: POST posts/:post_id/comments
  def create
    @post = Post.find(params[:post_id]) # <=> before_action :set_post
    #@comment = Comment.new(comment_params)
    @comment = @post.comments.build(comment_params)

    respond_to do |format|
      if @comment.save
        format.js
        format.html { redirect_to post_comments_path(@post), notice: 'Comment was successfully created.' }
        format.json { render :show, status: :created, location: @comment }
      else
        format.html { render :new }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  def save
    @comment = @post.comments.create(comment_params)
    respond_to do |format|
      format.js
    end
  end
  # PATCH/PUT /comments/1
  def update
    @post = Post.find(params[:post_id]) # <=> before_action :set_post
    @comment = Comment.find(params[:id])
    respond_to do |format|
      if @comment.update(comment_params)
        # @comments => post_comments_path(@post)
        format.html { redirect_to post_comments_path(@post), notice: 'Comment was successfully updated.' }
        format.json { render :show, status: :ok, location: @comment }
      else
        format.html { render :edit }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /comments/1 # modify path
  def destroy
    @post = Post.find(params[:post_id]) # <=> before_action :set_post
    @comment = Comment.find(params[:id])
    @comment.destroy
    respond_to do |format|
      format.js
      format.html { redirect_to post_path(@post), notice: 'Comment was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_comment
      @comment = Comment.find(params[:id])
    end

    def set_post
      @post = Post.find(params[:post_id])
    end

    # Only allow a list of trusted parameters through.
    def comment_params
      params.require(:comment).permit(:body, :post_id)
    end
end
