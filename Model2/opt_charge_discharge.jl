using JuMP
using GLPK

# Define the data
total_demand = [80, 120, 110, 105]  # Total grid demand in MW over time
max_wind_available = [40, 35, 45, 30]  # Maximum wind energy available in MW over time
wind_cost = [20, 22, 18, 25]  # Cost of wind energy in $/MW over time
max_solar_available = [50, 45, 55, 40]  # Maximum solar energy available in MW over time
solar_cost = [25, 28, 23, 30]  # Cost of solar energy in $/MW over time
storage_capacity = 50  # Storage capacity in MW
storage_efficiency = 1  # Efficiency of storage
storage_degradation = 1  # Degradation factor


# Create a JuMP model
model = Model(GLPK.Optimizer)

# Stored energy cost is half the cost of the original sources
storage_cost_from_wind = 0.5 * wind_cost
storage_cost_from_solar = 0.5 * solar_cost

# Define decision variables
@variable(model, 0 <= wind_use[t=1:4] <= max_wind_available[t])  # Amount of wind energy to use in MW over time
@variable(model, 0 <= solar_use[t=1:4] <= max_solar_available[t])  # Amount of solar energy to use in MW over time
@variable(model, 0 <= storage_charge_from_wind[t=1:4] <= storage_capacity)  # Amount of energy to charge storage from wind in MW over time
@variable(model, 0 <= storage_charge_from_solar[t=1:4] <= storage_capacity)  # Amount of energy to charge storage from solar in MW over time
@variable(model, 0 <= storage_discharge_solar[t=1:4] <= storage_capacity)  # Amount of energy to discharge storage in MW over time
@variable(model, 0 <= storage_discharge_wind[t=1:4] <= storage_capacity)
@variable(model, 0 <= stored_energy_from_wind[t=1:4] <= storage_capacity)  # Amount of stored energy from wind in MW over time
@variable(model, 0 <= stored_energy_from_solar[t=1:4] <= storage_capacity)  # Amount of stored energy from solar in MW over time

# Define objective function (minimize the cost)
@objective(model, Min, sum(wind_cost[t]* (wind_use[t] + storage_charge_from_wind[t]) + solar_cost[t]*( solar_use[t] + storage_charge_from_solar[t]) for t=1:4) + 
                      sum(storage_cost_from_wind[t] * storage_discharge_wind[t] for t=1:4) +
                      sum(storage_cost_from_solar[t] * storage_discharge_solar[t] for t=1:4))

# Define constraints
@constraint(model, [t=1:4], wind_use[t] + solar_use[t] +  storage_discharge_wind[t] + 
                           storage_discharge_solar[t] == total_demand[t])
@constraint(model, [t=2:4], stored_energy_from_wind[t] == stored_energy_from_wind[t-1]*storage_efficiency*storage_degradation + storage_charge_from_wind[t] - storage_discharge_wind[t])
@constraint(model, [t=2:4], stored_energy_from_solar[t] == stored_energy_from_solar[t-1]*storage_efficiency*storage_degradation + storage_charge_from_solar[t] - storage_discharge_solar[t])

@constraint(model, [t=1:4], wind_use[t] + storage_charge_from_wind[t] <= max_wind_available[t])
@constraint(model, [t=1:4], solar_use[t] + storage_charge_from_solar[t] <= max_solar_available[t])
# Solve the optimization problem
optimize!(model)

# Get the results
println("Optimal solution:")
for t = 1:4
    println("Time period $t:")
    println("  Wind energy used = ", value(wind_use[t]), " MW")
    println("  Solar energy used = ", value(solar_use[t]), " MW")
    println("  Storage charged from wind = ", value(storage_charge_from_wind[t]), " MW")
    println("  Storage charged from solar = ", value(storage_charge_from_solar[t]), " MW")
    println("  Storage discharged wind = ", value(storage_discharge_wind[t]), " MW")
    println("  Storage discharged solar = ", value(storage_discharge_solar[t]), " MW")
    println("  Stored energy from wind = ", value(stored_energy_from_wind[t]), " MW")
    println("  Stored energy from solar = ", value(stored_energy_from_solar[t]), " MW")
end

println("\nTotal cost of energy production: ", objective_value(model))
