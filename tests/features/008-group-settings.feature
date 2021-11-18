@feat @feat-group-settings @ee @ce @deploy
Feature: Group Settings
  Basic tests

  Background:
    Given I am logged in as an admin
    Then I am on the PrimeHub console "Home" page

    When I choose group with name "e2e-test-group-display-name"
    And I choose "Settings" in sidebar menu
    Then I am on the PrimeHub console "Settings" page

  @wip @regression
  Scenario: Group admin can change default timeout in group settings
    When I click tab of "Jobs"
    And I type value to element with xpath on the page
    | xpath                                                   | value |
    | //input[@class='ant-input-number-input' and @max='999'] | 1     |

     And I click element with xpath on the page
    | xpath                                               |
    | //button[@type='submit']//span[contains(., 'Save')] |

    And I choose "Jobs" in sidebar menu
    Then I am on the PrimeHub console "Jobs" page

    When I click "New Job" button
    Then I am on the PrimeHub console "NewJob" page
    And I "should" see element with xpath "//input[@aria-valuenow='60']"
    And I "should" see element with xpath "//div[contains(., 'Minutes')]"



