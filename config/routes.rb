Rails.application.routes.draw do

  root 'home#front'


  get   '/login' => 'session#new', as: 'login'
  post  '/login' => 'session#create'
  get   '/logout' => 'session#destroy', as: 'logout'

  get   '/ps/:id/' => 'home#prospect_share', as: 'prospect_share'
  post   '/ps/l' => 'home#prospect_share_login', as: 'prospect_share_login'

  get   '/dashboard' => 'home#dashboard', as: 'dashboard'

  get   '/admin' => 'admin#index', as: 'admin'
  get   '/admin/new_bulk_upload' => 'admin#new_bulk_upload', as: 'new_bulk_upload'
  post   '/admin/new_bulk_upload' => 'admin#do_bulk_upload'
  get   '/admin/distributors' => 'admin#distributors_index', as: 'admin_distributors_index'
  get   '/admin/brands' => 'admin#brands_index', as: 'admin_brands_index'
  get   '/admin/retailers' => 'admin#retailers_index', as: 'admin_retailers_index'
  get   '/admin/orders/:group' => 'admin#orders_index', as: 'admin_orders_index'
  post   '/admin/orders/search/' => 'admin#orders_search', as: 'admin_orders_search'
  post   '/admin/orders/bc/' => 'admin#orders_by_company', as: 'admin_view_orders_by_company'
  get   '/admin/orders/search/pre/brands' => 'admin#orders_pre_search_brands', as: 'admin_orders_pre_search_brands'
  get   '/admin/orders/search/pre/buyers' => 'admin#orders_pre_search_buyers', as: 'admin_orders_pre_search_buyers'
  get   '/admin/order/d/:id/:confirm' => 'admin#order_destroy', as: 'admin_order_destroy'
  get   '/admin/distributor/:id' => 'admin#distributor_view', as: 'admin_distributor_view'
  get   '/admin/brand/:id' => 'admin#brand_view', as: 'admin_brand_view'
  get   '/admin/retailer/:id' => 'admin#retailer_view', as: 'admin_retailer_view'
  get   '/admin/order/:id' => 'admin#order_view', as: 'admin_order_view'
  post   '/admin/adduser/:id' => 'admin#add_user', as: 'admin_add_user'
  delete   '/admin/deleteuser/:id' => 'admin#delete_user', as: 'admin_delete_user'


  # ORDERS
  resources :orders, only: [:show, :edit, :update, :destroy, :index]
  post   '/orders/search/' => 'orders#orders_search', as: 'orders_search'
  post   '/order/new' => 'orders#create', as: 'new_order'
  get   '/order/s/:id/:confirm' => 'orders#submit', as: 'submit_order'
  get   '/order/p/:id/:confirm' => 'orders#pending', as: 'pending_order'
  patch   '/order/p/:id/:confirm' => 'orders#pending'
  get   '/order/a/:id/:confirm' => 'orders#approve', as: 'approve_order'
  get   '/order/da/:id/:confirm' => 'orders#decline_approval', as: 'decline_approval_order'
  patch '/order/da/:id/:confirm' => 'orders#decline_approval'
  post  '/order/shipment/:id' => 'orders#shipment', as: 'order_shipment_info'
  # for non armor orders
  get   '/order/c/:id/:confirm' => 'orders#complete', as: 'complete_order'
  get   '/order/add/:id/:confirm' => 'orders#armor_disabled_delivered', as: 'armor_disabled_received_order'
  get   '/order/adc/:id/:confirm' => 'orders#armor_disabled_completed', as: 'armor_disabled_completed_order'
  # for order comments
  patch   '/order/comments/:id' => 'comments#update', as: 'order_update_comment'
  # order-calculator display
  get   'order/calculator/show/:id' => 'orders#show_calculator', as: 'show_order_calculator'

# PACKING LISTS

  get   '/admin/packinglists' => 'packing_lists#index', as: 'packing_lists'
  get   '/admin/packinglist/new' => 'packing_lists#new', as: 'new_packing_list'
  patch   '/admin/packinglist/update' => 'packing_lists#update', as: 'update_packing_list'

