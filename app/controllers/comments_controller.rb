class CommentsController < ApplicationController
  before_action :set_comment, only: [:show, :edit, :update, :destroy]
  

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
    @post = Post.find(params[:post_id]) # <=> before_action :set_post
    @comment = @post.comments.build
  end

  # not nested
  def edit
    @comment = Comment.find(params[:id])

  end

  # POST posts/:post_id/comments
  def create
    @post = Post.find(params[:post_id]) # <=> before_action :set_post
    @comment = @post.comments.build(comment_params)

    # alternative:
    @post = Post.find(params[:post_id])
    @comment = Comment.new(comment_params)
    @comment.post = @post
    ##

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

  # custom route namespaced by posts to 'comments#save'
  def save
    @post = Post.find(params[:post_id])
    #byebug
    respond_to do |format|
      @comment = @post.comments.create(comment_params)
      format.html { redirect_to post_comments_path(@comment.post), notice: 'Comment was successfully created' }
    end
  end

  # PATCH/PUT /comments/1
  def update
    #@post = Post.find(params[:post_id]) # <=> before_action :set_post
    @comment = Comment.find(params[:id])
    respond_to do |format|
      if @comment.update(comment_params)
        # @comments => post_comments_path(@post)
        format.html { redirect_to post_comments_path(@comment.post), notice: 'Comment was successfully updated.' }
        format.json { render :show, status: :ok, location: @comment }
      else
        format.html { render :edit }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /comments/1 # modify path
  def destroy
    #@post = Post.find(params[:post_id]) # <=> before_action :set_post
    @comment = Comment.find(params[:id])
    @comment.destroy
    respond_to do |format|
      format.js
      format.html { redirect_to post_path(@post), notice: 'Comment was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def erase
    #@post = Post.find(params[:post_id]) # <=> before_action :set_post
    @comment = Comment.find(params[:id])
    @comment.destroy
    respond_to do |format|
      format.js
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_comment
      @comment = Comment.find(params[:id])
    end

    # def set_post
    #   @post = Post.find(params[:post_id])
    # end

    # Only allow a list of trusted parameters through.
    def comment_params
      params.require(:comment).permit(:body, :post_id)
    end
end
