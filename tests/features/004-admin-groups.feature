@released
Feature: Admin
  In order to manage groups
  I want to change settings

  Scenario: Create group
    Given I go to login page
    When I fill in the correct username credentials
    And I click login
    Then I am on the landing page
    When I click "Admin Dashboard" image in landing page
    Then I am on the admin dashboard "Groups" page
    And I should see element with test-id "group"
    When I click element with test-id "add-button"
    Then I should see element with test-id "group/name"
    And I should see element with test-id "group/displayName"
    When I type "e2e-test-group" to element with test-id "group/name"
    And I click element with xpath "//a/span[text()='Confirm']"
    And I wait for 2.0 seconds
    And I search "e2e-test-group" in test-id "text-filter-name"
    Then list-view table "should" contain row with "e2e-test-group"
    When I logout from banner UI
    Then I am on login page

  Scenario: Update group and connect to existing user
    Given I go to login page
    When I fill in the correct username credentials
    And I click login
    Then I am on the landing page
    When I click "Admin Dashboard" image in landing page
    Then I am on the admin dashboard "Groups" page
    When I search "e2e-test-group" in test-id "text-filter-name"
    And I click edit-button in row contains text "e2e-test-group"
    Then I should see input in test-id "group/name" with value "e2e-test-group"
    When I type "e2e-test-group-display-name" to element with test-id "group/displayName"
    And I type "1" to element with xpath "//div[@data-testid='group/quotaCpu']//input[@class='ant-input-number-input']"
    And I type "1" to element with xpath "//div[@data-testid='group/quotaGpu']//input[@class='ant-input-number-input']"
    And I click element with xpath "//div[@data-testid='group/quotaMemory']//input[@class='ant-checkbox-input']"
    And I type "2" to element with xpath "//div[@data-testid='group/quotaMemory']//input[@class='ant-input-number-input']"
    And I click element with xpath "//div[@data-testid='group/projectQuotaCpu']//input[@class='ant-checkbox-input']"
    And I type "2" to element with xpath "//div[@data-testid='group/projectQuotaCpu']//input[@class='ant-input-number-input']"
    And I click element with xpath "//div[@data-testid='group/projectQuotaGpu']//input[@class='ant-checkbox-input']"
    And I type "2" to element with xpath "//div[@data-testid='group/projectQuotaGpu']//input[@class='ant-input-number-input']"
    And I click element with xpath "//div[@data-testid='group/projectQuotaMemory']//input[@class='ant-checkbox-input']"
    And I type "4" to element with xpath "//div[@data-testid='group/projectQuotaMemory']//input[@class='ant-input-number-input']"
    And I click element with test-id "connect-button"
    And I wait for 4.0 seconds
    And I search my username in name filter
    And I click my username
    And I click element with xpath "//button/span[text()='OK']"
    And I wait for 4.0 seconds
    And I click element with xpath "//a/span[text()='Confirm']"
    And I wait for 2.0 seconds
    And I search "e2e-test-group" in test-id "text-filter-name"
    Then list-view table "should" contain row with "e2e-test-group"
    When I click edit-button in row contains text "e2e-test-group"
    Then I should see input in test-id "group/name" with value "e2e-test-group"
    And I should see input in test-id "group/displayName" with value "e2e-test-group-display-name"
    When I logout from banner UI
    Then I am on login page
    When I fill in the correct username credentials
    And I click login
    Then I am on the landing page
    When I click "JupyterHub" image in landing page
    Then I am on the spawner page
    When I choose group with name "e2e-test-group"
    And I wait for 2.0 seconds
    Then I can see the user limits are "1", "2 GB", and "1"
    And I can see the group resource limits are "2", "4GB", and "2"
    When I logout on JupyterHub page
    Then I can logout from JupyterHub
