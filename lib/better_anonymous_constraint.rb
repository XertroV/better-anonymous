class BetterAnonymousConstraint
  def matches?(request)
    SiteSetting.better_anonymous_enabled
  end
end
