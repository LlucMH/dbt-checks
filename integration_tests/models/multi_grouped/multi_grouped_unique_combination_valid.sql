select * from (values
    ('ES', 'web', 1, 100),
    ('ES', 'web', 2, 100),
    ('ES', 'web', 3, 100),
    ('ES', 'web', 3, 100),

    ('ES', 'app', 4, 100),
    ('ES', 'app', 5, 100),
    ('ES', 'app', 6, 100),
    ('ES', 'app', 6, 100),

    ('FR', 'web', 7, 100),
    ('FR', 'web', 8, 100),
    ('FR', 'web', 9, 100),
    ('FR', 'web', 9, 100),

    ('FR', 'app', 10, 100),
    ('FR', 'app', 11, 100),
    ('FR', 'app', 12, 100),
    ('FR', 'app', 12, 100)
) as t(country, channel, order_id, line_no)
