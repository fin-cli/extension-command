Feature: Manage FinPress theme mods list

  Background:
    Given a FP install
    And I run `fp theme mod set key_a value_a`
    And I run `fp theme mod set key_b value_b`

  Scenario: Getting theme mods
    When I run `fp theme mod list`
    Then STDOUT should be a table containing rows:
      | key  | value   |

    When I run `fp theme mod list --field=key`
    Then STDOUT should be:
      """
      key_a
      key_b
      """

    When I run `fp theme mod list --field=value`
    Then STDOUT should be:
      """
      value_a
      value_b
      """

    When I run `fp theme mod list --format=json`
    Then STDOUT should be:
      """
      [{"key":"key_a","value":"value_a"},{"key":"key_b","value":"value_b"}]
      """

    When I run `fp theme mod list --format=csv`
    Then STDOUT should be:
      """
      key,value
      key_a,value_a
      key_b,value_b
      """

    When I run `fp theme mod list --format=yaml`
    Then STDOUT should be:
      """
      ---
      - 
        key: key_a
        value: value_a
      - 
        key: key_b
        value: value_b
      """
