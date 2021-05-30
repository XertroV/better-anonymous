
import Button from "discourse/components/d-button";
import { ajax } from "discourse/lib/ajax";

export default Button.extend({
    selected: false,

    init() {
        this._super(...arguments);
        this.classNameBindings = this.classNameBindings.concat("selected:btn-primary");
    },

    actions: {
        activateAnonClick(user_id) {
            this.set("loading", true);
            return ajax("/better-anonymous/set_active", { method: "post", data: { shadow_user_id: user_id } }).then(result => {
                this.set("loading", false);
                window.location.reload();
            });
        }
    }
})
