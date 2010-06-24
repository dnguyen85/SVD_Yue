----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    23:29:05 03/N/2009 
-- Design Name: 
-- Module Name:    r2p_w - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------library IEEE;s
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.STD_LOGIC_ARITH.ALL;
--use IEEE.STD_LOGIC_SIGNED.ALL;
use IEEE.NUMERIC_STD.all;
---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity r2p_w is
	Generic( N : natural := 15);
	port (
	x_in: IN std_logic_VECTOR(N downto 0);
	y_in: IN std_logic_VECTOR(N downto 0);
	x_out: OUT std_logic_VECTOR(N downto 0);
	phase_out: OUT std_logic_VECTOR(N downto 0);
	ce: IN std_logic;
	rdy: OUT std_logic;
	sclr: IN std_logic;
	clk: IN std_logic);
end r2p_w;

architecture Behavioral of r2p_w is
component r2p
	port (
	x_in: IN std_logic_VECTOR(11 downto 0);
	y_in: IN std_logic_VECTOR(11 downto 0);
	x_out: OUT std_logic_VECTOR(11 downto 0);
	phase_out: OUT std_logic_VECTOR(11 downto 0);
	rdy: OUT std_logic;
	clk: IN std_logic;
	ce: IN std_logic;
	sclr: IN std_logic);
end component;
begin
U0 : r2p
		port map (
			x_in => x_in,
			y_in => y_in,
			x_out => x_out,
			phase_out => phase_out,
			rdy => rdy,
			clk => clk,
			ce => ce,
			sclr => sclr);
end Behavioral;

