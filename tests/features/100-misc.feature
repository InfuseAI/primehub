@feat-misc @ee @ce @deploy
Feature: misc
  Check API token

  Background:
    Given I am logged in
    Then I am on the PrimeHub console "Home" page

    When I choose "API Token" in top-right menu
    Then I am on the admin portal "API Token" page

  @regression @sanity @smoke
  Scenario: User can see server URL in Example
    And I should see URL in textarea in API Token

  @regression @sanity @smoke
  Scenario: User can request an API Token
    When I click element with test-id "request-button"
    And I wait for 4 seconds
    And I should see element with test-id on the page
    | test-id         |
    | request-button  |
    | download-button |

    And I should see API Token in input in API Token

  @regression @sanity
  Scenario: User can request API Token again
    When I click element with test-id "request-button"
    And I click button of "OK" on confirmation dialogue
    And I wait for 4 seconds
    And I should see element with test-id on the page
    | test-id         |
    | request-button  |
    | download-button |

    And I should see API Token in input in API Token
