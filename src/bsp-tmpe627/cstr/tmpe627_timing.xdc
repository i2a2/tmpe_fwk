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
##   File Name       : tmpe627_timing.xdc
##   Target Device   : Artix-7 XC7A50T-2CSG325I
##   Design Tool     : Xilinx Vivado 2016.3
##   Simulation Tool : -
##
##   Description     : Timing constraint file for TMPE627 FPGA
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
##       Version   1 : (RR, 02.12.2016)
##                     Initial Version
##
##   Comments        : none
##
## ############################################################################################# ##

# PCIe Reference Clock
create_clock -period 10.000 [get_ports REFCLK_P]

# 100 MHz External Configuration Master Clock
create_clock -period 10.000 [get_ports EMC_CLK]




