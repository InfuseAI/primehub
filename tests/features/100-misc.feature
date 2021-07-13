@released @daily
Feature: MISC
  Miscellaneous tests
  
  Scenario: User can access every single page
    Given I go to login page
    When I fill in the correct username credentials
    And I click login
    Then I am on the PrimeHub console "Home" page
    And I choose group with name "e2e-test-group-display-name"
    # Landing page
    Then I "should" see element with xpath "//h2[text()='User Guide']"
    # TODO: add tests for landing page component
    #When I click element with xpath "//div[contains(@style, 'support.png')]"
    #And I switch to "UserGuide" tab
    #Then I "should" see element with xpath "//small[text()='Effortless Infrastructure for Machine Learning']"
    #When I switch to "Home" tab
    #Then I am on the PrimeHub console "Home" page
    # Shared Files
    When I choose "Shared Files" in sidebar menu
    Then I am on the PrimeHub console "SharedFiles" page
    # API Token
    When I choose "API Token" in top-right menu
    Then I "should" see element with xpath "//button//span[text()='Request API Token']"
    # Groups - add - dataset
    When I choose "Admin Portal" in top-right menu
    Then I am on the admin dashboard "Groups" page
    When I click element with test-id "add-button"
    Then I should see element with test-id "group/name"
    When I click tab of "Datasets"
    Then I "should" see element with xpath "//div[@aria-hidden='false']//div[@data-testid='group/datasets']//span[text()='Permissions']"
    # Groups - add - image
    When I click tab of "Images"
    Then I "should" see element with xpath "//div[@aria-hidden='false']//div[@data-testid='group/images']//span[text()='Type']"
    # Groups - add - instanceType
    When I click tab of "Instance Types"
    Then I "should" see element with xpath "//div[@aria-hidden='false']//div[@data-testid='group/instanceTypes']//span[text()='CPU Limit']"
    # Groups - edit - dataset
    When I click button of "Back"
    And I wait for 2.0 seconds
    And I click button of "Discard"
    #When I click tab of "Info"
    #And I wait for 2.0 seconds
    #And I click element with test-id "reset-button"
    Then I am on the admin dashboard "Groups" page
    When I search "e2e-test-group" in test-id "text-filter-name"
    And I click edit-button in row contains text "e2e-test-group"
    Then I should see input in test-id "group/name" with value "e2e-test-group"
    When I click tab of "Datasets"
    Then I "should" see element with xpath "//div[@aria-hidden='false']//div[@data-testid='group/datasets']//tr[contains(@class, 'ant-table-row')]"
    # Groups - edit - image
    When I click tab of "Images"
    Then I "should" see element with xpath "//div[@aria-hidden='false']//div[@data-testid='group/images']//tr[contains(@class, 'ant-table-row')]"
    # Groups - edit - instanceType
    When I click tab of "Instance Types"
    Then I "should" see element with xpath "//div[@aria-hidden='false']//div[@data-testid='group/instanceTypes']//tr[contains(@class, 'ant-table-row')]"
    # Users - edit - send email
    When I click "Users" in admin dashboard
    Then I am on the admin dashboard "Users" page
    When I search "test-user" in test-id "text-filter-username"
    And I click edit-button in row contains text "test-user"
    Then I should see input in test-id "user/username" with value "test-user"
    When I click tab of "Send Email"
    Then I "should" see element with xpath "//div[@aria-hidden='false']//span[text()='Reset Actions']"
    # instanceTypes - add - tolerations
    When I click "Instance Types" in admin dashboard
    Then I am on the admin dashboard "Instance Types" page
    When I click element with test-id "add-button"
    Then I should see element with test-id "instanceType/name"
    When I click tab of "Tolerations"
    Then I "should" see element with xpath "//div[@aria-hidden='false']//div[@data-testid='instanceType/tolerations']//div[text()='Key']"
    # instanceTypes - add - nodeSelector
    When I click tab of "Node Selector"
    Then I "should" see element with xpath "//div[@aria-hidden='false']//div[@data-testid='instanceType/nodeSelector']//p[text()='There is no fields.']"    
    # instanceTypes - edit - tolerations
    And I wait for 2.0 seconds
    And I click element with test-id "reset-button"
    Then I am on the admin dashboard "Instance Types" page
    When I search "test-instance-type" in test-id "text-filter-name"
    And I click edit-button in row contains text "test-instance-type"
    Then I should see input in test-id "instanceType/name" with value "test-instance-type"
    When I click tab of "Tolerations"
    Then I "should" see element with xpath "//div[@aria-hidden='false']//div[@data-testid='instanceType/tolerations']//div[text()='Key']"
    # instanceTypes - edit - nodeSelector
    When I click tab of "Node Selector"
    Then I "should" see element with xpath "//div[@aria-hidden='false']//div[@data-testid='instanceType/nodeSelector']//p[text()='There is no fields.']"    
    # imageBuilders - add
    When I click "Image Builder" in admin dashboard
    Then I am on the admin dashboard "Image Builder" page
    When I click element with test-id "add-button"
    Then I should see element with test-id "buildImage/name"
    # imageBuilders - existing - info
    And I wait for 2.0 seconds
    And I click element with test-id "reset-button"
    Then I am on the admin dashboard "Image Builder" page
    When I click element with test-id "edit-button"
    Then I "should" see element with xpath "//div[@aria-hidden='false']//span[text()='Base Image']"
    # imageBuilders - existing - job
    When I click tab of "Jobs"
    Then I "should" see element with xpath "//div[@aria-hidden='false']//span[text()='Image Revision']"
    # imageBuilders - existing - job - info
    When I click element with test-id "view-button"
    Then I "should" see element with xpath "//div[@data-testid='buildImageJob/logEndpoint']//div[text()='Please download the log to view more than 2000 lines.']"
    # Secrets - add
    When I click "Secrets" in admin dashboard
    Then I am on the admin dashboard "Secrets" page
    When I click element with test-id "add-button"
    Then I should see element with test-id "secret/name"
    # Secrets - edit
    And I wait for 2.0 seconds
    And I click element with test-id "reset-button"
    Then I am on the admin dashboard "Secrets" page
    When I click element with test-id "edit-button"
    Then I should see element with test-id "secret/name"
    # Notebooks Admin
    When I click "Notebooks Admin" in admin dashboard
    Then I go to the notebooks admin page
    And I "should" see element with xpath "//a[text()='delete user']" in hub
    # Usage Reports
    When I click "Usage Reports" in admin dashboard
    Then I am on the admin dashboard "Usage Reports" page
    And I should see element with test-id "view-button"
    # System Settings
    When I click "System Settings" in admin dashboard
    Then I am on the admin dashboard "System Settings" page
    And I "should" see element with xpath "//div[@class='ant-card-head-title' and contains(text(), 'PrimeHub License')]"
    And I "should" see element with xpath "//div[@class='ant-card-head-title' and contains(text(), 'System Settings')]"
    And I "should" see element with xpath "//div[@class='ant-card-head-title' and contains(text(), 'Email Settings')]"    
    # User Profile
    When I choose "User Profile" in top-right menu
    Then I "should" see element with xpath "//label[text()='Username']"
    # Change Password
    When I click "Back to PrimeHub" button
    Then I am on the admin dashboard "Groups" page
    When I choose "Change Password" in top-right menu
    Then I "should" see element with xpath "//label[text()='Confirmation']"
    When I click "Back to PrimeHub" button
    Then I am on the admin dashboard "Groups" page
    When I choose "Logout" in top-right menu
    Then I am on login page
