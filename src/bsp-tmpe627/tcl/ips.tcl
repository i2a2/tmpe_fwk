# Vivado Tcl that imports the HLS DSP IP and configures the BSP peripheral IPs
# Author: David Andrino-Izquierdo <david.andrino@upm.es>
# Copyright: I2A2-UPM 2026
# SPDX-License-Identifier: Apache-2.0

if { ! [ file exists $::fwfwk::HlsIpRepoPath ] } {
    ::fwfwk::printDivider
    ::fwfwk::printError "HLS project has not been generated yet. Run 'make cfg=vitis build' first"
    ::fwfwk::exit -1
}
create_ip -name hls_dsp -vendor David-Andrino -library hls -version 1.0 -module_name hls_dsp

create_ip -name fifo_generator -vendor xilinx.com -library ip -version 13.2 -module_name fifo_generator_0
set_property -dict [list \
  CONFIG.INTERFACE_TYPE {AXI_STREAM} \
  CONFIG.TDATA_NUM_BYTES {2} \
  CONFIG.TUSER_WIDTH {0} \
] [get_ips fifo_generator_0]
