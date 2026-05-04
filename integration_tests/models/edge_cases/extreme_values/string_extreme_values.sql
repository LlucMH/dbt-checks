select * from (values
    (''),
    ('   '),
    ('a'),
    ('abc'),
    ('ABC'),
    ('abc-123'),
    ('very_long_string_value'),
    (null)
) as t(value)