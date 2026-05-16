select * from (values
    (1, true, 'cancelled', '2026-01-01', 'processed', true),
    (2, true, 'active', null, null, false),
    (3, false, 'cancelled', null, 'pending', true)
) as t(
    id,
    is_active,
    status,
    cancelled_at,
    refund_status,
    is_refunded
)