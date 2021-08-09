const { defineStep } = require("cucumber");
const { expect } = require("chai");

defineStep("I click {string} in admin dashboard", async function(string) {
  await this.clickElementByXpath(`//li[contains(., '${string}')]`);
});

defineStep("I am on the admin dashboard {string} page", async function(string) {
  await this.page.waitForXPath(`//span[contains(., '${string}')]`);
  await this.takeScreenshot(`admin-dashboard-${string}`);
});

defineStep("I click element with test-id {string}", async function(testId) {
  await this.clickElementBySelector(testIdToSelector(testId));
});

defineStep("I type {string} to element with test-id {string}", async function(string, testId) {
  const selector = `${testIdToSelector(testId)} input`;
  await this.inputText(selector, string);
});

defineStep("I type valid info to test-id on the page", async function(datatable) {
  for (const row of datatable.rows()) {
    const selector = await `${testIdToSelector(row[0])} input`
    await this.inputText(selector, row[1]);
  }
});

defineStep("I search {string} in test-id {string}", async function(name, testId) {
  const selector = testIdToSelector(testId);
  await this.inputText(selector, name);
  await this.page.keyboard.press("Enter");
  await this.page.waitForTimeout(500);
  await this.takeScreenshot(`search-${name}`);
});

defineStep("I search my username in name filter", async function() {
  const selector = testIdToSelector("text-filter-username");
  await this.page.waitForSelector(selector, {visible: true});
  await this.page.focus(selector);
  await this.page.$eval(selector, el => el.setSelectionRange(0, el.value.length));
  await this.page.keyboard.press("Backspace");
  await this.page.type(selector, this.USERNAME);
  await this.page.keyboard.press("Enter");
  await this.page.waitForTimeout(500);
  await this.takeScreenshot(`search-${this.USERNAME}`);
});

defineStep("I click my username", async function() {
  await this.clickElementByXpath(`//td[text()='${this.USERNAME}']/..//input`);
});

defineStep("I click edit-button in row contains text {string}", async function(string) {
  // use xpath to find the <tr> containing 'text', then edit button
  // xpath: //tr[contains(., 'hlb')]//button[@data-testid='edit-button']
  const xpath = `//tr[contains(., '${string}-${this.E2E_SUFFIX}')]//button[@data-testid='edit-button']`;
  await this.clickElementByXpath(xpath);
});

defineStep("I delete a row with text {string}", async function(string) {
  // use xpath to find the <tr> containing 'text', then delete button
  // xpath: //tr[contains(., 'string')]//button[@data-testid='delete-button']
  const xpath = `//tr[contains(., '${string}-${this.E2E_SUFFIX}')]//button[@data-testid='delete-button']`;
  await this.clickElementByXpath(xpath);
  await this.page.waitForTimeout(3*1000);
  // press OK button in popup
  const okButtonXPath = `//button[contains(., 'OK')]`;
  await this.clickElementByXpath(okButtonXPath);
});

defineStep("I check boolean input with test-id {string}", async function(testId) {
  // the boolean checkbox we use is a <button>
  const xpath = `${testIdToXpath(testId)}//button`;
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

defineStep("list-view table {string} contain row with {string}", async function(exist, string) {
  // use xpath to find the <tr> containing 'text'
  const xpath = `//tr[contains(., '${string}-${this.E2E_SUFFIX}')]`;
  var isExist = true;
  try {await this.page.waitForXPath(xpath, {timeout: 10 * 1000});}
  catch (err) {isExist = false;}
  if (exist.includes("not") === isExist) throw new Error(`list view ${string}-${this.E2E_SUFFIX} is exist: ${isExist}`);
  await this.takeScreenshot(`list-view-${string}-${this.E2E_SUFFIX}-isExist-${isExist}`);
});

defineStep("I should see input in test-id {string} with value {string}", async function(testId, string) {
  // xpath: //*[@data-testid='user/username']//input
  const xpath = `${testIdToXpath(testId)}//input`;
  const inputValue = await this.getXPathValue(xpath);
  await this.takeScreenshot(`test-id-${testId.replace('/', '-')}-value-${string}-${this.E2E_SUFFIX}`);
  expect(inputValue).to.equal(`${string}-${this.E2E_SUFFIX}`);
});

defineStep("boolean input with test-id {string} should have value {string}", async function(testId, rawValue) {
  // the boolean checkbox we use is a <button>
  const xpath = `${testIdToXpath(testId)}//button`;
  const value = (rawValue === 'true');
  const rawInputValue = await this.getXPathAttribute(xpath, 'aria-checked');
  const inputValue = (rawInputValue === 'true');
  await this.takeScreenshot(`test-id-${testId.replace('/', '-')}-value-${rawValue}`);
  expect(inputValue).to.equal(value);
});

defineStep("I select option {string} in admin dashboard", async function(name) {
  await this.clickElementByXpath("//div[contains(@class, 'ant-select-selection--single')]");
  await this.page.waitForTimeout(500);
  await this.clickElementByXpath(`//li[text()='${name}']`);
  await this.takeScreenshot(`select-option-${name}`);
});

defineStep("I assign group admin of {string} to {string}", async function(group, user) {
  const groupXpath = `//div[contains(@data-testid, "group/name")]//input[@value='${group}-${this.E2E_SUFFIX}']`;
  const userGroupAdminXpath = (user == "me") ? `//tr//td[text()='${this.USERNAME}']/following-sibling::td//input` : `//tr//td[text()='${user}-${this.E2E_SUFFIX}']/following-sibling::td//input`;
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
