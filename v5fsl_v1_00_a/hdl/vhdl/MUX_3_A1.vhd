----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:03:12 04/05/2009 
-- Design Name: 
-- Module Name:    mux2 - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
-- we did not get the Y+X but the (Y+X)/2 which does not change the value of the angle from arctan.
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

entity MUX_3 is
    Generic( N : natural := 15);
    Port ( W : in  STD_LOGIC_VECTOR (N downto 0);
           X : in  STD_LOGIC_VECTOR (N downto 0);
           Y : in  STD_LOGIC_VECTOR (N downto 0);
           Z : in  STD_LOGIC_VECTOR (N downto 0);
           YX_sum : out  STD_LOGIC_VECTOR (N downto 0);
           ZW_diff : out  STD_LOGIC_VECTOR (N downto 0);
           YX_diff : out  STD_LOGIC_VECTOR (N downto 0);
           ZW_sum : out  STD_LOGIC_VECTOR (N downto 0);
           ce : in std_logic;
           rdy : out  std_logic;
           clk : in std_logic);
end MUX_3;

architecture Behavioral of MUX_3 is
signal W_temp, X_temp, Y_temp, Z_temp: STD_LOGIC_VECTOR (N+1 downto 0):= (others => 'Z');
signal YX_sum_temp, YX_diff_temp, ZW_sum_temp, ZW_diff_temp : STD_LOGIC_VECTOR (N+1 downto 0):= (others => 'Z');
signal temp_ce: std_logic :='Z';

begin
	--------0--------1---------2-------------
	----------12345678901234567890123-----------
	W_temp <= W(N) & W;
	X_temp <= X(N) & X;
	Y_temp <= Y(N) & Y;
	Z_temp <= Z(N) & Z;
	
	process(clk)
	begin
		if clk='1' and clk'event then
			if ce = '1' then
				temp_ce <= ce;
				YX_sum_temp <= STD_LOGIC_VECTOR (signed(Y_temp) + signed(X_temp));
				YX_diff_temp <= STD_LOGIC_VECTOR (signed(Y_temp) + (-signed(X_temp)));
				ZW_sum_temp <= STD_LOGIC_VECTOR (signed(Z_temp) + signed(W_temp));
				ZW_diff_temp <= STD_LOGIC_VECTOR (signed(Z_temp) + (-signed(W_temp)));
			end if;
		end if;
	end process;
	YX_sum <= YX_sum_temp(N+1 downto 1);
	YX_diff <= YX_diff_temp(N+1 downto 1);
	ZW_sum <= ZW_sum_temp(N+1 downto 1);
	ZW_diff <= ZW_diff_temp(N+1 downto 1);
	rdy <= temp_ce;
end Behavioral;
