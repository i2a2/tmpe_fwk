# DSP module Tcl: Vitis HLS project configuration and source registration
# Author: David Andrino-Izquierdo <david.andrino@upm.es>
# Copyright: I2A2-UPM 2026
# SPDX-License-Identifier: Apache-2.0

################################################################################
# Main tcl for the module
################################################################################

# ==============================================================================

setTop  "top"
setName "hls_dsp"

proc doOnInit {} {
  puts "===== Main doOnInit ====="
  variable Top
  variable Name
  variable Part
  variable Vendor
  variable VerMajor
  variable VerMinor
  variable VerPatch

  set Part "xc7a50tcsg325-2"
  set ::fwk::Part $Part

  set Vendor "David-Andrino"
  set VerMajor 1
  set VerMinor 0
  set VerPatch 0

  # Clock period in ns. 100 MHz = 10 ns
  set ::fwk::ClockPeriod "10"
  set ::fwk::ClockUncertainty 0

  # Add soruces
  addSource [dict create File "../src/fir.h"           Type "hls" ]
  addSource [dict create File "../src/hls_dsp.cpp"     Type "hls" ]
  addSource [dict create File "../src/hls_dsp.h"       Type "hls" ]
  addSource [dict create File "../src/width_adapter.h" Type "hls" ]
}
