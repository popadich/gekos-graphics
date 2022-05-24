#! /usr/bin/env python3
"""meshstat.py: Scans passed 'Open File Format (OFF)' mesh file and checks its consistency."""

import sys


def main(argv):
	if len(argv) == 1:
		filename = argv[0]
		print(f"\n\nStats: {filename}")
		with open(filename) as f:
			lines = f.readlines()
			linecount = len(lines)
			print(f"line count: {linecount}")
			token = lines[0].rstrip('\n')
			if token == "OFF":
				countValuesLine = lines[1].rstrip('\n')
				countValues = countValuesLine.split(" ")
				if len(countValues) != 3:
					print("Error parsing file: count values missing")
					sys.exit(countValues)
				
				countVertices = int(countValues[0])
				countPolygons = int(countValues[1])
				countEdges = int(countValues[2])
				print(f"specified counts: {countVertices} {countPolygons} {countEdges}")
				if countEdges == 0:
					print("Error edge count missing")
			
				total_edges = 0
				total_polygons = 0
				total_vertices = 0
				max_polygon_size = 0
				meta_offset = 2
				for vertdex in range(0, countVertices):
					vertex_line = lines[vertdex + meta_offset].rstrip('\n')
					points = vertex_line.split(" ")
					if len(points) == 3:
						total_vertices += 1
				for polydex in range(0, countPolygons):
					a_poly = lines[countVertices + polydex + meta_offset].rstrip('\n')
					poly_stat = a_poly.split(" ")
					poly_size = int(poly_stat[0])
					if poly_size > max_polygon_size:
						max_polygon_size = poly_size;
					total_edges += poly_size
					total_polygons += 1
				print(f"\nactual counts: {total_vertices} {total_polygons} {total_edges}  max poly size: {max_polygon_size}")
			else:
				print("Not an OFF file")
		

if __name__ == "__main__":
	main(sys.argv[1:])