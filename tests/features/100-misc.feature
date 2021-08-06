@feat-edition @ee
Feature: Features
  Available feature in different edition for different roles

  Background:
    Given I am logged in
    Then I am on the PrimeHub console "Home" page
    When I choose "Admin Portal" in top-right menu
    Then I am on the admin dashboard "Groups" page

  @regression
  Scenario: Admin can access pages in Admin Portal - Group and User in EE
    # Admin - Groups - Add
    When I click element with test-id "add-button"
    Then I should see element with test-id "group/name"
    And I click element with test-id "reset-button"

    # Admin - Groups - Search
    When I search "e2e-test-group" in test-id "text-filter-name"
    And I click edit-button in row contains text "e2e-test-group"
    Then I should see input in test-id "group/name" with value "e2e-test-group"

    # Users - edit - send email
    When I click "Users" in admin dashboard
    Then I am on the admin dashboard "Users" page
    When I search "e2e-test-group-user" in test-id "text-filter-username"
    And I click edit-button in row contains text "e2e-test-group-user"
    Then I should see input in test-id "user/username" with value "e2e-test-group-user"
    When I click tab of "Send Email"
    Then I "should" see element with xpath "//div[@aria-hidden='false']//span[text()='Reset Actions']"

  @regression
  Scenario: Admin can access pages in Admin Portal - Instance Types in EE
    # Admin - Instance Types
    When I click "Instance Types" in admin dashboard
    And I wait for 1.0 second
    Then I am on the admin dashboard "Instance Types" page
    And I "should" see element with xpath "//div[@class='ant-table-column-sorters']//span[text()='CPU Limit']"

    # Admin - Instance Types - Add 
    When I click element with test-id "add-button"
    Then I should see element with test-id "instanceType/name"

    # Admin - Instance Types - Add - Tolerations
    When I click tab of "Tolerations"
    Then I "should" see element with xpath "//div[@aria-hidden='false']//div[@data-testid='instanceType/tolerations']//div[text()='Key']"

    # Admin - Instance Types - Add - Node Selector
    When I click tab of "Node Selector"
    Then I "should" see element with xpath "//div[@aria-hidden='false']//div[@data-testid='instanceType/nodeSelector']//p[text()='There is no fields.']"    
    And I wait for 1.0 second
    And I click element with test-id "reset-button"
    Then I am on the admin dashboard "Instance Types" page

    # Admin - Instance Types - Search
    When I search "e2e-test-instance-type" in test-id "text-filter-name"
    And I click edit-button in row contains text "e2e-test-instance-type"
    Then I should see input in test-id "instanceType/name" with value "e2e-test-instance-type"

  @regression
  Scenario: Admin can access pages in Admin Portal - Images and Image Builder in EE
    # Admin - Images
    When I click "Images" in admin dashboard
    Then I "should" see element with xpath "//h2//span[text()='Images']"

    # Admin - Image Builder - Add
    When I click "Image Builder" in admin dashboard
    Then I am on the admin dashboard "Image Builder" page
    When I click element with test-id "add-button"
    Then I should see element with test-id "buildImage/name"
    And I click element with test-id "reset-button"
    Then I am on the admin dashboard "Image Builder" page

    # Admin - Image Builder - Edit
    # When I click element with test-id "edit-button"
    # Then I "should" see element with xpath "//div[@aria-hidden='false']//span[text()='Base Image']"

    # Admin - Image Builder - existing - job
    # Then I click tab of "Jobs"
    # Then I "should" see element with xpath "//div[@aria-hidden='false']//span[text()='Image Revision']"

    # Admin - Image Builder - existing - view
    # When I click element with test-id "view-button"
    # Then I "should" see element with xpath "//div[@data-testid='buildImageJob/logEndpoint']//div[text()='Please download the log to view more than 2000 lines.']"

  @regression
  Scenario: Admin can access pages in Admin Portal - Datasets and Secrets in EE
    # Admin - Datasets
    When I click "Datasets" in admin dashboard
    Then I am on the admin dashboard "Datasets" page
    And I "should" see element with xpath "//h2//span[text()='Datasets']"
    And I "should" see element with xpath "//div[@class='ant-table-column-sorters' and text()='Upload Server']"
     
    # Secrets - add
    # When I click "Secrets" in admin dashboard
    # Then I am on the admin dashboard "Secrets" page
    # When I click element with test-id "add-button"
    # Then I should see element with test-id "secret/name"

    # Secrets - edit
    # And I wait for 2.0 seconds
    # And I click element with test-id "reset-button"
    # Then I am on the admin dashboard "Secrets" page

  @regression
  Scenario: Admin can access pages in Admin Portal - Usage Reports and System Settings in EE
    # Usage Reports
    # When I click "Usage Reports" in admin dashboard
    # Then I am on the admin dashboard "Usage Reports" page
    # And I "should" see element with xpath "//div[contains(., 'Summary Report')]"
    # And I "should" see element with xpath "//div[contains(., 'Detailed Report')]"

    # System Settings
    When I click "System Settings" in admin dashboard
    Then I am on the admin dashboard "System Settings" page
    And I "should" see element with xpath "//div[@class='ant-card-head-title' and contains(text(), 'PrimeHub License')]"
    And I "should" see element with xpath "//div[@class='ant-card-head-title' and contains(text(), 'System Settings')]"
    And I "should" see element with xpath "//div[@class='ant-card-head-title' and contains(text(), 'Email Settings')]"    

  @regression
  Scenario: User can access pages in User Portal in EE
    # Go to user portal
    When I click element with xpath "//a[contains(text(), 'Back to User Portal')]"
    Then I "should" see element with xpath "//h2[text()='User Guide']"

    # Shared Files
    When I choose "Shared Files" in sidebar menu
    Then I "should" see element with xpath "//a[text()='Shared Files']"

  @regression
  Scenario: User can access items via the top right menu in EE
    # User Profile
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
    When I choose "Logout" in top-right menu
    Then I am on login page
