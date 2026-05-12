select * from (values
    ('es', 'completed', 10),
    ('es', 'pending', -10),
    (null, 'completed', 20),
    (null, 'pending', -20)
) as t(country, status, amount)