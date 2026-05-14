select * from (values
    ('active', 1),
    ('inactive', 2),
    ('inactive', 3)
) as t(status, id)