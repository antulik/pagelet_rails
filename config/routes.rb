Rails.application.routes.draw do
  
  PageletRails::Router.load_routes!(self)

  get 'pagelet_proxy' => 'pagelet_proxy#show'

end
