@admin-users @ee @ce @deploy
Feature: Admin - Users
  In order to manage users
  I want to change settings

  Background:
    Given I am logged in
    Then I am on the PrimeHub console "Home" page

    When I choose "Admin Portal" in top-right menu
    Then I am on the admin dashboard "Groups" page

    When I click "Users" in admin dashboard
    Then I am on the admin dashboard "Users" page
    And I should see element with test-id "user"

  @regression @sanity @prep-data
  Scenario: Create a normal user
    When I click element with test-id "add-button"
    Then I should see element with test-id on the page
    | test-id        |
    | user/username  |
    | user/email     |
    | user/sendEmail |

    When I type "e2e-test-user" to element with test-id "user/username"
    And I click element with xpath "//button/span[text()='Confirm']"
    Then I "should" see element with xpath "//span[text()='Users']"

    When I search "e2e-test-user" in test-id "text-filter-username"
    And I click edit-button in row contains text "e2e-test-user"
    Then I should see input in test-id "user/username" with value "e2e-test-user"

  @regression @sanity @prep-data
  Scenario: Update password for a normal user
    When I search "e2e-test-user" in test-id "text-filter-username"
    And I click edit-button in row contains text "e2e-test-user"
    Then I should see input in test-id "user/username" with value "e2e-test-user"

    When I click element with xpath "//div[@role='tab']//span[text()='Reset Password']"
    Then I should see element with test-id "reset-password-reset-button" 

    When I type "password" to "password" text field
    And I type "password" to "confirm" text field
    And I click element with test-id "reset-password-reset-button"
    Then I "should" see element with xpath "//span[text()='Users']"

  @regression @prep-data
  Scenario: Create another normal user
    When I click element with test-id "add-button"
    Then I should see element with test-id on the page
    | test-id        |
    | user/username  |
    | user/email     |
    | user/sendEmail |

    When I type "e2e-test-another-user" to element with test-id "user/username"
    And I click element with xpath "//button/span[text()='Confirm']"
    Then I "should" see element with xpath "//span[text()='Is Admin']"

    When I search "e2e-test-another-user" in test-id "text-filter-username"
    And I click edit-button in row contains text "e2e-test-another-user"
    Then I should see input in test-id "user/username" with value "e2e-test-another-user"

  @regression @prep-data
  Scenario: Update password for another normal user
    When I search "e2e-test-another-user" in test-id "text-filter-username"
    And I click edit-button in row contains text "e2e-test-another-user"
    Then I should see input in test-id "user/username" with value "e2e-test-another-user"

    When I click element with xpath "//div[@role='tab']//span[text()='Reset Password']"
    Then I should see element with test-id "reset-password-reset-button" 

    When I type "password" to "password" text field
    And I type "password" to "confirm" text field
    And I click element with test-id "reset-password-reset-button"
    Then I "should" see element with xpath "//span[text()='Is Admin']"

  @regression @error-check
  Scenario: User can see expected results when no group is available
    When I choose "Logout" in top-right menu
    Then I am on login page

    When I go to login page
    And I fill in the username "e2e-test-user" and password "password"
    And I click login
    Then I should see element with xpath on the page 
    | exist      | xpath                                                                                                         |
    | should not | //div[@class='ant-layout-sider-children']//span[text()='Home']                                                |
    | should not | //div[@class='ant-layout-sider-children']//span[text()='Notebooks']                                           |
    | should not | //div[@class='ant-layout-sider-children']//span[text()='Jobs']                                                |
    | should not | //div[@class='ant-layout-sider-children']//span[text()='Schedule']                                            |
    | should not | //div[@class='ant-layout-sider-children']//span[text()='Models']                                              |
    | should     | //span[@class='ant-alert-message' and text()='No group is available']                                         |
    | should     | //span[@class='ant-alert-description' and text()='Please contact your administrator to be added to a group.'] |
    | should     | //div[@class='ant-select-selection-selected-value' and text()='None']                                         |

  @regression @prep-data
  Scenario: Update user info of first user and connect to existing group
    When I search "e2e-test-user" in test-id "text-filter-username"
    And I click edit-button in row contains text "e2e-test-user"
    Then I should see input in test-id "user/username" with value "e2e-test-user"

    When I type "e2e-test" to element with test-id "user/firstName"
    And I check boolean input with test-id "user/isAdmin"
    And I click element with test-id "connect-button"
    And I wait for 4.0 seconds
    And I search "e2e-test-group" in test-id "text-filter-name"
    And I click element with xpath on the page
    | xpath                                              |
    | //td[contains(text(), 'e2e-test-group')]/..//input |
    | //button/span[text()='OK']                         |

    And I wait for 4.0 seconds
    And I click element with xpath "//button/span[text()='Confirm']"
    And I wait for 2.0 seconds
    And I search "e2e-test-user" in test-id "text-filter-username"
    Then list-view table "should" contain row with "e2e-test-user"

    When I click edit-button in row contains text "e2e-test-user"
    Then I should see value of element with test-id on the page
    | test-id        | value               |
    | user/username  | e2e-test-user |
    | user/firstName | e2e-test            |

    And boolean input with test-id "user/isAdmin" should have value "true"

    When I click "Groups" in admin dashboard
    Then I am on the admin dashboard "Groups" page

    When I search "e2e-test-group" in test-id "text-filter-name"
    And I click edit-button in row contains text "e2e-test-group"
    Then I "should" see element with xpath "//td[contains(text(), 'e2e-test-user')]"

  @regression @prep-data
  Scenario: Update user info of second user and connect to another group
    When I search "e2e-test-another-user" in test-id "text-filter-username"
    And I click edit-button in row contains text "e2e-test-another-user"
    Then I should see input in test-id "user/username" with value "e2e-test-another-user"

    When I type "another test" to element with test-id "user/firstName"
    And I click element with test-id "connect-button"
    And I wait for 4.0 seconds
    And I search "e2e-test-another-group" in test-id "text-filter-name"
    And I click element with xpath on the page
    | xpath                                                      |
    | //td[contains(text(), 'e2e-test-another-group')]/..//input |
    | //button/span[text()='OK']                                 |

    And I wait for 2.0 seconds
    And I click element with xpath "//button/span[text()='Confirm']"
    Then I "should" see element with xpath "//span[text()='Is Admin']"

  @regression
  Scenario: Remove myself from group admin and switch my role to normal user
    When I click "Groups" in admin dashboard
    Then I am on the admin dashboard "Groups" page
    And I should see element with test-id "group"

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
