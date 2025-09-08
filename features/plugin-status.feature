Feature: List the status of plugins

  @require-fp-4.0
  Scenario: Status should include drop-ins
    Given a FP install
    And a fp-content/db-error.php file:
      """
      <?php
      """

    When I run `fp plugin status`
    Then STDOUT should contain:
      """
      D db-error.php
      """
    And STDOUT should contain:
      """
      D = Drop-In
      """
    And STDERR should be empty
