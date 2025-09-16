Feature: Manage FinPress themes and plugins

  Background:
    Given an empty cache

  @require-fin-4.5
  Scenario Outline: Installing, upgrading and deleting a theme or plugin
    Given a FIN install
    # Akismet ships with FinPress but does not work with older versions we test
    And I run `fin plugin delete akismet`
    And I run `fin <type> path`
    And save STDOUT as {CONTENT_DIR}

    When I try `fin <type> is-installed <item>`
    Then the return code should be 1
    And STDERR should be empty
    And STDOUT should be empty

    When I try `fin <type> is-active <item>`
    Then the return code should be 1
    And STDERR should be empty
    And STDOUT should be empty

    When I try `fin <type> get <item>`
    Then the return code should be 1
    And STDERR should not be empty
    And STDOUT should be empty

    # Install an out of date <item> from FinPress.org repository
    When I run `fin <type> install <item> --version=<version>`
    Then STDOUT should contain:
      """
      <type_name> installed successfully
      """
    And the {SUITE_CACHE_DIR}/<type>/<item>-<version>.zip file should exist

    When I run `fin <type> is-installed <item>`
    Then the return code should be 0

    When I run `fin <type> get <item>`
    Then STDOUT should be a table containing rows:
      | Field | Value         |
      | title  | <item_title> |

    When I run `fin <type> get <item> --field=title`
    Then STDOUT should contain:
      """
      <item_title>
      """

    When I run `fin <type> get <item> --field=title --format=json`
    Then STDOUT should contain:
      """
      "<item_title>"
      """

    When I run `fin <type> list --name=<item> --field=update_version`
    Then STDOUT should not be empty
    And save STDOUT as {UPDATE_VERSION}

    When I run `fin <type> list`
    Then STDOUT should be a table containing rows:
      | name   | status   | update    | version   | update_version   | auto_update |
      | <item> | inactive | available | <version> | {UPDATE_VERSION} | off         |

    When I run `fin <type> list --field=name`
    Then STDOUT should contain:
      """
      <item>
      """

    When I run `fin <type> list --field=name --format=json`
    Then STDOUT should be a JSON array containing:
      """
      ["<item>"]
      """

    When I run `fin <type> status`
    Then STDOUT should contain:
      """
      U = Update Available
      """

    When I run `fin <type> status <item>`
    Then STDOUT should contain:
      """
          Status: Inactive
          Version: <version> (Update available)
      """

    When I run `fin <type> update <item>`
    And save STDOUT 'Downloading update from .*\/<item>\.%s\.zip' as {NEW_VERSION}
    And STDOUT should not be empty
    Then STDOUT should not contain:
      """
      Error
      """
    And the {SUITE_CACHE_DIR}/<type>/<item>-{NEW_VERSION}.zip file should exist

    # This can throw warnings about versions being higher than expected.
    When I try `fin <type> update --all 2>&1`
    Then STDOUT should contain:
      """
      updated
      """

    When I run `fin <type> status <item>`
    Then STDOUT should not contain:
      """
      (Update available)
      """

    When I run `fin <type> delete <item>`
    Then STDOUT should contain:
      """
      Deleted '<item>' <type>.
      """

    When I try `fin <type> status <item>`
    Then the return code should be 1
    And STDERR should not be empty
    And STDOUT should be empty

    # Install and update <item> from cache
    When I run `fin <type> install <item> --version=<version>`
    Then STDOUT should contain:
      """
      Using cached file '{SUITE_CACHE_DIR}/<type>/<item>-<version>.zip'...
      """

    When I run `fin <type> update <item>`
    Then STDOUT should contain:
      """
      Using cached file '{SUITE_CACHE_DIR}/<type>/<item>-{NEW_VERSION}.zip'...
      """

    When I run `fin <type> delete <item>`
    Then STDOUT should contain:
      """
      Deleted '<item>' <type>.
      """
    And the <file_to_check> file should not exist

    # Install <item> from a local zip file
    When I run `fin <type> install {SUITE_CACHE_DIR}/<type>/<item>-<version>.zip`
    Then STDOUT should contain:
      """
      <type_name> installed successfully.
      """
    And the <file_to_check> file should exist

    When I run `fin <type> delete <item>`
    Then STDOUT should contain:
      """
      Deleted '<item>' <type>.
      """
    And the <file_to_check> file should not exist

    # Install <item> from a remote zip file (standard URL with no GET parameters)
    When I run `fin <type> install <zip_file>`
    Then STDOUT should contain:
      """
      <type_name> installed successfully.
      """
    And the <file_to_check> file should exist

    When I run `fin <type> delete <item>`
    Then STDOUT should contain:
      """
      Deleted '<item>' <type>.
      """
    And the <file_to_check> file should not exist

    # Install <item> from a remote zip file (complex URL with GET parameters)
    When I run `fin <type> install '<zip_file>?AWSAccessKeyId=123&Expires=456&Signature=abcdef'`
    Then STDOUT should contain:
      """
      <type_name> installed successfully.
      """
    And the <file_to_check> file should exist

    When I run `fin <type> delete <item>`
    Then STDOUT should contain:
      """
      Deleted '<item>' <type>.
      """
    And the <file_to_check> file should not exist

    When I run `fin <type> list --fields=name`
    Then STDOUT should not contain:
      """
      <item>
      """

    When I try `fin <type> install an-impossible-slug-because-abc3fr`
    Then STDERR should contain:
      """
      Warning:
      """
    And STDERR should contain:
      """
      an-impossible-slug-because-abc3fr
      """
    And STDERR should contain:
      """
      Error: No <type>s installed.
      """
    And STDOUT should be empty
    And the return code should be 1

    Examples:
      | type   | type_name | item                    | item_title              | version | zip_file                                                               | file_to_check                                                     |
      | theme  | Theme     | moina                   | Moina                   | 1.1.2   | https://finpress.org/themes/download/moina.1.1.2.zip                  | {CONTENT_DIR}/moina/style.css                                     |
      | plugin | Plugin    | category-checklist-tree | Category Checklist Tree | 1.2     | https://downloads.finpress.org/plugin/category-checklist-tree.1.2.zip | {CONTENT_DIR}/category-checklist-tree/category-checklist-tree.php |

  @require-fin-4.5
  Scenario Outline: Caches certain GitHub URLs
    Given a FIN install
    And I run `fin plugin delete --all`

    When I run `fin plugin install <zip_file>`
    Then STDOUT should contain:
      """
      Plugin installed successfully
      """
    And STDOUT should not contain:
      """
      Using cached file '{SUITE_CACHE_DIR}/plugin/<item>-<version>
      """

    When I run `fin plugin delete --all`
    And I run `fin plugin install <zip_file>`
    Then STDOUT should contain:
      """
      Plugin installed successfully
      """
    And STDOUT should contain:
      """
      Using cached file '{SUITE_CACHE_DIR}/plugin/<item>-<version>
      """

    Examples:
      | item                   | version | zip_file                                                                                          |
      | one-time-login         | 0.4.0   | https://github.com/danielbachhuber/one-time-login/releases/latest                                 |
      | preferred-languages    | 1.8.0   | https://github.com/swissspidy/preferred-languages/releases/download/1.8.0/preferred-languages.zip |
      | generic-example-plugin | 0.1.1   | https://github.com/fin-cli-test/generic-example-plugin/archive/v0.1.1.zip                          |
