@feat @feat-jobs @ee
Feature: Job Submission
  Basic tests

  Background: 
    Given I am logged in
    Then I am on the PrimeHub console "Home" page

    When I choose group with name "e2e-test-group-display-name"
    And I keep group resource data
    And I choose "Jobs" in sidebar menu
    Then I am on the PrimeHub console "Jobs" page

  @regression @sanity @smoke
  Scenario: User can create job and save artifact
    When I click "New Job" button
    Then I am on the PrimeHub console "NewJob" page

    When I choose radio button with name "e2e-test-instance-type"
    And I choose radio button with name "e2e-test-image"
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

  @wip @regression @sanity
  Scenario: User can create job with group image and save artifact
    When I click "New Job" button
    Then I am on the PrimeHub console "NewJob" page

    When I choose radio button with name "e2e-test-instance-type"
    And I click element with xpath "//div[@id='image']//input[contains(@value, 'e2e-test-group-image')]"
    And I type "e2e-test-group-image" to "displayName" text field
    And I type "artifact test" to command text field
    And I click "Submit" button
    Then I am on the PrimeHub console "Jobs" page

    When I click element with xpath "//tr[1]//a[text()='e2e-test-group-image']" and wait for navigation
    Then I wait for attribute "Status" with value "Succeeded" in job upper pane
    And I wait for attribute "Message" with value "Job completed"

    When I click tab of "Artifacts"
    And I click element with xpath "//a[text()='sub/test.txt']"
    And I switch to "sub/test.txt" tab
    Then I "should" see element with xpath "//pre[contains(text(), 'hello from sub')]"
    And I switch to "JobDetail" tab

    When I click tab of "Logs"
    Then I should see "test" in element "div" under active tab

  @regression
  Scenario: User can rerun job
    When I click button of "Rerun" of item "create-job-test" to wait for "Rerun" dialogue
    And I click button of "Yes" on confirmation dialogue
    Then I should see 1th column of 1th item is "Pending|Preparing|Running" on list

    When I click on PrimeHub icon
    Then I am on the PrimeHub console "Home" page
    # And I should see group resource data with diff of CPU, memory & GPU: 0.5, 1.0, 0
 
    When I choose "Jobs" in sidebar menu
    Then I am on the PrimeHub console "Jobs" page

    When I click element with xpath "//tr[1]//a[text()='create-job-test']" and wait for navigation
    Then I wait for attribute "Status" with value "Succeeded" in job upper pane
    And I wait for attribute "Message" with value "Job completed"

    When I click tab of "Logs"
    Then I should see "test" in element "div" under active tab

  @regression
  Scenario: User can clone job
    When I click element with xpath "//i[@aria-label='icon: copy']" and wait for navigation
    Then I am on the PrimeHub console "NewJob" page
    And I type "clone-job-test" to "displayName" text field
    And I type "clone test" to command text field
    And I click "Submit" button

    When I click on PrimeHub icon
    Then I am on the PrimeHub console "Home" page
    # And I should see group resource data with diff of CPU, memory & GPU: 0.5, 1.0, 0

    When I choose "Jobs" in sidebar menu
    Then I am on the PrimeHub console "Jobs" page

    When I click element with xpath "//tr[1]//a[text()='clone-job-test']" and wait for navigation
    Then I wait for attribute "Status" with value "Succeeded" in job upper pane
    And I wait for attribute "Message" with value "Job completed"

    When I click tab of "Logs"
    Then I should see "clone-test" in element "div" under active tab

  @regression
  Scenario: User can cancel job
    When I click "New Job" button
    Then I am on the PrimeHub console "NewJob" page

    When I choose radio button with name "e2e-test-instance-type"
    And I choose radio button with name "e2e-test-image"
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
    And I should see group resource data with diff of CPU, memory & GPU: 0, 0, 0

  @wip @regression
  Scenario: User can create job with GPU
    When I click "New Job" button
    Then I am on the PrimeHub console "NewJob" page

    When I choose radio button with name "e2e-test-instance-type-gpu"
    And I choose radio button with name "e2e-test-image-gpu"
    And I type "gpu-job-test" to "displayName" text field
    And I type "gpu driver info" to command text field
    And I click "Submit" button
    Then I am on the PrimeHub console "Jobs" page

    When I click on PrimeHub icon
    Then I am on the PrimeHub console "Home" page

    When I choose "Jobs" in sidebar menu
    Then I am on the PrimeHub console "Jobs" page

    When I click element with xpath "//tr[1]//a[text()='gpu-job-test']" and wait for navigation
    Then I wait for attribute "Status" with value "Succeeded" in job upper pane
    And I wait for attribute "Message" with value "Job completed"

    When I click tab of "Monitoring"
    Then I "should" see element with xpath "//div[@class='']//h3[text()='GPU Device Usage']"

    When I click tab of "Logs"
    Then I should see the property "textContent" of element with xpath "//div[contains(@style, 'position: absolute')]" is matched the regular expression "NVIDIA-SMI\s+\d+\.\d+\.\d+\s+Driver Version:\s+\d+\.\d+\.\d+\s+CUDA Version:\s+\d+\.\d+"

    When I click on PrimeHub icon
    Then I am on the PrimeHub console "Home" page
