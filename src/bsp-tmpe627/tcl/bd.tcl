# Vivado Tcl that creates and wires the tmpe_daq block design
# Author: David Andrino-Izquierdo <david.andrino@upm.es>
# Copyright: I2A2-UPM 2026
# SPDX-License-Identifier: Apache-2.0

set design_name tmpe_daq

common::send_gid_msg -ssname BD::TCL -id 2010 -severity "INFO" "Currently there is no design <$design_name> in project, so creating one..."

create_bd_design $design_name

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
    set list_check_ips "\ 
xilinx.com:ip:axis_data_fifo:2.0\
xilinx.com:ip:c_counter_binary:12.0\
xilinx.com:ip:xdma:4.2\
xilinx.com:ip:xlconcat:2.1\
xilinx.com:ip:xlconstant:1.1\
"

set list_ips_missing ""
common::send_gid_msg -ssname BD::TCL -id 2011 -severity "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

foreach ip_vlnv $list_check_ips {
    set ip_obj [get_ipdefs -all $ip_vlnv]
    if { $ip_obj eq "" } {
        lappend list_ips_missing $ip_vlnv
    }
}

if { $list_ips_missing ne "" } {
    catch {common::send_gid_msg -ssname BD::TCL -id 2012 -severity "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
    set bCheckIPsPassed 0
}

}

##################################################################
# CHECK Modules
##################################################################
set bCheckModules 1
if { $bCheckModules == 1 } {
    set list_check_mods "\ 
adc\
axiRegisters\
clock_buffer\
dac\
dsp\
fgen\
reset_generator\
"

set list_mods_missing ""
common::send_gid_msg -ssname BD::TCL -id 2020 -severity "INFO" "Checking if the following modules exist in the project's sources: $list_check_mods ."

foreach mod_vlnv $list_check_mods {
    if { [can_resolve_reference $mod_vlnv] == 0 } {
        lappend list_mods_missing $mod_vlnv
    }
}

if { $list_mods_missing ne "" } {
    catch {common::send_gid_msg -ssname BD::TCL -id 2021 -severity "ERROR" "The following module(s) are not found in the project: $list_mods_missing" }
    common::send_gid_msg -ssname BD::TCL -id 2022 -severity "INFO" "Please add source files for the missing module(s) above."
    set bCheckIPsPassed 0
}
}

if { $bCheckIPsPassed != 1 } {
common::send_gid_msg -ssname BD::TCL -id 2023 -severity "WARNING" "Will not continue with creation of design due to the error(s) above."
return 3
}

variable script_folder

set parentCell "" 

if { $parentCell eq "" } {
    set parentCell [get_bd_cells /]
}

# Get object for parentCell
set parentObj [get_bd_cells $parentCell]
if { $parentObj == "" } {
    catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
    return
}

# Make sure parentObj is hier blk
set parentType [get_property TYPE $parentObj]
if { $parentType ne "hier" } {
    catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
    return
}

# Save current instance; Restore later
set oldCurInst [current_bd_instance .]

# Set parent object as current
current_bd_instance $parentObj


# Create interface ports

