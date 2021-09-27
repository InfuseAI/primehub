@admin-datasets @ee @ce
Feature: Admin - Datasets
  In order to manage datasets
  I want to change settings
  
  Background:
    Given I am logged in as a admin
    Then I am on the PrimeHub console "Home" page

    When I choose "Admin Portal" in top-right menu
    Then I "should" see element with xpath "//a[contains(text(), 'Back to User Portal')]"

    When I click "Datasets" in admin portal
    Then I am on the admin portal "Datasets" page
    And I should see element with test-id on the page
    | test-id        |
    | dataset-active |
    | add-button     |

  @regression @sanity @smoke
  Scenario: Create a dataset
    When I click element with test-id "add-button"
    Then I should see element with test-id on the page
    | test-id                   |
    | dataset/input-name        |
    | dataset/input-displayName |

    When I type value to element with test-id on the page
    | test-id            | value            |
    | dataset/input-name | e2e-test-dataset |

    And I click element with xpath "//div[contains(@class, 'ant-select-selection--single')]"
    And I click element with xpath "//li[text()='Env']"
    And I click element with test-id "confirm-button"
    Then I should see element with test-id on the page
    | test-id        |
    | dataset-active |
    | add-button     |

  @regression @sanity @smoke
  Scenario: Search a dataset
    When I search "e2e-test-dataset" in test-id "text-filter"
    Then I "should" see list-view table containing row with "e2e-test-dataset"

  @regression
  Scenario: Update a dataset
    When I search "e2e-test-dataset" in test-id "text-filter"
    And I click edit-button in row containing text "e2e-test-dataset"
    Then I should see value of element with test-id on the page
    | test-id                   | value            |
    | dataset/input-name        | e2e-test-dataset |
    | dataset/input-displayName | e2e-test-dataset |

    When I type value to element with test-id on the page
    | test-id                   | value                         |
    | dataset/input-displayName | e2e-test-dataset-display-name |

    And I click element with test-id "confirm-button"
    Then I should see element with test-id on the page
    | test-id        |
    | dataset-active |
    | add-button     |

  @regression
  Scenario: Connect a dataset to an existing group
    When I search "e2e-test-dataset" in test-id "text-filter"
    And I click edit-button in row containing text "e2e-test-dataset"
    Then I should see value of element with test-id on the page
    | test-id                   | value                         |
    | dataset/input-name        | e2e-test-dataset              |
    | dataset/input-displayName | e2e-test-dataset-display-name |

    When I click element with test-id "connect-button"
    And I wait for 2.0 seconds
    And I search "e2e-test-group" in test-id "text-filter"
    And I click element with xpath on the page
    | xpath                                              |
    | //td[contains(text(), 'e2e-test-group')]/..//input |
    | //button/span[text()='OK']                         |

    And I wait for 2.0 seconds
    And I click element with test-id "confirm-button"
    Then I should see element with test-id on the page
    | test-id        |
    | dataset-active |
    | add-button     |

  @regression
  Scenario: Show a dataset in spawner page
    When I click on PrimeHub icon
    Then I am on the PrimeHub console "Home" page

    When I choose group with name "e2e-test-group-display-name"
    And I choose "Notebooks" in sidebar menu
    Then I am on the PrimeHub console "Notebooks" page

    When I get the iframe object
    And I go to the spawner page
    Then I "should" see element with xpath "//div[@id='dataset-list']//li[contains(text(), 'e2e-test-dataset-display-name')]" in hub

  @regression
  Scenario: Delete a dataset
    When I search "e2e-test-dataset" in test-id "text-filter"
    And I delete a row with text "e2e-test-dataset"
    And I wait for 2.0 seconds
    And I click refresh
    And I search "e2e-test-dataset" in test-id "text-filter"
    Then I "should not" see list-view table containing row with "e2e-test-dataset" 

  @regression
  Scenario: Do not show a deleted dataset in spawner page
    When I click on PrimeHub icon
    Then I am on the PrimeHub console "Home" page

    When I choose group with name "e2e-test-group-display-name"
    And I choose "Notebooks" in sidebar menu
    Then I am on the PrimeHub console "Notebooks" page

    When I get the iframe object
    And I go to the spawner page
    Then I "should not" see element with xpath "//div[@id='dataset-list']//li[contains(text(), 'e2e-test-dataset-display-name')]" in hub
