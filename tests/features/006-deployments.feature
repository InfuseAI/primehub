@released @ee
Feature: Model Deployment
  Basic tests

  @admin-user
  Scenario: User can see expected results when model deployment enabled/disabled
    Given I go to login page
    When I fill in the correct username credentials
    And I click login
    Then I am on the PrimeHub console "Home" page
    And I choose group with name "e2e-test-group-display-name"
    When I choose "Deployments" in sidebar menu
    Then I am on the PrimeHub console "Deployments" page
    And I "should" see element with xpath "//span[text()='Model Deployment is not enabled for this group. Please contact your administrator to enable it.']"
    When I choose "Admin Portal" in top-right menu
    Then I am on the admin dashboard "Groups" page
    When I search "e2e-test-group" in test-id "text-filter-name"
    And I click edit-button in row contains text "e2e-test-group"
    Then I should see element with test-id "group/enabledDeployment"
    And I check boolean input with test-id "group/enabledDeployment"
    And I click element with test-id "confirm-button"
    When I click on PrimeHub icon
    Then I am on the PrimeHub console "Home" page
    And I choose group with name "e2e-test-group-display-name"
    When I choose "Deployments" in sidebar menu
    Then I am on the PrimeHub console "Deployments" page
    When I click "Create Deployment" button
    Then I am on the PrimeHub console "CreateDeployment" page
    When I choose "Logout" in top-right menu
    Then I am on login page

  Scenario: User can create deployment
    Given I go to login page
    When I fill in the correct username credentials
    And I click login
    Then I am on the PrimeHub console "Home" page
    And I choose group with name "e2e-test-group-display-name"
    When I choose "Deployments" in sidebar menu
    Then I am on the PrimeHub console "Deployments" page
    When I click "Create Deployment" button
    Then I am on the PrimeHub console "CreateDeployment" page
    When I type "create-deployment-test" to "name" text field
    And I choose radio button with name "test-instance-type"
    And I type "infuseai/model-tensorflow2-mnist:v0.1.0" to "modelImage input" text field
    And I click element with xpath "//span[text()='Deploy']"
    Then I am on the PrimeHub console "Deployments" page
    When I go to the deployment detail page with name "create-deployment-test"
    Then I wait for attribute "Status" with value "Deployed"
    And I wait for attribute "Model Image" with value "infuseai/model-tensorflow2-mnist:v0.1.0"
    When I click tab of "Logs"
    Then I should see "Running on http://0.0.0.0:9000/" in element "div" under active tab
    When I click tab of "History"
    And I click element with xpath "//a[text()='View']"
    Then I wait for attribute "Deployment Stopped" with value "False"
    And I click escape
    When I choose "Logout" in top-right menu
    Then I am on login page

  @daily
  Scenario: User can update deployment
    Given I go to login page
    When I fill in the correct username credentials
    And I click login
    Then I am on the PrimeHub console "Home" page
    And I choose group with name "e2e-test-group-display-name"
    #And I should see group resources with CPU "0.5,2", Memory "1.0 GB,4 GB", GPU "0,2"
    When I choose "Deployments" in sidebar menu
    Then I am on the PrimeHub console "Deployments" page
    When I go to the deployment detail page with name "create-deployment-test"
    And I click "Update" button
    And I type "infuseai/model-tensorflow2-mnist:v0.2.0" to "modelImage input" text field
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
    When I click tab of "Information"
    And I copy value from "Endpoint" attribute
    When I choose "Jobs" in sidebar menu
    Then I am on the PrimeHub console "Jobs" page
    When I click "New Job" button
    Then I am on the PrimeHub console "NewJob" page
    When I choose radio button with name "test-instance-type"
    And I choose radio button with name "test-image"
    And I type "deployment-endpoint-test" to "displayName" text field
    And I type "endpoint curl test" to command text field
    And I click "Submit" button
    Then I am on the PrimeHub console "Jobs" page
    When I click element with xpath "//tr[1]//a[text()='deployment-endpoint-test']" and wait for navigation
    Then I wait for attribute "Status" with value "Succeeded" in job upper pane
    When I click tab of "Logs"
    Then I should see "predicted_number ...Download to see more... 3127632811083e-06" in element "div" under active tab
    When I choose "Logout" in top-right menu
    Then I am on login page

  @daily
  Scenario: User can stop/start deployment
    Given I go to login page
    When I fill in the correct username credentials
    And I click login
    Then I am on the PrimeHub console "Home" page
    And I choose group with name "e2e-test-group-display-name"
    #And I should see group resources with CPU "0.5,2", Memory "1.0 GB,4 GB", GPU "0,2"
    When I choose "Deployments" in sidebar menu
    Then I am on the PrimeHub console "Deployments" page
    When I go to the deployment detail page with name "create-deployment-test"
    And I click "Stop" button
    And I click button of "Yes" on confirmation dialogue
    Then I wait for attribute "Status" with value "Stopped"
    When I click tab of "Logs"
    #Then I should see "loading...|cannot get log|(no data)" in element "div" under active tab
    When I click tab of "History"
    And I click element with xpath "//a[text()='View']"
    Then I wait for attribute "Deployment Stopped" with value "True"
    And I click escape
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
    #And I should see group resources with CPU "0,2", Memory "0.0 GB,4 GB", GPU "0,2"
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
    When I choose "Jobs" in sidebar menu
    Then I am on the PrimeHub console "Jobs" page
    When I click button of "Rerun" of item "deployment-endpoint-test" to wait for "Rerun" dialogue
    And I click button of "Yes" on confirmation dialogue
    Then I should see 1th column of 1th item is "Pending|Preparing|Running" on list
    When I click element with xpath "//tr[1]//a[text()='deployment-endpoint-test']" and wait for navigation
    Then I wait for attribute "Status" with value "Succeeded" in job upper pane
    When I click tab of "Logs"
    Then I should see "predicted_number ...Download to see more... 3127632811083e-06|503 Service Temporarily Unavailable" in element "div" under active tab
    When I choose "Logout" in top-right menu
    Then I am on login page

  @daily
  Scenario: User can delete deployment
    Given I go to login page
    When I fill in the correct username credentials
    And I click login
    Then I am on the PrimeHub console "Home" page
    And I choose group with name "e2e-test-group-display-name"
    #And I should see group resources with CPU "0.5,2", Memory "1.0 GB,4 GB", GPU "0,2"
    When I choose "Deployments" in sidebar menu
    Then I am on the PrimeHub console "Deployments" page
    When I go to the deployment detail page with name "create-deployment-test"
    And I click "Delete" button
    And I type "create-deployment-test" to element with xpath "//input[@id='delete-deployment']"
    And I click button of "Delete" on deletion confirmation dialogue
    Then I am on the PrimeHub console "Deployments" page
    And I "should not" see element with xpath "//div[@class='ant-card-body']//h2[text()='create-deployment-test']"
    When I click on PrimeHub icon
    Then I am on the PrimeHub console "Home" page
    #And I should see group resources with CPU "0,2", Memory "0.0 GB,4 GB", GPU "0,2"
    When I choose "Logout" in top-right menu
    Then I am on login page

  @daily
  Scenario: Model URI: User can create deployment
    Given I go to login page
    When I fill in the correct username credentials
    And I click login
    Then I am on the PrimeHub console "Home" page
    And I choose group with name "e2e-test-group-display-name"
    When I choose "Deployments" in sidebar menu
    Then I am on the PrimeHub console "Deployments" page
    When I click "Create Deployment" button
    Then I am on the PrimeHub console "CreateDeployment" page
    When I type "model-uri-test" to "name" text field
    And I choose radio button with name "test-instance-type"
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
    When I choose "Logout" in top-right menu
    Then I am on login page

  @daily
  Scenario: Model URI: User can update deployment
    Given I go to login page
    When I fill in the correct username credentials
    And I click login
    Then I am on the PrimeHub console "Home" page
    And I choose group with name "e2e-test-group-display-name"
    When I choose "Deployments" in sidebar menu
    Then I am on the PrimeHub console "Deployments" page
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
    When I click tab of "Information"
    And I copy value from "Endpoint" attribute
    When I choose "Jobs" in sidebar menu
    Then I am on the PrimeHub console "Jobs" page
    When I click "New Job" button
    Then I am on the PrimeHub console "NewJob" page
    When I choose radio button with name "test-instance-type"
    And I choose radio button with name "test-image"
    And I type "deployment-endpoint-test" to "displayName" text field
    And I type "endpoint curl test" to command text field
    And I click "Submit" button
    Then I am on the PrimeHub console "Jobs" page
    When I click element with xpath "//tr[1]//a[text()='deployment-endpoint-test']" and wait for navigation
    Then I wait for attribute "Status" with value "Succeeded" in job upper pane
    When I click tab of "Logs"
    Then I should see "...Download to see more... 305647406407e-07" in element "div" under active tab
    When I choose "Logout" in top-right menu
    Then I am on login page

  @daily
  Scenario: Model URI: User can stop/start deployment
    Given I go to login page
    When I fill in the correct username credentials
    And I click login
    Then I am on the PrimeHub console "Home" page
    And I choose group with name "e2e-test-group-display-name"
    When I choose "Deployments" in sidebar menu
    Then I am on the PrimeHub console "Deployments" page
    When I go to the deployment detail page with name "model-uri-test"
    And I click "Stop" button
    And I click button of "Yes" on confirmation dialogue
    Then I wait for attribute "Status" with value "Stopped"
    When I click tab of "Logs"
    #Then I should see "loading...|cannot get log|(no data)" in element "div" under active tab
    When I click tab of "History"
    And I click element with xpath "//a[text()='View']"
    Then I wait for attribute "Deployment Stopped" with value "True"
    And I click escape
    When I choose "Jobs" in sidebar menu
    Then I am on the PrimeHub console "Jobs" page
    When I click button of "Rerun" of item "deployment-endpoint-test" to wait for "Rerun" dialogue
    And I click button of "Yes" on confirmation dialogue
    Then I should see 1th column of 1th item is "Pending|Preparing|Running" on list
    When I click element with xpath "//tr[1]//a[text()='deployment-endpoint-test']" and wait for navigation
    Then I wait for attribute "Status" with value "Succeeded" in job upper pane
    When I click tab of "Logs"
    Then I should see "503 Service Temporarily Unavailable" in element "div" under active tab
    When I choose "Deployments" in sidebar menu
    Then I am on the PrimeHub console "Deployments" page
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
    When I choose "Logout" in top-right menu
    Then I am on login page

  @daily
  Scenario: Model URI: User can delete deployment
    Given I go to login page
    When I fill in the correct username credentials
    And I click login
    Then I am on the PrimeHub console "Home" page
    And I choose group with name "e2e-test-group-display-name"
    When I choose "Deployments" in sidebar menu
    Then I am on the PrimeHub console "Deployments" page
    When I go to the deployment detail page with name "model-uri-test"
    And I click "Delete" button
    And I type "model-uri-test" to element with xpath "//input[@id='delete-deployment']"
    And I click button of "Delete" on deletion confirmation dialogue
    Then I am on the PrimeHub console "Deployments" page
    And I "should not" see element with xpath "//div[@class='ant-card-body']//h2[text()='model-uri-test']"
    When I choose "Logout" in top-right menu
    Then I am on login page

  @daily
  Scenario: User can create deployment with GPU
    Given I go to login page
    When I fill in the correct username credentials
    And I click login
    Then I am on the PrimeHub console "Home" page
    And I choose group with name "e2e-test-group-display-name"
    When I choose "Deployments" in sidebar menu
    Then I am on the PrimeHub console "Deployments" page
    When I click "Create Deployment" button
    Then I am on the PrimeHub console "CreateDeployment" page
    When I type "create-deployment-test-gpu" to "name" text field
    And I choose radio button with name "test-instance-type-gpu"
    And I type "infuseai/model-tensorflow2-mnist:v0.2.0" to "modelImage input" text field
    And I click element with xpath "//span[text()='Deploy']"
    Then I am on the PrimeHub console "Deployments" page
    When I go to the deployment detail page with name "create-deployment-test-gpu"
    Then I wait for attribute "Status" with value "Deployed"
    And I wait for attribute "Model Image" with value "infuseai/model-tensorflow2-mnist:v0.2.0"
    When I click tab of "Logs"
    Then I should see "kernel reported version is: 450.51.6" in element "div" under active tab
    When I choose "Logout" in top-right menu
    Then I am on login page

  @daily
  Scenario: User can delete deployment with GPU
    Given I go to login page
    When I fill in the correct username credentials
    And I click login
    Then I am on the PrimeHub console "Home" page
    And I choose group with name "e2e-test-group-display-name"
    #And I should see group resources with CPU "1,2", Memory "1.0 GB,4 GB", GPU "1,2"
    When I choose "Deployments" in sidebar menu
    Then I am on the PrimeHub console "Deployments" page
    When I go to the deployment detail page with name "create-deployment-test-gpu"
    And I click "Delete" button
    And I type "create-deployment-test-gpu" to element with xpath "//input[@id='delete-deployment']"
    And I click button of "Delete" on deletion confirmation dialogue
    Then I am on the PrimeHub console "Deployments" page
    And I "should not" see element with xpath "//div[@class='ant-card-body']//h2[text()='create-deployment-test-gpu']"
    When I click on PrimeHub icon
    Then I am on the PrimeHub console "Home" page
    #And I should see group resources with CPU "0,2", Memory "0.0 GB,4 GB", GPU "0,2"
    When I choose "Logout" in top-right menu
    Then I am on login page
