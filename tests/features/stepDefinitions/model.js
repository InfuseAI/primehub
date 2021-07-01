const { defineStep } = require("cucumber");
const { expect } = require("chai");

defineStep("I keep service endpoint", async function() {
    let cardXpath = `//div[@class='ant-card-body']//h2[text()='${name}']`;
    let titleXpath = `//span[@class='ant-breadcrumb-link']//span[text()='Deployment: ${name}']`;
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
        await this.page.waitForTimeout(2000);
    }
    throw new Error(`failed to go to deployment detail page with name ${name}`);
});

