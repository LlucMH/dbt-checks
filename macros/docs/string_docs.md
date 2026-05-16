-- =========================
-- STRING DOCS
-- =========================

{% docs test_not_blank %}
Ensures that string values are not empty or whitespace.

### Description

Checks that non-null string values are not empty and do not consist only of spaces or whitespace characters.

NULL values are ignored.  
Use `null_ratio_below` or `null_ratio_between` to validate NULL presence explicitly.

### Arguments

- **column_name** *(string)*  
Column to evaluate.

- **where** *(string, optional)*  
Optional SQL expression used to filter rows before applying the check.

### Failure output

| failing_value | failed_check | failure_reason |
| --- | --- | --- |
| "   " | not_blank | String value must not be blank |

### Example

```yaml
tests:
  - dbt_checks.not_blank:
      arguments:
        column_name: email
```

{% enddocs %}


{% docs test_length_between %}
Ensures that string length falls within a specified range.

### Description

Checks that the length of each non-null value is between `min_length` and `max_length`.

NULL values are ignored.  
Use `null_ratio_below` or `null_ratio_between` to validate NULL presence explicitly.

### Arguments

- **column_name** *(string)*  
Column to evaluate.

- **min_length** *(integer)*  
Minimum allowed length.

- **max_length** *(integer)*  
Maximum allowed length.

- **where** *(string, optional)*  
Optional SQL expression used to filter rows before applying the check.

### Failure output

| failing_value | actual_length | expected_min_length | expected_max_length |
| --- | --- | --- | --- |
| "ABCDE" | 5 | 2 | 3 |

### Example

```yaml
tests:
  - dbt_checks.length_between:
      arguments:
        column_name: country_code
        min_length: 2
        max_length: 3
```

{% enddocs %}


{% docs test_matches_regex %}
Ensures that values match a given regular expression.

### Description

Checks that each non-null value satisfies the provided regex pattern.

NULL values are ignored.  
Use `null_ratio_below` or `null_ratio_between` to validate NULL presence explicitly.

### Arguments

- **column_name** *(string)*  
Column to evaluate.

- **pattern** *(string)*  
Regular expression pattern.

- **where** *(string, optional)*  
Optional SQL expression used to filter rows before applying the check.

### Failure output

| failing_value | failed_check | failure_reason |
| --- | --- | --- |
| "invalid-email" | matches_regex | Value must match regex pattern |

### Example

```yaml
tests:
  - dbt_checks.matches_regex:
      arguments:
        column_name: email
        pattern: "^[^@]+@[^@]+\\.[^@]+$"
```

{% enddocs %}


{% docs test_starts_with %}
Ensures that values start with a given prefix.

### Description

Checks that each non-null value begins with the specified prefix.

NULL values are ignored.  
Use `null_ratio_below` or `null_ratio_between` to validate NULL presence explicitly.

### Arguments

- **column_name** *(string)*  
Column to evaluate.

- **prefix** *(string)*  
Required prefix.

- **where** *(string, optional)*  
Optional SQL expression used to filter rows before applying the check.

### Failure output

| failing_value | expected_prefix | failed_check |
| --- | --- | --- |
| "ABC-123" | "SKU-" | starts_with |

### Example

```yaml
tests:
  - dbt_checks.starts_with:
      arguments:
        column_name: sku
        prefix: "SKU-"
```

{% enddocs %}


{% docs test_ends_with %}
Ensures that values end with a given suffix.

### Description

Checks that each non-null value ends with the specified suffix.

NULL values are ignored.  
Use `null_ratio_below` or `null_ratio_between` to validate NULL presence explicitly.

### Arguments

- **column_name** *(string)*  
Column to evaluate.

- **suffix** *(string)*  
Required suffix.

- **where** *(string, optional)*  
Optional SQL expression used to filter rows before applying the check.

### Failure output

| failing_value | expected_suffix | failed_check |
| --- | --- | --- |
| "example.org" | ".com" | ends_with |

### Example

```yaml
tests:
  - dbt_checks.ends_with:
      arguments:
        column_name: website
        suffix: ".com
```

{% enddocs %}


{% docs test_contains %}
Ensures that values contain a given substring.

### Description

Checks that each non-null value contains the specified substring.

NULL values are ignored.  
Use `null_ratio_below` or `null_ratio_between` to validate NULL presence explicitly.

### Arguments

- **column_name** *(string)*  
Column to evaluate.

- **substring** *(string)*  
Substring that must be present.

- **where** *(string, optional)*  
Optional SQL expression used to filter rows before applying the check.

### Failure output

| failing_value | expected_substring | failed_check |
| --- | --- | --- |
| "basic_plan" | "premium" | contains |

### Example

```yaml
tests:
  - dbt_checks.contains:
      arguments:
        column_name: description
        substring: "premium"
```

{% enddocs %}