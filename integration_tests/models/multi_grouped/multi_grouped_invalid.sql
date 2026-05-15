select * from (values
    ('ES', 'active', -10),
    ('ES', 'inactive', 20),
    ('FR', 'active', 30),
    ('FR', 'inactive', 40)
) as t(country, status, amount)