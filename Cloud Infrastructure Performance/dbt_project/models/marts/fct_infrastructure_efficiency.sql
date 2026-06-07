with servers as (
    select * from {{ ref('stg_servers') }}
),

logs as (
    select * from {{ ref('stg_hourly_logs') }}
),

aggregated_logs as (
    select
        server_id,
        date(log_timestamp) as log_date,
        avg(cpu_utilization_pct) as avg_daily_cpu,
        avg(ram_utilization_pct) as avg_daily_ram,
        sum(hourly_cost_usd) as total_daily_cost
    from logs
    group by 1, 2
)

select
    al.log_date,
    al.server_id,
    s.server_name,
    s.department_name,
    s.operating_system,
    al.avg_daily_cpu,
    al.avg_daily_ram,
    al.total_daily_cost,
    -- Business logic to identify wasted resources
    case 
        when al.avg_daily_cpu < 5.0 then 'Zombie Server (Underutilized)'
        when al.avg_daily_cpu > 85.0 then 'Overloaded Over-provision'
        else 'Optimized'
    end as efficiency_status,
    -- Calculate explicit money wasted if it is a zombie server
    case 
        when al.avg_daily_cpu < 5.0 then al.total_daily_cost
        else 0.0
    end as wasted_spend_usd
from aggregated_logs al
left join servers s on al.server_id = s.server_id
