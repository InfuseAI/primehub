@ee @ce @deploy
Feature: Login
  In order to manage system
  As a user, I want to login

  Background:
    Given I go to login page

  @regression @sanity @error-check
  Scenario: User can't login via incorrect username and password
    When I fill in the wrong credentials and click login
    | fields                    | values                           |
    | //span[text()='username'] | document.getElementById('temp')] |
    | \n\n\n\n\n\n\n\n\n\n\n\n  | %s/pass/\$PASSWORD/g             |
    | phadmin                   | grep -r temp \/                  |
    | ^\S+@\S+$                 | password                         |

    And I wait for 2.0 seconds
    Then I am on login page
