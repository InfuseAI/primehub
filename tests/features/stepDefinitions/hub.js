const { defineStep } = require("cucumber");
const { expect } = require("chai");

defineStep("I am on the spawner page", async function() {
  // click on "Launch Server" if "Server not running"
  for (retryCount=0; retryCount < 3; retryCount++) {
    try {
      await this.page.waitForXPath(
        "//h1[contains(text(), 'Server not running')]", {timeout: 10 * 1000});
      console.log("Detect 'Server not running', try to click on 'Launch Server' button");
      await this.takeScreenshot("server-not-running");
      await this.clickElementByXpath(xpath="//a[@id='start']");
      break;
    }
    catch (e) {}
  }

  await this.page.waitForXPath("//h4[text()='Select your notebook settings']");
  const url = this.page.url();
  expect(url).to.contain("/hub/spawn");
  await this.takeScreenshot("spawner-page");
});

defineStep("I go to the jupyterhub admin page to stop server", async function() {
  this.page = await this.browser.newPage();
  await this.page.goto(this.HUB_ADMIN_URL);
  await this.takeScreenshot("hub-admin-page");
  for (retryCount=0; retryCount < 3; retryCount++) {
    try {
      await this.clickElementByXpath(xpath="//a[contains(text(), 'stop server')]");
      await this.page.waitFor(3 * 1000);
      await this.page.waitForXPath(
        "//a[@class='stop-server btn btn-xs btn-danger']", {timeout: 5 * 1000});
      console.log("Detect server is still running, try to click on 'stop server' button");
      await this.takeScreenshot("server-still-running");
    }
    catch (e) {
      break;
    }
  }
});

defineStep("I am on the jupyterhub admin page", async function() {
  await this.page.waitForXPath("//tr[@id='user-phadmin']");
  const url = this.page.url();
  expect(url).to.contain("/hub/admin");
  await this.takeScreenshot("hub-admin-page");
});

defineStep("I choose group with name {string}", async function(name) {
  await this.page.select("#group-selector select", `${name}-${this.E2E_SUFFIX}`);
  await this.takeScreenshot(`choose-group-${name}-${this.E2E_SUFFIX}`);
});

defineStep("I choose instance type", async function() {
  const selector = "#it-container label:first-child input[type='radio']";
  await this.clickElementBySelector(selector);
});

defineStep("I choose image", async function() {
  const selector = "#image-container label:first-child input[type='radio']";
  await this.clickElementBySelector(selector);
});

defineStep("I choose option with name {string}", async function(name) {
  const xpath = `//input[@value='${name}-${this.E2E_SUFFIX}']`;
  await this.clickElementByXpath(xpath);
});

defineStep("I go to the spawner page", async function() {
  /* wait unitl page fully load */
  await this.page.goto(this.HUB_HOME_URL, {
    waitUntil: "networkidle0"
  });
  const url = this.page.url();
  expect(url).to.contain("/hub/home");
});

defineStep("I can see the user limits are {string}, {string}, and {string}", async function(cpu, mem, gpu) {
  var xpath = "//tr[@id='user-limits-body']";
  var element, text;
  const resources = [cpu, mem, gpu];
  for (index = 0; index < resources.length; index++) {
    [element] = await this.page.$x(xpath+`//td[${index+1}]`);
    text = await (await element.getProperty('textContent')).jsonValue();
    if (resources[index] !== text.trim()) throw new Error(`Resources value mismatch, ecpected: ${resources[index]}, actual: ${text.trim()}`);
  }
});

defineStep("I can see the group resource limits are {string}, {string}, and {string}", async function(cpu, mem, gpu) {
  var text;
  const ids = ['#group-cpu-limit', '#group-mem-limit', '#group-gpu-limit'];
  const resources = [cpu, mem, gpu];
  for (index = 0; index < resources.length; index++) {
    text = await this.page.$eval(ids[index], ele => ele.textContent);
    if (resources[index] !== text) throw new Error(`Resources value mismatch, ecpected: ${resources[index]}, actual: ${text}`);
  }
});

defineStep("I can see the error message {string}", async function(message) {
  const xpath = "//p[@class='spawn-error-msg text-danger']";  
  await this.page.waitForXPath(xpath);

  const [ui_element] = await this.page.$x(xpath);
  var text = await (await ui_element.getProperty('textContent')).jsonValue();
  console.log(`Error message: ${text.trim()}`);
  if (text.trim() !== message) throw new Error("Error message is incorrect");
});

