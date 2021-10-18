@feat-deployment @ee @deploy
Feature: Model Deployment
  Basic tests

  Background:
    Given I am logged in
    Then I am on the PrimeHub console "Home" page

    When I choose group with name "e2e-test-group-display-name"
    And I keep group resource data
    And I choose "Deployments" in sidebar menu
    Then I am on the PrimeHub console "Deployments" page

  @regression @smoke
  Scenario: User can see notification when model deployment is disabled
    And I "should" see element with xpath "//span[text()='Model Deployment is not enabled for this group. Please contact your administrator to enable it.']"

  @regression @smoke
  Scenario: Admin can enable model deployment for a group
    When I choose "Admin Portal" in top-right menu
    Then I am on the admin portal "Groups" page

    When I search "e2e-test-group" in test-id "text-filter-name"
    And I click edit-button in row containing text "e2e-test-group"
    Then I should see element with test-id "group/enabledDeployment"
    And I check boolean input with test-id "group/enabledDeployment"
    And I click element with test-id "confirm-button"
    Then I am on the admin portal "Groups" page

    When I click on PrimeHub icon
    Then I am on the PrimeHub console "Home" page
    And I choose group with name "e2e-test-group-display-name"

    When I choose "Deployments" in sidebar menu
    Then I am on the PrimeHub console "Deployments" page

    When I click "Create Deployment" button
    Then I am on the PrimeHub console "CreateDeployment" page

  @regression
  Scenario: User can create a deployment
    When I click "Create Deployment" button
    Then I am on the PrimeHub console "CreateDeployment" page

    When I type "create-deployment-test" to "name" text field
    And I wait for 1.0 second
    And I click element with xpath "//input[@type='checkbox']"
    Then I should see the property "value" of element with xpath "//input[@id='id']" is matched the regular expression "create-deployment-test-[a-z0-9][a-z0-9-]{1,61}[a-z0-9]"

    When I type "customizable-deployment-id" to "id" text field
    And I choose radio button with name "e2e-test-instance-type" and e2e suffix
    And I type "infuseai/model-tensorflow2-mnist:v0.1.0" to "modelImage input" text field
    And I click element with xpath "//span[text()='Deploy']"
    Then I am on the PrimeHub console "Deployments" page
    
  @regression
  Scenario: User can check details of a deployment
    When I go to the deployment detail page with name "create-deployment-test"
    Then I wait for attribute "Status" with value "Deployed"
    And I wait for attribute "Model Image" with value "infuseai/model-tensorflow2-mnist:v0.1.0"

    When I click tab of "Logs"
    Then I should see "Running on http://0.0.0.0:9000/" in element "div" under active tab

    When I click tab of "History"
    And I click element with xpath "//a[text()='View']"
    Then I wait for attribute "Deployment Stopped" with value "False"
    And I click escape

  @regression @error-check
  Scenario: User can't set the invalid/empty/duplicate deployment ID
    When I click "Create Deployment" button
    Then I am on the PrimeHub console "CreateDeployment" page

    When I click element with xpath "//input[@type='checkbox']"
    And I type "-)(*&^%$#@!" to "id" text field
    Then I "should" see element with xpath "//div[text()=\"lower case alphanumeric characters, '-', and must start and end with an alphanumeric character.\"]"

    When I type "" to "id" text field
    Then I "should" see element with xpath "//div[text()='Please input an ID']"

    When I type "customizable-deployment-id" to "id" text field
    Then I "should" see element with xpath "//div[text()='The ID has been used by other users. Change your ID to a unique string to try again.']"

  @regression
  Scenario: User can update a deployment
    When I go to the deployment detail page with name "create-deployment-test"
    And I click "Update" button
    Then I "should" see element with xpath "//input[@id='id' and @disabled]"

    When I type "infuseai/model-tensorflow2-mnist:v0.2.0" to "modelImage input" text field
    And I click "Confirm and Deploy" button
    Then I am on the PrimeHub console "Deployments" page

    When I go to the deployment detail page with name "create-deployment-test"
    Then I wait for attribute "Status" with value "Deployed"
    And I wait for attribute "Model Image" with value "infuseai/model-tensorflow2-mnist:v0.2.0"

    When I click tab of "Logs"
    Then I should see "Running on http://0.0.0.0:9000/|loading..." in element "div" under active tab

    When I click tab of "History"
    And I click element with xpath "//a[text()='View']"
    Then I wait for attribute "Model Image" with value "infuseai/model-tensorflow2-mnist:v0.2.0"
    And I click escape

  @regression
  Scenario: User can use an updated deployment in jobs
    When I go to the deployment detail page with name "create-deployment-test"
    And I copy value from "Endpoint" attribute

    When I choose "Jobs" in sidebar menu
    Then I am on the PrimeHub console "Jobs" page

    When I click "New Job" button
    Then I am on the PrimeHub console "NewJob" page

    When I choose radio button with name "e2e-test-instance-type" and e2e suffix
    And I choose radio button with name "e2e-test-image" and e2e suffix
    And I type "deployment-endpoint-test" to "displayName" text field
    And I type "endpoint curl test" to command text field
    And I click "Submit" button
    Then I am on the PrimeHub console "Jobs" page

    When I click element with xpath "//tr[1]//a[text()='deployment-endpoint-test']" and wait for navigation
    Then I wait for attribute "Status" with value "Succeeded" in job upper pane

    When I click tab of "Logs"
    Then I should see "predicted_number ...Download to see more... 3127632811083e-06" in element "div" under active tab

  @regression
  Scenario: User can stop a deployment
    When I go to the deployment detail page with name "create-deployment-test"
    And I click "Stop" button
    And I click button of "Yes" on confirmation dialogue
    Then I wait for attribute "Status" with value "Stopped"

    When I click tab of "History"
    And I click element with xpath "//a[text()='View']"
    Then I wait for attribute "Deployment Stopped" with value "True"
    And I click escape

  @regression
  Scenario: User cannot use a stopped deployment in jobs
    When I choose "Jobs" in sidebar menu
    Then I am on the PrimeHub console "Jobs" page

    When I click button of "Rerun" of item "deployment-endpoint-test" to wait for "Rerun" dialogue
    And I click button of "Yes" on confirmation dialogue
    Then I should see 1th column of 1th item is "Pending|Preparing|Running" on list

    When I click element with xpath "//tr[1]//a[text()='deployment-endpoint-test']" and wait for navigation
    Then I wait for attribute "Status" with value "Succeeded" in job upper pane

    When I click tab of "Logs"
    Then I should see "503 Service Temporarily Unavailable" in element "div" under active tab

    When I click on PrimeHub icon
    Then I am on the PrimeHub console "Home" page
    And I should see group resource data with diff of CPU, memory & GPU: -0.5, -1.0, 0
   
  @regression
  Scenario: User can start a stopped deployment
    When I choose "Deployments" in sidebar menu
    Then I am on the PrimeHub console "Deployments" page

    When I go to the deployment detail page with name "create-deployment-test"
    When I click tab of "Information"
    And I click "Start" button
    And I click button of "Yes" on confirmation dialogue
    Then I wait for attribute "Status" with value "Deployed"

    When I click tab of "Logs"
    Then I should see "Running on http://0.0.0.0:9000/|loading..." in element "div" under active tab

    When I click tab of "History"
    And I click element with xpath "//a[text()='View']"
    Then I wait for attribute "Deployment Stopped" with value "False"
    And I click escape

  @regression
  Scenario: User can rerun a job with deployment
    When I choose "Jobs" in sidebar menu
    Then I am on the PrimeHub console "Jobs" page

    When I click button of "Rerun" of item "deployment-endpoint-test" to wait for "Rerun" dialogue
    And I click button of "Yes" on confirmation dialogue
    Then I should see 1th column of 1th item is "Pending|Preparing|Running" on list

    When I click element with xpath "//tr[1]//a[text()='deployment-endpoint-test']" and wait for navigation
    Then I wait for attribute "Status" with value "Succeeded" in job upper pane

    When I click tab of "Logs"
    Then I should see "predicted_number ...Download to see more... 3127632811083e-06|503 Service Temporarily Unavailable" in element "div" under active tab

  @regression
  Scenario: User can delete deployment
    When I go to the deployment detail page with name "create-deployment-test"
    And I click "Delete" button
    And I type "create-deployment-test" to element with xpath "//input[@id='delete-deployment']"
    And I click button of "Delete" on deletion confirmation dialogue
    Then I am on the PrimeHub console "Deployments" page
    And I "should not" see element with xpath "//div[@class='ant-col-xs-24 ant-col-md-12 ant-col-xl-8 ant-col-xxl-6']//div[text()='create-deployment-test']"

    When I click on PrimeHub icon
    Then I am on the PrimeHub console "Home" page
    And I should see group resource data with diff of CPU, memory & GPU: 0, 0, 0

  @regression
  Scenario: Model URI: User can create deployment
    When I click "Create Deployment" button
    Then I am on the PrimeHub console "CreateDeployment" page

    When I type "model-uri-test" to "name" text field
    And I choose radio button with name "e2e-test-instance-type" and e2e suffix
    And I type "infuseai/tensorflow2-prepackaged_rest:v0.4.2" to "modelImage input" text field
    And I type "gs://primehub-models/tensorflow2/mnist/" to "modelURI" text field
    And I click element with xpath "//span[text()='Deploy']"
    Then I am on the PrimeHub console "Deployments" page

    When I go to the deployment detail page with name "model-uri-test"
    Then I wait for attribute "Status" with value "Deployed"
    And I wait for attribute "Model Image" with value "infuseai/tensorflow2-prepackaged_rest:v0.4.2"
    And I wait for attribute "Model URI" with value "gs://primehub-models/tensorflow2/mnist/"
    When I click tab of "Logs"
    Then I should see "Running on http://0.0.0.0:9000/" in element "div" under active tab

    When I click tab of "History"
    And I click element with xpath "//a[text()='View']"
    Then I wait for attribute "Deployment Stopped" with value "False"
    And I click escape

  @regression
  Scenario: Model URI: User can update deployment
    When I go to the deployment detail page with name "model-uri-test"
    And I click "Update" button
    And I type "gs://seldon-models/keras/mnist" to "modelURI" text field
    And I click "Confirm and Deploy" button
    Then I am on the PrimeHub console "Deployments" page

    When I go to the deployment detail page with name "model-uri-test"
    Then I wait for attribute "Status" with value "Deployed"
    And I wait for attribute "Model URI" with value "gs://seldon-models/keras/mnist"

    When I click tab of "Logs"
    Then I should see "Running on http://0.0.0.0:9000/|loading..." in element "div" under active tab

    When I click tab of "History"
    And I click element with xpath "//a[text()='View']"
    Then I wait for attribute "Model URI" with value "gs://seldon-models/keras/mnist"
    And I click escape

  @regression
  Scenario: Model URI: User can use an updated deployment in jobs
    When I go to the deployment detail page with name "model-uri-test"
    And I copy value from "Endpoint" attribute

    When I choose "Jobs" in sidebar menu
    Then I am on the PrimeHub console "Jobs" page

    When I click "New Job" button
    Then I am on the PrimeHub console "NewJob" page

    When I choose radio button with name "e2e-test-instance-type" and e2e suffix
    And I choose radio button with name "e2e-test-image" and e2e suffix
    And I type "deployment-endpoint-test" to "displayName" text field
    And I type "endpoint curl test" to command text field
    And I click "Submit" button
    Then I am on the PrimeHub console "Jobs" page

    When I click element with xpath "//tr[1]//a[text()='deployment-endpoint-test']" and wait for navigation
    Then I wait for attribute "Status" with value "Succeeded" in job upper pane

    When I click tab of "Logs"
    Then I should see "...Download to see more... 305647406407e-07" in element "div" under active tab

  @regression
  Scenario: Model URI: User can stop a deployment
    When I go to the deployment detail page with name "model-uri-test"
    And I click "Stop" button
    And I click button of "Yes" on confirmation dialogue
    Then I wait for attribute "Status" with value "Stopped"

    When I click tab of "History"
    And I click element with xpath "//a[text()='View']"
    Then I wait for attribute "Deployment Stopped" with value "True"
    And I click escape

  @regression
  Scenario: Model URI: User can start a deployment
    When I go to the deployment detail page with name "model-uri-test"
    When I click tab of "Information"
    And I click "Start" button
    And I click button of "Yes" on confirmation dialogue
    Then I wait for attribute "Status" with value "Deployed"

    When I click tab of "Logs"
    Then I should see "Running on http://0.0.0.0:9000/|loading..." in element "div" under active tab

    When I click tab of "History"
    And I click element with xpath "//a[text()='View']"
    Then I wait for attribute "Deployment Stopped" with value "False"
    And I click escape

    When I choose "Jobs" in sidebar menu
    Then I am on the PrimeHub console "Jobs" page

    When I click button of "Rerun" of item "deployment-endpoint-test" to wait for "Rerun" dialogue
    And I click button of "Yes" on confirmation dialogue
    Then I should see 1th column of 1th item is "Pending|Preparing|Running" on list

    When I click element with xpath "//tr[1]//a[text()='deployment-endpoint-test']" and wait for navigation
    Then I wait for attribute "Status" with value "Succeeded" in job upper pane

    When I click tab of "Logs"
    Then I should see "...Download to see more... 305647406407e-07|503 Service Temporarily Unavailable" in element "div" under active tab

  @regression
  Scenario: Model URI: User can delete deployment
    When I go to the deployment detail page with name "model-uri-test"
    And I click "Delete" button
    And I type "model-uri-test" to element with xpath "//input[@id='delete-deployment']"
    And I click button of "Delete" on deletion confirmation dialogue
    Then I am on the PrimeHub console "Deployments" page
    And I "should not" see element with xpath "//div[@class='ant-col-xs-24 ant-col-md-12 ant-col-xl-8 ant-col-xxl-6']//div[text()='model-uri-test']"

  @wip @regression
  Scenario: User can create deployment with GPU
    When I click "Create Deployment" button
    Then I am on the PrimeHub console "CreateDeployment" page

    When I type "create-deployment-test-gpu" to "name" text field
    And I choose radio button with name "e2e-test-instance-type-gpu" and e2e suffix
    And I type "infuseai/model-tensorflow2-mnist:v0.2.0" to "modelImage input" text field
    And I click element with xpath "//span[text()='Deploy']"
    Then I am on the PrimeHub console "Deployments" page

    When I go to the deployment detail page with name "create-deployment-test-gpu"
    Then I wait for attribute "Status" with value "Deployed"
    And I wait for attribute "Model Image" with value "infuseai/model-tensorflow2-mnist:v0.2.0"

    When I click tab of "Logs"
    Then I should see the property "textContent" of element with xpath "//div[contains(@style, 'position: absolute')]" is matched the regular expression "kernel reported version is:\s+\d+\.\d+\.\d+"

  @wip @regression
  Scenario: User can delete deployment with GPU
    When I go to the deployment detail page with name "create-deployment-test-gpu"
    And I click "Delete" button
    And I type "create-deployment-test-gpu" to element with xpath "//input[@id='delete-deployment']"
    And I click button of "Delete" on deletion confirmation dialogue
    Then I am on the PrimeHub console "Deployments" page
    And I "should not" see element with xpath "//div[@class='ant-col-xs-24 ant-col-md-12 ant-col-xl-8 ant-col-xxl-6']//div[text()='create-deployment-test-gpu']"

    When I click on PrimeHub icon
    Then I am on the PrimeHub console "Home" page
    And I wait for 1.0 second
    And I click refresh
    # And I should see group resource data with diff of CPU, memory & GPU: -1.0, -1.0, -1.0
