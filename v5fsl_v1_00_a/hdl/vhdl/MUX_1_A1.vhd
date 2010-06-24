----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:18:06 03/20/2009 
-- Design Name: 
-- Module Name:    angle - Behavioral 
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

entity MUX_1 is
    Generic( N : natural := 15);
    Port ( theta_c : in  STD_LOGIC_VECTOR (N downto 0);
           theta_d : in  STD_LOGIC_VECTOR (N downto 0);
           theta_alpha : out  STD_LOGIC_VECTOR (N downto 0);
           theta_beta : out  STD_LOGIC_VECTOR (N downto 0);
           theta_gamma : out  STD_LOGIC_VECTOR (N downto 0);
           theta_delta : out  STD_LOGIC_VECTOR (N downto 0);
           ce : in std_logic;
           rdy : out  std_logic;
           clk : in std_logic);
end MUX_1;

architecture Behavioral of MUX_1 is

signal temp_ab, temp_gd, temp_gd_b: STD_LOGIC_VECTOR (N+1 downto 0) := (others => 'Z');--temp for theta alpha beta, and gamma delta
signal temp_theta_c, temp_theta_d : STD_LOGIC_VECTOR (N+1 downto 0) := (others => 'Z');--18 bit takes p+p and N+N
signal temp_ce: std_logic := 'Z';

begin
	--------0--------1---------2-------------
	--------1234567890123456789012-----------
	temp_theta_d <= theta_d(N) & theta_d;
	temp_theta_c <= theta_c(N) & theta_c;

	process(clk)
	begin
		if clk='1' and clk'event then
			if ce = '1' then
				temp_ce <= ce;
				temp_ab <= std_logic_vector( - (signed(temp_theta_d) + signed(temp_theta_c))); --get temp_ab = -(theta_d+theta_c)
				temp_gd <= std_logic_vector (signed(temp_theta_d) + (- signed(temp_theta_c)));
				temp_gd_b <= std_logic_vector(signed(temp_theta_c) + (- signed(temp_theta_d)));
			end if;
		end if;
	end process;
	rdy <= temp_ce;	
	theta_alpha <= temp_ab(N+1 downto 1);--/2;--get theta_alpha = -(theta_d+theta_c)/2 (!!!shifting here may cause rounding error!!!)
	theta_beta  <= temp_ab(N+1 downto 1);
	theta_gamma <= temp_gd(N+1 downto 1); --theta_gamma = (theta_d-theta_c)/2
	theta_delta <= temp_gd_b(N+1 downto 1);
	
end Behavioral;
