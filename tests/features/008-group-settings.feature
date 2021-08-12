@wip @feat-group-settings @ee @ce @deploy
Feature: Group Settings
  Basic tests

  Background:
    Given I am logged in
    Then I am on the PrimeHub console "Home" page

    When I choose group with name "e2e-test-group-display-name"
    And I keep group resources
    And I choose "Settings" in sidebar menu
    Then I am on the PrimeHub console "Settings" page

