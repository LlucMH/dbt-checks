select * from (values
    ('electronics', 10),
    ('electronics', null),
    ('electronics', 20),
    ('fashion', 30),
    ('fashion', null),
    ('fashion', 40)
) as t(category, amount)