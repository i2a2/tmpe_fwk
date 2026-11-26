-- Wrapper around the hls_dsp IP that splits the aggregated AXI-Stream signals
-- Author: David Andrino-Izquierdo <david.andrino@upm.es>
-- Copyright: I2A2-UPM 2026
-- SPDX-License-Identifier: Apache-2.0

----------------------------------------------------------------------------------
-- DSP (Digital Signal Processing) module
--
-- Wrapper around the hls_dsp IP. The IP should be generated with HLS on Vitis 
-- and imported into the design. It takes the aggregated AXI Stream signals and 
-- splits it for the DSP IP. 
--
-- Author: David Andrino - I2A2 UPM
-- Date: 12-03-2025
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity dsp is
    generic(
        constant DATA_IN_CNT: integer := 4;
        constant DATA_IN_WIDTH: integer := 16;
        constant DATA_OUT_CNT: integer := 4;
        constant DATA_OUT_WIDTH: integer := 16
    );
    port(
        clk:           in  std_logic;
        anrst:         in  std_logic;

        -- Input ports
        axi_in_tdata:     in  std_logic_vector(DATA_IN_CNT*DATA_IN_WIDTH - 1 downto 0);
        axi_in_tvalid:    in  std_logic_vector(DATA_IN_CNT   - 1 downto 0);
        axi_in_tready:    out std_logic_vector(DATA_IN_CNT   - 1 downto 0) := (others => '0');

        axi_h2c_tvalid:   in std_logic := '0';
        axi_h2c_tready:   out std_logic := '0';
        axi_h2c_tdata:    in std_logic_vector(63 downto 0) := (others => '0');
        axi_h2c_tkeep:    in std_logic_vector(7 downto 0) := (others => '0');
        axi_h2c_tstrb:    in std_logic_vector(7 downto 0) := (others => '0');
        axi_h2c_tlast:    in std_logic_vector(0 downto 0) := (others => '0');
    
        -- Output
        axi_out_tdata:     out  std_logic_vector(DATA_OUT_CNT*DATA_OUT_WIDTH - 1 downto 0) := (others => '0');
        axi_out_tvalid:    out  std_logic_vector(DATA_OUT_CNT   - 1 downto 0) := (others => '0');
        axi_out_tready:    in   std_logic_vector(DATA_OUT_CNT   - 1 downto 0);
    
        axi_c2h_TVALID:  out std_logic := '0';
        axi_c2h_TREADY:  in  std_logic := '0';
        axi_c2h_TDATA:   out std_logic_vector(63 downto 0) := (others => '0');
        axi_c2h_TKEEP:   out std_logic_vector(7 downto 0) := (others => '0');
        axi_c2h_TSTRB:   out std_logic_vector(7 downto 0) := (others => '0');
        axi_c2h_TLAST:   out std_logic_vector(0 downto 0) := (others => '0')
    );
end entity;

