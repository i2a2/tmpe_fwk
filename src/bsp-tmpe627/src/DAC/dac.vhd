-- Copyright (c) TEWS Technologies GmbH.
-- All rights reserved.
-- This Reference Design is protected by copyright laws and is provided exclusively for use with TEWS Technologies products.
-- Reproduction, modification, distribution, or implementation of this Reference Design, in whole or in part, on non-TEWS products is strictly prohibited without prior written permission from TEWS Technologies GmbH.
-- SPDX-License-Identifier: LicenseRef-TEWS-Reference-Design
----------------------------------------------------------------------------------
-- DAC module
--
-- FSM for DAC configuration and data transfer. Reads data from the AXI4-Stream
-- interface and sends it to the DAC.
-- 
-- Based on example by: TEWS Technologies
-- Modified by: David Andrino - I2A2 UPM
-- Date: 12-03-2025
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use ieee.math_real.log2;

entity dac is
    generic (
        CLOCK_FREQUENCY   : integer := 40;    -- System clock frequency / MHz
        DATA_LENGTH       : integer := 24;    -- Number of bits that are transferred over SPI
        SYSTEM_ACCURACY   : integer := 16;    -- Bits that are actually taken from the conversion result
        CHANNELS          : integer := 1      -- Number of DAC channels
    );
    port (
        axi_in_tdata_array      : in  std_logic_vector(16*channels - 1 downto 0) := (others => '0');
        axi_in_tvalid_array     : in  std_logic_vector(channels - 1    downto 0) := (others => '0');
        axi_in_tready_array     : out std_logic_vector(channels - 1    downto 0);
        axi_anrst               : in  std_logic;
        sampling_clk            : in  std_logic := '0';

        config_code       : in  std_logic := '0';
        config_tsd_en     : in  std_logic := '0';
        config_clr_sel    : in  std_logic := '0';
        config_pu_en      : in  std_logic_vector(3 downto 0) := (others => '1');
        config_range      : in  std_logic_vector(2 downto 0) := "000";


        -- Signals to external DAC devices
        dac_sclk          : out std_logic;
        -- dac_clrn          : out std_logic;
        dac_bin2s         : out std_logic;
        dac_sdin          : out std_logic;
        dac_sdo           : in  std_logic;
        dac_syncn         : out std_logic;
        dac_ldacn         : out std_logic;

        -- Clock and Reset
        clock             : in  std_logic     -- User / Config-Clock
    );
end dac;


architecture rtl of dac is

    component ad5754r is
        generic (
            CLOCK_FREQUENCY   : integer := 40;    -- System clock frequency / MHz
            DATA_LENGTH       : integer := 24     -- Number of bits that are transferred over SPI
        );
        port (
            clock             : in  std_logic;

            start             : in  std_logic;
            input_word        : in  std_logic_vector(DATA_LENGTH-1 downto 0);         -- Data to DAC
            output_word       : out std_logic_vector(15 downto 0) := (others => '0'); -- Data from DAC
            load_request      : in  std_logic;          -- Request a DAC load
            busy              : out std_logic := '1';   -- Transmission from/to the DAC is in progress

            sclk              : out std_logic;
            sync_n            : out std_logic := '1';
            sdin              : out std_logic := '1';   -- DAC SDI
            sdo               : in  std_logic;          -- DAC SDO
            ldac_n            : out std_logic := '1'    -- DAC LOAD
        );
    end component;

    component fifo_generator_0
        PORT (
            wr_rst_busy : OUT STD_LOGIC;
            rd_rst_busy : OUT STD_LOGIC;
            s_aclk : IN STD_LOGIC;
            s_aresetn : IN STD_LOGIC;
            s_axis_tvalid : IN STD_LOGIC;
            s_axis_tready : OUT STD_LOGIC;
            s_axis_tdata : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            m_axis_tvalid : OUT STD_LOGIC;
            m_axis_tready : IN STD_LOGIC;
            m_axis_tdata : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
        );
    end component;

    constant DAC_REG_ADR_RANGE : std_logic_vector(7 downto 0) := "00001100";  -- All four DACs output range select
    constant DAC_REG_ADR_POWER : std_logic_vector(7 downto 0) := "00010000";  -- Power control register
    constant DAC_REG_ADR_CNTRL : std_logic_vector(7 downto 0) := "00011001";  -- Control register: TSD/Clamp/CLR/SDO

    type STATE_TYPE is ( IDLE, CONFIG_PU, CONFIG_RNG, CONFIG_CNT, DATA, WAIT_SAMPLING_CLK );

    signal STATE                : STATE_TYPE := IDLE;

    signal dac_input_word       : std_logic_vector(DATA_LENGTH-1 downto 0) := (others => '0');
    signal dac_output_word      : std_logic_vector(15 downto 0) := (others => '0');

    signal busy                 : std_logic;
    signal dac_busy             : std_logic;

    signal dac_start            : std_logic := '0';

    signal output_range_select  : std_logic_vector(2 downto 0) := (others => '0');
    signal output_range         : std_logic_vector(2 downto 0) := (others => '0');
    signal load_dac             : std_logic := '0';

    type START_TYPE is (STARTUP, CLEAR, IDLE);
    signal START_STATE          : START_TYPE := STARTUP;

    signal dac_clrn_int         : std_logic := '1';

    type dac_data_t is array(3 downto 0) of std_logic_vector(15 downto 0);
    signal dac_data     : dac_data_t := (others => (others => '0'));

    signal sampling_clk_T1: std_logic := '0';
    signal sampling_clk_conf: std_logic := '0';

    signal channel_cnt: natural range 0 to 3 := 0;

    signal dac_ref_pu : std_logic := '1';
    
    signal axi_in_tready_array_i : std_logic_vector(CHANNELS - 1 downto 0);

