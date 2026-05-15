select * from (values
    (1, true, 10, 10, 20),
    (2, true, 20, 20, 30),
    (3, false, 50, 999, 1)
) as t(id, is_active, amount, expected_amount, max_amount)