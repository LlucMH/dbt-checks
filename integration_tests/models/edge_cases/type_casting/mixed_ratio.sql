select * from (values
    ('1', 'active'),
    ('-1', 'inactive'),
    (null, null)
) as t(value, status)