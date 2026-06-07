with source as (
    select * from {{ source('raw_infra', 'raw_server_inventory') }}
)

select
    cast(server_id as varchar) as server_id,
    cast(server_name as varchar) as server_name,
    cast(department as varchar) as department_name,
    cast(os_version as varchar) as operating_system,
    cast(max_cpu_cores as integer) as total_cpu_cores,
    cast(max_ram_gb as integer) as total_ram_gb
from source
