select * from (values
    ('active', 1),
    ('active', 2),
    ('inactive', 3)
) as t(status, id)