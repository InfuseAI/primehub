@released
Feature: Admin
  In order to manage users
  I want to change settings
  
  Scenario: Create user
    Given I go to login page
    When I fill in the correct username credentials
    And I click login
    Then I am on the landing page
    When I click "Admin Dashboard" image in landing page
    Then I am on the admin dashboard "Groups" page
    When I click "Users" in admin dashboard
    Then I am on the admin dashboard "Users" page
    And I should see element with test-id "user"
    When I click element with test-id "add-button"
    Then I should see element with test-id "user/username"
    And I should see element with test-id "user/email"
    And I should see element with test-id "user/sendEmail"
    When I type "test-user" to element with test-id "user/username"
    And I click element with xpath "//button/span[text()='Confirm']"
    And I wait for 2.0 seconds
    And I search "test-user" in test-id "text-filter-username"
    Then list-view table "should" contain row with "test-user"
    When I logout from banner UI
    Then I am on login page
  
  Scenario: Update user info and connect to existing group
    Given I go to login page
    When I fill in the correct username credentials
    And I click login
    Then I am on the landing page
    When I click "Admin Dashboard" image in landing page
    Then I am on the admin dashboard "Groups" page
    When I click "Users" in admin dashboard
    Then I am on the admin dashboard "Users" page
    When I search "test-user" in test-id "text-filter-username"
    And I click edit-button in row contains text "test-user"
    Then I should see input in test-id "user/username" with value "test-user"
    When I type "test" to element with test-id "user/firstName"
    And I check boolean input with test-id "user/isAdmin"
    And I click element with test-id "connect-button"
    And I wait for 4.0 seconds
    And I search "e2e-test-group" in test-id "text-filter-name"
    And I click element with xpath "//td[contains(text(), 'e2e-test-group')]/..//input"
    And I click element with xpath "//button/span[text()='OK']"
    And I wait for 4.0 seconds
    And I click element with xpath "//button/span[text()='Confirm']"
    And I wait for 2.0 seconds
    And I search "test-user" in test-id "text-filter-username"
    Then list-view table "should" contain row with "test-user"
    When I click edit-button in row contains text "test-user"
    Then I should see input in test-id "user/username" with value "test-user"
    And I should see input in test-id "user/firstName" with value "test"
    And boolean input with test-id "user/isAdmin" should have value "true"
    When I click "Groups" in admin dashboard
    Then I am on the admin dashboard "Groups" page
    When I search "e2e-test-group" in test-id "text-filter-name"
    And I click edit-button in row contains text "e2e-test-group"
    Then I "should" see element with xpath "//td[contains(text(), 'test-user')]"
    When I logout from banner UI
    Then I am on login page
  
  Scenario: Delete user
    Given I go to login page
    When I fill in the correct username credentials
    And I click login
    Then I am on the landing page
    When I click "Admin Dashboard" image in landing page
    Then I am on the admin dashboard "Groups" page
    When I click "Users" in admin dashboard
    Then I am on the admin dashboard "Users" page
    When I search "test-user" in test-id "text-filter-username"
    And I delete a row with text "test-user"
    And I wait for 2.0 seconds
    Then list-view table "should not" contain row with "test-user"
    When I click refresh
    And I search "test-user" in test-id "text-filter-username"
    Then list-view table "should not" contain row with "test-user" 
    When I logout from banner UI
    Then I am on login page
