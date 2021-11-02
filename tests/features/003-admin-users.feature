@admin-users @ee @ce @deploy
Feature: Admin - Users
  In order to manage users
  I want to change settings

  Background:
    Given I am logged in as an admin
    Then I am on the PrimeHub console "Home" page

    When I choose "Admin Portal" in top-right menu
    Then I "should" see element with xpath "//a[contains(text(), 'Back to User Portal')]"

    When I click "Users" in admin portal
    Then I am on the admin portal "Users" page
    And I should see element with test-id on the page
    | test-id     |
    | user-active |
    | add-button  |

  @regression @sanity @prep-data
  Scenario: Create a normal user
    When I click element with test-id "add-button"
    Then I should see element with test-id on the page
    | test-id  |
    | username |
    | email    |

    When I type value to element with test-id on the page
    | test-id  | value         |
    | username | e2e-test-user |

    And I click element with xpath "//button/span[text()='Create']"
    Then I should see element with test-id on the page
    | test-id     |
    | user-active |
    | add-button  |

    When I search "e2e-test-user" in test-id "text-filter-username"
    And I click edit-button in row containing text "e2e-test-user"
    Then I should see input in test-id "username" with value "e2e-test-user"

  @regression @sanity @prep-data
  Scenario: Update password for a normal user
    When I search "e2e-test-user" in test-id "text-filter-username"
    And I click edit-button in row containing text "e2e-test-user"
    Then I should see input in test-id "username" with value "e2e-test-user"

    When I click element with xpath "//div[@role='tab' and text()='Reset Password']"
    Then I should see element with test-id on the page
    | test-id                       |
    | reset-password-password-input |
    | reset-password-reset-button   |

    When I type "password" to "password" text field
    And I type "password" to "confirm" text field    
    And I click element with test-id "reset-password-reset-button"
    Then I should see element with xpath on the page
    | exist  | xpath                                                                       |
    | should | //input[@data-testid='reset-password-password-input' and @value='password'] |
    | should | //input[@data-testid='reset-password-confirm-input' and @value='password']  |


  @regression @prep-data
  Scenario: Create another normal user
    When I click element with test-id "add-button"
    Then I should see element with test-id on the page
    | test-id   |
    | username  |
    | email     |

    When I type value to element with test-id on the page
    | test-id  | value                 |
    | username | e2e-test-another-user |

    And I click element with xpath "//button/span[text()='Create']"
    Then I should see element with test-id on the page
    | test-id     |
    | user-active |
    | add-button  |

    When I search "e2e-test-another-user" in test-id "text-filter-username"
    And I click edit-button in row containing text "e2e-test-another-user"
    Then I should see input in test-id "username" with value "e2e-test-another-user"

  @regression @prep-data
  Scenario: Update password for another normal user
    When I search "e2e-test-another-user" in test-id "text-filter-username"
    And I click edit-button in row containing text "e2e-test-another-user"
    Then I should see input in test-id "username" with value "e2e-test-another-user"

    When I click element with xpath "//div[@role='tab' and text()='Reset Password']"
    Then I should see element with test-id on the page
    | test-id                       |
    | reset-password-password-input |
    | reset-password-reset-button   |

    When I type "password" to "password" text field
    And I type "password" to "confirm" text field
    And I click element with test-id "reset-password-reset-button"
    Then I should see element with xpath on the page
    | exist  | xpath                                                                       |
    | should | //input[@data-testid='reset-password-password-input' and @value='password'] |
    | should | //input[@data-testid='reset-password-confirm-input' and @value='password']  |

  @regression @error-check
  Scenario: User can see expected results when no group is available
    When I choose "Logout" in top-right menu
    Then I am on login page

    When I go to login page
    And I fill in the username "e2e-test-user" and password "password"
    And I wait for 1.0 second
    And I click login
    Then I should see element with xpath on the page 
    | exist      | xpath                                                                 |
    | should not | //div[@class='ant-layout-sider-children']//span[text()='Home']        |
    | should not | //div[@class='ant-layout-sider-children']//span[text()='Notebooks']   |
    | should     | //span[@class='ant-alert-message' and text()='No group is available'] |

  @regression @prep-data
  Scenario: Update user info of first user
    When I search "e2e-test-user" in test-id "text-filter-username"
    And I click edit-button in row containing text "e2e-test-user"
    Then I should see value of element with test-id on the page
    | test-id   | value         |
    | username  | e2e-test-user |

    When I type value to element with test-id on the page
    | test-id   | value    |
    | firstName | e2e-test |

    And I check boolean input with test-id "isAdmin"
    And I click element with xpath "//button/span[text()='Update']"

    When I search "e2e-test-user" in test-id "text-filter-username"
    And I click edit-button in row containing text "e2e-test-user"
    Then I should see boolean input with test-id "isAdmin" having value "true"
    And I should see value of element with test-id on the page
    | test-id   | value         |
    | username  | e2e-test-user |
    | firstName | e2e-test      |

  @regression @prep-data
  Scenario: Connect first user to existing group
    When I search "e2e-test-user" in test-id "text-filter-username"
    And I click edit-button in row containing text "e2e-test-user"
    Then I should see value of element with test-id on the page
    | test-id   | value         |
    | username  | e2e-test-user |

    When I click element with test-id "connect-button"
    And I wait for 3.0 seconds
    And I search "e2e-test-group" in test-id "text-filter"
    And I click element with xpath on the page
    | xpath                                                                      |
    | //td/a[contains(text(), 'e2e-test-group')]/../preceding-sibling::td//input |
    | //button/span[text()='OK']                                                 |

    And I wait for 3.0 seconds
    And I click element with xpath "//button/span[text()='Update']"
    And I wait for 2.0 seconds
    And I search "e2e-test-user" in test-id "text-filter-username"
    Then I "should" see list-view table containing row with "e2e-test-user"

    When I click "Groups" in admin portal
    Then I am on the admin portal "Groups" page

    When I search "e2e-test-group" in test-id "text-filter-name"
    And I click edit-button in row containing text "e2e-test-group"
    Then I "should" see element with xpath "//td[contains(text(), 'e2e-test-user')]"    

  @regression @prep-data
  Scenario: Update user info of second user
    When I search "e2e-test-another-user" in test-id "text-filter-username"
    And I click edit-button in row containing text "e2e-test-another-user"
    Then I should see value of element with test-id on the page
    | test-id   | value                 |
    | username  | e2e-test-another-user |

    When I type value to element with test-id on the page
    | test-id   | value            |
    | firstName | e2e-test-another |

    And I check boolean input with test-id "isAdmin"
    And I click element with xpath "//button/span[text()='Update']"

    When I search "e2e-test-another-user" in test-id "text-filter-username"
    And I click edit-button in row containing text "e2e-test-another-user"
    Then I should see boolean input with test-id "isAdmin" having value "true"
    And I should see value of element with test-id on the page
    | test-id   | value                 |
    | username  | e2e-test-another-user |
    | firstName | e2e-test-another      |

  @regression @prep-data
  Scenario: Connect second user to existing group
    When I search "e2e-test-another-user" in test-id "text-filter-username"
    And I click edit-button in row containing text "e2e-test-another-user"
    Then I should see value of element with test-id on the page
    | test-id   | value                 |
    | username  | e2e-test-another-user |

    When I click element with test-id "connect-button"
    And I wait for 3.0 seconds
    And I search "e2e-test-another-group" in test-id "text-filter"
    And I click element with xpath on the page
    | xpath                                                                              |
    | //td/a[contains(text(), 'e2e-test-another-group')]/../preceding-sibling::td//input |
    | //button/span[text()='OK']                                                         |

    And I wait for 3.0 seconds
    And I click element with xpath "//button/span[text()='Update']"
    And I wait for 2.0 seconds
    And I search "e2e-test-another-user" in test-id "text-filter-username"
    Then I "should" see list-view table containing row with "e2e-test-another-user"

    When I click "Groups" in admin portal
    Then I am on the admin portal "Groups" page

    When I search "e2e-test-another-group" in test-id "text-filter-name"
    And I click edit-button in row containing text "e2e-test-another-group"
    Then I "should" see element with xpath "//td[contains(text(), 'e2e-test-another-user')]"

  @regression @prep-data
  Scenario: Newly created users can login
    When I choose "Logout" in top-right menu
    Then I am on login page

    When I go to login page
    And I fill in the username "e2e-test-user" and password "password"
    And I wait for 1.0 second
    And I click login
    Then I should see element with xpath on the page 
    | exist  | xpath                                                                 |
    | should | //div[@class='ant-layout-sider-children']//span[text()='Home']        |

    When I choose "User Profile" in top-right menu
    Then I "should" see element with xpath "//h2[text()='Edit Account']"
    And I "should" see element with xpath "//label[text()='Username']"
    And I "should" see element with xpath "//input[@id='username' and contains(@value, 'e2e-test-user')]"

    When I click element with xpath "//li//a[contains(text(), 'Sign Out')]"
    Then I am on login page

    When I go to login page
    And I fill in the username "e2e-test-another-user" and password "password"
    And I wait for 1.0 second
    And I click login
    Then I should see element with xpath on the page 
    | exist  | xpath                                                                 |
    | should | //div[@class='ant-layout-sider-children']//span[text()='Home']        |
    | should | //div[@class='ant-layout-sider-children']//span[text()='Notebooks']   |

    When I choose "User Profile" in top-right menu
    Then I "should" see element with xpath "//h2[text()='Edit Account']"
    And I "should" see element with xpath "//label[text()='Username']"
    And I "should" see element with xpath "//input[@id='username' and contains(@value, 'e2e-test-another-user')]"

    When I click element with xpath "//li//a[contains(text(), 'Sign Out')]"
    Then I am on login page
