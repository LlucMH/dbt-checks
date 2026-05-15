select * from (values
    ('ES', 'web', current_date),
    ('ES', 'store', current_date - interval '1 day'),
    ('FR', 'web', current_date - interval '2 days'),
    ('FR', 'store', current_date - interval '3 days')
) as t(country, channel, event_date)