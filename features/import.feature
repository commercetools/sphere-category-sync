Feature: Import categories

  @wip
  Scenario: Error on wrong file
    When I run `category-sync -p import-101-64 import -f not_here.csv`
    Then the exit status should be 1
    And the output should contain "Error: ENOENT, open 'not_here.csv'"

  Scenario: Import a single category from a CSV file
    Given a file named "single.csv" with:
    """
    name.en,slug.en
    Some Category,some-category
    """
    When I run `category-sync -p import-101-64 import -f single.csv`
    Then the exit status should be 0
    And the output should contain "Processing '1' category"
    And the output should contain "Import done."

  Scenario: Import a simple tree of categories from a CSV file
    Given a file named "simple-tree.csv" with:
    """
    externalId,name.en,slug.en,parentId
    rootCat,Root Category,root-category,
    subCat,Sub Category,sub-category,rootCat
    """
    When I run `category-sync -p import-101-64 import -f simple-tree.csv`
    Then the exit status should be 0
    And the output should contain "Found parent for 'rootCat' using externalId (language: en)."
    And the output should contain "Import done."

  Scenario: Use slug as parentId during import
    Given a file named "import-by-slug.csv" with:
    """
    name.en,slug.en,parentId
    Root Category,root-slug,
    Sub Category,sub-category-slug,root-slug
    Sub Sub Category 1,x,sub-category-slug
    Sub Sub Category 2,y,sub-category-slug
    """
    When I run `category-sync -p import-101-64 import --parentBy slug -f import-by-slug.csv`
    Then the exit status should be 0
    And the output should contain "Found parent for 'root-slug' using slug (language: en)."
    And the output should contain "Found parent for 'sub-category-slug' using slug (language: en)."
    And the output should contain "Import done."

  Scenario: Continue on problems
    Given a file named "problem.csv" with:
    """
    name.en,slug.en,parentId
    A Category,a-slug,Not Existing!!!
    """
    When I run `category-sync --continueOnProblems -p import-101-64 import -f problem.csv`
    Then the exit status should be 0
    And the output should contain "Could not resolve parent for 'Not Existing!!!' using externalId (language: en)."
    And the output should contain "Import done."
