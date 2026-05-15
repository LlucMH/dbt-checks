select * from (values
    (1, 10, 10, 5),
    (2, 20, 25, 10),
    (3, 30, 30, 20)
) as t(id, amount, expected_amount, max_amount)