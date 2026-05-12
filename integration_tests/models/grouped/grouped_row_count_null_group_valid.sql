select * from (values
    ('active', 1),
    (null, 2),
    (null, 3)
) as t(status, id)