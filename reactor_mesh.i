# Simple reactor mesh example

half_flat_to_flat = ${units 1 cm -> m} # or just 0.01
height = 1.0
n_axial_elements = 10

# block IDs
fuel_id      = 100
reflector_id = 101

# boundary IDs
bottom_id = 200
top_id    = 201
wall_id   = 202

refinement_level = 1

[Mesh]
  uniform_refine = ${refinement_level}

  [fuel_unit]
    type = SimpleHexagonGenerator
    # 'hexagon_size' is not the side length but the apothem: the apothem of a
    # regular polygon is the distance from the center to the midpoint of a side.
    hexagon_size = ${half_flat_to_flat}
    block_id = ${fuel_id}
    block_name = fuel
  []
  [reflector_unit]
    type = SimpleHexagonGenerator
    hexagon_size = ${half_flat_to_flat}
    block_id = ${reflector_id}
    block_name = reflector
  []
  [pattern]
    type = PatternedHexMeshGenerator
    inputs = 'fuel_unit reflector_unit'
    # indices correspond to position in 'inputs' parameter, starting from 0
    pattern = '0 1;
              1 1 1;
               1 1'
    pattern_boundary = none
    external_boundary_id = ${wall_id}
    external_boundary_name = wall
  []
  [extrude]
    type = AdvancedExtruderGenerator
    direction = '0 0 1'
    input = pattern
    heights = ${height}
    num_layers = ${n_axial_elements}
    bottom_boundary = ${bottom_id}
    top_boundary = ${top_id}
  []
  [rename_boundary]
    type = RenameBoundaryGenerator
    input = extrude
    old_boundary = '${bottom_id} ${top_id}'
    new_boundary = 'bottom top'
  []
[]
