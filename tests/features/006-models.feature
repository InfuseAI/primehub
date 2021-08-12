@wip @feat-model @ee @deploy
Feature: Model Management 
  Basic tests

  Background:
    Given I am logged in
    Then I am on the PrimeHub console "Home" page

    When I choose group with name "e2e-test-group-display-name"
    And I keep group resources
    And I choose "Models" in sidebar menu
    Then I am on the PrimeHub console "Models" page

