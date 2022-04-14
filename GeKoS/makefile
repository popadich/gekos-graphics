#
# Makefile for
#    creating a C graphics library.
#
# Date: 04/14/22
# Author: Alex Popadich
#

CC=gcc
CFLAGS=-g -Wall
SRC=gks
OBJ=obj
SRCS=$(wildcard $(SRC)/*.c)
OBJS=$(patsubst $(SRC)/%.c, $(OBJ)/%.o, $(SRCS))

TEST=tests
TESTS=$(wildcard $(TEST)/*.c)
TESTBINS=$(patsubst $(TEST)/%.c, $(TEST)/bin/%, $(TESTS))

LIBDIR=lib
LIB = $(LIBDIR)/gks.a

all:$(LIB)

release: CFLAGS=-Wall -DNDEBUG
release: clean
release: $(LIB)

$(LIB): $(LIBDIR) $(OBJ) $(OBJS)
	$(RM) $(LIB)
	ar -cvrs $(LIB) $(OBJS)

$(OBJ)/%.o: $(SRC)/%.c $(SRC)/%.h
	$(CC) $(CFLAGS) -c $< -o $@

$(OBJ)/%.o: $(SRC)/%.c
	$(CC) $(CFLAGS) -c $< -o $@



$(TEST)/bin/%: $(TEST)/%.c 
	$(CC) $(CFLAGS) $< $(OBJS) -o $@ -lcriterion

$(TEST)/bin:
	mkdir $@


$(OBJ):
	mkdir $@

$(LIBDIR):
	mkdir $@


test: $(LIB) $(TEST)/bin $(TESTBINS)
	for test in $(TESTBINS) ; do ./$$test ; done
	

clean:
	$(RM) -r $(LIBDIR) $(OBJ)
