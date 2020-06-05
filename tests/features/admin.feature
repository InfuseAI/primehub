Feature: Admin
  In order to manage system
  As a user
  I want to change settings

  Scenario Outline: Admin can set system name
    Given I am a logged-in admin
    When I go to the System page
    And I fill in "Name" with "<name>"
    And I click "Confirm" button
    And I logout on admin page
    Then I am on admin login page
    And I see "<name>" in logo alt text

    Examples:
      | name                              |
      | Foobar Inc                        |
      | 台灣好棒棒                             |
      | Ho Ho Ho 🤠                       |
      | Foobar Else; SELECT * FROM USERS; |
      | InfuseAI                          |
