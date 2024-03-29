# 2D transient heat conduction problem:
#   - Domain: (0, 1 m) X (0, 0.2 m) (assume depth = 0.1 m)
#   - BCs: with a 2D rectangular domain with the following BCs:
#     - left:   Insulated: q = 0
#     - right:  Insulated: q = 0
#     - top:    Convection: q = htc * (T_inf - T), htc = 100 W/(m^2-K), T_inf(x) = 300 + 50x
#     - bottom: Insulated, q = 0
#   - Source: 1 kW, uniform
#
# Start with random IC and run until steady.
#
# Objectives:
#   - Verify conservation of energy at steady-state
#   - Check maximum and minimum temperatures at the steady-state
#   - Get the final temperature distribution along the top

length_x = 1.0
length_y = 0.2
depth = 0.1
volume = ${fparse length_x * length_y * depth}

nx = 100
ny = 20

T_ic_min = 500
T_ic_max = 700

htc = 100
T_inf_left = 300
T_inf_coef = 50

source_power = 1e3
source_power_density = ${fparse source_power / volume}

[Mesh]
  type = GeneratedMesh
  dim = 2
  xmin = 0
  ymin = 0
  xmax = ${length_x}
  ymax = ${length_y}
  nx = ${nx}
  ny = ${ny}
[]

[Variables]
  [T]
  []
[]

[ICs]
  [T_ic]
    type = RandomIC
    variable = T
    min = ${T_ic_min}
    max = ${T_ic_max}
  []
[]

[SolidProperties]
  [sp_ss316]
    type = ThermalSS316Properties
  []
[]

[Materials]
  [mat]
    type = ADThermalSolidPropertiesMaterial
    temperature = T
    density = rho
    specific_heat = cp
    thermal_conductivity = k
    sp = sp_ss316
  []
[]

[Kernels]
  [time_derivative]
    type = ADHeatConductionTimeDerivative
    variable = T
    density_name = rho
    specific_heat = cp
  []
  [diffusion]
    type = Diffusion
    variable = T
  []
  [heat_source]
    type = BodyForce
    variable = T
    value = ${source_power_density}
  []
[]

[Functions]
  [T_inf_fn]
    type = ParsedFunction
    expression = '${T_inf_left} + ${T_inf_coef}*x'
  []
[]

[AuxVariables]
  [T_inf]
  []
[]

[AuxKernels]
  [T_inf_ak]
    type = FunctionAux
    variable = T_inf
    function = T_inf_fn
    execute_on = 'INITIAL'
  []
[]

[FunctorMaterials]
  [q_conv_mat]
    type = ADParsedFunctorMaterial
    property_name = q_conv
    functor_names = 'T_inf T'
    expression = '${htc} * (T_inf - T)'
  []
[]

[BCs]
  [top_bc]
    type = FunctorNeumannBC
    variable = T
    boundary = top
    functor = q_conv
  []
[]

[Postprocessors]
  [T_min]
    type = ElementExtremeValue
    variable = T
    value_type = min
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [T_max]
    type = ElementExtremeValue
    variable = T
    value_type = max
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [heat_loss]
    type = ADSideIntegralFunctorPostprocessor
    boundary = top
    functor = q_conv
    functor_argument = qp
    prefactor = ${depth} # Recall that in 2D, the "side" is 1D; still need to integrate over depth
    execute_on = 'INITIAL TIMESTEP_END'
  []
[]

[VectorPostprocessors]
  [top_vpp]
    type = SideValueSampler
    variable = T
    boundary = top
    sort_by = x
    execute_on = 'FINAL'
  []
[]

[Executioner]
  type = Transient
  scheme = implicit-euler
  end_time = 1e8 # some time longer than it takes to achieve steady-state
  dt = 1000
  steady_state_detection = true
  steady_state_tolerance = 1e-7

  solve_type = NEWTON

  nl_max_its = 10
  nl_abs_tol = 1e-8
  nl_rel_tol = 1e-8

  l_max_its = 10
  l_tol = 1e-3
[]

[Outputs]
  exodus = true

  # Could do 'csv = true', but we don't want to output a CSV file every time step for
  # the VPP; therefore we must customize the output.
  # This one is for the PPs:
  [csv_pp]
    type = CSV
    file_base = 'heat_conduction'
    execute_vector_postprocessors_on = 'NONE' # disable VPP output, leaving only PPs.
  []
  # This one is for the VPPs:
  [csv_vpp]
    type = CSV
    file_base = 'out'
    execute_postprocessors_on = 'NONE' # disable PP output, leaving only VPP.
  []
[]
