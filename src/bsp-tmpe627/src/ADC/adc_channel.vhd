-- Copyright (c) TEWS Technologies GmbH.
-- All rights reserved.
-- This Reference Design is protected by copyright laws and is provided exclusively for use with TEWS Technologies products.
-- Reproduction, modification, distribution, or implementation of this Reference Design, in whole or in part, on non-TEWS products is strictly prohibited without prior written permission from TEWS Technologies GmbH.
-- SPDX-License-Identifier: LicenseRef-TEWS-Reference-Design
----------------------------------------------------------------------------------
-- ADC Channel module
--
-- Cell for each ADC Channel. Reads samples and sends them through AXI4-Stream 
-- interface.
-- 
-- Based on example by: TEWS Technologies
-- Modified by: David Andrino - I2A2 UPM
-- Date: 12-03-2025
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity adc_channel is
    port(
        clk:            in  std_logic;
        scki:           in  std_logic;
        anrst:          in  std_logic;
        sdo:            in  std_logic;
        shift_ena:      in  std_logic;
        finished_conv:  in  std_logic;

        m_axi_data:     out std_logic_vector(15 downto 0);
        m_axi_valid:    out std_logic;
        m_axi_ready:    in std_logic
    );
end entity;

architecture rtl of adc_channel is
    signal m_axi_valid_i: std_logic := '0';
    signal shift_in: std_logic_vector(23 downto 0) := (others => '0');
begin
    -- Input shift registers
    process (clk)
    begin
        if rising_edge(clk) then
            if shift_ena = '1' and scki = '0' then
                shift_in <= shift_in(22 downto 0) & sdo;
            end if;
        end if;
    end process;
  
    m_axi_valid <= m_axi_valid_i;
  
    -- AXI4-Stream interface
    process(clk)
    begin
        if rising_edge(clk) then
            -- Master cannot deassert tvalid. Only one sample is transferred, so they are replaced if not accepted
            if m_axi_valid_i = '1' and m_axi_ready = '1' then 
                m_axi_valid_i <= '0';
            elsif finished_conv = '1' then
                m_axi_valid_i <= '1';
                m_axi_data <= shift_in(23 downto 8);
            end if;
        end if;
    end process;

end architecture rtl;
