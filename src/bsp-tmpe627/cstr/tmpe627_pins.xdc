## Copyright (c) TEWS Technologies GmbH.
## All rights reserved.
## This Reference Design is protected by copyright laws and is provided exclusively for use with TEWS Technologies products.
## Reproduction, modification, distribution, or implementation of this Reference Design, in whole or in part, on non-TEWS products is strictly prohibited without prior written permission from TEWS Technologies GmbH.
## SPDX-License-Identifier: LicenseRef-TEWS-Reference-Design
### ############################################################################################# ##
###                                       TEWS TECHNOLOGIES                                       ##
### ############################################################################################# ##
###
###   Project Name    : TMPE627 Example
###   File Name       : tmpe627_pins.xdc
###   Target Device   : Artix-7 XC7A50T-2CSG325I
###   Design Tool     : Xilinx Vivado 2016.3
###   Simulation Tool : -
###
###   Description     : Pin and location constraint file for TMPE627 FPGA
###
###   Owner           : TEWS TECHNOLOGIES GmbH
###                     Am Bahnhof 7
###                     D-25469 Halstenbek
###
###                     Tel.: +49 / (0)4101 / 4058-0
###                     Fax.: +49 / (0)4101 / 4058-19
###                     e-mail: support@tews.com
###
###                     Copyright (c) 2018
###                     TEWS TECHNOLOGIES GmbH
###
###   History         :
###       Version   1 : (RR, 30.11.2016)
###                     Initial Version
###       Version   2 : (RR, 23.03.2018)
###                     Used "-dict { } nomenclature for "set_property"
###
###   Comments        : none
###
### ############################################################################################# ##



### ############################################################################################# ##
### PCIe
### ############################################################################################# ##

## PCIe Lanes
set_property LOC GTPE2_CHANNEL_X0Y0 [get_cells {PCIE_FW_UNIT_INST/B_XIL_PCIE_EP.I_PCIE_EP/U0/inst/gt_top_i/pipe_wrapper_i/pipe_lane[0].gt_wrapper_i/gtp_channel.gtpe2_channel_i}]
set_property LOC GTPE2_CHANNEL_X0Y0 [get_cells {tmpe_daq_i/xdma_0/inst/tmpe_daq_xdma_0_0_pcie2_to_pcie3_wrapper_i/pcie2_ip_i/U0/inst/gt_top_i/pipe_wrapper_i/pipe_lane[0].gt_wrapper_i/gtp_channel.gtpe2_channel_i}]
set_property PACKAGE_PIN E3 [get_ports PET0_N]
set_property PACKAGE_PIN E4 [get_ports PET0_P]
set_property PACKAGE_PIN H1 [get_ports {PER0_N[0]}]
set_property PACKAGE_PIN H2 [get_ports {PER0_P[0]}]

## PCIe Reference Clock
set_property PACKAGE_PIN D6 [get_ports REFCLK_P]
set_property PACKAGE_PIN D5 [get_ports REFCLK_N]

## PERST
set_property -dict {PACKAGE_PIN K1 IOSTANDARD LVCMOS33} [get_ports PERST_n]


### ############################################################################################# ##
### Front I/O
### ############################################################################################# ##

set_property -dict {PACKAGE_PIN V9 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 4} [get_ports {OE[0]}]
set_property -dict {PACKAGE_PIN K17 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 4} [get_ports {OE[1]}]
set_property -dict {PACKAGE_PIN T12 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 4} [get_ports {OE[2]}]
set_property -dict {PACKAGE_PIN M16 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 4} [get_ports {OE[3]}]
set_property -dict {PACKAGE_PIN T18 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 4} [get_ports {OE[4]}]
set_property -dict {PACKAGE_PIN N16 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 4} [get_ports {OE[5]}]
set_property -dict {PACKAGE_PIN K15 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 4} [get_ports {OE[6]}]
set_property -dict {PACKAGE_PIN M15 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 4} [get_ports {OE[7]}]
set_property -dict {PACKAGE_PIN V11 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 4} [get_ports {OE[8]}]
set_property -dict {PACKAGE_PIN N14 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 4} [get_ports {OE[9]}]
set_property -dict {PACKAGE_PIN U16 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 4} [get_ports {OE[10]}]
set_property -dict {PACKAGE_PIN V17 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 4} [get_ports {OE[11]}]
set_property -dict {PACKAGE_PIN R15 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 4} [get_ports {OE[12]}]
set_property -dict {PACKAGE_PIN V16 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 4} [get_ports {OE[13]}]

