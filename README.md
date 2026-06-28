# ehGreen

**Green's function library**, core written in Fortran with multi-language bindings.

[中文](docs/README.zh.md)

---

## Features

- [x] Infinite depth pulsating source
- [ ] Finite depth pulsating source
- [ ] Infinite depth Kelvin source
- [ ] Finite depth Kelvin source
- [ ] Infinite depth translating-pulsating source
- [ ] Finite depth translating-pulsating source

---

## Infinite Depth Zero-Speed Pulsating Source

### Mathematical Formulation

For field point $P(x,y,z)$ and source point $Q(\xi,\eta,\zeta)$, the infinite depth pulsating source Green's function satisfies the free-surface condition

```math
-\omega^2 G(P,Q) + g\,G_z(P,Q) = 0
```

The expression is

```math
G(P,Q) = \frac{1}{r} + \frac{1}{r_1} + 2k_0 \int_0^\infty \frac{e^{k(z+\zeta)}}{k - k_0} J_0(kR)\,dk
```

where $k_0 = \omega^2 / g$, $R = \sqrt{(x-\xi)^2 + (y-\eta)^2}$, $r = \sqrt{R^2 + (z-\zeta)^2}$, $r_1 = \sqrt{R^2 + (z+\zeta)^2}$.

Non-dimensionalized as

```math
\begin{aligned}
G^*(P,Q) &= 2k_0 \int_0^\infty \frac{e^{k(z+\zeta)}}{k - k_0} J_0(kR)\,dk \\[2pt]
         &= k_0 F(X,Y) + 2\pi i\,k_0 e^{-Y} J_0(X)
\end{aligned}
```

with $X = k_0 R$, $Y = -k_0 (z+\zeta)$,

```math
F(X,Y) = 2 \int_0^\infty \frac{e^{-Yt}}{t-1} J_0(Xt)\,dt
```

Partial derivatives

```math
\begin{aligned}
G^*_x &= k_0^2 \frac{x-\xi}{R} \bigl(F_X(X,Y) - 2\pi i\,e^{-Y} J_1(X)\bigr) \\[2pt]
G^*_y &= k_0^2 \frac{y-\eta}{R} \bigl(F_X(X,Y) - 2\pi i\,e^{-Y} J_1(X)\bigr) \\[2pt]
G^*_z &= \frac{2k_0^2}{\sqrt{X^2 + Y^2}} + k_0 G^*
\end{aligned}
```

### API

#### `kernel_piz(X, Y, res)`

| Input | | |
|-------|----|----|
| Parameter | Type | Description |
| `X` | `real` | $X$ in $F(X,Y)$ |
| `Y` | `real` | $Y$ in $F(X,Y)$ |
| `res` | `real(4)` | Output array |

| Output | |
|--------|----|
| `res` index | Value |
| `res(1)` | $F(X,Y)$ |
| `res(2)` | $2\pi e^{-Y} J_0(X)$ |
| `res(3)` | $F_X(X,Y)$ |
| `res(4)` | $-2\pi e^{-Y} J_1(X)$ |

---

## Building & Binding

### Default Build

```bash
git clone https://github.com/EtherHelm/ehGreen.git
cd ehGreen
make
```

| System | Output | Notes |
|--------|--------|-------|
| Linux | `bin/libehgreen.so` | |
| macOS | `bin/libehgreen.dylib` | |
| Windows | `bin/libehgreen.dll` | MinGW environment |

Intermediate files (`.o`, `.mod`) go to `build/`.

### Manual Build

#### gfortran

```bash
mkdir -p build bin
gfortran -Jbuild -fPIC -shared -o bin/libehgreen.so src/*.f90
```

#### ifx (Intel Fortran)

```bash
mkdir -p build bin
ifx -Jbuild -fPIC -shared -o bin/libehgreen.so src/*.f90
```

#### Windows (MinGW-w64 gfortran)

```bash
mkdir build bin
gfortran -Jbuild -shared -o bin/libehgreen.dll src/*.f90
```

### Bindings

Python, C/C++, MATLAB bindings available — see [`examples/`](./examples).

---

## Benchmark

10 million calls to `kernel_piz` via ISO_C_BINDING from `libehgreen.so`, measured with the Fortran benchmark in `examples/`. Each metric takes the minimum over three runs.

| Metric | Platform 1 | Platform 2 |
|--------|-----------|-----------|
| **Single thread** | 0.41 s | 0.141 s |
| **OpenMP multi-thread** | 0.018 s | 0.018 s |

**Platform 1:** AMD EPYC 7532 32-Core Processor @ 2.40 GHz (VMware virtualized)  
**Platform 2:** AMD Ryzen 7 9700X 8-Core Processor @ 3.81 GHz (VM)  
**Compiler:** gfortran 13.3.0, flags: `-O3 -march=native -mtune=native -funroll-loops -ffast-math -flto -fopenmp`
