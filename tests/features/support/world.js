const { setWorldConstructor } = require("cucumber");
const { expect } = require("chai");
const puppeteer = require("puppeteer");
const fs = require("fs");
const defaultTimeout = 120 * 1000

const {setDefaultTimeout} = require('cucumber');
setDefaultTimeout(defaultTimeout);

const escapeXpathString = str => {
  const splitedQuotes = str.replace(/'/g, `', "'", '`);
  return `concat('${splitedQuotes}', '')`;
};

class World {
  constructor({ attach, parameters }) {
    this.attach = attach;
    this.parameters = parameters;
    this.KC_SCHEME = process.env.KC_SCHEME;
    this.KC_DOMAIN = process.env.KC_DOMAIN;
    this.KC_REALM = process.env.KC_REALM;
    this.PRIMEHUB_SCHEME = process.env.PRIMEHUB_SCHEME;
    this.PRIMEHUB_DOMAIN = process.env.PRIMEHUB_DOMAIN;
    this.USERNAME = process.env.PH_USERNAME;
    //this.USER_EMAIL = process.env.PH_USER_EMAIL;
    this.PASSWORD = process.env.PH_PASSWORD;
    this.DEBUG = process.env.DEBUG;
    this.E2E_SUFFIX = process.env.E2E_SUFFIX;
    this.SPAWNER_START_TIMEOUT = process.env.SPAWNER_START_TIMEOUT;

    // To run tests in different setup,
    // kind -> port# is need; gcp -> port# isn't need
    if (process.env.KC_PORT !== 'None') this.KC_PORT = `:${process.env.KC_PORT}`;
    else this.KC_PORT = '';
    this.PRIMEHUB_PORT = this.KC_PORT;

    this.HOME_URL = `${this.PRIMEHUB_SCHEME}://${this.PRIMEHUB_DOMAIN}${this.PRIMEHUB_PORT}/console/g`;
    this.KC_SERVER_URL = `${this.KC_SCHEME}://${this.KC_DOMAIN}${this.KC_PORT}/auth/realms`;

    this.context = null;
    this.copyText = null;
  }

  async start() {
    this.browser = await puppeteer.launch({
      defaultViewport: {
        width: 1920,
        height: 1080
      },
      // setup proxy server to speed up puppeteer
      args: ['--no-sandbox', '--disable-setuid-sandbox', "--proxy-server='direct://'", '--proxy-bypass-list=*']
    });
    this.page = await this.browser.newPage();
    this.page.setDefaultTimeout(defaultTimeout);
    // suppress console.log unless DEBUG is true.
    if (this.DEBUG) {
      await this.page.setCacheEnabled(false); // avoid ERR_CONNECTION_RESET error
      this.page.on('console', msg => {
        for (let i = 0; i < msg.args().length; i++) {
          console.log(`[console] ${i}: ${msg.args()[i]}`);
        }
      });
      this.page.on('pageerror', err => {  
        console.log(`pageerror: ${err.toString()}`);
      });
      this.page.on('error', err => {  
        console.log(`error: ${err.toString()}`);
      });
      this.page.on('requestfailed', request => {  
        console.log(`requestfailed: ${request.url()}`);
      });
      this.page.on('load', () => console.log('[Puppeteer] frame loaded: ' + this.page.url()));
    }
  }
  async stop() {
    await this.browser.close();
  }
  async input(input, value) {
    const inputSelector = `input[name="${input}"]`;
    await this.page.waitForSelector(inputSelector);
    this.inputElement = await this.page.$(inputSelector);
    await this.inputElement.type(value);
  }
  async submit() {
    await this.inputElement.press("Enter");
  }
  /*
   * this.clickByText("some text") : search all <a> with "some text"
   * this.clickByText("some text", "div[@class='kc-dropdown']/ul//") : saerch <a> in div.kc-dropdown>ul with "some text"
   */
  async clickByText(text, xpath = "") {
    const escapedText = escapeXpathString(text);
    const handlers = await this.page.$x(
      `(
        //${xpath}input[@value=${escapedText}]|
        //${xpath}button/span[contains(text(), ${escapedText})]|
        //${xpath}a[contains(text(), ${escapedText})]
      )`
    );
    if (handlers.length > 0) {
      await handlers[0].click();
    } else {
      throw new Error(`not found: ${text}`);
    }
  }
  async checkText(selector, text) {
    await this.page.waitForSelector(selector);
    const result = await this.page.evaluate(
      selector => document.querySelector(selector).innerText,
      selector
    );
    expect(result).to.eql(text);
  }

  async clickElementBySelector(selector, context = this.page) {
    await context.waitForSelector(selector, {visible: true});
    await context.click(selector);
  }

  async clickElementByXpath(xpath, context = this.page) {
    await context.waitForXPath(xpath, {visible: true});
    const [ui_element] = await context.$x(xpath);
    await ui_element.click();
  }

  async getValue(element) {
    try {
      await this.page.waitForSelector(element);
      const target = await this.page.$(element);
      const valueHandle = await target.getProperty('value');
      return valueHandle.jsonValue();
    } catch (err) {
      return null;
    }
  }

  async getXPathValue(xpath) {
    try {
      await this.page.waitForXPath(xpath);
      const target = await this.page.$x(xpath);
      if (!target[0]) {
        throw new Error(`xpath ${xpath} not found`);
      }
      const valueHandle = await target[0].getProperty('value');
      return valueHandle.jsonValue();
    } catch (err) {
      return null;
    }
  }

  async getXPathAttribute(xpath, attribute) {
    try {
      await this.page.waitForXPath(xpath);
      const target = await this.page.$x(xpath);
      if (!target[0]) {
        throw new Error(`xpath ${xpath} not found`);
      }

      const attributeValue = await this.page.evaluate(
        (ele, attr) => {
          return ele.getAttribute(attr);
        },
        target[0],
        attribute,
      );
      return attributeValue;
    } catch (err) {
      console.log(err);
      return null;
    }
  }

  async checkElementExistByXPath(exist, xpath, context = this.page) {
    const [ui_element] = await context.$x(xpath);
    return (exist.includes("not") === !ui_element) ? true : false;
  }

  async inputText(selector, text) {
    await this.page.waitForSelector(selector, {visible: true});
    await this.page.focus(selector);
    await this.page.$eval(selector, el => el.setSelectionRange(0, el.value.length));
    await this.page.keyboard.press("Backspace");
    await this.page.type(selector, `${text}-${this.E2E_SUFFIX}`);
  }

  async takeScreenshot(filename) {
    var today = new Date();
    var hours = (today.getHours()>9) ? today.getHours() : '0'+today.getHours();
    var minutes = (today.getMinutes()>9) ? today.getMinutes() : '0'+today.getMinutes();
    var seconds = (today.getSeconds()>9) ? today.getSeconds() : '0'+today.getSeconds();
    await this.page.screenshot({path: 'e2e/screenshots/'+hours+'-'+minutes+'-'+seconds+'-'+filename+'.png'});
  }

  async exportPageContent(filename) {
    const html = await this.page.content();
    fs.writeFile(`e2e/webpages/${filename}.html`, html, function (err) {
      if (err) console.log(err);
      else console.log("Successfully export page content");
    });
  }
}

setWorldConstructor(World);