architecture rtl of dsp is
    COMPONENT hls_dsp
    PORT (
        in_adc1_TVALID : IN STD_LOGIC;
        in_adc1_TREADY : OUT STD_LOGIC;
        in_adc1_TDATA : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        in_adc1_TKEEP : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        in_adc1_TSTRB : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        in_adc1_TLAST : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
        in_adc2_TVALID : IN STD_LOGIC;
        in_adc2_TREADY : OUT STD_LOGIC;
        in_adc2_TDATA : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        in_adc2_TKEEP : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        in_adc2_TSTRB : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        in_adc2_TLAST : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
        in_adc3_TVALID : IN STD_LOGIC;
        in_adc3_TREADY : OUT STD_LOGIC;
        in_adc3_TDATA : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        in_adc3_TKEEP : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        in_adc3_TSTRB : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        in_adc3_TLAST : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
        in_adc4_TVALID : IN STD_LOGIC;
        in_adc4_TREADY : OUT STD_LOGIC;
        in_adc4_TDATA : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        in_adc4_TKEEP : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        in_adc4_TSTRB : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        in_adc4_TLAST : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
        out_dac1_TVALID : OUT STD_LOGIC;
        out_dac1_TREADY : IN STD_LOGIC;
        out_dac1_TDATA : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        out_dac1_TKEEP : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        out_dac1_TSTRB : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        out_dac1_TLAST : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
        out_dac2_TVALID : OUT STD_LOGIC;
        out_dac2_TREADY : IN STD_LOGIC;
        out_dac2_TDATA : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        out_dac2_TKEEP : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        out_dac2_TSTRB : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        out_dac2_TLAST : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
        out_dac3_TVALID : OUT STD_LOGIC;
        out_dac3_TREADY : IN STD_LOGIC;
        out_dac3_TDATA : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        out_dac3_TKEEP : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        out_dac3_TSTRB : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        out_dac3_TLAST : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
        out_dac4_TVALID : OUT STD_LOGIC;
        out_dac4_TREADY : IN STD_LOGIC;
        out_dac4_TDATA : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        out_dac4_TKEEP : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        out_dac4_TSTRB : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        out_dac4_TLAST : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
        in_h2c_TVALID : IN STD_LOGIC;
        in_h2c_TREADY : OUT STD_LOGIC;
        in_h2c_TDATA : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
        in_h2c_TKEEP : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        in_h2c_TSTRB : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        in_h2c_TLAST : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
        out_c2h_TVALID : OUT STD_LOGIC;
        out_c2h_TREADY : IN STD_LOGIC;
        out_c2h_TDATA : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
        out_c2h_TKEEP : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        out_c2h_TSTRB : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        out_c2h_TLAST : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
        ap_clk : IN STD_LOGIC;
        ap_rst_n : IN STD_LOGIC
    );
    END COMPONENT;

    signal in_adc1_TVALID:  std_logic := '0';
    signal in_adc1_TREADY:  std_logic := '0';
    signal in_adc1_TDATA:   std_logic_vector(15 downto 0) := (others => '0');
    signal in_adc2_TVALID:  std_logic := '0';
    signal in_adc2_TREADY:  std_logic := '0';
    signal in_adc2_TDATA:   std_logic_vector(15 downto 0) := (others => '0');
    signal in_adc3_TVALID:  std_logic := '0';
    signal in_adc3_TREADY:  std_logic := '0';
    signal in_adc3_TDATA:   std_logic_vector(15 downto 0) := (others => '0');
    signal in_adc4_TVALID:  std_logic := '0';
    signal in_adc4_TREADY:  std_logic := '0';
    signal in_adc4_TDATA:   std_logic_vector(15 downto 0) := (others => '0');

    signal out_dac_TVALID: std_logic_vector(3 downto 0) := (others =>'0');
    signal out_dac_TREADY: std_logic_vector(3 downto 0) := (others => '0');
    signal out_dac_TDATA:  std_logic_vector(63 downto 0) := (others => '0');

