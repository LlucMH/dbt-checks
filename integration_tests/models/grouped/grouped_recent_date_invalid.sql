select * from (values
    ('ES', current_date),
    ('ES', current_date - interval '1 day'),
    ('FR', current_date - interval '30 days'),
    ('FR', current_date - interval '40 days')
) as t(country, event_date)