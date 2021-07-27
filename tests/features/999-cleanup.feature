@admin-user @ee
Feature: Delete data
  Delete some created resources

  Background:
    Given I am logged in
    Then I am on the PrimeHub console "Home" page
    When I choose "Admin Portal" in top-right menu
    Then I am on the admin dashboard "Groups" page

  @regression @destroy-data
  Scenario: Delete user
    When I click "Users" in admin dashboard
    Then I am on the admin dashboard "Users" page
    When I search "e2e-test-group-user" in test-id "text-filter-username"
    And I delete a row with text "e2e-test-group-user"
    And I wait for 2.0 seconds
    Then list-view table "should not" contain row with "e2e-test-group-user"
    When I click refresh
    And I search "e2e-test-group-user" in test-id "text-filter-username"
    Then list-view table "should not" contain row with "e2e-test-group-user"
    When I choose "Logout" in top-right menu
    Then I am on login page

  @regression @destroy-data
  Scenario: Delete image
    When I click "Images" in admin dashboard
    Then I am on the admin dashboard "Images" page
    When I search "test-image" in test-id "text-filter-name"
    And I delete a row with text "test-image"
    And I wait for 2.0 seconds
    Then list-view table "should not" contain row with "test-image"
    When I click refresh
    And I search "test-image" in test-id "text-filter-name"
    Then list-view table "should not" contain row with "test-image"
    When I search "test-bs-image" in test-id "text-filter-name"
    And I delete a row with text "test-bs-image"
    And I wait for 2.0 seconds
    Then list-view table "should not" contain row with "test-bs-image"
    When I click refresh
    And I search "test-bs-image" in test-id "text-filter-name"
    Then list-view table "should not" contain row with "test-bs-image"
    When I search "error-image" in test-id "text-filter-name"
    And I delete a row with text "error-image"
    And I wait for 2.0 seconds
    Then list-view table "should not" contain row with "error-image"
    When I click refresh
    And I search "error-image" in test-id "text-filter-name"
    Then list-view table "should not" contain row with "error-image"
    When I click on PrimeHub icon
    Then I am on the PrimeHub console "Home" page
    And I choose group with name "e2e-test-group-display-name"
    When I choose "Notebooks" in sidebar menu
    Then I am on the PrimeHub console "Notebooks" page
    When I get the iframe object
    And I go to the spawner page
    #Then I "should not" see images block contains "test-image-display-name" image with "System / Universal" type and "test-description" description
    When I choose "Logout" in top-right menu
    Then I am on login page

  @regression @destroy-data
  Scenario: Delete GPU image
    When I click "Images" in admin dashboard
    Then I am on the admin dashboard "Images" page
    When I search "test-image-gpu" in test-id "text-filter-name"
    And I delete a row with text "test-image-gpu"
    And I wait for 2.0 seconds
    Then list-view table "should not" contain row with "test-image-gpu"
    When I click refresh
    And I search "test-image-gpu" in test-id "text-filter-name"
    Then list-view table "should not" contain row with "test-image-gpu"
    When I click on PrimeHub icon
    Then I am on the PrimeHub console "Home" page
    And I choose group with name "e2e-test-group-display-name"
    When I choose "Notebooks" in sidebar menu
    Then I am on the PrimeHub console "Notebooks" page
    When I get the iframe object
    And I go to the spawner page
    #Then I "should not" see images block contains "test-image-gpu-display-name" image with "System / GPU" type and "test-description-gpu" description
    When I choose "Logout" in top-right menu
    Then I am on login page

  @regression @destroy-data
  Scenario: Delete instance type
    When I click "Instance Types" in admin dashboard
    Then I am on the admin dashboard "Instance Types" page
    When I search "test-instance-type" in test-id "text-filter-name"
    And I delete a row with text "test-instance-type"
    And I wait for 2.0 seconds
    Then list-view table "should not" contain row with "test-instance-type"
    When I click on PrimeHub icon
    Then I am on the PrimeHub console "Home" page
    And I choose group with name "e2e-test-group-display-name"
    When I choose "Notebooks" in sidebar menu
    Then I am on the PrimeHub console "Notebooks" page
    When I get the iframe object
    And I go to the spawner page
    Then I "should not" see instance types block contains "test-instance-type-display-name" instanceType with "test-description" description and tooltip to show "CPU: 0.5 / Memory: 1G / GPU: 0"
    When I choose "Logout" in top-right menu
    Then I am on login page

  @regression @destroy-data
  Scenario: Delete GPU instance type
    When I click "Instance Types" in admin dashboard
    Then I am on the admin dashboard "Instance Types" page
    When I search "test-instance-type-gpu" in test-id "text-filter-name"
    And I delete a row with text "test-instance-type-gpu"
    And I wait for 2.0 seconds
    Then list-view table "should not" contain row with "test-instance-type-gpu"
    When I click on PrimeHub icon
    Then I am on the PrimeHub console "Home" page
    And I choose group with name "e2e-test-group-display-name"
    When I choose "Notebooks" in sidebar menu
    Then I am on the PrimeHub console "Notebooks" page
    When I get the iframe object
    And I go to the spawner page
    Then I "should not" see instance types block contains "test-instance-type-gpu-display-name" instanceType with "test-description-gpu" description and tooltip to show "CPU: 1 / Memory: 1G / GPU: 1"
    When I choose "Logout" in top-right menu
    Then I am on login page

  @regression @destroy-data
  Scenario: Delete group
    When I click "Groups" in admin dashboard
    Then I am on the admin dashboard "Groups" page
    When I search "e2e-test-group" in test-id "text-filter-name"
    And I delete a row with text "e2e-test-group"
    And I wait for 2.0 seconds
    Then list-view table "should not" contain row with "e2e-test-group"
    When I click refresh
    And I search "e2e-test-group" in test-id "text-filter-name"
    Then list-view table "should not" contain row with "e2e-test-group" 
    When I choose "Logout" in top-right menu
    Then I am on login page
