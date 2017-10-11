# PageletRails

[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/antulik/pagelet_rails/master/LICENSE)
[![Gem Version](https://badge.fury.io/rb/pagelet_rails.svg)](https://badge.fury.io/rb/pagelet_rails)
[![Build Status](https://travis-ci.org/antulik/pagelet_rails.svg?branch=master)](https://travis-ci.org/antulik/pagelet_rails)
[![Code Climate](https://codeclimate.com/github/antulik/pagelet_rails/badges/gpa.svg)](https://codeclimate.com/github/antulik/pagelet_rails)
[![Test Coverage](https://codeclimate.com/github/antulik/pagelet_rails/badges/coverage.svg)](https://codeclimate.com/github/antulik/pagelet_rails/coverage)

PageletRails is the addon for Rails which allows you to build components. Achieve amazing performance and reusability by slicing your webpages into components. PageletRails is built on top of Rails and uses it as much as possible. The main philosophy: **Do not reinvent the wheel, build on shoulders of giants.**

## Why?

* Do you have pages with a lot of information?
* The pages where you need to get data from 5 or 10 different sources?
* What if one of them is slow?
* Does this mean your users have to wait?

Don't make your users wait for page to load.

[View Demo Project](http://polar-river-18908.herokuapp.com)

## Example

![](https://camo.githubusercontent.com/50f4078cc4015e3df89afc753a5ff79828ac0e8e/68747470733a2f2f73332e616d617a6f6e6177732e636f6d2f662e636c2e6c792f6974656d732f303031323133314d324b3147335831483276314f2f313433303033383036373738372e6a7067)

For example let's take facebook user home page. It has A LOT of data, but it loads very quickly. How? The answer is [perceived performance](https://en.wikipedia.org/wiki/Perceived_performance). It's not about in how many milliseconds you can serve request, but how fast it **feels** to the user.

The page body is served instantly and all the data is loaded after. Even for facebook it takes multiple seconds to fully load the page. But it feels instant, that it's all about.

## Who is doing that?

Originally I saw such solution implemented at Facebook and Linkedin. Each page consists of small blocks, where each is responsible for it's own functionality and does not depend on the page where it's included. You can read more on that below.

* [BigPipe: Pipelining web pages for high performance](https://www.facebook.com/notes/facebook-engineering/bigpipe-pipelining-web-pages-for-high-performance/389414033919/)
* [Engineering the New LinkedIn Profile](https://engineering.linkedin.com/profile/engineering-new-linkedin-profile)
* [Play Framework & SF Scala: Jim Brikman, Composable Applications in Play, 7/23/14](https://www.youtube.com/watch?v=4b1XLka0UIw)

## What is Pagelet?

You can break a web page into number of sections, where each one is responsible for its own functionality. Pagelet is the name for each section. It is a part of the page which has it's own route, controller and view.

The closest alternative in ruby is [cells gem](https://github.com/apotonick/cells). After using it for long time I've faced many limitations of its approach. Cells has a custom Rails-like syntax but not quite. That is frustrating as you have to learn and remember those differences. The second issue, and the biggest, cells are internal only and not designed to be routable. This stops many great possibilities for improving perceived performance, as request has to wait for all cells to render.

# Usage


## Installation
Add this line to your application's Gemfile:

```ruby
gem 'pagelet_rails'
```

Or install it yourself as:
```bash
$ gem install pagelet_rails
```

## Setup

Include small javascript extension `pagelet_rails`:

```js
// file app/assets/javascripts/application.js

//= require jquery
//= require jquery_ujs
// ...
//= require pagelet_rails

````

## Structure

```
app
├── pagelets
│   ├── current_time
│   │   ├── current_time_controller.rb
│   │   ├── views
│   │   │   ├── show.erb
```

## Example Usage

```ruby
# app/pagelets/current_time/current_time_controller.rb
class CurrentTime::CurrentTimeController < ApplicationController
  include PageletRails::Concerns::Controller

  # add pagelets_current_time_path route
  # which gives "/pagelets/current_time" url route
  pagelet_resource only: [:show]

  def show
  end
end
```

```erb
<!-- Please note view path -->
<!-- app/pagelets/current_time/views/show.erb -->
<div class="panel-heading">Current time</div>

<div class="panel-body">
  <p><%= Time.now %></p>
  <p>
    <%= link_to 'Refresh', pagelets_current_time_path, remote: true %>
  </p>
</div>
```

And now use it anywhere in your view

```erb
<!-- app/views/dashboard/show.erb -->
<%= pagelet :pagelets_current_time %>
```

## Documentation

- [Pagelet view helper](#pagelet-view-helper)
- [Pagelet options](#pagelet-options)
- [Inline routes](#inline-routes)
- [Pagelet cache](#pagelet-cache)
- [Advanced functionality](#advanced-functionality)
  - [Partial update](#partial-update)
  - [Streaming](#streaming)
  - [Super smart caching](#super-smart-caching)
  - [Ajax Batching](#ajax-batching)

## Pagelet view helper

`pagelet` helper allows you to render pagelets in views. Name of pagelet is its path.

For example pagelet with route `pagelets_current_time_path` will have `pagelets_current_time` name.

### remote

Example
```erb
<%= pagelet :pagelets_current_time, remote: true %>
```

Options for `remote`:
* `true`, `:ajax` - always render pagelet through ajax
* `:turbolinks`  - same as `:ajax` but inline for turbolinks page visit
* `false` or missing - render inline
* `:stream` - (aka BigPipe) render placeholder and render full version at the end of html. See streaming for more info.
* `:ssi` - render through [server side includes](https://en.wikipedia.org/wiki/Server_Side_Includes)

### params

Example
```erb
<%= pagelet :pagelets_current_time, params: { id: 123 } %>
```

`params` are the parameters to pass to pagelet path. Same as `pagelets_current_time_path(id: 123)`

### html

```erb
<%= pagelet :pagelets_current_time, html: { class: 'panel' } %>
```

You can specify html attributes to pagelet with `html` option

### placeholder

Configuration for placeholder before pagelet is loaded.

```erb
<%= pagelet :pagelets_current_time, placeholder: { text: 'Loading...', height: 300 } %>
```

or use your own placeholder template

```erb
 <%= pagelet :pagelets_current_time, placeholder: { view: 'path_to_template' } %>
```

### other

You can pass any other data and it will be available in `pagelet_options`

```erb
<%= pagelet :pagelets_current_time, title: 'Hello' %>
```

```ruby
# ...
  def show
    @title = pagelet_options.title
  end
#...
```


## Pagelet options

`pagelet_options` is similar to `params` object, but for private data and config. Options can be global for all actions or specific actions only.

```ruby
class CurrentTime::CurrentTimeController < ::ApplicationController
  include PageletRails::Concerns::Controller

  # Set default option for all actions
  pagelet_options remote: true

  # set option for :show and :edit actions only
  pagelet_options :show, :edit, remote: :turbolinks

  def show
  end

  def new
  end

  def edit
  end

end
```

```erb
<%= pagelet :new_pagelets_current_time %><!-- defaults to remote: true -->
<%= pagelet :pagelets_current_time %> <!-- defaults to remote: turbolinks -->

<%= pagelet :pagelets_current_time, remote: false %> <!-- force remote: false -->
```

## Inline routes

Because pagelets are small you will have many of them. In order to keep them under control pagelet_rails provides helpers.

You can inline routes inside you controller.

```ruby
class CurrentTime::CurrentTimeController < ::ApplicationController
  include PageletRails::Concerns::Controller

  pagelet_resource only: [:show]
  # same as in config/routes.rb:
  #
  # resource :current_time, only: [:show]
  #

  pagelet_resources
  # same as in config/routes.rb:
  #
  # resources :current_time
  #

  pagelet_routes do
    # this is the same context as in config/routes.rb:
    get 'show_me_time' => 'current_time/current_time#show'
  end

end
```

## Pagelet cache

Cache of pagelet rails is built on top of [actionpack-action_caching gem](https://github.com/rails/actionpack-action_caching).

Simple example

```ruby
# app/pagelets/current_time/current_time_controller.rb
class CurrentTime::CurrentTimeController < ::ApplicationController
  include PageletRails::Concerns::Controller

  pagelet_options expires_in: 10.minutes

  def show
  end

end
```

### cache_path

Is a hash of additional parameters for cache key.

* `Hash` - static hash
* `Proc` - dynamic params, it must return hash. Eg. `Proc.new { params.permit(:sort_by) }`
* `Lambda` - same as `Proc` but accepts `controller` as first argument
* `String` - any custom identifier

### expires_in

Set the cache expiry. For example `expires_in: 1.hour`.

Warning: if `expires_in` is missing, it will be cached indefinitely.

### cache

This is toggle to enable caching without specifying options. `cache_defaults` options will be used (see below).

If any of `cache_path`, `expires_in` and `cache` is present then cache will be enabled.


### cache_defaults

You can set default options for caching.

```ruby
class PageletController < ::ApplicationController
  include PageletRails::Concerns::Controller

  pagelet_options cache_defaults: {
    expires_in: 5.minutes,
    cache_path: Proc.new {
      { user_id: current_user.id }
    }
  }
end
```

In the example above cache will be scoped per `user_id` and for 5 minutes unless it is overwritten in pagelet itself.


## Advanced functionality

### Partial update

```erb
<!-- app/pagelets/current_time/views/show.erb -->
<div class="panel-heading">Current time</div>

<div class="panel-body">
  <p><%= Time.now %></p>
  <p>
    <%= link_to 'Refresh', pagelets_current_time_path, remote: true %>
  </p>
</div>
```
Please note `remote: true` option for `link_to`.

This is default Rails functionality with small addition. If that link is inside pagelet, than controller response will be replaced in that pagelet.

```ruby
# app/pagelets/current_time/current_time_controller.rb
class CurrentTime::CurrentTimeController < ::ApplicationController
  include PageletRails::Concerns::Controller

  pagelet_resource only: [:show]

  def show
  end

end
```

This will partially update the page and replace only that pagelet.


### Streaming

This is the most efficient way to deliver data with minimum delays. The placeholder will be rendered first and the full version will be delivered at the end of page and replaced with Javascript code. Everything is delivered in the same request.

This mode requires rendering of templates with [streaming mode](http://api.rubyonrails.org/classes/ActionController/Streaming.html) enabled.

Warning: Session and Cookies are currently not supported in streaming mode.

```ruby
  #...
  def show
    render :show, stream: true
  end
  #...
```

In you layout add `pagelet_stream` right before `</body>` tag.

```erb
<!-- app/views/layouts/application.erb -->

<body>
<%= yield %>

<% pagelet_stream %>
</body>
```

Usage:

```erb
<%= pagelet :pagelets_current_time, remote: :stream %>
```

**Warning!!!** You also should have webserver compatible for streaming like puma, passenger or unicorn (requires special config).

**Warning!!!** you need to have multiple threads/processes configured in the web server. This is required so the page could fetch assets while content is streaming.

Finally if everything is done right you should see significant rendering speed improvements especially on old browsers, slow network or with cold cache.


### Super smart caching

Probably one of the coolest functionality of pagelet_rails is "super smart caching". It allows you to render pagelets through ajax and cache them, but if page is reloaded the pagelet is rendered instantly from cache.

 So on the first page load user sees "Loading..." blocks, but after the content is instant.

The best thing, it's enabled by default if pagelet has caching enabled and is rendering through ajax request.

### Ajax Batching

Only relevant for `remote: true` and `remote: :turbolinks` when request is loaded through ajax. Loading each pagelet with a separate request is inefficient if you need to do make many requests. That's why you need to group multiple requests into one. By default all ajax requests are grouped into single request. But you can have full control of it. You can specify how to group requests with `ajax_group` option.

```erb
<%= pagelet :pagelets_current_time, remote: true, ajax_group: 'main' %>
<%= pagelet :pagelets_current_time, remote: true, ajax_group: 'leftpanel' %>
```

There will be one request per group. Missing value is considered a separate group as well.

## Todo

* assets support with webpacker in rails 5.1
* session (and CSRF) support in streaming mode
* delay load of not visible pagelets (aka. below the fold)
  * do not load pagelets which are not visible to the user until user scrolls down. For example like Youtube comments.
* high test coverage
* update actionpack-action_caching gem to support rails 5

## Links

- [Parallel rendering in Rails](http://antulik.com/posts/2016-10-02-parallel-rendering-in-rails.html)

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

