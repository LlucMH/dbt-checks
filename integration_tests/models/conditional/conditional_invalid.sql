select * from (values
    (1, 'cancelled', null, 'processed', true),
    (2, 'refunded', '2026-01-01', 'pending', true),
    (3, 'cancelled', null, null, false)
) as t(
    id,
    status,
    cancelled_at,
    refund_status,
    is_refunded
)