# comments
  resources :comments, only: [:create]

  # ARMOR PAYMENTS TESTING
  get   '/order/paid/:id/:confirm' => 'orders#paid', as: 'paid_order'
  get   '/order/delivered/:id/:confirm' => 'orders#delivered', as: 'delivered_order'

  resources :order_items, only: [:create, :edit, :update, :index]
  get   '/order/newitem/:product_id' => 'order_items#new', as: 'new_order_item'
  delete '/order/order_items/:o/:id' => 'order_items#destroy', as: 'delete_order_item'

  post   'order/charges/a/:order_id' => 'order_additional_charges#create', as: 'create_order_additional_charge'
  patch   'order/:order_id/charges/u/:id' => 'order_additional_charges#update', as: 'update_order_additional_charge'
  delete   'order/:order_id/charges/d/:id' => 'order_additional_charges#destroy', as: 'delete_order_additional_charge'

  # ARMOR PAYMENTS
  post  '/ap/complete' => 'armor_payments#complete_required', as: 'ap_complete_required'
  post  '/ap/create' => 'armor_payments#create_account', as: 'ap_create_account'
  post  '/ap/disable' => 'armor_payments#disable', as: 'ap_disable'
  post  '/ap/wh' => 'armor_payments#webhook'

  # "static" pages
  get  '/pages/:page' => 'pages#show'

  resources :articles, only: [:index, :show, :update, :destroy]
  get  '/article/view/:id' => 'articles#public_view', as: 'public_view_article'
  post  '/article/new/:type' => 'articles#create', as: 'create_article'
  post  '/article/fb/:id' => 'articles#featured_brand', as: 'article_featured_brand'
  delete  '/article/fb/:id/:fb_id' => 'articles#delete_featured_brand', as: 'delete_article_featured_brand'
  post  '/article/fp/:id' => 'articles#featured_product', as: 'article_featured_product'
  delete  '/article/fp/:id/:fp_id' => 'articles#delete_featured_product', as: 'delete_article_featured_product'
  delete  '/article/carousel/:id/' => 'articles#delete_carousel_photo', as: 'delete_article_carousel_photo'
  delete  '/article/tile/:id/' => 'articles#delete_tile_photo', as: 'delete_article_tile_photo'

  resources :article_photos, only: [:create]
  delete '/article_photos/:id/:article_id' => 'article_photos#destroy', as: 'delete_article_photo'

  resources :sectors, only: [:create, :update, :destroy]
  resources :subsectors, only: [:create, :update, :destroy]
  resources :channels, only: [:create, :update, :destroy]
  resources :company_sizes, only: [:create, :update, :destroy]
  resources :key_retailers, only: [:create, :update, :destroy]
  resources :trends, only: [:create, :update, :destroy]
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
  get   'product/preview/:id' => 'products#preview', as: 'product_preview'
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
  get    '/users/admin' => 'users#admin_index', as: 'users_admin'
  get    '/user/confirm/:token' => 'users#confirm_email', as: 'user_email_confirmation'
  patch    '/user/lu/:id' => 'users#limited_update', as: 'user_limited_update'

  get    '/distributor/edit' => 'distributors#edit', as: 'distributor'
  get    '/distributor/full_profile' => 'distributors#full_profile', as: 'distributor_full_profile'
  patch  '/distributor/edit' => 'distributors#update'
  patch  '/distributor_brands' => 'distributor_brands#update'
  patch  '/distributor/adminupdate/:id' => 'distributors#adminupdate', as: 'distributor_admin_update'
  delete '/distributor/validation/delitem' => 'distributors#validation_delete', as: 'distributor_validation_delete'

  get    '/retailer/edit' => 'retailers#edit', as: 'retailer'
  get    '/retailer/full_profile' => 'retailers#full_profile', as: 'retailer_full_profile'
  patch  '/retailer/edit' => 'retailers#update'
  patch  '/retailer/adminupdate/:id' => 'retailers#adminupdate', as: 'retailer_admin_update'
  delete '/retailer/validation/delitem' => 'retailers#validation_delete', as: 'retailer_validation_delete'


  # v2 public view
  get    '/brands' => 'brands#index', as: 'brands'
  get    '/brands/s/' => 'brands#search', as: 'search_brands'
  get    '/brand/view/:id' => 'brands#view', as: 'view_brand'
  get    '/brand/preview/:id' => 'brands#preview', as: 'preview_brand'

  get    '/retailer/view/:id' => 'retailers#view', as: 'view_retailer'
  get    '/distributor/view/:id' => 'distributors#view', as: 'view_distributor'

  # for brand editing
  get    '/brand/edit' => 'brands#edit', as: 'brand'
  get    '/brand/full_profile' => 'brands#full_profile', as: 'brand_full_profile'
  patch  '/brand/edit' => 'brands#update'
  patch  '/brand/adminupdate/:id' => 'brands#adminupdate', as: 'brand_admin_update'
  get    '/brand/subscribe' => 'brands#subscription', as: 'brand_subscription'

  # for article brand link
  get    '/brands/list' => 'brands#list', as: 'brand_list'
  # for article product link
  get    '/products/list' => 'products#list', as: 'product_list'

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
  get '/gallerynext' => 'matches#gallery_next', as: 'gallery_next'
  # post '/matches/share/:match_id' => 'matches#match_share', as: 'match_share'
  patch '/matches/share/:match_id' => 'matches#match_share', as: 'match_share'

  # post '/conversations/share' => 'conversations#share', as: 'conversation_share'

  resources :messages, only: [:create, :index]
  get '/smsg/:recipient_id' => 'messages#new_simple_message', as: 'new_simple_message'
  post '/smsg/:recipient_id' => 'messages#send_simple_message'
  resources :password_resets
  # get 'messages/all/:match_id' => 'messages#all_messages', as: 'all_messages'

  get '/inventory_adjustments/new/:type/:product_id' => 'inventory_adjustments#new', as: 'new_inventory_adjustment'
  get '/inventory_adjustments/edit/:id' => 'inventory_adjustments#edit', as: 'edit_inventory_adjustment'
  get '/inventory_adjustments/' => 'inventory_adjustments#index', as: 'inventory_adjustments'
  post '/inventory_adjustments/viewtable/' => 'inventory_adjustments#view_table', as: 'view_inventory_table'
  post '/inventory_adjustments/' => 'inventory_adjustments#create'
  put '/inventory_adjustments/:id' => 'inventory_adjustments#update', as: 'inventory_adjustment'
  patch '/inventory_adjustments/:id' => 'inventory_adjustments#update'
  delete '/inventory_adjustments/:id' => 'inventory_adjustments#destroy', as: 'inventory_adjustment_delete'

end
