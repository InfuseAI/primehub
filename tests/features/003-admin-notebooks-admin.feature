@admin-user @ee
Feature: Notebooks Admin
  Basic tests

  @wip @admin-user @regression
  Scenario: User can access/stop the JupyterLab server in notebooks admin page
    Given I am logged in
    Then I am on the PrimeHub console "Home" page
    When I choose "Notebooks" in sidebar menu
    Then I am on the PrimeHub console "Notebooks" page
    When I get the iframe object
    And I go to the spawner page
    And I wait for 2.0 seconds
    And I choose instance type with name "test-instance-type"
    And I choose image with name "test-image"
    And I click element with selector "input[value='Start Notebook']" in hub
    Then I can see the spawning page and wait for notebook started
    When I choose "Admin Portal" in top-right menu
    Then I am on the admin dashboard "Groups" page
    When I click "Notebooks Admin" in admin dashboard
    Then I go to the notebooks admin page
    When I access my server in notebooks admin
    And I wait for 4.0 seconds
    And I switch to "JupyterLab" tab
    Then I can see the JupyterLab page
    When I switch to "NotebooksAdmin" tab
    Then I go to the notebooks admin page
    When I stop my server in notebooks admin
    And I click on PrimeHub icon
    Then I am on the PrimeHub console "Home" page
    When I choose "Notebooks" in sidebar menu
    Then I am on the PrimeHub console "Notebooks" page
    When I get the iframe object
    And I go to the spawner page
    When I choose "Logout" in top-right menu
    Then I am on login page
