@ee
Feature: Delete data
  Delete some created resources

  Background:
    Given I am logged in
    Then I am on the PrimeHub console "Home" page

    When I choose "Admin Portal" in top-right menu
    Then I am on the admin portal "Groups" page

  @regression @admin-users @destroy-data
  Scenario: Delete users
    When I click "Users" in admin portal
    Then I am on the admin portal "Users" page

    When I search "e2e-test-user" in test-id "text-filter-username"
    And I delete a row with text "e2e-test-user"
    And I wait for 2.0 seconds
    Then I "should not" see list-view table containing row with "e2e-test-user"

    When I click refresh
    And I search "e2e-test-user" in test-id "text-filter-username"
    Then I "should not" see list-view table containing row with "e2e-test-user"

    When I search "e2e-test-another-user" in test-id "text-filter-username"
    And I delete a row with text "e2e-test-another-user"
    And I wait for 2.0 seconds
    Then I "should not" see list-view table containing row with "e2e-test-another-user"

    When I click refresh
    And I search "e2e-test-another-user" in test-id "text-filter-username"
    Then I "should not" see list-view table containing row with "e2e-test-another-user"

  @regression @admin-images @destroy-data
  Scenario: Delete images
    When I click "Images" in admin portal
    Then I am on the admin portal "Images" page

    When I search "e2e-test-image" in test-id "text-filter"
    And I delete a row with text "e2e-test-image"
    And I wait for 3.0 seconds
    Then I "should not" see list-view table containing row with "e2e-test-image"

    When I click refresh
    And I search "e2e-test-image" in test-id "text-filter"
    Then I "should not" see list-view table containing row with "e2e-test-image"

    When I search "e2e-test-bs-image" in test-id "text-filter"
    And I delete a row with text "e2e-test-bs-image"
    And I wait for 3.0 seconds
    Then I "should not" see list-view table containing row with "e2e-test-bs-image"

    When I click refresh
    And I search "e2e-test-bs-image" in test-id "text-filter"
    Then I "should not" see list-view table containing row with "e2e-test-bs-image"

    When I search "e2e-test-error-image" in test-id "text-filter"
    And I delete a row with text "e2e-test-error-image"
    And I wait for 3.0 seconds
    Then I "should not" see list-view table containing row with "e2e-test-error-image"

    When I click refresh
    And I search "e2e-test-error-image" in test-id "text-filter"
    Then I "should not" see list-view table containing row with "e2e-test-error-image"

  @regression @admin-images @destroy-data
  Scenario: Delete GPU images
    When I click "Images" in admin portal
    Then I am on the admin portal "Images" page

    When I search "e2e-test-image-gpu" in test-id "text-filter"
    And I delete a row with text "e2e-test-image-gpu"
    And I wait for 3.0 seconds
    Then I "should not" see list-view table containing row with "e2e-test-image-gpu"

    When I click refresh
    And I search "e2e-test-image-gpu" in test-id "text-filter"
    Then I "should not" see list-view table containing row with "e2e-test-image-gpu"

  @regression @admin-instance-types @destroy-data
  Scenario: Delete instance types
    When I click "Instance Types" in admin portal
    Then I am on the admin portal "Instance Types" page

    When I search "e2e-test-instance-type" in test-id "text-filter"
    And I delete a row with text "e2e-test-instance-type"
    And I wait for 2.0 seconds
    Then I "should not" see list-view table containing row with "e2e-test-instance-type"

  @regression @admin-instance-types @destroy-data
  Scenario: Delete GPU instance types
    When I click "Instance Types" in admin portal
    Then I am on the admin portal "Instance Types" page

    When I search "e2e-test-instance-type-gpu" in test-id "text-filter"
    And I delete a row with text "e2e-test-instance-type-gpu"
    And I wait for 2.0 seconds
    Then I "should not" see list-view table containing row with "e2e-test-instance-type-gpu"

  @regression @admin-instance-types @destroy-data @error-check
  Scenario: Delete instance type that exceeds resource quota
    When I click "Instance Types" in admin portal
    Then I am on the admin portal "Instance Types" page

    When I search "e2e-test-instance-type-large" in test-id "text-filter"
    And I delete a row with text "e2e-test-instance-type-large"
    And I wait for 2.0 seconds
    Then I "should not" see list-view table containing row with "e2e-test-instance-type-large"

  @regression @admin-groups @destroy-data
  Scenario: Delete groups
    When I click "Groups" in admin portal
    Then I am on the admin portal "Groups" page

    When I search "e2e-test-group" in test-id "text-filter-name"
    And I delete a row with text "e2e-test-group"
    And I wait for 1.0 second
    And I click refresh
    And I search "e2e-test-group" in test-id "text-filter-name"
    Then I "should not" see list-view table containing row with "e2e-test-group"

    When I search "e2e-test-another-group" in test-id "text-filter-name"
    And I delete a row with text "e2e-test-another-group"
    And I wait for 1.0 second
    And I click refresh
    And I search "e2e-test-another-group" in test-id "text-filter-name"
    Then I "should not" see list-view table containing row with "e2e-test-another-group"
