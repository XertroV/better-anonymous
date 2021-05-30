import Button from "discourse/components/d-button";
import { ajax } from "discourse/lib/ajax";

export default Button.extend({
    selected: false,

    init() {
        this._super(...arguments);
        this.classNameBindings = this.classNameBindings.concat("selected:btn-primary");
    },

    actions: {
        newAnonClick() {
            this.set("loading", true);
            return ajax("/better-anonymous/new", { method: "post" }).then(result => {
                this.set("loading", false);
                window.location.reload();
            });
        }
    }
})
