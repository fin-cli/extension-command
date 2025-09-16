Feature: Search FinPress.org plugins

  Scenario: Search for plugins with active_installs field
    Given a FIN install

    When I run `fin plugin search foo --fields=name,slug,active_installs`
    Then STDOUT should contain:
      """
      Success: Showing
      """

    When I run `fin plugin search foo --fields=name,slug,active_installs --format=csv`
    Then STDOUT should not contain:
      """
      Success: Showing
      """
    And STDOUT should contain:
      """
      name,slug,active_installs
      """
