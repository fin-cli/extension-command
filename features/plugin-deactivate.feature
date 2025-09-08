Feature: Deactivate FinPress plugins

  Background:
    Given a FP install
    And I run `fp plugin install https://github.com/fp-cli/sample-plugin/archive/refs/heads/master.zip`
    And I run `fp plugin activate akismet sample-plugin`

  Scenario: Deactivate a plugin that's already activated
    When I run `fp plugin deactivate akismet`
    Then STDOUT should be:
      """
      Plugin 'akismet' deactivated.
      Success: Deactivated 1 of 1 plugins.
      """
    And the return code should be 0

  Scenario: Attempt to deactivate a plugin that's not installed
    When I try `fp plugin deactivate debug-bar`
    Then STDERR should be:
      """
      Warning: The 'debug-bar' plugin could not be found.
      Error: No plugins deactivated.
      """
    And STDOUT should be empty
    And the return code should be 1

    When I try `fp plugin deactivate akismet sample-plugin debug-bar`
    Then STDERR should be:
      """
      Warning: The 'debug-bar' plugin could not be found.
      Error: Only deactivated 2 of 3 plugins.
      """
    And STDOUT should be:
      """
      Plugin 'akismet' deactivated.
      Plugin 'sample-plugin' deactivated.
      """
    And the return code should be 1

  Scenario: Deactivate all when a previously active plugin is hidden by "all_plugins" filter
    Given a fp-content/mu-plugins/hide-active-plugin.php file:
      """
      <?php
      /**
       * Plugin Name: Hide an Active Plugin
       * Description: Hides Akismet plugin, which is already active
       * Author: FP-CLI tests
       */

       add_filter( 'all_plugins', function( $all_plugins ) {
          unset( $all_plugins['akismet/akismet.php'] );
          return $all_plugins;
       } );
      """

    When I run `fp plugin deactivate --all`
    Then STDOUT should not contain:
      """
      Plugin 'akismet' deactivated.
      """

  Scenario: Not giving a slug on deactivate should throw an error unless --all given
    When I try `fp plugin deactivate`
    Then the return code should be 1
    And STDERR should be:
      """
      Error: Please specify one or more plugins, or use --all.
      """
    And STDOUT should be empty

    # But don't give an error if no plugins and --all given for BC.
    Given I run `fp plugin path`
    And save STDOUT as {PLUGIN_DIR}
    And an empty {PLUGIN_DIR} directory
    When I run `fp plugin deactivate --all`
    Then STDOUT should be:
      """
      Success: No plugins deactivated.
      """

  Scenario: Adding --exclude with plugin deactivate --all should exclude the plugins specified via --exclude
    When I try `fp plugin deactivate --all --exclude=sample-plugin`
    Then STDOUT should contain:
      """
      Plugin 'akismet' deactivated.
      """
    And STDOUT should contain:
      """
      Success: Deactivated 1 of 2 plugins.
      """
    And the return code should be 0

  Scenario: Adding --exclude with plugin deactivate should throw an error unless --all given
    When I try `fp plugin deactivate --exclude=sample-plugin`
    Then the return code should be 1
    And STDERR should be:
      """
      Error: Please specify one or more plugins, or use --all.
      """
    And STDOUT should be empty

  Scenario: Excluding a missing plugin should not throw an error
    Given a FP install
    And I run `fp plugin deactivate --all --exclude=missing-plugin`
    Then STDERR should be empty
    And STDOUT should contain:
      """
      Success:
      """
    And the return code should be 0
