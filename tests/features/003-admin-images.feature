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
    | test-id           |
    | image/name        |
    | image/displayName |    

    When I type value to element with test-id on the page
    | test-id           | value                       |
    | image/name        | e2e-test-image              |
    | image/displayName | e2e-test-image-display-name |
    | image/description | e2e-test-description        |

    And I type "jupyter/datascience-notebook:b90cce83f37b" to element with xpath "//div[@data-testid='image/url']//input"
    And I click element with xpath "//a/span[text()='Confirm']"
    Then I should see element with test-id on the page
    | test-id    |
    | image      |
    | add-button |

  @regression @sanity @smoke @prep-data
  Scenario: Connect an image to an existing group
    When I search "e2e-test-image" in test-id "text-filter-name"
    Then I "should" see list-view table containing row with "e2e-test-image"

    When I click edit-button in row contains text "e2e-test-image"
    Then I should see input in test-id "image/name" with value "e2e-test-image"

    When I click element with test-id "connect-button"
    And I wait for 1.0 second
    And I search "e2e-test-group" in test-id "text-filter-name"
    Then I "should" see list-view table containing row with "e2e-test-image"

    And I click element with xpath on the page
    | xpath                                              |
    | //td[contains(text(), 'e2e-test-group')]/..//input |
    | //button/span[text()='OK']                         |

    And I wait for 1.0 second
    And I click element with xpath "//a/span[text()='Confirm']"
    Then I should see element with test-id on the page
    | test-id      |
    | image-active |
    | add-button   |

  @regression @sanity @smoke @prep-data
  Scenario: Create an image with latest base notebook
    When I click element with test-id "add-button"
    Then I should see element with test-id on the page
    | test-id           |
    | image/name        |
    | image/displayName |

    When I type value to element with test-id on the page
    | test-id           | value                          |
    | image/name        | e2e-test-bs-image              |
    | image/displayName | e2e-test-bs-image-display-name |
    | image/description | e2e-test-bs-description        |

    And I type "jupyter/base-notebook:latest" to element with xpath "//div[@data-testid='image/url']//input"
    And I click element with xpath "//a/span[text()='Confirm']"
    Then I should see element with test-id on the page
    | test-id      |
    | image-active |
    | add-button   |

  @regression @sanity @smoke @prep-data
  Scenario: Connect an image with latest base notebook to an existing group
    When I search "e2e-test-bs-image" in test-id "text-filter-name"
    Then I "should" see list-view table containing row with "e2e-test-bs-image"

    When I click edit-button in row contains text "e2e-test-bs-image"
    Then I should see input in test-id "image/name" with value "e2e-test-bs-image"

    When I click element with test-id "connect-button"
    And I wait for 1.0 second
    And I search "e2e-test-group" in test-id "text-filter-name"
    Then I "should" see list-view table containing row with "e2e-test-group"

    When I click element with xpath on the page
    | xpath                                              |
    | //td[contains(text(), 'e2e-test-group')]/..//input |
    | //button/span[text()='OK']                         |

    And I wait for 1.0 second
    And I click element with xpath "//a/span[text()='Confirm']"
    Then I should see element with test-id on the page
    | test-id      |
    | image-active |
    | add-button   |

  @regression @error-check @prep-data
  Scenario: Create an error image
    When I click element with test-id "add-button"
    Then I should see element with test-id on the page
    | test-id           |
    | image/name        |
    | image/displayName |    

    When I type value to element with test-id on the page
    | test-id           | value                             |
    | image/name        | e2e-test-error-image              |
    | image/displayName | e2e-test-error-image-display-name |
    | image/description | e2e-test-error-description        |

    And I type "error-url" to element with xpath "//div[@data-testid='image/url']//input"
    And I click element with xpath "//a/span[text()='Confirm']"
    Then I should see element with test-id on the page
    | test-id      |
    | image-active |
    | add-button   |

  @regression @error-check @prep-data
  Scenario: Connect an error image to an existing group
    When I search "e2e-test-error-image" in test-id "text-filter-name"
    Then I "should" see list-view table containing row with "e2e-test-error-image"

    When I click edit-button in row contains text "e2e-test-error-image"
    Then I should see input in test-id "image/name" with value "e2e-test-error-image"

    When I click element with test-id "connect-button"
    And I wait for 1.0 second
    And I search "e2e-test-group" in test-id "text-filter-name"
    Then I "should" see list-view table containing row with "e2e-test-group"

    When I click element with xpath on the page
    | xpath                                              |
    | //td[contains(text(), 'e2e-test-group')]/..//input |
    | //button/span[text()='OK']                         |

    And I wait for 1.0 second
    And I click element with xpath "//a/span[text()='Confirm']"
    Then I should see element with test-id on the page
    | test-id      |
    | image-active |
    | add-button   |

  @regression @prep-data
  Scenario: Create a GPU image
    When I click element with test-id "add-button"
    Then I should see element with test-id on the page
    | test-id           |
    | image/name        |
    | image/displayName |    

    When I type value to element with test-id on the page
    | test-id           | value                |
    | image/name        | e2e-test-image-gpu   |
    | image/displayName | e2e-test-image-gpu   |

    And I click element with xpath "//a/span[text()='Confirm']"
    Then I should see element with test-id on the page
    | test-id      |
    | image-active |
    | add-button   |

  @regression @prep-data
  Scenario: Update a GPU image
    When I search "e2e-test-image-gpu" in test-id "text-filter-name"
    Then I "should" see list-view table containing row with "e2e-test-image-gpu"

    When I click edit-button in row contains text "e2e-test-image-gpu"
    Then I should see input in test-id "image/name" with value "e2e-test-image-gpu"
    And I should see input in test-id "image/displayName" with value "e2e-test-image-gpu"

    When I type value to element with test-id on the page
    | test-id           | value                           |
    | image/displayName | e2e-test-image-display-name-gpu |
    | image/description | e2e-test-image-description-gpu  |

    And I click element with xpath on the page
    | xpath                               |
    | //div[@data-testid='image/type']//i |
    | //li[text()='GPU']                  |

    And I type "infuseai/docker-stacks:base-notebook-2d701645-gpu" to element with xpath "//div[@data-testid='image/url']//input"
    And I click element with xpath "//a/span[text()='Confirm']"
    Then I should see element with test-id on the page
    | test-id      |
    | image-active |
    | add-button   |

  @regression @prep-data
  Scenario: Connect a GPU image to an existing group
    When I search "e2e-test-image-gpu" in test-id "text-filter-name"
    Then I "should" see list-view table containing row with "e2e-test-image-gpu"

    When I click edit-button in row contains text "e2e-test-image-gpu"
    Then I should see input in test-id "image/name" with value "e2e-test-image-gpu"

    When I click element with test-id "connect-button"
    And I wait for 1.0 second
    And I search "e2e-test-group" in test-id "text-filter-name"
    Then I "should" see list-view table containing row with "e2e-test-group"

    And I click element with xpath on the page
    | xpath                                              |
    | //td[contains(text(), 'e2e-test-group')]/..//input |
    | //button/span[text()='OK']                         |

    And I wait for 1.0 second
    And I click element with xpath "//a/span[text()='Confirm']"
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
