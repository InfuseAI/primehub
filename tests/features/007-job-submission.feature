@released @ee
Feature: Job Submission
  Basic tests

  Scenario: User can create job
    Given I go to login page
    When I fill in the correct username credentials
    And I click login
    Then I am on the landing page
    When I click "Job Submission (Beta)" image in landing page
    Then I am on the job submission page
    When I click "Create Job" button
    Then I am on the create job page
    When I choose group with name "e2e-test-group-display-name" in create job page
    And I choose radio button with name "test-instance-type"
    And I choose radio button with name "test-image"
    And I type "create-job-test" to "displayName" text field
    And I type "echo 'test'" to "command" text field
    And I click "Submit" button
    Then I am on the job submission page
    And I wait for job completed
    And I wait for 0.5 seconds
    And I click link of "create-job-test" of 1th item on list
    Then I "should" see element with xpath "//div[text()='create-job-test']"
    And I click tab of "Logs"
    Then I should see "test" in element "div" under active tab
    When I logout from banner UI
    Then I am on login page

  Scenario: User can rerun job
    Given I go to login page
    When I fill in the correct username credentials
    And I click login
    Then I am on the landing page
    When I click "Job Submission (Beta)" image in landing page
    Then I am on the job submission page
    And I wait for 0.5 seconds
    When I click button of "Rerun" of item "create-job-test"
    Then I should see confirmation dialogue of "Rerun"
    And I click button of "Yes" on confirmation dialogue
    And I wait for 0.5 seconds
    And I click "Refresh" button
    Then I should see 1th column of 1th item is "Pending" on list
    And I wait for job completed
    And I wait for 0.5 seconds
    And I click link of "create-job-test" of 1th item on list
    Then I "should" see element with xpath "//div[text()='create-job-test']"
    And I click tab of "Logs"
    Then I should see "test" in element "div" under active tab
    When I logout from banner UI
    Then I am on login page

  Scenario: User can cancel job
    Given I go to login page
    When I fill in the correct username credentials
    And I click login
    Then I am on the landing page
    When I click "Job Submission (Beta)" image in landing page
    Then I am on the job submission page
    When I click "Create Job" button
    Then I am on the create job page
    When I choose group with name "e2e-test-group-display-name" in create job page
    And I choose radio button with name "test-instance-type"
    And I choose radio button with name "test-image"
    And I type "cancel-job-test" to "displayName" text field
    And I type "echo 'test'" to "command" text field
    And I click "Submit" button
    Then I am on the job submission page
    And I wait for 0.5 seconds
    And I click "Refresh" button
    And I wait for 0.5 seconds
    When I click button of "Cancel" of item "cancel-job-test"
    Then I should see confirmation dialogue of "Cancel"
    And I click button of "Yes" on confirmation dialogue
    And I wait for 0.5 seconds
    And I click "Refresh" button
    And I wait for 0.5 seconds
    Then I should see 1th column of 1th item is "Cancelled" on list
    And I click link of "cancel-job-test" of 1th item on list
    Then I "should" see element with xpath "//div[text()='cancel-job-test']"
    And I click tab of "Logs"
    Then I should see "cannot get log|(no data)" in element "div" under active tab
    When I logout from banner UI
    Then I am on login page
