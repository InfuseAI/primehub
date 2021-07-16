@released @daily @error_check
Feature: Login
  In order to manage system
  As a user, I want to login

  Background:
    Given I go to login page

  @released @daily @error_check @admin
  Scenario: User can't login via incorrect username and password
    When I fill in the wrong credentials
    | fields                    | values                           |
    | //span[text()='username'] | document.getElementById('temp')] |
    | \n\n\n\n\n\n\n\n\n\n\n\n  | %s/pass/\$PASSWORD/g             |
    | phadmin                   | grep -r temp \/                  |

    And I wait for 3.0 seconds
    Then I am on login page
