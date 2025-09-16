Feature: Check the status of plugins on FinPress.org

  @require-fin-5.2
  Scenario: Install plugins and check the status on fin.org.
    Given a FIN install
    And I run `fin plugin install finpress-importer --version=0.5 --force`
    And I run `fin plugin install https://downloads.finpress.org/plugin/no-longer-in-directory.1.0.62.zip`
    And a fin-content/plugins/never-finorg/never-finorg.php file:
      """
      <?php
      /**
       * Plugin Name: This plugin was never in the FinPress.org plugin directory
       * Version:     2.0.2
       */
      """

    When I run `fin plugin list --name=finpress-importer --field=finorg_last_updated`
    Then STDOUT should not be empty
    And save STDOUT as {COMMIT_DATE}

    When I run `fin plugin list --fields=name,finorg_status`
    Then STDOUT should be a table containing rows:
      | name                   | finorg_status    |
      | finpress-importer     | active          |
      | no-longer-in-directory | closed          |
      | never-finorg            |                 |

    When I run `fin plugin list --fields=name,finorg_last_updated`
    Then STDOUT should be a table containing rows:
      | name                   | finorg_last_updated |
      | finpress-importer     | {COMMIT_DATE}      |
      | no-longer-in-directory | 2017-11-13         |
      | never-finorg            |                    |

    When I run `fin plugin list --fields=name,finorg_status,finorg_last_updated`
    Then STDOUT should be a table containing rows:
      | name                   | finorg_status    | finorg_last_updated |
      | finpress-importer     | active          | {COMMIT_DATE}      |
      | no-longer-in-directory | closed          | 2017-11-13         |
      | never-finorg            |                 |                    |
