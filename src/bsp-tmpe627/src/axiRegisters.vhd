-- AXI4-Lite DAQ configuration register file with outputs synchronised to the dst_clk domain
-- Author: David Andrino-Izquierdo <david.andrino@upm.es>
-- Copyright: I2A2-UPM 2026
-- SPDX-License-Identifier: Apache-2.0

----------------------------------------------------------------------------------
-- AXI Registers
--
-- Register interface for DAQ configuration. Written by the AXI4Lite interface.
--
-- Inputs are in the AXI4Lite clock domain, but outputs are synchronized to the
-- dst_clk domain.
-- 
-- Author: David Andrino - I2A2 UPM
-- Date: 12-03-2025
----------------------------------------------------------------------------------
-- Address space:
-- Reg 0 = sampling_eoc (32 bits)
-- Reg 1 = adc_pd (1 bit) + padding + adc_softspan[4] (12 bits)
-- Reg 2 = dac_pd (4 bit) + dac_code (1bit) + dac_clr_sel (1bit) 
--       + dac_tsd_ena (1bit) + padding + dac_range (3 bits)
-- Reg 3 = padding + ena_c2h_dma (1bit)
--
-- ADC and DAC ranges:
-- | Range | ADC     | DAC    |
-- |-------|---------| -------|
-- | 0     |   +5.12 |     +5 |
-- | 1     |     +10 |    +10 |
-- | 2     |  +10.24 |  +10.8 |
-- | 3     |     +-5 |    +-5 |
-- | 4     |  +-5.12 |    +-5 |
-- | 5     |    +-10 |   +-10 |
-- | 6     | +-10.24 | +-10.8 |
-- | 7     | +-10.24 | +-10.8 |
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library xpm;
use xpm.vcomponents.all;

library desyrdl;
use desyrdl.common.all;

use work.pkg_bsp_tmpe627.all;

entity axiRegisters is
        generic (
                -- Width of S_AXI data bus
                C_S_AXI_DATA_WIDTH	: integer	:= 32;
                -- Width of S_AXI address bus
                C_S_AXI_ADDR_WIDTH	: integer	:= 6;

                -- Users to add parameters here
                SAMPLING_EOC_INITIAL_VALUE : std_logic_vector(32 - 1 downto 0) := x"000003E8"; -- 1000 for 100 kHz

                ADC_SOFTSPAN_INITIAL_VALUE : std_logic_vector(2 downto 0) := o"5"; -- 101 for [0, 10] V
                ADC_POWERDOWN_INITIAL_VALUE : std_logic := '0';

                DAC_RANGE_INITIAL_VALUE : std_logic_vector(2 downto 0) := o"5"; -- 101 for [0, 10] V
                DAC_PD_INITIAL_VALUE : std_logic_vector(3 downto 0) := x"0";
                DAC_CODE_INITIAL_VALUE : std_logic := '0';
                DAC_CLR_SEL_INITIAL_VALUE : std_logic := '0';
                DAC_TSD_ENA_INITIAL_VALUE : std_logic := '1';
                DSP_ENA_C2H_INITIAL_VALUE  : std_logic := '0'
                
                -- User parameters ends
        );
        port (
                -- Users to add ports here
                dst_clk : in std_logic;
                sampling_eoc  : out std_logic_vector(C_S_AXI_DATA_WIDTH - 1  downto 0);
                adc_powerdown : out std_logic;
                adc_softspan  : out std_logic_vector(23 downto 0);
                dac_code      : out std_logic;
                dac_range     : out std_logic_vector(2 downto 0);
                dac_tsd_ena   : out std_logic;
                dac_powerup   : out std_logic_vector(3 downto 0);
                dac_clr_sel   : out std_logic; -- TODO: Check if should be removed, as CLR is not used in the DAC
                dsp_ena_c2h   : out std_logic;

                -- User ports endins
                -- Do not modify the ports beyond this line

                -- Global Clock Signal
                S_AXI_ACLK	: in std_logic;
                -- Global Reset Signal. This Signal is Active LOW
                S_AXI_ARESETN	: in std_logic;
                -- Write address (issued by master, acceped by Slave)
                S_AXI_AWADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
                -- Write channel Protection type. This signal indicates the
                        -- privilege and security level of the transaction, and whether
                        -- the transaction is a data access or an instruction access.
                S_AXI_AWPROT	: in std_logic_vector(2 downto 0);
                -- Write address valid. This signal indicates that the master signaling
                        -- valid write address and control information.
                S_AXI_AWVALID	: in std_logic;
                -- Write address ready. This signal indicates that the slave is ready
                        -- to accept an address and associated control signals.
                S_AXI_AWREADY	: out std_logic;
                -- Write data (issued by master, acceped by Slave) 
                S_AXI_WDATA	: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
                -- Write strobes. This signal indicates which byte lanes hold
                        -- valid data. There is one write strobe bit for each eight
                        -- bits of the write data bus.    
                S_AXI_WSTRB	: in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
                -- Write valid. This signal indicates that valid write
                        -- data and strobes are available.
                S_AXI_WVALID	: in std_logic;
                -- Write ready. This signal indicates that the slave
                        -- can accept the write data.
                S_AXI_WREADY	: out std_logic;
                -- Write response. This signal indicates the status
                        -- of the write transaction.
                S_AXI_BRESP	: out std_logic_vector(1 downto 0);
                -- Write response valid. This signal indicates that the channel
                        -- is signaling a valid write response.
                S_AXI_BVALID	: out std_logic;
                -- Response ready. This signal indicates that the master
                        -- can accept a write response.
                S_AXI_BREADY	: in std_logic;
                -- Read address (issued by master, acceped by Slave)
                S_AXI_ARADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
                -- Protection type. This signal indicates the privilege
                        -- and security level of the transaction, and whether the
                        -- transaction is a data access or an instruction access.
                S_AXI_ARPROT	: in std_logic_vector(2 downto 0);
                -- Read address valid. This signal indicates that the channel
                        -- is signaling valid read address and control information.
                S_AXI_ARVALID	: in std_logic;
                -- Read address ready. This signal indicates that the slave is
                        -- ready to accept an address and associated control signals.
                S_AXI_ARREADY	: out std_logic;
                -- Read data (issued by slave)
                S_AXI_RDATA	: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
                -- Read response. This signal indicates the status of the
                        -- read transfer.
                S_AXI_RRESP	: out std_logic_vector(1 downto 0);
                -- Read valid. This signal indicates that the channel is
                        -- signaling the required read data.
                S_AXI_RVALID	: out std_logic;
                -- Read ready. This signal indicates that the master can
                        -- accept the read data and response information.
                S_AXI_RREADY	: in std_logic
        );
