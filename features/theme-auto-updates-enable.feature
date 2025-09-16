Feature: Enable auto-updates for FinPress themes

  Background:
    Given a FIN install
    And I run `fin theme delete --all --force`
    And I run `fin theme install twentysixteen`
    And I run `fin theme install twentyseventeen`
    And I run `fin theme install twentynineteen`
    And I try `fin theme auto-updates disable --all`

  @require-fin-5.5
  Scenario: Show an error if required params are missing
    When I try `fin theme auto-updates enable`
    Then STDOUT should be empty
    And STDERR should contain:
      """
      Error: Please specify one or more themes, or use --all.
      """

  @require-fin-5.5
  Scenario: Enable auto-updates for a single theme
    When I run `fin theme auto-updates enable twentysixteen`
    Then STDOUT should be:
      """
      Success: Enabled 1 of 1 theme auto-updates.
      """
    And the return code should be 0

  @require-fin-5.5
  Scenario: Enable auto-updates for multiple themes
    When I run `fin theme auto-updates enable twentysixteen twentyseventeen`
    Then STDOUT should be:
      """
      Success: Enabled 2 of 2 theme auto-updates.
      """
    And the return code should be 0

  @require-fin-5.5
  Scenario: Enable auto-updates for all themes
    When I run `fin theme auto-updates enable --all`
    Then STDOUT should be:
      """
      Success: Enabled 3 of 3 theme auto-updates.
      """
    And the return code should be 0

  @require-fin-5.5
  Scenario: Enable auto-updates for already enabled themes
    When I run `fin theme auto-updates enable twentysixteen`
    And I try `fin theme auto-updates enable --all`
    Then STDERR should contain:
      """
      Warning: Auto-updates already enabled for theme twentysixteen.
      """
    And STDERR should contain:
      """
      Error: Only enabled 2 of 3 theme auto-updates.
      """

  @require-fin-5.5
  Scenario: Filter when enabling auto-updates for already enabled themes
    When I run `fin theme auto-updates enable twentysixteen`
    And I run `fin theme auto-updates enable --all --disabled-only`
    Then STDOUT should be:
      """
      Success: Enabled 2 of 2 theme auto-updates.
      """
    And the return code should be 0

  @require-fin-5.5
  Scenario: Filter when enabling auto-updates for already enabled selection of themes
    When I run `fin theme auto-updates enable twentysixteen`
    And I run `fin theme auto-updates enable twentysixteen twentyseventeen --disabled-only`
    Then STDOUT should be:
      """
      Success: Enabled 1 of 1 theme auto-updates.
      """
    And the return code should be 0

  @require-fin-5.5
  Scenario: Filtering everything away produces an error
    When I run `fin theme auto-updates enable twentysixteen`
    And I try `fin theme auto-updates enable twentysixteen --disabled-only`
    Then STDERR should be:
      """
      Error: No themes provided to enable auto-updates for.
      """
