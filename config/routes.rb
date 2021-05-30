require_dependency "better_anonymous_constraint"

BetterAnonymous::Engine.routes.draw do
  # get "/" => "better_anonymous#index", constraints: BetterAnonymousConstraint.new
  get "/list" => "actions#list_shadow_users", constraints: BetterAnonymousConstraint.new
  get "/new" => "actions#create_new_shadow_user", constraints: BetterAnonymousConstraint.new
  post "/set_active" => "actions#set_active_shadow_user", constraints: BetterAnonymousConstraint.new

  # get "/actions" => "actions#index", constraints: BetterAnonymousConstraint.new
  # get "/actions/:id" => "actions#show", constraints: BetterAnonymousConstraint.new
end
