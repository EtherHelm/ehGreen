# ehGreen

**格林函数计算库**，核心由 Fortran 编写，提供多种语言调用 binding。

[English](../README.md)

---

## 功能

- [x] 无限水深脉动源
- [ ] 有限水深脉动源
- [ ] 无限水深开尔文源
- [ ] 有限水深开尔文源
- [ ] 无限水深移动脉动源
- [ ] 有限水深移动脉动源

---

## 无限水深零航速脉动源

### 数学公式

关于场点 $P(x,y,z)$ 和源点 $Q(\xi,\eta,\zeta)$ 的无限水深脉动源格林函数满足自由面条件

```math
-\omega^2 G(P,Q) + g\,G_z(P,Q) = 0
```

表达式为

```math
G(P,Q) = \frac{1}{r} + \frac{1}{r_1} + 2k_0 \int_0^\infty \frac{e^{k(z+\zeta)}}{k - k_0} J_0(kR)\,dk
```

式中 $k_0 = \omega^2 / g$，$R = \sqrt{(x-\xi)^2 + (y-\eta)^2}$，$r = \sqrt{R^2 + (z-\zeta)^2}$，$r_1 = \sqrt{R^2 + (z+\zeta)^2}$。

无因次化为

```math
\begin{aligned}
G^*(P,Q) &= 2k_0 \int_0^\infty \frac{e^{k(z+\zeta)}}{k - k_0} J_0(kR)\,dk \\[2pt]
         &= k_0 F(X,Y) + 2\pi i\,k_0 e^{-Y} J_0(X)
\end{aligned}
```

其中 $X = k_0 R$，$Y = -k_0 (z+\zeta)$，

```math
F(X,Y) = 2 \int_0^\infty \frac{e^{-Yt}}{t-1} J_0(Xt)\,dt
```

偏导数

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
| 参数 | 类型 | 含义 |
| `X` | `real` | $F(X,Y)$ 中的 $X$ |
| `Y` | `real` | $F(X,Y)$ 中的 $Y$ |
| `res` | `real(4)` | 输出数组 |

| Output | |
|--------|----|
| `res` 索引 | 值 |
| `res(1)` | $F(X,Y)$ |
| `res(2)` | $2\pi e^{-Y} J_0(X)$ |
| `res(3)` | $F_X(X,Y)$ |
| `res(4)` | $-2\pi e^{-Y} J_1(X)$ |

---

## 编译与绑定

### 默认编译

```bash
git clone https://github.com/EtherHelm/ehGreen.git
cd ehGreen
make
```

| 系统 | 产物路径 | 说明 |
|------|---------|------|
| Linux | `bin/libehgreen.so` | |
| macOS | `bin/libehgreen.dylib` | |
| Windows | `bin/libehgreen.dll` | MinGW 环境下 |

中间文件（`.o`、`.mod`）位于 `build/`。

### 手动编译

#### gfortran

```bash
mkdir -p build bin
gfortran -Jbuild -fPIC -shared -o bin/libehgreen.so src/*.f90
```

#### ifx（Intel Fortran）

```bash
mkdir -p build bin
ifx -Jbuild -fPIC -shared -o bin/libehgreen.so src/*.f90
```

#### Windows（MinGW-w64 gfortran）

```bash
mkdir build bin
gfortran -Jbuild -shared -o bin/libehgreen.dll src/*.f90
```

### 绑定

支持 Python、C/C++、MATLAB，详见 [`examples/`](./examples)。

---

## 基准测试

在均匀网格（10000×1000）上对 `kernel_piz` 进行 1000 万次求值，使用 `examples/` 中的 Fortran 基准测试程序。

| 指标 | 耗时 |
|------|------|
| **单线程** | 0.41 s |
| **32 线程（OpenMP）** | 0.018 s |

**平台：** AMD EPYC 7532 32-Core Processor @ 2.40 GHz（VMware 虚拟化）  
**编译器：** gfortran 13.3.0，编译选项：`-O3 -march=native -mtune=native -funroll-loops -ffast-math -flto -fopenmp`
