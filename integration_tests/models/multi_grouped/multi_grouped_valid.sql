select * from (values
    ('ES', 'active', 100),
    ('ES', 'inactive', 120),
    ('FR', 'active', 140),
    ('FR', 'inactive', 160)
) as t(country, status, amount)