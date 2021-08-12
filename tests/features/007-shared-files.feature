@wip @feat-sharedfiles @ee @ce @deploy
Feature: Shared Files
  Basic tests

  Background:
    Given I am logged in
    Then I am on the PrimeHub console "Home" page

    When I choose group with name "e2e-test-group-display-name"
    And I choose "Shared Files" in sidebar menu
    Then I am on the PrimeHub console "SharedFiles" page

