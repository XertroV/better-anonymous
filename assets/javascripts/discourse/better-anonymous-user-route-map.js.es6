export default {
    resource: "user",
    path: "users/:username",
    map() {
        this.route("anons", function () {
            this.route("index");
            this.route("list");
            // this.route("activate");
        });
    }
}