@feat-schedule @ee
Feature: Job Schedule
  Basic tests

  Background:
    Given I am logged in
    Then I am on the PrimeHub console "Home" page

  @regression
  Scenario: User can create schedule
    When I choose group with name "e2e-test-group-display-name"
    And I choose "Schedule" in sidebar menu
    Then I am on the PrimeHub console "Schedule" page
    When I click "New Schedule" button
    Then I am on the PrimeHub console "NewSchedule" page
    When I choose radio button with name "test-instance-type"
    And I choose radio button with name "test-image"
    And I type "create-schedule-test" to "displayName" text field
    And I type "echo 'test'" to "command" text field
    And I click "Submit" button
    Then I am on the PrimeHub console "Schedule" page
    When I click element with xpath "//td[text()='create-schedule-test']//..//button[1]" and wait for xpath "//div[@class='ant-modal-content']//a" appearing
    And I click element with xpath "//div[@class='ant-modal-content']//a"
    Then I wait for attribute "Status" with value "Succeeded" in job upper pane
    And I wait for attribute "Job Name" with value "create-schedule-test"
    When I click tab of "Logs"
    Then I should see "test" in element "div" under active tab
    When I choose "Logout" in top-right menu
    Then I am on login page

  @regression
  Scenario: User can update schedule
    When I choose group with name "e2e-test-group-display-name"
    And I choose "Schedule" in sidebar menu
    Then I am on the PrimeHub console "Schedule" page
    When I click element with xpath "//td[text()='create-schedule-test']//..//button[2]" and wait for navigation
    Then I am on the PrimeHub console "UpdateSchedule" page    
    When I type "update-schedule-test" to "displayName" text field
    And I type "echo 'update-test'" to "command" text field
    And I click element with xpath "//div[text()='Inactive']"
    And I wait for 1.0 seconds
    And I click element with xpath "//li[text()='Custom']"
    And I wait for 1.0 seconds
    And I type "* * * * *" to element with xpath "//input[@placeholder='* * * * *']"
    And I click "Confirm" button
    Then I am on the PrimeHub console "Schedule" page
    And I wait for 60.0 seconds
    When I choose "Jobs" in sidebar menu
    Then I am on the PrimeHub console "Jobs" page
    When I click element with xpath "//tr[1]//a[text()='update-schedule-test']" and wait for navigation
    Then I wait for attribute "Status" with value "Succeeded" in job upper pane
    When I click tab of "Logs"
    Then I should see "update-test" in element "div" under active tab
    When I choose "Logout" in top-right menu
    Then I am on login page

  @regression
  Scenario: User can delete schedule
    When I choose group with name "e2e-test-group-display-name"
    And I choose "Schedule" in sidebar menu
    Then I am on the PrimeHub console "Schedule" page
    When I click element with xpath "//td[text()='update-schedule-test']//..//button[3]" and wait for xpath "//div[@class='ant-modal-confirm-body-wrapper']//span[contains(.,'Delete')]" appearing
    And I click button of "Yes" on confirmation dialogue
    Then I "should not" see element with xpath "//td[text()='update-schedule-test']"
