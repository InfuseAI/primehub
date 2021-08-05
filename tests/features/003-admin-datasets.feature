@admin-datasets @ee @ce
Feature: Admin - Datasets
  In order to manage datasets
  I want to change settings
  
  Background:
    Given I am logged in
    Then I am on the PrimeHub console "Home" page
    When I choose "Admin Portal" in top-right menu
    Then I am on the admin dashboard "Groups" page

    When I click "Datasets" in admin dashboard
    Then I am on the admin dashboard "Datasets" page
    And I should see element with test-id "dataset"

  @regression @sanity @smoke
  Scenario: Create dataset
    When I click element with test-id "add-button"
    Then I should see element with test-id "dataset/name"
    And I should see element with test-id "dataset/displayName"
    When I type "e2e-test-dataset" to element with test-id "dataset/name"
    When I type valid info to test-id on the page
    | fields       | values           |
    | dataset/name | e2e-test-dataset |

    And I select option "Env" in admin dashboard
    And I click element with test-id "confirm-button"
    And I wait for 2.0 seconds
    And I search "e2e-test-dataset" in test-id "text-filter-name"
    Then list-view table "should" contain row with "e2e-test-dataset"

    When I wait for 1.0 second
    And I choose "Logout" in top-right menu
    Then I am on login page

  @regression
  Scenario: Update a dataset
    When I search "e2e-test-dataset" in test-id "text-filter-name"
    And I click edit-button in row contains text "e2e-test-dataset"
    Then I should see input in test-id "dataset/name" with value "e2e-test-dataset"
    And I should see input in test-id "dataset/displayName" with value "e2e-test-dataset"
    When I type valid info to test-id on the page
    | fields              | values                        |
    | dataset/displayName | e2e-test-dataset-display-name |

    And I click element with test-id "confirm-button"

    When I wait for 1.0 second
    And I choose "Logout" in top-right menu
    Then I am on login page

  @regression
  Scenario: Connect a dataset to an existing group
    When I search "e2e-test-dataset" in test-id "text-filter-name"
    And I click edit-button in row contains text "e2e-test-dataset"
    Then I should see input in test-id "dataset/name" with value "e2e-test-dataset"
    And I should see input in test-id "dataset/displayName" with value "e2e-test-dataset-display-name"
    And I click element with test-id "connect-button"
    And I wait for 2.0 seconds
    And I search "e2e-test-group" in test-id "text-filter-name"
    And I click element with xpath on the page
    | fields                                             |
    | //td[contains(text(), 'e2e-test-group')]/..//input |
    | //button/span[text()='OK']                         |

    And I wait for 2.0 seconds
    And I click element with test-id "confirm-button"
    And I search "e2e-test-dataset" in test-id "text-filter-name"
    Then list-view table "should" contain row with "e2e-test-dataset"

    When I wait for 1.0 second
    And I choose "Logout" in top-right menu
    Then I am on login page

  @regression
  Scenario: Show a dataset in spawner page
    When I click on PrimeHub icon
    Then I am on the PrimeHub console "Home" page
    And I choose group with name "e2e-test-group-display-name"
    When I choose "Notebooks" in sidebar menu
    Then I am on the PrimeHub console "Notebooks" page
    When I get the iframe object
    And I go to the spawner page
    Then I "should" see element with xpath "//div[@id='dataset-list']//li[contains(text(), 'e2e-test-dataset-display-name')]" in hub

    When I wait for 1.0 second
    And I choose "Logout" in top-right menu
    Then I am on login page

  @regression
  Scenario: Delete a dataset
    When I search "e2e-test-dataset" in test-id "text-filter-name"
    And I delete a row with text "e2e-test-dataset"
    And I wait for 2.0 seconds
    When I click refresh
    And I search "e2e-test-dataset" in test-id "text-filter-name"
    Then list-view table "should not" contain row with "e2e-test-dataset" 

    When I wait for 1.0 second
    And I choose "Logout" in top-right menu
    Then I am on login page

  @regression
  Scenario: Do not show a deleted dataset in spawner page
    When I click on PrimeHub icon
    Then I am on the PrimeHub console "Home" page
    And I choose group with name "e2e-test-group-display-name"
    When I choose "Notebooks" in sidebar menu
    Then I am on the PrimeHub console "Notebooks" page
    When I get the iframe object
    And I go to the spawner page
    Then I "should not" see element with xpath "//div[@id='dataset-list']//li[contains(text(), 'e2e-test-dataset-display-name')]" in hub

    When I wait for 1.0 second
    And I choose "Logout" in top-right menu
    Then I am on login page
