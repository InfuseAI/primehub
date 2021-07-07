Feature: Apps
  I would like to set up apps, so I can use it in primehub 
  Prerequisite:
    User is in a group with shared volume, model deployment enabled
    User is a group admin

  Background:
    Given I am logged in
    Then I am on the PrimeHub console "Home" page
    When I choose group with name "test-group"

  @wip
  Scenario: Install MLflow
    When I choose "Apps" in sidebar menu
    Then I am on the PrimeHub console "Apps" page
    When I click "Applications" button
    Then I am on the PrimeHub console "Store" page
    When I click button to install "mlflow"
    And I type "test-mlf" to "displayName" text field
    And I click "Create" button
    And I wait for 1.0 second
    And I go to the apps detail page with name "test-mlf"
    Then I wait for attribute "Message" with value "Deployment is ready"

  @wip
  Scenario: Config MLflow in group
    Given I choose "Apps" in sidebar menu
    Then I am on the PrimeHub console "Apps" page
    And I have "mlflow" installed
    When I go to the apps detail page with name "test-mlf"
    And I keep MLflow info from detail page in memory
    And I choose "Settings" in sidebar menu
    Then I am on the PrimeHub console "Settings" page
    When I click tab of "MLflow"
    And I provide MLflow info in Settings page from memory
    And I click element with xpath "//button/span[text()='Save']"

  @wip
  Scenario: Run an existing notebook
    When I choose "Notebooks" in sidebar menu
    Then I am on the PrimeHub console "Notebooks" page
    When I get the iframe object
    And I go to the spawner page
    And I wait for 2.0 seconds
    And I choose instance type
    And I choose latest TensorFlow image
    And I click element with selector "input[value='Start Notebook']" in hub
    Then I can see the spawning page and wait for notebook started
    When I wait for 4.0 seconds
    And I switch to "JupyterLab" tab
    Then I can see the JupyterLab page
    And I click the "Terminal" card in the launcher
    Then I "should" see element with xpath "//div[text()='Terminal 1']"
    When I input "curl https://docs.primehub.io/docs/assets/model_management_tutorial.ipynb --output model_management_tutorial.ipynb" command in the terminal
    And I close all tabs in JupyterLab
    And I wait for 1.0 seconds
    And I open "model_management_tutorial.ipynb" file in the file browser
    When I click element with xpath "//button[@title='Restart the kernel, then re-run the whole notebook']"
    And I wait for 1.0 seconds
    And I click element with xpath "//button[@class='jp-Dialog-button jp-mod-accept jp-mod-warn jp-mod-styled']"
    And I wait for 60.0 seconds
    Then I "should" see element with xpath "//pre[contains(text(), 'tf.Tensor')]"

  @wip
  Scenario: Remove MLflow
    Given I choose "Apps" in sidebar menu
    Then I am on the PrimeHub console "Apps" page
    And I have "mlflow" installed
    When I go to the apps detail page with name "test-mlf"
    And I click "Uninstall" button
    And I click "Yes" button
    Then I "should not" see element with xpath "//div[@class='ant-card-body']//h2[text()='test-mlf']"
