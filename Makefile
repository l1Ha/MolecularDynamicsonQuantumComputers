FC = gfortran
FFLAGS = -O2 -fPIC

test:
	bash tests/run_all_tests.sh

# GPU (OpenACC) 构建: 同一份源码, 热循环经 !$acc 卸载到加速器;
# 无 GPU 时由 OpenACC 运行时回退到主机执行 (结果与 CPU 路径一致)
gpu:
	FFLAGS="-O3 -fopenacc" bash tests/run_all_tests.sh

clean:
	rm -f src/*.o src/*.mod src/libmdqc.a tests/test_quantum_hardware

.PHONY: test gpu clean
