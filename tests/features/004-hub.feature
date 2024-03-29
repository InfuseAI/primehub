@feat @feat-hub @ee @ce @deploy
Feature: Hub
  In order to do machine learning experiments,
  As a user,
  I want to spawn a hub and do something.

  Background:
    Given I am logged in
    Then I am on the PrimeHub console "Home" page

    When I choose group with name "e2e-test-group-display-name"
    And I keep group resource data
    And I choose "Notebooks" in sidebar menu
    Then I am on the PrimeHub console "Notebooks" page

  @regression
  Scenario: User can see advanced settings
    When I get the iframe object
    And I go to the spawner page
    Then I can see advanced settings

  @wip @regression @sanity
  Scenario: User can start the JupyterLab server
    When I get the iframe object
    And I go to the spawner page
    And I wait for 2.0 seconds
    And I choose instance type with name "e2e-test-instance-type"
    And I choose image with name "e2e-test-image"
    And I click element with selector "input[value='Start Notebook']" in hub
    Then I can see the spawning page and wait for notebook started

    When I click tab of "Logs"
    Then I should see "start the standard notebook command" in element "div" under active tab
    And I should see "Set username to: jovyan" in element "div" under active tab
    And I should see "usermod: no changes" in element "div" under active tab
    And I should see "Granting jovyan sudo access and appending /opt/conda/bin to sudo PATH" in element "div" under active tab
    And I should see "--ip=0.0.0.0 --port=8888 --NotebookApp.default_url=/lab" in element "div" under active tab

    When I click on PrimeHub icon
    Then I am on the PrimeHub console "Home" page
    #And I should see group resource data with diff of CPU, memory & GPU: 0.5, 1.0, 0

  @wip @regression @sanity
  Scenario: User can stop the JupyterLab server
    When I get the iframe object
    And I click element with selector "#start" in hub
    And I wait for 2.0 seconds
    And I switch to "JupyterLab" tab
    Then I can see the JupyterLab page

    When I switch to "Notebooks" tab
    Then I am on the PrimeHub console "Notebooks" page
    
    When I stop my server in hub
    And I get the iframe object
    Then I "should" see element with xpath "//div//a[@id='start']" in hub

  @wip @regression @sanity
  Scenario: User can start the JupyterLab server with group image
    When I get the iframe object
    And I go to the spawner page
    And I wait for 2.0 seconds
    And I choose instance type with name "e2e-test-instance-type"
    And I click element with xpath "//div[@id='image-container']//input[contains(@value, 'e2e-test-group-image')]" in hub
    And I click element with selector "input[value='Start Notebook']" in hub
    Then I can see the spawning page and wait for notebook started

    When I click tab of "Logs"
    Then I should see "start the standard notebook command" in element "div" under active tab
    And I should see "Set username to: jovyan" in element "div" under active tab
    And I should see "usermod: no changes" in element "div" under active tab
    And I should see "Granting jovyan sudo access and appending /opt/conda/bin to sudo PATH" in element "div" under active tab
    And I should see "--ip=0.0.0.0 --port=8888 --NotebookApp.default_url=/lab" in element "div" under active tab

  @wip @regression @sanity
  Scenario: User can stop the JupyterLab server with group image
    When I get the iframe object
    And I click element with selector "#start" in hub
    And I wait for 2.0 seconds
    And I switch to "JupyterLab" tab
    Then I can see the JupyterLab page

    When I switch to "Notebooks" tab
    Then I am on the PrimeHub console "Notebooks" page
 
    When I stop my server in hub
    And I get the iframe object
    Then I "should" see element with xpath "//div//a[@id='start']" in hub

  @regression
  Scenario: User can start the TensorBoard
    When I get the iframe object
    And I go to the spawner page
    And I choose instance type
    And I choose latest TensorFlow image
    And I click element with selector "input[value='Start Notebook']" in hub
    Then I can see the spawning page and wait for notebook started

    When I click element with selector "#start" in hub
    And I wait for 2.0 seconds
    And I switch to "JupyterLab" tab
    Then I can see the JupyterLab page

    When I click the "Tensorboard" card in the launcher
    And I wait for 3.0 seconds
    And I switch to "JupyterLab" tab
    Then I "should" see element with xpath "//div[text()='Tensorboard 1']"

    When I switch to "Notebooks" tab
    Then I am on the PrimeHub console "Notebooks" page

    When I stop my server in hub
    And I get the iframe object
    Then I "should" see element with xpath "//div//a[@id='start']" in hub

  @regression
  Scenario: User can start/stop the JupyterLab server with latest jupyter/base-notebook
    When I get the iframe object
    And I go to the spawner page
    And I choose instance type
    And I choose image with name "e2e-test-bs-image"
    And I click element with selector "input[value='Start Notebook']" in hub
    Then I can see the spawning page and wait for notebook started

    When I click element with selector "#start" in hub
    And I wait for 2.0 seconds
    And I switch to "JupyterLab" tab
    Then I can see the JupyterLab page

    When I switch to "Notebooks" tab
    Then I am on the PrimeHub console "Notebooks" page

    When I stop my server in hub
    And I get the iframe object
    Then I "should" see element with xpath "//div//a[@id='start']" in hub

  @wip @regression
  Scenario: User can start/stop the JupyterLab server with GPU
    When I get the iframe object
    And I go to the spawner page
    And I wait for 2.0 seconds
    And I choose instance type with name "e2e-test-instance-type-gpu"
    And I choose image with name "e2e-test-image-gpu"
    And I click element with selector "input[value='Start Notebook']" in hub
    Then I can see the spawning page and wait for notebook started

    When I click on PrimeHub icon
    Then I am on the PrimeHub console "Home" page
    And I should see group resource data with diff of CPU, memory & GPU: 1.0, 1.0, 1.0

    When I keep group resource data
    When I choose "Notebooks" in sidebar menu
    Then I am on the PrimeHub console "Notebooks" page

    When I get the iframe object
    And I click element with selector "#start" in hub
    And I wait for 2.0 seconds
    And I switch to "JupyterLab" tab
    Then I can see the JupyterLab page

    When I click element with xpath "//div[text()='File']"
    And I click element with xpath "//div[@class='lm-Menu-itemLabel p-Menu-itemLabel' and text()='Close All Tabs']"
    And I click the "Terminal" card in the launcher
    And I input "nvidia-smi > tmp.txt" command in the terminal
    And I open "tmp.txt" file in the file browser
    Then I should see the property "textContent" of element with xpath "//div[@style='position: relative;']//span[@role='presentation']" is matched the regular expression "NVIDIA-SMI\s+\d+\.\d+\.\d+\s+Driver Version:\s+\d+\.\d+\.\d+\s+CUDA Version:\s+\d+\.\d+"
    And I close all tabs in JupyterLab

    When I switch to "Notebooks" tab
    Then I am on the PrimeHub console "Notebooks" page
    And I check the group warning message against group "e2e-test-group"
    And I switch group
    And I check the group warning message against group "e2e-test-group"

    When I stop my server in hub
    And I get the iframe object
    Then I "should" see element with xpath "//div//a[@id='start']" in hub

    When I click on PrimeHub icon
    Then I am on the PrimeHub console "Home" page
    And I choose group with name "e2e-test-group-display-name"
    And I should see group resource data with diff of CPU, memory & GPU: -1.0, -1.0, -1.0

  @regression @error-check
  Scenario: User can cancel spawning while chose error image
    When I get the iframe object
    And I go to the spawner page
    And I wait for 2.0 seconds
    And I choose instance type with name "e2e-test-instance-type"
    And I choose image with name "e2e-test-error-image"
    And I click element with selector "input[value='Start Notebook']" in hub
    Then I can see the spawning page and wait for log "[Warning] Error: ImagePullBackOff"

    When I click tab of "Logs"
    Then I should see "waiting to start: image can't be pulled" in element "div" under active tab

    When I click tab of "Notebooks"
    And I click element with xpath "//a[text()='Cancel']" in hub
    Then I go to the spawner page

    When I click on PrimeHub icon
    Then I am on the PrimeHub console "Home" page
    And I should see group resource data with diff of CPU, memory & GPU: 0, 0, 0
