const { defineStep } = require("cucumber");
const { expect } = require("chai");

defineStep("I am on the landing page", async function() {
  await this.page.waitForXPath("//title[text()='PrimeHub']");
  const url = this.page.url();
  expect(url).to.contain("/console/landing");
  await this.takeScreenshot("landing-page");
});

defineStep("I click PrimeHub icon", async function() {
  // blocked by ch3826
  return;
  //const xpath = "//a[@href='/']";
  //await this.clickElementByXpath(xpath);
});

defineStep("I logout from banner UI", async function() {
  for (retryCount=0; retryCount < 3; retryCount++) {
    await this.page.mouse.move(0, 0);
    hovers = await this.page.$x("//span[contains(@class, 'ant-avatar ant-avatar-circle')]");
    if (hovers.length > 0) await hovers[0].hover();
    else console.log("Cannot find hover item");

    await this.clickElementByXpath(xpath="//li[text()='Logout']");
    await this.takeScreenshot("logout-from-banner-ui");

    try {
      await this.page.waitForXPath("//title[text()='Log in to primehub']", {timeout: 5 * 1000});
      break;
    }
    catch(e){}
  }
});

defineStep("I click {string} image in landing page", async function(string) {
  const xpath = "//h3[text()='"+ string +"']/..";
  await this.clickElementByXpath(xpath);
});
