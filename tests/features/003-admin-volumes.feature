@admin-volumes @ee @ce
Feature: Admin - Volumes 
  In order to manage volumes
  I want to change settings
  
  Background:
    Given I am logged in as an admin
    Then I am on the PrimeHub console "Home" page

    When I choose "Admin Portal" in top-right menu
    Then I "should" see element with xpath "//a[contains(text(), 'Back to User Portal')]"

    When I click "Volumes" in admin portal
    Then I am on the admin portal "Volumes" page
    And I should see element with test-id on the page
    | test-id       |
    | volume-active |
    | add-button    |

  @regression @sanity @smoke
  Scenario: Create a volume
    When I click element with test-id "add-button"
    Then I should see element with test-id on the page
    | test-id                  |
    | volume/input-name        |
    | volume/input-displayName |

    When I type value to element with test-id on the page
    | test-id           | value           |
    | volume/input-name | e2e-test-volume |

    And I select option "Env" in admin portal
    And I click element with test-id "confirm-button"
    Then I should see element with test-id on the page
    | test-id       |
    | volume-active |
    | add-button    |

  @regression
  Scenario: Search a volume
    When I search "e2e-test-volume" in test-id "text-filter"
    Then I "should" see list-view table containing row with "e2e-test-volume"

  @regression
  Scenario: Update a volume
    When I search "e2e-test-volume" in test-id "text-filter"
    And I click edit-button in row containing text "e2e-test-volume"
    Then I should see value of element with test-id on the page
    | test-id                  | value           |
    | volume/input-name        | e2e-test-volume |
    | volume/input-displayName | e2e-test-volume |

    When I type value to element with test-id on the page
    | test-id                  | value                        |
    | volume/input-displayName | e2e-test-volume-display-name |

    And I click element with test-id "confirm-button"
    Then I should see element with test-id on the page
    | test-id       |
    | volume-active |
    | add-button    |

  @regression
  Scenario: Connect a volume to an existing group
    When I search "e2e-test-volume" in test-id "text-filter"
    And I click edit-button in row containing text "e2e-test-volume"
    Then I should see value of element with test-id on the page
    | test-id                  | value                        |
    | volume/input-name        | e2e-test-volume              |
    | volume/input-displayName | e2e-test-volume-display-name |

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
    | test-id       |
    | volume-active |
    | add-button    |

  @regression
  Scenario: Show a volume in spawner page
    When I click on PrimeHub icon
    Then I am on the PrimeHub console "Home" page

    When I choose group with name "e2e-test-group-display-name"
    And I choose "Notebooks" in sidebar menu
    Then I am on the PrimeHub console "Notebooks" page

    When I get the iframe object
    And I go to the spawner page
    Then I "should" see element with xpath "//div[@id='volume-list']//li[contains(text(), 'e2e-test-volume-display-name')]" in hub

  @regression
  Scenario: Delete a volume
    When I search "e2e-test-volume" in test-id "text-filter"
    And I delete a row with text "e2e-test-volume"
    And I wait for 2.0 seconds
    And I click refresh
    And I search "e2e-test-volume" in test-id "text-filter"
    Then I "should not" see list-view table containing row with "e2e-test-volume"

  @regression
  Scenario: Do not show a deleted volume in spawner page
    When I click on PrimeHub icon
    Then I am on the PrimeHub console "Home" page

    When I choose group with name "e2e-test-group-display-name"
    And I choose "Notebooks" in sidebar menu
    Then I am on the PrimeHub console "Notebooks" page

    When I get the iframe object
    And I go to the spawner page
    Then I "should not" see element with xpath "//div[@id='volume-list']//li[contains(text(), 'e2e-test-volume-display-name')]" in hub
