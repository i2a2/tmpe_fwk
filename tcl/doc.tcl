# Project Tcl that gathers the DSP and BSP module documentation
# Author: David Andrino-Izquierdo <david.andrino@upm.es>
# Copyright: I2A2-UPM 2026
# SPDX-License-Identifier: Apache-2.0

proc init {} {
  # Include both Vitis DSP and Vivado BSP modules so their docs are gathered
  addSrcModule dsp $::fwfwk::SrcPath/dsp/tcl/main.tcl
  addSrcModule bsp $::fwfwk::SrcPath/bsp-tmpe627/tcl/main.tcl
}
