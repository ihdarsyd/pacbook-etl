with stg_customer_address as (
    select
        customer_id as nk_customer_id,
        address_id as nk_address_id,
        status_id
    from {{ source("staging", "customer_address") }}
),
stg_address_status as (
    select
        status_id,
        address_status
    from {{ source("staging", "address_status") }}
),
join_address_status as (
    select * 
    from stg_customer_address a
    join stg_address_status s on a.status_id = s.status_id
),
dim_customer as (
    select *
    from {{ ref("dim_customer") }}
),
dim_address as (
    select *
    from {{ ref("dim_address") }}
),
join_stg_dim_cust_address as (
    select 
        c.customer_id,
        a.address_id,
        address_status
    from join_address_status j 
    join dim_customer c on j.nk_customer_id = c.nk_customer_id
    join dim_address a on j.nk_address_id = a.nk_address_id
),
final_bridge_cust_address as (
    select
        {{ dbt_utils.generate_surrogate_key( ["customer_id", "address_id"] ) }} as cust_address_id,
        *,
        {{ dbt_date.now() }} as created_at,
        {{ dbt_date.now() }} as updated_at
    from join_stg_dim_cust_address
)

select * from final_bridge_cust_address