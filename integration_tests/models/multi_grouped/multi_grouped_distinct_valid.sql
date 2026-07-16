select * from (values
    ('ES', 'web', 'u1'),
    ('ES', 'web', 'u2'),
    ('ES', 'app', 'u3'),
    ('ES', 'app', 'u3'),

    ('FR', 'web', 'u4'),
    ('FR', 'web', 'u5'),
    ('FR', 'app', 'u6'),
    ('FR', 'app', 'u6')
) as t(country, channel, session_id)
