#pragma once
#if !defined(K_VEC_WRAP_H) && !defined(SERIAL)
#define K_VEC_WRAP_H



#include "config.h"
#include "vec_oper.h"
#include "time.h"



extern time_s Operation(uint8_t *arr_inp1, uint8_t *arr_inp2, uint8_t *arr_out, const uint32_t size, const enum Oper operation);



#endif // !K_VEC_WRAP_H
