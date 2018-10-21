SELECT
    beneficiary_id,
    query_country_code,
    query_country,
    query_type,
    query_state,
    query_region,
    query_county,
    query_city,
    query_postal_code,
    query_address,
    result_country,
    result_region,
    result_county,
    result_city,
    result_postal_code,
    result_street,
    result_number,
    result_full_address,
    result_lat,
    result_long,
    geocoded,
    lau
FROM geocode
WHERE query_country = 'Cyprus'
AND geocoded IS TRUE;