defineStep("I go to the hub control panel", async function() {
  this.page = await this.browser.newPage();
  await this.page.goto(this.HUB_HOME_URL);
  await this.page.waitForXPath("//a[contains(text(), 'Stop My Server')]");
  const url = this.page.url();
  expect(url).to.contain("/hub/home");
  await this.takeScreenshot("hub-control-panel");
});

defineStep("I click Stop My Server", async function() {
  for (retryCount=0; retryCount < 3; retryCount++) {
    await this.clickByText("Stop My Server");
    await this.takeScreenshot("stop-my-server");
    const [ui_element] = await this.page.$x("//a[text()='Start My Server']", {timeout: 5 * 1000});
    if (ui_element) break;
  }
});

defineStep("I logout on JupyterHub page", async function() {
  await this.page.waitForXPath("//a[@id='logout']", {timeout: 5 * 1000});
  const [button] = await this.page.$x("//a[@id='logout']");
  if (button) button.click();
  else throw new Error(`logout button not found`);
  
  await this.takeScreenshot("logout-on-jupyterhub");
});

defineStep("I {string} see instance types block contains {string} instanceType with {string} description and tooltip to show {string}", async function(exist, name, desc, resource) {
  const xpath = `//div[@id='it-container']//strong[contains(text(), '${name}-${this.E2E_SUFFIX}')]`;
  if (!this.checkElementExistByXPath(exist, xpath)) 
    throw new Error(`failed to check '${name}-${this.E2E_SUFFIX}' instanceType is existed`);
  if (!exist.includes('not')) {
    const [element] = await this.page.$x(xpath+'//i');
    await element.hover();
    await this.takeScreenshot("hover-information-tooltip");

    if (!this.checkElementExistByXPath(exist, xpath+`//div[text()='${resource}']`))
      throw new Error(`failed to get '${resource}' information tooltip`);
    if (!this.checkElementExistByXPath(exist, xpath+`//..//p[text()='${desc}-${this.E2E_SUFFIX}']`))
      throw new Error(`failed to get '${desc}-${this.E2E_SUFFIX}' instanceType description`);
  }
});

defineStep("I {string} see images block contains {string} image with {string} type and {string} description", async function(exist, name, type, desc) {
  var postfix;
  switch (type) {
    case "universal":
      postfix = " (CPU, GPU)";
      break;
    case "cpu":
      postfix = " (CPU)";
      break;
    case "gpu":
      postfix = " (GPU)";
      break;
  }
  var xpath = `//div[@id='image-container']//strong[text()='${name}-${this.E2E_SUFFIX}${postfix}']`;
  if (!this.checkElementExistByXPath(exist, xpath))
    throw new Error(`failed to check image '${name}-${this.E2E_SUFFIX}' is existed`);
  if (!exist.includes('not')) {
    xpath += `//..//p[text()='${desc}-${this.E2E_SUFFIX}']`;
    if (!this.checkElementExistByXPath(exist, xpath))
      throw new Error(`failed to get '${desc}-${this.E2E_SUFFIX}' image description`);
  }
});

defineStep("I can see advanced settings", async function() {
  await this.clickElementByXpath("//a[@href='#advanced-setup']");

  const xpath = "//div[@aria-expanded='true']//label[text()='Enable Safe Mode ']";
  if (!this.checkElementExistByXPath('should exist', xpath))
    throw new Error("failed to get 'Enable Safe Mode' checkbox");

  const [element] = await this.page.$x(xpath+'//i');
  await element.hover();
  await this.takeScreenshot("hover-information-tooltip");
  if (!this.checkElementExistByXPath(
    'should exist',
    xpath+"//div[text()='Safe Mode mounts your persistent home directory under /home/jovyan/user.']"))
    throw new Error("failed to get information tooltip");
});

defineStep("I can see the spawning page", async function() {
  await this.page.waitForXPath("//div[@id='custom-progress-bar']");
  await this.takeScreenshot("spawning-page");
});

defineStep("I can see the JupyterLab page", {timeout: 310 * 1000}, async function() {
  await this.page.waitForXPath("//title[text()='JupyterLab']", {timeout: 300 * 1000});
  const url = this.page.url();
  expect(url).to.contain("/lab");
  await this.page.waitFor(6 * 1000); // just for screenshot the lab page
  await this.takeScreenshot("jupyterlab-page");
});

defineStep("I can see the JupyterLab server is stopped", async function() {
  await this.page.waitForXPath("//a[text()='Start My Server']");
  await this.takeScreenshot("jupyterlab-server-stopped");
});

defineStep("I can logout from JupyterHub", async function() {
  await this.page.waitForXPath("//p[contains(text(), 'Successfully logged out.')]");
  await this.takeScreenshot("logout-from-jupyterhub");
});
