Feature: Apps
  I would like to set up apps, so I can use it in primehub 
  Prerequisite:
    User A is in a group with shared volume, model deployment enabled
    User A is a group admin
    User B is in different group than A

  Background:
    Given I am logged in
    Then I am on the PrimeHub console "Home" page
    When I choose group with name "e2e-test-group-display-name"

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

  Scenario: Remove MLflow
    Given I choose "Apps" in sidebar menu
    Then I am on the PrimeHub console "Apps" page
    And I have "mlflow" installed
    When I go to the apps detail page with name "test-mlf"
    And I click "Uninstall" button
    And I click "Yes" button
    Then I "should not" see element with xpath "//div[@class='ant-card-body']//h2[text()='test-mlf']"

  Scenario: Install Code Server
    When I choose "Apps" in sidebar menu
    Then I am on the PrimeHub console "Apps" page
    When I click "Applications" button
    Then I am on the PrimeHub console "Store" page
    When I click button to install "code-server"
    And I type "test-code-server" to "displayName" text field
    And I click "Create" button
    And I wait for 1.0 second
    And I go to the apps detail page with name "test-code-server"
    Then I wait for attribute "Message" with value "Deployment is ready"

  Scenario: Launch Code Server
    Given I choose "Apps" in sidebar menu
    Then I am on the PrimeHub console "Apps" page
    And I have "code-server" installed
    When I go to the apps detail page with name "test-code-server"
    #And I click "Open Web UI" button
    And I click element with xpath "//span[contains(text(), 'Open Web UI')]"
    And I switch to "console/apps/code-server" tab
    Then I "should" see element with xpath "//h1[contains(text(), 'code-server')]"

  Scenario: A user can not see Code Server with default grop access scope installed by other group
    When I choose "Logout" in top-right menu
    Then I am on login page
    When I fill in the username "e2e-test-user" and password "password"
    And I click login
    And I choose "Apps" in sidebar menu
    Then I am on the PrimeHub console "Apps" page
    And I "should not" have "code-server" installed with name "test-code-server"
    When I choose "Logout" in top-right menu
    Then I am on login page    

 Scenario: Update access scope of Code Server to PhimeHub Users only
    And I choose "Apps" in sidebar menu
    Then I am on the PrimeHub console "Apps" page
    And I "should" have "code-server" installed with name "test-code-server"
    When I go to the apps detail page with name "test-code-server"
    And I click "Update" button
    And I select option "PrimeHub users only" of access scope in apps detail page
    And I click element with xpath "//button[@type='submit']/span[text()='Update']"

  Scenario: A member not in the same group can see Code Server created by others
    When I choose "Logout" in top-right menu
    Then I am on login page
    When I fill in the username "e2e-test-user" and password "password"
    And I click login
    And I choose "Apps" in sidebar menu
    Then I am on the PrimeHub console "Apps" page
    And I "should" have "code-server" installed with name "test-code-server"
    When I choose "Logout" in top-right menu
    Then I am on login page    

  Scenario: Remove Code Server
    Given I choose "Apps" in sidebar menu
    Then I am on the PrimeHub console "Apps" page
    And I have "code-server" installed
    When I go to the apps detail page with name "test-code-server"
    And I click "Uninstall" button
    And I click "Yes" button
    Then I "should not" see element with xpath "//div[@class='ant-card-body']//h2[text()='test-code-server']"

  Scenario: Install Label Studio
    When I choose "Apps" in sidebar menu
    Then I am on the PrimeHub console "Apps" page
    When I click "Applications" button
    Then I am on the PrimeHub console "Store" page
    When I click button to install "label-studio"
    And I type "test-label-studio" to "displayName" text field
    And I click "Create" button
    And I wait for 1.0 second
    And I go to the apps detail page with name "test-label-studio"
    Then I wait for attribute "Message" with value "Deployment is ready"

  Scenario: Launch Label Studio
    Given I choose "Apps" in sidebar menu
    Then I am on the PrimeHub console "Apps" page
    And I have "label-studio" installed
    When I go to the apps detail page with name "test-label-studio"
    And I click element with xpath "//span[contains(text(), 'Open Web UI')]"
    And I switch to "console/apps/label-studio" tab
    Then I "should" see element with xpath "//h1[contains(text(), 'Welcome to Label Studio Community Edition')]" after page reloaded

  Scenario: Update settings of Label Studio
    Given I choose "Apps" in sidebar menu
    Then I am on the PrimeHub console "Apps" page
    And I have "label-studio" installed
    When I go to the apps detail page with name "test-label-studio"
    And I click "Update" button
    And I wait for 1.0 second
    # change envVar "LOCAL_FILES_SERVING_ENABLED" from "true" to "false"
    And I type "false" to element with xpath "//input[@value='LOCAL_FILES_SERVING_ENABLED']/following-sibling::input"
    And I click "Update" button
    And I wait for 1.0 second
    And I go to the apps detail page with name "test-label-studio"
    Then I wait for attribute "Message" with value "Deployment is ready"
    When I click element with xpath "//span[contains(text(), 'Open Web UI')]"
    And I switch to "console/apps/label-studio" tab
    Then I "should" see element with xpath "//h1[contains(text(), 'Welcome to Label Studio Community Edition')]" after page reloaded

  Scenario: Remove Label Studio
    Given I choose "Apps" in sidebar menu
    Then I am on the PrimeHub console "Apps" page
    And I have "label-studio" installed
    When I go to the apps detail page with name "test-label-studio"
    And I click "Uninstall" button
    And I click "Yes" button
    Then I "should not" see element with xpath "//div[@class='ant-card-body']//h2[text()='test-label-studio']"

  Scenario: Install Matlab
    When I choose "Apps" in sidebar menu
    Then I am on the PrimeHub console "Apps" page
    When I click "Applications" button
    Then I am on the PrimeHub console "Store" page
    When I click button to install "matlab"
    And I type "test-matlab" to "displayName" text field
    And I click "Create" button
    And I wait for 1.0 second
    And I go to the apps detail page with name "test-matlab"
    Then I wait for attribute "Message" with value "Deployment is ready"

  Scenario: Launch Matlab
    Given I choose "Apps" in sidebar menu
    Then I am on the PrimeHub console "Apps" page
    And I have "matlab" installed
    When I go to the apps detail page with name "test-matlab"
    And I click element with xpath "//span[contains(text(), 'Open Web UI')]"
    And I switch to "console/apps/matlab" tab
    #Then 

  Scenario: Check buttons on detail page of Matlab
    Given I choose "Apps" in sidebar menu
    Then I am on the PrimeHub console "Apps" page
    And I have "matlab" installed
    When I go to the apps detail page with name "test-matlab"
    And I click element with xpath "//span[contains(text(), 'App Documents')]"
    Then I switch to "catalog/containers/partners:matlab/tags" tab
    And I switch to "apps/matlab" tab
    When I click "Stop" button
    And I click "Yes" button
    Then I wait for attribute "Message" with value "Deployment had stopped"
    When I click "Start" button
    And I click "Yes" button
    Then I wait for attribute "Message" with value "Deployment is ready"

  Scenario: Remove Matlab
    Given I choose "Apps" in sidebar menu
    Then I am on the PrimeHub console "Apps" page
    And I have "matlab" installed
    When I go to the apps detail page with name "test-matlab"
    And I click "Uninstall" button
    And I click "Yes" button
    Then I "should not" see element with xpath "//div[@class='ant-card-body']//h2[text()='test-matlab']"

  Scenario: Install Streamlit 
    When I choose "Apps" in sidebar menu
    Then I am on the PrimeHub console "Apps" page
    When I click "Applications" button
    Then I am on the PrimeHub console "Store" page
    When I click button to install "streamlit"
    And I type "test-streamlit" to "displayName" text field
    And I type "https://raw.githubusercontent.com/streamlit/streamlit-example/master/streamlit_app.py" to element with xpath "//input[contains(@value, 'FILE_PATH')]/following-sibling::input"
    And I click "Create" button
    And I wait for 1.0 second
    And I go to the apps detail page with name "test-streamlit"
    Then I wait for attribute "Message" with value "Deployment is ready"

  Scenario: Launch Streamlit
    Given I choose "Apps" in sidebar menu
    Then I am on the PrimeHub console "Apps" page
    And I have "streamlit" installed
    When I go to the apps detail page with name "test-streamlit"
    And I click element with xpath "//span[contains(text(), 'Open Web UI')]"
    And I switch to "console/apps/streamlit" tab
    Then I "should" see element with xpath "//h1[contains(text(), 'Welcome to Streamlit!')]" after page reloaded

  Scenario: Stop Streamlit
    Given I choose "Apps" in sidebar menu
    Then I am on the PrimeHub console "Apps" page
    And I have "streamlit" installed
    When I click element with xpath "//ul[@class='ant-card-actions']//span[text()=' Stop']"
    And I click "Yes" button
    Then I "should" see element with xpath "//div[@class='ant-card-body']//div[text()='Stopped']"

  Scenario: Remove Streamlit
    Given I choose "Apps" in sidebar menu
    Then I am on the PrimeHub console "Apps" page
    Then I "should" see element with xpath "//div[@class='ant-card-body']//h2[text()='test-streamlit']"
    When I go to the apps detail page with name "test-streamlit"
    And I click "Uninstall" button
    And I click "Yes" button
    Then I "should not" see element with xpath "//div[@class='ant-card-body']//h2[text()='test-streamlit']"
