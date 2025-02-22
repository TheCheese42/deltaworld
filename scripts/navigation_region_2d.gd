extends NavigationRegion2D
class_name GameNavRegion

func init_nav_region() -> void:
	var nav_polygon: NavigationPolygon = NavigationPolygon.new()
	nav_polygon.agent_radius = 0.0
	var polygon: PackedVector2Array = PackedVector2Array([
		Vector2(0, 0),
		Vector2(460, 0),
		Vector2(270, 0),
		Vector2(270, 460),
		#Vector2(120, 15),
		#Vector2(360, 15),
		#Vector2(120, 255),
		#Vector2(360, 255),
	])
	var mesh: NavigationMeshSourceGeometryData2D = NavigationMeshSourceGeometryData2D.new()
	mesh.add_obstruction_outline(polygon)
	nav_polygon.clear()
	NavigationServer2D.bake_from_source_geometry_data(nav_polygon, mesh)
	navigation_polygon = nav_polygon
	bake_navigation_polygon()
