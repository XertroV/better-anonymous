import Controller from "@ember/controller";
import { ajax } from "discourse/lib/ajax";
import DiscourseURL, { userPath } from "discourse/lib/url";
import User from "discourse/models/user";

export default Controller.extend({
    actions: {
        newAnonClick(user) {
            this.set("loading", true);
            return ajax("/better-anonymous/new", { method: "post" }).then(result => {
                window.location.reload();
            });
        },
        activateAnonClick(anon_to_activate) {
            this.set("loading", true);
            const origUser = User.current();
            return ajax("/better-anonymous/set_active", { method: "post", data: { shadow_user_id: anon_to_activate.id } }).then(result => {
                console.log({
                    orig: origUser,
                    anon_to_activate,
                });
                if (origUser.is_anonymous) {
                    DiscourseURL.redirectTo(userPath(`${anon_to_activate.username}/anons/list`));
                } else {
                    window.location.reload();
                }
            });
        }
    }
});
