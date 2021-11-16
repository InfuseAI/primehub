const { defineStep } = require("@cucumber/cucumber");
const { expect } = require("chai");

defineStep("I click {string} in admin portal", async function(string) {
  await this.clickElementByXpath(`//li[contains(., '${string}')]`);
});

defineStep("I am on the admin portal {string} page", async function(string) {
  await this.page.waitForXPath(`//span[contains(., '${string}')]`);
  await this.takeScreenshot(`admin-portal-${string}`);
});

defineStep("I click element with test-id {string}", async function(testId) {
  await this.page.waitForSelector(testIdToSelector(testId));
  await this.clickElementBySelector(testIdToSelector(testId));
});

defineStep("I press-click element with test-id {string}", async function(testId) {
  await this.page.waitForSelector(testIdToSelector(testId));
  await this.pressClickElementBySelector(testIdToSelector(testId));
});

defineStep("I type {string} to element with test-id {string}", async function(string, testId) {
  const selector = `${testIdToSelector(testId)} input`;
  await this.inputTextWithE2ESuffix(selector, string);
});

defineStep("I type value to element with test-id on the page", async function(datatable) {
  for (const row of datatable.rows()) {
    const selector = await `${testIdToSelector(row[0])}`
    await this.inputTextWithE2ESuffix(selector, row[1]);
    await this.takeScreenshot(`type-element-test-id-${row[1]}-${this.E2E_SUFFIX}`);
  }
});

defineStep("I search {string} in test-id {string}", async function(name, testId) {
  const selector = testIdToSelector(testId);
  await this.inputTextWithE2ESuffix(selector, name);
  await this.page.keyboard.press("Enter");
  await this.page.waitForTimeout(500);
  await this.takeScreenshot(`search-${name}`);
});

defineStep("I search my username in name filter", async function() {
  const selector = testIdToSelector("text-filter");
  await this.page.waitForSelector(selector, {visible: true});
  await this.page.focus(selector);
  await this.page.$eval(selector, el => el.setSelectionRange(0, el.value.length));
  await this.page.keyboard.press("Backspace");
  await this.page.type(selector, this.PH_ADMIN_USERNAME);
  await this.page.keyboard.press("Enter");
  await this.page.waitForTimeout(500);
  await this.takeScreenshot(`search-${this.PH_ADMIN_USERNAME}`);
});

defineStep("I click my username", async function() {
  await this.clickElementByXpath(`//td[contains(., '${this.PH_ADMIN_USERNAME}')]//preceding-sibling::td//input`);
});

defineStep("I click edit-button in row containing text {string}", async function(string) {
  // use xpath to find the <tr> containing 'text', then edit button
  // xpath: //tr[contains(., 'hlb')]//button[@data-testid='edit-button']
  const xpath = `//td[contains(., '${string}-${this.E2E_SUFFIX}')]/following-sibling::td//button[@data-testid='edit-button']`;
  await this.clickElementByXpath(xpath);
});

defineStep("I delete a row with text {string}", async function(string) {
  // use xpath to find the <tr> containing 'text', then delete button
  // xpath: //tr[contains(., 'string')]//td//button[@data-testid='delete-button']
  const xpath = `//tr[contains(., '${string}-${this.E2E_SUFFIX}')]//td//button[@data-testid='delete-button']`;
  await this.clickElementByXpath(xpath);
  await this.page.waitForTimeout(3*1000);
  // press OK button in popup
  const okButtonXPath = `//button[contains(., 'OK') or contains(., 'Yes')]`;
  await this.clickElementByXpath(okButtonXPath);
});

defineStep("I check boolean input with test-id {string}", async function(testId) {
  // the boolean checkbox we use is a <button>
  const xpath = `${testIdToXpath(testId)}`;
  await this.clickElementByXpath(xpath);
});

defineStep("I should see element with test-id {string}", async function(testId) {
  await this.page.waitForSelector(testIdToSelector(testId));
});

defineStep("I should see element with test-id on the page", async function(datatable) {
  for (const row of datatable.rows()) {
    await this.page.waitForSelector(testIdToSelector(row[0]));
  }
});

