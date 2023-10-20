# Renewable Energy Integration Optimization

This repository contains a Julia code that performs optimization for integrating renewable energy sources into a grid. The optimization aims to minimize the cost of energy production while meeting the total grid demand over a specified time period.

## Problem Description

The problem involves the following data:

- `total_demand`: Total grid demand in MW over time.
- `max_wind_available`: Maximum wind energy available in MW over time.
- `wind_cost`: Cost of wind energy in $/MW over time.
- `max_solar_available`: Maximum solar energy available in MW over time.
- `solar_cost`: Cost of solar energy in $/MW over time.
- `storage_capacity`: Storage capacity in MW.
- `storage_efficiency`: Efficiency of storage.
- `storage_degradation`: Degradation factor.

## Dependencies

This code uses the following Julia packages:

- JuMP
- GLPK

## How to Use

1. Install the required packages:

   ```julia
   using Pkg
   Pkg.add("JuMP")
   Pkg.add("GLPK")
   ```

2. Run the code:

   ```julia
   include("renewable_energy_optimization.jl")
   ```

3. The optimized results will be displayed, including the energy utilization, storage charging and discharging, and stored energy.

## Optimization Details

The optimization problem is formulated as follows:

- Objective: Minimize the total cost of energy production, which includes the cost of wind and solar energy utilization, as well as storage operations.

- Decision Variables:
  - `wind_use`: Amount of wind energy used in MW over time.
  - `solar_use`: Amount of solar energy used in MW over time.
  - `storage_charge_from_wind`: Amount of energy charged to storage from wind in MW over time.
  - `storage_charge_from_solar`: Amount of energy charged to storage from solar in MW over time.
  - `storage_discharge_solar`: Amount of energy discharged from storage due to solar in MW over time.
  - `storage_discharge_wind`: Amount of energy discharged from storage due to wind in MW over time.
  - `stored_energy_from_wind`: Amount of stored energy from wind in MW over time.
  - `stored_energy_from_solar`: Amount of stored energy from solar in MW over time.

- Constraints:
  - Total energy demand must be met in each time period.
  - Storage charging and discharging operations must satisfy efficiency and degradation considerations.

## Results

The optimal solution displays the energy usage, storage operations, and stored energy for each time period.

```
Optimal solution:
Time period 1:
  Wind energy used = [Value] MW
  Solar energy used = [Value] MW
  Storage charged from wind = [Value] MW
  Storage charged from solar = [Value] MW
  Storage discharged wind = [Value] MW
  Storage discharged solar = [Value] MW
  Stored energy from wind = [Value] MW
  Stored energy from solar = [Value] MW

Time period 2:
...

...

Total cost of energy production: [Value] USD
```