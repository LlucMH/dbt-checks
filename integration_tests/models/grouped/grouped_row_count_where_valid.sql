select * from (values
    ('active', true, 1),
    ('active', true, 2),
    ('inactive', false, 3),
    ('inactive', false, 4)
) as t(status, is_active, id)