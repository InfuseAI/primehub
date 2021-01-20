@released
Feature: Admin
  In order to manage users
  I want to change settings

  @admin-user @daily
  Scenario: Create user
    Given I go to login page
    When I fill in the correct username credentials
    And I click login
    Then I am on the PrimeHub console "Home" page
    When I choose "Admin Portal" in top-right menu
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
    And I click edit-button in row contains text "test-user"
    Then I should see input in test-id "user/username" with value "test-user"
    When I click tab of "Reset Password"
    And I type "password" to "password" text field
    And I type "password" to "confirm" text field
    And I click element with test-id "reset-password-reset-button"
    When I choose "Logout" in top-right menu
    Then I am on login page

  @admin-user @daily
  Scenario: User can see expected results when no group is available
    Given I go to login page
    When I fill in the username "test-user" and password "password"
    And I click login
    #Then I am on the PrimeHub console "Home" page
    And I "should" see element with xpath "//div[@class='ant-layout-sider-children']//span[text()='Home']"
    And I "should not" see element with xpath "//div[@class='ant-layout-sider-children']//span[text()='Notebooks']"
    And I "should not" see element with xpath "//div[@class='ant-layout-sider-children']//span[text()='Jobs']"
    And I "should not" see element with xpath "//div[@class='ant-layout-sider-children']//span[text()='Schedule']"
    And I "should not" see element with xpath "//div[@class='ant-layout-sider-children']//span[text()='Models']"
    And I "should" see element with xpath "//span[@class='ant-alert-message' and text()='No group is available']"
    And I "should" see element with xpath "//span[@class='ant-alert-description' and text()='Please contact your administrator to be added to a group.']"
    And I "should" see element with xpath "//div[@class='ant-select-selection-selected-value' and text()='None']"
    When I choose "Logout" in top-right menu
    Then I am on login page

  @admin-user @daily
  Scenario: Update user info and connect to existing group
    Given I go to login page
    When I fill in the correct username credentials
    And I click login
    Then I am on the PrimeHub console "Home" page
    When I choose "Admin Portal" in top-right menu
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
    When I choose "Logout" in top-right menu
    Then I am on login page

  @admin-user @daily
  Scenario: Delete user
    Given I go to login page
    When I fill in the correct username credentials
    And I click login
    Then I am on the PrimeHub console "Home" page
    When I choose "Admin Portal" in top-right menu
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
    When I choose "Logout" in top-right menu
    Then I am on login page

  @normal-user
  Scenario: Remove myself from group admin and switch my role to normal user
    Given I go to login page
    When I fill in the correct username credentials
    And I click login
    Then I am on the PrimeHub console "Home" page
    When I choose "Admin Portal" in top-right menu
    Then I am on the admin dashboard "Groups" page
    When I search "e2e-test-group" in test-id "text-filter-name"
    And I click edit-button in row contains text "e2e-test-group"
    Then I "should" see element with xpath "//table//span[@class='ant-checkbox ant-checkbox-checked']"
    # checkbox of group admin
    When I click element with xpath "//table//input"
    And I click element with test-id "confirm-button"
    And I wait for 2.0 seconds
    And I search "e2e-test-group" in test-id "text-filter-name"
    Then list-view table "should" contain row with "e2e-test-group"
    When I click edit-button in row contains text "e2e-test-group"
    Then I "should" see element with xpath "//table//span[@class='ant-checkbox']"
    When I click "Users" in admin dashboard
    Then I am on the admin dashboard "Users" page
    When I click element with test-id "edit-button"
    Then I "should" see element with xpath "//div[@data-testid='user/isAdmin']"
    When I check boolean input with test-id "user/isAdmin"
    And I click element with xpath "//button/span[text()='Confirm']"
    And I wait for 2.0 seconds
    When I click element with test-id "edit-button"
    Then boolean input with test-id "user/isAdmin" should have value "false"
    When I choose "Logout" in top-right menu
    Then I am on login page
