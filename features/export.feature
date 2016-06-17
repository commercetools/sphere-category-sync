Feature: Export categories

  Scenario: Error on wrong template file
    When I run `category-sync -p import-101-64 export -t not_here.csv -o output.csv`
    Then the exit status should be 1
    And the output should contain "Error: ENOENT"
    And the output should contain "open 'not_here.csv'"

  Scenario: Error on unwriteable output
    Given a file named "template.csv" with:
    """
    id
    """
    When I run `category-sync -p import-101-64 export -t template.csv -o /output.csv`
    Then the exit status should be 1
    And the output should contain "Error: EACCES"
    And the output should contain "open '/output.csv'"

  Scenario: Export category to a CSV file
    Given a file named "single.csv" with:
    """
    name.en,slug.en
    Some Export Category,some-export-category
    """
    When I run `category-sync -p import-101-64 import -f single.csv`
    Then the exit status should be 0
    When I run `category-sync -p import-101-64 export -t single.csv -o output1.csv`
    Then the exit status should be 0
    Then a file named "output1.csv" should exist
    And the file "output1.csv" should match /^name.en,slug.en$/
    And the file "output1.csv" should match /^Some Export Category,some-export-category$/

  Scenario: Export works without template
    When I run `category-sync -p import-101-64 export -o no-template.csv`
    Then the exit status should be 0
    Then a file named "no-template.csv" should exist
    And the file "no-template.csv" should match /^id,externalId,parentId,orderHint,createdAt,lastModifiedAt,name.de,description.de,slug.de,metaTitle.de,metaDescription.de,metaKeywords.de$/

  Scenario: Use externalId for parentId during Export
    Given a file named "single.csv" with:
    """
    externalId,name.de,slug.de,parentId
    e-1,Foo,foo
    e-2,Bar,bar,e-1
    e-3,Baz,baz,e-1
    """
    When I run `category-sync -p import-101-64 import -f single.csv`
    Then the exit status should be 0
    Given a file named "externalId-parentId.csv" with:
    """
    externalId,parentId
    """
    When I run `category-sync -p import-101-64 export --parentBy externalId -t externalId-parentId.csv -o output3.csv`
    Then the exit status should be 0
    Then a file named "output3.csv" should exist
    And the file "output3.csv" should match /^externalId,parentId$/
    And the file "output3.csv" should match /^e-1,$/
    And the file "output3.csv" should match /^e-2,e-1$/
    And the file "output3.csv" should match /^e-3,e-1$/

  Scenario: Impex all possible attributes
    Given a file named "full.csv" with:
    """
    externalId,name.en,slug.en,description.en,metaTitle.en,metaDescription.en,metaKeywords.en,orderHint,parentId
    exId1,Nice Stuff,nice-stuff,It's very nice stuff - bla bla,nice stuff,SEO magic for the nice stuff,nice;stuff,0.1
    exId2,Old Stuff,old-stuff,It's pretty old stuff - foo bar,old stuff,even more SEO magic needed for old stuff,stuff;old,0.9,exId1
    """
    When I run `category-sync -p import-101-64 import -f full.csv`
    Then the exit status should be 0
    When I run `category-sync -p import-101-64 export -t full.csv -o output.csv`
    Then the exit status should be 0
    Then a file named "output.csv" should exist
    And the file "output.csv" should match /^externalId,name.en,slug.en,description.en,metaTitle.en,metaDescription.en,metaKeywords.en,orderHint,parentId$/
    And the file "output.csv" should match /^exId1,Nice Stuff,nice-stuff,It's very nice stuff - bla bla,nice stuff,SEO magic for the nice stuff,nice;stuff,0.1,$/
    And the file "output.csv" should match /^exId2,Old Stuff,old-stuff,It's pretty old stuff - foo bar,old stuff,even more SEO magic needed for old stuff,stuff;old,0.9,exId1$/

    Given a file named "template.csv" with:
    """
    externalId,id,createdAt,lastModifiedAt,parentId
    """
    When I run `category-sync -p import-101-64 --parentBy slug export -t template.csv -o output2.csv`
    Then the exit status should be 0
    Then a file named "output2.csv" should exist
    And the file "output2.csv" should match /^externalId,id,createdAt,lastModifiedAt,parentId$/
    And the file "output2.csv" should match /^exId2,[a-z,0-9,\-]{36},[0-9]{4}-[0-1][0-9]-[0-3][0-9]T[0-2][0-9]:[0-5][0-9]:[0-5][0-9].[0-9]{3}Z,[0-9]{4}-[0-1][0-9]-[0-3][0-9]T[0-2][0-9]:[0-5][0-9]:[0-5][0-9].[0-9]{3}Z,nice-stuff$/
    And the file "output2.csv" should match /^exId1,[a-z,0-9,\-]{36},[0-9]{4}-[0-1][0-9]-[0-3][0-9]T[0-2][0-9]:[0-5][0-9]:[0-5][0-9].[0-9]{3}Z,[0-9]{4}-[0-1][0-9]-[0-3][0-9]T[0-2][0-9]:[0-5][0-9]:[0-5][0-9].[0-9]{3}Z,$/
