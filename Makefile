FC = gfortran
FFLAGS = -O2 -fPIC

test:
	bash tests/run_all_tests.sh

clean:
	rm -f src/*.o src/*.mod src/libmdqc.a tests/test_quantum_hardware

.PHONY: test clean
