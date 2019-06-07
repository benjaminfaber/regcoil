LIBSTELL_DIR = mini_libstell
LIBSTELL_FOR_REGCOIL=$(LIBSTELL_DIR)/mini_libstell.a

ifneq (,$(wildcard /.dockerenv))
NETCDF_INC:=/usr/include
NETCDF_LIB:=/usr/lib
else
NETCDF_INC:=$(NETCDF_F_DIR)/include
NETCDF_LIB:=$(NETCDF_F_DIR)/lib
endif

FC = mpifort
COMPILE_FLAGS = -fopenmp -I$(NETCDF_INC) -ffree-line-length-none -cpp
EXTRA_COMPILE_FLAGS = -fopenmp -I$(NETCDF_INC) -ffree-line-length-none -O3
EXTRA_LINK_FLAGS =  -fopenmp -L$(NETCDF_LIB) -lnetcdff  -lnetcdf -lopenblas

# End of system-dependent variable assignments

TARGET = regcoil

export

.PHONY: all clean

all: $(TARGET)

include makefile.depend

%.o: %.f90 $(LIBSTELL_DIR)/mini_libstell.a
	$(FC) $(EXTRA_COMPILE_FLAGS) -I $(LIBSTELL_DIR) -c $<

%.o: %.f $(LIBSTELL_DIR)/mini_libstell.a
	$(FC) $(EXTRA_COMPILE_FLAGS) -I $(LIBSTELL_DIR) -c $<

lib$(TARGET).a: $(OBJ_FILES)
	ar rcs lib$(TARGET).a $(OBJ_FILES)

$(TARGET): lib$(TARGET).a $(TARGET).o $(LIBSTELL_FOR_REGCOIL)
	$(FC) -o $(TARGET) $(TARGET).o lib$(TARGET).a $(LIBSTELL_FOR_REGCOIL) $(EXTRA_LINK_FLAGS)

$(LIBSTELL_DIR)/mini_libstell.a:
	$(MAKE) -C mini_libstell

clean:
	rm -f *.o *.mod *.MOD *~ $(TARGET) *.a
	cd mini_libstell; rm -f *.o *.mod *.MOD *.a

test: $(TARGET)
	@echo "Beginning functional tests." && cd examples && export REGCOIL_RETEST=no && ./runExamples.py

retest: $(TARGET)
	@echo "Testing existing output files for examples without re-running then." && cd examples && export REGCOIL_RETEST=yes && ./runExamples.py

test_make:
	@echo HOSTNAME is $(HOSTNAME)
	@echo FC is $(FC)
	@echo LIBSTELL_DIR is $(LIBSTELL_DIR)
	@echo LIBSTELL_FOR_REGCOIL is $(LIBSTELL_FOR_REGCOIL)
	@echo EXTRA_COMPILE_FLAGS is $(EXTRA_COMPILE_FLAGS)
	@echo EXTRA_LINK_FLAGS is $(EXTRA_LINK_FLAGS)