begin
    -- axi_out_tdata <=  axi_in_tdata;
    -- axi_out_tvalid <= axi_in_tvalid;
    -- axi_in_tready <=  axi_out_tready;

    -- Connect ADC Channels
    in_adc1_TVALID <= axi_in_tvalid(0);
    axi_in_tready(0) <= in_adc1_TREADY;
    in_adc1_TDATA <= axi_in_tdata(DATA_IN_WIDTH-1 downto 0);

    ADC_CONNECT_CH2: if DATA_IN_CNT > 1 generate
        in_adc2_TVALID <= axi_in_tvalid(1);
        axi_in_tready(1) <= in_adc2_TREADY;
        in_adc2_TDATA <= axi_in_tdata(DATA_IN_WIDTH*2-1 downto DATA_IN_WIDTH);
    end generate;

    ADC_CONNECT_CH3: if DATA_IN_CNT > 2 generate
        in_adc3_TVALID <= axi_in_tvalid(2);
        axi_in_tready(2) <= in_adc3_TREADY;
        in_adc3_TDATA <= axi_in_tdata(DATA_IN_WIDTH*3-1 downto DATA_IN_WIDTH*2);
    end generate;

    ADC_CONNECT_CH4: if DATA_IN_CNT > 3 generate
        in_adc4_TVALID <= axi_in_tvalid(3);
        axi_in_tready(3) <= in_adc4_TREADY;
        in_adc4_TDATA <= axi_in_tdata(DATA_IN_WIDTH*4-1 downto DATA_IN_WIDTH*3);
    end generate;

    -- Connect DAC channels
    axi_out_tdata <= out_dac_TDATA(DATA_OUT_CNT*DATA_OUT_WIDTH - 1 downto 0);
    axi_out_tvalid <= out_dac_TVALID(DATA_OUT_CNT - 1 downto 0);
    
    DAC_CONNECT_TREADY_PARTIAL: if DATA_OUT_CNT < 4 generate
        out_dac_TREADY <= (3 downto DATA_OUT_CNT => '0') & axi_out_tready;
    end generate;
    
    DAC_CONNECT_TREADY_FULL: if DATA_OUT_CNT = 4 generate
        out_dac_TREADY <= axi_out_tready;
    end generate;

    hsl_dsp_inst : hls_dsp
    PORT MAP (
        in_adc1_TVALID  => in_adc1_TVALID,
        in_adc1_TREADY  => in_adc1_TREADY,
        in_adc1_TDATA   => in_adc1_TDATA,
        in_adc1_TKEEP   => "11",
        in_adc1_TSTRB   => "11",
        in_adc1_TLAST   => "0",
        in_adc2_TVALID  => in_adc2_TVALID,
        in_adc2_TREADY  => in_adc2_TREADY,
        in_adc2_TDATA   => in_adc2_TDATA,
        in_adc2_TKEEP   => "11",
        in_adc2_TSTRB   => "11",
        in_adc2_TLAST   => "0",
        in_adc3_TVALID  => in_adc3_TVALID,
        in_adc3_TREADY  => in_adc3_TREADY,
        in_adc3_TDATA   => in_adc3_TDATA,
        in_adc3_TKEEP   => "11",
        in_adc3_TSTRB   => "11",
        in_adc3_TLAST   => "0",
        in_adc4_TVALID  => in_adc4_TVALID,
        in_adc4_TREADY  => in_adc4_TREADY,
        in_adc4_TDATA   => in_adc4_TDATA,
        in_adc4_TKEEP   => "11",
        in_adc4_TSTRB   => "11",
        in_adc4_TLAST   => "0",
        out_dac1_TVALID => out_dac_TVALID(0),
        out_dac1_TREADY => out_dac_TREADY(0),
        out_dac1_TDATA  => out_dac_TDATA(15 downto 0),
        out_dac1_TKEEP  => open,
        out_dac1_TSTRB  => open,
        out_dac1_TLAST  => open,
        out_dac2_TVALID => out_dac_TVALID(1),
        out_dac2_TREADY => out_dac_TREADY(1),
        out_dac2_TDATA  => out_dac_TDATA(31 downto 16),
        out_dac2_TKEEP  => open,
        out_dac2_TSTRB  => open,
        out_dac2_TLAST  => open,
        out_dac3_TVALID => out_dac_TVALID(2),
        out_dac3_TREADY => out_dac_TREADY(2),
        out_dac3_TDATA  => out_dac_TDATA(47 downto 32),
        out_dac3_TKEEP  => open,
        out_dac3_TSTRB  => open,
        out_dac3_TLAST  => open,
        out_dac4_TVALID => out_dac_TVALID(3),
        out_dac4_TREADY => out_dac_TREADY(3),
        out_dac4_TDATA  => out_dac_TDATA(63 downto 48),
        out_dac4_TKEEP  => open,
        out_dac4_TSTRB  => open,
        out_dac4_TLAST  => open,
        in_h2c_TVALID   => axi_h2c_tvalid,
        in_h2c_TREADY   => axi_h2c_tready,
        in_h2c_TDATA    => axi_h2c_tdata,
        in_h2c_TKEEP    => axi_h2c_tkeep,
        in_h2c_TSTRB    => axi_h2c_tstrb,
        in_h2c_TLAST    => axi_h2c_tlast,
        out_c2h_TVALID  => axi_c2h_tvalid,
        out_c2h_TREADY  => axi_c2h_tready,
        out_c2h_TDATA   => axi_c2h_tdata,
        out_c2h_TKEEP   => axi_c2h_tkeep,
        out_c2h_TSTRB   => axi_c2h_tstrb,
        out_c2h_TLAST   => axi_c2h_tlast,
        ap_clk          => clk,
        ap_rst_n        => anrst
  );
end rtl;
