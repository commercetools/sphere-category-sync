Feature: Import categories

  Scenario: Import a single category from a CSV file
    Given a file named "single.csv" with:
    """
    name.en,slug.en
    Some Category,some-category
    """
    When I run `../../bin/category-sync -p import-101-64 import -f single.csv`
    Then the exit status should be 0
    And the output should contain "Processing '1' category"
    And the output should contain "Import done."

  Scenario: Import a simple tree of categories from a CSV file
    Given a file named "simple-tree.csv" with:
    """
    externalId,name.en,slug.en,parentId
    root2,Root Category,root-category,
    sub2,Sub Category,sub-categorty,root2
    """
    When I run `../../bin/category-sync -p import-101-64 import -f simple-tree.csv`
    Then the exit status should be 0
    And the output should contain "Found parent"
    And the output should contain "Import done."
