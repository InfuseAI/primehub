@feat @feat-jobs @ee
Feature: Recurring Jobs 
  Basic tests

  @regression
  Scenario Outline: User can create recurring jobs
    Given I am logged in as a <role>
    Then I am on the PrimeHub console "Home" page

    When I choose group with name "e2e-test-group-display-name"
    And I keep group resource data
    And I choose "Jobs" in sidebar menu
    Then I am on the PrimeHub console "Jobs" page

    When I click "New Job" button
    Then I am on the PrimeHub console "NewJob" page

    When I choose radio button with name "e2e-test-instance-type"
    And I choose radio button with name "e2e-test-image"
    And I type "create-recurring-job-test" to "displayName" text field
    And I type "echo 'test'" to "command" text field
    And I click element with xpath "//input[@value='schedule']"
    And I click "Submit" button
    Then I am on the PrimeHub console "RecurringJob" page

    When I wait for 1.0 second
    And I "run" the "create-recurring-job-test" in Jobs 
    And I wait for 1.0 second
    And I click element with xpath "//a//u[contains(., 'view your job details here.')]"
    Then I wait for attribute "Status" with value "Succeeded" in job upper pane
    And I wait for attribute "Job Name" with value "create-recurring-job-test"

    When I click tab of "Logs"
    Then I should see "test" in element "div" under active tab

    Examples:
    | role  |
    | admin |
    | user  |

  @regression
  Scenario Outline: User can update recurring jobs
    Given I am logged in as a <role>
    Then I am on the PrimeHub console "Home" page

    When I choose group with name "e2e-test-group-display-name"
    And I keep group resource data
    And I choose "Jobs" in sidebar menu
    Then I am on the PrimeHub console "Jobs" page

    When I click tab of "Recurring Jobs"
    And I click element with xpath "//td[text()='create-recurring-job-test']//..//button[2]" and wait for navigation
    Then I am on the PrimeHub console "UpdateJob" page    

    When I type "update-recurring-job-test" to "displayName" text field
    And I type "echo 'update-test'" to "command" text field
    And I click element with xpath "//div[text()='On Demand']"
    And I wait for 1.0 seconds
    And I click element with xpath "//li[text()='Custom']"
    And I wait for 1.0 seconds
    And I type "* * * * *" to element with xpath "//input[@placeholder='* * * * *']"
    And I click "Submit" button
    Then I am on the PrimeHub console "RecurringJob" page

    When I click tab of "Recurring Jobs"
    And I "run" the "update-recurring-job-test" in Jobs 
    And I wait for 1.0 second
    And I click element with xpath "//a//u[contains(., 'view your job details here.')]"
    Then I wait for attribute "Status" with value "Succeeded" in job upper pane

    When I click tab of "Logs"
    Then I should see "update-test" in element "div" under active tab

    Examples:
    | role  |
    | admin |
    | user  |

  @regression
  Scenario Outline: User can delete recurring jobs
    Given I am logged in as a <role>
    Then I am on the PrimeHub console "Home" page

    When I choose group with name "e2e-test-group-display-name"
    And I keep group resource data
    And I choose "Jobs" in sidebar menu
    Then I am on the PrimeHub console "Jobs" page

    When I click tab of "Recurring Jobs"
    And I click element with xpath "//td[text()='update-recurring-job-test']//..//button[3]" and wait for xpath "//div[@class='ant-modal-confirm-body-wrapper']//span[contains(.,'Delete')]" appearing
    And I click button of "Yes" on confirmation dialogue
    Then I "should not" see element with xpath "//td[text()='update-recurring-job-test']"

    Examples:
    | role  |
    | admin |
    | user  |
