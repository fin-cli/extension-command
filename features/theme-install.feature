Feature: Install FinPress themes

  Background:
    Given a FP install
    And I run `fp theme delete --all --force`

  Scenario: Return code is 1 when one or more theme installations fail
    When I try `fp theme install twentytwelve twentytwelve-not-a-theme`
    Then STDERR should contain:
      """
      Warning:
      """
    And STDERR should contain:
      """
      twentytwelve-not-a-theme
      """
    And STDERR should contain:
      """
      Error: Only installed 1 of 2 themes.
      """
    And STDOUT should contain:
      """
      Installing Twenty Twelve
      """
    And STDOUT should contain:
      """
      Theme installed successfully.
      """
    And the return code should be 1

    When I try `fp theme install twentytwelve`
    Then STDOUT should be:
      """
      Success: Theme already installed.
      """
    And STDERR should be:
      """
      Warning: twentytwelve: Theme already installed.
      """
    And the return code should be 0

    When I try `fp theme install twentytwelve-not-a-theme`
    Then STDERR should contain:
      """
      Warning:
      """
    And STDERR should contain:
      """
      twentytwelve-not-a-theme
      """
    And STDERR should contain:
      """
      Error: No themes installed.
      """
    And STDOUT should be empty
    And the return code should be 1

  Scenario: Ensure automatic parent theme installation uses http cacher
    Given a FP install
    And an empty cache

    When I run `fp theme install moina`
    Then STDOUT should contain:
      """
      Success: Installed 1 of 1 themes.
      """
    And STDOUT should not contain:
      """
      Using cached file
      """

    When I run `fp theme uninstall moina`
    Then STDOUT should contain:
      """
      Success: Deleted 1 of 1 themes.
      """

    When I run `fp theme install moina-blog`
    Then STDOUT should contain:
      """
      Success: Installed 1 of 1 themes.
      """
    And STDOUT should contain:
      """
      This theme requires a parent theme.
      """
    And STDOUT should contain:
      """
      Using cached file
      """

  Scenario: Verify installed theme activation
    When I run `fp theme install twentytwelve`
    Then STDOUT should not be empty

    When I try `fp theme install twentytwelve --activate`
    Then STDERR should contain:
      """
      Warning: twentytwelve: Theme already installed.
      """

    And STDOUT should contain:
      """
      Activating 'twentytwelve'...
      Success: Switched to 'Twenty Twelve' theme.
      Success: Theme already installed.
      """

  Scenario: Installation of multiple themes with activate
    When I try `fp theme install twentytwelve twentyeleven --activate`
    Then STDERR should contain:
      """
      Warning: Only this single theme will be activated: twentyeleven
      """

    When I run `fp theme list --field=name`
    Then STDOUT should contain:
      """
      twentyeleven
      twentytwelve
      """

    When I run `fp theme list --field=name --status=active`
    Then STDOUT should contain:
      """
      twentyeleven
      """

  @require-php-7
  Scenario: Can't install theme that requires a newer version of FinPress
    Given a FP install

    When I run `fp core download --version=6.4 --force`
    And I run `rm -r fp-content/themes/*`

    And I try `fp theme install twentytwentyfive`
    Then STDERR should contain:
      """
      Warning: twentytwentyfive: This theme does not work with your version of FinPress.
      """

    And STDERR should contain:
      """
      Error: No themes installed.
      """

  @less-than-php-7.4 @require-fp-5.6
  Scenario: Can't install theme that requires a newer version of PHP
    Given a FP install

    And I try `fp theme install oceanfp`
    Then STDERR should contain:
      """
      Warning: oceanfp: This theme does not work with your version of PHP.
      """

    And STDERR should contain:
      """
      Error: No themes installed.
      """
