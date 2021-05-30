module BetterAnonymous
  class BetterAnonymousController < ::ApplicationController
    requires_plugin BetterAnonymous

    before_action :ensure_logged_in

    def index
    end


    # # https://github.com/discourse/discourse/blob/dc6b547ed89f652b5406489d76140b76cf8e0d1d/app/controllers/application_controller.rb#L456 
    # def serialize_data(obj, serializer, opts = nil)
    #   # If it's an array, apply the serializer as an each_serializer to the elements
    #   serializer_opts = { scope: guardian }.merge!(opts || {})
    #   if obj.respond_to?(:to_ary)
    #     serializer_opts[:each_serializer] = serializer
    #     ActiveModel::ArraySerializer.new(obj.to_ary, serializer_opts).as_json
    #   else
    #     serializer.new(obj, serializer_opts).as_json
    #   end
    # end

    # def render_serialized(obj, serializer, opts = nil)
    #   render_json_dump(serialize_data(obj, serializer, opts), opts)
    # end



    # def create_new_shadow_user
    #   user = current_user
    #   master_user = user.anonymous_user_master || user

    #   curr_shadow = user.shadow_user
    #   # we want to temporarily change the curr_shadow user's last_posted_at time so that we can trigger creation of a new anon account.
    #   temp_modify_last_posted_ts = !!curr_shadow
    #   last_posted_at_cache = nil

    #   if temp_modify_last_posted_ts
    #     last_posted_at_cache = curr_shadow.last_posted_at
    #     # set's last_posted_at 1 day earlier than required
    #     curr_shadow.last_posted_at = SiteSetting.anonymous_account_duration_minutes.minutes.ago - 1
    #     curr_shadow.save!
    #   end

    #   new_shadow = AnonymousShadowCreator.get(master_user)

    #   if temp_modify_last_posted_ts && !last_posted_at_cache.nil?
    #     curr_shadow.last_posted_at = last_posted_at_cache
    #     curr_shadow.save!
    #   end

    #   render_serialized(new_shadow, BasicUserSerializer)
    # end

    # def list_shadow_users
    #   user = current_user
    #   master_user = user.anonymous_user_master || user
    #   all_shadow_users = AnonymousUser.where(master_user: master_user)
    #   render_serialized(all_shadow_users, BasicUserSerializer)
    # end
  end
end
