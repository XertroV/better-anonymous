# frozen_string_literal: true

# name: BetterAnonymous
# about: Improve anonymous mode with features like manually creating a new anonymous identity and giving newly created anonymous users nonsequential names.
# version: 0.1
# authors: xertrov
# url: https://github.com/xertrov

register_asset 'stylesheets/common/better-anonymous.scss'
register_asset 'stylesheets/desktop/better-anonymous.scss', :desktop
register_asset 'stylesheets/mobile/better-anonymous.scss', :mobile

enabled_site_setting :better_anonymous_enabled

PLUGIN_NAME ||= 'BetterAnonymous'

load File.expand_path('lib/better-anonymous/engine.rb', __dir__)

after_initialize do
  # https://github.com/discourse/discourse/blob/master/lib/plugin/instance.rb

  require_dependency 'discourse_event'

  # DiscourseEvent.on(:user_created) do |user|
  #   if user.anonymous? && SiteSetting.better_anonymous_enabled
  #     # OwnedAnonymousUser.create(user)
  #   end
  # end

end