# Create ports
set ADC_BUSY [ create_bd_port -dir I -type data ADC_BUSY ]
set ADC_CNV [ create_bd_port -dir O -type data ADC_CNV ]
set ADC_CS_n [ create_bd_port -dir O -type data ADC_CS_n ]
set ADC_LVDS_CMOS_n [ create_bd_port -dir O -type data ADC_LVDS_CMOS_n ]
set ADC_PD [ create_bd_port -dir O -type data ADC_PD ]
set ADC_SCKI_SCKI_N [ create_bd_port -dir O -type data ADC_SCKI_SCKI_N ]
set ADC_SDI [ create_bd_port -dir O -type data ADC_SDI ]
set ADC_SDO0 [ create_bd_port -dir I -type data ADC_SDO0 ]
set ADC_SDO1_SDI_P [ create_bd_port -dir I -type data ADC_SDO1_SDI_P ]
set ADC_SDO2_SDI_N [ create_bd_port -dir I -type data ADC_SDO2_SDI_N ]
set ADC_SDO3_SCKI_P [ create_bd_port -dir I -type data ADC_SDO3_SCKI_P ]
set ADC_SDO4_SCKO_N [ create_bd_port -dir I -type data ADC_SDO4_SCKO_N ]
set ADC_SDO5_SDO_P [ create_bd_port -dir I -type data ADC_SDO5_SDO_P ]
set ADC_SDO6_SDO_N [ create_bd_port -dir I -type data ADC_SDO6_SDO_N ]
set ADC_SDO7 [ create_bd_port -dir I -type data ADC_SDO7 ]
set DAC_BIN2S [ create_bd_port -dir O -type data DAC_BIN2S ]
set DAC_CLR_n [ create_bd_port -dir O -from 0 -to 0 -type data DAC_CLR_n ]
set DAC_LDAC_n [ create_bd_port -dir O -type data DAC_LDAC_n ]
set DAC_SCLK [ create_bd_port -dir O -type data DAC_SCLK ]
set DAC_SDIN [ create_bd_port -dir O -type data DAC_SDIN ]
set DAC_SDO [ create_bd_port -dir I -type data DAC_SDO ]
set DAC_SYNC_n [ create_bd_port -dir O -type data DAC_SYNC_n ]
set DI [ create_bd_port -dir I -from 13 -to 0 -type data DI ]
set DOut [ create_bd_port -dir O -from 13 -to 0 -type data DOut ]
set EMC_CLK [ create_bd_port -dir I -type clk -freq_hz 100000000 EMC_CLK ]
set OE [ create_bd_port -dir O -from 13 -to 0 -type data OE ]
set PER0_N [ create_bd_port -dir O -from 0 -to 0 -type data PER0_N ]
set PER0_P [ create_bd_port -dir O -from 0 -to 0 -type data PER0_P ]
set PERST_n [ create_bd_port -dir I -type rst PERST_n ]
set PET0_N [ create_bd_port -dir I -type data PET0_N ]
set PET0_P [ create_bd_port -dir I -type data PET0_P ]
set REFCLK_N [ create_bd_port -dir I -type clk -freq_hz 100000000 REFCLK_N ]
set REFCLK_P [ create_bd_port -dir I -type clk -freq_hz 100000000 REFCLK_P ]
set SEL [ create_bd_port -dir O -from 1 -to 0 -type data SEL ]

