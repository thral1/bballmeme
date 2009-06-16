ActionController::Routing::Routes.draw do |map|

  map.resources :urlinfos

  #map.resources :feedbacks

  map.resources :links

  #map.resources :articles

  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.
  # FBallnews.com routes
  map.connect '/', :controller => 'fb_articles', :action => 'index', :conditions => {:hostname => "fballnews" }
  map.connect '/hot', :controller => 'fb_articles', :action => 'hot', :conditions => {:hostname => "fballnews" }
  map.connect '/news', :controller => 'fb_articles', :action => 'news', :conditions => {:hostname => "fballnews" }
  map.connect '/blogs', :controller => 'fb_articles', :action => 'blogs', :conditions => {:hostname => "fballnews" }

  map.root :controller => 'fb_articles', :action => 'index', :conditions => {:hostname => "fballnews" }

  FBTeam.find(:all).each { |team|
    map.connect "/teams/#{team.name}", :controller => 'fb_teams', :action => 'show', :id => team.id, :conditions => {:hostname => "fballnews" }
    map.connect "/teams/#{team.name}/hot", :controller => 'fb_teams', :action => 'hot', :id => team.id, :conditions => {:hostname => "fballnews" }
    map.connect "/teams/#{team.name}/news", :controller => 'fb_teams', :action => 'news', :id => team.id, :conditions => {:hostname => "fballnews" }
    map.connect "/teams/#{team.name}/blogs", :controller => 'fb_teams', :action => 'blogs', :id => team.id, :conditions => {:hostname => "fballnews" }
  }

  map.connect 'about', :controller => 'fb_home', :action => 'about', :conditions => {:hostname => "fballnews" }
  map.connect 'contact', :controller => 'fb_home', :action => 'contact', :conditions => {:hostname => "fballnews" }
  map.connect 'help', :controller => 'fb_home', :action => 'help', :conditions => {:hostname => "fballnews" }

  # BBallnews.com routes
  map.connect '/', :controller => 'bb_articles', :action => 'index', :conditions => {:hostname => "bballnews" }
  map.connect '/hot', :controller => 'bb_articles', :action => 'hot', :conditions => {:hostname => "bballnews" }
  map.connect '/news', :controller => 'bb_articles', :action => 'news', :conditions => {:hostname => "bballnews" }
  map.connect '/blogs', :controller => 'bb_articles', :action => 'blogs', :conditions => {:hostname => "bballnews" }

  map.root :controller => 'bb_articles', :action => 'index', :conditions => {:hostname => "bballnews" }

  BBTeam.find(:all).each { |team|
    map.connect "/teams/#{team.name}", :controller => 'bb_teams', :action => 'show', :id => team.id, :conditions => {:hostname => "bballnews" }
    map.connect "/teams/#{team.name}/hot", :controller => 'bb_teams', :action => 'hot', :id => team.id, :conditions => {:hostname => "bballnews" }
    map.connect "/teams/#{team.name}/news", :controller => 'bb_teams', :action => 'news', :id => team.id, :conditions => {:hostname => "bballnews" }
    map.connect "/teams/#{team.name}/blogs", :controller => 'bb_teams', :action => 'blogs', :id => team.id, :conditions => {:hostname => "bballnews" }
  }

  map.connect 'about', :controller => 'bb_home', :action => 'about', :conditions => {:hostname => "bballnews" }
  map.connect 'contact', :controller => 'bb_home', :action => 'contact', :conditions => {:hostname => "bballnews" }
  map.connect 'help', :controller => 'bb_home', :action => 'help', :conditions => {:hostname => "bballnews" }



  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
  map.resources :articles
end
