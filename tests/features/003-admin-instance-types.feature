@admin-instance-types @ee @ce
Feature: Admin - Instance Types
  In order to manage instance types
  I want to change settings

  Background:
    Given I am logged in
    Then I am on the PrimeHub console "Home" page
    When I choose "Admin Portal" in top-right menu
    Then I am on the admin dashboard "Groups" page

    When I click "Instance Types" in admin dashboard
    Then I am on the admin dashboard "Instance Types" page
    And I should see element with test-id "instanceType"

  @regression @sanity @smoke @prep-data
  Scenario: Create an instance type
    When I click element with test-id "add-button"
    Then I should see element with test-id "instanceType/name"
    And I should see element with test-id "instanceType/displayName"
    When I type valid info to test-id on the page
    | fields            | values                                     |
    | instanceType/name        | e2e-test-instance-type              |
    | instanceType/displayName | e2e-test-instance-type-display-name |
    | instanceType/description | e2e-test-description                |
    | instanceType/cpuLimit    | 0.5                                 |

    And I click element with test-id "confirm-button"
    When I choose "Logout" in top-right menu
    Then I am on login page


  @regression @sanity @smoke @prep-data
  Scenario: Connect an instance type to an existing group
    When I search "e2e-test-instance-type" in test-id "text-filter-name"
    Then list-view table "should" contain row with "e2e-test-instance-type"
    When I click edit-button in row contains text "e2e-test-instance-type"
    Then I should see input in test-id "instanceType/name" with value "e2e-test-instance-type"
    When I click element with test-id "connect-button"
    And I wait for 1.0 second
    And I search "e2e-test-group" in test-id "text-filter-name"
    Then list-view table "should" contain row with "e2e-test-group"
    And I click element with xpath on the page
    | fields                                             |
    | //td[contains(text(), 'e2e-test-group')]/..//input |
    | //button/span[text()='OK']                         |

    And I wait for 1.0 second
    And I click element with xpath "//a/span[text()='Confirm']"
    When I choose "Logout" in top-right menu
    Then I am on login page

  @regression @prep-data
  Scenario: Create an GPU instance type
    When I click element with test-id "add-button"
    Then I should see element with test-id "instanceType/name"
    And I should see element with test-id "instanceType/displayName"
    When I type valid info to test-id on the page
    | fields                   | values                     |
    | instanceType/name        | e2e-test-instance-type-gpu |
    | instanceType/displayName | e2e-test-instance-type-gpu |
    | instanceType/cpuLimit    | 0.5                        |

    And I click element with test-id "confirm-button"
    When I choose "Logout" in top-right menu
    Then I am on login page

  @regression @prep-data
  Scenario: Update an GPU instance type
    When I search "e2e-test-instance-type-gpu" in test-id "text-filter-name"
    And I click edit-button in row contains text "e2e-test-instance-type-gpu"
    Then I should see input in test-id "instanceType/name" with value "e2e-test-instance-type-gpu"
    And I should see input in test-id "instanceType/displayName" with value "e2e-test-instance-type-gpu"
    When I type valid info to test-id on the page
    | fields                   | values                                  |
    | instanceType/displayName | e2e-test-instance-type-display-name-gpu |
    | instanceType/description | e2e-test-instance-type-description-gpu  |
    | instanceType/cpuLimit    | 1                                       |

    And I click element with xpath "//a/span[text()='Confirm']"
    When I choose "Logout" in top-right menu
    Then I am on login page

  @regression @prep-data
  Scenario: Connect an GPU instance type to an existing group
    When I search "e2e-test-instance-type-gpu" in test-id "text-filter-name"
    Then list-view table "should" contain row with "e2e-test-instance-type-gpu"
    When I click edit-button in row contains text "e2e-test-instance-type-gpu"
    Then I should see input in test-id "instanceType/name" with value "e2e-test-instance-type-gpu"
    When I click element with test-id "connect-button"
    And I wait for 1.0 second
    And I search "e2e-test-group" in test-id "text-filter-name"
    Then list-view table "should" contain row with "e2e-test-group"
    And I click element with xpath on the page
    | fields                                             |
    | //td[contains(text(), 'e2e-test-group')]/..//input |
    | //button/span[text()='OK']                         |

    And I wait for 1.0 second
    And I click element with xpath "//a/span[text()='Confirm']"
    When I choose "Logout" in top-right menu
    Then I am on login page

  @regression @prep-data
  Scenario: Show an GPU instance type in spawner page
    When I click on PrimeHub icon
    Then I am on the PrimeHub console "Home" page
    And I choose group with name "e2e-test-group-display-name"
    When I choose "Notebooks" in sidebar menu
    Then I am on the PrimeHub console "Notebooks" page
    When I get the iframe object
    And I go to the spawner page
    #Then I "should" see instance types block contains "e2e-test-instance-type-display-name-gpu" instanceType with "e2e-test-description-gpu" description and tooltip to show "CPU: 1 / Memory: 1G / GPU: 1"
    When I choose "Logout" in top-right menu
    Then I am on login page
