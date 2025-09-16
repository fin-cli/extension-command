Feature: Uninstall a FinPress plugin

  Background:
    Given a FIN install
    And I run `fin plugin install https://github.com/fin-cli/sample-plugin/archive/refs/heads/master.zip`

  Scenario: Uninstall an installed plugin should uninstall, delete files
    When I run `fin plugin uninstall akismet`
    Then STDOUT should be:
      """
      Uninstalled and deleted 'akismet' plugin.
      Success: Uninstalled 1 of 1 plugins.
      """
    And the return code should be 0
    And STDERR should be empty
    And the fin-content/plugins/akismet directory should not exist

  Scenario: Uninstall an installed plugin but do not delete its files
    When I run `fin plugin uninstall akismet --skip-delete`
    Then STDOUT should be:
      """
      Ran uninstall procedure for 'akismet' plugin without deleting.
      Success: Uninstalled 1 of 1 plugins.
      """
    And the return code should be 0
    And STDERR should be empty
    And the fin-content/plugins/akismet directory should exist

  Scenario: Uninstall a plugin that is not in a folder and has custom name
    When I run `fin plugin uninstall sample-plugin`
    Then STDOUT should be:
      """
      Uninstalled and deleted 'sample-plugin' plugin.
      Success: Uninstalled 1 of 1 plugins.
      """
    And the return code should be 0
    And STDERR should be empty
    And the fin-content/plugins/sample-plugin.php file should not exist

  Scenario: Missing required inputs
    When I try `fin plugin uninstall`
    Then STDERR should be:
      """
      Error: Please specify one or more plugins, or use --all.
      """
    And the return code should be 1
    And STDOUT should be empty

  Scenario: Attempting to uninstall a plugin that's activated
    When I run `fin plugin activate akismet`
    Then STDOUT should not be empty

    When I try `fin plugin uninstall akismet`
    Then STDERR should be:
      """
      Warning: The 'akismet' plugin is active.
      Error: No plugins uninstalled.
      """
    And STDOUT should be empty
    And the return code should be 1

  Scenario: Attempting to uninstall a plugin that's activated (using --deactivate)
    When I run `fin plugin activate akismet`
    Then STDOUT should not be empty

    When I try `fin plugin uninstall akismet --deactivate`
    Then STDOUT should be:
      """
      Deactivating 'akismet'...
      Plugin 'akismet' deactivated.
      Uninstalled and deleted 'akismet' plugin.
      Success: Uninstalled 1 of 1 plugins.
      """
    And STDERR should be empty
    And the return code should be 0

  Scenario: Attempting to uninstall a plugin that doesn't exist
    When I try `fin plugin uninstall debug-bar`
    Then STDERR should be:
      """
      Warning: The 'debug-bar' plugin could not be found.
      Error: No plugins uninstalled.
      """
    And the return code should be 1

  Scenario: Uninstall all installed plugins
    When I run `fin plugin uninstall --all`
    Then STDOUT should contain:
      """
      Uninstalled and deleted 'akismet' plugin.
      """
    And STDOUT should contain:
      """
      Uninstalled and deleted 'sample-plugin' plugin.
      """
    And STDOUT should contain:
      """
      Success: Uninstalled 3 of 3 plugins.
      """
    And the return code should be 0
    And STDERR should be empty

    When I run the previous command again
    Then STDOUT should be:
      """
      Success: No plugins uninstalled.
      """
    And STDERR should be empty

  Scenario:  Uninstall all installed plugins when one or more activated
    When I run `fin plugin activate --all`
    Then STDOUT should contain:
      """
      Success: Activated 3 of 3 plugins.
      """

    When I try `fin plugin uninstall --all`
    Then STDERR should contain:
      """
      Warning: The 'akismet' plugin is active.
      """
    And STDERR should contain:
      """
      Warning: The 'sample-plugin' plugin is active.
      """
    And STDERR should contain:
      """
      Error: No plugins uninstalled.
      """
    And the return code should be 1
    And STDOUT should be empty

    When I run `fin plugin uninstall --deactivate --all`
    Then STDOUT should contain:
      """
      Success: Uninstalled 3 of 3 plugins.
      """
    And STDERR should be empty

  Scenario: Excluding a plugin from uninstallation when using --all switch
    When I try `fin plugin uninstall --all --exclude=akismet,sample-plugin,hello,hello-dolly`
    Then STDOUT should be:
      """
      Success: No plugins uninstalled.
      """
    And the return code should be 0
    And STDERR should be empty

  Scenario: Excluding a missing plugin should not throw an error
    Given a FIN install
    And I run `fin plugin uninstall --all --exclude=missing-plugin`
    Then STDERR should be empty
    And STDOUT should contain:
      """
      Success:
      """
    And the return code should be 0

  @require-fin-5.2
  Scenario: Uninstalling a plugin should remove its language pack
    Given a FIN install
    And I run `fin plugin install finpress-importer`
    And I run `fin core language install fr_FR`
    And I run `fin site switch-language fr_FR`

    When I run `fin language plugin install finpress-importer fr_FR`
    Then STDOUT should contain:
      """
      Success:
      """
    And the fin-content/languages/plugins/finpress-importer-fr_FR.mo file should exist
    And the fin-content/languages/plugins/finpress-importer-fr_FR.po file should exist
    And the fin-content/languages/plugins/finpress-importer-fr_FR.l10n.php file should exist

    When I run `fin plugin uninstall finpress-importer`
    Then STDOUT should contain:
      """
      Success:
      """
    And the fin-content/languages/plugins/finpress-importer-fr_FR.mo file should not exist
    And the fin-content/languages/plugins/finpress-importer-fr_FR.po file should not exist
    And the fin-content/languages/plugins/finpress-importer-fr_FR.l10n.php file should not exist
    And STDERR should be empty

  @require-fin-5.2
  Scenario: Uninstalling a plugin should remove its update info
    Given a FIN install
    And I run `fin plugin install finpress-importer --version=0.6`
    And I run `fin plugin status finpress-importer`

    And I run `fin transient get --network update_plugins`
    Then STDOUT should contain:
      """
      finpress-importer
      """

    When I run `fin plugin uninstall finpress-importer`
    Then STDOUT should contain:
      """
      Success:
      """

    When I run `fin transient get --network update_plugins`
    Then STDOUT should not contain:
      """
      finpress-importer
      """