set_property -dict {PACKAGE_PIN N18 IOSTANDARD LVCMOS33} [get_ports {DI[0]}]
set_property -dict {PACKAGE_PIN U10 IOSTANDARD LVCMOS33} [get_ports {DI[1]}]
set_property -dict {PACKAGE_PIN J14 IOSTANDARD LVCMOS33} [get_ports {DI[2]}]
set_property -dict {PACKAGE_PIN N17 IOSTANDARD LVCMOS33} [get_ports {DI[3]}]
set_property -dict {PACKAGE_PIN M17 IOSTANDARD LVCMOS33} [get_ports {DI[4]}]
set_property -dict {PACKAGE_PIN U17 IOSTANDARD LVCMOS33} [get_ports {DI[5]}]
set_property -dict {PACKAGE_PIN R17 IOSTANDARD LVCMOS33} [get_ports {DI[6]}]
set_property -dict {PACKAGE_PIN P18 IOSTANDARD LVCMOS33} [get_ports {DI[7]}]
set_property -dict {PACKAGE_PIN U12 IOSTANDARD LVCMOS33} [get_ports {DI[8]}]
set_property -dict {PACKAGE_PIN T17 IOSTANDARD LVCMOS33} [get_ports {DI[9]}]
set_property -dict {PACKAGE_PIN U11 IOSTANDARD LVCMOS33} [get_ports {DI[10]}]
set_property -dict {PACKAGE_PIN U14 IOSTANDARD LVCMOS33} [get_ports {DI[11]}]
set_property -dict {PACKAGE_PIN P15 IOSTANDARD LVCMOS33} [get_ports {DI[12]}]
set_property -dict {PACKAGE_PIN U9 IOSTANDARD LVCMOS33} [get_ports {DI[13]}]

set_property -dict {PACKAGE_PIN V12 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 4} [get_ports {DOut[0]}]
set_property -dict {PACKAGE_PIN L18 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 4} [get_ports {DOut[1]}]
set_property -dict {PACKAGE_PIN T13 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 4} [get_ports {DOut[2]}]
set_property -dict {PACKAGE_PIN L14 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 4} [get_ports {DOut[3]}]
set_property -dict {PACKAGE_PIN M14 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 4} [get_ports {DOut[4]}]
set_property -dict {PACKAGE_PIN R18 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 4} [get_ports {DOut[5]}]
set_property -dict {PACKAGE_PIN P16 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 4} [get_ports {DOut[6]}]
set_property -dict {PACKAGE_PIN P14 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 4} [get_ports {DOut[7]}]
set_property -dict {PACKAGE_PIN V13 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 4} [get_ports {DOut[8]}]
set_property -dict {PACKAGE_PIN T15 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 4} [get_ports {DOut[9]}]
set_property -dict {PACKAGE_PIN R13 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 4} [get_ports {DOut[10]}]
set_property -dict {PACKAGE_PIN V14 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 4} [get_ports {DOut[11]}]
set_property -dict {PACKAGE_PIN U15 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 4} [get_ports {DOut[12]}]
set_property -dict {PACKAGE_PIN T14 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 4} [get_ports {DOut[13]}]

set_property -dict {PACKAGE_PIN R2 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 4} [get_ports {SEL[0]}]
set_property -dict {PACKAGE_PIN V8 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 4} [get_ports {SEL[1]}]


### ############################################################################################# ##
### ADC
### ############################################################################################# ##

set_property -dict {PACKAGE_PIN C12 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 4} [get_ports ADC_CNV]
set_property -dict {PACKAGE_PIN D18 IOSTANDARD LVCMOS33} [get_ports ADC_BUSY]
set_property -dict {PACKAGE_PIN B17 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 4} [get_ports ADC_PD]
set_property -dict {PACKAGE_PIN G16 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 4} [get_ports ADC_CS_n]
set_property -dict {PACKAGE_PIN B16 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 4} [get_ports ADC_LVDS_CMOS_n]
set_property -dict {PACKAGE_PIN G17 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 4} [get_ports ADC_SDI]
set_property -dict {PACKAGE_PIN A17 IOSTANDARD LVCMOS33} [get_ports ADC_SDO0]
set_property -dict {PACKAGE_PIN D13 IOSTANDARD LVCMOS33} [get_ports ADC_SDO1_SDI_P]
set_property -dict {PACKAGE_PIN C13 IOSTANDARD LVCMOS33} [get_ports ADC_SDO2_SDI_N]
set_property -dict {PACKAGE_PIN E13 IOSTANDARD LVCMOS33} [get_ports ADC_SDO3_SCKI_P]
set_property -dict {PACKAGE_PIN D14 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 4} [get_ports ADC_SCKI_SCKI_N]
set_property -dict {PACKAGE_PIN E15 IOSTANDARD LVCMOS33} [get_ports ADC_SCKO_SCKO_P]
set_property -dict {PACKAGE_PIN D15 IOSTANDARD LVCMOS33} [get_ports ADC_SDO4_SCKO_N]
set_property -dict {PACKAGE_PIN E16 IOSTANDARD LVCMOS33} [get_ports ADC_SDO5_SDO_P]
set_property -dict {PACKAGE_PIN D16 IOSTANDARD LVCMOS33} [get_ports ADC_SDO6_SDO_N]
set_property -dict {PACKAGE_PIN C18 IOSTANDARD LVCMOS33} [get_ports ADC_SDO7]
#set_property -dict {PACKAGE_PIN B11 IOSTANDARD LVCMOS33} [get_ports FF_12]
#set_property -dict {PACKAGE_PIN E17 IOSTANDARD LVCMOS33} [get_ports FF_34]


