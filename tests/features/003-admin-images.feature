@released
Feature: Admin
  In order to manage images
  I want to change settings
  
  Scenario: Create image
    Given I go to login page
    When I fill in the correct username credentials
    And I click login
    Then I am on the PrimeHub console "Home" page
    When I choose "Admin Portal" in top-right menu
    Then I am on the admin dashboard "Groups" page
    When I click "Images" in admin dashboard
    Then I am on the admin dashboard "Images" page
    And I should see element with test-id "image"
    When I click element with test-id "add-button"
    Then I should see element with test-id "image/name"
    And I should see element with test-id "image/displayName"
    When I type "test-image" to element with test-id "image/name"
    And I click element with xpath "//a/span[text()='Confirm']"
    And I wait for 2.0 seconds
    And I search "test-image" in test-id "text-filter-name"
    Then list-view table "should" contain row with "test-image"
    When I choose "Logout" in top-right menu
    Then I am on login page
  
  Scenario: Update image and connect to existing group
    Given I go to login page
    When I fill in the correct username credentials
    And I click login
    Then I am on the PrimeHub console "Home" page
    When I choose "Admin Portal" in top-right menu
    Then I am on the admin dashboard "Groups" page
    When I click "Images" in admin dashboard
    Then I am on the admin dashboard "Images" page
    When I search "test-image" in test-id "text-filter-name"
    And I click edit-button in row contains text "test-image"
    Then I should see input in test-id "image/name" with value "test-image"
    And I should see input in test-id "image/displayName" with value "test-image"
    When I type "test-image-display-name" to element with test-id "image/displayName"
    And I type "test-description" to element with test-id "image/description"
    And I type "jupyter/base-notebook:e255f1aa00b2" to element with xpath "//div[@data-testid='image/url']//input"
    And I click element with test-id "connect-button"
    And I wait for 4.0 seconds
    And I search "e2e-test-group" in test-id "text-filter-name"
    And I click element with xpath "//td[contains(text(), 'e2e-test-group')]/..//input"
    And I click element with xpath "//button/span[text()='OK']"
    And I wait for 4.0 seconds
    And I click element with xpath "//a/span[text()='Confirm']"
    And I wait for 2.0 seconds
    And I search "test-image" in test-id "text-filter-name"
    Then list-view table "should" contain row with "test-image"
    When I click edit-button in row contains text "test-image"
    Then I should see input in test-id "image/name" with value "test-image"
    And I should see input in test-id "image/displayName" with value "test-image-display-name"
    When I click on PrimeHub icon
    Then I am on the PrimeHub console "Home" page
    And I choose group with name "e2e-test-group-display-name"
    When I choose "JupyterHub" in sidebar menu
    Then I am on the PrimeHub console "JupyterHub" page
    When I go to the spawner page
    Then I "should" see images block contains "test-image-display-name" image with "Universal" type and "test-description" description
    When I choose "Logout" in top-right menu
    Then I am on login page
