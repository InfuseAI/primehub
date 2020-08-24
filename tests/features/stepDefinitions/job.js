const { defineStep } = require("cucumber");
const { expect } = require("chai");

defineStep("I am on the create job page", async function() {
    await this.page.waitForXPath("//h2[text()='Create Job']");
    const url = this.page.url();
    expect(url).to.contain(`-${this.E2E_SUFFIX}/job/create`);
    await this.takeScreenshot("create-job-page");
});

defineStep("I wait for job {string} succeeded", {timeout: 310 * 1000}, async function(jobname) {
    await this.page.waitForXPath(`//h2[text()='Job: ${jobname}']`);
    var text = '';
    for (retryCount=0; retryCount < 10; retryCount++) {
        try {
            const [element] = await this.page.$x("//div[text()='Status']/following-sibling::div//strong");
            text = await (await element.getProperty('textContent')).jsonValue();
        }
        catch (e) {}
        console.log(`Job status: ${text}`);
        if (text != "Succeeded") {
            await this.takeScreenshot("wait-for-job-succeeded");
            await this.page.waitFor(6 * 1000);
        }
        else {
            return;
        }
    }
    throw new Error("The job is not succeeded");
});
