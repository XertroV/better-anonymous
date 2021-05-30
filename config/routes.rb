require_dependency "better_anonymous_constraint"

BetterAnonymous::Engine.routes.draw do
  get "/list" => "actions#list_shadow_users", constraints: BetterAnonymousConstraint.new
  get "/new" => "actions#create_new_shadow_user", constraints: BetterAnonymousConstraint.new
  post "/set_active" => "actions#set_active_shadow_user", constraints: BetterAnonymousConstraint.new

  namespace :user do
    # resources :anons, only: [:index, :create, :list, :activate]
    scope 'anons' do
      get "/list" => "actions#list_shadow_users", constraints: BetterAnonymousConstraint.new
      get "/new" => "actions#create_new_shadow_user", constraints: BetterAnonymousConstraint.new
      post "/set_active" => "actions#set_active_shadow_user", constraints: BetterAnonymousConstraint.new
    end
  end
end
