module BetterAnonymous
  class Engine < ::Rails::Engine
    engine_name "BetterAnonymous".freeze
    isolate_namespace BetterAnonymous

    config.after_initialize do
      Discourse::Application.routes.append do
        mount ::BetterAnonymous::Engine, at: "/better-anonymous"
      end
    end
  end
end
