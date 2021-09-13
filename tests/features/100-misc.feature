@feat-edition
Feature: Features
  Available feature in different edition for different roles

  Background:
    Given I am logged in as an admin
    Then I am on the PrimeHub console "Home" page

    When I choose "Admin Portal" in top-right menu
    Then I am on the admin dashboard "Groups" page

  @regression @ee @ce @deploy
  Scenario: Admin can access pages in Admin Portal - Group
    # Admin - Groups - Add
    When I click element with test-id "add-button"
    Then I should see element with test-id "group/name"
    And I click element with test-id "reset-button"

    # Admin - Groups - Search
    When I search "e2e-test-group" in test-id "text-filter-name"
    And I click edit-button in row contains text "e2e-test-group"
    Then I should see input in test-id "group/name" with value "e2e-test-group"

  @regression @ee @ce @deploy
  Scenario: Admin can access pages in Admin Portal - Users
    # Admin - Users
    When I click "Users" in admin dashboard
    Then I am on the admin dashboard "Users" page
    And I should see element with test-id on the page
    | test-id     |
    | user-active |
    | add-button  |

    # Admin - Users - Search
    When I search "e2e-test-user" in test-id "text-filter-username"
    And I click edit-button in row contains text "e2e-test-user"
    Then I should see input in test-id "username" with value "e2e-test-user"

    # Admin - Users - Edit - Send Email
    When I click tab of "Send Email"
    And I should see element with test-id on the page
    | test-id      |
    | email-button |
    
    # Admin - Users - Edit - Reset Password
    When I click tab of "Reset Password"
    And I should see element with test-id on the page
    | test-id                     |
    | reset-password-reset-button |

  @regression @ee @ce @deploy
  Scenario: Admin can access pages in Admin Portal - Instance Types
    # Admin - Instance Types
    When I click "Instance Types" in admin dashboard
    Then I am on the admin dashboard "Instance Types" page
    And I should see element with test-id on the page
    | test-id             |
    | instanceType-active |
    | add-button          |

    # Admin - Instance Types - Add
    When I click element with test-id "add-button"
    Then I should see element with test-id on the page
    | test-id     |
    | name        |
    | displayName |

    # Admin - Instance Types - Add - Tolerations
    When I click tab of "Tolerations"
    Then I should see element with test-id on the page
    | test-id           |
    | create-toleration |

    # Admin - Instance Types - Add - Node Selector
    When I click tab of "Node Selector"
    Then I should see element with test-id on the page
    | test-id          |
    | add-field-button |

    When I click element with test-id "reset-button"
    Then I am on the admin dashboard "Instance Types" page

    # Admin - Instance Types - Search
    When I search "e2e-test-instance-type" in test-id "text-filter"
    And I click edit-button in row contains text "e2e-test-instance-type"
    Then I should see input in test-id "name" with value "e2e-test-instance-type"

  @regression @ee @ce
  Scenario: Admin can access pages in Admin Portal - Images
    # Admin - Images
    When I click "Images" in admin dashboard
    Then I am on the admin dashboard "Images" page
    And I should see element with test-id on the page
    | test-id     |
    | image-active |
    | add-button  |

  @wip @regression @ee @ce
  Scenario: Admin can access pages in Admin Portal - Datasets
    # Admin - Datasets
    When I click "Datasets" in admin dashboard
    Then I am on the admin dashboard "Datasets" page
    And I should see element with xpath on the page
    | exist  | xpath                                                               |
    | should | //div[@class='ant-table-column-sorters' and text()='Upload Server'] |

  @wip @regression @ee @ce @deploy
  Scenario: Admin can access pages in Admin Portal - Secrets
    # Admin - Secrets - Add
    When I click "Secrets" in admin dashboard
    Then I am on the admin dashboard "Secrets" page
    And I should see element with test-id on the page
    | test-id       |
    | secret-active |
    | add-button    |

    When I click element with test-id "add-button"
    Then I should see element with test-id "name"

    # Secrets - Edit
    And I wait for 2.0 seconds
    And I click element with test-id "reset-button"
    Then I am on the admin dashboard "Secrets" page

  @regression @ee
  Scenario: Admin can access pages in Admin Portal - Usage Reports
    # Admin - Usage Reports
    When I click "Usage Reports" in admin dashboard
    Then I am on the admin dashboard "Usage Reports" page
    And I should see element with test-id on the page
    | test-id            |
    | usageReport-active |

    And I should see element with xpath on the page
    | exist  | xpath                                 |
    | should | //div[contains(., 'Summary Report')]  |
    | should | //div[contains(., 'Detailed Report')] | 

  @regression @ee @ce @deploy
  Scenario: Admin can access pages in Admin Portal - System Settings
    # Admin - System Settings
    When I click "System Settings" in admin dashboard
    Then I am on the admin dashboard "System Settings" page
    And I should see element with test-id on the page
    | test-id       |
    | system-active |

  @regression @ee @ce @deploy
  Scenario: User can access pages in User Portal
    # User portal
    When I click element with xpath "//a[contains(text(), 'Back to User Portal')]"
    Then I "should" see element with xpath "//h2[text()='User Guide']"

    # Shared Files
    When I choose "Shared Files" in sidebar menu
    Then I "should" see element with xpath "//a[text()='Shared Files']"

  @regression
  Scenario: User can access items via the top right menu
    # Top right menu 
    When I choose "User Profile" in top-right menu
    Then I "should" see element with xpath "//h2[text()='Edit Account']"
    And I "should" see element with xpath "//label[text()='Username']"

    When I click element with xpath "//li//a[@id='referrer']"
    And I wait for 2 seconds
    And I click element with xpath "//a[contains(text(), 'Back to User Portal')]"
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
