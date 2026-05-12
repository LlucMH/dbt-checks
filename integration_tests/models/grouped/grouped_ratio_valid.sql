select * from (values
    ('es', 'completed', 10),
    ('es', 'completed', 20),
    ('es', 'pending', -5),
    ('es', null, -10),

    ('fr', 'completed', 30),
    ('fr', 'completed', 40),
    ('fr', 'pending', -15),
    ('fr', null, -20)
) as t(country, status, amount)