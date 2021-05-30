import EmberObject from "@ember/object";
// import discourseComputed from "discourse-common/utils/decorators";
import { ajax } from "discourse/lib/ajax";
// import I18n from "I18n";

const AnonUser = EmberObject.extend({
  userId: 0
});

AnonUser.reopenClass({
  findAll() {
    return ajax("/better-anonymous/list", { method: "get" }).then(result =>
      result.map(au => AnonUser.create(au)));
  }
})

export default AnonUser;