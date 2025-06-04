CC = gcc
CCFLAGS = -Wall -Wextra -Iinclude
NV = nvcc
NVFLAGS = -Wall -Wextra -Iinclude

SRC_DIR = src
OBJ_DIR = obj
LSF_DIR = lsf

SRC_C = $(wildcard $(SRC_DIR)/*.c)
SRC_CU = $(wildcard $(SRC_DIR)/*.cu)
OBJ = $(patsubst $(SRC_DIR)/%.c, $(OBJ_DIR)/%.o, $(SRC_C)) \
			$(patsubst $(SRC_DIR)/%.cu, $(OBJ_DIR)/%.o, $(SRC_CU))

LSF = $(wildcard $(LSF_DIR)/*.lsf)

TARGET = program

all: $(TARGET)

serial: CCFLAGS += -DSERIAL
serial: $(TARGET)
	mv $(TARGET) "$(TARGET)_serial"

parallel: $(TARGET)
	mv $(TARGET) "$(TARGET)_parallel"

$(TARGET): $(OBJ)
	$(NV) $(NVFLAGS) -o $@ $^

DEP := $(patsubst $(OBJ_DIR)/%.o, $(OBJ_DIR)/%.d, $(OBJ))
-include $(DEP)
DEPFLAGS = -MMD -MF $(@:.o=.d)

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c
	$(CC) $(CCFLAGS) -c $< -o $@ $(DEPFLAGS)

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.cu
	$(NV) $(NVFLAGS) -c $< -o $@ $(DEPFLAGS)

$(OBJ_DIR)/:
	mkdir -p $@

clean:
	rm -f $(OBJ) $(DEP)

bsubload: $(TARGET)
	for lsf_script in $(LSF) ; do \
		bsub < $$lsf_script ; \
	done

lsf:
	echo $(THREADS) $(TYPE) $(ARRAY_SIZE) $(CYCLES)
	mkdir -p lsf

	$(eval JOB_NAME := "lab3_3_$(TYPE)_$(THREADS)")
	$(eval PROJECT_NAME := "mothm_lab3_3")
	$(eval LOG_FILE := "$(JOB_NAME).log")

	echo -e "#!/bin/bash\nmkdir -p logs err\n\n#BSUB -J $(JOB_NAME)\n#BSUB -P $(PROJECT_NAME)\n#BSUB -W 08:00\n#BSUB -n $(THREADS)\n#BSUB -oo logs/$(LOG_FILE)\n#BSUB -eo err/$(LOG_FILE)\n\nexport ARRAY_SIZE=$(ARRAY_SIZE)\nexport CYCLES=$(CYCLES)\n\nmodule load mpi/openmpi-x86_64\n{ time mpiexec --use-hwthread-cpus -np $(THREADS) ./program_$(TYPE) ; } 2> logs/$(JOB_NAME).time" > "./lsf/pr$(THREADS)_$(TYPE).lsf"

	chmod +x ./lsf/pr$(THREADS)_$(TYPE).lsf

.PHONY: lsf
