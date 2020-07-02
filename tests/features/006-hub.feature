@released
Feature: Hub
  In order to do machine learning experiments,
  As a user,
  I want to spawn a hub and do something.

  Scenario: User can see advanced settings
    Given I go to login page
    When I fill in the correct username credentials
    And I click login
    Then I am on the landing page
    When I click "JupyterHub" image in landing page
    Then I am on the spawner page
    And I can see advanced settings
    When I logout on JupyterHub page
    Then I can logout from JupyterHub

  Scenario: User can start/stop the JupyterLab server
    Given I go to login page
    When I fill in the correct username credentials
    And I click login
    Then I am on the landing page
    When I click "JupyterHub" image in landing page
    Then I am on the spawner page
    When I choose group with name "e2e-test-group"
    And I choose instance type
    And I choose image
    And I click "Start Notebook" button
    Then I can see the spawning page
    And I can see the JupyterLab page
    And I go to the jupyterhub admin page to stop server
    When I logout on JupyterHub page
    Then I can logout from JupyterHub

  @wip
  Scenario: ch5367: User can see the error message when there is not enough quota
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
    When I type "test-instance-type-gpu" to element with test-id "instanceType/name"
    And I type "1" to element with test-id "instanceType/gpuLimit"
    And I click element with test-id "connect-button"
    And I wait for 4.0 seconds
    And I click element with xpath "//td[text()='test-group']/..//input"
    And I click element with xpath "//button/span[text()='OK']"
    And I wait for 4.0 seconds
    And I click element with xpath "//a/span[text()='Confirm']"
    And I wait for 4.0 seconds
    Then list-view table "should" contain row with "test-instance-type-gpu"
    When I logout from banner UI
    Then I am on login page
    When I fill in the correct username credentials
    And I click login
    Then I am on the landing page
    When I click "JupyterHub" image in landing page
    Then I am on the spawner page
    When I choose group with name "test-group"
    And I choose option with name "test-instance-type-gpu"
    And I choose image
    And I click "Start Notebook" button
    Then I can see the error message "Error: User phadmin exceeded gpu quota: 0, requesting 1"
    When I logout on JupyterHub page
    Then I can logout from JupyterHub

  @scheduled
  Scenario: Regression test with official latest jupyter/base-notebook
    Given I go to login page
    When I fill in the correct username credentials
    And I click login
    Then I am on the landing page
    When I click "Admin Dashboard" image in landing page
    Then I am on the admin dashboard "System" page
    When I click "Images" in admin dashboard
    Then I am on the admin dashboard "Images" page
    And I should see element with test-id "image"
    When I click element with test-id "add-button"
    Then I should see element with test-id "image/name"
    And I should see element with test-id "image/displayName"
    When I type "test-image" to element with test-id "image/name"
    And I type "jupyter/base-notebook:latest" to element with xpath "//div[@data-testid='image/url']//input"
    And I click element with test-id "connect-button"
    And I wait for 4.0 seconds
    And I click element with xpath "//td[contains(text(), 'phusers')]/..//input"
    And I click element with xpath "//button/span[text()='OK']"
    And I wait for 4.0 seconds
    And I click element with xpath "//a/span[text()='Confirm']"
    Then list-view table "should" contain row with "test-image"
    When I logout from banner UI
    Then I am on login page
    When I fill in the correct username credentials
    And I click login
    Then I am on the landing page
    When I click "JupyterHub" image in landing page
    Then I am on the spawner page
    And I choose instance type
    And I choose option with name "test-image"
    And I click "Start Notebook" button
    Then I can see the spawning page
    And I can see the JupyterLab page
    And I go to the jupyterhub admin page to stop server
    When I logout on JupyterHub page
    Then I can logout from JupyterHub
