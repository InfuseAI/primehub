@released
Feature: Admin
  In order to manage images
  I want to change settings

  Scenario: Create image and connect to existing group
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
    And I type "test-image-display-name" to element with test-id "image/displayName"
    And I type "test-description" to element with test-id "image/description"
    And I type "jupyter/datascience-notebook:b90cce83f37b" to element with xpath "//div[@data-testid='image/url']//input"
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
    When I choose "Logout" in top-right menu
    Then I am on login page

  @normal-user
  Scenario: Create group image
    Given I go to login page
    When I fill in the correct username credentials
    And I click login
    Then I am on the PrimeHub console "Home" page
    And I choose group with name "e2e-test-group-display-name"
    When I choose "Images" in sidebar menu
    Then I am on the PrimeHub console "Images" page
    When I click "New Image" button
    Then I am on the PrimeHub console "NewImage" page
    When I type "test-group-image" to "displayName" text field
    And I type "test-group-image-description" to "description" text field
    And I type "jupyter/datascience-notebook:b90cce83f37b" to "url" text field
    And I click "Create" button
    Then I "should" see element with xpath "//a[text()='test-group-image']"
    When I click on PrimeHub icon
    Then I am on the PrimeHub console "Home" page
    And I choose group with name "e2e-test-group-display-name"
    When I choose "Notebooks" in sidebar menu
    Then I am on the PrimeHub console "Notebooks" page
    When I get the iframe object
    And I go to the spawner page
    Then I "should" see images block contains "test-group-image" image with "Group / Universal" type and "test-group-image-description" description
    When I choose "Logout" in top-right menu
    Then I am on login page

  @daily
  Scenario: Create error image and connect to existing group
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
    When I type "error-image" to element with test-id "image/name"
    When I type "error-url" to element with xpath "//div[@data-testid='image/url']//input"
    And I click element with test-id "connect-button"
    And I wait for 4.0 seconds
    And I search "e2e-test-group" in test-id "text-filter-name"
    And I click element with xpath "//td[contains(text(), 'e2e-test-group')]/..//input"
    And I click element with xpath "//button/span[text()='OK']"
    And I wait for 4.0 seconds
    And I click element with xpath "//a/span[text()='Confirm']"
    And I wait for 2.0 seconds
    And I search "error-image" in test-id "text-filter-name"
    Then list-view table "should" contain row with "error-image"
    When I choose "Logout" in top-right menu
    Then I am on login page

  @weekly
  Scenario: Create GPU image
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
    When I type "test-image-gpu" to element with test-id "image/name"
    And I click element with xpath "//a/span[text()='Confirm']"
    And I wait for 2.0 seconds
    And I search "test-image-gpu" in test-id "text-filter-name"
    Then list-view table "should" contain row with "test-image-gpu"
    When I choose "Logout" in top-right menu
    Then I am on login page

  @weekly
  Scenario: Update GPU image and connect to existing group
    Given I go to login page
    When I fill in the correct username credentials
    And I click login
    Then I am on the PrimeHub console "Home" page
    When I choose "Admin Portal" in top-right menu
    Then I am on the admin dashboard "Groups" page
    When I click "Images" in admin dashboard
    Then I am on the admin dashboard "Images" page
    When I search "test-image-gpu" in test-id "text-filter-name"
    And I click edit-button in row contains text "test-image-gpu"
    Then I should see input in test-id "image/name" with value "test-image-gpu"
    And I should see input in test-id "image/displayName" with value "test-image-gpu"
    When I type "test-image-gpu-display-name" to element with test-id "image/displayName"
    And I type "test-description-gpu" to element with test-id "image/description"
    And I click element with xpath "//div[@data-testid='image/type']//i"
    And I click element with xpath "//li[text()='gpu']"
    And I type "infuseai/docker-stacks:base-notebook-2d701645-gpu" to element with xpath "//div[@data-testid='image/url']//input"
    And I click element with test-id "connect-button"
    And I wait for 4.0 seconds
    And I search "e2e-test-group" in test-id "text-filter-name"
    And I click element with xpath "//td[contains(text(), 'e2e-test-group')]/..//input"
    And I click element with xpath "//button/span[text()='OK']"
    And I wait for 4.0 seconds
    And I click element with xpath "//a/span[text()='Confirm']"
    And I wait for 2.0 seconds
    And I search "test-image-gpu" in test-id "text-filter-name"
    Then list-view table "should" contain row with "test-image-gpu"
    When I click edit-button in row contains text "test-image-gpu"
    Then I should see input in test-id "image/name" with value "test-image-gpu"
    And I should see input in test-id "image/displayName" with value "test-image-gpu-display-name"
    When I click on PrimeHub icon
    Then I am on the PrimeHub console "Home" page
    And I choose group with name "e2e-test-group-display-name"
    When I choose "Notebooks" in sidebar menu
    Then I am on the PrimeHub console "Notebooks" page
    When I get the iframe object
    And I go to the spawner page
    Then I "should" see images block contains "test-image-gpu-display-name" image with "System / GPU" type and "test-description-gpu" description
    When I choose "Logout" in top-right menu
    Then I am on login page
