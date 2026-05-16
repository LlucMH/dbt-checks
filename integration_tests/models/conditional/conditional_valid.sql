select * from (values
    (1, 'cancelled', '2026-01-01', 'processed', true),
    (2, 'active', null, null, false),
    (3, 'refunded', '2026-01-02', 'processed', true)
) as t(
    id,
    status,
    cancelled_at,
    refund_status,
    is_refunded
)