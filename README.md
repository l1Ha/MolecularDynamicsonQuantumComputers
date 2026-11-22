# Molecular Dynamics on Quantum Computers

量子计算机上的分子反应动力学计算：**散射、解离、潘宁（Penning）电离**等量子动力学过程的量子算法实现与可行性验证。

本仓库是 [GeneralModule](https://github.com/l1Ha/QuantumGeneralModule) 中对应经典算法的量子硬件分支：以经典验证过的复势动力学/散射传播为基准，把 **Zhuang, Yang, Wang, Zhang, Zhao, *J. Phys. Chem. Lett.* 2026, 17, 9513**（DOI 10.1021/acs.jpclett.6c01867）提出的量子算法四步工作流移植到分子反应动力学场景，并逐项对表。

## 算法（论文四步工作流）

1. **态初始化**：核波函数按二进制网格编码到 $n_q$ 个坐标 qubit（$N=2^{n_q}$ 点）；
2. **分裂算符传播**：二阶 split-operator（DVR 势相位 + QFT 切到 FBR 施加对角动能相位），每步 $\Delta t$；
3. **非幺正吸收经膨胀（dilation）**：$M=e^{-\Gamma(R)\Delta t/2}$ 嵌入
   $$U_{\rm dil}|0_a\psi\rangle=|0_a\rangle(M\psi)+|1_a\rangle(\sqrt{I-M^2}\,\psi)$$
   测量 ancilla $|0\rangle_a$ 后选择 → 投影 $M\psi$，概率 $p_0=\|M\psi\|^2$；
4. **读出**：存活概率 $\prod p_0$，$P_{\rm ion}=1-\prod p_0$；或 Hadamard test 提取自相关 $C(t)=\langle\psi_0|\psi(t)\rangle$ 再做傅里叶变换得截面。

> **物理语义差别**：光解离中 CAP 是人为边界处理；**潘宁电离中 $\Gamma(R)$ 就是物理信号**——自电离宽度导致的吸收即电离事件，后选择失败率可直接读作电离率。

## 已实现（本轮）

`src/mod_quantum_hardware.f90`：态矢模拟器（无采样噪声）精确复现上述电路，内嵌迭代基-2 Cooley–Tukey FFT；H(e\*(2³S)+Ar 复光学势取自库内已验证的潘宁体系模块。

`tests/test_quantum_hardware.f90` — 4 项验收（全部通过）：

| 断言 | 结果 |
|---|---|
| 膨胀后选择恒等（$p_0$ 与 $M$ 振幅一致） | ✓ |
| $\Delta t$ 收敛（6000→12000 步 vs 96000 步参考） | 1.65e-6 → 5.51e-7（≈$\Delta t^2$） |
| 量子电路 vs 经典轨迹 $P_{\rm ion}$（0.03 eV） | **0.997 vs 1.00** |
| 资源量级 | 7 qubits + 2 ancilla（含 Hadamard 控制）、128 点网格 |

## 快速开始

```bash
bash tests/run_all_tests.sh     # 编译 + 全部验收
make test                       # 等价
```

依赖：gfortran（≥9）、bash；无外部库。

## 路线图

- **光解离**：把同一电路用于 S0 振动本征态 → 排斥态传播 + CAP 膨胀 + Hadamard test 自相关 → $\sigma_{\rm tot}(E)$（复现论文 NOCl 基准）；
- **散射**：渐近通道 + 复杂吸收势/出射边界，从 $C(t)$ 或渐近通量提取 S 矩阵与截面；
- **PIES 谱**：末态动量寄存器投影（QFT 测量）→ 电子动能分布，与经典 PIES 峰对表；
- **噪声与采样**：shots 采样 ∝$1/\sqrt{N_{\rm shots}}$、器件噪声模型（复现论文抗噪结论）；
- **多通道**：PI/AI 双通道（$V^*(R)$ 与 $V^+(R)$）分别传播，分支比由两通道后选择统计给出。

## 引用

Zikun Zhuang, Chengdong Yang, Yuchen Wang, Dong H. Zhang, Bin Zhao,
*Quantum Mechanical Studies of Photodissociation Dynamics on Quantum Computers*,
J. Phys. Chem. Lett. **2026**, 17, 9513−9522.
