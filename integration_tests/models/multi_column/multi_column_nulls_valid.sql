select * from (values
    (1, 10, 10),
    (2, null, 20),
    (3, 30, null)
) as t(id, amount, expected_amount)