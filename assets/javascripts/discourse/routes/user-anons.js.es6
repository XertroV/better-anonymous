import Route from "@ember/routing/route";

export default Route.extend({
  templateName: "user/anons",

  setupController(controller, model) {
    if (this.currentUser.id !== this.modelFor("user").id) {
      this.replaceWith("userActivity");
    } else {
      controller.setProperties({ model });
    }
  },
});
