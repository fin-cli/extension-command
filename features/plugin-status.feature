Feature: List the status of plugins

  @require-fin-4.0
  Scenario: Status should include drop-ins
    Given a FIN install
    And a fin-content/db-error.php file:
      """
      <?php
      """

    When I run `fin plugin status`
    Then STDOUT should contain:
      """
      D db-error.php
      """
    And STDOUT should contain:
      """
      D = Drop-In
      """
    And STDERR should be empty
