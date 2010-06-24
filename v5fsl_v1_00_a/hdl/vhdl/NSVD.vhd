----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:00:09 04/05/2009 
-- Design Name: 
-- Module Name:    CORDIC - Behavioral 
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

entity NSVD is
    Generic( N : natural := 11);
    Port (
    	   p_r : in  STD_LOGIC_VECTOR (N downto 0);
           p_i : in  STD_LOGIC_VECTOR (N downto 0);
           s_r : in  STD_LOGIC_VECTOR (N downto 0);
           s_i : in  STD_LOGIC_VECTOR (N downto 0);
           r_r : in  STD_LOGIC_VECTOR (N downto 0);
           r_i : in  STD_LOGIC_VECTOR (N downto 0);
           q_r : in  STD_LOGIC_VECTOR (N downto 0);
           q_i : in  STD_LOGIC_VECTOR (N downto 0);
           U_p_r : in  STD_LOGIC_VECTOR (N downto 0);
           U_p_i : in  STD_LOGIC_VECTOR (N downto 0);
           U_s_r : in  STD_LOGIC_VECTOR (N downto 0);
           U_s_i : in  STD_LOGIC_VECTOR (N downto 0);
           U_r_r : in  STD_LOGIC_VECTOR (N downto 0);
           U_r_i : in  STD_LOGIC_VECTOR (N downto 0);
           U_q_r : in  STD_LOGIC_VECTOR (N downto 0);
           U_q_i : in  STD_LOGIC_VECTOR (N downto 0);
           V_p_r : in  STD_LOGIC_VECTOR (N downto 0);
           V_p_i : in  STD_LOGIC_VECTOR (N downto 0);
           V_s_r : in  STD_LOGIC_VECTOR (N downto 0);
           V_s_i : in  STD_LOGIC_VECTOR (N downto 0);
           V_r_r : in  STD_LOGIC_VECTOR (N downto 0);
           V_r_i : in  STD_LOGIC_VECTOR (N downto 0);
           V_q_r : in  STD_LOGIC_VECTOR (N downto 0);
           V_q_i : in  STD_LOGIC_VECTOR (N downto 0);
           p_r_II : out  STD_LOGIC_VECTOR (N downto 0);
           p_i_II : out  STD_LOGIC_VECTOR (N downto 0);
           s_r_II : out  STD_LOGIC_VECTOR (N downto 0);
           s_i_II : out  STD_LOGIC_VECTOR (N downto 0);
           r_r_II : out  STD_LOGIC_VECTOR (N downto 0);
           r_i_II : out  STD_LOGIC_VECTOR (N downto 0);
           q_r_II : out  STD_LOGIC_VECTOR (N downto 0);
           q_i_II : out  STD_LOGIC_VECTOR (N downto 0);
           U_p_r_II : out  STD_LOGIC_VECTOR (N downto 0);
           U_p_i_II : out  STD_LOGIC_VECTOR (N downto 0);
           U_s_r_II : out  STD_LOGIC_VECTOR (N downto 0);
           U_s_i_II : out  STD_LOGIC_VECTOR (N downto 0);
           U_r_r_II : out  STD_LOGIC_VECTOR (N downto 0);
           U_r_i_II : out  STD_LOGIC_VECTOR (N downto 0);
           U_q_r_II : out  STD_LOGIC_VECTOR (N downto 0);
           U_q_i_II : out  STD_LOGIC_VECTOR (N downto 0);
           V_p_r_II : out  STD_LOGIC_VECTOR (N downto 0);
           V_p_i_II : out  STD_LOGIC_VECTOR (N downto 0);
           V_s_r_II : out  STD_LOGIC_VECTOR (N downto 0);
           V_s_i_II : out  STD_LOGIC_VECTOR (N downto 0);
           V_r_r_II : out  STD_LOGIC_VECTOR (N downto 0);
           V_r_i_II : out  STD_LOGIC_VECTOR (N downto 0);
           V_q_r_II : out  STD_LOGIC_VECTOR (N downto 0);
           V_q_i_II : out  STD_LOGIC_VECTOR (N downto 0);
	   ce: IN std_logic;
	   rdy: OUT std_logic;
	   clk: IN std_logic);
end NSVD;

architecture Behavioral of NSVD is
signal temp: std_logic;
begin
temp <= ce;
process(clk) -- clk triggers the execution
begin
  if clk='1' and clk'event then
	  if ce = '1' then
	  	if q_r < p_r then --H
			p_r_II <= p_r(N downto 0); 
			p_i_II <= p_i(N downto 0);
			s_r_II <= s_r(N downto 0);
			s_i_II <= s_i(N downto 0);
			r_r_II <= r_r(N downto 0);
			r_i_II <= r_i(N downto 0);
			q_r_II <= q_r(N downto 0);
			q_i_II <= q_i(N downto 0);
			
			U_p_r_II <= U_p_r(N downto 0);
			U_p_i_II <= std_logic_vector( -signed(U_p_i(N downto 0) ) );
			U_s_r_II <= U_r_r(N downto 0);
			U_s_i_II <= std_logic_vector( -signed(U_r_i(N downto 0) ) );
			U_r_r_II <= U_s_r(N downto 0);
			U_r_i_II <= std_logic_vector( -signed(U_s_i(N downto 0) ) );
			U_q_r_II <= U_q_r(N downto 0);
			U_q_i_II <= std_logic_vector( -signed(U_q_i(N downto 0) ) );
			
			V_p_r_II <= V_p_r(N downto 0); 
			V_p_i_II <= V_p_i(N downto 0);
			V_s_r_II <= V_s_r(N downto 0);
			V_s_i_II <= V_s_i(N downto 0);
			V_r_r_II <= V_r_r(N downto 0);
			V_r_i_II <= V_r_i(N downto 0);
			V_q_r_II <= V_q_r(N downto 0);
			V_q_i_II <= V_q_i(N downto 0);
		else --H and switch
			p_r_II <= q_r(N downto 0); 
			p_i_II <= q_i(N downto 0);
			s_r_II <= r_r(N downto 0);
			s_i_II <= r_i(N downto 0);
			r_r_II <= s_r(N downto 0);
			r_i_II <= s_i(N downto 0);
			q_r_II <= p_r(N downto 0);
			q_i_II <= p_i(N downto 0);
			
			U_p_r_II <= std_logic_vector( -signed(U_r_r(N downto 0) ) ); 
			U_p_i_II <= U_r_i(N downto 0); 
			U_s_r_II <= U_p_r(N downto 0); 
			U_s_i_II <= std_logic_vector( -signed(U_p_i(N downto 0) ) );  
			U_r_r_II <= std_logic_vector( -signed(U_q_r(N downto 0) ) );  
			U_r_i_II <= U_q_i(N downto 0); 
			U_q_r_II <= U_s_r(N downto 0); 
			U_q_i_II <= std_logic_vector( -signed(U_s_i(N downto 0) ) );  
			
			V_p_r_II <= V_r_r(N downto 0);
			V_p_i_II <= std_logic_vector( -signed(V_r_i(N downto 0) ) ); 
			V_s_r_II <= V_q_r(N downto 0); 
			V_s_i_II <= std_logic_vector( -signed(V_q_i(N downto 0) ) ); 
			V_r_r_II <= std_logic_vector( -signed(V_p_r(N downto 0) ) );
			V_r_i_II <= V_p_i(N downto 0); 
			V_q_r_II <= std_logic_vector( -signed(V_s_r(N downto 0) ) );
			V_q_i_II <= V_s_i(N downto 0); 
		end if;
		rdy <= temp;		
	  end if;
  end if;
end process;

end Behavioral;

