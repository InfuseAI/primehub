@feat @feat-edition
Feature: Features accessible for user
  Available feature in different edition for different roles

  Background:
    Given I am logged in as a user 
    Then I am on the PrimeHub console "Home" page
    And I "should not" see element with xpath "//span[text()='Settings']"

  @regression @ee @ce @deploy
  Scenario: User can access pages in User Portal
    # Shared Files
    When I choose "Shared Files" in sidebar menu
    Then I "should" see element with xpath "//a[text()='Shared Files']"

  @regression @ee @ce @deploy
  Scenario: User can access items via the top right menu
    # Top right menu 
    When I choose "User Profile" in top-right menu
    Then I "should" see element with xpath "//h2[text()='Edit Account']"
    And I "should" see element with xpath "//label[text()='Username']"

    When I click element with xpath "//li//a[@id='referrer']"
    And I wait for 2 seconds
    Then I "should" see element with xpath "//h2[text()='User Guide']"

    # API Token
    When I choose "API Token" in top-right menu
    Then I "should" see element with xpath "//button//span[text()='Request API Token']"

    # Change Password
    When I choose "Change Password" in top-right menu
    Then I "should" see element with xpath "//h2[text()='Change Password']"
    And I "should" see element with xpath "//label[text()='Confirmation']"

    When I click element with xpath "//li//a[@id='referrer']"
    And I wait for 1 second
    And I click on PrimeHub icon
    Then I am on the PrimeHub console "Home" page
