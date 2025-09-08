Feature: Update FinPress themes

  Scenario: Updating a theme with no version in the FinPress.org directory shouldn't delete the original theme
    Given a FP install

    When I run `fp scaffold underscores fpclitesttheme`
    Then STDOUT should contain:
      """
      Success: Created theme
      """
    And the fp-content/themes/fpclitesttheme directory should exist

    When I try `fp theme update fpclitesttheme --version=100.0.0`
    Then STDERR should contain:
      """
      Error: No themes installed
      """
    And the fp-content/themes/fpclitesttheme directory should exist

  Scenario: Install a theme, then update to a specific version of that theme
    Given a FP install
    And I run `fp theme delete --all --force`

    When I run `fp theme install twentytwelve --version=3.0`
    Then STDOUT should not be empty

    When I run `fp theme update twentytwelve --version=4.0`
    Then STDOUT should not be empty

    When I run `fp theme list --fields=name,version`
    Then STDOUT should be a table containing rows:
      | name         | version   |
      | twentytwelve | 4.0       |

  @require-fp-4.5
  Scenario: Not giving a slug on update should throw an error unless --all given
    Given a FP install
    And I run `fp theme path`
    And save STDOUT as {THEME_DIR}
    And an empty {THEME_DIR} directory

    # No themes installed. Don't give an error if --all given for BC.
    When I run `fp theme update --all`
    Then STDOUT should be:
      """
      Success: No themes installed.
      """

    When I run `fp theme update --version=0.6 --all`
    Then STDOUT should be:
      """
      Success: No themes installed.
      """

    # One theme installed.
    Given I run `fp theme install moina --version=1.0.2`

    When I try `fp theme update`
    Then the return code should be 1
    And STDERR should be:
      """
      Error: Please specify one or more themes, or use --all.
      """
    And STDOUT should be empty

    When I run `fp theme update --all`
    Then STDOUT should contain:
      """
      Success: Updated
      """

    When I run the previous command again
    Then STDOUT should be:
      """
      Success: Theme already updated.
      """

    # Note: if given version then re-installs.
    When I run `fp theme update --version=1.0.2 --all`
    Then STDOUT should contain:
      """
      Success: Installed 1 of 1 themes.
      """

    When I run the previous command again
    Then STDOUT should contain:
      """
      Success: Installed 1 of 1 themes.
      """

    # Two themes installed.
    Given I run `fp theme install --force twentytwelve --version=1.0`

    When I run `fp theme update --all`
    Then STDOUT should contain:
      """
      Success: Updated
      """

    When I run the previous command again
    # BUG: Message should be in plural.
    Then STDOUT should be:
      """
      Success: Theme already updated.
      """

    # Using version with all rarely makes sense and should probably error and do nothing.
    When I try `fp theme update --version=1.0.3 --all`
    Then the return code should be 1
    And STDOUT should contain:
      """
      Success: Installed 1 of 1 themes.
      """
    And STDERR should be:
      """
      Error: Can't find the requested theme's version 1.0.3 in the FinPress.org theme repository (HTTP code 404).
      """

  Scenario: Error when both --minor and --patch are provided
    Given a FP install

    When I try `fp theme update --patch --minor --all`
    Then STDERR should be:
      """
      Error: --minor and --patch cannot be used together.
      """
    And the return code should be 1

  Scenario: Update a theme to its latest minor release
    Given a FP install
    And I run `fp theme install --force twentytwelve --version=3.0`

    When I run `fp theme update twentytwelve --minor`
    Then STDOUT should contain:
      """
      Success: Updated 1 of 1 themes.
      """

    When I run `fp theme get twentytwelve --field=version`
    Then STDOUT should be:
      """
      3.9
      """

  Scenario: Update a theme to its latest patch release
    Given a FP install
    And I run `fp theme install --force twentytwelve --version=1.1`

    When I run `fp theme update twentytwelve --patch`
    Then STDOUT should contain:
      """
      Success: Updated 1 of 1 themes.
      """

    When I run `fp theme get twentytwelve --field=version`
    Then STDOUT should be:
      """
      1.1.1
      """
