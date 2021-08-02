@ee
Feature: Delete data
  Delete some created resources

  Background:
    Given I am logged in
    Then I am on the PrimeHub console "Home" page
    When I choose "Admin Portal" in top-right menu
    Then I am on the admin dashboard "Groups" page

  @regression @admin-users @destroy-data
  Scenario: Delete users
    When I click "Users" in admin dashboard
    Then I am on the admin dashboard "Users" page
    When I search "e2e-test-group-user" in test-id "text-filter-username"
    And I delete a row with text "e2e-test-group-user"
    And I wait for 2.0 seconds
    Then list-view table "should not" contain row with "e2e-test-group-user"
    When I click refresh
    And I search "e2e-test-group-user" in test-id "text-filter-username"
    Then list-view table "should not" contain row with "e2e-test-group-user"
    When I search "e2e-test-another-user" in test-id "text-filter-username"
    And I delete a row with text "e2e-test-another-user"
    And I wait for 2.0 seconds
    Then list-view table "should not" contain row with "e2e-test-another-user"
    When I click refresh
    And I search "e2e-test-another-user" in test-id "text-filter-username"
    Then list-view table "should not" contain row with "e2e-test-another-user"
    When I choose "Logout" in top-right menu
    Then I am on login page

  @regression @admin-images @destroy-data
  Scenario: Delete images
    When I click "Images" in admin dashboard
    Then I am on the admin dashboard "Images" page
    When I search "e2e-test-image" in test-id "text-filter-name"
    And I delete a row with text "e2e-test-image"
    And I wait for 2.0 seconds
    Then list-view table "should not" contain row with "e2e-test-image"
    When I click refresh
    And I search "e2e-test-image" in test-id "text-filter-name"
    Then list-view table "should not" contain row with "e2e-test-image"
    When I search "e2e-test-bs-image" in test-id "text-filter-name"
    And I delete a row with text "e2e-test-bs-image"
    And I wait for 2.0 seconds
    Then list-view table "should not" contain row with "e2e-test-bs-image"
    When I click refresh
    And I search "e2e-test-bs-image" in test-id "text-filter-name"
    Then list-view table "should not" contain row with "e2e-test-bs-image"
    When I search "e2e-error-image" in test-id "text-filter-name"
    And I delete a row with text "e2e-error-image"
    And I wait for 2.0 seconds
    Then list-view table "should not" contain row with "e2e-error-image"
    When I click refresh
    And I search "e2e-error-image" in test-id "text-filter-name"
    Then list-view table "should not" contain row with "e2e-error-image"
    And I wait for 1.0 seconds
    When I choose "Logout" in top-right menu
    Then I am on login page

  @regression @admin-images @destroy-data
  Scenario: Delete GPU images
    When I click "Images" in admin dashboard
    Then I am on the admin dashboard "Images" page
    When I search "e2e-test-image-gpu" in test-id "text-filter-name"
    And I delete a row with text "e2e-test-image-gpu"
    And I wait for 2.0 seconds
    Then list-view table "should not" contain row with "e2e-test-image-gpu"
    When I click refresh
    And I search "e2e-test-image-gpu" in test-id "text-filter-name"
    Then list-view table "should not" contain row with "e2e-test-image-gpu"
    And I wait for 1.0 second
    When I choose "Logout" in top-right menu
    Then I am on login page

  @regression @admin-instance-types @destroy-data
  Scenario: Delete instance types
    When I click "Instance Types" in admin dashboard
    Then I am on the admin dashboard "Instance Types" page
    When I search "e2e-test-instance-type" in test-id "text-filter-name"
    And I delete a row with text "e2e-test-instance-type"
    And I wait for 2.0 seconds
    Then list-view table "should not" contain row with "e2e-test-instance-type"
    And I wait for 1.0 second
    When I choose "Logout" in top-right menu
    Then I am on login page

  @regression @admin-instance-types @destroy-data
  Scenario: Delete GPU instance types
    When I click "Instance Types" in admin dashboard
    Then I am on the admin dashboard "Instance Types" page
    When I search "e2e-test-instance-type-gpu" in test-id "text-filter-name"
    And I delete a row with text "e2e-test-instance-type-gpu"
    And I wait for 2.0 seconds
    Then list-view table "should not" contain row with "e2e-test-instance-type-gpu"
    And I wait for 1.0 second
    When I choose "Logout" in top-right menu
    Then I am on login page

  @regression @admin-groups @destroy-data
  Scenario: Delete groups
    When I click "Groups" in admin dashboard
    Then I am on the admin dashboard "Groups" page
    When I search "e2e-test-group" in test-id "text-filter-name"
    And I delete a row with text "e2e-test-group"
    And I search "e2e-test-another-group" in test-id "text-filter-name"
    And I delete a row with text "e2e-test-another-group"
    And I wait for 1.0 second
    And I click refresh
    And I search "e2e-test-group" in test-id "text-filter-name"
    Then list-view table "should not" contain row with "e2e-test-group"
    And I search "e2e-test-another-group" in test-id "text-filter-name"
    Then list-view table "should not" contain row with "e2e-test-another-group"
    When I choose "Logout" in top-right menu
    Then I am on login page
