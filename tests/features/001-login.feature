@ee @ce @deploy
Feature: Login
  In order to manage system
  As a user, I want to login

  Background:
    Given I go to login page

  @regression
  Scenario: User can login with correct username and password
    When I fill in the correct username credentials
    And I click login
    Then I am on the PrimeHub console "Home" page

    When I choose "Logout" in top-right menu
    Then I am on login page

  @regression @sanity @error-check
  Scenario: User can't login with incorrect username and password
    When I fill in the wrong credentials and click login
    | username                  | password                         |
    | //span[text()='username'] | document.getElementById('temp')] |
    | \n\n\n\n\n\n\n\n\n\n\n\n  | %s/pass/\$PASSWORD/g             |
    | phadmin                   | grep -r temp \/                  |
    | ^\S+@\S+$                 | password                         |

    Then I am on login page

