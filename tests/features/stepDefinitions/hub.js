const { defineStep } = require("cucumber");
const { expect } = require("chai");

defineStep("I get the iframe object", async function() {
  this.context = this.page.frames()[1];
});

defineStep("I go to the spawner page", async function() {
  let frame, ret;
  let xpath = "//h4[text()='Select your notebook settings']";
  for (retryCount=0; retryCount < 10; retryCount++) {
    try {
      await this.context.click("#start");
    }
    catch (e) {}
    await this.checkElementExistByXPath('should exist', xpath, context = this.context).then(
      function(result) { ret = result; }
    );
    if (ret) {
      await this.page.waitForTimeout(2000);
      await this.takeScreenshot("spawner-page");
      return;
    }
    await this.page.waitForTimeout(2000);
  }
  throw new Error("failed to go to the spawner page");
});

defineStep("I am on the notebooks admin page", async function() {
  let frame, ret;
  let xpath = "//title[text()='JupyterHub']";
  for (retryCount=0; retryCount < 5; retryCount++) {
    await this.checkElementExistByXPath('should exist', xpath, context = this.context).then(
      function(result) { ret = result; }
    );
    if (ret) {
      await this.page.waitForTimeout(2000);
      await this.takeScreenshot("notebooks-admin-page");
      return;
    }
    await this.page.waitForTimeout(1000);
  }
  throw new Error("failed to go to the notebooks admin page");
});

defineStep("I click element with selector {string} in hub", async function(selector) {
  await this.clickElementBySelector(selector, context = this.context);
});

defineStep("I choose instance type", async function() {
  const selector = "#it-container label:first-child input[type='radio']";
  await this.clickElementBySelector(selector, context = this.context);
});

defineStep("I choose instance type with name {string}", async function(name) {
  const selector = this.E2E_SUFFIX ? `#it-container input[value='${name}-${this.E2E_SUFFIX}']` : `#it-container input[value='${name}']`;
  await this.clickElementBySelector(selector, context = this.context);
  await this.page.waitForTimeout(500);
  const screenshot = this.E2E_SUFFIX ? `choose-instance-type-${name}-${this.E2E_SUFFIX}` : `choose-instance-type-${name}`;
  await this.takeScreenshot(screenshot);
});

defineStep("I choose image with name {string}", async function(name) {
  const selector = this.E2E_SUFFIX ? `#image-container input[value='${name}-${this.E2E_SUFFIX}']` : `#image-container input[value='${name}']`;
  await this.clickElementBySelector(selector, context = this.context);
  await this.page.waitForTimeout(500);
  const screenshot = this.E2E_SUFFIX ? `choose-image-${name}-${this.E2E_SUFFIX}` : `choose-image-${name}`;
  await this.takeScreenshot(screenshot);
});

defineStep("I choose latest TensorFlow image", async function() {
  let ele;
  for (retryCount=0; retryCount < 3; retryCount++) {
    ele = await this.context.$x("//input[contains(@value, 'tf-') and not(@disabled)]");
    if (ele.length > 0) {
      await ele[ele.length-1].click();
      await this.page.waitForTimeout(500);
      await this.takeScreenshot("choose-latest-tensorflow-image");
      return;
    }
  }
  throw new Error("failed to choose latest TensorFlow image");
});

defineStep("I can see the user limits are {string}, {string}, and {string}", async function(cpu, mem, gpu) {
  var xpath = "//tr[@id='user-limits-body']";
  var element, text;
  const resources = [cpu, mem, gpu];
  for (index = 0; index < resources.length; index++) {
    [element] = await this.context.$x(xpath+`//td[${index+1}]`);
    text = await (await element.getProperty('textContent')).jsonValue();
    if (resources[index] !== text.trim()) throw new Error(`Resources value mismatch, ecpected: ${resources[index]}, actual: ${text.trim()}`);
  }
});

defineStep("I can see the group resource limits are {string}, {string}, and {string}", async function(cpu, mem, gpu) {
  var text;
  const ids = ['#group-cpu-limit', '#group-mem-limit', '#group-gpu-limit'];
  const resources = [cpu, mem, gpu];
  for (index = 0; index < resources.length; index++) {
    text = await this.context.$eval(ids[index], ele => ele.textContent);
    if (resources[index] !== text) throw new Error(`Resources value mismatch, ecpected: ${resources[index]}, actual: ${text}`);
  }
});

