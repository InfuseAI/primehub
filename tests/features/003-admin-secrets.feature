@admin-secrets @ee @ce @deploy
Feature: Admin - Secrets
  In order to manage users
  I want to change settings

  Background:
    Given I am logged in as an admin
    Then I am on the PrimeHub console "Home" page

    When I choose "Admin Portal" in top-right menu
    Then I "should" see element with xpath "//a[contains(text(), 'Back to User Portal')]"

    When I click "Secrets" in admin dashboard
    Then I am on the admin dashboard "Secrets" page
    And I should see element with test-id on the page
    | test-id       |
    | secret-active |
    | add-button    |

  @regression @sanity @prep-data
  Scenario: Create a secret
    When I click element with test-id "add-button"
    And I click element with test-id "reset-button"
    Then I should see element with test-id on the page
    | test-id       |
    | secret-active |
    | add-button    |
