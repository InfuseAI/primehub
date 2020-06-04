Feature: i18n
  In order to use preferred language
  As a User
  I want to choose language

  Scenario Outline: User can change interface language
    Given I am on admin login page
    When I change language to "<lang>"
    Then the login heading should be "<heading>"

    Examples:
      | lang    | heading |
      | English | Log In  |
      | 正體中文    | 登入      |
