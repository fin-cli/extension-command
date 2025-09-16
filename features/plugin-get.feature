Feature: Get FinPress plugin

  Scenario: Get plugin info
    Given a FIN install
    And a fin-content/plugins/foo.php file:
      """
      /**
       * Plugin Name: Sample Plugin
       * Description: Description for sample plugin.
       * Requires at least: 6.0
       * Requires PHP: 5.6
       * Version: 1.0.0
       * Author: John Doe
       * Author URI: https://example.com/
       * License: GPLv2 or later
       * License URI: https://www.gnu.org/licenses/old-licenses/gpl-2.0.html
       * Text Domain: sample-plugin
       */
      """

    When I run `fin plugin get foo --fields=name,author,version,status`
    Then STDOUT should be a table containing rows:
      | Field   | Value    |
      | name    | foo      |
      | author  | John Doe |
      | version | 1.0.0    |
      | status  | inactive |

    When I run `fin plugin get foo --format=json`
    Then STDOUT should be:
      """
      {"name":"foo","title":"Sample Plugin","author":"John Doe","version":"1.0.0","description":"Description for sample plugin.","status":"inactive"}
      """

  @require-fin-6.5
  Scenario: Get Requires Plugins header of plugin
    Given a FIN install
    And a fin-content/plugins/foo.php file:
      """
      <?php
      /**
       * Plugin Name: Foo
       * Description: Foo plugin
       * Author: John Doe
       * Requires Plugins: jetpack, woocommerce
       */
      """

    When I run `fin plugin get foo --field=requires_plugins`
    Then STDOUT should be:
      """
      jetpack, woocommerce
      """

  @require-fin-5.3
  Scenario: Get Requires PHP and Requires FIN header of plugin
    Given a FIN install
    And a fin-content/plugins/foo.php file:
      """
      <?php
      /**
       * Plugin Name: Foo
       * Description: Foo plugin
       * Author: John Doe
       * Requires at least: 6.2
       * Requires PHP: 7.4
       */
      """

    When I run `fin plugin get foo --fields=requires_fin,requires_php`
    Then STDOUT should be a table containing rows:
      | Field        | Value |
      | requires_fin  | 6.2   |
      | requires_php | 7.4   |
