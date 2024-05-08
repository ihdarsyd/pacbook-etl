with  stg_cust_order as (
    select
        *
    from {{ source("staging", "cust_order") }}
),
stg_order_line as (
    select
        *
    from {{ source("staging", "order_line") }}
    order by order_id
),
stg_order_history as (
    select
        *
    from {{ source("staging", "order_history") }}
    order by order_id, status_date
),
stg_order_status as (
    select
        *
    from {{ source("staging", "order_status") }}
),
dim_customer as (
    select * 
    from {{ref("dim_customer")}}
),
dim_address as (
    select * 
    from {{ref("dim_address")}}
),
dim_book as (
    select * 
    from {{ref("dim_book")}}
),
dim_shipping_method as (
    select * 
    from {{ref("dim_shipping_method")}}
),
dim_date as (
    select * 
    from {{ref("dim_date")}}
),
dim_time as (
    select * 
    from {{ref("dim_time")}}
),
fct_order_book as (
    select
        co.order_id as nk_order_id,
        dc.customer_id as customer_id,
        db.book_id as book_id,
        ol.price,
        dsm.shipping_method_id as shipping_method_id,
        da.address_id as dest_address_id,
        dd1.date_id as order_date,
        dt1.time_id as order_time,
        os.status_value,
        dd2.date_id as status_date,
        dt2.time_id as status_time
    from stg_cust_order co
    join stg_order_line ol 
        on co.order_id = ol.order_id
    join stg_order_history oh 
        on co.order_id = oh.order_id
    join stg_order_status os 
        on oh.status_id = os.status_id
    join dim_customer dc
        on co.customer_id = dc.nk_customer_id
    join dim_address da 
        on co.dest_address_id = da.nk_address_id
    join dim_shipping_method dsm 
        on co.shipping_method_id = dsm.nk_shipping_method_id 
    join dim_book db 
        on ol.book_id = db.nk_book_id
    join dim_date dd1
        on DATE(co.order_date) = dd1.date_actual
    join dim_time dt1
        on TO_CHAR(DATE_TRUNC('second', co.order_date), 'HH24:MI:SS')= (dt1.time_actual::time)::text
    join dim_date dd2
        on DATE(oh.status_date) = dd2.date_actual
    join dim_time dt2
        on TO_CHAR(DATE_TRUNC('second', oh.status_date), 'HH24:MI:SS') = (dt2.time_actual::time)::text
),
final_fct_order_book as (
    select
        {{ dbt_utils.generate_surrogate_key( ["nk_order_id","book_id","status_value","price"] ) }} as order_id,
        *,
        {{ dbt_date.now() }} as created_at,
        {{ dbt_date.now() }} as updated_at
    from fct_order_book
)

select * from final_fct_order_book