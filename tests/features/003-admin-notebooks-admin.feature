@admin-notebooks-admin @ee @ce
Feature: Notebooks Admin
  Basic tests

  Background:
    Given I am logged in
    Then I am on the PrimeHub console "Home" page

    When I choose "Admin Portal" in top-right menu
    Then I am on the admin dashboard "Groups" page

    When I click "Notebooks Admin" in admin dashboard
    And I get the iframe object
    Then I am on the notebooks admin page

  @regression
  Scenario: User can start the JupyterLab server
    When I click on PrimeHub icon
    Then I am on the PrimeHub console "Home" page

    When I choose group with name "e2e-test-group-display-name"
    And I choose "Notebooks" in sidebar menu
    Then I am on the PrimeHub console "Notebooks" page

    When I get the iframe object
    And I go to the spawner page
    And I wait for 2.0 seconds
    And I choose instance type with name "e2e-test-instance-type"
    And I choose image with name "e2e-test-image"
    And I click element with selector "input[value='Start Notebook']" in hub
    Then I can see the spawning page and wait for notebook started

    When I choose "Logout" in top-right menu
    Then I am on login page

  @regression
  Scenario: User can access the JupyterLab server in notebooks admin page
    When I access my server in notebooks admin
    And I wait for 4.0 seconds
    And I switch to "JupyterLab" tab
    Then I can see the JupyterLab page

    When I switch to "NotebooksAdmin" tab
    Then I am on the notebooks admin page

    When I choose "Logout" in top-right menu
    Then I am on login page

  @regression
  Scenario: User can stop the JupyterLab server in notebooks admin page
    When I stop my server in notebooks admin
    And I click on PrimeHub icon
    Then I am on the PrimeHub console "Home" page

    When I choose "Notebooks" in sidebar menu
    Then I am on the PrimeHub console "Notebooks" page

    When I get the iframe object
    And I go to the spawner page

    When I choose "Logout" in top-right menu
    Then I am on login page

