@released
Feature: Admin
  Delete some created resources

  Scenario: Delete image
    Given I go to login page
    When I fill in the correct username credentials
    And I click login
    Then I am on the landing page
    When I click "Admin Dashboard" image in landing page
    Then I am on the admin dashboard "System" page
    When I click "Images" in admin dashboard
    Then I am on the admin dashboard "Images" page
    When I delete a row with text "test-image"
    And I wait for 2.0 seconds
    Then list-view table "should not" contain row with "test-image"
    When I click refresh
    Then list-view table "should not" contain row with "test-image"
    When I logout from banner UI
    Then I am on login page
    When I fill in the correct username credentials
    And I click login
    Then I am on the landing page
    When I click "JupyterHub" image in landing page
    Then I am on the spawner page
    When I choose group with name "e2e-test-group"
    Then I "should not" see images block contains "test-image-type-display-name" image with "universal" type and "test-description" description
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
    #And I delete a row with text "test-instance-type-gpu"
    #And I wait for 2.0 seconds
    Then list-view table "should not" contain row with "test-instance-type"
    #And list-view table "should not" contain row with "test-instance-type-gpu"
    When I click refresh
    Then list-view table "should not" contain row with "test-instance-type"
    #And list-view table "should not" contain row with "test-instance-type-gpu"
    When I logout from banner UI
    Then I am on login page
    When I fill in the correct username credentials
    And I click login
    Then I am on the landing page
    When I click "JupyterHub" image in landing page
    Then I am on the spawner page
    When I choose group with name "e2e-test-group"
    Then I "should not" see instance types block contains "test-instance-type-display-name" instanceType with "test-description" description and tooltip to show "CPU: 0.5 / Memory: 1G / GPU: 0"
    When I logout on JupyterHub page
    Then I can logout from JupyterHub

  Scenario: Delete group
    Given I go to login page
    When I fill in the correct username credentials
    And I click login
    Then I am on the landing page
    When I click "Admin Dashboard" image in landing page
    Then I am on the admin dashboard "System" page
    When I click "Groups" in admin dashboard
    Then I am on the admin dashboard "Groups" page
    When I delete a row with text "e2e-test-group"
    And I wait for 2.0 seconds
    Then list-view table "should not" contain row with "e2e-test-group"
    When I click refresh
    Then list-view table "should not" contain row with "e2e-test-group" 
    When I logout from banner UI
    Then I am on login page
