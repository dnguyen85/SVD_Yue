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
-- Description: Just a register. 
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

entity stage_I is
	Generic( N : natural := 15);
    Port ( A : in  STD_LOGIC_VECTOR (N  downto 0);
           theta_A : in  STD_LOGIC_VECTOR (N  downto 0);
           B : in  STD_LOGIC_VECTOR (N  downto 0);
           theta_B : in  STD_LOGIC_VECTOR (N  downto 0);
           C : in  STD_LOGIC_VECTOR (N  downto 0);
           theta_C : in  STD_LOGIC_VECTOR (N  downto 0);
           D : in  STD_LOGIC_VECTOR (N  downto 0);
           theta_D : in  STD_LOGIC_VECTOR (N  downto 0);
           A_II : out  STD_LOGIC_VECTOR (N downto 0);
           theta_A_II : out  STD_LOGIC_VECTOR (N downto 0);
           B_II : out  STD_LOGIC_VECTOR (N downto 0);
           theta_B_II : out  STD_LOGIC_VECTOR (N downto 0);
           C_II : out  STD_LOGIC_VECTOR (N downto 0);
           theta_C_II : out  STD_LOGIC_VECTOR (N downto 0);
           D_II : out  STD_LOGIC_VECTOR (N downto 0);
           theta_D_II : out  STD_LOGIC_VECTOR (N downto 0);
	   ce: IN std_logic;
	   rdy: OUT std_logic;
	   clk: IN std_logic);
end stage_I;

architecture Behavioral of stage_I is

signal temp_A : std_logic_vector(N downto 0);
signal temp_theta_A : std_logic_vector(N downto 0);
signal temp_B : std_logic_vector(N downto 0);
signal temp_theta_B : std_logic_vector(N downto 0);
signal temp_C : std_logic_vector(N downto 0);
signal temp_theta_C : std_logic_vector(N downto 0);
signal temp_D : std_logic_vector(N downto 0);
signal temp_theta_D : std_logic_vector(N downto 0);
signal temp_ce: std_logic;

begin

process(clk) -- clk triggers the execution
begin
  if clk='1' and clk'event then
    if ce = '1' then
	temp_A <= A; 
	temp_theta_A <= theta_A;
	temp_B <= B;
	temp_theta_B <= theta_B;
	temp_C<= C;
	temp_theta_C <= theta_C;
	temp_D <= D;
	temp_theta_D <= theta_D;
    	temp_ce <= ce;
    end if;
  end if;
end process;
A_II <= temp_A; 
theta_A_II <= temp_theta_A;
B_II <= temp_B;
theta_B_II <= temp_theta_B;
C_II <= temp_C;
theta_C_II <= temp_theta_C;
D_II <= temp_D;
theta_D_II <= temp_theta_D;
rdy <= temp_ce;

end Behavioral;

