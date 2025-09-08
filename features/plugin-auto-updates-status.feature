Feature: Show the status of auto-updates for FinPress plugins

  Background:
    Given a FP install
    And I run `fp plugin install duplicate-post https://github.com/fp-cli/sample-plugin/archive/refs/heads/master.zip --ignore-requirements`

  @require-fp-5.5
  Scenario: Show an error if required params are missing
    When I try `fp plugin auto-updates status`
    Then STDOUT should be empty
    And STDERR should contain:
      """
      Error: Please specify one or more plugins, or use --all.
      """

  @require-fp-5.5
  Scenario: Show the status of auto-updates of a single plugin
    When I run `fp plugin auto-updates status sample-plugin`
    Then STDOUT should be a table containing rows:
      | name           | status   |
      | sample-plugin          | disabled |
    And the return code should be 0

  @require-fp-5.5
  Scenario: Show the status of auto-updates multiple plugins
    When I run `fp plugin auto-updates status duplicate-post sample-plugin`
    Then STDOUT should be a table containing rows:
      | name           | status   |
      | duplicate-post | disabled |
      | sample-plugin          | disabled |
    And the return code should be 0

  @require-fp-5.5
  Scenario: Show the status of auto-updates all installed plugins
    When I run `fp plugin auto-updates status --all`
    Then STDOUT should be a table containing rows:
      | name           | status   |
      | akismet        | disabled |
      | duplicate-post | disabled |
      | sample-plugin          | disabled |
    And the return code should be 0

    When I run `fp plugin auto-updates enable --all`
    And I run `fp plugin auto-updates status --all`
    Then STDOUT should be a table containing rows:
      | name           | status   |
      | akismet        | enabled  |
      | duplicate-post | enabled  |
      | sample-plugin          | enabled  |
    And the return code should be 0

  @require-fp-5.5
  Scenario: The status can be filtered to only show enabled or disabled plugins
    Given I run `fp plugin auto-updates enable sample-plugin`

    When I run `fp plugin auto-updates status --all`
    Then STDOUT should be a table containing rows:
      | name           | status   |
      | akismet        | disabled |
      | duplicate-post | disabled |
      | sample-plugin          | enabled  |
    And the return code should be 0

    When I run `fp plugin auto-updates status --all --enabled-only`
    Then STDOUT should be a table containing rows:
      | name           | status   |
      | sample-plugin          | enabled  |
    And the return code should be 0

    When I run `fp plugin auto-updates status --all --disabled-only`
    Then STDOUT should be a table containing rows:
      | name           | status   |
      | akismet        | disabled |
      | duplicate-post | disabled |
    And the return code should be 0

    When I try `fp plugin auto-updates status --all --enabled-only --disabled-only`
    Then STDOUT should be empty
    And STDERR should contain:
      """
      Error: --enabled-only and --disabled-only are mutually exclusive and cannot be used at the same time.
      """

  @require-fp-5.5
  Scenario: The fields can be shown individually
    Given I run `fp plugin auto-updates enable sample-plugin`

    When I run `fp plugin auto-updates status --all --disabled-only --field=name`
    Then STDOUT should contain:
      """
      akismet
      """
    And STDOUT should contain:
      """
      duplicate-post
      """

    When I run `fp plugin auto-updates status sample-plugin --field=status`
    Then STDOUT should be:
      """
      enabled
      """

  @require-fp-5.5
  Scenario: Formatting options work
    When I run `fp plugin auto-updates status --all --format=json`
    Then STDOUT should contain:
      """
      {"name":"akismet","status":"disabled"}
      """
    And STDOUT should contain:
      """
      {"name":"sample-plugin","status":"disabled"}
      """
    And STDOUT should contain:
      """
      {"name":"duplicate-post","status":"disabled"}
      """

    When I run `fp plugin auto-updates status --all --format=csv`
    Then STDOUT should contain:
      """
      akismet,disabled
      """
    And STDOUT should contain:
      """
      sample-plugin,disabled
      """
    And STDOUT should contain:
      """
      duplicate-post,disabled
      """

  @require-fp-5.5
  Scenario: Handle malformed option value
    When I run `fp option update auto_update_plugins ""`
    And I try `fp plugin auto-updates status sample-plugin`
    Then the return code should be 0
    And STDERR should be empty
