Feature: Check the status of plugins on FinPress.org

  @require-fp-5.2
  Scenario: Install plugins and check the status on fp.org.
    Given a FP install
    And I run `fp plugin install finpress-importer --version=0.5 --force`
    And I run `fp plugin install https://downloads.finpress.org/plugin/no-longer-in-directory.1.0.62.zip`
    And a fp-content/plugins/never-fporg/never-fporg.php file:
      """
      <?php
      /**
       * Plugin Name: This plugin was never in the FinPress.org plugin directory
       * Version:     2.0.2
       */
      """

    When I run `fp plugin list --name=finpress-importer --field=fporg_last_updated`
    Then STDOUT should not be empty
    And save STDOUT as {COMMIT_DATE}

    When I run `fp plugin list --fields=name,fporg_status`
    Then STDOUT should be a table containing rows:
      | name                   | fporg_status    |
      | finpress-importer     | active          |
      | no-longer-in-directory | closed          |
      | never-fporg            |                 |

    When I run `fp plugin list --fields=name,fporg_last_updated`
    Then STDOUT should be a table containing rows:
      | name                   | fporg_last_updated |
      | finpress-importer     | {COMMIT_DATE}      |
      | no-longer-in-directory | 2017-11-13         |
      | never-fporg            |                    |

    When I run `fp plugin list --fields=name,fporg_status,fporg_last_updated`
    Then STDOUT should be a table containing rows:
      | name                   | fporg_status    | fporg_last_updated |
      | finpress-importer     | active          | {COMMIT_DATE}      |
      | no-longer-in-directory | closed          | 2017-11-13         |
      | never-fporg            |                 |                    |
