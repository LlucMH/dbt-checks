select * from (values
    ('active', 1),
    ('active', 2),
    ('inactive', 3),
    ('inactive', 4)
) as t(status, id)