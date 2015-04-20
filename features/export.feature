Feature: Export categories

  Scenario: Error on wrong template file
    When I run `../../bin/category-sync -p import-101-64 export -t nothere.csv -o output.csv`
    Then the exit status should be 8

  Scenario: Error on unwriteable output
    Given a file named "template.csv" with:
    """
    id
    """
    When I run `../../bin/category-sync -p import-101-64 export -t template.csv -o /output.csv`
    Then the exit status should be 8

  Scenario: Export category to a CSV file
    Given a file named "single.csv" with:
    """
    name.en,slug.en
    Some Export Category,some-export-category
    """
    And a file named "template.csv" with:
    """
    id
    """
    When I run `../../bin/category-sync -p import-101-64 import -f single.csv`
    Then the exit status should be 0
    When I run `../../bin/category-sync -p import-101-64 export -t single.csv -o output.csv`
    Then the exit status should be 0
    Then a file named "output.csv" should exist
    And the file "output.csv" should contain "name.en,slug.en"
    And the file "output.csv" should contain "Some Export Category,some-export-category"


