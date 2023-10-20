import pulp

# Define the data
total_demand = [80, 120, 110, 105]
max_wind_available = [40, 35, 45, 30]
wind_cost = [20, 22, 18, 25]
max_solar_available = [50, 45, 55, 40]
solar_cost = [25, 28, 23, 30]
storage_capacity = 50
storage_efficiency = 1
storage_degradation = 1

# Create a linear programming problem
model = pulp.LpProblem("Energy_Optimization", pulp.LpMinimize)

# Define decision variables
time_periods = range(4)
wind_use = pulp.LpVariable.dicts("Wind_Use", time_periods, 0, None)
solar_use = pulp.LpVariable.dicts("Solar_Use", time_periods, 0, None)
storage_charge_from_wind = pulp.LpVariable.dicts("Storage_Charge_From_Wind", time_periods, 0, storage_capacity)
storage_charge_from_solar = pulp.LpVariable.dicts("Storage_Charge_From_Solar", time_periods, 0, storage_capacity)
storage_discharge_wind = pulp.LpVariable.dicts("Storage_Discharge_Wind", time_periods, 0, None)
storage_discharge_solar = pulp.LpVariable.dicts("Storage_Discharge_Solar", time_periods, 0, None)
stored_energy_from_wind = pulp.LpVariable.dicts("Stored_Energy_From_Wind", time_periods, 0, storage_capacity)
stored_energy_from_solar = pulp.LpVariable.dicts("Stored_Energy_From_Solar", time_periods, 0, storage_capacity)

# Define objective function
model += (
    pulp.lpSum(wind_cost[t] * (wind_use[t] + storage_charge_from_wind[t]) + 
               solar_cost[t] * (solar_use[t] + storage_charge_from_solar[t]) +
               0.5 * wind_cost[t] * storage_discharge_wind[t] +
               0.5 * solar_cost[t] * storage_discharge_solar[t]
               for t in time_periods)
)

# Define constraints
for t in time_periods:
    model += wind_use[t] + solar_use[t] + storage_discharge_wind[t] + storage_discharge_solar[t] == total_demand[t]
    if t > 0:
        model += stored_energy_from_wind[t] == (stored_energy_from_wind[t-1] * storage_efficiency * storage_degradation +
                                               storage_charge_from_wind[t] - storage_discharge_wind[t])
        model += stored_energy_from_solar[t] == (stored_energy_from_solar[t-1] * storage_efficiency * storage_degradation +
                                                 storage_charge_from_solar[t] - storage_discharge_solar[t])
    model += wind_use[t] + storage_charge_from_wind[t] <= max_wind_available[t]
    model += solar_use[t] + storage_charge_from_solar[t] <= max_solar_available[t]

# Solve the optimization problem
model.solve()

# Get the results
print("Optimal solution:")
for t in time_periods:
    print(f"Time period {t+1}:")
    print(f"  Wind energy used = {wind_use[t].value()} MW")
    print(f"  Solar energy used = {solar_use[t].value()} MW")
    print(f"  Storage charged from wind = {storage_charge_from_wind[t].value()} MW")
    print(f"  Storage charged from solar = {storage_charge_from_solar[t].value()} MW")
    print(f"  Storage discharged wind = {storage_discharge_wind[t].value()} MW")
    print(f"  Storage discharged solar = {storage_discharge_solar[t].value()} MW")
    print(f"  Stored energy from wind = {stored_energy_from_wind[t].value()} MW")
    print(f"  Stored energy from solar = {stored_energy_from_solar[t].value()} MW")

print(f"\nTotal cost of energy production: {pulp.value(model.objective)}")
