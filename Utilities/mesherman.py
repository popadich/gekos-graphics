#! /usr/bin/env python3

"""mesherman.py: Create 'Open File Format (OFF)' mesh files algorithmically."""


import sys
import math
import itertools


def pizza_vertex_list(slices):
	radius = 4.0
	dtheta = 360/slices;
	origin_b   = (0.0, 0.0, 0.0)
	origin_t = (0.0, 0.0, 1.0)
	# bottom
	vertex_List = [origin_b]
	for rounder in range(0, slices):
		theta = rounder * dtheta
		theta_rad = math.radians(theta)
		xo, yo, zo = origin_b
		x = xo + radius * math.cos(theta_rad)
		y = yo + radius * math.sin(theta_rad)
		z = zo
		vertex = (x,y,z)
		vertex_List.append(vertex)
	# top
	vertex_List.append(origin_t)
	for rounder in range(0, slices):
		theta = rounder * dtheta
		theta_rad = math.radians(theta)
		xo, yo, zo = origin_t
		x = xo + radius * math.cos(theta_rad)
		y = yo + radius * math.sin(theta_rad)
		z = zo
		vertex = (x,y,z)
		vertex_List.append(vertex)
	return vertex_List


def pizza_polygons(slices):
	polygonList = []
	vert_center = 0
	# bottom
	for idx in range(0, slices):
		ev = vert_center + idx
		poly = [3, vert_center, ev % slices + 1, (ev + 1) % slices + 1]
		polygonList.append(poly)
	# top
	vert_center = slices + 1
	for idx in range(0, slices):
		ev = vert_center + idx
		poly = [3, vert_center, ev % slices + 1 + slices + 1, ev + 1]
		polygonList.append(poly)
	return polygonList


def crust_polygons(slices):
	top_edges = []
	bot_edges = []
	out_edges = []
	polygon_list = []
	vert_center = 0
	for idx in range(0, slices):
		ev = vert_center + idx
		poly = [2, ev % slices + 1, (ev + 1) % slices + 1]
		top_edges.append(poly)
	vert_center = slices + 1
	for idx in range(0, slices):
		ev = vert_center + idx
		poly = [2, ev % slices + 1 + slices + 1, ev + 1]
		bot_edges.append(poly)
	for (a,b) in zip(top_edges, bot_edges):
		polygon_list.append([4,  a[1], a[2], b[1], b[2]])
	return polygon_list


def lid_polygons(slices):
	polygon_list = []
	top_edges = [slices]
	bot_edges = [slices]
	vert_center = 0
	for idx in range(0, slices):
		ev = vert_center + idx
		poly_idx = ev % slices + 1
		top_edges.append(poly_idx)
	vert_center = slices + 1
	for idx in range(0, slices):
		ev = vert_center + idx
		poly_idx = ev + 1
		bot_edges.append(poly_idx)
	polygon_list.append(top_edges)
	polygon_list.append(bot_edges)
	return polygon_list
	


def pizza_OFF(slices):
	total_vertices = 0
	total_polygons = 0
	total_edges = 0
	vl = pizza_vertex_list(slices)
	total_vertices = len(vl)
	
	zpl = pizza_polygons(slices)
	cpl = crust_polygons(slices)
	lpl = lid_polygons(slices)
	pl = cpl + lpl
	total_polygons = len(pl)
	for poly in pl:
		poly_size = poly[0]
		total_edges += poly_size
	# output file here?
	print(f"OFF")
	print(f"{total_vertices} {total_polygons} {total_edges}")
	for vert in vl:
		x,y,z = vert
		print(f"{x:.3f} {y:.3f} {z:.3f}")
	for poly in pl:
		for i, vert_idx in enumerate(poly):
			if i + 1 == len(poly):
				print(vert_idx)
			else:
				print(vert_idx, end=" ")


def main(argv):
	if len(argv) == 1:
		kind = argv[0]
		slices = 12
		if kind == 'pizza':
			pizza_OFF(slices)
		else:
			print('We only serve "pizza"')
			
			

if __name__ == "__main__":
	main(sys.argv[1:])
