----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    23:27:35 03/N/N09 
-- Design Name: 
-- Module Name:    p2r_w - Behavioral 
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

entity p2r_w is
	Generic( N : natural := 15);
	port (
	x_in: IN std_logic_VECTOR(N downto 0);
	y_in: IN std_logic_VECTOR(N downto 0);
	phase_in: IN std_logic_VECTOR(N downto 0);
	x_out: OUT std_logic_VECTOR(N downto 0);
	y_out: OUT std_logic_VECTOR(N downto 0);
	ce: IN std_logic;
	rdy: OUT std_logic;
	sclr: IN std_logic;
	clk: IN std_logic);
end p2r_w;

architecture Behavioral of p2r_w is
component p2r IS
	port (
	x_in: IN std_logic_VECTOR(11 downto 0);
	y_in: IN std_logic_VECTOR(11 downto 0);
	phase_in: IN std_logic_VECTOR(11 downto 0);
	x_out: OUT std_logic_VECTOR(11 downto 0);
	y_out: OUT std_logic_VECTOR(11 downto 0);
	rdy: OUT std_logic;
	clk: IN std_logic;
	ce: IN std_logic;
	sclr: IN std_logic);
END component;
begin
U0 : p2r
		port map (
			x_in => x_in,
			y_in => y_in,
			phase_in => phase_in,
			x_out => x_out,
			y_out => y_out,
			rdy => rdy,
			clk => clk,
			ce => ce,
			sclr => sclr);

end Behavioral;

