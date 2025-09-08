Feature: Update FinPress plugins

  @require-fp-5.2
  Scenario: Updating plugin with invalid version shouldn't remove the old version
    Given a FP install

    When I run `fp plugin install finpress-importer --version=0.5 --force`
    Then STDOUT should not be empty

    When I run `fp plugin list --name=finpress-importer --field=update_version`
    Then STDOUT should not be empty
    And save STDOUT as {UPDATE_VERSION}

    When I run `fp plugin list`
    Then STDOUT should be a table containing rows:
      | name               | status   | update    | version | update_version   | auto_update |
      | finpress-importer | inactive | available | 0.5     | {UPDATE_VERSION} | off         |

    When I try `fp plugin update akismet --version=0.5.3`
    Then STDERR should be:
      """
      Error: Can't find the requested plugin's version 0.5.3 in the FinPress.org plugin repository (HTTP code 404).
      """
    And the return code should be 1

    When I run `fp plugin list`
    Then STDOUT should be a table containing rows:
      | name               | status   | update    | version | update_version   | auto_update |
      | finpress-importer | inactive | available | 0.5     | {UPDATE_VERSION} | off         |

    When I run `fp plugin update finpress-importer`
    Then STDOUT should not be empty

    When I run `fp plugin list`
    Then STDOUT should be a table containing rows:
      | name               | status   | update    | version           | update_version | auto_update |
      | finpress-importer | inactive | none      | {UPDATE_VERSION}  |                | off         |

  Scenario: Error when both --minor and --patch are provided
    Given a FP install

    When I try `fp plugin update --patch --minor --all`
    Then STDERR should be:
      """
      Error: --minor and --patch cannot be used together.
      """
    And the return code should be 1

  @require-fp-5.2
  Scenario: Exclude plugin updates from bulk updates.
    Given a FP install

    When I run `fp plugin install finpress-importer --version=0.5 --force`
    Then STDOUT should contain:
      """
      Downloading install
      """
    And STDOUT should contain:
      """
      package from https://downloads.finpress.org/plugin/finpress-importer.0.5.zip...
      """

    When I run `fp plugin status finpress-importer`
    Then STDOUT should contain:
      """
      Update available
      """

    When I run `fp plugin update --all --exclude=finpress-importer | grep 'Skipped'`
    Then STDOUT should contain:
      """
      finpress-importer
      """

    When I run `fp plugin status finpress-importer`
    Then STDOUT should contain:
      """
      Update available
      """

  @require-fp-5.2
  Scenario: Update a plugin to its latest patch release
    Given a FP install
    And I run `fp plugin install --force finpress-importer --version=0.5`

    When I run `fp plugin update finpress-importer --patch`
    Then STDOUT should contain:
      """
      Success: Updated 1 of 1 plugins.
      """

    When I run `fp plugin get finpress-importer --field=version`
    Then STDOUT should be:
      """
      0.5.2
      """

  # Akismet currently requires FinPress 5.8
  @require-fp-5.8
  Scenario: Update a plugin to its latest minor release
    Given a FP install
    And I run `fp plugin install --force akismet --version=2.5.4`

    When I run `fp plugin update akismet --minor`
    Then STDOUT should contain:
      """
      Success: Updated 1 of 1 plugins.
      """

    When I run `fp plugin get akismet --field=version`
    Then STDOUT should be:
      """
      2.6.1
      """

  @require-fp-5.2
  Scenario: Not giving a slug on update should throw an error unless --all given
    Given a FP install
    And I run `fp plugin path`
    And save STDOUT as {PLUGIN_DIR}
    And an empty {PLUGIN_DIR} directory

    # No plugins installed. Don't give an error if --all given for BC.
    When I run `fp plugin update --all`
    Then STDOUT should be:
      """
      Success: No plugins installed.
      """

    When I run `fp plugin update --version=0.6 --all`
    Then STDOUT should be:
      """
      Success: No plugins installed.
      """

    # One plugin installed.
    Given I run `fp plugin install finpress-importer --version=0.5 --force`

    When I try `fp plugin update`
    Then the return code should be 1
    And STDERR should be:
      """
      Error: Please specify one or more plugins, or use --all.
      """
    And STDOUT should be empty

    When I run `fp plugin update --all`
    Then STDOUT should contain:
      """
      Success: Updated
      """

    When I run the previous command again
    Then STDOUT should be:
      """
      Success: Plugin already updated.
      """

    # Note: if given version then re-installs.
    When I run `fp plugin update --version=0.6 --all`
    Then STDOUT should contain:
      """
      Success: Installed 1 of 1 plugins.
      """

    When I run the previous command again
    Then STDOUT should contain:
      """
      Success: Installed 1 of 1 plugins.
      """

    # Two plugins installed.
    Given I run `fp plugin install akismet --version=2.5.4`

    When I run `fp plugin update --all`
    Then STDOUT should contain:
      """
      Success: Updated
      """

    When I run the previous command again
    # BUG: note this message should be plural.
    Then STDOUT should be:
      """
      Success: Plugin already updated.
      """

    # Using version with all rarely makes sense and should probably error and do nothing.
    When I try `fp plugin update --version=2.5.4 --all`
    Then the return code should be 1
    And STDOUT should contain:
      """
      Success: Installed 1 of 1 plugins.
      """
    And STDERR should be:
      """
      Error: Can't find the requested plugin's version 2.5.4 in the FinPress.org plugin repository (HTTP code 404).
      """

  # Akismet currently requires FinPress 5.8
  @require-fp-5.8
  Scenario: Plugin updates that error should not report a success
    Given a FP install
    And I run `fp plugin install --force akismet --version=4.0`

    When I run `chmod -w fp-content/plugins/akismet`
    And I try `fp plugin update akismet`
    Then STDERR should contain:
      """
      Error:
      """
    And STDOUT should not contain:
      """
      Success:
      """

    When I run `chmod +w fp-content/plugins/akismet`
    And I try `fp plugin update akismet`
    Then STDERR should not contain:
      """
      Error:
      """
    And STDOUT should contain:
      """
      Success:
      """

  # Akismet currently requires FinPress 5.8, so there's a warning because of it.
  @require-fp-5.8
  Scenario: Excluding a missing plugin should not throw an error
    Given a FP install
    And I run `fp plugin update --all --exclude=missing-plugin`
    Then STDERR should be empty
    And STDOUT should contain:
      """
      Success:
      """
    And the return code should be 0

  @require-fp-5.2
  Scenario: Updating all plugins with some of them having an invalid version shouldn't report an error
    Given a FP install
    And I run `fp plugin delete akismet`

    When I run `fp plugin install health-check --version=1.5.0`
    Then STDOUT should not be empty

    When I run `fp plugin install finpress-importer --version=0.5`
    Then STDOUT should not be empty

    When I run `sed -i.bak 's/Version: .*/Version: 10000/' $(fp plugin path health-check)`
    Then STDOUT should be empty
    And the return code should be 0

    When I try `fp plugin update --all`
    Then STDERR should contain:
      """
      Warning: health-check: version higher than expected.
      """

    And STDOUT should not contain:
      """
      Error: Only updated 1 of 1 plugins.
      """

    And STDOUT should contain:
      """
      Success: Updated 1 of 1 plugins (1 skipped).
      """
