const { defineStep, After, Before } = require("cucumber");
const { expect } = require("chai");

Before(async function(scenario) {
  console.log(`\nScenario: ${scenario.pickle.name}`);
  return await this.start();
});

After(async function(scenario) {
  const scenarioName = scenario.pickle.name.replace(/\/| /g, '-');
  if (scenario.result.status === 'failed') {
    console.log("Scenario failed, exporting latest page content...");
    await this.exportPageContent(scenarioName);
  }
  await this.takeScreenshot(`After-${scenarioName}`);
  return await this.stop();
});

defineStep("I go to login page", async function() {
  await this.page.goto(this.ADMIN_LANDING_URL);
  await this.page.waitForXPath(`//title[text()='Log in to ${this.KC_REALM}']`);
  const url = this.page.url();
  expect(url).to.contain(this.KC_SERVER_URL);
  await this.takeScreenshot(`login-page`);
});

defineStep("I am on login page", async function() {
  await this.page.waitForXPath(`//title[text()='Log in to ${this.KC_REALM}']`);
  const url = this.page.url();
  expect(url).to.contain(this.KC_SERVER_URL);
});

defineStep("I click element with xpath {string}", async function(string) {
  await this.clickElementByXpath(string);
});

defineStep("I fill in {string} with {string}", async function(string, string2) {
  return await this.input(string, string2);
});

defineStep("I fill in the wrong credentials", async function() {
  await this.input("username", this.USERNAME);
  return await this.input("password", "wrong password");
});

defineStep("I fill in the correct username credentials", async function() {
  await this.input("username", this.USERNAME);
  return await this.input("password", this.PASSWORD);
});

defineStep("I fill in the correct email credentials", async function() {
  await this.input("username", this.USER_EMAIL);
  return await this.input("password", this.PASSWORD);
});

defineStep("I click login", async function() {
  const xpath = "//input[@id='kc-login']";
  await this.clickElementByXpath(xpath);
});

defineStep("I click {string} button", async function(string) {
  return await this.clickByText(string);
});

defineStep("I click GoBack", async function() {
  return await this.page.goBack();
});

defineStep("I click refresh", async function() {
  await await this.page.reload();
});

defineStep("I {string} see element with xpath {string}", async function(exist, string) {
  try {
    await this.page.waitForXPath(string, {timeout: 5 * 1000});
    if (exist.includes('not')) throw new Error('element should not exist');
  }
  catch (e) {
    if (!exist.includes('not')) throw new Error('element should be exist');
  }
});

defineStep("I wait for {float} seconds", async function(float) {
  await this.page.waitFor(float * 1000);
});

defineStep("I choose radio button with name {string}", async function(name) {
  await this.clickElementByXpath(`//input[@value='${name}-${this.E2E_SUFFIX}']`);
  await this.takeScreenshot(`choose-radio-button-${name}-${this.E2E_SUFFIX}`);
});

defineStep("I type {string} to element with xpath {string}", async function(string, xpath) {
  const [element] = await this.page.$x(xpath);
  await element.focus();
  await this.page.keyboard.down('Control');
  await this.page.keyboard.press('KeyA');
  await this.page.keyboard.up('Control');
  await element.type(string);
});

/* i18n */
defineStep("I change language to {string}", async function(lang) {
  await this.page.hover("#kc-current-locale-link");
  return await this.clickByText(lang, "div[@class='kc-dropdown']/ul//");
});

defineStep("the login heading should be {string}", async function(heading) {
  await this.page.waitForNavigation();
  return await this.checkText("#kc-page-title", heading);
});


/* 
*  Action on elements, such as click, switch, input 
*/

defineStep("I click tab of {string}", async function(title) {
  //div[@role='tab'][contains(.,'Reset Password')]
  const element = "span";
  const xpath = `//div[@role='tab'][contains(.,'${title}')]`;
  await this.clickElementByXpath(xpath);
  await this.page.waitFor(1000);
  await this.takeScreenshot(`${title}-tab`);
});

defineStep("I click button of {string}", async function(title) {
  const xpath = `//button[contains(., '${title}')]`;
  await this.clickElementByXpath(xpath);
});

defineStep("I click button of {string} of item {string}", async function(action, string) {
  //tr[contains(.,'gabriel')]//button[contains(*,'Rerun')]
  const xpath = `//tr[contains(.,'${string}')]//button[contains(*,'${action}')]`;
  await this.clickElementByXpath(xpath);
});

