@released @ee
Feature: Job Submission
  Basic tests

  Scenario: User can create job and save artifact
    Given I go to login page
    When I fill in the correct username credentials
    And I click login
    Then I am on the PrimeHub console "Home" page
    And I choose group with name "e2e-test-group-display-name"
    When I choose "Jobs" in sidebar menu
    Then I am on the PrimeHub console "Jobs" page
    When I click "New Job" button
    Then I am on the PrimeHub console "NewJob" page
    When I choose radio button with name "test-instance-type"
    And I choose radio button with name "test-image"
    And I type "create-job-test" to "displayName" text field
    And I type "artifact test" to command text field
    And I click "Submit" button
    Then I am on the PrimeHub console "Jobs" page
    When I click element with xpath "//tr[1]//a[text()='create-job-test']" and wait for navigation
    Then I wait for attribute "Status" with value "Succeeded" in job upper pane
    And I wait for attribute "Message" with value "Job completed"
    When I click tab of "Artifacts"
    And I click element with xpath "//a[text()='sub/test.txt']"
    And I switch to "sub/test.txt" tab
    Then I "should" see element with xpath "//pre[contains(text(), 'hello from sub')]"
    And I switch to "JobDetail" tab
    When I click tab of "Logs"
    Then I should see "test" in element "div" under active tab
    When I choose "Logout" in top-right menu
    Then I am on login page

  @normal-user
  Scenario: User can create job with group image and save artifact
    Given I go to login page
    When I fill in the correct username credentials
    And I click login
    Then I am on the PrimeHub console "Home" page
    And I choose group with name "e2e-test-group-display-name"
    When I choose "Jobs" in sidebar menu
    Then I am on the PrimeHub console "Jobs" page
    When I click "New Job" button
    Then I am on the PrimeHub console "NewJob" page
    When I choose radio button with name "test-instance-type"
    And I click element with xpath "//div[@id='image']//input[contains(@value, 'test-group-image')]"
    And I type "group-image-test" to "displayName" text field
    And I type "artifact test" to command text field
    And I click "Submit" button
    Then I am on the PrimeHub console "Jobs" page
    When I click element with xpath "//tr[1]//a[text()='group-image-test']" and wait for navigation
    Then I wait for attribute "Status" with value "Succeeded" in job upper pane
    And I wait for attribute "Message" with value "Job completed"
    When I click tab of "Artifacts"
    And I click element with xpath "//a[text()='sub/test.txt']"
    And I switch to "sub/test.txt" tab
    Then I "should" see element with xpath "//pre[contains(text(), 'hello from sub')]"
    And I switch to "JobDetail" tab
    When I click tab of "Logs"
    Then I should see "test" in element "div" under active tab
    When I choose "Logout" in top-right menu
    Then I am on login page

  @daily
  Scenario: User can rerun job
    Given I go to login page
    When I fill in the correct username credentials
    And I click login
    Then I am on the PrimeHub console "Home" page
    And I choose group with name "e2e-test-group-display-name"
    And I should see group resources with CPU "0,2", Memory "0.0 GB,4 GB", GPU "0,2"
    When I choose "Jobs" in sidebar menu
    Then I am on the PrimeHub console "Jobs" page
    And I click button of "Rerun" of item "create-job-test" to wait for "Rerun" dialogue
    And I click button of "Yes" on confirmation dialogue
    Then I should see 1th column of 1th item is "Pending|Preparing|Running" on list
    When I click on PrimeHub icon
    Then I am on the PrimeHub console "Home" page
    And I should see group resources with CPU "0.5,2", Memory "1.0 GB,4 GB", GPU "0,2"
    When I choose "Jobs" in sidebar menu
    Then I am on the PrimeHub console "Jobs" page
    When I click element with xpath "//tr[1]//a[text()='create-job-test']" and wait for navigation
    Then I wait for attribute "Status" with value "Succeeded" in job upper pane
    And I wait for attribute "Message" with value "Job completed"
    When I click tab of "Logs"
    Then I should see "test" in element "div" under active tab
    When I choose "Logout" in top-right menu
    Then I am on login page

  @daily
  Scenario: User can clone job
    Given I go to login page
    When I fill in the correct username credentials
    And I click login
    Then I am on the PrimeHub console "Home" page
    And I choose group with name "e2e-test-group-display-name"
    And I should see group resources with CPU "0,2", Memory "0.0 GB,4 GB", GPU "0,2"
    When I choose "Jobs" in sidebar menu
    Then I am on the PrimeHub console "Jobs" page
    When I click element with xpath "//tr[1]//button[contains(., 'Clone')]" and wait for navigation
    Then I am on the PrimeHub console "NewJob" page
    And I type "clone-job-test" to "displayName" text field
    And I type "echo 'clone-test'" to "command" text field
    And I click "Submit" button
    Then I am on the PrimeHub console "Jobs" page
    When I click on PrimeHub icon
    Then I am on the PrimeHub console "Home" page
    And I should see group resources with CPU "0.5,2", Memory "1.0 GB,4 GB", GPU "0,2"
    When I choose "Jobs" in sidebar menu
    Then I am on the PrimeHub console "Jobs" page
    When I click element with xpath "//tr[1]//a[text()='clone-job-test']" and wait for navigation
    Then I wait for attribute "Status" with value "Succeeded" in job upper pane
    And I wait for attribute "Message" with value "Job completed"
    When I click tab of "Logs"
    Then I should see "clone-test" in element "div" under active tab
    When I choose "Logout" in top-right menu
    Then I am on login page

  @daily
  Scenario: User can cancel job
    Given I go to login page
    When I fill in the correct username credentials
    And I click login
    Then I am on the PrimeHub console "Home" page
    And I choose group with name "e2e-test-group-display-name"
    When I choose "Jobs" in sidebar menu
    Then I am on the PrimeHub console "Jobs" page
    When I click "New Job" button
    Then I am on the PrimeHub console "NewJob" page
    When I choose radio button with name "test-instance-type"
    And I choose radio button with name "test-image"
    And I type "cancel-job-test" to "displayName" text field
    And I type "echo 'test'" to "command" text field
    And I click "Submit" button
    Then I am on the PrimeHub console "Jobs" page
    And I click button of "Cancel" of item "cancel-job-test" to wait for "Cancel" dialogue
    And I click button of "Yes" on confirmation dialogue
    Then I should see 1th column of 1th item is "Cancelled" on list
    When I click element with xpath "//tr[1]//a[text()='cancel-job-test']" and wait for navigation
    Then I wait for attribute "Status" with value "Cancelled" in job upper pane
    And I wait for attribute "Message" with value "Cancelled by user"
    When I click tab of "Logs"
    Then I should see "cannot get log|(no data)" in element "div" under active tab
    When I click on PrimeHub icon
    Then I am on the PrimeHub console "Home" page
    And I should see group resources with CPU "0,2", Memory "0.0 GB,4 GB", GPU "0,2"
    When I choose "Logout" in top-right menu
    Then I am on login page

  @weekly
  Scenario: User can create job with GPU
    Given I go to login page
    When I fill in the correct username credentials
    And I click login
    Then I am on the PrimeHub console "Home" page
    And I choose group with name "e2e-test-group-display-name"
    When I choose "Jobs" in sidebar menu
    Then I am on the PrimeHub console "Jobs" page
    When I click "New Job" button
    Then I am on the PrimeHub console "NewJob" page
    When I choose radio button with name "test-instance-type-gpu"
    And I choose radio button with name "test-image-gpu"
    And I type "gpu-job-test" to "displayName" text field
    And I type "gpu driver info" to command text field
    And I click "Submit" button
    Then I am on the PrimeHub console "Jobs" page
    When I click element with xpath "//tr[1]//a[text()='gpu-job-test']" and wait for navigation
    Then I wait for attribute "Status" with value "Succeeded" in job upper pane
    And I wait for attribute "Message" with value "Job completed"
    When I click tab of "Monitoring"
    Then I "should" see element with xpath "//div[@class='']//h3[text()='GPU Device Usage']"
    When I click tab of "Logs"
    Then I should see "NVIDIA-SMI 418.67       Driver Version: 418.67       CUDA Version: 10.1" in element "div" under active tab
    When I choose "Logout" in top-right menu
    Then I am on login page
