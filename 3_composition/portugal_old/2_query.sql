SELECT
    id AS query_id,
    beneficiary_id,
    query_country_code,
    query_country,
    query_type,
    query_state,
    query_region,
    query_county,
    query_city,
    query_postal_code,
    query_address
FROM beneficiary_geocode
WHERE query_country = 'Portugal'
AND geocoded IS FALSE;