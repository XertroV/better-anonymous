import { withPluginApi } from "discourse/lib/plugin-api";

function initializeBetterAnonymous(api) {
  // https://github.com/discourse/discourse/blob/master/app/assets/javascripts/discourse/lib/plugin-api.js.es6
  api.addNavigationBarItem({
    name: "better-anonymous",
    displayName: I18n.t("better_anonymous.navigation.label"),
    href: "/"
  })
}

export default {
  name: "better-anonymous",

  initialize() {
    withPluginApi("0.8.31", initializeBetterAnonymous);
  }
};
