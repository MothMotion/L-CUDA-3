#include "config.h"
#include "random.h"
#include "timer.h"

#ifdef SERIAL
#include "vec_oper.h"
#else
#include "k_vec_oper.h"
#endif

#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>



int main() {
  time_s time_temp;
  uint32_t arr_size = ARRAY_SIZE,
           cycles   = CYCLES;

  arr_t *arr1 = malloc(arr_size * sizeof(arr_t)),
        *arr2 = malloc(arr_size * sizeof(arr_t)),
        *out  = malloc(arr_size * sizeof(arr_t));

  float avg_rand = 0;

  time_s avg_time[4];
  for(enum Oper i = opadd; i <= opdiv; ++i)
    EMPTYTIME(avg_time[i]);

  for(uint32_t i=0; i<cycles; ++i) {
    GETTIME(({
      Randomize(arr1, arr_size, MIN_RAND, MAX_RAND);
      Randomize(arr2, arr_size, MIN_RAND, MAX_RAND);
    }), time_temp.total);
    avg_rand += time_temp.total/cycles;

    #ifdef SERIAL

    time_temp = Add(arr1, arr2, out, arr_size);
    avg_sum.total += time_temp.total/cycles;
 
    time_temp = Sub(arr1, arr2, out, arr_size);
    avg_sub.total += time_temp.total/cycles;

    time_temp = Mul(arr1, arr2, out, arr_size);
    avg_mul.total += time_temp.total/cycles;

    time_temp = Div(arr1, arr2, out, arr_size);
    avg_div.total += time_temp.total/cycles;

    #else

    time_temp = Operation(arr1, arr2, out, arr_size, opadd);
    time_div(&time_temp, cycles);
    time_add(&avg_sum, &time_temp);

    time_temp = Operation(arr1, arr2, out, arr_size, opsub);
    time_div(&time_temp, cycles);
    time_add(&avg_sub, &time_temp);

    time_temp = Operation(arr1, arr2, out, arr_size, opmul);
    time_div(&time_temp, cycles);
    time_add(&avg_mul, &time_temp);

    time_temp = Operation(arr1, arr2, out, arr_size, opdiv);
    time_div(&time_temp, cycles);
    time_add(&avg_div, &time_temp);


    #endif
  }

  printf("Average time spent per cycle.\nRandomizing:\t%f", avg_rand);
  #ifdef SERIAL
  PRINTTIME()

  #else
  PRINTTIME(avg_sum, "\nSummation, total:\t%f\n", "\tCopying:\t%f\n", "\tRunning:\t%f\n", "\tReturning:\t%f\n");

  #endif

  return 0;
}
