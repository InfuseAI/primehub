@released
Feature: Admin
  In order to manage datasets
  I want to change settings
  
  Scenario: Create dataset
    Given I go to login page
    When I fill in the correct username credentials
    And I click login
    Then I am on the landing page
    When I click "Admin Dashboard" image in landing page
    Then I am on the admin dashboard "System" page
    When I click "Datasets" in admin dashboard
    Then I am on the admin dashboard "Datasets" page
    And I should see element with test-id "dataset"
    When I click element with test-id "add-button"
    Then I should see element with test-id "dataset/name"
    And I should see element with test-id "dataset/displayName"
    When I type "test-dataset" to element with test-id "dataset/name"
    And I select option "env" in admin dashboard
    And I click element with test-id "confirm-button"
    And I wait for 2.0 seconds
    And I search "test-dataset" in test-id "text-filter-name"
    Then list-view table "should" contain row with "test-dataset"
    When I logout from banner UI
    Then I am on login page

  Scenario: Update dataset and connect to existing group
    Given I go to login page
    When I fill in the correct username credentials
    And I click login
    Then I am on the landing page
    When I click "Admin Dashboard" image in landing page
    Then I am on the admin dashboard "System" page
    When I click "Datasets" in admin dashboard
    Then I am on the admin dashboard "Datasets" page
    When I search "test-dataset" in test-id "text-filter-name"
    And I click edit-button in row contains text "test-dataset"
    Then I should see input in test-id "dataset/name" with value "test-dataset"
    And I should see input in test-id "dataset/displayName" with value "test-dataset"
    When I type "test-dataset-display-name" to element with test-id "dataset/displayName"
    And I click element with test-id "connect-button"
    And I wait for 4.0 seconds
    And I search "e2e-test-group" in test-id "text-filter-name"
    And I click element with xpath "//td[contains(text(), 'e2e-test-group')]/..//input"
    And I click element with xpath "//button/span[text()='OK']"
    And I wait for 4.0 seconds
    And I click element with test-id "confirm-button"
    And I wait for 2.0 seconds
    And I search "test-dataset" in test-id "text-filter-name"
    Then list-view table "should" contain row with "test-dataset"
    When I click edit-button in row contains text "test-dataset"
    Then I should see input in test-id "dataset/name" with value "test-dataset"
    And I should see input in test-id "dataset/displayName" with value "test-dataset-display-name"
    When I logout from banner UI
    Then I am on login page
    When I fill in the correct username credentials
    And I click login
    Then I am on the landing page
    When I click "JupyterHub" image in landing page
    Then I am on the spawner page
    When I choose group with name "e2e-test-group"
    And I click element with xpath "//a[@href='#dataset-list']"
    Then I "should" see element with xpath "//div[@aria-expanded='true']//li[contains(text(), 'test-dataset-display-name')]"
    When I logout on JupyterHub page
    Then I can logout from JupyterHub

  Scenario: Delete dataset
    Given I go to login page
    When I fill in the correct username credentials
    And I click login
    Then I am on the landing page
    When I click "Admin Dashboard" image in landing page
    Then I am on the admin dashboard "System" page
    When I click "Datasets" in admin dashboard
    Then I am on the admin dashboard "Datasets" page
    When I search "test-dataset" in test-id "text-filter-name"
    And I delete a row with text "test-dataset"
    And I wait for 2.0 seconds
    Then list-view table "should not" contain row with "test-dataset"
    When I click refresh
    And I search "test-dataset" in test-id "text-filter-name"
    Then list-view table "should not" contain row with "test-dataset" 
    When I logout from banner UI
    Then I am on login page
    When I fill in the correct username credentials
    And I click login
    Then I am on the landing page
    When I click "JupyterHub" image in landing page
    Then I am on the spawner page
    When I choose group with name "e2e-test-group"
    And I click element with xpath "//a[@href='#dataset-list']"
    Then I "should not" see element with xpath "//div[@aria-expanded='true']//li[contains(text(), 'test-dataset-display-name')]"
    When I logout on JupyterHub page
    Then I can logout from JupyterHub
