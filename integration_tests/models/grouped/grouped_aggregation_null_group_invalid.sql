select * from (values
    ('electronics', 10),
    ('electronics', 20),
    (null, 300),
    (null, 400)
) as t(category, amount)