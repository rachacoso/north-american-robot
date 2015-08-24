Rails.application.routes.draw do


  root 'home#front'


  get   '/login' => 'session#new', as: 'login'
  post  '/login' => 'session#create'
  get   '/logout' => 'session#destroy', as: 'logout'

  get   '/dashboard' => 'home#dashboard', as: 'dashboard'

  get   '/admin' => 'admin#index', as: 'admin'
  get   '/admin/new_bulk_upload' => 'admin#new_bulk_upload', as: 'new_bulk_upload'
  post   '/admin/new_bulk_upload' => 'admin#do_bulk_upload'
  get   '/admin/distributors' => 'admin#distributors_index', as: 'admin_distributors_index'
  get   '/admin/brands' => 'admin#brands_index', as: 'admin_brands_index'
  get   '/admin/distributors/:id' => 'admin#distributor_view', as: 'admin_distributor_view'
  get   '/admin/brands/:id' => 'admin#brand_view', as: 'admin_brand_view'
  post   '/admin/adduser/:id' => 'admin#add_user', as: 'admin_add_user'
  delete   '/admin/deleteuser/:id' => 'admin#delete_user', as: 'admin_delete_user'


  resources :sectors, only: [:create, :update, :destroy]
  resources :channels, only: [:create, :update, :destroy]
  resources :company_sizes, only: [:create, :update, :destroy]
  resources :countries, only: [:create, :update, :destroy]
  resources :channel_capacities, only: [:create, :update, :destroy]
  resources :brand_photos, only: [:create, :destroy]
  resources :contacts, only: [:index, :new, :create, :update, :destroy]
  resources :tags, only: [:new, :create, :destroy]

  post '/bulkupdate' => 'channel_capacities#bulkupdate', as: 'channel_capacity_bulkupdate'

  resources :displays, only: [:create, :update, :destroy]
  put '/displays/:id/:photo' => 'displays#update', as: 'display_delete'
  resources :distributor_brands, only: [:create, :update, :destroy]
  resources :trade_shows, only: [:create, :update, :destroy]
  resources :press_hits, only: [:create, :update, :destroy]
  delete '/press_hits/file_delete/:id' => 'press_hits#file_destroy', as: 'press_hits_file_delete'
  resources :products, only: [:create, :update, :destroy]
  resources :patents, only: [:create, :update, :destroy]
  resources :trademarks, only: [:create, :update, :destroy]
  resources :compliances, only: [:create, :update, :destroy]
  resources :export_countries, only: [:create, :update, :destroy]


  resources :product_photos, only: [:create]
  delete '/product_photos/:id' => 'product_photos#destroy', as: 'product_photo_delete'

  resources :library_documents, only: [:update, :create, :index]
  delete '/library_documents/:id' => 'library_documents#destroy', as: 'library_document_delete'



  # Deprecated
  # resources :sales_sizes, only: [:create, :update, :destroy]
  # resources :marketing_spends, only: [:create, :update, :destroy]
  
  resources :users, only: [:new, :create, :edit, :update, :destroy, :index]
  
  get    '/distributors' => 'distributors#edit', as: 'distributor'
  get    '/distributors/public_profile' => 'distributors#public_profile', as: 'distributor_public_profile'
  get    '/distributors/full_profile' => 'distributors#full_profile', as: 'distributor_full_profile'
  patch  '/distributors' => 'distributors#update'
  patch  '/distributor_brands' => 'distributor_brands#update'
  patch  '/distributors/adminupdate/:id' => 'distributors#adminupdate', as: 'distributor_admin_update'
  delete '/distributors/validation/delitem' => 'distributors#validation_delete', as: 'distributor_validation_delete'

  
  get    '/brands' => 'brands#edit', as: 'brand'
  get    '/brands/public_profile' => 'brands#public_profile', as: 'brand_public_profile'
  get    '/brands/full_profile' => 'brands#full_profile', as: 'brand_full_profile'
  patch  '/brands' => 'brands#update'
  patch  '/brands/adminupdate/:id' => 'brands#adminupdate', as: 'brand_admin_update'

  get '/onboard/distributor/one' => 'onboard_distributor#one', as: 'onboard_distributor_one'
  get '/onboard/distributor/two' => 'onboard_distributor#two', as: 'onboard_distributor_two'
  get '/onboard/distributor/three' => 'onboard_distributor#three', as: 'onboard_distributor_three'
  get '/onboard/distributor/four' => 'onboard_distributor#four', as: 'onboard_distributor_four'
  get '/onboard/distributor/five' => 'onboard_distributor#five', as: 'onboard_distributor_five'
  get '/onboard/distributor/six' => 'onboard_distributor#six', as: 'onboard_distributor_six'
  # get '/onboard/distributor/seven' => 'onboard_distributor#seven', as: 'onboard_distributor_seven'
  # get '/onboard/distributor/eight' => 'onboard_distributor#eight', as: 'onboard_distributor_eight'

  get '/onboard/brand/one' => 'onboard_brand#one', as: 'onboard_brand_one'
  get '/onboard/brand/two' => 'onboard_brand#two', as: 'onboard_brand_two'
  get '/onboard/brand/three' => 'onboard_brand#three', as: 'onboard_brand_three'
  get '/onboard/brand/four' => 'onboard_brand#four', as: 'onboard_brand_four'
  get '/onboard/brand/five' => 'onboard_brand#five', as: 'onboard_brand_five'
  get '/onboard/brand/six' => 'onboard_brand#six', as: 'onboard_brand_six'
  get '/onboard/brand/seven' => 'onboard_brand#seven', as: 'onboard_brand_seven'
  get '/onboard/brand/eight' => 'onboard_brand#eight', as: 'onboard_brand_eight'

  get '/matches' => 'matches#index', as: 'all_matches'
  get '/savedmatches' => 'matches#index_saved_matches', as: 'saved_matches'
  get '/contactedmatches' => 'matches#index_contacted_matches', as: 'contacted_matches'
  get '/incomingmatches' => 'matches#index_incoming_matches', as: 'incoming_matches'
  get '/conversations' => 'matches#index_conversations', as: 'conversations'
  post '/matches' => 'matches#index'
  get '/matches/save/:match_id' => 'matches#save_match', as: 'save_match'
  get '/matches/unsave/:match_id/:remove' => 'matches#unsave_match', as: 'unsave_match'
  get '/matches/view/:match_id/:referrer' => 'matches#view_match', as: 'view_match'
  get '/matches/contact/:match_id' => 'matches#contact_match', as: 'contact_match'
  get '/matches/search' => 'matches#search', as: 'search'
  post '/matches/stage/update/:id' => 'matches#match_stage_update', as: 'match_stage_update'
  get '/matches/stage/view/:id/:stage' => 'matches#match_stage_view', as: 'match_stage_view'
  get '/matches/profilequickview/:match_id' => 'matches#profile_quick_view', as: 'profile_quick_view'
  get '/matches/contract/:match_id' => 'matches#view_contract', as: 'view_contract'
  post '/matches/accept/:id' => 'matches#accept_match', as: 'accept_match'
  get '/gallery' => 'matches#gallery', as: 'gallery'
  # post '/matches/share/:match_id' => 'matches#match_share', as: 'match_share'
  patch '/matches/share/:match_id' => 'matches#match_share', as: 'match_share'

  # post '/conversations/share' => 'conversations#share', as: 'conversation_share'

  resources :messages, only: [:create, :index]
  resources :password_resets
  # get 'messages/all/:match_id' => 'messages#all_messages', as: 'all_messages'

end
