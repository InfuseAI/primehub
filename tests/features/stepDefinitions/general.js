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

defineStep("I click on PrimeHub icon", async function() {
  if (this.PRIMEHUB_PORT) // workaround for ingress redirect issue
    await this.page.goto(this.HOME_URL);
  else
    await this.clickElementByXpath("//a[@href='/']");
});

defineStep("I choose group with name {string}", async function(name) {
  await this.clickElementBySelector(".ant-select-selection__rendered");
  await this.clickElementByXpath(`//li[text()='${name}-${this.E2E_SUFFIX}']`);
  await this.takeScreenshot(`choose-group-${name}-${this.E2E_SUFFIX}`);
});

defineStep("I choose {string} in top-right menu", async function(menuitem) {
  for (retryCount=0; retryCount < 3; retryCount++) {
    await this.page.mouse.move(0, 0);
    hovers = await this.page.$x("//span[contains(@class, 'ant-avatar ant-avatar-circle')]");
    if (hovers.length > 0) {
      await hovers[0].hover();
      await this.page.waitFor(500);
      break;
    }
    else console.log("Cannot find top-right icon");
  }
  await this.clickElementByXpath(`//li[text()='${menuitem}']`);
  await this.takeScreenshot(`choose-${menuitem}-top-right-menu`);
});

defineStep("I choose {string} in sidebar menu", async function(menuitem) {
  await this.clickElementByXpath(
    `//div[@class='ant-layout-sider-children']//span[text()='${menuitem}']`);
});

defineStep("I am on the PrimeHub console {string} page", async function(menuitem) {
  const xpathMap = {
    'Home': "//title[text()='PrimeHub']", // temporarily used
    'JupyterHub': "//title[text()='PrimeHub']", // temporarily used
    'Jobs': "//h2[text()='Jobs']",
    'Schedule': "//h2[text()='Job Schedule']",
    'Models': "//h2[text()='Model Deployments']"
  };
  const urlMap = {
    'Home': '/home', // temporarily used
    'JupyterHub': '/hub', // temporarily used
    'Jobs': `-${this.E2E_SUFFIX}/job`,
    'Schedule': `-${this.E2E_SUFFIX}/schedule`,
    'Models': `-${this.E2E_SUFFIX}/model-deployment`
  };
  await this.page.waitForXPath(xpathMap[menuitem]);

  for (retryCount=0; retryCount < 5; retryCount++) {
    if (this.page.url().includes(urlMap[menuitem])) {
      await this.takeScreenshot(`${menuitem}-page`);
      return;
    }
    await this.page.waitFor(2000);
  }
  throw new Error(`failed to go to ${menuitem} page`);
});

defineStep("I switch to {string} tab", async function(tabname) {
  const urlMap = {
    'JupyterHub': `-${this.E2E_SUFFIX}/hub`,
    'JupyterLab': `/user/${this.USERNAME}/lab`
  };
  let pages, targetPage;
  if (tabname in urlMap) tabname = urlMap[tabname];

  for (retryCount=0; retryCount < 5; retryCount++) {
    pages = await this.browser.pages();
    targetPage = pages.find(ele => ele.url().includes(tabname));
    if (targetPage) {
      await targetPage.bringToFront();
      this.page = targetPage;
      await this.takeScreenshot("switch-tab");
      return;
    }
    await this.page.waitFor(2000);
  }
  throw new Error(`failed to switch to ${tabname} tab`);
});

defineStep("I go to login page", async function() {
  await this.page.goto(this.HOME_URL);
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

defineStep("I click button of {string} of item {string} to wait for {string} dialogue", async function(action, string, dialog) {
  //tr[contains(.,'gabriel')]//button[contains(*,'Rerun')]
  const buttonXpath = `//tr[contains(.,'${string}')]//button[contains(*,'${action}')]`;
  const dialogXpath = `//div[@class='ant-modal-confirm-body-wrapper']//span[contains(.,'${dialog}')]`;
  let ret;
  for (retryCount=0; retryCount < 3; retryCount++) {
    try { await this.clickElementByXpath(buttonXpath); } catch (e) {}
    await this.checkElementExistByXPath('should exist', dialogXpath).then(
      function(result) { ret = result; }
    );
    if (ret) {
      await this.takeScreenshot(`${dialog}-dialogue`);
      return;
    }
    await this.page.waitFor(2000);
  }
  throw new Error(`failed to wait for ${dialog} dialogue`);
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
  let ret;
  for (retryCount=0; retryCount < 3; retryCount++) {
    try { await this.clickElementByXpath(xpath); } catch (e) {}
    await this.checkElementExistByXPath('should exist', xpath).then(
      function(result) { ret = !result; }
    );
    //await this.takeScreenshot(`retry-${retryCount}`);
    //console.log(ret);
    if (ret) {
      await this.takeScreenshot(`click-${title}-link`);
      return;
    }
    await this.page.waitFor(2000);
  }
  throw new Error(`failed to click ${title} link`);
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

defineStep("I should see confirmation dialogue of {string}", async function(string) {
  //div[@class='ant-modal-confirm-body-wrapper']//span[contains(.,'Rerun')]
  await this.page.waitFor(500);
  await this.takeScreenshot(`confirmation-dialogue-${string}`);
  const xpath = `//div[@class='ant-modal-confirm-body-wrapper']//span[contains(.,'${string}')]`;
  await this.page.waitForXPath(xpath);
});

defineStep("I should see {int}th column of {int}th item is {string} on list", async function(col, row, text) {
  //tbody/tr[1]/td[1][contains(., 'Cancelled')]
  let xpath;
  let content = text.split("|");
  for (index = 0; index < content.length; index++) {
    xpath = `//tbody/tr[${row}]/td[${col}][contains(., '${content[index]}')]`;
    try {
      await this.page.waitForXPath(xpath, {timeout: 5 * 1000});
      console.log(`Found '${content[index]}'`);
      await this.takeScreenshot(`${row}th-item-${col}th-col-with-${content[index]}`); 
      return;
    }
    catch (e) {}
  }
});

defineStep("I should see {string} in element {string} under active tab", async function(text, element) {
  //div[@class="ant-tabs-tabpane ant-tabs-tabpane-active"]//textarea[contains(., 'test')]
  let xpath;
  let content = text.split("|");
  for (index = 0; index < content.length; index++) {
    xpath = `//div[@class="ant-tabs-tabpane ant-tabs-tabpane-active"]//${element}[contains(., '${content[index]}')]`;
    try {
      await this.page.waitForXPath(xpath, {timeout: 5 * 1000});
      console.log(`Found '${content[index]}'`);
      await this.takeScreenshot(`element-${element}-show-${content[index]}`);
      return;
    }
    catch (e) {}
  }
  throw new Error(`Failed to find '${text}'`);
});

// Helper functions
function testIdToSelector(testId) {
  return `[data-testid="${testId}"]`;
}

function testIdToXpath(testId) {
  return `//*[@data-testid='${testId}']`;
}