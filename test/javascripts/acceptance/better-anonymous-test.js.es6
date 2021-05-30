import { acceptance } from "discourse/tests/helpers/qunit-helpers";

acceptance("BetterAnonymous", { loggedIn: true });

test("BetterAnonymous works", async assert => {
  await visit("/admin/plugins/better-anonymous");

  assert.ok(false, "it shows the BetterAnonymous button");
});
