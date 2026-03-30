-- =========================
-- STRING DOCS
-- =========================

{% docs test_not_blank %}
Ensures that string values are not empty or whitespace.
### Description
Checks that non-null string values are not empty and do not consist only of spaces or whitespace characters.
### Arguments
- **column_name** *(string)*
Column to evaluate.
### Example
    tests:
        - dbt_checks.not_blank:
            column_name: email
{% enddocs %}


{% docs test_length_between %}
Ensures that string length falls within a specified range.
### Description
Checks that the length of each non-null value is between `min_length` and `max_length`.
### Arguments
- **column_name** *(string)*
Column to evaluate.
- **min_length** *(integer)*
Minimum allowed length.
- **max_length** *(integer)*
Maximum allowed length.
### Example
    tests:
        - dbt_checks.length_between:
            column_name: country_code
            min_length: 2
            max_length: 3
{% enddocs %}


{% docs test_matches_regex %}
Ensures that values match a given regular expression.
### Description
Checks that each non-null value satisfies the provided regex pattern.
### Arguments
- **column_name** *(string)*
Column to evaluate.
- **pattern** *(string)*
Regular expression pattern.
### Example
    tests:
        - dbt_checks.matches_regex:
            column_name: email
            pattern: "^[^@]+@[^@]+\\.[^@]+$"
{% enddocs %}


{% docs test_starts_with %}
Ensures that values start with a given prefix.
### Description
Checks that each non-null value begins with the specified prefix.
### Arguments
- **column_name** *(string)*
Column to evaluate.
- **prefix** *(string)*
Required prefix.
### Example
    tests:
        - dbt_checks.starts_with:
            column_name: sku
            prefix: "SKU-"
{% enddocs %}


{% docs test_ends_with %}
Ensures that values end with a given suffix.
### Description
Checks that each non-null value ends with the specified suffix.
### Arguments
- **column_name** *(string)*
Column to evaluate.
- **suffix** *(string)*
Required suffix.
### Example
    tests:
        - dbt_checks.ends_with:
            column_name: website
            suffix: ".com"
{% enddocs %}


{% docs test_contains %}
Ensures that values contain a given substring.
### Description
Checks that each non-null value contains the specified substring.
### Arguments
- **column_name** *(string)*
Column to evaluate.
- **substring** *(string)*
Substring that must be present.
### Example
    tests:
        - dbt_checks.contains:
            column_name: description
            substring: "premium"
{% enddocs %}