export default function() {
  this.route("better-anonymous", function() {
    this.route("actions", function() {
      this.route("show", { path: "/:id" });
    });
  });
};
