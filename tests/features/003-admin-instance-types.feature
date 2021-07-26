@released @ee @ce
Feature: Admin
  In order to manage instance types
  I want to change settings

  Background:
    Given I am logged in
    Then I am on the PrimeHub console "Home" page
    When I choose "Admin Portal" in top-right menu
    Then I am on the admin dashboard "Groups" page

  @sanity @smoke
  Scenario: Create instance type and connect to existing group
    When I click "Instance Types" in admin dashboard
    Then I am on the admin dashboard "Instance Types" page
    And I should see element with test-id "instanceType"
    When I click element with test-id "add-button"
    Then I should see element with test-id "instanceType/name"
    And I should see element with test-id "instanceType/displayName"
    When I type "test-instance-type" to element with test-id "instanceType/name"
    When I type "test-instance-type-display-name" to element with test-id "instanceType/displayName"
    And I type "test-description" to element with test-id "instanceType/description"
    And I type "0.5" to element with test-id "instanceType/cpuLimit"
    And I click element with test-id "connect-button"
    And I wait for 4.0 seconds
    And I search "e2e-test-group" in test-id "text-filter-name"
    And I click element with xpath on the page
    | fields                                             |
    | //td[contains(text(), 'e2e-test-group')]/..//input |
    | //button/span[text()='OK']                         |

    And I wait for 4.0 seconds
    And I click element with xpath "//a/span[text()='Confirm']"
    And I wait for 2.0 seconds
    And I search "test-instance-type" in test-id "text-filter-name"
    Then list-view table "should" contain row with "test-instance-type"
    When I choose "Logout" in top-right menu
    Then I am on login page

  @daily
  Scenario: Create GPU instance type
    When I click "Instance Types" in admin dashboard
    Then I am on the admin dashboard "Instance Types" page
    And I should see element with test-id "instanceType"
    When I click element with test-id "add-button"
    Then I should see element with test-id "instanceType/name"
    And I should see element with test-id "instanceType/displayName"
    When I type "test-instance-type-gpu" to element with test-id "instanceType/name"
    And I click element with xpath "//a/span[text()='Confirm']"
    And I wait for 2.0 seconds
    And I search "test-instance-type-gpu" in test-id "text-filter-name"
    Then list-view table "should" contain row with "test-instance-type-gpu"
    When I choose "Logout" in top-right menu
    Then I am on login page

  @daily
  Scenario: Update GPU instance type and connect to existing group
    When I click "Instance Types" in admin dashboard
    Then I am on the admin dashboard "Instance Types" page
    When I search "test-instance-type-gpu" in test-id "text-filter-name"
    And I click edit-button in row contains text "test-instance-type-gpu"
    Then I should see input in test-id "instanceType/name" with value "test-instance-type-gpu"
    And I should see input in test-id "instanceType/displayName" with value "test-instance-type-gpu"
    When I type "test-instance-type-gpu-display-name" to element with test-id "instanceType/displayName"
    And I type "test-description-gpu" to element with test-id "instanceType/description"
    And I type "1" to element with xpath "//div[@data-testid='instanceType/gpuLimit']//input"
    And I click element with test-id "connect-button"
    And I wait for 4.0 seconds
    And I search "e2e-test-group" in test-id "text-filter-name"
    And I click element with xpath on the page
    | fields                                             |
    | //td[contains(text(), 'e2e-test-group')]/..//input |
    | //button/span[text()='OK']                         |

    And I wait for 4.0 seconds
    And I click element with xpath "//a/span[text()='Confirm']"
    And I wait for 2.0 seconds
    And I search "test-instance-type-gpu-display-name" in test-id "text-filter-displayName"
    Then list-view table "should" contain row with "test-instance-type-gpu"
    When I click edit-button in row contains text "test-instance-type-gpu"
    Then I should see input in test-id "instanceType/name" with value "test-instance-type-gpu"
    And I should see input in test-id "instanceType/displayName" with value "test-instance-type-gpu-display-name"
    When I click on PrimeHub icon
    Then I am on the PrimeHub console "Home" page
    And I choose group with name "e2e-test-group-display-name"
    When I choose "Notebooks" in sidebar menu
    Then I am on the PrimeHub console "Notebooks" page
    When I get the iframe object
    And I go to the spawner page
    #Then I "should" see instance types block contains "test-instance-type-gpu-display-name" instanceType with "test-description-gpu" description and tooltip to show "CPU: 1 / Memory: 1G / GPU: 1"
    When I choose "Logout" in top-right menu
    Then I am on login page
