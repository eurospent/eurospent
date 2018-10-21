INSERT INTO public."gr_locations" (
  coordinate_id,
  transaction_id,
  project_name,
  beneficiary_name,
  description,
  operational_programe,
  thematical_priority,
  nr_of_subprojects,
  budget,
  contracts,
  payments,
  start_date,
  end_date,
  region,
  lau1_code,
  project_lat,
  project_long
)
WITH
base AS (
  SELECT
    d.*,
    STRING_TO_ARRAY(coordinates, ';') AS coordinates_array,
    n.region,
    n.contracts,
    n.project_status
  FROM gr_projects_detailed AS d
  INNER JOIN gr_projects_lists_nuts2 AS n ON d.transaction_id = n.transaction_id
  WHERE d.start_date >= '2007-01-01'
    AND d.start_date < '2015-01-01'
    AND n.project_status = '4'
),

base_unnested As (
  SELECT
    *, 
    UNNEST(CASE WHEN "coordinates_array" <> '{}' THEN "coordinates_array" ELSE '{null}' END) AS single_coords
  FROM base
),

base_lat_long AS (
  SELECT
    *,
    md5(CONCAT('EL',ROW_NUMBER() OVER()::text)) AS coordinate_id,
    COALESCE(SPLIT_PART(single_coords,',',1)::float,NULL) AS project_lat,
    COALESCE(SPLIT_PART(single_coords,',',2)::float,NULL) AS project_long
  FROM base_unnested
)

SELECT
  coordinate_id,
  transaction_id,
  project_title AS project_name,
  beneficiary As beneficiary_name,
  description,
  operational_programe,
  thematical_priority,
  nr_of_subprojects,
  budget,
  contracts,
  payments,
  start_date,
  end_date,
  region,
  NULL::text AS lau1_code,
  project_lat,
  project_long
FROM base_lat_long;