using JuMP, GLPK, Random

# Create a new model
model = Model(GLPK.Optimizer)

# Define parameters
Random.seed!(123) # for reproducibility

# demand = 100 + rand([-5, 0, 5]) # Adding demand variability
demand = [95, 100, 100, 100, 100, 97, 100, 96, 99, 100, 104, 94, 100, 93, 100, 92, 100, 91, 109, 90, 100, 89, 100, 88]
max_wind_energy = 80
max_solar_energy = 70
storage_capacity = 30
storage_cost_factor = 0.5
storage_degradation_factor = 0.99 # Storage degradation factor
storage_efficiency = 0.99 # Storage efficiency

# Define time periods (e.g., hours of the day)
num_periods = 24
wind_cost = [20 + rand([-2, 0, 2]) for _ in 1:num_periods] # Wind cost for each period
solar_cost = [25 + rand([-2, 0, 2]) for _ in 1:num_periods] # Solar cost for each period

# Decision Variables
@variable(model, 0 <= wind_energy[1:num_periods] <= max_wind_energy) # Wind energy integrated
@variable(model, 0 <= solar_energy[1:num_periods] <= max_solar_energy) # Solar energy integrated
@variable(model, 0 <= stored_energy_from_wind[1:num_periods] <= storage_capacity) # Energy to store from wind for later use
@variable(model, 0 <= stored_energy_from_solar[1:num_periods] <= storage_capacity) # Energy to store from solar for later use


# New binary variable to represent day or night
@variable(model, is_day[1:num_periods], Bin)

# Ensure that is_day is 1 during hours 7 to 18, and 0 otherwise
for i in 1:num_periods
    @constraint(model, is_day[i] == (i >= 5 && i <= 19))
end

# Additional constraint to ensure solar energy is generated only during the day
for i in 1:num_periods
    @constraint(model, solar_energy[i] <= is_day[i] * max_solar_energy)
end

# Objective: Minimize cost
@objective(model, Min,
    sum(wind_cost[i]*wind_energy[i] + solar_cost[i]*solar_energy[i] +
    storage_cost_factor*(wind_cost[i]*stored_energy_from_wind[i] + solar_cost[i]*stored_energy_from_solar[i]) for i=1:num_periods))

# Constraints
# Energy balance constraint for each time period
@constraint(model, [i=1:num_periods], wind_energy[i] + solar_energy[i] +
storage_efficiency*(stored_energy_from_wind[i] + stored_energy_from_solar[i]) == demand[i])

# Storage degradation constraints for each time period
@constraint(model, [i=2:num_periods], stored_energy_from_wind[i] <=
    storage_degradation_factor * stored_energy_from_wind[i-1])
@constraint(model, [i=2:num_periods], stored_energy_from_solar[i] <=
    storage_degradation_factor * stored_energy_from_solar[i-1])

# Efficiency losses for each time period
# @constraint(model, [i=1:num_periods], stored_energy_from_wind[i] + stored_energy_from_solar[i] <=
#     storage_efficiency * (stored_energy_from_wind[i] + stored_energy_from_solar[i]))

# Storage capacity limit for each time period
@constraint(model, [i=1:num_periods], stored_energy_from_wind[i] + stored_energy_from_solar[i] <= storage_capacity)

# Solar and wind limits for each time period
@constraint(model, [i=1:num_periods], wind_energy[i] + stored_energy_from_wind[i] <= max_wind_energy)
@constraint(model, [i=1:num_periods], solar_energy[i] + stored_energy_from_solar[i] <= max_solar_energy)

# Solve the problem
optimize!(model)

# Results
println("Objective Value: ", objective_value(model))

# Print energy generation and storage for each time period
for i in 1:num_periods
    if i >= 5 && i <= 19
        println("Hour ", i, ":")
        println("Demand: ", demand_values[i])
        println("Wind Cost: ", wind_cost[i])
        println("Solar Cost: ", solar_cost[i])
        println("Wind Energy: ", value(wind_energy[i]), " MW")
        println("Solar Energy: ", value(solar_energy[i]), " MW")
        println("Stored Energy from Wind: ", value(stored_energy_from_wind[i]), " MW")
        println("Stored Energy from Solar: ", value(stored_energy_from_solar[i]), " MW")
        println("Day or Night: ", value(is_day[i]) == 1 ? "Day" : "Night", "\n")
        println("-----------------------------------------")
    else
        println("Hour ", i, ":")
        println("Demand: ", demand_values[i])
        println("Wind Cost: ", wind_cost[i])
        println("Wind Energy: ", value(wind_energy[i]), " MW")
        println("Solar Energy: ", value(solar_energy[i]), " MW")
        println("Stored Energy from Wind: ", value(stored_energy_from_wind[i]), " MW")
        println("Stored Energy from Solar: ", value(stored_energy_from_solar[i]), " MW")
        println("Day or Night: ", value(is_day[i]) == 1 ? "Day" : "Night", "\n")
        println("-----------------------------------------")
    end
end

# Store the results in a dictionary
results = Dict{String, Any}()

for i = 1:num_periods
    period_results = Dict{String, Any}()

    period_results["Wind energy used"] = value(wind_energy[i])
    period_results["Solar energy used"] = value(solar_energy[i])
    period_results["Stored energy from wind"] = value(stored_energy_from_wind[i])
    period_results["Stored energy from solar"] = value(stored_energy_from_solar[i])


    results["Time period $i"] = period_results
end

# Save the results to a JSON file
open("Model1/results.json", "w") do file
    JSON.print(file, results, 4)
end
