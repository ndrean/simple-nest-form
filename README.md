# README

Simple one-to-may association _post / comment_ where the comments resources are namespaced by posts.

- Nested forms with namespace
- custom methods/routes

```ruby
#routes
root to: 'posts#index'

resources :posts do
    post 'comments/save'
    delete 'comments/:id', to: 'comments#erase'
    resources :comments do
    end
end
```

- render a nested form: we gave two examples

On the view 'show' for _/posts/1_, we have a form to create a nested _comment_ (=> comments#create) with rendering `<%= render 'comments/_form %>` where `<%= form_with model: [@post, @comment] do |form| %>` (`f.object` is a _comment_). The _posts#show_ furnishes a new comment object:

```ruby
def show
    @post = Post.find(params[:id])
    @comment = Comment.new(post: @post)
end
```

and on submit, the form calls by default the method _comments#create_ (the url would have been `post_comments_path(@post) <=> url: {controller: 'comments, action: "create"}` but it is automatically called by Rails):

```ruby
def create
    @post = Post.find(params[:post_id]) # <=> before_action :set_post
    @comment = @post.comments.build(comment_params)

    respond_to do |format|
      if @comment.save
        format.js
        format.html { redirect_to post_comments_path(@post), notice: 'Comment was successfully created.' }
      else
        format.html { render :new }
      end
    end
  end
```

From the index view _/posts/1/comments_, we have defined a custom method 'save' method (the standard _comments#create_ works with `respond_to js` since the formbuilder `form_with` has the attribute `remote: true` by default; here, we don't need JAXA rendering as we have a redirection in the view, so we defined a custom non-Ajax method) by defining the route

```ruby
resources: posts do
    post 'comments/save'
```

```ruby
#comments#save
def save
    respond_to do |format|
      @comment = @post.comments.create(comment_params)
      format.html { redirect_to post_comments_path(@post), notice: 'Comment was successfully created' }
    end
  end
```

so we have a view _/posts/1/comments/new_ that contains a form with `form_with ..., local: true` (non-Ajax):

```ruby
<%= form_with model: [@post, @comment], url: {controller:"comments", action: "save"}, local: true  do |form| %>

```

The command _rails routes_ shows that:

> url: post_comments_save_path(@post) <=> url: {controller:"comments", action: "save"}

We also defined two destroy methods in the controller _comments_ as the rendering was different. Both are Ajax.

We normally call a _destroy_ method, defined automatically in the _resouces_ routes with a link:

```ruby
    <%= link_to 'Destroy', post, method: :delete, remote: true, data: { confirm: 'Are you sure?' } %>

```

or `post_comment_path(comment.post, comment), method: :delete,`, if we use the nested object. Since we have two _delete_ in the controller _comments_, we need to specify the route:

```ruby
resources :posts do
    delete 'comments/:id', to: 'comments#erase'
```

and the call in the view _posts/:post_id/comments_ by the limnk:

```ruby
<%= link_to 'Erase', [@post, comment], url: "erase/#{comment.id}", method: :delete, remote: true,
```

and in the show _views/posts/:post_id_ calling the partial _views/comments/\_comment.html.erb_, we use:

```ruby
<%= link_to 'Destroy', [@post, comment], url: "destroy/#{comment.id}", method: :delete, remote: true, data: { confirm: 'Are you sure to Erase?' } %>
```

- To render an collection of comments:
  we can use: `<%= render @posts %>` (from the _posts#index_ view) to render the list of post where we defined a partial _views/posts/\_post.html.erb_ (as an _article_, where we have the _posts#destroy_ method

  or `<%= render @post.comments %>` to render all comments for a given post, and defined a partial _/views/comemnts/\_comment.html.erb_ (where we have the _comments#erase_ method).
