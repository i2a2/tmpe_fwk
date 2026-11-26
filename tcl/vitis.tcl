# Project Tcl that registers the DSP module for the Vitis HLS build
# Author: David Andrino-Izquierdo <david.andrino@upm.es>
# Copyright: I2A2-UPM 2026
# SPDX-License-Identifier: Apache-2.0

proc doOnInit {} {
  addModule [dict create InstanceName dsp File $::fwk::SrcPath/dsp/tcl/main.tcl]

  setTop [dsp::getTop]
}
