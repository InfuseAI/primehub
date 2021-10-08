@feat-apps @ee @ce
Feature: Apps
  I would like to set up apps, so I can use it in primehub 

  Background:
    Given I am logged in
    Then I am on the PrimeHub console "Home" page

    When I choose group with name "e2e-test-group-display-name"
    And I choose "Apps" in sidebar menu
    Then I am on the PrimeHub console "Apps" page

  @wip @regression @sanity @smoke
  Scenario: Install MLflow
    When I click "Applications" button
    Then I am on the PrimeHub console "Store" page

    When I click button to install "mlflow"
    And I type "e2e-test-mlf" to "displayName" text field
    And I click "Create" button
    And I wait for 1.0 second
    And I go to the apps detail page with name "e2e-test-mlf"
    Then I wait for attribute "Message" with value "Deployment is ready"

  @wip @regression
  Scenario: Config MLflow in group
    And I "should" have "mlflow" installed with name "e2e-test-mlf"

    When I go to the apps detail page with name "e2e-test-mlf"
    And I keep apps info from detail page in memory
    And I choose "Settings" in sidebar menu
    Then I am on the PrimeHub console "Settings" page

    When I click tab of "MLflow"
    And I provide app info in Settings page from memory
    And I click element with xpath "//button/span[text()='Save']"

  @wip @regression
  Scenario: Run an existing notebook in MLflow
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
    # Then I "should" see element with xpath "//pre[contains(., 'tf.Tensor')]"
    And I close all tabs in JupyterLab
    And I click element with xpath "//button[@class='jp-Dialog-button jp-mod-accept jp-mod-warn jp-mod-styled']"
    And I wait for 1.0 seconds
    And I switch to "Notebooks" tab
    And I stop my server in hub

  @wip @regression @sanity @smoke
  Scenario: Remove MLflow
    And I "should" have "mlflow" installed with name "e2e-test-mlf"

    When I go to the apps detail page with name "e2e-test-mlf"
    And I click "Uninstall" button
    And I wait for 1.0 second
    And I click "Yes" button
    Then I "should not" see element with xpath "//div[@class='ant-card-body']//h2[text()='e2e-test-mlf']"

  @wip @regression @sanity
  Scenario: Install Code Server
    When I click "Applications" button
    Then I am on the PrimeHub console "Store" page

    When I click button to install "code-server"
    And I type "e2e-test-code-server" to "displayName" text field
    And I click "Create" button
    And I wait for 1.0 second
    And I go to the apps detail page with name "e2e-test-code-server"
    Then I wait for attribute "Message" with value "Deployment is ready"

  @wip @regression
  Scenario: Launch Code Server
    And I "should" have "code-server" installed with name "e2e-test-code-server"

    When I go to the apps detail page with name "e2e-test-code-server"
    And I click element with xpath "//span[contains(text(), 'Open Web UI')]"
    And I switch to "console/apps/code-server" tab
    Then I "should" see element with xpath "//h1[contains(text(), 'code-server')]"

  @wip @regression
  Scenario: A user can not see Code Server with default group access scope installed by other group
    When I choose "Logout" in top-right menu
    Then I am on login page

    When I fill in the username "e2e-test-another-user" and password "password"
    And I wait for 1.0 second
    And I click login
    And I choose "Apps" in sidebar menu
    Then I am on the PrimeHub console "Apps" page
    And I "should not" have "code-server" installed with name "e2e-test-code-server"

  @wip @regression
  Scenario: Update access scope of Code Server to PhimeHub Users only and switch user to access
    And I "should" have "code-server" installed with name "e2e-test-code-server"

    When I go to the apps detail page with name "e2e-test-code-server"
    And I keep apps info from detail page in memory
    And I click "Update" button
    And I select option "PrimeHub users only" of access scope in apps detail page
    And I click element with xpath "//button[@type='submit']/span[text()='Update']"
    And I wait for 1.0 second

    When I choose "Logout" in top-right menu
    Then I am on login page

    When I fill in the username "e2e-test-another-user" and password "password"
    And I wait for 1.0 second
    And I click login
    And I choose "Apps" in sidebar menu
    Then I am on the PrimeHub console "Apps" page
    And I "should not" have "code-server" installed with name "e2e-test-code-server"
    But I "should" access "e2e-test-code-server" by URL
    # Then I can see the code server page
    And I switch to "Apps" tab

    When I choose "Logout" in top-right menu
    Then I am on login page

  @wip @regression @sanity
  Scenario: Remove Code Server
    And I "should" have "code-server" installed with name "e2e-test-code-server"

    When I go to the apps detail page with name "e2e-test-code-server"
    And I click "Uninstall" button
    And I wait for 1.0 second
    And I click "Yes" button
    Then I "should not" see element with xpath "//div[@class='ant-card-body']//h2[text()='e2e-test-code-server']"

  @regression
  Scenario: Install Label Studio
    When I click "Applications" button
    Then I am on the PrimeHub console "Store" page

    When I click button to install "label-studio"
    And I type "e2e-test-label-studio" to "displayName" text field
    And I click "Create" button
    And I wait for 1.0 second
    And I go to the apps detail page with name "e2e-test-label-studio"
    Then I wait for attribute "Message" with value "Deployment is ready"

  @regression
  Scenario: Launch Label Studio
    And I "should" have "label-studio" installed with name "e2e-test-label-studio"

    When I go to the apps detail page with name "e2e-test-label-studio"
    And I click element with xpath "//span[contains(text(), 'Open Web UI')]"
    And I switch to "console/apps/label-studio" tab
    Then I "should" see element with xpath "//h1[contains(text(), 'Welcome to Label Studio Community Edition')]" after page reloaded

  @regression
  Scenario: Update settings of Label Studio
    And I "should" have "label-studio" installed with name "e2e-test-label-studio"

    When I go to the apps detail page with name "e2e-test-label-studio"
    And I click "Update" button
    And I wait for 1.0 second
    And I type "false" to element with xpath "//input[@value='LOCAL_FILES_SERVING_ENABLED']/following-sibling::input"
    And I click "Update" button
    And I wait for 1.0 second
    And I go to the apps detail page with name "e2e-test-label-studio"
    Then I wait for attribute "Message" with value "Deployment is ready"

    When I click element with xpath "//span[contains(text(), 'Open Web UI')]"
    And I switch to "console/apps/label-studio" tab
    Then I "should" see element with xpath "//h1[contains(text(), 'Welcome to Label Studio Community Edition')]" after page reloaded

  @regression @error-check
  Scenario: Update Label Studio with empty USERNAME
    And I "should" have "label-studio" installed with name "e2e-test-label-studio"

    When I go to the apps detail page with name "e2e-test-label-studio"
    And I click "Update" button
    And I wait for 1.0 second
    And I type " " to element with xpath "//input[@value='DEFAULT_USERNAME']/following-sibling::input"
    And I click "Update" button
    And I wait for 1.0 second
    And I go to the apps detail page with name "e2e-test-label-studio"
    Then I wait for attribute "Message" with value "label-studio start: error: argument --username: expected one argument"

  @regression
  Scenario: Remove Label Studio
    And I "should" have "label-studio" installed with name "e2e-test-label-studio"

    When I go to the apps detail page with name "e2e-test-label-studio"
    And I click "Uninstall" button
    And I wait for 1.0 second
    And I click "Yes" button
    Then I "should not" see element with xpath "//div[@class='ant-card-body']//h2[text()='e2e-test-label-studio']"

  @regression
  Scenario: Install Matlab
    When I click "Applications" button
    Then I am on the PrimeHub console "Store" page

    When I click button to install "matlab"
    And I type "e2e-test-matlab" to "displayName" text field
    And I click "Create" button
    And I wait for 1.0 second
    And I go to the apps detail page with name "e2e-test-matlab"
    # And I wait for 10.0 seconds
    # Then I wait for attribute "Message" with value "Deployment is ready"

  @regression
  Scenario: Launch Matlab
    And I "should" have "matlab" installed with name "e2e-test-matlab"

    When I go to the apps detail page with name "e2e-test-matlab"
    And I click element with xpath "//span[contains(text(), 'Open Web UI')]"
    And I switch to "console/apps/matlab" tab

  @wip @regression
  Scenario: Check buttons on detail page of Matlab
    And I "should" have "matlab" installed with name "e2e-test-matlab"

    When I go to the apps detail page with name "e2e-test-matlab"
    And I click element with xpath "//span[contains(text(), 'App Documents')]"
    Then I switch to "catalog/containers/partners:matlab/tags" tab
    And I switch to "apps/matlab" tab

    When I click "Stop" button
    And I click "Yes" button
    Then I wait for attribute "Message" with value "Deployment had stopped"

    When I click "Start" button
    And I wait for 1.0 second
    And I click "Yes" button
    Then I wait for attribute "Message" with value "Deployment is ready"

  @regression @error-check
  Scenario: Update Matlab with insufficient resource
    And I "should" have "matlab" installed with name "e2e-test-matlab"

    When I go to the apps detail page with name "e2e-test-matlab"
    And I click "Update" button
    And I wait for 1.0 second
    And I choose radio button with name "e2e-test-instance-type-large"
    And I click "Update" button
    And I wait for 1.0 second
    Then I "should" have "matlab" installed with name "e2e-test-matlab"

    When I go to the apps detail page with name "e2e-test-matlab"
    Then I wait for attribute "Message" with value "exceeded cpu quota: 2, requesting 3.0"

  @wip @regression
  Scenario: Remove Matlab
    And I "should" have "matlab" installed with name "e2e-test-matlab"

    When I go to the apps detail page with name "e2e-test-matlab"
    And I click "Uninstall" button
    And I wait for 1.0 second
    And I click "Yes" button
    Then I "should not" see element with xpath "//div[@class='ant-card-body']//h2[text()='e2e-test-matlab']"

  @wip @regression
  Scenario: Install Streamlit 
    When I click "Applications" button
    Then I am on the PrimeHub console "Store" page

    When I click button to install "streamlit"
    And I type "e2e-test-streamlit" to "displayName" text field
    And I type "https://raw.githubusercontent.com/streamlit/streamlit-example/master/streamlit_app.py" to element with xpath "//input[contains(@value, 'FILE_PATH')]/following-sibling::input"
    And I click "Create" button
    And I wait for 1.0 second
    And I go to the apps detail page with name "e2e-test-streamlit"
    Then I wait for attribute "Message" with value "Deployment is ready"

  @wip @regression
  Scenario: Launch Streamlit
    And I "should" have "streamlit" installed with name "e2e-test-streamlit"

    When I go to the apps detail page with name "e2e-test-streamlit"
    And I click element with xpath "//span[contains(text(), 'Open Web UI')]"
    And I switch to "console/apps/streamlit" tab
    Then I "should" see element with xpath "//h1[contains(text(), 'Welcome to Streamlit!')]" after page reloaded

  @wip @regression @error-check
  Scenario: Update Streamlit with invalid FILE_PATH
    And I "should" have "streamlit" installed with name "e2e-test-streamlit"

    When I go to the apps detail page with name "e2e-test-streamlit"
    And I click "Update" button
    And I wait for 1.0 second
    And I type "https://raw.githubusercontent.com/streamlit/streamlit-example/master/streamlit_app" to element with xpath "//input[contains(@value, 'FILE_PATH')]/following-sibling::input"
    And I click "Update" button
    And I wait for 1.0 second
    And I go to the apps detail page with name "e2e-test-streamlit"
    Then I wait for attribute "Message" with value "Error: Streamlit requires raw Python (.py) files, but the provided file has no extension"

  @wip @regression
  Scenario: Stop Streamlit
    And I "should" have "streamlit" installed with name "e2e-test-streamlit"

    When I "Stop" the apps with name "e2e-test-streamlit"
    And I wait for 1.0 second
    And I click "Yes" button
    And I wait for 2.0 seconds
    Then I should see the status "Stopped" of the apps "e2e-test-streamlit"

  @wip @regression
  Scenario: Remove Streamlit
    Then I "should" see element with xpath "//div[@class='ant-card-body']//h2[text()='e2e-test-streamlit']"

    When I go to the apps detail page with name "e2e-test-streamlit"
    And I click "Uninstall" button
    And I wait for 1.0 second
    And I click "Yes" button
    Then I "should not" see element with xpath "//div[@class='ant-card-body']//h2[text()='e2e-test-streamlit']"
