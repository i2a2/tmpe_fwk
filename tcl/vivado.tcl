# Project Tcl that registers the BSP module for the Vivado build
# Author: David Andrino-Izquierdo <david.andrino@upm.es>
# Copyright: I2A2-UPM 2026
# SPDX-License-Identifier: Apache-2.0

proc doOnInit {} {
  set ::fwk::addr::TypesToGen {vhdl h map}
  set ::fwk::addr::TypesToAdd {vhdl}

  addModule [dict create InstanceName bsp File $::fwk::SrcPath/bsp-tmpe627/tcl/main.tcl]
  addAddressSpace [dict create \
    Type module \
    Id bsp \
    Name bsp \
    Parent "" \
    Address 0x00000000 \
    Size 64 \
    Channel 0 \
    ChannelSel 0
  ]
}
