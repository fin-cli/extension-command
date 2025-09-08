Feature: Disable auto-updates for FinPress plugins

  Background:
    Given a FP install
    And I run `fp plugin install duplicate-post https://github.com/fp-cli/sample-plugin/archive/refs/heads/master.zip --ignore-requirements`
    And I run `fp plugin auto-updates enable --all`

  @require-fp-5.5
  Scenario: Show an error if required params are missing
    When I try `fp plugin auto-updates disable`
    Then STDOUT should be empty
    And STDERR should contain:
      """
      Error: Please specify one or more plugins, or use --all.
      """

  @require-fp-5.5
  Scenario: Disable auto-updates for a single plugin
    When I run `fp plugin auto-updates disable sample-plugin`
    Then STDOUT should be:
      """
      Success: Disabled 1 of 1 plugin auto-updates.
      """
    And the return code should be 0

  @require-fp-5.5
  Scenario: Disable auto-updates for multiple plugins
    When I run `fp plugin auto-updates disable sample-plugin duplicate-post`
    Then STDOUT should be:
      """
      Success: Disabled 2 of 2 plugin auto-updates.
      """
    And the return code should be 0

  @require-fp-5.5
  Scenario: Disable auto-updates for all plugins
    When I run `fp plugin list --status=inactive --format=count`
    Then save STDOUT as {PLUGIN_COUNT}

    When I run `fp plugin auto-updates disable --all`
    Then STDOUT should be:
      """
      Success: Disabled {PLUGIN_COUNT} of {PLUGIN_COUNT} plugin auto-updates.
      """
    And the return code should be 0

  @require-fp-5.5
  Scenario: Disable auto-updates for already disabled plugins
    When I run `fp plugin auto-updates disable sample-plugin`
    And I try `fp plugin auto-updates disable --all`
    Then STDERR should contain:
      """
      Warning: Auto-updates already disabled for plugin sample-plugin.
      """
    And STDERR should contain:
      """
      Error: Only disabled 3 of 4 plugin auto-updates.
      """

  @require-fp-5.5
  Scenario: Filter when disabling auto-updates for already enabled plugins
    When I run `fp plugin auto-updates disable sample-plugin`
    And I run `fp plugin list --auto_update=on --format=count`
    Then save STDOUT as {PLUGIN_COUNT}

    When I run `fp plugin auto-updates disable --all --enabled-only`
    Then STDOUT should be:
      """
      Success: Disabled {PLUGIN_COUNT} of {PLUGIN_COUNT} plugin auto-updates.
      """
    And the return code should be 0

  @require-fp-5.5
  Scenario: Filter when disabling auto-updates for already disabled selection of plugins
    When I run `fp plugin auto-updates disable sample-plugin`
    And I run `fp plugin auto-updates disable sample-plugin duplicate-post --enabled-only`
    Then STDOUT should be:
      """
      Success: Disabled 1 of 1 plugin auto-updates.
      """
    And the return code should be 0

  @require-fp-5.5
  Scenario: Filtering everything away produces an error
    When I run `fp plugin auto-updates disable sample-plugin`
    And I try `fp plugin auto-updates disable sample-plugin --enabled-only`
    Then STDERR should be:
      """
      Error: No plugins provided to disable auto-updates for.
      """
