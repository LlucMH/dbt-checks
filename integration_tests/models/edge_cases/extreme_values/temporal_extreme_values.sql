select * from (values
    (cast('1900-01-01' as date)),
    (cast('2024-01-01' as date)),
    (cast('2099-12-31' as date)),
    (null)
) as t(date)