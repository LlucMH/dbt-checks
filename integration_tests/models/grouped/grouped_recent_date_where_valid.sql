select * from (values
    ('ES', true, current_date),
    ('ES', true, current_date - interval '1 day'),
    ('FR', true, current_date),
    ('FR', false, current_date - interval '60 days')
) as t(country, is_active, event_date)