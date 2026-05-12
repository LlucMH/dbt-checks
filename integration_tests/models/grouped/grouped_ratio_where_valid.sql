select * from (values
    ('es', true, 'completed', 10),
    ('es', true, 'completed', 20),
    ('es', true, 'pending', -5),
    ('es', false, null, -999),

    ('fr', true, 'completed', 30),
    ('fr', true, 'completed', 40),
    ('fr', true, 'pending', -15),
    ('fr', false, null, -999)
) as t(country, is_active, status, amount)