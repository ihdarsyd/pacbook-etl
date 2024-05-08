with stg_book as (
    select
        book_id as nk_book_id,
        title,
        isbn13,
        language_id,
        num_pages,
        publication_date,
        publisher_id
    from {{ source("staging", "book") }}
),
stg_book_language as (
    select
        *
    from {{ source("staging", "book_language") }}
),
stg_publisher as (
    select
       *
    from {{ source("staging", "publisher") }}
),
stg_book_author as (
    select 
        ba.book_id,
        array_to_string(array_agg(a.author_name), ', ') as author
    from {{ source("staging", "book_author") }} ba
    join 
        {{ source("staging", "author") }} a on a.author_id = ba.author_id
    group by 
        ba.book_id
),
dim_book as (
    select 
    nk_book_id,
    title,
    isbn13,
    language_code,
    language_name,
    num_pages,
    publication_date,
    publisher_name,
    author
    from stg_book b
    join stg_book_language l on b.language_id = l.language_id
    join stg_publisher p on b.publisher_id = p.publisher_id
    join stg_book_author ba on b.nk_book_id = ba.book_id
),
final_dim_customer as (
    select
        {{ dbt_utils.generate_surrogate_key( ["nk_book_id"] ) }} as book_id,
        *,
        {{ dbt_date.now() }} as created_at,
        {{ dbt_date.now() }} as updated_at
    from dim_book
)

select * from final_dim_customer