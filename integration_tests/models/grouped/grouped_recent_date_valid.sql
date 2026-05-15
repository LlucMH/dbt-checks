select * from (values
    ('ES', current_date),
    ('ES', current_date - interval '1 day'),
    ('FR', current_date),
    ('FR', current_date - interval '2 days')
) as t(country, event_date)