defineStep("I {string} see list-view table containing row with {string}", async function(exist, string) {
  // use xpath to find the <tr> containing 'text'
  const xpath = `//tr[contains(., '${string}-${this.E2E_SUFFIX}')]`;
  var isExist = true;
  try {
    await this.page.waitForXPath(xpath, {timeout: 10 * 1000});
    await this.takeScreenshot(`list-view-${string}-${this.E2E_SUFFIX}-isExist-${isExist}`);
  }
  catch (err) {isExist = false;}
  if (exist.includes("not") === isExist) throw new Error(`list view ${string}-${this.E2E_SUFFIX} is exist: ${isExist}`);
});

defineStep("I should see input in test-id {string} with value {string}", async function(testId, string) {
  // xpath: //*[@data-testid='username']//input
  const xpath = `${testIdToXpath(testId)}`;
  const inputValue = await this.getXPathValue(xpath);
  await this.takeScreenshot(`test-id-${testId.replace('/', '-')}-value-${string}-${this.E2E_SUFFIX}`);
  expect(inputValue).to.equal(`${string}-${this.E2E_SUFFIX}`);
});

defineStep("I should see value of element with test-id on the page", async function(datatable) {
  for (const row of datatable.rows()) {
    // xpath: //*[@data-testid='username']//input
    const xpath = `${testIdToXpath(row[0])}`;
    const inputValue = await this.getXPathValue(xpath);
    await this.takeScreenshot(`test-id-${row[0].replace('/', '-')}-value-${row[1]}-${this.E2E_SUFFIX}`);
    expect(inputValue).to.equal(`${row[1]}-${this.E2E_SUFFIX}`);
  }
});

defineStep("I should see boolean input with test-id {string} having value {string}", async function(testId, rawValue) {
  // the boolean checkbox we use is a <button>
  const xpath = `${testIdToXpath(testId)}`;
  const value = (rawValue === 'true');
  const rawInputValue = await this.getXPathAttribute(xpath, 'aria-checked');
  const inputValue = (rawInputValue === 'true');
  await this.takeScreenshot(`test-id-${testId.replace('/', '-')}-value-${rawValue}`);
  expect(inputValue).to.equal(value);
});

defineStep("I select option {string} in admin portal", async function(name) {
  const xpath = `//li[text()='${name}']`;
  try {
    for (retryCount=0; retryCount < 3; retryCount++) {	  
      await this.clickElementByXpath("//div[contains(@class, 'ant-select-selection--single')]");
      hovers = await this.page.$x("//div[contains(@class, 'ant-select-selection--single')]");
      if (hovers.length > 0) {
	await this.page.waitForTimeout(500);
        await this.clickElementByXpath(xpath);
      }
    }
    await this.takeScreenshot(`Select-option-for-${name}-admin-portal`);
  }
  catch(e) {
    throw new Error(`Select option ${name} failed`);
  }
});

defineStep("I assign group admin of {string} to {string}", async function(group, user) {
  const groupXpath = `//input[contains(@data-testid, "group/name") and @value='${group}-${this.E2E_SUFFIX}']`;
  const userGroupAdminXpath = (user == "me") ? `//input[@value='${this.PH_ADMIN_USERNAME}']` : `//input[@value='${user}-${this.E2E_SUFFIX}']`;
  try {
    await this.page.waitForXPath(groupXpath, {timeout: 1000});
    await this.page.waitForXPath(userGroupAdminXpath, {timeout: 1000});
    await this.clickElementByXpath(userGroupAdminXpath);
    await this.takeScreenshot(`I-assign-group-admin-of-${group}-to-${user}`);
  }
  catch (e) {
    throw new Error(`assign group admin of ${group}-${this.E2E_SUFFIX} to ${user} failed`);
  }
});

function testIdToSelector(testId) {
  return `[data-testid="${testId}"]`;
}

function testIdToXpath(testId) {
  return `//*[@data-testid='${testId}']`;
}