begin


    PHY: ad5754r
        generic map (
            CLOCK_FREQUENCY => CLOCK_FREQUENCY,
            DATA_LENGTH     => DATA_LENGTH    -- Number of bits that are transferred over SPI
        )
        port map (
            clock           => clock,
            start           => dac_start,
            input_word      => dac_input_word,
            output_word     => dac_output_word,
            load_request    => load_dac,
            busy            => busy,
            sclk            => dac_sclk,
            sync_n          => dac_syncn,
            sdin            => dac_sdin,
            sdo             => dac_sdo,
            ldac_n          => dac_ldacn
        );

    dac_busy <= busy or dac_start;

    dac_ref_pu <= config_pu_en(0) or config_pu_en(1) or config_pu_en(2) or config_pu_en(3);

    -- Output range decode (DAC Configuration Register --> AD5745R Output Range)
    -- Select Register
    -- output_range_select <= config_register(6) & config_register(1 downto 0);
    with config_range select
        output_range <= 
            "000" when "000",    -- +  5V
            "001" when "001",    -- + 10V
            "010" when "010",   -- + 10.8V
            "011" when "011" | "100",    -- +- 5V
            "100" when "101",    -- +-10V
            "101" when others;    -- +-10.8V


    -- dac_bin2s <= config_register(5);
    dac_bin2s <= config_code;


    -- State transitions only happen when the DAC is not busy!
    CONTROL_PROC: process (clock)
    begin
        if rising_edge(clock) then
            dac_start <= '0';
            load_dac <= '0';
            if dac_busy = '0' then  -- Only change states when the DAC is not busy transferring data
                case STATE is
                    -- START is active for a single clock pulse.
                    -- We stay in each state until DAC_BUSY is deasserted, which indicates
                    -- that the access to the DAC is done and we can proceed.
                    when IDLE         =>  -- Start around
                        STATE <= CONFIG_RNG;
                    when CONFIG_RNG   =>  -- Build Output Range Select Register
                        dac_input_word <= DAC_REG_ADR_RANGE & x"000" & '0' & output_range;
                        dac_start <= '1';
                        STATE <= CONFIG_PU;
                    when CONFIG_PU    =>  -- Build Power Control Register                       "PU" DAC Power-Up
                        -- dac_input_word <= DAC_REG_ADR_POWER & x"00" & "000" & config_register(2) & config_register(2) & config_register(2) & config_register(2) & config_register(2);
                        dac_input_word <= DAC_REG_ADR_POWER & x"00" & "000" & dac_ref_pu & config_pu_en;
                        dac_start <= '1';
                        STATE <= CONFIG_CNT;
                    when CONFIG_CNT   =>  -- Build Control Register                       TSD Enable  |  Clamp enable | Clear Select | SDO disable
                        dac_input_word <= DAC_REG_ADR_CNTRL & x"000" & config_tsd_en & '1' & config_clr_sel & '0';
                        dac_start <= '1';
                        STATE <= WAIT_SAMPLING_CLK;
                    when WAIT_SAMPLING_CLK    =>  -- Wait for the values
                        load_dac <= '1';
                        channel_cnt <= 0;
                        if sampling_clk_conf = '1' then
                            STATE <= DATA;
                        end if;
                    when DATA        =>  -- Build DAC 1 Data Register
                        -- dac_input_word <= DAC_REG_ADR_DATA1 & dac_data1;--data_buffer_out( 15 downto   0);
                        dac_input_word <= "00000" & std_logic_vector(to_unsigned(channel_cnt, 3)) & dac_data(channel_cnt);
                        dac_start <= '1';
                        channel_cnt <= channel_cnt + 1;
                        if channel_cnt = CHANNELS - 1 then
                            -- STATE <= WAIT_SAMPLING_CLK;
                            STATE <= CONFIG_RNG;
                        end if;
                    when others       =>  STATE <= IDLE;
                end case;
            end if;
        end if;
    end process;

    -- Auto DAC-Clear on startup
    STARTUP_PROC: process (clock)
    begin
        if rising_edge(clock) then
            case START_STATE is
                when STARTUP   => dac_clrn_int <= '1';
                                                    START_STATE <= CLEAR;
                when CLEAR     => dac_clrn_int <= '0';
                                                    START_STATE <= IDLE;
                when IDLE      => dac_clrn_int <= '0';
                when others => null;
            end case;
        end if;
    end process;

    sampling_clk_conf <= sampling_clk and not sampling_clk_T1;
    register_sampling_clk: process (clock) begin
        if rising_edge(clock) then
            sampling_clk_T1 <= sampling_clk;
        end if;
    end process;

    axi_in_tready_array <= axi_in_tready_array_i;
    
    generate_channels: for i in 0 to CHANNELS - 1 generate
    begin
        -- When receiving sampling_clk, try to get one value from queue. If not possible, keep the last value.
        axi_in_tready_array_i(i) <= sampling_clk_conf;
        fifo_dequeue: process (clock) begin
            if rising_edge(clock) then
                if axi_in_tready_array_i(i) = '1' and axi_in_tvalid_array(i) = '1' then
                    dac_data(i) <= axi_in_tdata_array(16*i + 15 downto 16*i);
                end if;
            end if;
        end process;
    end generate;

end rtl;
