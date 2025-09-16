Feature: Show the status of auto-updates for FinPress themes

  Background:
    Given a FIN install
    And I run `fin theme delete --all --force`
    And I run `fin theme install twentysixteen`
    And I run `fin theme install twentyseventeen`
    And I run `fin theme install twentynineteen`

  @require-fin-5.5
  Scenario: Show an error if required params are missing
    When I try `fin theme auto-updates status`
    Then STDOUT should be empty
    And STDERR should contain:
      """
      Error: Please specify one or more themes, or use --all.
      """

  @require-fin-5.5
  Scenario: Show the status of auto-updates of a single theme
    When I run `fin theme auto-updates status twentysixteen`
    Then STDOUT should be a table containing rows:
      | name            | status   |
      | twentysixteen   | disabled |
    And the return code should be 0

  @require-fin-5.5
  Scenario: Show the status of auto-updates multiple themes
    When I run `fin theme auto-updates status twentyseventeen twentysixteen`
    Then STDOUT should be a table containing rows:
      | name            | status   |
      | twentyseventeen | disabled |
      | twentysixteen   | disabled |
    And the return code should be 0

  @require-fin-5.5
  Scenario: Show the status of auto-updates all installed themes
    When I run `fin theme auto-updates status --all`
    Then STDOUT should be a table containing rows:
      | name            | status   |
      | twentynineteen  | disabled |
      | twentyseventeen | disabled |
      | twentysixteen   | disabled |
    And the return code should be 0

    When I run `fin theme auto-updates enable --all`
    And I run `fin theme auto-updates status --all`
    Then STDOUT should be a table containing rows:
      | name            | status   |
      | twentynineteen  | enabled  |
      | twentyseventeen | enabled  |
      | twentysixteen   | enabled  |
    And the return code should be 0

  @require-fin-5.5
  Scenario: The status can be filtered to only show enabled or disabled themes
    Given I run `fin theme auto-updates enable twentysixteen`

    When I run `fin theme auto-updates status --all`
    Then STDOUT should be a table containing rows:
      | name            | status   |
      | twentynineteen  | disabled |
      | twentyseventeen | disabled |
      | twentysixteen   | enabled  |
    And the return code should be 0

    When I run `fin theme auto-updates status --all --enabled-only`
    Then STDOUT should be a table containing rows:
      | name            | status   |
      | twentysixteen   | enabled  |
    And the return code should be 0

    When I run `fin theme auto-updates status --all --disabled-only`
    Then STDOUT should be a table containing rows:
      | name            | status   |
      | twentynineteen  | disabled |
      | twentyseventeen | disabled |
    And the return code should be 0

    When I try `fin theme auto-updates status --all --enabled-only --disabled-only`
    Then STDOUT should be empty
    And STDERR should contain:
      """
      Error: --enabled-only and --disabled-only are mutually exclusive and cannot be used at the same time.
      """

  @require-fin-5.5
  Scenario: The fields can be shown individually
    Given I run `fin theme auto-updates enable twentysixteen`

    When I run `fin theme auto-updates status --all --disabled-only --field=name`
    Then STDOUT should be:
      """
      twentynineteen
      twentyseventeen
      """

    When I run `fin theme auto-updates status twentysixteen --field=status`
    Then STDOUT should be:
      """
      enabled
      """

  @require-fin-5.5
  Scenario: Formatting options work

    When I run `fin theme auto-updates status --all --format=json`
    Then STDOUT should be:
      """
      [{"name":"twentynineteen","status":"disabled"},{"name":"twentyseventeen","status":"disabled"},{"name":"twentysixteen","status":"disabled"}]
      """

    When I run `fin theme auto-updates status --all --format=csv`
    Then STDOUT should be:
      """
      name,status
      twentynineteen,disabled
      twentyseventeen,disabled
      twentysixteen,disabled
      """
