# Makefile goes here
#
#
CC      =  gcc
CFLAGS  =  -g -Wall
EXEC    =  GKS.out
INCLS   =  
LIBS    =  -lm
OBJS    =  gks_3d_matrix.o gks_3d_projection.o gks_3d_world.o gks_3d_normalization.o gks_3d_view_orient.o gks_drawing_glue.o gks_3d_pipeline.o gks_mesh.o gks_3d_object_list.o gks_3d_vantage.o gks.o gks_utility.o main.o

$(EXEC): $(OBJS)
	@echo "linking ..."
	@$(CC)  $(CFLAGS)  -o $(EXEC)  $(OBJS)  $(LIBS)

$(OBJS): gks_3d_matrix.c gks_3d_projection.c gks_3d_world.c gks_3d_normalization.c gks_3d_view_orient.c gks_drawing_glue.c gks_3d_pipeline.c gks_mesh.c gks_3d_object_list.c gks_3d_vantage.c gks.c gks_utility.c main.c
	$(CC)  $(CFLAGS)  $(INCLS)  -c  $*.c

relink:
	@echo "relinking ..."
	@$(CC)  $(CFLAGS)  -o $(EXEC)  $(OBJS)  $(LIBS)

clean:
	rm gks_3d_matrix.o gks_3d_projection.o gks_3d_world.o gks_3d_normalization.o gks_3d_view_orient.o gks_drawing_glue.o gks_3d_pipeline.o gks_mesh.o gks_3d_object_list.o gks_3d_vantage.o gks.o gks_utility.o main.o GKS.out