defineStep("I {string} see instance types block contains {string} instanceType with {string} description and tooltip to show {string}", async function(exist, name, desc, resource) {
  const xpath = `//div[@id='it-container']//strong[contains(text(), '${name}-${this.E2E_SUFFIX}')]`;
  let ret;

  await this.checkElementExistByXPath(exist, xpath, context = this.context).then(
      function(result) { ret = result; }
  );
  if (!ret) throw new Error(`failed to check '${name}-${this.E2E_SUFFIX}' instanceType does not exist`);
  
  if (!exist.includes('not')) {
    const [element] = await this.context.$x(xpath+'//i');
    await element.hover();
    await this.takeScreenshot("hover-information-tooltip");

    await this.checkElementExistByXPath(exist, xpath+`//div[text()='${resource}']`, context = this.context).then(
      function(result) { ret = result; }
    );
    if (!ret) throw new Error(`failed to get '${resource}' information tooltip`);

    await this.checkElementExistByXPath(exist, xpath+`//..//p[text()='${desc}-${this.E2E_SUFFIX}']`, context = this.context).then(
      function(result) { ret = result; }
    );
    if (!ret) throw new Error(`failed to get '${desc}-${this.E2E_SUFFIX}' instanceType description`);
  }
});

defineStep("I {string} see images block contains {string} image with {string} type and {string} description", async function(exist, name, type, desc) {
  let ret;
  let xpath = `//div[@id='image-container']//strong[contains(text(), '${name}')]`;
  
  await this.checkElementExistByXPath(exist, xpath, context = this.context).then(
      function(result) { ret = result; }
  );
  if (!ret) throw new Error(`failed to check image '${name}' is existed`);
  
  if (!exist.includes('not')) {
    const [element] = await this.context.$x(xpath+'//i');
    await element.hover();
    await this.takeScreenshot("hover-information-tooltip");

    await this.checkElementExistByXPath(exist, xpath+`//div[text()='${type}']`, context = this.context).then(
      function(result) { ret = result; }
    );
    if (!ret) throw new Error(`failed to get '${type}' information tooltip`);

    xpath += `//..//p[contains(text(), '${desc}')]`;
    await this.checkElementExistByXPath(exist, xpath, context = this.context).then(
      function(result) { ret = result; }
    );
    if (!ret) throw new Error(`failed to get '${desc}' image description`);
  }
});

defineStep("I can see advanced settings", async function() {
  let ret;
  const xpath = "//div[@aria-expanded='true']//label[text()='Enable Safe Mode ']";
  
  await this.clickElementByXpath("//a[@href='#advanced-setup']", context = this.context);
  await this.checkElementExistByXPath('should exist', xpath, context = this.context).then(
      function(result) { ret = result; }
  );
  if (!ret) throw new Error("failed to get 'Enable Safe Mode' checkbox");

  for (retryCount=0; retryCount < 5; retryCount++) {
    await this.checkElementExistByXPath(
      'should exist', 
      xpath+"//i[@data-original-title='Safe Mode mounts your persistent home directory under /home/jovyan/user.']", 
      context = this.context).then(
        function(result) { ret = result; }
    );
    if (ret) return;
    await this.page.waitForTimeout(2000);
  }
  throw new Error("failed to get information tooltip");
});

defineStep("I can see the spawning page and wait for notebook started", {timeout: 500 * 1000}, async function() {
  let ret;
  await this.context.waitForXPath("//div[@id='custom-progress-bar']");
  await this.takeScreenshot("spawning-page");
  for (retryCount=0; retryCount < this.SPAWNER_START_TIMEOUT; retryCount+=10) {
    await this.checkElementExistByXPath('should exist', "//a[@id='start']", context = this.context).then(
      function(result) { ret = result; }
    );
    if (ret){
      await this.page.waitForTimeout(1000);
      return;
    }
    else
      await this.page.waitForTimeout(10000);
  }
  throw new Error("failed to start notebook");
});

defineStep("I can see the spawning page and wait for log {string}", async function(log) {
  let xpath = `//div[@class='progress-log-event' and contains(text(), '${log}')]`, ret;
  await this.context.waitForXPath("//div[@id='custom-progress-bar']");
  await this.takeScreenshot("spawning-page");
  for (retryCount=0; retryCount < 20; retryCount++) {
    await this.checkElementExistByXPath('should exist', xpath, context = this.context).then(
      function(result) { ret = result; }
    );
    if (ret) return;
    else await this.page.waitForTimeout(6000);
  }
  throw new Error(`failed to wait for log: ${log}`);
});

defineStep("I can see the JupyterLab page", async function() {
  await this.page.waitForXPath("//title[text()='JupyterLab']");
  await this.takeScreenshot("jupyter-lab");
});