end;

architecture arch_imp of axiRegisters is
        component bsp_tmpe627 is
          port (
            pi_clock : in std_logic;
            pi_reset : in std_logic;
            -- TOP subordinate memory mapped interface
            pi_s_reset : in std_logic := '0';
            pi_s_top   : in  t_bsp_tmpe627_m2s;
            po_s_top   : out t_bsp_tmpe627_s2m;
            -- to logic interface
            pi_addrmap : in  t_addrmap_bsp_tmpe627_in;
            po_addrmap : out t_addrmap_bsp_tmpe627_out
          );
        end component bsp_tmpe627;
        signal po_addrmap : t_addrmap_bsp_tmpe627_out;
        signal pi_addrmap : t_addrmap_bsp_tmpe627_in;
        signal sampling_eoc_reg_0, adc_ctrl_reg_1, dac_ctrl_reg_2, dsp_ctrl_reg_3,
                slv_reg4_sync, slv_reg5_sync, slv_reg6_sync, slv_reg7_sync, slv_reg8_sync, 
                slv_reg9_sync, slv_reg10_sync, slv_reg11_sync, slv_reg12_sync, slv_reg13_sync, 
                slv_reg14_sync, slv_reg15_sync : std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);

        signal adc_softspan_aux : std_logic_vector(11 downto 0) := (others => '0');
        signal pi_s_top: t_bsp_tmpe627_m2s;
        signal po_s_top: t_bsp_tmpe627_s2m;
