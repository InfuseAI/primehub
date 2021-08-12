@admin-groups @ee @ce @deploy
Feature: Admin - Groups
  In order to manage groups
  I want to change settings

  Background:
    Given I am logged in
    Then I am on the PrimeHub console "Home" page

    When I choose "Admin Portal" in top-right menu
    Then I am on the admin dashboard "Groups" page
    And I should see element with test-id "group"

  @regression @sanity @smoke @prep-data
  Scenario: Create a group
    When I click element with test-id "add-button"
    Then I should see element with test-id on the page
    | test-id           |
    | group/name        |
    | group/displayName |

    When I type value to test-id on the page
    | test-id           | value                       |
    | group/name        | e2e-test-group              |
    | group/displayName | e2e-test-group-display-name |

    And I click element with xpath on the page
    | xpath                                                                              |
    | //div[@data-testid='group/quotaMemory']//input[@class='ant-checkbox-input']        |
    | //div[@data-testid='group/projectQuotaCpu']//input[@class='ant-checkbox-input']    |
    | //div[@data-testid='group/projectQuotaGpu']//input[@class='ant-checkbox-input']    |
    | //div[@data-testid='group/projectQuotaMemory']//input[@class='ant-checkbox-input'] |

    And I type value to element with xpath on the page
    | xpath                                                                                  | value |
    | //div[@data-testid='group/quotaCpu']//input[@class='ant-input-number-input']           | 1     |
    | //div[@data-testid='group/quotaGpu']//input[@class='ant-input-number-input']           | 1     |
    | //div[@data-testid='group/quotaMemory']//input[@class='ant-input-number-input']        | 2     |
    | //div[@data-testid='group/projectQuotaCpu']//input[@class='ant-input-number-input']    | 2     |
    | //div[@data-testid='group/projectQuotaGpu']//input[@class='ant-input-number-input']    | 2     |
    | //div[@data-testid='group/projectQuotaMemory']//input[@class='ant-input-number-input'] | 4     |

    And I click element with test-id "confirm-button"
    Then I "should" see element with xpath "//span[text()='Group CPU Quota']"

    When I choose "Logout" in top-right menu
    Then I am on login page

  @regression @sanity @smoke @prep-data
  Scenario: Connect a group to an existing user
    When I search "e2e-test-group" in test-id "text-filter-name"
    Then list-view table "should" contain row with "e2e-test-group"

    When I click edit-button in row contains text "e2e-test-group"
    Then I should see element with test-id on the page
    | test-id           |
    | group/name        |
    | group/displayName |

    When I click element with test-id "connect-button"
    And I wait for 2.0 seconds
    And I search my username in name filter
    And I click my username
    And I click element with xpath "//button/span[text()='OK']"
    And I wait for 2.0 seconds
    And I click element with test-id "confirm-button"
    Then I "should" see element with xpath "//span[text()='Group CPU Quota']"

    When I click on PrimeHub icon
    Then I am on the PrimeHub console "Home" page

    When I choose group with name "e2e-test-group-display-name"
    Then I should see user limits with CPU, Memory, GPU is "1,2,1"

    When I choose "Logout" in top-right menu
    Then I am on login page

  @regression @sanity @smoke @prep-data
  Scenario: Check group resources of a new group as speficied upon creation
    When I click on PrimeHub icon
    Then I am on the PrimeHub console "Home" page

    When I choose group with name "e2e-test-group-display-name"
    Then I should see group resources with CPU "0,2", Memory "0.0 GB,4 GB", GPU "0,2"

    When I choose "Logout" in top-right menu
    Then I am on login page

  @regression @sanity @smoke @prep-data
  Scenario: Create another group
    When I click element with test-id "add-button"
    Then I should see element with test-id on the page
    | test-id           |
    | group/name        |
    | group/displayName |

    When I type value to test-id on the page
    | test-id           | value                               |
    | group/name        | e2e-test-another-group              |
    | group/displayName | e2e-test-another-group-display-name |

    And I click element with xpath on the page
    | xpath                                                                              |
    | //div[@data-testid='group/quotaMemory']//input[@class='ant-checkbox-input']        |
    | //div[@data-testid='group/projectQuotaCpu']//input[@class='ant-checkbox-input']    |
    | //div[@data-testid='group/projectQuotaGpu']//input[@class='ant-checkbox-input']    |
    | //div[@data-testid='group/projectQuotaMemory']//input[@class='ant-checkbox-input'] |

    And I type value to element with xpath on the page
    | xpath                                                                                  | value |
    | //div[@data-testid='group/quotaCpu']//input[@class='ant-input-number-input']           | 1     |
    | //div[@data-testid='group/quotaGpu']//input[@class='ant-input-number-input']           | 1     |
    | //div[@data-testid='group/quotaMemory']//input[@class='ant-input-number-input']        | 2     |
    | //div[@data-testid='group/projectQuotaCpu']//input[@class='ant-input-number-input']    | 2     |
    | //div[@data-testid='group/projectQuotaGpu']//input[@class='ant-input-number-input']    | 2     |
    | //div[@data-testid='group/projectQuotaMemory']//input[@class='ant-input-number-input'] | 4     |

    And I click element with test-id "confirm-button"
    And I wait for 1.0 second
    Then I "should" see element with xpath "//span[text()='Group CPU Quota']"

    When I choose "Logout" in top-right menu
    Then I am on login page

  @regression @sanity @prep-data
  Scenario: Assign group admin to an existing user
    When I search "e2e-test-group" in test-id "text-filter-name"
    And I click edit-button in row contains text "e2e-test-group"
    Then I should see input in test-id "group/name" with value "e2e-test-group"

    When I assign group admin of "e2e-test-group" to "me"
    And I click element with test-id "confirm-button"
    Then I "should" see element with xpath "//span[text()='Group CPU Quota']"

    When I choose "Logout" in top-right menu
    Then I am on login page
