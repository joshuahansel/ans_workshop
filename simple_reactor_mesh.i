# Simple reactor mesh example

half_flat_to_flat = ${units 1 cm -> m} # or just 0.01
height = 1.0
n_axial_elements = 10

# block IDs
dummy_id     = 0
fuel_id      = 100
reflector_id = 101

# boundary IDs
bottom_id = 200
top_id    = 201

refinement_level = 1

[Mesh]
  uniform_refine = ${refinement_level}

  [dummy_unit]
    type = SimpleHexagonGenerator
    # 'hexagon_size' is not the side length but the apothem: the apothem of a
    # regular polygon is the distance from the center to the midpoint of a side.
    hexagon_size = ${half_flat_to_flat}
    block_id = ${dummy_id}
    block_name = dummy
  []
  [fuel_unit]
    type = SimpleHexagonGenerator
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
    inputs = 'fuel_unit reflector_unit dummy_unit'
    # indices correspond to position in 'inputs' parameter, starting from 0
    pattern = '2 2 2;
              2 0 1 2;
             2 1 1 1 2;
              2 1 1 2;
               2 2 2'
    pattern_boundary = none
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
  [add_wall_boundary]
    type = SideSetsBetweenSubdomainsGenerator
    input = extrude
    primary_block = '${fuel_id} ${reflector_id}'
    paired_block = '${dummy_id}'
    new_boundary = 'wall'
  []
  [rename_boundary]
    type = RenameBoundaryGenerator
    input = add_wall_boundary
    old_boundary = '${bottom_id} ${top_id}'
    new_boundary = 'bottom top'
  []
  [delete_dummy_units]
    type = BlockDeletionGenerator
    input = rename_boundary
    block = '${dummy_id}'
  []
[]
