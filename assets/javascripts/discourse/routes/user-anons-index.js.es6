import Route from "@ember/routing/route";

export default Route.extend({
    templateName: "user/anons/index",
    redirect() {
        this.transitionTo("user.anons.list");
    }
})