const { defineStep } = require("@cucumber/cucumber");
const { expect } = require("chai");

defineStep("I am on the user guide page", async function() {
  await this.page.waitForXPath("//h2[text()='PrimeHub']");
  await this.takeScreenshot("user-guide-page");
  const url = this.page.url();
  expect(url).to.contain(`https://docs.primehub.io/`);
});