begin

        generatedRegs: bsp_tmpe627
        port map(
                pi_clock => S_AXI_ACLK,
                pi_reset => not S_AXI_ARESETN,
                pi_s_reset => '0',
                pi_s_top => pi_s_top,
                po_s_top => po_s_top,
                pi_addrmap => pi_addrmap,
                po_addrmap => po_addrmap
        );

        cdc_synchronization: block 
            signal reg_concat, reg_sync : std_logic_vector((C_S_AXI_DATA_WIDTH * 16) - 1 downto 0);
            signal ena_sample_regs : std_logic := '0';
            signal src_send : std_logic := '0';
            signal src_rcv : std_logic := '0';

            signal src_rcv_t1 : std_logic := '0';
        begin
            ena_sample_regs <= src_rcv_t1 and not src_rcv; -- Falling edge detection

            process(S_AXI_ACLK)
            begin
                if rising_edge(S_AXI_ACLK) then
                    src_rcv_t1 <= src_rcv;
                end if;
            end process;

            -- Cannot use not ena_sample_regs and not src_rcv_t1 because src_rcv starts as 'X' on simulation until first synchronization 
            src_send <= '1' when ena_sample_regs /= '1' and src_rcv_t1 /= '1' and S_AXI_ARESETN = '1' else '0';

            S_AXI_AWREADY <= po_s_top.awready;
            S_AXI_WREADY  <= po_s_top.wready;
            S_AXI_BRESP   <= po_s_top.bresp;
            S_AXI_BVALID  <= po_s_top.bvalid;
            S_AXI_ARREADY <= po_s_top.arready;
            S_AXI_RDATA   <= po_s_top.rdata;
            S_AXI_RRESP   <= po_s_top.rresp;
            S_AXI_RVALID  <= po_s_top.rvalid;

            pi_s_top.awaddr  <= (31 downto 6 => '0') & S_AXI_AWADDR;
            pi_s_top.awprot  <= S_AXI_AWPROT;
            pi_s_top.awvalid <= S_AXI_AWVALID;
            pi_s_top.wdata   <= S_AXI_WDATA;
            pi_s_top.wstrb   <= S_AXI_WSTRB;
            pi_s_top.wvalid  <= S_AXI_WVALID;
            pi_s_top.bready  <= S_AXI_BREADY;
            pi_s_top.araddr  <= (31 downto 6 => '0') & S_AXI_ARADDR;
            pi_s_top.arprot  <= S_AXI_ARPROT;
            pi_s_top.arvalid <= S_AXI_ARVALID;
            pi_s_top.rready  <= S_AXI_RREADY;

            process (S_AXI_ACLK, S_AXI_ARESETN)
            begin
                if S_AXI_ARESETN = '0' then
                    reg_concat <= (others => '0');
                elsif rising_edge(S_AXI_ACLK) then
                    if ena_sample_regs = '1' then
                        reg_concat <= (511 downto 97 => '0')           &
                                po_addrmap.C2H_ENA.E.data              & 
                                po_addrmap.DAC_CONFIG.PD3.data         &
                                po_addrmap.DAC_CONFIG.PD2.data         & 
                                po_addrmap.DAC_CONFIG.PD1.data         & 
                                po_addrmap.DAC_CONFIG.PD0.data         & 
                                po_addrmap.DAC_CONFIG.Code.data        & 
                                po_addrmap.DAC_CONFIG.CLR_Sel.data     & 
                                po_addrmap.DAC_CONFIG.TSD_Ena.data     & 
                                po_addrmap.DAC_CONFIG.Padding.data     & 
                                po_addrmap.DAC_CONFIG.DACRange.data    & 
                                po_addrmap.ADC_CONFIG.PD.data          & 
                                po_addrmap.ADC_CONFIG.Padding.data     &
                                po_addrmap.ADC_CONFIG.SoftspanCH3.data & 
                                po_addrmap.ADC_CONFIG.SoftspanCH2.data & 
                                po_addrmap.ADC_CONFIG.SoftspanCH1.data & 
                                po_addrmap.ADC_CONFIG.SoftspanCH0.data & 
                                po_addrmap.SAMP_EOC.eoc.data;
                    end if;
                end if;
            end process;

            xpm_cdc_handshake_inst : xpm_cdc_handshake
            generic map (
                DEST_EXT_HSK => 0,   -- DECIMAL; 0=internal handshake, 1=external handshake
                DEST_SYNC_FF => 4,   -- DECIMAL; range: 2-10
                INIT_SYNC_FF => 0,   -- DECIMAL; 0=disable simulation init values, 1=enable simulation init values
                SIM_ASSERT_CHK => 0, -- DECIMAL; 0=disable simulation messages, 1=enable simulation messages
                SRC_SYNC_FF => 4,    -- DECIMAL; range: 2-10
                WIDTH => C_S_AXI_DATA_WIDTH*16-- DECIMAL; range: 1-1024
            )
            port map (
                dest_out => reg_sync,
                dest_req => open, -- TODO: Check if this should be checked, because the output is supposedly registered
                src_rcv => src_rcv,
                dest_ack => '0', -- Unused because DEST_EXT_HSK = 0
                dest_clk => dst_clk,
                src_clk => S_AXI_ACLK,
                src_in => reg_concat, -- WIDTH-bit input: Input bus that will be synchronized to the destination clock
                src_send => src_send
            );

            sampling_eoc_reg_0  <= reg_sync(1*C_S_AXI_DATA_WIDTH - 1 downto 0);
            adc_ctrl_reg_1  <= reg_sync(2*C_S_AXI_DATA_WIDTH - 1 downto 1*C_S_AXI_DATA_WIDTH);
            dac_ctrl_reg_2  <= reg_sync(3*C_S_AXI_DATA_WIDTH - 1 downto 2*C_S_AXI_DATA_WIDTH);
            dsp_ctrl_reg_3  <= reg_sync(4*C_S_AXI_DATA_WIDTH - 1  downto 3*C_S_AXI_DATA_WIDTH);
            slv_reg4_sync  <= reg_sync(5*C_S_AXI_DATA_WIDTH - 1  downto 4*C_S_AXI_DATA_WIDTH);
            slv_reg5_sync  <= reg_sync(6*C_S_AXI_DATA_WIDTH - 1  downto 5*C_S_AXI_DATA_WIDTH);
            slv_reg6_sync  <= reg_sync(7*C_S_AXI_DATA_WIDTH - 1  downto 6*C_S_AXI_DATA_WIDTH);
            slv_reg7_sync  <= reg_sync(8*C_S_AXI_DATA_WIDTH - 1  downto 7*C_S_AXI_DATA_WIDTH);
            slv_reg8_sync  <= reg_sync(9*C_S_AXI_DATA_WIDTH - 1  downto 8*C_S_AXI_DATA_WIDTH);
            slv_reg9_sync  <= reg_sync(10*C_S_AXI_DATA_WIDTH - 1 downto 9*C_S_AXI_DATA_WIDTH);
            slv_reg10_sync <= reg_sync(11*C_S_AXI_DATA_WIDTH - 1 downto 10*C_S_AXI_DATA_WIDTH);
            slv_reg11_sync <= reg_sync(12*C_S_AXI_DATA_WIDTH - 1 downto 11*C_S_AXI_DATA_WIDTH);
            slv_reg12_sync <= reg_sync(13*C_S_AXI_DATA_WIDTH - 1 downto 12*C_S_AXI_DATA_WIDTH);
            slv_reg13_sync <= reg_sync(14*C_S_AXI_DATA_WIDTH - 1 downto 13*C_S_AXI_DATA_WIDTH);
            slv_reg14_sync <= reg_sync(15*C_S_AXI_DATA_WIDTH - 1 downto 14*C_S_AXI_DATA_WIDTH);
            slv_reg15_sync <= reg_sync(16*C_S_AXI_DATA_WIDTH - 1 downto 15*C_S_AXI_DATA_WIDTH);

        end block;
 
        ADC_SOFTSPAN_TRANSLATION: for i in 0 to 3 generate
            with adc_ctrl_reg_1(i*3+2 downto i*3) 
            select adc_softspan_aux(i*3+2 downto i*3) <= 
                "001" when "000", -- +5.12 V
                "100" when "001", -- +10 V
                "101" when "010", -- +10.24 V
                "010" when "011", -- +- 5 V
                "011" when "100", -- +- 5.12 V
                "110" when "101", -- +- 10 V
                "111" when others; -- +- 10.24 V
        end generate;

        sampling_eoc <= sampling_eoc_reg_0;
        adc_powerdown <= adc_ctrl_reg_1(31);
        adc_softspan <= "000" & adc_softspan_aux(11 downto 9) & 
                        "000" & adc_softspan_aux(8 downto 6)  & 
                        "000" & adc_softspan_aux(5 downto 3)  & 
                        "000" & adc_softspan_aux(2 downto 0);

        dac_powerup <= not dac_ctrl_reg_2(C_S_AXI_DATA_WIDTH - 1 downto C_S_AXI_DATA_WIDTH - 4);
        dac_code    <= dac_ctrl_reg_2(C_S_AXI_DATA_WIDTH - 5);
        dac_clr_sel <= dac_ctrl_reg_2(C_S_AXI_DATA_WIDTH - 6);
        dac_tsd_ena <= dac_ctrl_reg_2(C_S_AXI_DATA_WIDTH - 7);
        dac_range   <= dac_ctrl_reg_2(2 downto 0);

        dsp_ena_c2h <= dsp_ctrl_reg_3(0); 
end arch_imp;
