@released @ee @ce
Feature: Admin
  In order to manage groups
  I want to change settings

  Background:
    Given I am logged in
    Then I am on the PrimeHub console "Home" page
    When I choose "Admin Portal" in top-right menu
    Then I am on the admin dashboard "Groups" page
    And I should see element with test-id "group"

  @sanity @smoke 
  Scenario: Create group and connect to existing user
    When I click element with test-id "add-button"
    Then I should see element with test-id "group/name"
    And I should see element with test-id "group/displayName"
    When I type valid test-id on the page
    | fields            | values                      |
    | group/name        | e2e-test-group              |
    | group/displayName | e2e-test-group-display-name |

    And I click element with xpath on the page
    | fields                                                                             |
    | //div[@data-testid='group/quotaMemory']//input[@class='ant-checkbox-input']        |
    | //div[@data-testid='group/projectQuotaCpu']//input[@class='ant-checkbox-input']    |
    | //div[@data-testid='group/projectQuotaGpu']//input[@class='ant-checkbox-input']    |
    | //div[@data-testid='group/projectQuotaMemory']//input[@class='ant-checkbox-input'] |

    And I type valid info to element with xpath on the page
    | fields                                                                                 | values |
    | //div[@data-testid='group/quotaCpu']//input[@class='ant-input-number-input']           | 1      |
    | //div[@data-testid='group/quotaGpu']//input[@class='ant-input-number-input']           | 1      |
    | //div[@data-testid='group/quotaMemory']//input[@class='ant-input-number-input']        | 2      |
    | //div[@data-testid='group/projectQuotaCpu']//input[@class='ant-input-number-input']    | 2      |
    | //div[@data-testid='group/projectQuotaGpu']//input[@class='ant-input-number-input']    | 2      |
    | //div[@data-testid='group/projectQuotaMemory']//input[@class='ant-input-number-input'] | 4      |

    And I click element with test-id "connect-button"
    And I wait for 4.0 seconds
    And I search my username in name filter
    And I click my username
    And I click element with xpath "//button/span[text()='OK']"
    And I wait for 4.0 seconds
    And I click element with test-id "confirm-button"
    And I wait for 2.0 seconds
    And I search "e2e-test-group" in test-id "text-filter-name"
    Then list-view table "should" contain row with "e2e-test-group"
    When I click on PrimeHub icon
    Then I am on the PrimeHub console "Home" page
    And I choose group with name "e2e-test-group-display-name"
    And I should see user limits with CPU, Memory, GPU is "1,2,1"
    And I should see group resources with CPU "0,2", Memory "0.0 GB,4 GB", GPU "0,2"
    When I choose "Logout" in top-right menu
    Then I am on login page

  @sanity @smoke
  Scenario: Create another group
    When I click element with test-id "add-button"
    Then I should see element with test-id "group/name"
    And I should see element with test-id "group/displayName"
    When I type valid test-id on the page
    | fields            | values                      |
    | group/name        | e2e-another-test-group              |
    | group/displayName | e2e-another-test-group-display-name |

    And I click element with xpath on the page
    | fields                                                                             |
    | //div[@data-testid='group/quotaMemory']//input[@class='ant-checkbox-input']        |
    | //div[@data-testid='group/projectQuotaCpu']//input[@class='ant-checkbox-input']    |
    | //div[@data-testid='group/projectQuotaGpu']//input[@class='ant-checkbox-input']    |
    | //div[@data-testid='group/projectQuotaMemory']//input[@class='ant-checkbox-input'] |

    And I type valid info to element with xpath on the page
    | fields                                                                                 | values |
    | //div[@data-testid='group/quotaCpu']//input[@class='ant-input-number-input']           | 1      |
    | //div[@data-testid='group/quotaGpu']//input[@class='ant-input-number-input']           | 1      |
    | //div[@data-testid='group/quotaMemory']//input[@class='ant-input-number-input']        | 2      |
    | //div[@data-testid='group/projectQuotaCpu']//input[@class='ant-input-number-input']    | 2      |
    | //div[@data-testid='group/projectQuotaGpu']//input[@class='ant-input-number-input']    | 2      |
    | //div[@data-testid='group/projectQuotaMemory']//input[@class='ant-input-number-input'] | 4      |

    And I click element with test-id "confirm-button"

  @normal-user @sanity
  Scenario: Enable model deployment and assign group admin
    When I search "e2e-test-group" in test-id "text-filter-name"
    And I click edit-button in row contains text "e2e-test-group"
    Then I should see input in test-id "group/name" with value "e2e-test-group"
    When I check boolean input with test-id "group/enabledDeployment"
    # checkbox of group admin
    And I click element with xpath "//table//input"
    And I click element with test-id "confirm-button"
    And I wait for 2.0 seconds
    And I search "e2e-test-group" in test-id "text-filter-name"
    Then list-view table "should" contain row with "e2e-test-group"
    When I click edit-button in row contains text "e2e-test-group"
    Then boolean input with test-id "group/enabledDeployment" should have value "true"
    And I "should" see element with xpath "//table//span[@class='ant-checkbox ant-checkbox-checked']"
    When I choose "Logout" in top-right menu
    Then I am on login page
