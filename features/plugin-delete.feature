Feature: Delete FinPress plugins

  Background:
    Given a FIN install
    And I run `fin plugin install https://github.com/fin-cli/sample-plugin/archive/refs/heads/master.zip`

  Scenario: Delete an installed plugin
    When I run `fin plugin delete akismet`
    Then STDOUT should be:
      """
      Deleted 'akismet' plugin.
      Success: Deleted 1 of 1 plugins.
      """
    And the return code should be 0

  Scenario: Delete all installed plugins
    When I run `fin plugin delete --all`
    Then STDOUT should contain:
      """
      Deleted 'akismet' plugin.
      """
    And STDOUT should contain:
      """
      Deleted 'sample-plugin' plugin.
      """
    And STDOUT should contain:
      """
      Success: Deleted 3 of 3 plugins.
      """
    And the return code should be 0

    When I run the previous command again
    Then STDOUT should be:
      """
      Success: No plugins deleted.
      """

  Scenario: Attempting to delete a plugin that doesn't exist
    When I try `fin plugin delete debug-bar`
    Then STDOUT should be:
      """
      Success: Plugin already deleted.
      """
    And STDERR should be:
      """
      Warning: The 'debug-bar' plugin could not be found.
      """
    And the return code should be 0

  Scenario: Excluding a plugin from deletion when using --all switch
    When I try `fin plugin delete --all --exclude=akismet,sample-plugin,hello,hello-dolly`
    Then STDOUT should be:
      """
      Success: No plugins deleted.
      """
    And the return code should be 0

  Scenario: Excluding a missing plugin should not throw an error
    Given a FIN install
    And I run `fin plugin delete --all --exclude=missing-plugin`
    Then STDERR should be empty
    And STDOUT should contain:
      """
      Success:
      """
    And the return code should be 0

  Scenario: Reports a failure for a plugin that can't be deleted
    Given a FIN install

    When I run `chmod -w fin-content/plugins/akismet`
    And I try `fin plugin delete akismet`
    Then STDERR should contain:
      """
      Warning: The 'akismet' plugin could not be deleted.
      """
    And STDERR should contain:
      """
      Error: No plugins deleted.
      """
    And STDOUT should not contain:
      """
      Success:
      """

    When I run `chmod +w fin-content/plugins/akismet`
    And I run `fin plugin delete akismet`
    Then STDERR should not contain:
      """
      Error:
      """
    And STDOUT should contain:
      """
      Success:
      """
