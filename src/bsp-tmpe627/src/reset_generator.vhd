-- Free-running domain reset generator: non-resetting counter holding EOC after its final value
-- Author: David Andrino-Izquierdo <david.andrino@upm.es>
-- Copyright: I2A2-UPM 2026
-- SPDX-License-Identifier: Apache-2.0

----------------------------------------------------------------------------------
-- Reset generator
--
-- Reset generator module for free-running clock domain reset. Non-resetting 
-- counter that asserts permanently the EOC signal when the counter reaches the
-- final value.
--
-- Author: David Andrino - I2A2 UPM
-- Date: 12-03-2025
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity reset_generator is
    generic (
        cnt_max: natural := 15 -- 0xF
    );
    port (
        clk: in   std_logic;
        eoc: out  std_logic := '0'
    );
end reset_generator;

architecture rtl of reset_generator is
    signal cnt: std_logic_vector(3 downto 0) := (others => '0');
begin
	IP_RESET_GENERATOR: process (clk)
	begin
		if rising_edge(clk) then
			if cnt = cnt_max then
				eoc <= '1';
			else
				cnt <= cnt + 1;
			end if;
		end if;
	end process;
end rtl;
