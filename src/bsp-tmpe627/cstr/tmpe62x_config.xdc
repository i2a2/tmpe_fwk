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
##   File Name       : tmpe62x_config.xdc
##   Target Device   : Artix-7 XC7A50T-2CSG325I
##   Design Tool     : Xilinx Vivado 2016.3
##   Simulation Tool :
##
##   Description     : Configuration constraint file for TMPE627 FPGA
##
##   Owner           : TEWS TECHNOLOGIES GmbH
##                     Am Bahnhof 7
##                     D-25469 Halstenbek
##
##                     Tel.: +49 / (0)4101 / 4058-0
##                     Fax.: +49 / (0)4101 / 4058-19
##                     e-mail: support@tews.com
##
##                     Copyright (c) 2016
##                     TEWS TECHNOLOGIES GmbH
##
##   History         :
##       Version   1 : (RR, 30.11..2016)
##                     Initial Version
##
##   Comments        : none
##
## ############################################################################################# ##


### General Config Settings
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property BITSTREAM.GENERAL.COMPRESS FALSE [current_design]


### Boot from external Clock
set_property BITSTREAM.CONFIG.EXTMASTERCCLK_EN div-1 [current_design]


### SPI x4 Settings
set_property BITSTREAM.CONFIG.SPI_FALL_EDGE YES [current_design]
set_property CONFIG_MODE SPIx4 [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]




