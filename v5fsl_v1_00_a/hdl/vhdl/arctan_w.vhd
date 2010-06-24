----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    23:23:41 03/N/N09 
-- Design Name: 
-- Module Name:    arctan_w - Behavioral 
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
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.STD_LOGIC_ARITH.ALL;
--use IEEE.STD_LOGIC_SIGNED.ALL;
use IEEE.NUMERIC_STD.all;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity arctan_w is
	Generic( N : natural := 15);
	port (
	x_in: IN std_logic_VECTOR(N downto 0);
	y_in: IN std_logic_VECTOR(N downto 0);
	phase_out: OUT std_logic_VECTOR(N downto 0);
	ce: IN std_logic;
	rdy: OUT std_logic;
	sclr: IN std_logic;
	clk: IN std_logic);
end arctan_w;

architecture Behavioral of arctan_w is
component arctan is
	port (
	x_in: IN std_logic_VECTOR(11 downto 0);
	y_in: IN std_logic_VECTOR(11 downto 0);
	phase_out: OUT std_logic_VECTOR(11 downto 0);
	rdy: OUT std_logic;
	clk: IN std_logic;
	ce: IN std_logic;
	sclr: IN std_logic);
end component;
begin
U0: arctan port map (
			x_in => x_in,
			y_in => y_in,
			phase_out => phase_out,
			rdy => rdy,
			clk => clk,
			ce => ce,
			sclr => sclr);

end Behavioral;

