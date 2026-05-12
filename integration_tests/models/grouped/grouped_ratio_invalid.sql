select * from (values
    ('es', 'completed', 10),
    ('es', 'completed', 20),
    ('es', 'completed', 30),
    ('es', null, 40),

    ('fr', 'pending', -10),
    ('fr', null, -20),
    ('fr', null, -30),
    ('fr', null, -40)
) as t(country, status, amount)