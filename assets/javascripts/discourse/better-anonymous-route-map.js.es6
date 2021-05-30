export default function() {
  this.route("better-anonymous", function() {
    this.route("anonymous-users", function() {
      this.route("show");
    });
  });
};
