-- Copyright (c) TEWS Technologies GmbH.
-- All rights reserved.
-- This Reference Design is protected by copyright laws and is provided exclusively for use with TEWS Technologies products.
-- Reproduction, modification, distribution, or implementation of this Reference Design, in whole or in part, on non-TEWS products is strictly prohibited without prior written permission from TEWS Technologies GmbH.
-- SPDX-License-Identifier: LicenseRef-TEWS-Reference-Design
-- --------------------------------------------------------------------------------------------- --
--                                       TEWS TECHNOLOGIES                                       --
-- --------------------------------------------------------------------------------------------- --
--
--   Project Name    : 
--   Module Name     : ad5754r.vhd
--   Target Device   : Artix-7 XC7A50T-2CSG325I
--   Design Tool     : Xilinx Vivado 2016.1
--   Simulation Tool : XSIM
--
--   Description     : Analog Devices AD5754R physical interface
--
--   Owner           : TEWS TECHNOLOGIES GmbH
--                     Am Bahnhof 7
--                     D-25469 Halstenbek
--
--                     Tel.: +49 / (0)4101 / 4058-0
--                     Fax.: +49 / (0)4101 / 4058-19
--                     e-mail: support@tews.com
--
--                     Copyright (c) 2016
--                     TEWS TECHNOLOGIES GmbH
--
--   Description     : AD5745R control module
--
--   History         :
--       Version 1   : (RR, 19.09.2011)
--                     Initial Version
--       Version 2   : (RR, 04.02.2014)
--                     After initial operation
--       Version 3   : (RR, 02.06.2016)
--                     Adaption for higher clock frequencies
--                     SCLK generation is moved to here
--       Version 4   : (RR, 08.11.2016)
--                     Changed PULSE_WIDTH generic from "time" to "integer", because Vivado
--                     doesn't properly support VHDL Time data Type (AR# 57964)
--
--   Comments        : 
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity ad5754r is
  generic (
    CLOCK_FREQUENCY   : integer := 40;          -- System clock frequency / MHz
    DATA_LENGTH       : integer := 24           -- Number of bits that are transferred over SPI
  );
  port (
    clock             : in  std_logic;

    start             : in  std_logic;
    input_word        : in  std_logic_vector(DATA_LENGTH-1 downto 0);           -- Data to DAC
    output_word       : out std_logic_vector(15 downto 0) := (others => '0');   -- Data from DAC
    load_request      : in  std_logic;          -- Request a DAC load
    busy              : out std_logic := '0';   -- Transmission from/to the DAC is in progress

    sclk              : out std_logic := '1';
    sync_n            : out std_logic := '1';
    sdin              : out std_logic := '1';   -- DAC SDI
    sdo               : in  std_logic;          -- DAC SDO
    ldac_n            : out std_logic := '1'    -- DAC LOAD
  );
end ad5754r;


architecture rtl of ad5754r is


  component pulse_stretcher is
    generic (
      CLOCK_FREQUENCY   : integer := 40;        -- Clock frequency in MHz
      PULSE_WIDTH       : integer := 50;        -- Required pulse width for pulse_out in ns
      POLARITY          : string  := "POSITIVE" -- Logic polarity < POSITIVE | NEGATIVE >
    );
    port (
      pulse_in          : in  std_logic;
      pulse_out         : out std_logic;
      clock             : in  std_logic
    );
  end component;


  -- Timings for minimum pulse length
--constant t6               : time := 100 ns;   -- Minimum SYNC high time, write mode
  constant t10              : integer := 130;-- ns;   -- Minimum SYNC# rising edge to LDAC# falling edge
  constant t11              : integer :=  20;-- ns;   -- LDAC# pulse width low
  constant t17              : integer := 200;-- ns;   -- Minimum SYNC high time, read mode


  -- DAC parameters
  constant MAX_SCLK_FREQUENCY: integer := 30;   -- Maximum SCLK frequency / MHz
