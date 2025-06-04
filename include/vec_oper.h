#pragma once
#ifndef VEC_OPER_H
#define VEC_OPER_H



#include "config.h"
#include "random.h"
#include "timer.h"

#include <stdint.h>

enum Oper {
  opadd=0, opsub=1,
  opmul=2, opdiv=3
};

time_s Operation(arr_t* arr1, arr_t* arr2, arr_t* out, const uint32_t, const enum Oper operation);

time_s Sum(arr_t* arr1, arr_t* arr2, arr_t* arr_out, const uint32_t size);
time_s Sub(arr_t* arr1, arr_t* arr2, arr_t* arr_out, const uint32_t size);
time_s Mul(arr_t* arr1, arr_t* arr2, arr_t* arr_out, const uint32_t size);
time_s Div(arr_t* arr1, arr_t* arr2, arr_t* arr_out, const uint32_t size);



#endif // !VEC_OPER_H
