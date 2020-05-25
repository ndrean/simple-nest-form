# README

Simple one-to-may association _post / comment_ where the comments resources are namespaced by posts: `posts/:post_id/comments/:id`.

- [Rendering a collection of comments](#rendering-a-collectino-of-comments)

- [ Render a nested form](#render-a-nested-form) with `@post, @comment`

- [Fetch GET for Post.all with 2 Ajax method](#fetch-GET-AJAX)
- [Other examples of custom routes/methods](#other-examples-of-custom-routes/methods)

- [ Reminder installation Bootstrap & Simple Form ](#bootstrap-simple-form-setup)

## Routes:

```ruby
#routes
Rails.application.routes.draw do

  root to: 'posts#index'

  resources :posts do
    post 'save/:id', to: 'comments#save', as: 'save'

    post 'comments/save'
    #delete 'comments/:id', to: 'comments#erase'
    resources :comments, only: [:index, :new, :create]
  end

  get 'articles', to: 'posts#display_articles'

  resources :comments, only: [:destroy, :show, :edit, :update]

  delete 'erase/:id', to: "comments#erase", as: 'erase'

end
```

## Render a collection of comments

Example in the view _/views/posts_ that renders the method _posts#index_. We can iterate with a table and use `<% @posts.each do |post| %> <%= post.title %> ...`. We can also use `<%= render @posts %>` to render the list of post defined in a partial _views/posts/\_post.html.erb_ (as an _article_).

Another example with `<%= render @post.comments %>` to render all comments for a given post, with the partial _/views/comments/\_comment.html.erb_.

## Render a nested form

Two examples.

1. On the view 'show' for _/posts/1_, we have a form to create a nested _comment_ (=> comments#create). The form is rendered with the partial `<%= render 'comments/_form %>`. We use the formbuilder `form_with` and define:

```ruby
# /views/post/1 posts/show
<% render comments/forms %
# views/comments/_forms.html.erb
 <%= form_with model: [@post, @comment] do |form| %
```

(where the form object `f.object` is a _comment_). The _posts#show_ furnishes a new comment object:

```ruby
def show
    @post = Post.find(params[:id])
    @comment = Comment.new(post: @post)
end
```

and on submit, the form calls by default the method _comments#create_ (the url would have been `post_comments_path(@post)`. It automatically calls the method _comments#create_ from the other controller:

```ruby
#comments_controller.rb
def create
    @post = Post.find(params[:post_id]) # <=> before_action :set_post
    @comment = @post.comments.build(comment_params)
    # we decided to inject the new comment by JAvascript in the 'posts/:post_id#show' view => respond_to js
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

2. In the index view _/posts/1/comments/new_, we have defined a custom method 'save' method (the standard _comments#create_ works with `respond_to js` since the formbuilder `form_with` has the attribute `remote: true` by default; here, we don't need AJAX rendering as we have a redirection in the view, so we could have used the html rendering and declare `local: true`). For this, we define a new route:

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
# views/posts/:post_id/comments/new
<%= form_with model: [@post, @comment], url: {controller:"comments", action: "save"}, local: true  do |form| %>

```

The command _rails routes_ shows that:

> url: post_comments_save_path(@post) <=> url: {controller:"comments", action: "save"}

## Fetch GET AJAX

We defined a button to display all the posts. On page load, the list is empty
We defined a JS `fetch() GET` function that triggers on this button click,
and points to the URL `/posts?f=""`. This URL is served by the method 'posts#index'.
We put a query string `f=""` such that we can differenciate the presence of params so
that the method `index` can react differently: an empty array `[]` on page load, and
`Post.all` when 'index' sees some params. Then we render a partial. Note that it is
important to use `locals: {posts: @posts}` for this to work (usually we don't need `locals`).
The JS `fetch()` asks for 'text/html' and parses the response from 'index' into 'text' with `response.text()`.
Then we just pass this content in the (unsual) form 'text/html' (parsed by Ruby, see in the console/network call) to render in
the view.</p>

<p>Note: we need Turbolinks to be loaded to use the JS methods (see 'application.js')</p>

```ruby
# post_controller.rb
def index
  if params[:f].present?
    @posts = Post.all
    render partial: 'posts/posts', locals: {posts: @posts}, layout: false
  else
  #   # on page load, show nothing
    @posts = []
  end
end
```

```js
#/packs/components/fetchPosts.js
const fetchPosts = (tag) => {
  document.querySelector(tag).addEventListener("click", (e) => {
    e.preventDefault();
    try {
      const query = await fetch('/posts?f=""', {
        method: "GET",
        headers: {
          "Content-Type": "text/html",
          Accept: "text/html",
        },
        credentials: "same-origin", // default value
      });
      if (query.ok) {
        const content = await query.text();
        return (document.querySelector("#posts_list").innerHTML = content);
      }
    } catch (error) {
      throw error;
    }
  });
};

export { fetchPosts };
```

> We can use `innerHTML` to render this text.

We can compare this to a traditionnal method using a `link_to, remote: true` to another method that renders a `js.erb` file:

```ruby
#posts#display_articles
def display_articles
      @posts = Post.all
      respond_to :js
  end
```

```js
document.querySelector("#articles_list").innerHTML = "";
document
  .querySelector("#articles_list")
  .insertAdjacentHTML("afterbegin", `<%= j render @posts %>`);
```

> We need `insertAdjacentHTML` and not `innerHTML` to work.

## Other examples of custom routes/methods

We also defined two destroy methods in the controller _comments_ . Both are Ajax but the rendering is different. Note that we could have written a `<% if condition %> { do something} <% else %> { do something else}` in a _destroy.js.erb_ file.

A _destroy_ method defined in the resources list is called - for a _post_ object by a link (made Ajax here with `remote: true`)

```ruby
    <%= link_to 'Destroy', post, method: :delete, remote: true, data: { confirm: 'Are you sure?' } %>

```

For a _destroy_ link for the nested _comments_ controller, the link would have been `post_comment_path(comment.post, comment), method: :delete,`.

Here, we have two _delete_ in the controller _comments_ so we need to specify the route:

```ruby
resources :posts do
    delete 'comments/:id', to: 'comments#erase'
```

and the call in the view _posts/:post_id/comments_ by the link:

```ruby
<%= link_to 'Erase', [@post, comment], url: "erase/#{comment.id}", method: :delete, remote: true,
```

and in the show _views/posts/:post_id_ calling the partial _views/comments/\_comment.html.erb_, we use:

```ruby
<%= link_to 'Destroy', [@post, comment], url: "destroy/#{comment.id}", method: :delete, remote: true, data: { confirm: 'Are you sure to Erase?' } %>
```

## Bootstrap Simple Form setup

```bash
yarn add bootstrap
```

- Modifiy _#assp/Assets/Stylesheets/application.css_ to _.scss_ and add: `@import "bootstrap/scss/bootstrap";`

- in _/layout/application.html.erb_ do

```html
<head>
  ...
  <meta http-equiv="X-UA-Compatible" content="IE=edge" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
</head>
```

```ruby
gem 'simple_form'
```

```bash
bundle
rails g simple_form:install --bootstrap
```
