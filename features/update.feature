Feature: Update categories

  Scenario: Update a single category from a CSV file
    Given a file named "update.csv" with:
    """
    externalId,name.en,slug.en,orderHint
    exId1,Category to update,category-to-update,0.1
    """
    When I run `../../bin/category-sync -p import-101-64 import -f update.csv`
    Then the exit status should be 0
    When I run `../../bin/category-sync -p import-101-64 import -f update.csv`
    Then the exit status should be 0
    And the output should contain "Processing '1' category"
    And the output should contain "Found candidates: 1"
    And the output should contain "Found match for externalId 'exId1'"
