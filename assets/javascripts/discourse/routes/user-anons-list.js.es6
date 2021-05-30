import Route from "@ember/routing/route";
import AnonUser from "discourse/plugins/BetterAnonymous/discourse/models/anon-user";
import I18n from "I18n";

export default Route.extend({
    templateName: "user/anons/list",
    model() {
        return AnonUser.findAll();
    },
    actions: {
    }
})