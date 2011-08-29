Savedis::Application.routes.draw do

  get "ajax/notes"

  resources :tags

  resources :favorites

  controller :sessions do
    get 'login' => :new
    delete 'logout' => :destroy
    post 'login' => :create
  end
  
  match "/popular" => redirect("/")
  
  get 'recent' => 'bookmarks#recent'
  
  get 'recentnotes' => 'notes#recent'
  
  get 'settings' => 'users#settings'

  #resources :users
  #resource :users, :except => [:new, :create]
  #get 'register' => 'users#new'

  resources :notes

  resources :bookmarks

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => 'bookmarks#popular'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
  #resources :users, :path => '/'
  resources :users
  get 'register' => 'users#new'
  
  #resources :users do 
  #  resources :notes
  #  resources :bookmarks
  #end
  
  scope ':username' do
    resources :notes, :as => :user_notes
    resources :bookmarks, :as => :user_bookmarks
  end
  
  #TODO: !! Find a better & cleaner way for this nested username bookmarks & notes update form issues!!
  match ":username/notes/:id" => "notes#update", :as => :update_user_note, :via => :put
  match ":username/bookmarks/:id" => "bookmarks#update", :as => :update_user_bookmark, :via => :put

  resources :tags do 
    resources :notes
    resources :bookmarks
  end
  
  match ":username" => "users#show", :as => :user_profile
  
end
