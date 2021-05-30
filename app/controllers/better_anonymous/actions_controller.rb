module BetterAnonymous
  class ActionsController < ::ApplicationController
    requires_plugin BetterAnonymous

    before_action :ensure_logged_in
    
    def create_new_shadow_user
      user = current_user
      master_user = user.anonymous_user_master || user
      curr_shadow = user.shadow_user

      # we want to temporarily change the curr_shadow user's last_posted_at time so that we can trigger creation of a new anon account.
      modify_curr_shadow = !!curr_shadow
      last_posted_at_cache = nil
      post_count_cache = nil

      if modify_curr_shadow
        last_posted_at_cache = curr_shadow.last_posted_at
        # set's last_posted_at 1 day earlier than required
        curr_shadow.last_posted_at = SiteSetting.anonymous_account_duration_minutes.minutes.ago - 1
        curr_shadow.save!

        stat = curr_shadow.user_stat
        post_count_cache = stat.post_count
        stat.post_count += 1
        stat.save!

        # AnonymousUser.where(user_id: curr_shadow.id).update_all(active:false)
      end

      new_shadow = AnonymousShadowCreator.get(master_user)
      new_shadow.created_at = DateTime.new(2999, 1, 1, 1, 1, 1)
      new_shadow.save!
      # puts("new shadow: #{new_shadow.to_json}")
      # puts("user.shadow_user: #{user.shadow_user.to_json}")

      if modify_curr_shadow
        curr_shadow.last_posted_at = last_posted_at_cache
        curr_shadow.save!
        stat = curr_shadow.user_stat
        stat.post_count = post_count_cache
        stat.save!
      end

      render json: BasicUserSerializer.new(new_shadow).as_json
    end

    def list_shadow_users
      user = current_user
      master_user = user.anonymous_user_master || user
      all_shadow_users = AnonymousUser.where(master_user: master_user).each do |au| au.user end
      render json: all_shadow_users.each do |u| BasicUserSerializer.new(u).as_json end
    end

    def set_active_shadow_user
      requested_active_shadow_user_id = params[:shadow_user_id]
      user = current_user
      master_user = user.master_user || user
      
      puts("set_active_shadow_user Request from user #{user.id} w/ master #{master_user.id} to activate #{requested_active_shadow_user_id} -- master: #{master_user}")
      # make sure this is a valid request first
      return render(json: failed_json, status: 401) unless AnonymousUser.where(user_id: requested_active_shadow_user_id, master_user_id: master_user.id).count == 1

      request_made_from_shadow = user.anonymous?

      # set all anon accounts inactive
      AnonymousUser.where(master_user: master_user).update_all(active: false)
      # activate the one we care about
      AnonymousUser.where(user_id: requested_active_shadow_user_id, master_user_id: master_user.id).update_all(active: true)

      shadow_user = User.find(requested_active_shadow_user_id)
      shadow_user.created_at = DateTime.new(2999, 1, 1, 1, 1, 1)
      shadow_user.last_posted_at = DateTime.new(2999, 1, 1, 1, 1, 1)
      shadow_user.save!
      if request_made_from_shadow
        log_on_user(shadow_user)
      end

      return render json: success_json
    end
  end
end
