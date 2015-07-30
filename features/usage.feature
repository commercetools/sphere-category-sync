Feature: Usage

  Scenario: Show usage when run without arguments
    When I run `category-sync`
    Then the exit status should be 1
    And the output should contain:
    """
    category-sync <command> [options]
    """