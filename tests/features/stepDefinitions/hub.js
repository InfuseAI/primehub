const { defineStep } = require("cucumber");
const { expect } = require("chai");

defineStep("I go to the spawner page", async function() {
  let frame, ret;
  let xpath = "//h4[text()='Select your notebook settings']";
  for (retryCount=0; retryCount < 10; retryCount++) {
    try {
      frame = this.page.frames()[1];
      await frame.click("#start");
    }
    catch (e) {}
    await this.checkElementExistByXPath('should exist', xpath, context = frame).then(
      function(result) { ret = result; }
    );
    if (ret) {
      await this.page.waitForTimeout(2000);
      this.context = frame;
      await this.takeScreenshot("spawner-page");
      return;
    }
    await this.page.waitForTimeout(2000);
  }
  throw new Error("failed to go to the spawner page");
});

defineStep("I go to the notebooks admin page", async function() {
  let frame, ret;
  let xpath = "//title[text()='JupyterHub']";
  for (retryCount=0; retryCount < 5; retryCount++) {
    try { frame = this.page.frames()[1]; }
    catch (e) {}
    await this.checkElementExistByXPath('should exist', xpath, context = frame).then(
      function(result) { ret = result; }
    );
    if (ret) {
      await this.page.waitForTimeout(2000);
      this.context = frame;
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

defineStep("I choose image", async function() {
  const selector = "#image-container label:first-child input[type='radio']";
  await this.clickElementBySelector(selector, context = this.context);
});

defineStep("I choose instance type with name {string}", async function(name) {
  const selector = `#it-container input[value='${name}-${this.E2E_SUFFIX}']`;
  await this.clickElementBySelector(selector, context = this.context);
  await this.page.waitForTimeout(500);
  await this.takeScreenshot(`choose-instance-type-${name}-${this.E2E_SUFFIX}`);
});

defineStep("I choose image with name {string}", async function(name) {
  const selector = `#image-container input[value='${name}-${this.E2E_SUFFIX}']`;
  await this.clickElementBySelector(selector, context = this.context);
  await this.page.waitForTimeout(500);
  await this.takeScreenshot(`choose-image-${name}-${this.E2E_SUFFIX}`);
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
  if (!ret) throw new Error(`failed to check '${name}-${this.E2E_SUFFIX}' instanceType is existed`);
  
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
  let xpath = `//div[@id='image-container']//strong[text()='${name}-${this.E2E_SUFFIX} (${type})']`;
  
  await this.checkElementExistByXPath(exist, xpath, context = this.context).then(
      function(result) { ret = result; }
  );
  if (!ret) throw new Error(`failed to check image '${name}-${this.E2E_SUFFIX} (${type})' is existed`);
  
  if (!exist.includes('not')) {
    xpath += `//..//p[text()='${desc}-${this.E2E_SUFFIX}']`;
    await this.checkElementExistByXPath(exist, xpath, context = this.context).then(
      function(result) { ret = result; }
    );
    if (!ret) throw new Error(`failed to get '${desc}-${this.E2E_SUFFIX}' image description`);
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

defineStep("I can see the spawning page and wait for notebook started", {timeout: 320 * 1000}, async function() {
  let ret;
  await this.context.waitForXPath("//div[@id='custom-progress-bar']");
  await this.takeScreenshot("spawning-page");
  for (retryCount=0; retryCount < 20; retryCount++) {
    await this.checkElementExistByXPath('should exist', "//a[@id='start']", context = this.context).then(
      function(result) { ret = result; }
    );
    if (ret){
      await this.page.waitForTimeout(15000);
      return;
    }
    else
      await this.page.waitForTimeout(15000);
  }
  throw new Error("failed to start notebook");
});

defineStep("I can see the spawning page and wait for log {string}", {timeout: 120 * 1000}, async function(log) {
  let xpath = `//div[@class='progress-log-event' and contains(text(), '${log}')]`, ret;
  await this.context.waitForXPath("//div[@id='custom-progress-bar']");
  await this.takeScreenshot("spawning-page");
  for (retryCount=0; retryCount < 20; retryCount++) {
    await this.checkElementExistByXPath('should exist', xpath, context = this.context).then(
      function(result) { ret = result; }
    );
    if (ret){
      const [ele] = await this.context.$x("//a[contains(@class, 'cancel-spawn')]");
      if (ele) {
        await ele.click();
        await this.takeScreenshot("cancel-spawning");
        return;
      }
      else throw new Error("failed to click cancel link");
    }
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
