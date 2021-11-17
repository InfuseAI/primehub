const { defineStep } = require("@cucumber/cucumber");
const { expect } = require("chai");

defineStep("I provide app info in Settings page from memory", async function() {
  const info = ["App URL", "Service Endpoints"]
  const xpath = ["//input[@id='uiUrl']", "//input[@id='trackingUri']"]
  for (itemCount=0; itemCount < info.length; itemCount++) {
    const [element] = await this.page.$x(xpath[itemCount]);
    await element.focus();
    await this.selectAllByHotKeys();
    (info[itemCount] == "Service Endpoints") ? await element.type("http://" + this.appInfo[itemCount]) : await element.type(this.appInfo[itemCount])
  }
});
