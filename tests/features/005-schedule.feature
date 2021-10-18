@feat-schedule @ee
Feature: Job Schedule
  Basic tests

  @regression
  Scenario Outline: User can create schedule
    Given I am logged in as a <role>
    Then I am on the PrimeHub console "Home" page

    When I choose group with name "e2e-test-group-display-name"
    And I keep group resource data
    And I choose "Schedule" in sidebar menu
    Then I am on the PrimeHub console "Schedule" page

    When I click "New Schedule" button
    Then I am on the PrimeHub console "NewSchedule" page

    When I choose radio button with name "e2e-test-instance-type" and e2e suffix
    And I choose radio button with name "e2e-test-image" and e2e suffix
    And I type "create-schedule-test" to "displayName" text field
    And I type "echo 'test'" to "command" text field
    And I click "Submit" button
    Then I am on the PrimeHub console "Schedule" page

    When I wait for 1.0 second
    And I "run" the "create-schedule-test" in Schedule
    And I wait for 1.0 second
    And I click element with xpath "//a//u[contains(., 'view your job details here.')]"
    Then I wait for attribute "Status" with value "Succeeded" in job upper pane
    And I wait for attribute "Job Name" with value "create-schedule-test"

    When I click tab of "Logs"
    Then I should see "test" in element "div" under active tab

    Examples:
    | role  |
    | admin |
    | user  |

  @regression
  Scenario Outline: User can update schedule
    Given I am logged in as a <role>
    Then I am on the PrimeHub console "Home" page

    When I choose group with name "e2e-test-group-display-name"
    And I keep group resource data
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

    Examples:
    | role  |
    | admin |
    | user  |

  @regression
  Scenario Outline: User can delete schedule
    Given I am logged in as a <role>
    Then I am on the PrimeHub console "Home" page

    When I choose group with name "e2e-test-group-display-name"
    And I keep group resource data
    And I choose "Schedule" in sidebar menu
    Then I am on the PrimeHub console "Schedule" page

    When I click element with xpath "//td[text()='update-schedule-test']//..//button[3]" and wait for xpath "//div[@class='ant-modal-confirm-body-wrapper']//span[contains(.,'Delete')]" appearing
    And I click button of "Yes" on confirmation dialogue
    Then I "should not" see element with xpath "//td[text()='update-schedule-test']"

    Examples:
    | role  |
    | admin |
    | user  |
