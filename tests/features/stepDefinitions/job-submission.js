const { defineStep } = require("cucumber");
const { expect } = require("chai");

defineStep("I am on the job submission page", async function() {
    await this.page.waitForXPath("//h2[text()='Jobs']");
    const url = this.page.url();
    expect(url).to.contain("/console/job");
    await this.takeScreenshot("job-submission-page");
});

defineStep("I am on the create job page", async function() {
    await this.page.waitForXPath("//h2[text()='Create Job']");
    const url = this.page.url();
    expect(url).to.contain("/console/job/create");
    await this.takeScreenshot("create-job-page");
});

defineStep("I choose group with name {string} in create job page", async function(name) {
    await this.clickElementBySelector("#groupId");
    await this.clickElementByXpath(`//li[text()='${name}-${this.E2E_SUFFIX}']`);
    await this.takeScreenshot(`choose-group-${name}-${this.E2E_SUFFIX}`);
});

defineStep("I wait for job completed", {timeout: 310 * 1000}, async function() {
    var text = '';
    for (retryCount=0; retryCount < 10; retryCount++) {
        try {
            const [element] = await this.page.$x("//tbody[@class='ant-table-tbody']/tr[1]/td[1]");
            text = await (await element.getProperty('textContent')).jsonValue();
        }
        catch (e) {}
        console.log(`Job status: ${text}`);
        if (text != "Succeeded") {
            await this.takeScreenshot("wait-for-job-completed");
            await this.page.reload();
            await this.page.waitFor(6 * 1000);
        }
        else {
            return;
        }
    }
    throw new Error("The job is not completed");
});
