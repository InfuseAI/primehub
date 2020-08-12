@released
Feature: Login
  In order to manage system
  As a user
  I want to login

  Scenario: User can't login the admin page via incorrect email and password
    Given I go to login page
    When I fill in the wrong credentials
    And I click login
    # wait for a short while to avoid "Node with given id does not belong to the document" error
    And I wait for 3.0 seconds
    Then I am on login page

  Scenario: User can login/logout the admin page via correct username and password
    Given I go to login page
    When I fill in the correct username credentials
    And I click login
    Then I am on the landing page
    When I click "Admin Dashboard" image in landing page
    Then I am on the admin dashboard "Groups" page
    When I logout from banner UI
    Then I am on login page

  Scenario: User can login/logout the JupyterHab page
    Given I go to login page
    When I fill in the correct username credentials
    And I click login
    Then I am on the landing page
    When I click "JupyterHub" image in landing page
    Then I am on the spawner page
    When I logout on JupyterHub page
    Then I can logout from JupyterHub
