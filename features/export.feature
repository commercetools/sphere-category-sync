Feature: Export categories

  Scenario: Error on wrong template file
    When I run `../../bin/category-sync -p import-101-64 export -t not_here.csv -o output.csv`
    Then the exit status should be 1
    And the output should contain "Error: ENOENT, open 'not_here.csv'"

  Scenario: Error on unwriteable output
    Given a file named "template.csv" with:
    """
    id
    """
    When I run `../../bin/category-sync -p import-101-64 export -t template.csv -o /output.csv`
    Then the exit status should be 1
    And the output should contain "Error: EACCES, open '/output.csv'"

  Scenario: Export category to a CSV file
    Given a file named "single.csv" with:
    """
    name.en,slug.en
    Some Export Category,some-export-category
    """
    When I run `../../bin/category-sync -p import-101-64 import -f single.csv`
    Then the exit status should be 0
    When I run `../../bin/category-sync -p import-101-64 export -t single.csv -o output1.csv`
    Then the exit status should be 0
    Then a file named "output1.csv" should exist
    And the file "output1.csv" should contain "name.en,slug.en"
    And the file "output1.csv" should contain "Some Export Category,some-export-category"

  Scenario: Impex all possible attributes
    Given a file named "full.csv" with:
    """
    externalId,name.en,slug.en,description.en,metaTitle.en,metaDescription.en,metaKeywords.en,orderHint,parentId
    1,Nice Stuff,nice-stuff,It's very nice stuff - bla bla,nice stuff,SEO magic for the nice stuff,nice;stuff,0.1
    2,Old Stuff,old-stuff,It's pretty old stuff - foo bar,old stuff,even more SEO magic needed for old stuff,stuff;old,0.9,1
    """
    When I run `../../bin/category-sync -p import-101-64 import -f full.csv`
    Then the exit status should be 0
    When I run `../../bin/category-sync -p import-101-64 export -t full.csv -o output.csv`
    Then the exit status should be 0
    Then a file named "output.csv" should exist
    And the file "output.csv" should contain "externalId,name.en,slug.en,description.en,metaTitle.en,metaDescription.en,metaKeywords.en,orderHint"
    And the file "output.csv" should contain "1,Nice Stuff,nice-stuff,It's very nice stuff - bla bla,nice stuff,SEO magic for the nice stuff,nice;stuff,0.1"

    Given a file named "template.csv" with:
    """
    id
    """
    When I run `../../bin/category-sync -p import-101-64 export -t template.csv -o output2.csv`
    Then the exit status should be 0
    Then a file named "output2.csv" should exist
    And the file "output2.csv" should contain "id"
    And the file "output2.csv" should match /[a-z,0-9,\-]{36}/

