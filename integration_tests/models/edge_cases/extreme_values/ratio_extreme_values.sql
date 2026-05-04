select * from (values
    (1, 'active'),
    (1, 'active'),
    (1, 'active'),
    (-1, 'inactive'),
    (0, 'pending'),
    (null, null)
) as t(value, status)