import EmberObject from "@ember/object";
// import discourseComputed from "discourse-common/utils/decorators";
import { ajax } from "discourse/lib/ajax";
// import I18n from "I18n";

const AnonUser = EmberObject.extend({
  id: 0
});

AnonUser.reopenClass({
  findAll() {
    return ajax("/better-anonymous/list", { method: "get" }).then(result => {
      console.log(result);
      return result.actions.map(au => AnonUser.create({ ...au.user, active: au.active })).sort((a, b) => a.username > b.username);
    });
  }
})

export default AnonUser;
