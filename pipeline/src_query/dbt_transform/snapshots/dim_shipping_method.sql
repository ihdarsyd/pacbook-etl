{% snapshot dim_shipping_method %}

{{
    config(
      target_database='pacbook-dwh',
      target_schema='final',
      unique_key='shipping_method_id',

      strategy='check',
      check_cols=[
			'method_name',
			'cost'
		]
    )
}}

with stg_shipping_method as (
	select 
    method_id as nk_shipping_method_id,
    method_name,
    cost
	from {{ source("pacbook-dwh", "shipping_method") }}
),
final_dim_method as (
	select
		{{ dbt_utils.generate_surrogate_key( ["nk_shipping_method_id"] ) }} as shipping_method_id, 
		* 
	from stg_shipping_method
)

select * from final_dim_method

{% endsnapshot %}