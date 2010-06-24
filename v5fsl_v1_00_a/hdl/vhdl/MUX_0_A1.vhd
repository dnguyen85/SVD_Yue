----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:42:29 03/29/2009 
-- Design Name: 
-- Module Name:    Complex_rotation_module - Behavioral 
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
-- theta_out is Round up!!!!!
-- Board problem may come from here !!!
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

entity MUX_0 is
    Generic( N : natural := 15);
    Port ( X : in STD_LOGIC_VECTOR (N downto 0);
           theta_m : in  STD_LOGIC_VECTOR (N downto 0);
           theta_1 : in  STD_LOGIC_VECTOR (N downto 0);
           theta_2 : in  STD_LOGIC_VECTOR (N downto 0);
           Z : out  STD_LOGIC_VECTOR (N downto 0);
           theta_out : out  STD_LOGIC_VECTOR (N downto 0);
           ce : in std_logic;
           rdy : out  std_logic;
           clk : in std_logic);
end MUX_0;

architecture Behavioral of MUX_0 is
signal temp_X : STD_LOGIC_VECTOR (N downto 0) := (others => 'Z');
signal temp_m, temp_1, temp_2 : STD_LOGIC_VECTOR (N+2 downto 0);
signal temp_out: STD_LOGIC_VECTOR (N+2 downto 0) := (others => 'Z');
signal PI, PI_N, PI_2, PI_N_2, PI_3, PI_N_3, theta_out_temp: STD_LOGIC_VECTOR (4 downto 0);
signal temp_ce: std_logic := 'Z';
begin
	--scaled pi
	-----------0--------1---------2-------------
	-----------1234567890123456789012-----------
	PI	 <= "00001";
	--PI     <= "00001000000000";
	PI_N	 <= "11111";
	--PI_N   <= "11111000000000";
	PI_2	 <= "00010";
	--PI_2   <= "00010000000000";
	PI_N_2	 <= "11110";
	--PI_N_2 <= "11110000000000";
	PI_3	 <= "00011";	
	--PI_3   <= "00011000000000";
	PI_N_3	 <= "11101";	
	--PI_N_3 <= "11101000000000";
	
	temp_m <= theta_m(N) & theta_m(N) & theta_m;
	temp_1 <= theta_1(N) & theta_1(N) & theta_1;
	temp_2 <= theta_2(N) & theta_2(N) & theta_2;
	
	temp_out  <= std_logic_vector(signed(temp_m)+signed(temp_1) + signed(temp_2));
	
	process(clk)
	begin
		if clk='1' and clk'event then
		    if ce = '1' then
			      temp_ce <= ce;	--outbuff
			      temp_X  <= X;       -----------1234567890123456789012-----------
			if ((temp_out( N+2 downto N-2) > PI) and (temp_out( N+2 downto N-2) <= PI_3)) then --smaller than 3pi
        		  	theta_out_temp <= std_logic_vector(signed(temp_out( N+2 downto N-2)) + signed(PI_N_2));
        		elsif ((temp_out( N+2 downto N-2) < PI_N) and (temp_out( N+2 downto N-2) >= PI_N_3)) then
          			theta_out_temp <= std_logic_vector(signed(temp_out( N+2 downto N-2)) + signed(PI_2));
			else
        			theta_out_temp <= temp_out( N+2 downto N-2);
          		end if;
		    end if;
		end if;
	end process;
	Z <= temp_X;
	theta_out <= theta_out_temp(2 downto 0) & temp_out(N-3 downto 0);
	rdy <= temp_ce;
end Behavioral;