--constant MAX_SCLK_FREQUENCY: integer := 10;   -- Maximum SCLK frequency / MHz for Readback / Daisy-Chain
  constant CLOCK_DIVIDE      : integer := (CLOCK_FREQUENCY / MAX_SCLK_FREQUENCY); -- Calculate clock divider


  type STATE_TYPE is (IDLE, SYNC, SHIFT, READ_DATA);
  signal STATE              : STATE_TYPE := IDLE;

  signal shift_in_counter   : integer range 0 to DATA_LENGTH-1 := 0;
  signal shift_out_counter  : integer range 0 to DATA_LENGTH-1 := 0;
  signal shift_in           : std_logic_vector(output_word'length-1 downto 0) := (others => '0');
  signal shift_out          : std_logic_vector(DATA_LENGTH-1 downto 0) := (others => '0');
  signal load_input_word    : std_logic := '0';
  signal internal_sync_n    : std_logic := '1';
  signal delayed_sync_n     : std_logic := '1';
  signal load_dac_wait      : std_logic := '0';
  signal ldac_n_i           : std_logic := '1';
  signal enable_shift_in_n  : std_logic;
  signal enable_shift_out_n : std_logic;

  signal clock_enable       : std_logic := '0';


begin


  -- Clock divider.
  -- Included is a clock enable signal, that is set one clock period before
  -- the rising edge of SCLK.
  process(clock)
    variable count : natural range 0 to CLOCK_DIVIDE := 0;
  begin
    if rising_edge(clock) then
      clock_enable <= '0';

      if count = CLOCK_DIVIDE/2 then
        sclk <= '1';
        count := count + 1;
      elsif count = CLOCK_DIVIDE then
        sclk <= '0';
        count := 0;
      else
        count := count + 1;
      end if;

      -- Since COUNT is a variable and was incremented before this compare,
      -- this is effectively a compare against (CLOCK_DIVIDE/2)+1
      if count = CLOCK_DIVIDE/2 then
        clock_enable <= '1';
      end if;

    end if;
  end process;


  -- This is the central control process for the SPI interface to the DAC.
  -- The LOAD-signal is controlled elsewhere.
  CONTROL_PROC: process (clock)
  begin
    if rising_edge(clock) then
      case STATE is
        when IDLE      => -- Idle state
                          output_word <= shift_in;
                          internal_sync_n <= '1';
                          load_input_word <= '0';
                          busy <= '0';
                          if start = '1' then
                            busy <= '1';
                            load_input_word <= '1';
                            STATE <= SYNC;
                          end if;
        when SYNC      => -- Sync with SCLK
                          load_input_word <= '0';
                          if clock_enable = '1' and delayed_sync_n = '1' then
                            internal_sync_n <= '0';
                            STATE <= SHIFT;
                          end if;
        when SHIFT     => if shift_out_counter = DATA_LENGTH-1 then
                            STATE <= READ_DATA;
                          end if;
        when READ_DATA => -- Sync with SCLK
                          if clock_enable = '1' then
                            internal_sync_n <= '1';
                            if delayed_sync_n = '1' then  -- Wait for minimum SYNC time
                              STATE <= IDLE;
                            end if;
                          end if;
        when others => null;
      end case;
    end if;
  end process;


  -- AD5754 SDIN: Data must be valid on the falling edge of SCLK
  enable_shift_out_n <= internal_sync_n;  -- Enable output shift when sync is low
  
  SHIFT_OUT_PROC: process (clock)
  begin
    if rising_edge(clock) then
      if load_input_word = '1' then
        shift_out <= input_word;
        shift_out_counter <= 0;
      elsif clock_enable = '1' then
        if enable_shift_out_n = '0' then
          shift_out <= shift_out(shift_out'left-1 downto 0) & shift_out(shift_out'left);
          if shift_out_counter = DATA_LENGTH-1 then
            shift_out_counter <= 0;
          else
            shift_out_counter <= shift_out_counter + 1;
          end if;
        end if;
      end if;
    end if;
  end process;

  sdin <= shift_out(shift_out'left);


  enable_shift_in_n <= internal_sync_n;
  -- AD5754 SDO: Data is clocked out on the rising edge of SCLK and is valid on
  -- the falling edge of SCLK
  SHIFT_IN_PROC: process (clock)
  begin
    if rising_edge(clock) then
      if clock_enable = '1' then
        if enable_shift_in_n = '0' then
          shift_in <= shift_in(shift_in'left-1 downto 0) & sdo;
          if shift_in_counter = DATA_LENGTH-1 then
            shift_in_counter <= 0;
          else
            shift_in_counter <= shift_in_counter + 1;
          end if;
        else
          shift_in_counter <= 0;
        end if;
      end if;
    end if;
  end process;


  -- Check LDAC to SYNC timing
--  process (clock)
--  begin
--    if rising_edge(clock) then
--      ldac_n_i <= '1';
--      if load_request = '1' then
--        if delayed_sync_n = '1' then  -- If LDAC to SYNC timing is ok
--          ldac_n_i <= '0';            -- load the DAC
--        else
--          load_dac_wait <= '1';       -- else wait until the timing is ok
--        end if;
--      end if;
--      if load_dac_wait = '1' then
--        if delayed_sync_n = '1' then  -- Timing is ok now
--          ldac_n_i <= '0';            -- load the DAC
--          load_dac_wait <= '0';
--        end if;
--      end if;
--    end if;
--  end process;
  ldac_n_i <= not load_request;


  PS_SYNC: pulse_stretcher
  generic map
  (
    CLOCK_FREQUENCY => CLOCK_FREQUENCY,
    PULSE_WIDTH     => t17,          -- Use "Minimum SYNC high time, read mode" instead of
    POLARITY        => "NEGATIVE"     -- "SYNC# rising edge to LDAC# falling edge"
  )
  port map
  (
    pulse_in        => internal_sync_n,
    pulse_out       => delayed_sync_n,
    clock           => clock
  );

  sync_n <= internal_sync_n;

  
  PS_LDAC: pulse_stretcher
  generic map
  (
    CLOCK_FREQUENCY => CLOCK_FREQUENCY,
    PULSE_WIDTH     => t11,           -- LDAC# pulse width low
    POLARITY        => "NEGATIVE"
  )
  port map
  (
    pulse_in        => ldac_n_i,
    pulse_out       => ldac_n,
    clock           => clock
  );
  
  
end rtl;
