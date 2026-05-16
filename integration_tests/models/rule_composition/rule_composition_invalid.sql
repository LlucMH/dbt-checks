select * from (values
    (1, -10, 100, null, null, null),
    (2, 300, 200, 'active', null, null)
) as t(
    id,
    discount_amount,
    total_amount,
    status,
    email,
    phone
)