#pragma once
#ifndef VEC_OPER_H
#define VEC_OPER_H



#include "config.h"
#include "random.h"
#include "timer.h"

#include <stdint.h>



enum Oper : uint8_t {
  opadd, opsub,
  opmul, opdiv,
  size
};



time_s Operation(arr_t* arr_inp1, arr_t* arr_inp2, arr_t* arr_out, const uint32_t& size, const Oper& operation);

#ifdef SERIAL

time_s Sum(arr_t* arr_inp1, arr_t* arr_inp2, arr_t* arr_out, const uint32_t& size);
time_s Sub(arr_t* arr_inp1, arr_t* arr_inp2, arr_t* arr_out, const uint32_t& size);
time_s Mul(arr_t* arr_inp1, arr_t* arr_inp2, arr_t* arr_out, const uint32_t& size);
time_s Div(arr_t* arr_inp1, arr_t* arr_inp2, arr_t* arr_out, const uint32_t& size);

#endif



#endif // !VEC_OPER_H
