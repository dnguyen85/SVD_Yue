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

entity MUX_5 is
    Generic( N : natural := 15);
    Port ( theta_a : in  STD_LOGIC_VECTOR (N downto 0);
           theta_b : in  STD_LOGIC_VECTOR (N downto 0);
           theta_c : out  STD_LOGIC_VECTOR (N downto 0);
           ce : in std_logic;
           rdy : out  std_logic;
           clk : in std_logic);
end MUX_5;

architecture Behavioral of MUX_5 is

signal temp_theta_a, temp_theta_b: STD_LOGIC_VECTOR (N+1 downto 0):= (others => 'Z');
signal temp_theta_c : STD_LOGIC_VECTOR (N+1 downto 0):= (others => 'Z');
signal temp_ce: std_logic:='Z';
signal PI, PI_N, PI_2, PI_N_2 , theta_c_temp: STD_LOGIC_VECTOR (3 downto 0);

begin
	---   -----0--------1---------2-------------
       	   --------1234567890123456789012-----------
	PI	<= "0001";
	--PI    <= "0001000000000";
	PI_N	<= "1111";
	--PI_N  <= "1111000000000";
	PI_2	<= "0010";
	--PI_2  <= "0010000000000";
	PI_N_2	<= "1110";
	--PI_N_2<= "1110000000000";
	
	temp_theta_a <= theta_a(N) & theta_a;  --use concatenation
	temp_theta_b <= theta_b(N) & theta_b;  --use concatenation

	temp_theta_c <= std_logic_vector( signed(temp_theta_b) + signed(temp_theta_a) ); 

	process(clk)
	begin
		if clk='1' and clk'event then
		if ce = '1' then
			temp_ce <= ce;
			if (   (temp_theta_c(N+1 downto N-2) > PI)   and (temp_theta_c(N+1 downto N-2) <= PI_2  ) ) then --smaller than 3pi
				theta_c_temp <= std_logic_vector(signed(temp_theta_c(N+1 downto N-2))+signed(PI_N_2));
			elsif ((temp_theta_c(N+1 downto N-2) < PI_N) and (temp_theta_c(N+1 downto N-2) >= PI_N_2) ) then
				theta_c_temp <= std_logic_vector(signed(temp_theta_c(N+1 downto N-2))+signed(PI_2));
			else
				theta_c_temp <= temp_theta_c(N+1 downto N-2);
			end if;	
		end if;
		end if;
	end process;
	theta_c<=theta_c_temp(2 downto 0) & temp_theta_c(N-3 downto 0);
	rdy <= temp_ce;
end Behavioral;
