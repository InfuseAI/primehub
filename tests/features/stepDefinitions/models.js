const { defineStep } = require("cucumber");
const { expect } = require("chai");

defineStep("I am on the create deployment page", async function() {
    await this.page.waitForXPath("//h2[text()='Create Deployment']");
    const url = this.page.url();
    expect(url).to.contain(`-${this.E2E_SUFFIX}/model-deployment/create`);
    await this.takeScreenshot("create-deployment-page");
});

defineStep("I go to the deployment detail page with name {string}", async function(name) {
    let cardXpath = `//div[@class='ant-card-body']//h2[text()='${name}']`;
    let titleXpath = `//h2[text()='Deployment: ${name}']`;
    let ele, ret;
    for (retryCount=0; retryCount < 5; retryCount++) {
        [ele] = await this.page.$x(cardXpath, {timeout: 5000});
        if (ele) ele.click();

        await this.checkElementExistByXPath('should exist', titleXpath).then(
            function(result) { ret = result; }
        );
        if (ret) {
            await this.takeScreenshot(`deployment-detail-page-${name}`);
            return;
        }
        await this.page.waitFor(2000);
    }
    throw new Error(`failed to go to deployment detail page with name ${name}`);
});

defineStep("I wait for attribute {string} with value {string}", {timeout: 310 * 1000}, async function(att, value) {
    let ele, text, xpath = `//div[text()='${att}']/following-sibling::div`;
    if (att === 'Status') xpath += '//strong';

    for (retryCount=0; retryCount < 10; retryCount++) {
        try {
            [ele] = await this.page.$x(xpath);
            text = await (await ele.getProperty('textContent')).jsonValue();
        }
        catch (e) {}
        console.log(`${att}: ${text}`);
        if (text != value) {
            await this.takeScreenshot(`wait-for-${att}-${value}`);
            await this.page.waitFor(10 * 1000);
        }
        else {
            return;
        }
    }
    throw new Error(`failed to wait for ${att} with value ${value}`);
});

defineStep("I copy value from {string} attribute", async function(att) {
    let [ele] = await this.page.$x(`//div[text()='${att}']/following-sibling::div`);
    let text = await (await ele.getProperty('textContent')).jsonValue();
    console.log(`${att}: ${text}`);
    this.copyText = text;
});