-- IBUFGDS wrapper exposing the differential gigabit-transceiver clock to the block design
-- Author: David Andrino-Izquierdo <david.andrino@upm.es>
-- Copyright: I2A2-UPM 2026
-- SPDX-License-Identifier: Apache-2.0

----------------------------------------------------------------------------------
-- Clock Buffer
--
-- Clock buffer for using a IBUFGDS in the Block Design. Wrapper around the 
-- primitive for differential clock from the Gigabit Transceivers.
--
-- Author: David Andrino - I2A2 UPM
-- Date: 12-03-2025
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity clock_buffer is
    Port ( I : in STD_LOGIC;
           IB : in STD_LOGIC;
           O : out STD_LOGIC);
end clock_buffer;

architecture rtl of clock_buffer is
begin
CLK_INST: IBUFDS_GTE2
	generic map (
		CLKCM_CFG => true,
		CLKRCV_TRST => true,
		CLKSWING_CFG => b"11"
	)
	port map (
		O => O,
		CEB => '0',
		I => I,
		IB => IB
	);

end rtl;
