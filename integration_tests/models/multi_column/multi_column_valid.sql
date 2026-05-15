select * from (values
    (1, 10, 10, 20),
    (2, 20, 20, 30),
    (3, 30, 30, 40)
) as t(id, amount, expected_amount, max_amount)