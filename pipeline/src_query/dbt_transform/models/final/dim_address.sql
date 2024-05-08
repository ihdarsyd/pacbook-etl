with stg_dim_address as (
    select
        address_id as nk_address_id,
        street_number,
        street_name,
        city,
        country_id
    from {{ source("staging", "address") }}
),
stg_dim_country as (
    select
        country_id,
        country_name
    from {{ source("staging", "country") }}
),
join_address_country as (
    select * 
    from stg_dim_address a
    join stg_dim_country c on a.country_id = c.country_id
),
final_dim_address as (
    select
        {{ dbt_utils.generate_surrogate_key( ["nk_address_id"] ) }} as address_id,
        nk_address_id,
        street_number,
        street_name,
        city,
        country_name,
        {{ dbt_date.now() }} as created_at,
        {{ dbt_date.now() }} as updated_at
    from join_address_country
)

select * from final_dim_address