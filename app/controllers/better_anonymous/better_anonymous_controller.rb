module BetterAnonymous
  class BetterAnonymousController < ::ApplicationController
    requires_plugin BetterAnonymous

    before_action :ensure_logged_in

    def index
    end
  end
end
