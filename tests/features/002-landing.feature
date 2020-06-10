@released
Feature: Landing page
  User portal tests

  Scenario: User can go to JupyterHub via the landing page
    Given I go to login page
    When I fill in the correct username credentials
    And I click login
    Then I am on the landing page
    When I click "JupyterHub" image in landing page
    Then I am on the spawner page
    When I click GoBack
    Then I am on the landing page
    When I logout from banner UI
    Then I am on login page

  @wip
  Scenario: User can go to User Guide via the landing page
    Given I go to login page
    When I fill in the correct username credentials
    And I click login
    Then I am on the landing page
    When I click "User Guide" image in landing page
    Then I am on the user guide page
    When I click GoBack
    Then I am on the landing page
    When I logout from banner UI
    Then I am on login page

  Scenario: User can go to JupyterHub Admin via the landing page
    Given I go to login page
    When I fill in the correct username credentials
    And I click login
    Then I am on the landing page
    When I click "JupyterHub Admin" image in landing page
    Then I am on the jupyterhub admin page
    When I click GoBack
    Then I am on the landing page
    When I logout from banner UI
    Then I am on login page

  Scenario: User can go to Admin Dashboard via the landing page
    Given I go to login page
    When I fill in the correct username credentials
    And I click login
    Then I am on the landing page
    When I click "Admin Dashboard" image in landing page
    Then I am on the admin dashboard "System" page
    When I click GoBack
    Then I am on the landing page
    When I logout from banner UI
    Then I am on login page
