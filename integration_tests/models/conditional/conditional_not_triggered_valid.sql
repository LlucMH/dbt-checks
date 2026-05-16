select * from (values
    (1, 'active', null, null, false),
    (2, 'pending', null, null, false)
) as t(
    id,
    status,
    cancelled_at,
    refund_status,
    is_refunded
)