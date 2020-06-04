@released
Feature: Admin
  In order to manage instance types
  I want to change settings
  
  Scenario: Create instance type
    Given I go to login page
    When I fill in the correct username credentials
    And I click login
    Then I am on the landing page
    When I click "Admin Dashboard" image in landing page
    Then I am on the admin dashboard "System" page
    When I click "Instance Types" in admin dashboard
    Then I am on the admin dashboard "Instance Types" page
    And I should see element with test-id "instanceType"
    When I click element with test-id "add-button"
    Then I should see element with test-id "instanceType/name"
    And I should see element with test-id "instanceType/displayName"
    When I type "test-instance-type" to element with test-id "instanceType/name"
    And I click element with xpath "//a/span[text()='Confirm']"
    Then list-view table "should" contain row with "test-instance-type"
    When I logout from banner UI
    Then I am on login page
  
  Scenario: Update instance type and connect to existing group
    Given I go to login page
    When I fill in the correct username credentials
    And I click login
    Then I am on the landing page
    When I click "Admin Dashboard" image in landing page
    Then I am on the admin dashboard "System" page
    When I click "Instance Types" in admin dashboard
    Then I am on the admin dashboard "Instance Types" page
    When I click edit-button in row contains text "test-instance-type"
    Then I should see input in test-id "instanceType/name" with value "test-instance-type"
    And I should see input in test-id "instanceType/displayName" with value "test-instance-type"
    When I type "test-instance-type-display-name" to element with test-id "instanceType/displayName"
    And I type "test-description" to element with test-id "instanceType/description"
    And I click element with test-id "connect-button"
    And I wait for 4.0 seconds
    And I click element with xpath "//td[text()='phusers']/..//input"
    And I click element with xpath "//button/span[text()='OK']"
    And I wait for 4.0 seconds
    And I click element with xpath "//a/span[text()='Confirm']"
    Then list-view table "should" contain row with "test-instance-type"
    When I click edit-button in row contains text "test-instance-type"
    Then I should see input in test-id "instanceType/name" with value "test-instance-type"
    And I should see input in test-id "instanceType/displayName" with value "test-instance-type-display-name"
    When I logout from banner UI
    Then I am on login page
    When I fill in the correct username credentials
    And I click login
    Then I am on the landing page
    When I click "JupyterHub" image in landing page
    Then I am on the spawner page
    And I "should" see instance types block contains "test-instance-type-display-name" instanceType with "test-description" description and tooltip to show "CPU: 1 / Memory: 1G / GPU: 0"
    When I logout on JupyterHub page
    Then I can logout from JupyterHub
  
  Scenario: Delete instance type
    Given I go to login page
    When I fill in the correct username credentials
    And I click login
    Then I am on the landing page
    When I click "Admin Dashboard" image in landing page
    Then I am on the admin dashboard "System" page
    When I click "Instance Types" in admin dashboard
    Then I am on the admin dashboard "Instance Types" page
    When I delete a row with text "test-instance-type"
    And I wait for 2.0 seconds
    Then list-view table "should not" contain row with "test-instance-type"
    When I click refresh
    Then list-view table "should not" contain row with "test-instance-type" 
    When I logout from banner UI
    Then I am on login page
    When I fill in the correct username credentials
    And I click login
    Then I am on the landing page
    When I click "JupyterHub" image in landing page
    Then I am on the spawner page
    And I "should not" see instance types block contains "test-instance-type-display-name" instanceType with "test-description" description and tooltip to show "CPU: 1 / Memory: 1G / GPU: 0"
    When I logout on JupyterHub page
    Then I can logout from JupyterHub
