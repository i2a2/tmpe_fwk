-- Copyright (c) TEWS Technologies GmbH.
-- All rights reserved.
-- This Reference Design is protected by copyright laws and is provided exclusively for use with TEWS Technologies products.
-- Reproduction, modification, distribution, or implementation of this Reference Design, in whole or in part, on non-TEWS products is strictly prohibited without prior written permission from TEWS Technologies GmbH.
-- SPDX-License-Identifier: LicenseRef-TEWS-Reference-Design
-- --------------------------------------------------------------------------------------------- --
--                                       TEWS TECHNOLOGIES                                       --
-- --------------------------------------------------------------------------------------------- --
--
--   Project Name    : -
--   File Name       : pulse_stretcher.vhd
--   Target Device   : 
--   Design Tool     : Vivado 2016.3
--   Simulation Tool : XSIM
--
--   Description     : This component stretches pulses
--
--   Owner           : TEWS TECHNOLOGIES GmbH
--                     Am Bahnhof 7
--                     D-25469 Halstenbek
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity pulse_stretcher is
  generic (
    CLOCK_FREQUENCY   : integer := 40;          -- Clock frequency in MHz
    PULSE_WIDTH       : integer := 50;          -- Required pulse width for pulse_out in ns
    OUTPUT_INIT       : std_logic := '0';
    POLARITY          : string  := "POSITIVE"   -- Logic polarity < POSITIVE | NEGATIVE >
  );
  port (
    pulse_in          : in  std_logic;
    pulse_out         : out std_logic := OUTPUT_INIT;
    clock             : in  std_logic
  );
end pulse_stretcher;


architecture behavioral of pulse_stretcher is


  constant CLOCK_PERIOD       : integer := 1000 / CLOCK_FREQUENCY;  -- = ns

  -- Calculate the number of clock pulses need to cover the PULSE_WIDTH. Add
  -- one clock pulse to cover a possible remainder of the division.
  constant NO_OF_CLOCK_PULSES : integer := (PULSE_WIDTH / CLOCK_PERIOD) + 1;


  signal pulse_counter        : integer range 0 to NO_OF_CLOCK_PULSES := 0;


begin


  pos: if POLARITY = "POSITIVE" generate
  begin

    -- Stretch PULSE_IN for NO_OF_CLOCK_PULSES-1
    process(clock)
    begin
      if rising_edge(clock) then
        if pulse_in = '1' then
          pulse_out <= '1';
          pulse_counter <= NO_OF_CLOCK_PULSES-1;
        else
          if pulse_counter = 0 then
            pulse_out <= '0';
          else
            pulse_counter <= pulse_counter - 1;
          end if;
        end if;
      end if;
    end process;

  end generate;


  neg: if POLARITY = "NEGATIVE" generate
  begin

    -- Stretch PULSE_IN for NO_OF_CLOCK_PULSES-1
    process(clock)
    begin
      if rising_edge(clock) then
        if pulse_in = '0' then
          pulse_out <= '0';
          pulse_counter <= NO_OF_CLOCK_PULSES-1;
        else
          if pulse_counter = 0 then
            pulse_out <= '1';
          else
            pulse_counter <= pulse_counter - 1;
          end if;
        end if;
      end if;
    end process;

  end generate;


end behavioral;
