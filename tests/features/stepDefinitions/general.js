const { defineStep, After, Before } = require("@cucumber/cucumber");
const { expect } = require("chai");
const fs = require("fs");
const rimraf = require("rimraf");

Before(async function(scenario) {
  console.log(`\nScenario: ${scenario.pickle.name}`);
  this.scenarioName = scenario.pickle.name.replace(/\/| |:|"|'|\.|_/g, '-');
  const dir = `e2e/screenshots/${this.scenarioName}`;
  await fs.access(dir, fs.constants.R_OK | fs.constants.W_OK, (err) => {
    if (err)
      fs.mkdirSync(dir);
  });
  return await this.start();
});

After(async function(scenario) {
  if (scenario.result.status.toLowerCase() === 'failed') {
    await this.exportPageContent(this.scenarioName);
    await this.takeScreenshot(`After-${this.scenarioName}`);
  }
  else
    await rimraf.sync(`e2e/screenshots/${this.scenarioName}`);
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
  await this.page.waitForTimeout(500);
  await this.clickElementByXpath(`//li[text()='${name}-${this.E2E_SUFFIX}']`);
  await this.takeScreenshot(`choose-group-${name}-${this.E2E_SUFFIX}`);
});

defineStep("I switch group", async function() {
  await this.clickElementBySelector(".ant-select-selection__rendered");
  await this.page.keyboard.press('ArrowDown');
  await this.page.keyboard.press('ArrowDown');
  await this.page.keyboard.press('Enter');
  await this.page.waitForTimeout(500);
  await this.takeScreenshot("switch-group");
});

defineStep("I choose {string} in top-right menu", async function(menuitem) {
  const xpath = `//li[text()='${menuitem}']`;
  let ret;
  for (retryCount=0; retryCount < 3; retryCount++) {
    await this.page.mouse.move(0, 0);
    hovers = await this.page.$x("//span[contains(@class, 'ant-avatar ant-avatar-circle')]");
    if (hovers.length > 0) {
      await hovers[0].hover();
      await this.page.waitForTimeout(500);
    }
    else console.log("Cannot find top-right icon");
    await Promise.all([
      this.clickElementByXpath(xpath),
      this.page.waitForNavigation(),
    ]);
    await this.page.waitForTimeout(500);
    await this.checkElementExistByXPath('should exist', xpath).then(
      function(result) { ret = !result; }
    );
    if (ret) {
      await this.takeScreenshot(`choose-${menuitem}-top-right-menu`);
      return;
    }
    await this.page.waitForTimeout(1000);
  }
});

defineStep("I choose {string} in sidebar menu", async function(menuitem) {
  await this.clickElementByXpath(
    `//div[@class='ant-layout-sider-children']//span[text()='${menuitem}']`);
});

defineStep("I am on the PrimeHub console {string} page", async function(menuitem) {
  const prefix = "//span[@class='ant-breadcrumb-link']";
  const xpathMap = {
    'Home': "//title[text()='PrimeHub']", // temporarily used
    'Notebooks': `${prefix}//span[text()='Notebooks']`,
    'Jobs': `${prefix}//a[text()='Jobs']`,
    'NewJob': `${prefix}//span[text()='New Job']`,
    'UpdateJob': `${prefix}//span[contains(text(), 'Recurring Job:')]`,
    'RecurringJob': `${prefix}//a[text()='Jobs']`,
    'Models': `${prefix}//a[text()='Models']`,
    'Deployments': `${prefix}//a[text()='Deployments']`,
    'CreateDeployment': `${prefix}//span[text()='Create Deployment']`,
    'SharedFiles': `${prefix}//a[text()='Shared Files']`,
    'Apps': `${prefix}//a[text()='Apps']`,
    'Store': `${prefix}//span[text()='Store']`,
    'NewApps': `${prefix}//span[text()='Add App to PrimeHub']`,
    'Images': `${prefix}//a[text()='Images']`,
    'NewImage': `${prefix}//span[text()='New Images']`,
    'Settings': `${prefix}//a[text()='Settings']`,
    'API Token': `${prefix}//span[text()='API Token']`
  };
  const urlMap = {
    'Home': '/home', // temporarily used
    'Notebooks': '/hub', // temporarily used
    'Jobs': `-${this.E2E_SUFFIX}/job`,
    'NewJob': `-${this.E2E_SUFFIX}/job/create`,
    'UpdateJob': `-${this.E2E_SUFFIX}/recurringJob/schedule-`,
    'RecurringJob': `-${this.E2E_SUFFIX}/recurringJob`,
    'Models': `-${this.E2E_SUFFIX}/models`,
    'Deployments': `-${this.E2E_SUFFIX}/deployments`,
    'CreateDeployment': `-${this.E2E_SUFFIX}/deployments/create`,
    'SharedFiles': `-${this.E2E_SUFFIX}/browse`,
    'Apps': `-${this.E2E_SUFFIX}/apps`,
    'Store': `-${this.E2E_SUFFIX}/apps/store`,
    'NewApps': `-${this.E2E_SUFFIX}/apps/create`,
    'Images': `-${this.E2E_SUFFIX}/images`,
    'NewImage': `-${this.E2E_SUFFIX}/images/create`,
    'Settings': `-${this.E2E_SUFFIX}/settings`,
    'API Token': `-${this.E2E_SUFFIX}/api-token`
  };

  await this.page.waitForXPath(xpathMap[menuitem]);

  for (retryCount=0; retryCount < 15; retryCount++) {
    if (this.page.url().includes(urlMap[menuitem])) {
      await this.takeScreenshot(`${menuitem}-page`);
      return;
    }
    await this.page.waitForTimeout(2000);
  }
  throw new Error(`failed to go to ${menuitem} page`);
});

defineStep("I switch to {string} tab", async function(tabname) {
  const urlMap = {
    'Home': `-${this.E2E_SUFFIX}/home`,
    'Apps': `-${this.E2E_SUFFIX}/apps`,
    'JobDetail': `-${this.E2E_SUFFIX}/job/`,
    'JupyterLab': `/user/${this.PH_USER_USERNAME}/lab`,
    'Notebooks': `-${this.E2E_SUFFIX}/hub`,
    'NotebooksAdmin': 'console/admin/jupyterhub',
    'UserGuide': 'https://docs.primehub.io'
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
    await this.page.waitForTimeout(2000);
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
  await this.page.waitForXPath(`//title[text()='Log in to ${this.KC_REALM}'] | //title[text()='登入到 ${this.KC_REALM}']`);
  const url = this.page.url();
  expect(url).to.contain(this.KC_SERVER_URL);
});

defineStep(/^I am logged in(?: as (.*))?$/, async function(role) {
  let username, password, ret;
  if (role == null || role.includes('user')) {
    username = this.PH_USER_USERNAME;
    password = this.PH_USER_PASSWORD;
  } else if (role.includes('admin')) {
    username = this.PH_ADMIN_USERNAME;
    password = this.PH_ADMIN_PASSWORD;
  }

  for (retryCount=0; retryCount < 3; retryCount++) {
    try {
      await Promise.all([
        this.page.goto(this.HOME_URL),
        this.page.waitForNavigation(),
      ]);
    } catch (e) {}
    await this.checkElementExistByXPath('should exist', `//title[text()='Log in to ${this.KC_REALM}']`).then(
      function(result) { ret = result; }
    );
    if (ret) { break; }
  }

  const url = this.page.url();
  expect(url).to.contain(this.KC_SERVER_URL);
  await this.input("username", username);
  await this.input("password", password);
  const xpath = "//input[@id='kc-login']";
  await this.clickElementByXpath(xpath);
  await this.takeScreenshot(`I-am-logged-in`);
});

defineStep("I click element with xpath {string}", async function(string) {
  await this.clickElementByXpath(string);
  await this.takeScreenshot("I-click-element-with-xpath");
});

defineStep("I click element with xpath on the page", async function(datatable) {
  for (const row of datatable.rows()) {
    await this.clickElementByXpath(row);
  }
  await this.takeScreenshot("I-click-element-with-xpath-on-the-page");
});

defineStep("I click element with xpath {string} and wait for navigation", async function(xpath) {
  let ret;
  for (retryCount=0; retryCount < 5; retryCount++) {
    try { await this.clickElementByXpath(xpath); } catch (e) {}
    await this.checkElementExistByXPath('should exist', xpath).then(
      function(result) { ret = !result; }
    );
    if (ret) {
      await this.takeScreenshot("click-and-wait-for-navigation");
      return;
    }
    await this.page.waitForTimeout(2000);
  }
  throw new Error(`failed to click ${xpath}`);
});

defineStep("I click element with xpath {string} and wait for xpath {string} appearing", async function(xpath, waitXpath) {
  let ret;
  for (retryCount=0; retryCount < 5; retryCount++) {
    try { await this.clickElementByXpath(xpath); } catch (e) {}
    await this.checkElementExistByXPath('should exist', waitXpath).then(
      function(result) { ret = result; }
    );
    if (ret) {
      await this.takeScreenshot("click-and-wait-for-appearing");
      return;
    }
    await this.page.waitForTimeout(2000);
  }
  throw new Error(`failed to click ${xpath} and wait for ${waitXpath} appearing`);
});

defineStep("I fill in the wrong credentials and click login", async function(datatable) {
  for (const row of datatable.rows()) {
    await this.input("username", row[0]);
    await this.input("password", row[1]);
    const xpath = "//input[@id='kc-login']";
    await this.page.waitForTimeout(1000);
    await this.clickElementByXpath(xpath);
  }
});

defineStep("I fill in the correct admin username credentials", async function() {
  await this.input("username", this.PH_ADMIN_USERNAME);
  await this.input("password", this.PH_ADMIN_PASSWORD);
});

defineStep("I fill in the username {string} and password {string}", async function(username, password) {
  await this.input("username", `${username}-${this.E2E_SUFFIX}`);
  await this.input("password", password);
});

defineStep("I click login", async function() {
  const xpath = "//input[@id='kc-login']";
  await this.clickElementByXpath(xpath);
});

defineStep("I click {string} button", async function(string) {
  await this.clickByText(string);
});

defineStep("I click button to install {string}", async function(apps) {
  const xpath = `//a[contains(@href, '/apps/create/${apps}')]`;
  await this.clickElementByXpath(xpath);
});

defineStep("I click refresh", async function() {
  await this.page.reload();
});

defineStep("I click escape", async function() {
  await this.page.keyboard.press('Escape');
  await this.page.waitForTimeout(1000);
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

defineStep("I should see element with xpath on the page", async function(datatable) {
  for (const row of datatable.rows()) {
    try {
      await this.page.waitForXPath(row[1], {timeout: 5 * 1000});
      if (row[0].includes('not')) throw new Error('element should not exist');
    }
    catch (e) {
      if (!row[0].includes('not')) throw new Error('element should be exist');
    }
  }
});

defineStep("I {string} see element with xpath {string} after page reloaded", async function(exist, xpath) {
  let ret;
  console.time(`${exist} see element with xpath ${xpath} after page reloaded`);
  for (retryCount=0; retryCount < 15; retryCount++) {
    await this.checkElementExistByXPath('should exist', xpath).then(
      function(result) { ret = result; }
    );
    if (exist.includes('not') === ret) {
      await this.takeScreenshot("before-reload");
      await this.page.waitForTimeout(3000);
      await this.page.reload();
    }
    else {
      console.timeEnd(`${exist} see element with xpath ${xpath} after page reloaded`);
      return;
    }
  }
  console.timeEnd(`${exist} see element with xpath ${xpath} after page reloaded`);
  throw new Error(`failed to see ${xpath} after page reloaded`);
});

defineStep("I wait for {float} second(s)", async function(float) {
  await this.page.waitForTimeout(float * 1000);
});

defineStep("I choose radio button with name {string}", async function(name) {
  await this.clickElementByXpath(`//input[@value='${name}-${this.E2E_SUFFIX}']`);
  await this.takeScreenshot(`choose-radio-button-${name}-${this.E2E_SUFFIX}`);
});

defineStep("I type {string} to element with xpath {string}", async function(string, xpath) {
  const [element] = await this.page.$x(xpath);
  await element.focus();
  await this.selectAllByHotKeys();
  await element.type(string);
});

defineStep("I type value to element with xpath on the page", async function(datatable) {
  for (const row of datatable.rows()) {
    const [element] = await this.page.$x(row[0]);
    await element.focus();
    await this.selectAllByHotKeys();
    await element.type(row[1]);
    await this.takeScreenshot(`type-value-to-element`);
  }
});

/* i18n */
defineStep("I change language to {string}", async function(lang) {
  await this.page.hover("#kc-current-locale-link");
  return await this.clickByText(lang, "div[@class='kc-dropdown']/ul//");
});

/*
*  Action on elements, such as click, switch, input
*/

defineStep("I click tab of {string}", async function(title) {
  //div[@role='tab'][contains(.,'Reset Password')]
  const xpath = `//div[@role='tab'][contains(.,'${title}')]`;
  await this.clickElementByXpath(xpath);
  await this.page.waitForTimeout(1000);
  await this.takeScreenshot(`${title}-tab`);
});

defineStep("I click button of {string}", async function(title) {
  const xpath = `//button[contains(., '${title}')]`;
  await this.clickElementByXpath(xpath);
});

defineStep("I click button of {string} of item {string} to wait for {string} dialogue", async function(action, string, dialog) {
  let buttonXpath;
  if (action.toLowerCase().includes('Rerun'.toLowerCase()) || action.toLowerCase().includes('Re-run'.toLowerCase())) {
    buttonXpath = `//tr//a[contains(.,'${string}')]/../following-sibling::td//button//i[@aria-label='icon: caret-right']`;
  } else if (action.toLowerCase().includes('Cancel'.toLowerCase())) {
    buttonXpath = `//tr//a[contains(.,'${string}')]/../following-sibling::td//button//i[@aria-label='icon: close-circle']`;
  }
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
    await this.page.waitForTimeout(2000);
  }
  throw new Error(`failed to wait for ${dialog} dialogue`);
});

defineStep("I click button of {string} on confirmation dialogue", async function(action) {
  //div[@class='ant-modal-confirm-body-wrapper']//button[contains(.,'Yes')]
  await this.page.waitForTimeout(1000);
  const xpath = `//div[@class='ant-modal-confirm-body-wrapper']//button[contains(.,'${action}')]`;
  await this.clickElementByXpath(xpath);
});

defineStep("I click button of {string} on deletion confirmation dialogue", async function(action) {
  //div[@class='ant-modal-content']//button[contains(.,'Delete')]
  await this.page.waitForTimeout(1000);
  const xpath = `//div[@class='ant-modal-content']//button[contains(.,'${action}')]`;
  await this.clickElementByXpath(xpath);
});

defineStep("I type {string} to {string} text field", async function(text, id) {
  const selector = `#${id}`;
  await this.page.waitForSelector(selector, {visible: true});
  await this.page.focus(selector);
  await this.page.$eval(selector, el => el.setSelectionRange(0, el.value.length));
  await this.page.keyboard.press("Backspace");
  await this.page.type(selector, text);
  await this.takeScreenshot(`type-${text}-to-${id}`.replace(/\//g, '-'));
});

defineStep("I should see confirmation dialogue of {string}", async function(string) {
  //div[@class='ant-modal-confirm-body-wrapper']//span[contains(.,'Rerun')]
  await this.page.waitForTimeout(500);
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
    xpath = `//div[@class="ant-tabs-tabpane ant-tabs-tabpane-active"]//${element}[contains(., "${content[index]}")]`;
    try {
      await this.page.waitForXPath(xpath, {timeout: 5 * 1000});
      console.log(`Found '${content[index]}'`);
      await this.takeScreenshot(`element-${element}-under-active-tab`);
      return;
    }
    catch (e) {}
  }
  throw new Error(`Failed to find '${text}'`);
});

defineStep("I should see user limits with CPU, Memory, GPU is {string}", async function(userLimit) {
  const input = userLimit.split(',');
  const table = await this.page.$x("//h3[text()='User Limits']/following-sibling::table//td");
  let text;
  for (i = 0; i < input.length; i++) {
    text = await (await table[i].getProperty('textContent')).jsonValue();
    if (text !== input[i]) throw new Error('User limits are incorrect, pls check screenshot');
  }
});

defineStep("I should see group resource data with CPU {string}, Memory {string}, GPU {string}", async function(cpu, mem, gpu) {
  const input = {
    'CPU': cpu.split(','),
    'Memory': mem.split(','),
    'GPU': gpu.split(',')
  };
  let row, text;
  for (retry = 0; retry < 5; retry++) {
    for (i = 0; i < Object.keys(input).length; i++) {
      try {
        row = await this.page.$x(
          `//h3[text()='Group Resource']/following-sibling::table//td[text()='${Object.keys(input)[i]}']/following-sibling::td`);
        // used column
        text = await (await row[0].getProperty('textContent')).jsonValue();
        if (text.trim() !== Object.values(input)[i][0]) break;
        // limit column
        text = await (await row[1].getProperty('textContent')).jsonValue();
        if (text.trim() !== Object.values(input)[i][1]) break;
        if (i+1 === Object.keys(input).length) return;
      }
      catch (e) {}
    }
    console.log('The group resource table is not showing well, try to reload the page...');
    await this.page.waitForTimeout(5000);
    await this.page.reload();
    await this.page.waitForTimeout(2000);
  }
  throw new Error('Group resources are incorrect, pls check screenshot');
});

defineStep(/^I (?:keep|should see) group resource data(?: with diff of CPU, memory & GPU: (.*), (.*), (.*))?$/, async function(cpuDiff, memDiff, gpuDiff) {
  const data = ['CPU', 'Memory', 'GPU']
  let lastUsed = [], lastQuota = [], diff = [];
  let row, text;
  await this.page.waitForTimeout(1000);
  await this.page.reload();
  if (cpuDiff && memDiff && gpuDiff)
  {
    diff = [cpuDiff, memDiff, gpuDiff]
    lastUsed = this.used;
    lastQuota = this.quota;
  }
  this.used = [], this.quota = [];
  for (retry = 0; retry < 3; retry++) {
    for (i = 0; i < data.length; i++) {
      try {
        row = await this.page.$x(
          `//h3[text()='Group Resource']/following-sibling::table//td[text()='${data[i]}']/following-sibling::td`);
        // used column
        text = await (await row[0].getProperty('textContent')).jsonValue();
        this.used.push(text);
        // limit column
        text = await (await row[1].getProperty('textContent')).jsonValue();
        this.quota.push(text);
      }
      catch (e) {}
    }
    if (this.used.length === data.length && this.quota.length === data.length) break;
    console.log('The group resource table is not showing well, try to reload the page...');
    this.used = [], this.quota = [];
    await this.page.waitForTimeout(3000);
    await this.page.reload();
    await this.page.waitForTimeout(2000);
  }
  console.log('    last used: ' + lastUsed);
  console.log('   last quota: ' + lastQuota);
  console.log(' current used: ' + this.used);
  console.log('current quota: ' + this.quota);
  console.log('         diff: ' + diff);
  if (cpuDiff && memDiff && gpuDiff) {
    for (i = 0; i < data.length; i++) {
      if (parseFloat(lastUsed[i]) + parseFloat(diff[i]) !== parseFloat(this.used[i])) {
        await this.takeScreenshot(`Group-resources-not-corret`);
        throw new Error('Group resources usage not correct, pls check screenshot');
      }
    }
  }
});

defineStep("I should see the property {string} of element with xpath {string} is matched the regular expression {string}", async function(property, xpath, exp) {
  let text;
  const re = new RegExp(exp);
  const ele = await this.page.$x(xpath);
  if (ele.length > 0) {
    for (i = 0; i < ele.length; i++) {
      text = await (await ele[i].getProperty(property)).jsonValue();
      if(text.match(re)) return;
    }
  }
  else {
    throw new Error(`Failed to get element "${xpath}"`);
  }
  throw new Error(`Failed to find text that matched the regular expression "${exp}"`);
});

defineStep(/^I should see (?:(.*)) in (?:(.*)) in API Token?$/, async function(item, tag) {
  let inputXpath, textareaXpath, text, ele, ret;
  if (item.includes('API Token')) {
    try {
      inputXpath = `//input[@class='ant-input']`;
      [ele] = await this.page.$x(inputXpath);
      text = await (await ele.getProperty('value')).jsonValue();
    } catch (e) {
      if (!text) {
        await this.takeScreenshot(`I-should-see-${item}-in-${tag}`);
        throw new Error('API Token not found');
      }
    }
    if (tag.includes('textarea')) {
      textareaXpath = `//textarea[contains(., ${text})]`;
      await this.checkElementExistByXPath('should exist', textareaXpath).then(
        function(result) { ret = !result; } );
      if (ret) {
        await this.takeScreenshot(`I-should-see-${item}-in-${tag}`);
	throw new Error(`API Token is missing or not matching in Example`);
      }
    }
  }

  if ((item.includes('URL')) && (tag.includes('textarea'))) {
      let url = this.API_URL;
      textareaXpath = `//textarea[contains(., '${this.API_URL}')]`;
      await this.checkElementExistByXPath('should exist', textareaXpath).then(
        function(result) { ret = !result; } );
      if (ret) {
        await this.takeScreenshot(`I-should-see-${item}-in-${tag}`);
	throw new Error(`URL is missing from Example`);
      }
    }
});

// Helper functions
function testIdToSelector(testId) {
  return `[data-testid="${testId}"]`;
}

function testIdToXpath(testId) {
  return `//*[@data-testid='${testId}']`;
}
