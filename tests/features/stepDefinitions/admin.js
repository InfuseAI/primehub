const { defineStep } = require("cucumber");
const { expect } = require("chai");

defineStep("I click {string} in admin dashboard", async function(string) {
  // the xpath, //li[text()='${string}'][1], is for secrets
  const xpath = 
  `(
    //span[text()='${string}'][1]|
    //li[text()='${string}'][1]
  )`;
  await this.clickElementByXpath(xpath);
});

defineStep("I am on the admin dashboard {string} page", async function(string) {
  // the xpath, //h2[text()='${string}'], is for secrets
  const xpath = 
  `(
    //h2/span[text()='${string}']|
    //h2[text()='${string}']
  )`;
  await this.page.waitForXPath(xpath);
  await this.takeScreenshot(`admin-dashboard-${string}`);
});

defineStep("I see {string} in logo alt text", function(string) {
  // Write code here that turns the phrase above into concrete actions
  return "pending";
});

defineStep("I click element with test-id {string}", async function(testId) {
  await this.clickElementBySelector(testIdToSelector(testId));
});

defineStep("I type {string} to element with test-id {string}", async function(string, testId) {
  const selector = `${testIdToSelector(testId)} input`;
  await this.page.focus(selector);
  await this.page.$eval(selector, el => el.setSelectionRange(0, el.value.length));
  await this.page.keyboard.press("Backspace");
  await this.page.type(selector, string);
});

defineStep("I click edit-button in row contains text {string}", async function(string) {
  // use xpath to find the <tr> containing 'text', then edit button
  // xpath: //tr[contains(., 'hlb')]//button[@data-testid='edit-button']
  const xpath = `//tr[contains(., '${string}')]//button[@data-testid='edit-button']`;
  await this.clickElementByXpath(xpath);
});

defineStep("I delete a row with text {string}", async function(string) {
  // use xpath to find the <tr> containing 'text', then delete button
  // xpath: //tr[contains(., 'string')]//button[@data-testid='delete-button']
  const xpath = `//tr[contains(., '${string}')]//button[@data-testid='delete-button']`;
  await this.clickElementByXpath(xpath);
  await this.page.waitFor(3*1000);
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

defineStep("list-view table {string} contain row with {string}", async function(exist, string) {
  // use xpath to find the <tr> containing 'text'
  const xpath = `//tr[contains(., '${string}')]`;
  var isExist = true;
  try {await this.page.waitForXPath(xpath, {timeout: 10 * 1000});}
  catch (err) {isExist = false;}
  if (exist.includes("not") === isExist) throw new Error(`list view ${string} is exist: ${isExist}`);
  await this.takeScreenshot(`list-view-${string}-isExist-${isExist}`);
});

defineStep("I should see input in test-id {string} with value {string}", async function(testId, string) {
  // xpath: //*[@data-testid='user/username']//input
  const xpath = `${testIdToXpath(testId)}//input`;
  const inputValue = await this.getXPathValue(xpath);
  await this.takeScreenshot(`test-id-${testId.replace('/', '-')}-value-${string}`);
  expect(inputValue).to.equal(string);
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
  await this.page.waitFor(500);
  await this.clickElementByXpath(`//li[text()='${name}']`);
  await this.takeScreenshot(`select-option-${name}`);
});

function testIdToSelector(testId) {
  return `[data-testid="${testId}"]`;
}

function testIdToXpath(testId) {
  return `//*[@data-testid='${testId}']`;
}
