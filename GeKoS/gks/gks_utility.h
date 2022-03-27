//
//  gks_utility.h
//  GeKoS
//
//  Created by Alex Popadich on 3/27/22.
//

#ifndef gks_utility_h
#define gks_utility_h

#include <stdio.h>
#include <stdbool.h>

#define EPSILON 0.005

bool areSame(double a, double b);

bool approximatelyEqual(float a, float b, float epsilon);
bool essentiallyEqual(float a, float b, float epsilon);
bool definitelyGreaterThan(float a, float b, float epsilon);
bool definitelyLessThan(float a, float b, float epsilon);

#endif /* gks_utility_h */
