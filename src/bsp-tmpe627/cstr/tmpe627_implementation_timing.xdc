## Copyright (c) TEWS Technologies GmbH.
## All rights reserved.
## This Reference Design is protected by copyright laws and is provided exclusively for use with TEWS Technologies products.
## Reproduction, modification, distribution, or implementation of this Reference Design, in whole or in part, on non-TEWS products is strictly prohibited without prior written permission from TEWS Technologies GmbH.
## SPDX-License-Identifier: LicenseRef-TEWS-Reference-Design
## ############################################################################################# ##
##                                       TEWS TECHNOLOGIES                                       ##
## ############################################################################################# ##
##
##   Project Name    : TMPE627 Example
##   File Name       : tmpe627_implementation_timing.xdc
##   Target Device   : Artix-7 XC7A50T-2CSG325I
##   Design Tool     : Xilinx Vivado 2016.3
##   Simulation Tool : -
##
##   Description     : Implementation timing constraint file for TMPE627 FPGA
##
##   Owner           : TEWS TECHNOLOGIES GmbH
##                     Am Bahnhof 7
##                     D-25469 Halstenbek
##
##                     Tel.: +49 / (0)4101 / 4058-0
##                     Fax.: +49 / (0)4101 / 4058-19
##                     e-mail: support@tews.com
##
##                     Copyright (c) 2017
##                     TEWS TECHNOLOGIES GmbH
##
##   History         :
##       Version   1 : (RR, 19.09.2017)
##                     Initial Version
##
##   Comments        : Set the "Used In" check marks in the Source File Properties to
##                     "Implementation" only.
##                     Using the contraints for synthesis will not result in an error, but
##                     synthesis will throw a couple of warnings because it can not find a clock.
##                     The reason for this is that the the clock used for the I/O constraining
##                     is sourced from the PCIe core, which, since it is an out-of-context module,
##                     is a black box during synthesis.
##
## ############################################################################################# ##


## ############################################################################################# ##
##  Generate a clock for the I/O Timing
## ############################################################################################# ##
# The "app_clk" used troughout the design is the same as "userclk1", which is a generated clock
# orginating from the PCIe IP-Core. The source pin is
# PCIE_FW_UNIT_INST/B_XIL_PCIE_EP.I_PCIE_EP/U0/inst/gt_top_i/pipe_wrapper_i/pipe_clock_int.pipe_clock_i/mmcm_i/CLKOUT2
# Use "report_clock" in the TCL Console to get a overview of the available clocks.
#
# "app_clk" is 62.5 MHz / 16 ns period

#create_generated_clock -name app_clk [get_pins PCIE_FW_UNIT_INST/B_XIL_PCIE_EP.I_PCIE_EP/U0/inst/gt_top_i/pipe_wrapper_i/pipe_clock_int.pipe_clock_i/mmcm_i/CLKOUT2]


## ############################################################################################# ##
##  SPI Interface I/O Constraints
## ############################################################################################# ##
# Inputs:   SPI_DO
# Outputs:  SPI_CS_n, SPI_DI
#           SPI_WP_n & SPI_HOLD_n are fixed to '1' in the SPI module and do not need to be constrained
#
# Clock to output valid     tCHQV   6 ns        SPI_DO
# Output hold time          tCHQX   1.5 ns
# Data in setup time        tDVCH   1.5 ns      SPI_DI
# Data in hold time         tCHDX   2.3 ns
# S# active hold time       tCHSH   3.375 ns    SPI_CS_n
# S# not active setup time  tSHCH   3.375 ns

#set_input_delay -clock app_clk -min -add_delay 1.500 [get_ports SPI_DO]
#set_input_delay -clock app_clk -max -add_delay 6.000 [get_ports SPI_DO]

#set_output_delay -clock app_clk -min -add_delay -3.375 [get_ports SPI_CS_n]
#set_output_delay -clock app_clk -max -add_delay 3.375 [get_ports SPI_CS_n]
#set_output_delay -clock app_clk -min -add_delay -2.300 [get_ports SPI_DI]
#set_output_delay -clock app_clk -max -add_delay 1.500 [get_ports SPI_DI]


## ############################################################################################# ##
##  Ignore Timing
## ############################################################################################# ##
# Most of the I/O signals are irrelavant to the timing analysis because they are simply
# asynchronous in- or outputs. For these signals the timing checks are disables by setting a
# false path.

# Inputs
set_false_path -from [get_ports {DI[*]}]

#set_false_path -from PROM_SDA
#set_false_path -from SE95_SDA
#set_false_path -from SE95_OS
#set_false_path -from PERST_n

## Outputs
set_false_path -to [get_ports {DOut[*]}]
set_false_path -to [get_ports {OE[*]}]
#set_false_path -to LED_WLAN
#set_false_path -to LED_WPAN
#set_false_path -to LED_WWAN
#set_false_path -to PROM_SCL
#set_false_path -to PROM_SDA
#set_false_path -to SE95_SCL
#set_false_path -to SE95_SDA
set_false_path -to SEL[*]
#set_false_path -to SPI_CS_n




