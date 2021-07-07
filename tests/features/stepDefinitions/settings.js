const { defineStep } = require("cucumber");
const { expect } = require("chai");

defineStep( "I provide MLflow info in Settings page from memory", async function() {
  const info = ["App URL", "Service Endpoints"]
  const xpath = ["//input[@id='uiUrl']", "//input[@id='trackingUri']"]
  for (itemCount=0; itemCount < info.length; itemCount++) {
    const [element] = await this.page.$x(xpath[itemCount]);
    await element.focus();
    await this.page.keyboard.down('Control');
    await this.page.keyboard.press('KeyA');
    await this.page.keyboard.up('Control');
    (info[itemCount] == "Service Endpoints") ? await element.type("http://" + this.copyArray[itemCount]) : await element.type(this.copyArray[itemCount])
  }
});