# Create instance: adc_0, and set properties
set block_name adc
set block_cell_name adc_0
if { [catch {set adc_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
    catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
    return 1
} elseif { $adc_0 eq "" } {
    catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
    return 1
}

# Create instance: axiRegisters_0, and set properties
set block_name axiRegisters
set block_cell_name axiRegisters_0
if { [catch {set axiRegisters_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
    catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
    return 1
} elseif { $axiRegisters_0 eq "" } {
    catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
    return 1
}
set_property CONFIG.SAMPLING_EOC_INITIAL_VALUE {0x000003E8} $axiRegisters_0


# Create instance: axis_data_fifo_0, and set properties
set axis_data_fifo_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo:2.0 axis_data_fifo_0 ]
set_property -dict [list \
CONFIG.ACLKEN_CONV_MODE {1} \
CONFIG.FIFO_DEPTH {16} \
CONFIG.FIFO_MEMORY_TYPE {auto} \
CONFIG.IS_ACLK_ASYNC {1} \
] $axis_data_fifo_0


# Create instance: axis_data_fifo_1, and set properties
set axis_data_fifo_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo:2.0 axis_data_fifo_1 ]
set_property -dict [list \
CONFIG.FIFO_DEPTH {16} \
CONFIG.IS_ACLK_ASYNC {1} \
] $axis_data_fifo_1


# Create instance: c_counter_binary_0, and set properties
set c_counter_binary_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:c_counter_binary:12.0 c_counter_binary_0 ]
set_property -dict [list \
CONFIG.CE {true} \
CONFIG.Output_Width {1} \
CONFIG.Restrict_Count {false} \
] $c_counter_binary_0


# Create instance: clock_buffer_0, and set properties
set block_name clock_buffer
set block_cell_name clock_buffer_0
if { [catch {set clock_buffer_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
    catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
    return 1
} elseif { $clock_buffer_0 eq "" } {
    catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
    return 1
}

# Create instance: dac_0, and set properties
set block_name dac
set block_cell_name dac_0
if { [catch {set dac_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
    catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
    return 1
} elseif { $dac_0 eq "" } {
    catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
    return 1
}
set_property -dict [list \
CONFIG.CHANNELS {4} \
CONFIG.CLOCK_FREQUENCY {100} \
] $dac_0


# Create instance: dsp_0, and set properties
set block_name dsp
set block_cell_name dsp_0
if { [catch {set dsp_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
    catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
    return 1
} elseif { $dsp_0 eq "" } {
    catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
    return 1
}
set_property CONFIG.DATA_IN_CNT {4} $dsp_0


# Create instance: fgen_0, and set properties
set block_name fgen
set block_cell_name fgen_0
if { [catch {set fgen_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
    catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
    return 1
} elseif { $fgen_0 eq "" } {
    catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
    return 1
}

# Create instance: reset_generator_0, and set properties
set block_name reset_generator
set block_cell_name reset_generator_0
if { [catch {set reset_generator_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
    catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
    return 1
} elseif { $reset_generator_0 eq "" } {
    catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
    return 1
}

# Create instance: xdma_0, and set properties
set xdma_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xdma:4.2 xdma_0 ]
set_property -dict [list \
CONFIG.axilite_master_en {true} \
CONFIG.axilite_master_scale {Kilobytes} \
CONFIG.axilite_master_size {4} \
CONFIG.axisten_freq {125} \
CONFIG.cfg_mgmt_if {false} \
CONFIG.pcie_extended_tag {false} \
CONFIG.pf0_link_status_slot_clock_config {true} \
CONFIG.xdma_axi_intf_mm {AXI_Stream} \
CONFIG.xdma_pcie_64bit_en {true} \
CONFIG.xdma_sts_ports {false} \
] $xdma_0


# Create instance: xlconcat_0, and set properties
set xlconcat_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_0 ]
set_property -dict [list \
CONFIG.IN3_WIDTH {11} \
CONFIG.NUM_PORTS {4} \
] $xlconcat_0


# Create instance: xlconstant_0, and set properties
set xlconstant_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_0 ]
set_property -dict [list \
CONFIG.CONST_VAL {7} \
CONFIG.CONST_WIDTH {14} \
] $xlconstant_0


# Create instance: xlconstant_1, and set properties
set xlconstant_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_1 ]
set_property -dict [list \
CONFIG.CONST_VAL {0} \
CONFIG.CONST_WIDTH {11} \
] $xlconstant_1


# Create instance: xlconstant_2, and set properties
set xlconstant_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_2 ]
set_property -dict [list \
CONFIG.CONST_VAL {0} \
CONFIG.CONST_WIDTH {2} \
] $xlconstant_2


# Create interface connections
connect_bd_intf_net -intf_net adc_0_axi_array [get_bd_intf_pins adc_0/axi_array] [get_bd_intf_pins dsp_0/axi_in]
connect_bd_intf_net -intf_net axis_data_fifo_0_M_AXIS [get_bd_intf_pins axis_data_fifo_0/M_AXIS] [get_bd_intf_pins xdma_0/S_AXIS_C2H_0]
connect_bd_intf_net -intf_net axis_data_fifo_1_M_AXIS [get_bd_intf_pins axis_data_fifo_1/M_AXIS] [get_bd_intf_pins dsp_0/axi_h2c]
connect_bd_intf_net -intf_net dsp_0_axi_c2h [get_bd_intf_pins axis_data_fifo_0/S_AXIS] [get_bd_intf_pins dsp_0/axi_c2h]
connect_bd_intf_net -intf_net dsp_0_axi_out [get_bd_intf_pins dac_0/axi_in_array] [get_bd_intf_pins dsp_0/axi_out]
connect_bd_intf_net -intf_net xdma_0_M_AXIS_H2C_0 [get_bd_intf_pins axis_data_fifo_1/S_AXIS] [get_bd_intf_pins xdma_0/M_AXIS_H2C_0]
connect_bd_intf_net -intf_net xdma_0_M_AXI_LITE [get_bd_intf_pins axiRegisters_0/S_AXI] [get_bd_intf_pins xdma_0/M_AXI_LITE]

# Create port connections
connect_bd_net -net ADC_BUSY_1 [get_bd_ports ADC_BUSY] [get_bd_pins adc_0/busy] [get_bd_pins xlconcat_0/In1]
connect_bd_net -net ADC_SDO0_1 [get_bd_ports ADC_SDO0] [get_bd_pins adc_0/sdo0]
connect_bd_net -net ADC_SDO1_SDI_P_1 [get_bd_ports ADC_SDO1_SDI_P] [get_bd_pins adc_0/sdo1]
connect_bd_net -net ADC_SDO2_SDI_N_1 [get_bd_ports ADC_SDO2_SDI_N] [get_bd_pins adc_0/sdo2]
connect_bd_net -net ADC_SDO3_SCKI_P_1 [get_bd_ports ADC_SDO3_SCKI_P] [get_bd_pins adc_0/sdo3]
connect_bd_net -net ADC_SDO4_SCKO_N_1 [get_bd_ports ADC_SDO4_SCKO_N] [get_bd_pins adc_0/sdo4]
connect_bd_net -net ADC_SDO5_SDO_P_1 [get_bd_ports ADC_SDO5_SDO_P] [get_bd_pins adc_0/sdo5]
connect_bd_net -net ADC_SDO6_SDO_N_1 [get_bd_ports ADC_SDO6_SDO_N] [get_bd_pins adc_0/sdo6]
connect_bd_net -net ADC_SDO7_1 [get_bd_ports ADC_SDO7] [get_bd_pins adc_0/sdo7]
connect_bd_net -net DAC_SDO_1 [get_bd_ports DAC_SDO] [get_bd_pins dac_0/dac_sdo]
connect_bd_net -net EMC_CLK_1 [get_bd_ports EMC_CLK] [get_bd_pins adc_0/clock] [get_bd_pins axiRegisters_0/dst_clk] [get_bd_pins axis_data_fifo_0/s_axis_aclk] [get_bd_pins axis_data_fifo_1/m_axis_aclk] [get_bd_pins c_counter_binary_0/CLK] [get_bd_pins dac_0/clock] [get_bd_pins dsp_0/clk] [get_bd_pins fgen_0/clk] [get_bd_pins reset_generator_0/clk]
connect_bd_net -net PERST_n_1 [get_bd_ports PERST_n] [get_bd_pins xdma_0/sys_rst_n]
connect_bd_net -net PET0_N_1 [get_bd_ports PET0_N] [get_bd_pins xdma_0/pci_exp_rxn]
connect_bd_net -net PET0_P_1 [get_bd_ports PET0_P] [get_bd_pins xdma_0/pci_exp_rxp]
connect_bd_net -net REFCLK_N_1 [get_bd_ports REFCLK_N] [get_bd_pins clock_buffer_0/IB]
connect_bd_net -net REFCLK_P_1 [get_bd_ports REFCLK_P] [get_bd_pins clock_buffer_0/I]
connect_bd_net -net adc_0_cnv [get_bd_pins adc_0/cnv] [get_bd_ports ADC_CNV]
connect_bd_net -net adc_0_cs_n [get_bd_pins adc_0/cs_n] [get_bd_ports ADC_CS_n]
connect_bd_net -net adc_0_lvds_cmos_n [get_bd_pins adc_0/lvds_cmos_n] [get_bd_ports ADC_LVDS_CMOS_n]
connect_bd_net -net adc_0_pd [get_bd_pins adc_0/pd] [get_bd_ports ADC_PD]
connect_bd_net -net adc_0_scki [get_bd_pins adc_0/scki] [get_bd_ports ADC_SCKI_SCKI_N]
connect_bd_net -net adc_0_sdi [get_bd_pins adc_0/sdi] [get_bd_ports ADC_SDI]
connect_bd_net -net axiRegisters_0_adc_powerdown [get_bd_pins axiRegisters_0/adc_powerdown] [get_bd_pins adc_0/adc_power_down]
connect_bd_net -net axiRegisters_0_adc_softspan [get_bd_pins axiRegisters_0/adc_softspan] [get_bd_pins adc_0/softspan]
connect_bd_net -net axiRegisters_0_dac_clr_sel [get_bd_pins axiRegisters_0/dac_clr_sel] [get_bd_pins dac_0/config_clr_sel]
connect_bd_net -net axiRegisters_0_dac_code [get_bd_pins axiRegisters_0/dac_code] [get_bd_pins dac_0/config_code]
connect_bd_net -net axiRegisters_0_dac_powerup [get_bd_pins axiRegisters_0/dac_powerup] [get_bd_pins dac_0/config_pu_en]
connect_bd_net -net axiRegisters_0_dac_range [get_bd_pins axiRegisters_0/dac_range] [get_bd_pins dac_0/config_range]
connect_bd_net -net axiRegisters_0_dac_tsd_ena [get_bd_pins axiRegisters_0/dac_tsd_ena] [get_bd_pins dac_0/config_tsd_en]
connect_bd_net -net axiRegisters_0_dsp_ena_c2h [get_bd_pins axiRegisters_0/dsp_ena_c2h] [get_bd_pins axis_data_fifo_0/s_axis_aclken]
connect_bd_net -net axiRegisters_0_sampling_eoc [get_bd_pins axiRegisters_0/sampling_eoc] [get_bd_pins fgen_0/cnt_end]
connect_bd_net -net c_counter_binary_0_Q [get_bd_pins c_counter_binary_0/Q] [get_bd_pins xlconcat_0/In0]
connect_bd_net -net clock_buffer_0_O [get_bd_pins clock_buffer_0/O] [get_bd_pins xdma_0/sys_clk]
connect_bd_net -net dac_0_dac_bin2s [get_bd_pins dac_0/dac_bin2s] [get_bd_ports DAC_BIN2S]
connect_bd_net -net dac_0_dac_ldacn [get_bd_pins dac_0/dac_ldacn] [get_bd_ports DAC_LDAC_n]
connect_bd_net -net dac_0_dac_sclk [get_bd_pins dac_0/dac_sclk] [get_bd_ports DAC_SCLK]
connect_bd_net -net dac_0_dac_sdin [get_bd_pins dac_0/dac_sdin] [get_bd_ports DAC_SDIN]
connect_bd_net -net dac_0_dac_syncn [get_bd_pins dac_0/dac_syncn] [get_bd_ports DAC_SYNC_n] [get_bd_pins xlconcat_0/In2]
connect_bd_net -net fgen_0_eoc [get_bd_pins fgen_0/eoc] [get_bd_pins adc_0/ena_conv] [get_bd_pins c_counter_binary_0/CE] [get_bd_pins dac_0/sampling_clk]
connect_bd_net -net reset_generator_0_eoc [get_bd_pins reset_generator_0/eoc] [get_bd_pins adc_0/anrst] [get_bd_pins axis_data_fifo_0/s_axis_aresetn] [get_bd_pins dac_0/axi_anrst] [get_bd_pins dsp_0/anrst]
connect_bd_net -net xdma_0_axi_aclk [get_bd_pins xdma_0/axi_aclk] [get_bd_pins axiRegisters_0/S_AXI_ACLK] [get_bd_pins axis_data_fifo_0/m_axis_aclk] [get_bd_pins axis_data_fifo_1/s_axis_aclk]
connect_bd_net -net xdma_0_axi_aresetn [get_bd_pins xdma_0/axi_aresetn] [get_bd_pins axiRegisters_0/S_AXI_ARESETN] [get_bd_pins axis_data_fifo_1/s_axis_aresetn]
connect_bd_net -net xdma_0_pci_exp_txn [get_bd_pins xdma_0/pci_exp_txn] [get_bd_ports PER0_N]
connect_bd_net -net xdma_0_pci_exp_txp [get_bd_pins xdma_0/pci_exp_txp] [get_bd_ports PER0_P]
connect_bd_net -net xlconcat_0_dout [get_bd_pins xlconcat_0/dout] [get_bd_ports DOut]
connect_bd_net -net xlconstant_0_dout [get_bd_pins xlconstant_0/dout] [get_bd_ports OE]
connect_bd_net -net xlconstant_1_dout [get_bd_pins xlconstant_1/dout] [get_bd_pins xlconcat_0/In3]
connect_bd_net -net xlconstant_2_dout [get_bd_pins xlconstant_2/dout] [get_bd_ports SEL]

# Create address segments
assign_bd_address -offset 0x00000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI_LITE] [get_bd_addr_segs axiRegisters_0/S_AXI/reg0] -force

# Perform GUI Layout
regenerate_bd_layout -layout_string {
"ActiveEmotionalView":"Default View",
"Default View_ScaleFactor":"0.22067",
"Default View_TopLeft":"-1523,-9",
"ExpandedHierarchyInLayout":"",
"guistr":"# # String gsaved with Nlview 7.5.8 2022-09-21 7111 VDI=41 GEI=38 GUI=JA:10.0 TLS
#  -string -flagsOSRD
preplace port port-id_ADC_BUSY -pg 1 -lvl 0 -x 0 -y 480 -defaultsOSRD
preplace port port-id_ADC_CNV -pg 1 -lvl 8 -x 2200 -y 900 -defaultsOSRD
preplace port port-id_ADC_CS_n -pg 1 -lvl 8 -x 2200 -y 880 -defaultsOSRD
preplace port port-id_ADC_LVDS_CMOS_n -pg 1 -lvl 8 -x 2200 -y 840 -defaultsOSRD
preplace port port-id_ADC_PD -pg 1 -lvl 8 -x 2200 -y 860 -defaultsOSRD
preplace port port-id_ADC_SCKI_SCKI_N -pg 1 -lvl 8 -x 2200 -y 920 -defaultsOSRD
preplace port port-id_ADC_SDI -pg 1 -lvl 8 -x 2200 -y 940 -defaultsOSRD
preplace port port-id_ADC_SDO0 -pg 1 -lvl 0 -x 0 -y 830 -defaultsOSRD
preplace port port-id_ADC_SDO1_SDI_P -pg 1 -lvl 0 -x 0 -y 850 -defaultsOSRD
preplace port port-id_ADC_SDO2_SDI_N -pg 1 -lvl 0 -x 0 -y 870 -defaultsOSRD
preplace port port-id_ADC_SDO3_SCKI_P -pg 1 -lvl 0 -x 0 -y 890 -defaultsOSRD
preplace port port-id_ADC_SDO4_SCKO_N -pg 1 -lvl 0 -x 0 -y 910 -defaultsOSRD
preplace port port-id_ADC_SDO5_SDO_P -pg 1 -lvl 0 -x 0 -y 930 -defaultsOSRD
preplace port port-id_ADC_SDO6_SDO_N -pg 1 -lvl 0 -x 0 -y 950 -defaultsOSRD
preplace port port-id_ADC_SDO7 -pg 1 -lvl 0 -x 0 -y 970 -defaultsOSRD
preplace port port-id_DAC_BIN2S -pg 1 -lvl 8 -x 2200 -y 190 -defaultsOSRD
preplace port port-id_DAC_LDAC_n -pg 1 -lvl 8 -x 2200 -y 250 -defaultsOSRD
preplace port port-id_DAC_SCLK -pg 1 -lvl 8 -x 2200 -y 170 -defaultsOSRD
preplace port port-id_DAC_SDIN -pg 1 -lvl 8 -x 2200 -y 210 -defaultsOSRD
preplace port port-id_DAC_SDO -pg 1 -lvl 0 -x 0 -y 440 -defaultsOSRD
preplace port port-id_DAC_SYNC_n -pg 1 -lvl 8 -x 2200 -y 230 -defaultsOSRD
preplace port port-id_EMC_CLK -pg 1 -lvl 0 -x 0 -y 550 -defaultsOSRD
preplace port port-id_PERST_n -pg 1 -lvl 0 -x 0 -y 280 -defaultsOSRD
preplace port port-id_PET0_N -pg 1 -lvl 0 -x 0 -y 90 -defaultsOSRD
preplace port port-id_PET0_P -pg 1 -lvl 0 -x 0 -y 460 -defaultsOSRD
preplace port port-id_REFCLK_N -pg 1 -lvl 0 -x 0 -y 360 -defaultsOSRD
preplace port port-id_REFCLK_P -pg 1 -lvl 0 -x 0 -y 340 -defaultsOSRD
preplace portBus DAC_CLR_n -pg 1 -lvl 8 -x 2200 -y 20 -defaultsOSRD
preplace portBus DI -pg 1 -lvl 0 -x 0 -y 20 -defaultsOSRD
preplace portBus DOut -pg 1 -lvl 8 -x 2200 -y 560 -defaultsOSRD
preplace portBus OE -pg 1 -lvl 8 -x 2200 -y 430 -defaultsOSRD
preplace portBus PER0_N -pg 1 -lvl 8 -x 2200 -y 350 -defaultsOSRD
preplace portBus PER0_P -pg 1 -lvl 8 -x 2200 -y 370 -defaultsOSRD
preplace portBus SEL -pg 1 -lvl 8 -x 2200 -y 690 -defaultsOSRD
preplace inst adc_0 -pg 1 -lvl 6 -x 1800 -y 880 -defaultsOSRD
preplace inst axiRegisters_0 -pg 1 -lvl 4 -x 1060 -y 130 -defaultsOSRD
preplace inst axis_data_fifo_0 -pg 1 -lvl 2 -x 380 -y 610 -defaultsOSRD
preplace inst axis_data_fifo_1 -pg 1 -lvl 4 -x 1060 -y 380 -defaultsOSRD
preplace inst c_counter_binary_0 -pg 1 -lvl 6 -x 1800 -y 480 -defaultsOSRD
preplace inst clock_buffer_0 -pg 1 -lvl 2 -x 380 -y 350 -defaultsOSRD
preplace inst dac_0 -pg 1 -lvl 6 -x 1800 -y 210 -defaultsOSRD
preplace inst dsp_0 -pg 1 -lvl 5 -x 1440 -y 590 -defaultsOSRD
preplace inst fgen_0 -pg 1 -lvl 5 -x 1440 -y 420 -defaultsOSRD
preplace inst reset_generator_0 -pg 1 -lvl 1 -x 120 -y 550 -defaultsOSRD
preplace inst xdma_0 -pg 1 -lvl 3 -x 680 -y 270 -defaultsOSRD
preplace inst xlconcat_0 -pg 1 -lvl 7 -x 2070 -y 560 -defaultsOSRD
preplace inst xlconstant_0 -pg 1 -lvl 7 -x 2070 -y 430 -defaultsOSRD
preplace inst xlconstant_1 -pg 1 -lvl 6 -x 1800 -y 610 -defaultsOSRD
preplace inst xlconstant_2 -pg 1 -lvl 7 -x 2070 -y 690 -defaultsOSRD
preplace netloc ADC_BUSY_1 1 0 7 NJ 480 NJ 480 NJ 480 870J 470 1270J 350 1570 550 NJ
preplace netloc ADC_SDO0_1 1 0 6 NJ 830 NJ 830 NJ 830 NJ 830 NJ 830 NJ
preplace netloc ADC_SDO1_SDI_P_1 1 0 6 NJ 850 NJ 850 NJ 850 NJ 850 NJ 850 NJ
preplace netloc ADC_SDO2_SDI_N_1 1 0 6 NJ 870 NJ 870 NJ 870 NJ 870 NJ 870 NJ
preplace netloc ADC_SDO3_SCKI_P_1 1 0 6 NJ 890 NJ 890 NJ 890 NJ 890 NJ 890 NJ
preplace netloc ADC_SDO4_SCKO_N_1 1 0 6 NJ 910 NJ 910 NJ 910 NJ 910 NJ 910 NJ
preplace netloc ADC_SDO5_SDO_P_1 1 0 6 NJ 930 NJ 930 NJ 930 NJ 930 NJ 930 NJ
preplace netloc ADC_SDO6_SDO_N_1 1 0 6 NJ 950 NJ 950 NJ 950 NJ 950 NJ 950 NJ
preplace netloc ADC_SDO7_1 1 0 6 NJ 970 NJ 970 NJ 970 NJ 970 NJ 970 NJ
preplace netloc DAC_SDO_1 1 0 6 NJ 440 NJ 440 500J 450 890J 290 NJ 290 1610J
preplace netloc EMC_CLK_1 1 0 6 20 610 230 510 NJ 510 880 480 1310 500 1650
preplace netloc PERST_n_1 1 0 3 NJ 280 NJ 280 NJ
preplace netloc PET0_N_1 1 0 4 NJ 90 NJ 90 NJ 90 840
preplace netloc PET0_P_1 1 0 4 NJ 460 NJ 460 NJ 460 840
preplace netloc REFCLK_N_1 1 0 2 NJ 360 NJ
preplace netloc REFCLK_P_1 1 0 2 NJ 340 NJ
preplace netloc adc_0_cnv 1 6 2 NJ 900 NJ
preplace netloc adc_0_cs_n 1 6 2 NJ 880 NJ
preplace netloc adc_0_lvds_cmos_n 1 6 2 NJ 840 NJ
preplace netloc adc_0_pd 1 6 2 NJ 860 NJ
preplace netloc adc_0_scki 1 6 2 NJ 920 NJ
preplace netloc adc_0_sdi 1 6 2 NJ 940 NJ
preplace netloc axiRegisters_0_adc_powerdown 1 4 2 1240 790 NJ
preplace netloc axiRegisters_0_adc_softspan 1 4 2 1280J 260 1580
preplace netloc axiRegisters_0_dac_clr_sel 1 4 2 1250 220 NJ
preplace netloc axiRegisters_0_dac_code 1 4 2 1310 180 NJ
preplace netloc axiRegisters_0_dac_powerup 1 4 2 1260 240 NJ
preplace netloc axiRegisters_0_dac_range 1 4 2 1270 250 1650J
preplace netloc axiRegisters_0_dac_tsd_ena 1 4 2 1290 200 NJ
preplace netloc axiRegisters_0_dsp_ena_c2h 1 1 4 260 500 NJ 500 NJ 500 1220
preplace netloc axiRegisters_0_sampling_eoc 1 4 1 1300 50n
preplace netloc c_counter_binary_0_Q 1 6 1 1950 480n
preplace netloc clock_buffer_0_O 1 2 1 520 260n
preplace netloc dac_0_dac_bin2s 1 6 2 NJ 190 NJ
preplace netloc dac_0_dac_ldacn 1 6 2 NJ 250 NJ
preplace netloc dac_0_dac_sclk 1 6 2 NJ 170 NJ
preplace netloc dac_0_dac_sdin 1 6 2 NJ 210 NJ
preplace netloc dac_0_dac_syncn 1 6 2 1960 230 NJ
preplace netloc fgen_0_eoc 1 5 1 1630 160n
preplace netloc reset_generator_0_eoc 1 1 5 220 710 NJ 710 NJ 710 1300 680 1640
preplace netloc xdma_0_axi_aclk 1 1 3 240 470 NJ 470 860
preplace netloc xdma_0_axi_aresetn 1 3 1 900 160n
preplace netloc xdma_0_pci_exp_txn 1 3 5 890J 270 NJ 270 1620J 360 NJ 360 2180J
preplace netloc xdma_0_pci_exp_txp 1 3 5 850J 280 NJ 280 1600J 370 NJ 370 NJ
preplace netloc xlconcat_0_dout 1 7 1 NJ 560
preplace netloc xlconstant_0_dout 1 7 1 NJ 430
preplace netloc xlconstant_1_dout 1 6 1 1950J 590n
preplace netloc xlconstant_2_dout 1 7 1 NJ 690
preplace netloc adc_0_axi_array 1 4 3 1320 690 NJ 690 1950
preplace netloc axis_data_fifo_0_M_AXIS 1 2 1 510 240n
preplace netloc axis_data_fifo_1_M_AXIS 1 4 1 1230 380n
preplace netloc dsp_0_axi_c2h 1 1 5 250 490 NJ 490 NJ 490 NJ 490 1560
preplace netloc dsp_0_axi_out 1 5 1 1590 120n
preplace netloc xdma_0_M_AXIS_H2C_0 1 3 1 870 170n
preplace netloc xdma_0_M_AXI_LITE 1 3 1 850 100n
levelinfo -pg 1 0 120 380 680 1060 1440 1800 2070 2200
pagesize -pg 1 -db -bbox -sgen -160 0 2360 1060
"
}

# Restore current instance
current_bd_instance $oldCurInst

validate_bd_design
save_bd_design
close_bd_design $design_name 
