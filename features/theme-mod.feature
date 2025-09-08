Feature: Manage FinPress theme mods

  Scenario: Getting theme mods
    Given a FP install

    When I run `fp theme mod get --all`
    Then STDOUT should be a table containing rows:
      | key  | value   |

    When I try `fp theme mod get`
    Then STDERR should contain:
      """
      You must specify at least one mod or use --all.
      """
    And STDOUT should be empty
    And the return code should be 1

    When I run `fp theme mod set background_color 123456`
    And I run `fp theme mod get --all`
    Then STDOUT should be a table containing rows:
      | key               | value    |
      | background_color  | 123456   |

    When I run `fp theme mod get background_color --field=value`
    Then STDOUT should be:
      """
      123456
      """

    When I run `fp theme mod set background_color 123456`
    And I run `fp theme mod get background_color header_textcolor`
    Then STDOUT should be a table containing rows:
      | key               | value    |
      | background_color  | 123456   |
      | header_textcolor  |          |

  Scenario: Setting theme mods
    Given a FP install

    When I run `fp theme mod set background_color 123456`
    Then STDOUT should be:
      """
      Success: Theme mod background_color set to 123456.
      """

  Scenario: Removing theme mods
    Given a FP install

    When I run `fp theme mod remove --all`
    Then STDOUT should be:
      """
      Success: Theme mods removed.
      """

    When I try `fp theme mod remove`
    Then STDERR should contain:
      """
      You must specify at least one mod or use --all.
      """
    And STDOUT should be empty
    And the return code should be 1

    When I run `fp theme mod remove background_color`
    Then STDOUT should be:
      """
      Success: 1 mod removed.
      """

    When I run `fp theme mod remove background_color header_textcolor`
    Then STDOUT should be:
      """
      Success: 2 mods removed.
      """
