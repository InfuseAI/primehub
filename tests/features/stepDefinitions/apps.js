const { defineStep } = require("cucumber");
const { expect } = require("chai");

defineStep("I go to the apps detail page with name {string}", async function(name) {
  let cardXpath = `//div[@class='ant-card-body']//h2[text()='${name}']`;
  let cardActionXpath = `//ul[@class='ant-card-actions']//a[text()=' Manage']`;
  let titleXpath = `//span[@class='ant-breadcrumb-link']//span[text()='App: ${name}']`;
  let ele, ret;
  for (retryCount=0; retryCount < 5; retryCount++) {
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

defineStep("I {string} have {string} installed with name {string}", async function(exist, app, name) {
  var isExist = true;
  try {
    await this.page.waitForXPath(`//h2[text()='${name}']`, {timeout: 2 * 1000});
    await this.page.waitForXPath("//div[(@class='ant-tag ant-tag-green') and (text()='Ready')]", {timeout: 2 * 1000});
    await this.page.waitForXPath(`//div[(@class='ant-tag') and contains(text(), ${app})]`, {timeout: 2 * 1000});
  }
  catch (err) {isExist = false; }
  if (exist.includes("not") === isExist) {
    throw new Error(`Apps ${app} ${name} exist?:  ${isExist}`);
    await this.takeScreenshot(`I-${exist}-have-${app}-installed-with-name-${name}-isExist-${isExist}`);
  }
});

defineStep("I keep MLflow info from detail page in memory", async function() {
  const info = ["App URL", "Service Endpoints"]
  for (itemCount=0; itemCount < info.length; itemCount++) {
    let [ele] = await this.page.$x(`//div[text()='${info[itemCount]}']/following-sibling::div`);
    let text = await (await ele.getProperty('textContent')).jsonValue();
    this.copyArray.push(text);
    console.log(`${info[itemCount]}: ${this.copyArray[itemCount]}`);
  }
});

defineStep("I select option {string} of access scope in apps detail page", async function(name) {
  await this.clickElementByXpath("//div[@id='scope']//div[contains(@class, 'ant-select-selection--single')]");
  await this.page.waitForTimeout(500);
  await this.clickElementByXpath(`//li[text()='${name}']`);
  await this.takeScreenshot(`select-option-${name}`);
});
