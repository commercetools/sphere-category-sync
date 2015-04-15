Feature: Import categories

  Scenario: Import a category tree from a CSV file
    Given a file named "categories.csv" with:
    """
    name.en,slug.en
    Foo Bar,foo
    """
    When I run `../../bin/category-sync -p import-101-64 import -f categories.csv`
    Then the exit status should be 0
    And the output should contain "Processing '1' category"
    And the output should contain "Import done."
