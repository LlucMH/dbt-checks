select * from (values
    (1, 10, 100, 'active', 'a@test.com', null),
    (2, 20, 200, 'active', null, '123456')
) as t(
    id,
    discount_amount,
    total_amount,
    status,
    email,
    phone
)