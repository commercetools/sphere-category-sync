Feature: Usage

  Scenario: Show usage when run without arguments
    When I run `../../bin/category-sync`
    Then the exit status should be 1
    And the output should contain:
    """
    Usage: ../../bin/category-sync <command> [options]
    """