select * from (values
    ('electronics', true, 10),
    ('electronics', true, 20),
    ('fashion', true, 30),
    ('fashion', true, 40)
) as t(category, is_active, amount)