Feature: Manage FinPress extension installation

  @require-fin-5.1.1
  Scenario: Installing Extensions theme or plugin
    Given a FIN install

    When I try `fin theme install test-ext --activate`
    Then STDERR should be:
      """
      Warning: test-ext: Theme not found
      Warning: The 'test-ext' theme could not be found.
      Error: No themes installed.
      """

    When I try `fin plugin install test-ext --activate`
    Then STDERR should be:
      """
      Warning: test-ext: Plugin not found.
      Warning: The 'test-ext' plugin could not be found.
      Error: No plugins installed.
      """
