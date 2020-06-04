var reporter = require("cucumber-html-reporter");

var options = {
  theme: "bootstrap",
  jsonFile: "tests/report/cucumber_report.json",
  output: "tests/report/cucumber_report.html",
  reportSuiteAsScenarios: true,
  launchReport: true
};

reporter.generate(options);
