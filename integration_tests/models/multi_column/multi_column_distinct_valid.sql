select * from (values
    (1, 2),
    (3, 4),
    (null, 1),
    (1, null)
) as t(id, amount)