### ############################################################################################# ##
### DAC
### ############################################################################################# ##

set_property -dict {PACKAGE_PIN C11 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 4} [get_ports DAC_SDIN]
set_property -dict {PACKAGE_PIN F17 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 4} [get_ports DAC_SCLK]
set_property -dict {PACKAGE_PIN D10 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 4} [get_ports DAC_SYNC_n]
set_property -dict {PACKAGE_PIN A15 IOSTANDARD LVCMOS33} [get_ports DAC_SDO]
set_property -dict {PACKAGE_PIN G14 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 4} [get_ports DAC_LDAC_n]
set_property -dict {PACKAGE_PIN F14 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 4} [get_ports DAC_CLR_n]
set_property -dict {PACKAGE_PIN B15 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 4} [get_ports DAC_BIN2S]


### ############################################################################################# ##
### I2C Interfaces
### ############################################################################################# ##

#set_property -dict {PACKAGE_PIN R1 IOSTANDARD LVCMOS33 SLEW SLOW} [get_ports PROM_SCL]
#set_property -dict {PACKAGE_PIN T2 IOSTANDARD LVCMOS33 SLEW SLOW} [get_ports PROM_SDA]
#set_property -dict {PACKAGE_PIN H16 IOSTANDARD LVCMOS33 SLEW SLOW} [get_ports SE95_SCL]
#set_property -dict {PACKAGE_PIN F15 IOSTANDARD LVCMOS33 SLEW SLOW} [get_ports SE95_SDA]
#set_property -dict {PACKAGE_PIN H18 IOSTANDARD LVCMOS33} [get_ports SE95_OS]


### ############################################################################################# ##
### SPI Interface
### ############################################################################################# ##

## CCLK runs through STARTUPE2
##set_property PACKAGE_PIN   E8        [get_ports CCLK]

## Setting Pin locations, IOSTANDARD, and SLEW
#set_property -dict {PACKAGE_PIN L15 IOSTANDARD LVCMOS33} [get_ports SPI_CS_n]
#set_property -dict {PACKAGE_PIN K16 IOSTANDARD LVCMOS33} [get_ports SPI_DI]
#set_property -dict {PACKAGE_PIN L17 IOSTANDARD LVCMOS33} [get_ports SPI_DO]
#set_property -dict {PACKAGE_PIN J15 IOSTANDARD LVCMOS33} [get_ports SPI_WP_n]
#set_property -dict {PACKAGE_PIN J16 IOSTANDARD LVCMOS33} [get_ports SPI_HOLD_n]


### ############################################################################################# ##
### Section: Miscellaneous
### ############################################################################################# ##

## XADC inputs
#set_property -dict {PACKAGE_PIN B9 IOSTANDARD LVCMOS33} [get_ports VAUXP1]
#set_property -dict {PACKAGE_PIN A9 IOSTANDARD LVCMOS33} [get_ports VAUXN1]
#set_property -dict {PACKAGE_PIN A13 IOSTANDARD LVCMOS33} [get_ports VAUXP10]
#set_property -dict {PACKAGE_PIN A14 IOSTANDARD LVCMOS33} [get_ports VAUXN10]
#set_property -dict {PACKAGE_PIN D9 IOSTANDARD LVCMOS33} [get_ports VAUXP8]
#set_property -dict {PACKAGE_PIN C9 IOSTANDARD LVCMOS33} [get_ports VAUXN8]
#set_property -dict {PACKAGE_PIN D8 IOSTANDARD LVCMOS33} [get_ports VAUXP0]
#set_property -dict {PACKAGE_PIN C8 IOSTANDARD LVCMOS33} [get_ports VAUXN0]
#set_property -dict {PACKAGE_PIN B12 IOSTANDARD LVCMOS33} [get_ports VAUXP2]
#set_property -dict {PACKAGE_PIN A12 IOSTANDARD LVCMOS33} [get_ports VAUXN2]
#set_property -dict {PACKAGE_PIN A10 IOSTANDARD LVCMOS33} [get_ports VAUXN9]
#set_property -dict {PACKAGE_PIN B10 IOSTANDARD LVCMOS33} [get_ports VAUXP9]


# 100 MHz External Configuration Master Clock
set_property -dict {PACKAGE_PIN K18 IOSTANDARD LVCMOS33} [get_ports EMC_CLK]
# Allow connection from non-clockable pin to clock nets
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets EMC_CLK]


## LEDs
#set_property -dict {PACKAGE_PIN P1 IOSTANDARD LVCMOS33 SLEW SLOW} [get_ports LED_WWAN]
#set_property -dict {PACKAGE_PIN V3 IOSTANDARD LVCMOS33 SLEW SLOW} [get_ports LED_WPAN]
#set_property -dict {PACKAGE_PIN V2 IOSTANDARD LVCMOS33 SLEW SLOW} [get_ports LED_WLAN]


## PCIe Mini Card SMBus
set_property PROHIBIT true [get_sites M1]
set_property PROHIBIT true [get_sites N1]





