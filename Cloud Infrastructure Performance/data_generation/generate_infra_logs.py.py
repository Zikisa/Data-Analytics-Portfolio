import pandas as pd
import numpy as np
from datetime import datetime, timedelta

# Generate Server Inventory Data
servers = [f"SRV-{i:03d}" for i in range(0, 50)]
departments = ["Production", "Staging", "Data-Team", "HR-System", "Marketing-App"]
os_types = ["Ubuntu 22.04", "RHEL 9", "Windows Server 2022"]

inventory_data = {
    "serverid": servers,
    "server_name": [f"lnx-{dep.lower()}-01" for dep in np.random.choice(departments, 50)],
    "department": np.random.choice(departments, 50),
    "os_version": np.random.choice(os_types, 50),
    "max_cpu_cores": np.random.choice([4, 8, 12, 16, 32], 50),
    "max_ram_gb": np.random.choice([16, 32, 64, 128], 50)
}
df_inventory = pd.DataFrame(inventory_data)
df_inventory.to_csv("server_inventory.csv", index = False)

#2. Generate 30 Days of Hourly Performance Logs
start_date = datetime.now() - timedelta(days = 30)
date_list = [start_date + timedelta(hours = x) for x in range(30 * 24)]

logs = []
for dt in date_list:
    for s_id in servers:
        # Simulate lower usage at night, higher during budiness hours
        is_business_hour = 8 <= dt.hour <= 18
        base_cpu = np.random.uniform(40, 85) if is_business_hour else np.random.uniform(5,25)

        # Simulate an underutilized zombie server (SRV-005)
        if s_id == "SRV-005":
            base_cpu = np.random.uniform(1, 4)

        cpu_util = min(100, max(0, base_cpu + np.random.normal(0, 5)))
        ram_util = min(100, max(0, (cpu_util * 0.9) + np.random.normal(0, 10)))

        # Base cost per hour based on imaginary cloud rates
        hourly_rate = 0.12 if "005" in s_id else 0.45

        logs.append({
            "timestamp": dt.strftime("%Y-%m-%d %H:%M:%S"),
            "server_id": s_id,
            "cpu_utilization_pct": round(cpu_util, 2),
            "ram_utilization_pct": round(ram_util, 2),
            "hourly_cost_usd": round(hourly_rate, 2)
        })

df_logs = pd.DataFrame(logs)
df_logs.to_csv("hourly_resource_logs.csv", index = False)
print("Data files generated: 'server_inventory.csv' and 'hourly_resource_logs.csv'")
