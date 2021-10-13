const { defineStep } = require("@cucumber/cucumber");
const { expect } = require("chai");

defineStep("I go to the apps detail page with name {string}", async function(name) {
  let cardXpath = `//div[@class='ant-card-body']//h2[text()='${name}']`;
  let cardActionXpath = `//div[@class='ant-card-body']//h2[text()='${name}']/../../../following-sibling::ul[@class='ant-card-actions']//a[contains(., 'Manage')]`; 
  let titleXpath = `//span[@class='ant-breadcrumb-link']//span[text()='App: ${name}']`;
  let ele, ret;
  for (retryCount=0; retryCount < 10; retryCount++) {
    [ele] = await this.page.$x(cardActionXpath, {timeout: 5000});
    if (ele) ele.click();
    await this.checkElementExistByXPath('should exist', titleXpath).then(
      function(result) { ret = result; }
      );
    if (ret) {
      await this.takeScreenshot(`apps-detail-page-${name}`);
        return;
    }
    await this.page.waitForTimeout(2000);
  }
  throw new Error(`failed to go to apps detail page with name ${name}`);
});

defineStep("I {string} the apps with name {string}", async function(action, apps) {
  xpath = `//div[@class='ant-card-body']//h2[text()='${apps}']/../../following-sibling::ul[@class='ant-card-actions']//span[contains(., '${action}')]`
  await this.clickElementByXpath(xpath);
  await this.takeScreenshot(`${action}-the-apps-with-${apps}`);
});

defineStep("I should see the status {string} of the apps {string}", async function(status, apps) {
  xpath = `//h2[text()='${apps}']/following-sibling::div//div[contains(., ${status})]`;
  try {
    await this.page.waitForXPath(xpath, {timeout: 1000});
  }
  catch (err) {
    throw new Error(`should see the status ${status} of the apps ${apps}`);
    await this.takeScreenshot(`should-see-the-status-${status}-of-the-apps-${app}`);
  }
});

defineStep("I {string} have {string} installed with name {string}", async function(exist, app, name) {
  var isExist = true;
  try {
    await this.page.waitForXPath(`//h2[text()='${name}']`, {timeout: 2 * 1000});
    await this.page.waitForXPath(`//span[(@class='ant-tag') and contains(text(), ${app})]`, {timeout: 2 * 1000});
  }
  catch (err) {isExist = false; }
  if (exist.includes("not") === isExist) {
    throw new Error(`Apps ${app} ${name} exist?:  ${isExist}`);
    await this.takeScreenshot(`${exist}-have-${app}-installed-with-name-${name}-isExist-${isExist}`);
  }
});

defineStep("I keep apps info from detail page in memory", async function() {
  this.appInfo = [];
  const info = ["App URL", "Service Endpoints"]
  for (itemCount=0; itemCount < info.length; itemCount++) {
    let [ele] = await this.page.$x(`//div[text()='${info[itemCount]}']/following-sibling::div`);
    let text = await (await ele.getProperty('textContent')).jsonValue();
    this.appInfo.push(text);
    console.log(`${info[itemCount]}: ${this.appInfo[itemCount]}`);
  }
  await this.takeScreenshot(`keep-app-info-from-detail-page`);
});

defineStep("I select option {string} of access scope in apps detail page", async function(name) {
  await this.clickElementByXpath("//div[@id='scope']//div[contains(@class, 'ant-select-selection--single')]");
  await this.page.waitForTimeout(500);
  await this.clickElementByXpath(`//li[text()='${name}']`);
  await this.takeScreenshot(`select-option-${name}-of-access-scope-in-app-detail-page`);
});

defineStep("I {string} access {string} by URL", async function(able, name) {
  let appInfo = this.appInfo;
  const info = ["App URL", "Service Endpoints"]
  const url = appInfo[0];
  const targetPage = await this.browser.newPage();
  await targetPage.goto(url);
  await	targetPage.bringToFront()
  this.page = targetPage
  await this.page.waitForTimeout(2500);
  await this.takeScreenshot(`access-${name}-by-URL`);
});

defineStep("I can see the code server page", async function() {
  await this.page.waitForXPath("//title[contains(., 'code-server')]");
  await this.takeScreenshot("code-server-page");
});
