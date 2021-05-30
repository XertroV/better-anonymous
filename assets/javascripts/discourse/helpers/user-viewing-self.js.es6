// borrowed from
// https://github.com/discourse/discourse-subscriptions/blob/252a11ed15bf81330e3ddcd8f52661ff92b77bba/assets/javascripts/discourse/helpers/user-viewing-self.js.es6

import { registerUnbound } from "discourse-common/lib/helpers";
import User from "discourse/models/user";

export default registerUnbound("user-viewing-self", function (model) {
    console.log(model);
    if (User.current()) {
        return (
            User.current().username.toLowerCase() === model.username.toLowerCase()
        );
    }

    return false;
});