defineStep("I click svg button of {string} of item {string}", async function(action, string) {
  //tr[contains(.,'aaron')]//button[contains(@*,'edit')]
  const xpath = `//tr[contains(.,'${string}')]//button[contains(@*,'${action}')]`;
  let elem = await this.page.$(xpath);
  await this.clickElementByXpath(xpath);
});

defineStep("I click button of {string} on confirmation dialogue", async function(action) {
  //div[@class='ant-modal-confirm-body-wrapper']//button[contains(.,'Yes')]
  const xpath = `//div[@class='ant-modal-confirm-body-wrapper']//button[contains(.,'${action}')]`;
  await this.clickElementByXpath(xpath);
});

defineStep("I click switch of {string}", async function(testId) {
  //div[@data-testid='user/enabled']//button
  const xpath = `//div[@data-testid='${testId}']//button`;
  await this.clickElementByXpath(xpath);
});

defineStep("I click link of {string} of {int}th item on list", async function(title, row) {
  //tr[1]//a[text()='create-job-test']
  const xpath = `//tr[${row}]//a[text()='${title}']`;
  await this.clickElementByXpath(xpath);
  await this.page.waitFor(500);
  await this.takeScreenshot(`${title}-link`);
});

defineStep("I click element {string} of {string}", async function(element, title) {
  const xpath = `//${element}[text()='${title}']/..`;
  await this.clickElementByXpath(xpath);
});

defineStep("I type {string} to {string} text field", async function(text, id) {
  await this.page.type(`#${id}`, text);
  await this.takeScreenshot(`type-${text}-to-${id}`);
});

// Input
defineStep("I fill {string} in input of {string}", async function(string, testId) {
  const selector = `input${testIdToSelector(testId)}`;
  await this.page.focus(selector);
  await this.page.$eval(selector, el => el.setSelectionRange(0, el.value.length));
  await this.page.keyboard.press("Backspace");
  await this.page.type(selector, string);
});


// View
defineStep("I go to InfuseAI login page", async function() {
  await this.page.goto(this.ADMIN_LANDING_URL);
  await this.page.hover("#kc-current-locale-link");
  await this.clickByText("English", "div[@class='kc-dropdown']/ul//");
  await this.page.waitForXPath("//title[text()='Log in to InfuseAI']");
  const url = this.page.url();
  expect(url).to.contain(this.KC_SERVER_URL);
  await this.takeScreenshot(`login-page`);
});

defineStep("I am on InfuseAI login page", async function() {
  await this.page.waitForXPath("//title[text()='Log in to InfuseAI']");
  const url = this.page.url();
  expect(url).to.contain(this.KC_SERVER_URL);
});


defineStep("I should see confirmation dialogue of {string}", async function(string) {
  //div[@class='ant-modal-confirm-body-wrapper']//span[contains(.,'Rerun')]
  await this.page.waitFor(500);
  await this.takeScreenshot(`confirmation-dialogue-${string}`);
  const xpath = `//div[@class='ant-modal-confirm-body-wrapper']//span[contains(.,'${string}')]`;
  await this.page.waitForXPath(xpath);
});


defineStep("I should see {int}th column of {int}th item is {string} on list", async function(col, row, string) {
  //tbody/tr[1]/td[1][contains(., 'Cancelled')]
  await this.takeScreenshot(`${row}th-item-${col}th-col-with-${string}`); 
  const xpath = `//tbody/tr[${row}]/td[${col}][contains(., '${string}')]`;
  await this.page.waitForXPath(xpath);
});


defineStep("I should see {string} in element {string} under active tab", async function(text, element) {
  //div[@class="ant-tabs-tabpane ant-tabs-tabpane-active"]//textarea[contains(., 'test')]
  const xpath = `//div[@class="ant-tabs-tabpane ant-tabs-tabpane-active"]//${element}[contains(., '${text}')]`;
  await this.page.waitForXPath(xpath);
  await this.takeScreenshot(`element-${element}-show-${text}`); 
});


// Helper functions
function testIdToSelector(testId) {
  return `[data-testid="${testId}"]`;
}

function testIdToXpath(testId) {
  return `//*[@data-testid='${testId}']`;
}