@released
Feature: Hub
  In order to do machine learning experiments,
  As a user,
  I want to spawn a hub and do something.

  @daily
  Scenario: User can see advanced settings
    Given I go to login page
    When I fill in the correct username credentials
    And I click login
    Then I am on the PrimeHub console "Home" page
    And I choose group with name "e2e-test-group-display-name"
    When I choose "Notebooks" in sidebar menu
    Then I am on the PrimeHub console "Notebooks" page
    When I go to the spawner page
    Then I can see advanced settings
    When I choose "Logout" in top-right menu
    Then I am on login page

  @daily
  Scenario: User can cancel spawning while chose error image
    Given I go to login page
    When I fill in the correct username credentials
    And I click login
    Then I am on the PrimeHub console "Home" page
    And I choose group with name "e2e-test-group-display-name"
    When I choose "Notebooks" in sidebar menu
    Then I am on the PrimeHub console "Notebooks" page
    When I go to the spawner page
    And I wait for 2.0 seconds
    And I choose instance type with name "test-instance-type"
    And I choose image with name "error-image"
    And I click element with selector "input[value='Start Notebook']" in hub
    Then I can see the spawning page and wait for log "[Warning] Error: ErrImagePull"
    When I click tab of "Logs"
    Then I should see "waiting to start: image can't be pulled" in element "div" under active tab
    When I click tab of "Notebooks"
    And I click element with xpath "//a[text()='Cancel']" in hub
    Then I go to the spawner page
    When I choose "Logout" in top-right menu
    Then I am on login page

  Scenario: User can start/stop the JupyterLab server
    Given I go to login page
    When I fill in the correct username credentials
    And I click login
    Then I am on the PrimeHub console "Home" page
    And I choose group with name "e2e-test-group-display-name"
    When I choose "Notebooks" in sidebar menu
    Then I am on the PrimeHub console "Notebooks" page
    When I go to the spawner page
    And I wait for 2.0 seconds
    And I choose instance type with name "test-instance-type"
    And I choose image with name "test-image"
    And I click element with selector "input[value='Start Notebook']" in hub
    Then I can see the spawning page and wait for notebook started
    When I click tab of "Logs"
    Then I should see "start the standard notebook command" in element "div" under active tab
    Then I should see "Set username to: jovyan" in element "div" under active tab
    Then I should see "usermod: no changes" in element "div" under active tab
    Then I should see "Granting jovyan sudo access and appending /opt/conda/bin to sudo PATH" in element "div" under active tab
    Then I should see "--ip=0.0.0.0 --port=8888 --NotebookApp.default_url=/lab" in element "div" under active tab
    When I click tab of "Notebooks"
    And I click element with selector "#start" in hub
    And I wait for 4.0 seconds
    And I switch to "JupyterLab" tab
    Then I can see the JupyterLab page
    When I switch to "Notebooks" tab
    Then I am on the PrimeHub console "Notebooks" page
    And I check the group warning message against group "e2e-test-group"
    And I switch group
    And I check the group warning message against group "e2e-test-group"
    And I stop my server in hub
    When I choose "Logout" in top-right menu
    Then I am on login page

  @regression
  Scenario: User can start the TensorBoard
    Given I go to login page
    When I fill in the correct username credentials
    And I click login
    Then I am on the PrimeHub console "Home" page
    When I choose "Notebooks" in sidebar menu
    Then I am on the PrimeHub console "Notebooks" page
    When I go to the spawner page
    And I choose instance type
    And I choose latest TensorFlow image
    And I click element with selector "input[value='Start Notebook']" in hub
    Then I can see the spawning page and wait for notebook started
    When I click element with selector "#start" in hub
    And I wait for 4.0 seconds
    And I switch to "JupyterLab" tab
    Then I can see the JupyterLab page
    When I click the "Tensorboard" card in the launcher
    Then I "should" see element with xpath "//div[text()='Tensorboard 1']"
    When I switch to "/console/g/phusers/hub" tab
    Then I am on the PrimeHub console "Notebooks" page
    #And I stop my server in hub
    When I choose "Logout" in top-right menu
    Then I am on login page

  @regression
  Scenario: User can start/stop the JupyterLab server with latest jupyter/base-notebook
    Given I go to login page
    When I fill in the correct username credentials
    And I click login
    Then I am on the PrimeHub console "Home" page
    When I choose "Admin Portal" in top-right menu
    Then I am on the admin dashboard "Groups" page
    When I click "Images" in admin dashboard
    Then I am on the admin dashboard "Images" page
    And I should see element with test-id "image"
    When I click element with test-id "add-button"
    Then I should see element with test-id "image/name"
    And I should see element with test-id "image/displayName"
    When I type "test-image" to element with test-id "image/name"
    And I type "jupyter/base-notebook:latest" to element with xpath "//div[@data-testid='image/url']//input"
    And I click element with test-id "connect-button"
    And I wait for 4.0 seconds
    And I click element with xpath "//td[contains(text(), 'phusers')]/..//input"
    And I click element with xpath "//button/span[text()='OK']"
    And I wait for 4.0 seconds
    And I click element with xpath "//a/span[text()='Confirm']"
    Then list-view table "should" contain row with "test-image"
    When I click on PrimeHub icon
    Then I am on the PrimeHub console "Home" page
    When I choose "Notebooks" in sidebar menu
    Then I am on the PrimeHub console "Notebooks" page
    When I go to the spawner page
    And I choose instance type
    And I choose image with name "test-image"
    And I click element with selector "input[value='Start Notebook']" in hub
    Then I can see the spawning page and wait for notebook started
    When I click element with selector "#start" in hub
    And I wait for 4.0 seconds
    And I switch to "JupyterLab" tab
    Then I can see the JupyterLab page
    When I switch to "/console/g/phusers/hub" tab
    Then I am on the PrimeHub console "Notebooks" page
    And I stop my server in hub
    When I choose "Logout" in top-right menu
    Then I am on login page

  @weekly
  Scenario: User can start/stop the JupyterLab server with GPU
    Given I go to login page
    When I fill in the correct username credentials
    And I click login
    Then I am on the PrimeHub console "Home" page
    And I choose group with name "e2e-test-group-display-name"
    When I choose "Notebooks" in sidebar menu
    Then I am on the PrimeHub console "Notebooks" page
    When I go to the spawner page
    And I wait for 2.0 seconds
    And I choose instance type with name "test-instance-type-gpu"
    And I choose image with name "test-image-gpu"
    And I click element with selector "input[value='Start Notebook']" in hub
    Then I can see the spawning page and wait for notebook started
    When I click element with selector "#start" in hub
    And I wait for 4.0 seconds
    And I switch to "JupyterLab" tab
    Then I can see the JupyterLab page
    When I click element with xpath "//div[text()='File']"
    And I click element with xpath "//div[@class='lm-Menu-itemLabel p-Menu-itemLabel' and text()='Close All Tabs']"
    #When I click element with xpath "//button[@title='New Launcher']"
    And I click the "Terminal" card in the launcher
    And I input "nvidia-smi > tmp.txt" command in the terminal
    And I open "tmp.txt" file in the file browser
    Then I "should" see element with xpath "//div[@class='CodeMirror-code']//span[contains(text(), 'Driver Version: 418.67')]"
    And I "should" see element with xpath "//div[@class='CodeMirror-code']//span[contains(text(), 'CUDA Version: 10.1')]"
    When I switch to "Notebooks" tab
    Then I am on the PrimeHub console "Notebooks" page
    And I check the group warning message against group "e2e-test-group"
    And I switch group
    And I check the group warning message against group "e2e-test-group"
    And I stop my server in hub
    When I choose "Logout" in top-right menu
    Then I am on login page
