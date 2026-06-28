"""Benchmark: call ehGreen Green function via shared library (libehgreen.so)
Uses Fortran batch wrapper (kernel_piz_batch) to avoid 10M FFI crossings."""
import ctypes
import os
import time
import numpy as np

lib_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'bin'))
lib = ctypes.cdll.LoadLibrary(os.path.join(lib_dir, 'libehgreen.so'))

_batch = lib.kernel_piz_batch
_batch.argtypes = [ctypes.c_void_p, ctypes.c_void_p,
                   ctypes.c_int, ctypes.c_void_p]
_batch.restype = None

NR = 10000
NZ = 1000

r = np.arange(NR, dtype=np.float64) / NR * 38.0
z = np.arange(NZ, dtype=np.float64) / NZ * 15.0
# Flatten to paired 1D arrays of length n = NR * NZ
rr, zz = np.meshgrid(r, z, indexing='ij')
r_flat = np.ascontiguousarray(rr.ravel(order='F'))
z_flat = np.ascontiguousarray(zz.ravel(order='F'))
n = NR * NZ
res = np.empty((4, n), dtype=np.float64, order='F')

r_ptr = r_flat.ctypes.data_as(ctypes.c_void_p)
z_ptr = z_flat.ctypes.data_as(ctypes.c_void_p)
res_ptr = res.ctypes.data_as(ctypes.c_void_p)

print("[INFO] Calling kernel_piz_batch from libehgreen.so")

for epoch in range(1, 4):
    print(f"--- Run {epoch} (single call, {n} evaluations) ---")
    t0 = time.perf_counter()
    _batch(r_ptr, z_ptr, n, res_ptr)
    t1 = time.perf_counter()
    print(f"    Elapsed: {t1 - t0:8.3f} s\n")
