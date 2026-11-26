-- Copyright (c) TEWS Technologies GmbH.
-- All rights reserved.
-- This Reference Design is protected by copyright laws and is provided exclusively for use with TEWS Technologies products.
-- Reproduction, modification, distribution, or implementation of this Reference Design, in whole or in part, on non-TEWS products is strictly prohibited without prior written permission from TEWS Technologies GmbH.
-- SPDX-License-Identifier: LicenseRef-TEWS-Reference-Design
----------------------------------------------------------------------------------
-- ADC module
--
-- Base module for ADC management. Controls ADC configuration and instantiates
-- channel modules based on a generic parameter.
-- 
-- Based on example by: TEWS Technologies
-- Modified by: David Andrino - I2A2 UPM
-- Date: 12-03-2025
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adc is
    generic (
        ACTIVE_CHANNELS     : integer := 4          -- Number of active channels (max 8)
    );
    port (
        clock               : in  std_logic;
        anrst               : in  std_logic;
        adc_power_down      : in  std_logic;

        -- I/O signals
        lvds_cmos_n         : out std_logic := '0';
        pd                  : out std_logic := '0';
        cs_n                : out std_logic := '0';
        cnv                 : out std_logic := '0';
        busy                : in  std_logic;
        scki                : out std_logic := '0';
        sdi                 : out std_logic := '0';
        -- scko                : in  std_logic;
        sdo0                : in  std_logic;
        sdo1                : in  std_logic;
        sdo2                : in  std_logic;
        sdo3                : in  std_logic;
        sdo4                : in  std_logic;
        sdo5                : in  std_logic;
        sdo6                : in  std_logic;
        sdo7                : in  std_logic;

        ena_conv            : in  std_logic;

        axi_array_tdata      : out std_logic_vector(16*ACTIVE_CHANNELS - 1 downto 0); -- TODO: Cambiar a 32
        axi_array_tvalid     : out std_logic_vector(ACTIVE_CHANNELS - 1 downto 0) := (others => '0');
        axi_array_tready     : in  std_logic_vector(ACTIVE_CHANNELS - 1 downto 0);

        softspan           : in  std_logic_vector(23 downto 0) := O"44444444"
    );
end entity adc;

architecture behave of adc is

    component adc_channel is
        port(
            clk:            in  std_logic;
            anrst:          in  std_logic;
            scki:           in  std_logic;
            sdo:            in  std_logic;
            shift_ena:      in  std_logic;
            finished_conv:  in  std_logic;

            m_axi_data:     out std_logic_vector(15 downto 0); -- TODO: Cambiar a 32
            m_axi_valid:    out std_logic;
            m_axi_ready:    in  std_logic
        );
    end component;

    signal sdo_array          : std_logic_vector(7 downto 0) := (others => '0');

    type   STATE_TYPE is (IDLE, TICK, TOCK, WAITING, CONVERT, ADC_PD);
    signal STATE              : STATE_TYPE := IDLE;

    signal busy_i             : std_logic := '0';
    signal busy_q             : std_logic := '0';

    signal count              : integer range 0 to 24 := 0;

    signal scki_i             : std_logic := '0';
    signal sample_enable      : std_logic := '0';
    signal shift_ena          : std_logic := '0';
    signal finished_conversion: std_logic := '0';

    signal shift_out          : std_logic_vector(23 downto 0) := O"44444444";

    -- attribute dont_touch : string;
    -- attribute dont_touch of shift_out: signal is "true"

begin
    -- Data vectorization
    sdo_array <= (sdo7, sdo6, sdo5, sdo4, sdo3, sdo2, sdo1, sdo0);

    -- Static signals
    lvds_cmos_n <= '0';   -- Fixed CMOS interface
    cs_n        <= '0';   -- Always select ADC
    scki <= scki_i;

    -- Synchronize BUSY
    process (clock)
    begin
        if rising_edge(clock) then
        busy_i <= busy;
        busy_q <= busy_i;
        end if;
    end process;

    -- Main control state machine
    process (clock)
    begin
        if rising_edge(clock) then
            case STATE is
                when IDLE  => -- Idle State
                            cnv  <= '0';
                            count <= 0;
                            scki_i <= '0';
                            if busy_q = '0' then
                                STATE <= TICK;
                                sample_enable <= '1';
                                sdi  <= shift_out(23);
                            else
                                shift_out <= softspan;
                                sdi  <= '0';
                            end if;
                when TICK  => -- SCKI low, SDI output
                            shift_out <= shift_out(22 downto 0) & '0';
                            count <= count + 1;
                            scki_i <= '1';
                            STATE <= TOCK;
                when TOCK  => -- SCKI high, SDI latch on ADC
                            if count = 24 then
                                STATE <= WAITING;
                                scki_i <= '0';
                                sdi  <= '0';
                                sample_enable <= '0';
                                finished_conversion <= '1';
                            else
                                STATE <= TICK;
                                scki_i <= '0';
                                sdi  <= shift_out(23);
                            end if;
                when WAITING => -- Waiting for the convert order
                            finished_conversion <= '0';
                            if ena_conv = '1' then
                                STATE <= CONVERT;
                                cnv <= '1';
                            end if;
                when CONVERT => -- ADC Convert
                            if busy_q = '1' then
                                STATE <= ADC_PD;
                            end if;
                when ADC_PD  => -- Check for ADC power down
                            cnv <= '0';
                            pd  <= adc_power_down;
                            if adc_power_down = '0' then
                                STATE <= IDLE;
                            end if;
            end case;
        end if;
    end process;

    shift_ena <= sample_enable and not scki_i; -- Sample in rising edge

    ADC_CHANNELS: for i in 0 to ACTIVE_CHANNELS - 1 generate
        adc_channel_inst : adc_channel
            port map (
                clk             => clock,
                anrst           => anrst,
                sdo             => sdo_array(2*i),
                scki            => scki_i,
                shift_ena       => shift_ena,
                finished_conv   => finished_conversion,
                m_axi_data      => axi_array_tdata(16*(i+1)-1 downto 16*i),
                m_axi_valid     => axi_array_tvalid(i),
                m_axi_ready     => axi_array_tready(i)
            );
    end generate;

end architecture behave;
