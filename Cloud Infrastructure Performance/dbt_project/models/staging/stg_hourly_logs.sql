with source as (
    select * from {{ source('raw_infra', 'raw_hourly_resource_logs') }}
)

select
    cast(timestamp as timestamp) as log_timestamp,
    cast(server_id as varchar) as server_id,
    cast(cpu_utilization_pct as float) as cpu_utilization_pct,
    cast(ram_utilization_pct as float) as ram_utilization_pct,
    cast(hourly_cost_usd as float) as hourly_cost_usd
from source
