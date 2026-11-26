# Project main Tcl: module registration placeholder for unconfigured builds
# Author: David Andrino-Izquierdo <david.andrino@upm.es>
# Copyright: I2A2-UPM 2026
# SPDX-License-Identifier: Apache-2.0

################################################################################
# Main tcl for project
################################################################################

# ==============================================================================
proc init {} {
  # addSrcModule bsp $::fwfwk::SrcPath/bsp_name/tcl/main.tcl
  error {No configuration specified. Use make cfg=vitis or make cfg=vivado}
}

# ==============================================================================
proc setSources {} {
}

# ==============================================================================
proc setAddressSpace {} {
}

# ==============================================================================
proc doOnCreate {} {
}

# ==============================================================================
proc doOnBuild {} {
}

# ==============================================================================
proc setSim {} {
}
