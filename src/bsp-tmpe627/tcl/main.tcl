# BSP module Tcl: part and top settings, source and IP registration
# Author: David Andrino-Izquierdo <david.andrino@upm.es>
# Copyright: I2A2-UPM 2026
# SPDX-License-Identifier: Apache-2.0

################################################################################
# Main tcl for the module
################################################################################

setConfig PART "xc7a50tcsg325-2"
setConfig TOP "tmpe_daq_wrapper"

proc doOnInit {} {
  puts "===== Main doOnInit ====="
  setTop [getConfig TOP]

  addSource [dict create File "../src/ADC/adc.vhd"                        Type "vhdl" ]
  addSource [dict create File "../src/ADC/adc_channel.vhd"                Type "vhdl" ]
  addSource [dict create File "../src/DAC/ad5754r.vhd"                    Type "vhdl" ]
  addSource [dict create File "../src/DAC/dac.vhd"                        Type "vhdl" ]
  addSource [dict create File "../src/DAC/pulse_stretcher.vhd"            Type "vhdl" ]
  addSource [dict create File "../src/axiRegisters.vhd"                   Type "vhdl" ]
  addSource [dict create File "../src/clock_buffer.vhd"                   Type "vhdl" ]
  addSource [dict create File "../src/dsp.vhd"                            Type "vhdl" ]
  addSource [dict create File "../src/fgen.vhd"                           Type "vhdl" ]
  addSource [dict create File "../src/reset_generator.vhd"                Type "vhdl" ]
  addSource [dict create File "../src/tmpe_daq_wrapper.vhd"               Type "vhdl" ]

  addSource [dict create File "../cstr/tmpe62x_config.xdc"                Type "xdc"  ]
  addSource [dict create File "../cstr/tmpe627_implementation_timing.xdc" Type "xdc"  ]
  addSource [dict create File "../cstr/tmpe627_pins.xdc"                  Type "xdc"  ]
  addSource [dict create File "../cstr/tmpe627_timing.xdc"                Type "xdc"  ]

  addAddressSpace [dict create Id "bsp_tmpe627" Type rdl Address 0x00000000 File ../rdl/bsp_tmpe627.rdl]
}


proc doOnCreate {} {
  set_property "part" [getConfig PART] [current_project]
  set_property top [getConfig TOP] [current_fileset]

  addIPs
}

proc doPostCreate {} {
  source bd.tcl
}

proc addIPs {} {
  if { ! [ file exists $::fwk::HlsIpRepoPath ] } {
      ::fwk::printDivider
      ::fwk::printError "HLS project has not been generated yet. Run 'make cfg=vitis build' first"
      ::fwk::exit -1
  }
  create_ip -name hls_dsp -vendor David-Andrino -library hls -version 1.0 -module_name hls_dsp

  create_ip -name fifo_generator -vendor xilinx.com -library ip -version 13.2 -module_name fifo_generator_0
  set_property -dict [list \
    CONFIG.INTERFACE_TYPE {AXI_STREAM} \
    CONFIG.TDATA_NUM_BYTES {2} \
    CONFIG.TUSER_WIDTH {0} \
  ] [get_ips fifo_generator_0]
}
