<!--
  TMPE-FWK project title page
  Author: David Andrino-Izquierdo <david.andrino@upm.es>
  Copyright: I2A2-UPM 2026
  SPDX-License-Identifier: Apache-2.0
-->

# FWK_TMPE

Firmware for the TEWS TECHNOLOGIES TMPE627 board (Xilinx Artix-7 XC7A50T-2CSG325I), built on the DESY FPGA Firmware Framework (`fwk`).

By default, the DSP kernels have the following assignment, but can be modified in the HLS code:

- ADC0 -> XDMA C2H
- XDMA H2C -> DAC0
- ADC1 -> FIR Filter -> DAC1
- ADC2 -> FIR Filter -> DAC2
- ADC3 -> FIR Filter -> DAC3

[1] D. Andrino-Izquierdo, A. Carpeño, M. Ruiz “Design and implementation of a signal acquisition and processing architecture over mPCIe on a Xilinx Artix 7,” Jun. 2025. [Online]. Available: https://oa.upm.es/89337/

## Build

Compile the DSP first, then the BSP. The DSP builds the HLS IP to the IP repo inside `prj` and the BSP builds the hardware interfacing logic around it.

```sh
make cfg=vitis  build
make cfg=vivado build
```
## License

Apache-2.0 for the I2A2-UPM sources, see [LICENSE](LICENSE) and [NOTICE](NOTICE).

The TEWS TECHNOLOGIES TMPE627 Reference Design files listed in [NOTICE](NOTICE)
are excluded from that grant and keep TEWS's own terms:

> Copyright (c) TEWS Technologies GmbH.
> All rights reserved.
> This Reference Design is protected by copyright laws and is provided exclusively for use with TEWS Technologies products.
> Reproduction, modification, distribution, or implementation of this Reference Design, in whole or in part, on non-TEWS products is strictly prohibited without prior written permission from TEWS Technologies GmbH.

This repository is published for academic and scientific purposes using the
TMPE627, with the permission of TEWS Technologies GmbH.

That permission is limited in scope: the TEWS files may be used and redistributed
only for academic and scientific work using a TEWS TMPE627. Commercial use, or
use of those files with other hardware, requires prior written permission from
TEWS Technologies GmbH. All other sources of this repository are Apache-2.0 and
are not subject to this limitation.

`src/bsp-tmpe627/src/tmpe_daq_wrapper.vhd` is an AMD/Xilinx
Vivado 2021.1 generated Output Product, tagged
`LicenseRef-AMD-Xilinx-Output-Products` and described in [NOTICE](NOTICE). It is
not I2A2-UPM work and carries no Apache-2.0 grant. Every other source file of
this repository, including `src/bsp-tmpe627/src/axiRegisters.vhd`, is Apache-2.0.

Contributions are accepted under Apache-2.0, except to the TEWS-licensed files
listed above, which keep their TEWS terms: see [CONTRIBUTING](CONTRIBUTING.md).
