@admin-images @ee @ce
Feature: Admin - Images
  In order to manage images
  I want to change settings

  Background:
    Given I am logged in as an admin
    Then I am on the PrimeHub console "Home" page

    When I choose "Admin Portal" in top-right menu
    Then I "should" see element with xpath "//a[contains(text(), 'Back to User Portal')]"

    When I click "Images" in admin dashboard
    Then I am on the admin dashboard "Images" page
    And I should see element with test-id on the page
    | test-id      |
    | image-active |
    | add-button   |

  @regression @sanity @smoke @prep-data
  Scenario: Create an image
    When I click element with test-id "add-button"
    Then I should see element with test-id on the page
    | test-id     |
    | name        |
    | displayName |    

    When I type value to element with test-id on the page
    | test-id     | value                       |
    | name        | e2e-test-image              |
    | displayName | e2e-test-image-display-name |
    | description | e2e-test-description        |

    And I type "jupyter/datascience-notebook:b90cce83f37b" to element with xpath "//input[@data-testid='imageUrl']"
    And I click element with test-id "confirm-button"
    Then I should see element with test-id on the page
    | test-id    |
    | image      |
    | add-button |

  @regression @sanity @smoke @prep-data
  Scenario: Connect an image to an existing group
    When I search "e2e-test-image" in test-id "text-filter"
    Then I "should" see list-view table containing row with "e2e-test-image"

    When I click edit-button in row contains text "e2e-test-image"
    And I wait for 0.5 second
    Then I should see input in test-id "name" with value "e2e-test-image"

    When I click element with test-id "global"
    And I click element with test-id "connect-button"
    And I wait for 1.0 second
    And I search "e2e-test-group" in test-id "text-filter"
    Then I "should" see list-view table containing row with "e2e-test-group"

    And I click element with xpath on the page
    | xpath                                              |
    | //td[contains(text(), 'e2e-test-group')]/..//input |
    | //button/span[text()='OK']                         |

    And I wait for 1.0 second
    And I click element with test-id "confirm-button"
    Then I should see element with test-id on the page
    | test-id      |
    | image-active |
    | add-button   |

  @regression @sanity @smoke @prep-data
  Scenario: Create an image with latest base notebook
    When I click element with test-id "add-button"
    Then I should see element with test-id on the page
    | test-id     |
    | name        |
    | displayName |

    When I type value to element with test-id on the page
    | test-id     | value                          |
    | name        | e2e-test-bs-image              |
    | displayName | e2e-test-bs-image-display-name |
    | description | e2e-test-bs-description        |

    And I type "jupyter/base-notebook:latest" to element with xpath "//input[@data-testid='imageUrl']"
    And I click element with test-id "confirm-button"
    Then I should see element with test-id on the page
    | test-id      |
    | image-active |
    | add-button   |

  @regression @sanity @smoke @prep-data
  Scenario: Connect an image with latest base notebook to an existing group
    When I search "e2e-test-bs-image" in test-id "text-filter"
    Then I "should" see list-view table containing row with "e2e-test-bs-image"

    When I click edit-button in row contains text "e2e-test-bs-image"
    And I wait for 0.5 second
    Then I should see input in test-id "name" with value "e2e-test-bs-image"

    When I click element with test-id "global"
    And I click element with test-id "connect-button"
    And I wait for 1.0 second
    And I search "e2e-test-group" in test-id "text-filter"
    Then I "should" see list-view table containing row with "e2e-test-group"

    When I click element with xpath on the page
    | xpath                                              |
    | //td[contains(text(), 'e2e-test-group')]/..//input |
    | //button/span[text()='OK']                         |

    And I wait for 1.0 second
    And I click element with test-id "confirm-button"
    Then I should see element with test-id on the page
    | test-id      |
    | image-active |
    | add-button   |

  @regression @error-check @prep-data
  Scenario: Create an error image
    When I click element with test-id "add-button"
    Then I should see element with test-id on the page
    | test-id     |
    | name        |
    | displayName |    

    When I type value to element with test-id on the page
    | test-id     | value                             |
    | name        | e2e-test-error-image              |
    | displayName | e2e-test-error-image-display-name |
    | description | e2e-test-error-description        |

    And I type "error-url" to element with xpath "//input[@data-testid='imageUrl']"
    And I click element with test-id "confirm-button"
    Then I should see element with test-id on the page
    | test-id      |
    | image-active |
    | add-button   |

  @regression @error-check @prep-data
  Scenario: Connect an error image to an existing group
    When I search "e2e-test-error-image" in test-id "text-filter"
    Then I "should" see list-view table containing row with "e2e-test-error-image"

    When I click edit-button in row contains text "e2e-test-error-image"
    And I wait for 0.5 second
    Then I should see input in test-id "name" with value "e2e-test-error-image"

    When I click element with test-id "global"
    And I click element with test-id "connect-button"
    And I wait for 1.0 second
    And I search "e2e-test-group" in test-id "text-filter"
    Then I "should" see list-view table containing row with "e2e-test-group"

    When I click element with xpath on the page
    | xpath                                              |
    | //td[contains(text(), 'e2e-test-group')]/..//input |
    | //button/span[text()='OK']                         |

    And I wait for 1.0 second
    And I click element with test-id "confirm-button"
    Then I should see element with test-id on the page
    | test-id      |
    | image-active |
    | add-button   |

  @regression @prep-data
  Scenario: Create a GPU image
    When I click element with test-id "add-button"
    Then I should see element with test-id on the page
    | test-id     |
    | name        |
    | displayName |    

    When I type value to element with test-id on the page
    | test-id     | value              |
    | name        | e2e-test-image-gpu |
    | displayName | e2e-test-image-gpu |

    And I click element with test-id "confirm-button"
    Then I should see element with test-id on the page
    | test-id      |
    | image-active |
    | add-button   |

  @regression @prep-data
  Scenario: Update a GPU image
    When I search "e2e-test-image-gpu" in test-id "text-filter"
    Then I "should" see list-view table containing row with "e2e-test-image-gpu"

    When I click edit-button in row contains text "e2e-test-image-gpu"
    And I wait for 0.5 second
    Then I should see input in test-id "name" with value "e2e-test-image-gpu"
    And I should see input in test-id "displayName" with value "e2e-test-image-gpu"

    When I type value to element with test-id on the page
    | test-id     | value                           |
    | displayName | e2e-test-image-display-name-gpu |
    | description | e2e-test-image-description-gpu  |

    And I click element with xpath on the page
    | xpath                                |
    | //div[@id='instance-type-form_type'] |
    | //li[text()='GPU']                   |

    And I type "infuseai/docker-stacks:base-notebook-2d701645-gpu" to element with xpath "//input[@data-testid='imageUrl']"
    And I click element with test-id "confirm-button"
    Then I should see element with test-id on the page
    | test-id      |
    | image-active |
    | add-button   |

  @regression @prep-data
  Scenario: Connect a GPU image to an existing group
    When I search "e2e-test-image-gpu" in test-id "text-filter"
    Then I "should" see list-view table containing row with "e2e-test-image-gpu"

    When I click edit-button in row contains text "e2e-test-image-gpu"
    And I wait for 0.5 second
    Then I should see input in test-id "name" with value "e2e-test-image-gpu"

    When I click element with test-id "global"
    And I click element with test-id "connect-button"
    And I wait for 1.0 second
    And I search "e2e-test-group" in test-id "text-filter"
    Then I "should" see list-view table containing row with "e2e-test-group"

    And I click element with xpath on the page
    | xpath                                              |
    | //td[contains(text(), 'e2e-test-group')]/..//input |
    | //button/span[text()='OK']                         |

    And I wait for 1.0 second
    And I click element with test-id "confirm-button"
    Then I should see element with test-id on the page
    | test-id      |
    | image-active |
    | add-button   |

  @regression @sanity @prep-data
  Scenario: Create a group image
    When I click on PrimeHub icon
    Then I am on the PrimeHub console "Home" page

    When I choose group with name "e2e-test-group-display-name"
    And I choose "Images" in sidebar menu
    Then I am on the PrimeHub console "Images" page

    When I click "New Image" button
    Then I am on the PrimeHub console "NewImage" page

    When I type value to element with xpath on the page
    | xpath                                 | value                                     |
    | //input[contains(@id, 'displayName')] | e2e-test-group-image                      |
    | //input[contains(@id, 'description')] | e2e-test-group-image-description          |
    | //input[contains(@id, 'url')]         | jupyter/datascience-notebook:b90cce83f37b |

    And I click "Create" button
    Then I "should" see element with xpath "//a[text()='e2e-test-group-image']"

  @regression @sanity @prep-data
  Scenario: Show a group image in spawner page
    When I click on PrimeHub icon
    Then I am on the PrimeHub console "Home" page

    When I choose group with name "e2e-test-group-display-name"
    And I choose "Notebooks" in sidebar menu
    Then I am on the PrimeHub console "Notebooks" page

    When I get the iframe object
    And I go to the spawner page
    #Then I "should" see images block contains "e2e-test-group-image" image with "Group / Universal" type and "e2e-test-group-image-description" description