defineStep("I stop my server in hub", async function() {
  const selector = "a[id='stop']";
  for (retryCount=0; retryCount < 10; retryCount++) {
    try {
      await this.context.waitForSelector(selector, {visible: true, timeout: 5000});
      await this.context.click(selector);
      await this.page.waitForTimeout(1000);
      console.log("still stopping my server");
    }
    catch (e) {
      await this.takeScreenshot("server-stopped");
      return;
    }
  }
  throw new Error("failed to stop my server");
});

defineStep("I access my server in notebooks admin", async function() {
  await this.clickElementByXpath(
    `//tr[@data-user='${this.USERNAME}']//a[contains(text(), 'access server')]`, context = this.context);
});

defineStep("I stop my server in notebooks admin", async function() {
  await this.clickElementByXpath(
    `//tr[@data-user='${this.USERNAME}']//a[contains(text(), 'stop server')]`, context = this.context);
  await this.page.waitForTimeout(20000);
  // might sometimes failed, blocked by ch13256
  /*
  const xpath = `//tr[@data-user='${this.USERNAME}']//a[text()='stopping...']`;
  let ele, ret;
  for (retryCount=0; retryCount < 5; retryCount++) {
    try { 
      [ele] = await this.context.$x(xpath, {timeout: 5000});
      await ele.click();
    } 
    catch (e) {}
    await this.checkElementExistByXPath('should exist', xpath, context = this.context).then(
      function(result) { ret = !result; }
    );
    console.log('click stop server');
    if (ret) {
      console.log('stopped');
      await this.takeScreenshot("stop-my-server");
      return;
    }
    await this.page.waitForTimeout(2000);
  }
  throw new Error('failed to stop my server in notebooks admin page');
  */
});

defineStep("I {string} see element with xpath {string} in hub", async function(exist, string) {
  try {
    await this.context.waitForXPath(string, {timeout: 5 * 1000});
    if (exist.includes('not')) throw new Error('element should not exist');
  }
  catch (e) {
    if (!exist.includes('not')) throw new Error('element should be exist');
  }
});

defineStep("I click element with xpath {string} in hub", async function(string) {
  await this.clickElementByXpath(string, context = this.context);
});

defineStep("I check the group warning message against group {string}", async function(name) {
  // group selector: ${NAME}-display-name-${E2E_SUFFIX}
  // warning message: ${NAME}-${E2E_SUFFIX}
  const xpath = `//h3[text()='The current server is launched by another group (${name}-${this.E2E_SUFFIX})']`;
  let ele, text, ret;

  [ele] = await this.page.$x("//div[@class='ant-select-selection-selected-value']");
  text = await (await ele.getProperty('textContent')).jsonValue();

  await this.checkElementExistByXPath('should not exist', xpath, context = this.context).then(
      function(result) { ret = result; }
  );
  if (ret !== (text === `${name}-display-name-${this.E2E_SUFFIX}`))
    throw new Error("the group warning message is existed: ", !ret);
});

defineStep("I click the {string} card in the launcher", async function(name) {
  await this.clickElementByXpath(`//p[text()='${name}']`);
  await this.page.waitForTimeout(5000);
  await this.takeScreenshot(`click-${name}`);
});

defineStep("I input {string} command in the terminal", async function(command) {
  await this.clickElementBySelector(".xterm-cursor-layer");
  await this.page.keyboard.type(command);
  await this.page.keyboard.press('Enter');
  await this.page.waitForTimeout(500);
  await this.takeScreenshot("input-command-terminal");
});

defineStep("I close all tabs in JupyterLab", async function() {
  const xpath = ["//div[text()='File']", "//div[@class='lm-Menu-itemLabel p-Menu-itemLabel' and text()='Close All Tabs']"];
  for (itemCount=0; itemCount < xpath.length; itemCount++) {
    await this.clickElementByXpath(xpath[itemCount]);
    await this.takeScreenshot("I-close-all-tabs-in-JupyterLab");
  }
});

defineStep("I open {string} file in the file browser", async function(name) {
  let ele;
  for (retryCount=0; retryCount < 3; retryCount++) {
    try {
      await this.page.waitForXPath(
        "//li[@data-id='filebrowser' and @class='p-TabBar-tab']",
        {timeout: 5000});
      await this.page.click("//li[@data-id='filebrowser' and @class='p-TabBar-tab']");
      await this.takeScreenshot("click-file-browser");
    }
    catch (e) {}

    [ele] = await this.page.$x(`//span[@class='jp-DirListing-itemText' and text()='${name}']`);
    if (ele) {
      const { x, y, width, height } = await ele.boundingBox();
      await this.page.mouse.click(x, y, { clickCount: 2 });
      await this.takeScreenshot("open-file");
      return;
    }
  }
  throw new Error("failed to open file");
});
