const { defineStep } = require("cucumber");
const { expect } = require("chai");

defineStep("I go to the apps detail page with name {string}", async function(app) {
  let cardXpath = `//div[@class='ant-card-body']//h2[text()='${app}']`;
  let cardActionXpath = `//ul[@class='ant-card-actions']//a[text()=' Manage']`;
  let titleXpath = `//span[@class='ant-breadcrumb-link']//span[text()='App: ${app}']`;
  let ele, ret;
  for (retryCount=0; retryCount < 5; retryCount++) {
    [ele] = await this.page.$x(cardActionXpath, {timeout: 5000});
    if (ele) ele.click();
    await this.checkElementExistByXPath('should exist', titleXpath).then(
      function(result) { ret = result; }
      );
    if (ret) {
      await this.takeScreenshot(`apps-detail-page-${app}`);
        return;
    }
    await this.page.waitForTimeout(2000);
  }
  throw new Error(`failed to go to apps detail page with name ${app}`);
});

defineStep("I have {string} installed", async function(app) {
  await this.page.waitForXPath("//div[(@class='ant-tag ant-tag-green') and (text()='Ready')]");
  await this.page.waitForXPath("//div[(@class='ant-tag') and contains(text(), 'mlflow')]");
});
