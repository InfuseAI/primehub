@admin-datasets @ee @ce
Feature: Admin - Datasets
  In order to manage datasets
  I want to change settings
  
  Background:
    Given I go to login page
    When I fill in the correct username credentials
    And I click login
    Then I am on the PrimeHub console "Home" page
    When I choose "Admin Portal" in top-right menu
    Then I am on the admin dashboard "Groups" page
    When I click "Datasets" in admin dashboard
    Then I am on the admin dashboard "Datasets" page

  @regression @sanity @smoke
  Scenario: Create dataset
    When I should see element with test-id "dataset"
    And I click element with test-id "add-button"
    Then I should see element with test-id "dataset/name"
    And I should see element with test-id "dataset/displayName"
    When I type "e2e-test-dataset" to element with test-id "dataset/name"
    And I select option "Env" in admin dashboard
    And I click element with test-id "confirm-button"
    And I wait for 2.0 seconds
    And I search "e2e-test-dataset" in test-id "text-filter-name"
    Then list-view table "should" contain row with "e2e-test-dataset"
    When I choose "Logout" in top-right menu
    Then I am on login page

  @regression
  Scenario: Update dataset and connect to existing group
    When I search "e2e-test-dataset" in test-id "text-filter-name"
    And I click edit-button in row contains text "e2e-test-dataset"
    Then I should see input in test-id "dataset/name" with value "e2e-test-dataset"
    And I should see input in test-id "dataset/displayName" with value "e2e-test-dataset"
    When I type "e2e-test-dataset-display-name" to element with test-id "dataset/displayName"
    And I click element with test-id "connect-button"
    And I wait for 4.0 seconds
    And I search "e2e-test-group" in test-id "text-filter-name"
    And I click element with xpath on the page
    | fields                                             |
    | //td[contains(text(), 'e2e-test-group')]/..//input |
    | //button/span[text()='OK']                         |

    And I wait for 4.0 seconds
    And I click element with test-id "confirm-button"
    And I wait for 2.0 seconds
    And I search "e2e-test-dataset" in test-id "text-filter-name"
    Then list-view table "should" contain row with "e2e-test-dataset"
    When I click edit-button in row contains text "e2e-test-dataset"
    Then I should see input in test-id "dataset/name" with value "e2e-test-dataset"
    And I should see input in test-id "dataset/displayName" with value "e2e-test-dataset-display-name"
    When I click on PrimeHub icon
    Then I am on the PrimeHub console "Home" page
    And I choose group with name "e2e-test-group-display-name"
    When I choose "Notebooks" in sidebar menu
    Then I am on the PrimeHub console "Notebooks" page
    When I get the iframe object
    And I go to the spawner page
    Then I "should" see element with xpath "//div[@id='dataset-list']//li[contains(text(), 'e2e-test-dataset-display-name')]" in hub
    When I choose "Logout" in top-right menu
    Then I am on login page

  @regression
  Scenario: Delete dataset
    When I search "e2e-test-dataset" in test-id "text-filter-name"
    And I delete a row with text "e2e-test-dataset"
    And I wait for 2.0 seconds
    Then list-view table "should not" contain row with "e2e-test-dataset"
    When I click refresh
    And I search "e2e-test-dataset" in test-id "text-filter-name"
    Then list-view table "should not" contain row with "e2e-test-dataset" 
    When I click on PrimeHub icon
    Then I am on the PrimeHub console "Home" page
    And I choose group with name "e2e-test-group-display-name"
    When I choose "Notebooks" in sidebar menu
    Then I am on the PrimeHub console "Notebooks" page
    When I get the iframe object
    And I go to the spawner page
    Then I "should not" see element with xpath "//div[@id='dataset-list']//li[contains(text(), 'e2e-test-dataset-display-name')]" in hub
    When I choose "Logout" in top-right menu
    Then I am on login page
