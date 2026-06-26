%% Benchmark: call ehGreen Green function via shared library (libehgreen.so)
% Uses Fortran batch wrapper (kernel_piz_batch) to avoid 10M FFI crossings.
clear; clc;

lib_dir = fullfile(fileparts(mfilename('fullpath')), '..', 'bin');
h_file  = fullfile(fileparts(mfilename('fullpath')), 'benchmark_kernel_piz.h');

if ~libisloaded('libehgreen')
    loadlibrary(fullfile(lib_dir, 'libehgreen.so'), h_file, 'alias', 'libehgreen');
end

NR = 10000;
NZ = 1000;

r = double(0:NR-1) / NR * 38;
z = double(0:NZ-1) / NZ * 15;
res = zeros(NR, NZ, 4);

fprintf('[INFO] Calling kernel_piz_batch from libehgreen.so\n');

%% Single call (batch processes all 10M evaluations internally)
for epoch = 1:3
    fprintf('--- Run %d (single call, 10M evaluations) ---\n', epoch);
    t0 = tic;
    calllib('libehgreen', 'kernel_piz_batch', r, NR, z, NZ, res);
    t1 = toc(t0);
    fprintf('    Elapsed: %8.3f s\n\n', t1);
end

unloadlibrary('libehgreen');
