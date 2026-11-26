-- Vivado block design top-level wrapper entity
-- Block design authored by David Andrino-Izquierdo <david.andrino@upm.es> (I2A2-UPM)
-- Copyright: AMD/Xilinx: Vivado 2021.1 generated Output Product
-- SPDX-License-Identifier: LicenseRef-AMD-Xilinx-Output-Products

----------------------------------------------------------------------------------
-- Block Design Wrapper
--
-- Wrapper for the block design. Should be used as top level entity. Generated
-- by Vivado 2021.1
-- This whole file is a Vivado Output Product (Create HDL Wrapper): no
-- I2A2-UPM original content is claimed in it and no Apache-2.0 grant is made
-- over it. Its terms are the AMD End User Licence Agreement and the Xilinx
-- Export Control Statement, referenced in NOTICE as
-- LicenseRef-AMD-Xilinx-Output-Products. The UNISIM primitives it instantiates
-- are supplied by Vivado at build time and are not redistributed here.
--
-- Author: David Andrino - I2A2 UPM
-- Date: 12-03-2025
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity tmpe_daq_wrapper is
  port (
    ADC_BUSY : in STD_LOGIC;
    ADC_CNV : out STD_LOGIC;
    ADC_CS_n : out STD_LOGIC;
    ADC_LVDS_CMOS_n : out STD_LOGIC;
    ADC_PD : out STD_LOGIC;
    ADC_SCKI_SCKI_N : out STD_LOGIC;
    ADC_SDI : out STD_LOGIC;
    ADC_SDO0 : in STD_LOGIC;
    ADC_SDO1_SDI_P : in STD_LOGIC;
    ADC_SDO2_SDI_N : in STD_LOGIC;
    ADC_SDO3_SCKI_P : in STD_LOGIC;
    ADC_SDO4_SCKO_N : in STD_LOGIC;
    ADC_SDO5_SDO_P : in STD_LOGIC;
    ADC_SDO6_SDO_N : in STD_LOGIC;
    ADC_SDO7 : in STD_LOGIC;
    DAC_BIN2S : out STD_LOGIC;
    DAC_CLR_n : out STD_LOGIC_VECTOR ( 0 to 0 );
    DAC_LDAC_n : out STD_LOGIC;
    DAC_SCLK : out STD_LOGIC;
    DAC_SDIN : out STD_LOGIC;
    DAC_SDO : in STD_LOGIC;
    DAC_SYNC_n : out STD_LOGIC;
    DI : in STD_LOGIC_VECTOR ( 13 downto 0 );
    DOut : out STD_LOGIC_VECTOR ( 13 downto 0 );
    EMC_CLK : in STD_LOGIC;
    OE : out STD_LOGIC_VECTOR ( 13 downto 0 );
    PER0_N : out STD_LOGIC_VECTOR ( 0 to 0 );
    PER0_P : out STD_LOGIC_VECTOR ( 0 to 0 );
    PERST_n : in STD_LOGIC;
    PET0_N : in STD_LOGIC;
    PET0_P : in STD_LOGIC;
    REFCLK_N : in STD_LOGIC;
    REFCLK_P : in STD_LOGIC;
    SEL : out STD_LOGIC_VECTOR ( 1 downto 0 )
  );
end tmpe_daq_wrapper;

architecture STRUCTURE of tmpe_daq_wrapper is
  component tmpe_daq is
  port (
    ADC_BUSY : in STD_LOGIC;
    ADC_CNV : out STD_LOGIC;
    ADC_CS_n : out STD_LOGIC;
    ADC_LVDS_CMOS_n : out STD_LOGIC;
    ADC_PD : out STD_LOGIC;
    ADC_SCKI_SCKI_N : out STD_LOGIC;
    ADC_SDI : out STD_LOGIC;
    ADC_SDO0 : in STD_LOGIC;
    ADC_SDO1_SDI_P : in STD_LOGIC;
    ADC_SDO2_SDI_N : in STD_LOGIC;
    ADC_SDO3_SCKI_P : in STD_LOGIC;
    ADC_SDO4_SCKO_N : in STD_LOGIC;
    ADC_SDO5_SDO_P : in STD_LOGIC;
    ADC_SDO6_SDO_N : in STD_LOGIC;
    ADC_SDO7 : in STD_LOGIC;
    DAC_BIN2S : out STD_LOGIC;
    DAC_CLR_n : out STD_LOGIC_VECTOR ( 0 to 0 );
    DAC_LDAC_n : out STD_LOGIC;
    DAC_SCLK : out STD_LOGIC;
    DAC_SDIN : out STD_LOGIC;
    DAC_SDO : in STD_LOGIC;
    DAC_SYNC_n : out STD_LOGIC;
    PER0_N : out STD_LOGIC_VECTOR ( 0 to 0 );
    PER0_P : out STD_LOGIC_VECTOR ( 0 to 0 );
    PERST_n : in STD_LOGIC;
    PET0_N : in STD_LOGIC;
    PET0_P : in STD_LOGIC;
    REFCLK_N : in STD_LOGIC;
    REFCLK_P : in STD_LOGIC;
    DI : in STD_LOGIC_VECTOR ( 13 downto 0 );
    DOut : out STD_LOGIC_VECTOR ( 13 downto 0 );
    SEL : out STD_LOGIC_VECTOR ( 1 downto 0 );
    OE : out STD_LOGIC_VECTOR ( 13 downto 0 );
    EMC_CLK : in STD_LOGIC
  );
  end component tmpe_daq;
begin
tmpe_daq_i: component tmpe_daq
     port map (
      ADC_BUSY => ADC_BUSY,
      ADC_CNV => ADC_CNV,
      ADC_CS_n => ADC_CS_n,
      ADC_LVDS_CMOS_n => ADC_LVDS_CMOS_n,
      ADC_PD => ADC_PD,
      ADC_SCKI_SCKI_N => ADC_SCKI_SCKI_N,
      ADC_SDI => ADC_SDI,
      ADC_SDO0 => ADC_SDO0,
      ADC_SDO1_SDI_P => ADC_SDO1_SDI_P,
      ADC_SDO2_SDI_N => ADC_SDO2_SDI_N,
      ADC_SDO3_SCKI_P => ADC_SDO3_SCKI_P,
      ADC_SDO4_SCKO_N => ADC_SDO4_SCKO_N,
      ADC_SDO5_SDO_P => ADC_SDO5_SDO_P,
      ADC_SDO6_SDO_N => ADC_SDO6_SDO_N,
      ADC_SDO7 => ADC_SDO7,
      DAC_BIN2S => DAC_BIN2S,
      DAC_CLR_n(0) => DAC_CLR_n(0),
      DAC_LDAC_n => DAC_LDAC_n,
      DAC_SCLK => DAC_SCLK,
      DAC_SDIN => DAC_SDIN,
      DAC_SDO => DAC_SDO,
      DAC_SYNC_n => DAC_SYNC_n,
      DI(13 downto 0) => DI(13 downto 0),
      DOut(13 downto 0) => DOut(13 downto 0),
      EMC_CLK => EMC_CLK,
      OE(13 downto 0) => OE(13 downto 0),
      PER0_N(0) => PER0_N(0),
      PER0_P(0) => PER0_P(0),
      PERST_n => PERST_n,
      PET0_N => PET0_N,
      PET0_P => PET0_P,
      REFCLK_N => REFCLK_N,
      REFCLK_P => REFCLK_P,
      SEL(1 downto 0) => SEL(1 downto 0)
    );
end STRUCTURE;
