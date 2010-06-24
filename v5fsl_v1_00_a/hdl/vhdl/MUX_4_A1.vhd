----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:18:06 09/17/2009 
-- Design Name: 
-- Module Name:     - Behavioral 
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

entity MUX_4 is
    Generic( N : natural := 15);
    Port ( theta_sum : in  STD_LOGIC_VECTOR (N downto 0);
           theta_diff : in  STD_LOGIC_VECTOR (N downto 0);
           theta_lambda_N : out  STD_LOGIC_VECTOR (N downto 0);
           theta_rho : out  STD_LOGIC_VECTOR (N downto 0);
           ce : in std_logic;
           rdy : out  std_logic;
           clk : in std_logic);
end MUX_4;

architecture Behavioral of MUX_4 is

signal temp_theta_sum, temp_theta_diff : STD_LOGIC_VECTOR (N+1 downto 0):= (others => 'Z');
signal temp_theta_lambda_N, temp_theta_rho : STD_LOGIC_VECTOR (N+1 downto 0):= (others => 'Z');
signal temp_ce: std_logic:='Z';

begin
	--------0--------1---------2-------------
	----------1234567890123456789012-----------
	--one <= "0000000000001";  --** generic N **--
	temp_theta_sum  <= theta_sum(N) & theta_sum;
	temp_theta_diff <= theta_diff(N)& theta_diff;

	process(clk)
	begin
		if clk='1' and clk'event then
		if ce = '1' then
			temp_theta_lambda_N <= std_logic_vector( (- signed(temp_theta_diff)) + signed(temp_theta_sum));
			temp_theta_rho    <= std_logic_vector (signed(temp_theta_sum) +  signed(temp_theta_diff));
			temp_ce <= ce;	
		end if;
		end if;
	end process;
		
	theta_lambda_N <= temp_theta_lambda_N(N+1 downto 1);--/2;
	theta_rho  <= temp_theta_rho(N+1 downto 1);
	rdy <= temp_ce;
end Behavioral;
