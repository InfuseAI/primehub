@released @daily
Feature: Login
  In order to manage system
  As a user
  I want to login
  Background:
    Given I go to login page

  Scenario: User can't login via incorrect username and password
    When I fill in the wrong credentials
    And I click login
    # wait for a short while to avoid "Node with given id does not belong to the document" error
    And I wait for 3.0 seconds
    Then I am on login page

  Scenario: User can login/logout the home page
    When I fill in the correct username credentials
    And I click login
    Then I am on the PrimeHub console "Home" page
    When I choose "Logout" in top-right menu
    Then I am on login page

  Scenario: User can login/logout the admin page
    When I fill in the correct username credentials
    And I click login
    Then I am on the PrimeHub console "Home" page
    When I choose "Admin Portal" in top-right menu
    Then I am on the admin dashboard "Groups" page
    When I choose "Logout" in top-right menu
    Then I am on login page
