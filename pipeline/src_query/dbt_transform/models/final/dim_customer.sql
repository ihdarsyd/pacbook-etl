with stg_dim_customer as (
    select
        customer_id as nk_customer_id,
        first_name,
        last_name,
        email
    from {{ source("staging", "customer") }}
),

final_dim_customer as (
    select
        {{ dbt_utils.generate_surrogate_key( ["nk_customer_id"] ) }} as customer_id,
        *,
        {{ dbt_date.now() }} as created_at,
        {{ dbt_date.now() }} as updated_at
    from stg_dim_customer
)

select * from final_dim_customer