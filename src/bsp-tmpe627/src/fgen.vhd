-- Sampling clock generator: self-resetting counter asserting EOC at the end count
-- Author: David Andrino-Izquierdo <david.andrino@upm.es>
-- Copyright: I2A2-UPM 2026
-- SPDX-License-Identifier: Apache-2.0

----------------------------------------------------------------------------------
-- Sampling clock generator
--
-- Self-reset counter with external end count. The EOC signal is asserted for one 
-- clock cycle when the cnt_end value is reached.
--
-- Author: David Andrino - I2A2 UPM
-- Date: 12-03-2025
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity fgen is
    generic (
        cnt_size: integer := 32
    );
    port(
        clk:      in  std_logic;
        cnt_end:  in  std_logic_vector(cnt_size - 1 downto 0);
        eoc:      out std_logic
    );
end entity fgen;

architecture rtl of fgen is
    signal cnt: std_logic_vector(cnt_size - 1 downto 0) := (others => '0');
    signal eoc_i: std_logic := '0';
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if eoc_i = '1' then
                cnt <= (others => '0');
            else
                cnt <= cnt + 1;
            end if;
        end if;
    end process;

    eoc_i <= '1' when cnt >= cnt_end - 1 else '0';
    eoc <= eoc_i;

end architecture rtl;
