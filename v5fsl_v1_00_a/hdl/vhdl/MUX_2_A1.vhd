----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:34:29 04/05/2009 
-- Design Name: 
-- Module Name:    mux1 - Behavioral 
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

entity MUX_2 is
    Generic( N : natural := 15);
    Port ( theta_w : in  STD_LOGIC_VECTOR (N downto 0);
           theta_x : in  STD_LOGIC_VECTOR (N downto 0);
           theta_xi : out  STD_LOGIC_VECTOR (N downto 0);
           theta_eta : out  STD_LOGIC_VECTOR (N downto 0);
           theta_zeta : out  STD_LOGIC_VECTOR (N downto 0);
           theta_omega : out  STD_LOGIC_VECTOR (N downto 0);
           ce : in std_logic;
           rdy : out  std_logic;
           clk : in std_logic);
end MUX_2;

architecture Behavioral of MUX_2 is

signal temp_theta_w, temp_theta_x : STD_LOGIC_VECTOR (N+1 downto 0):= (others => 'Z');
signal temp_theta_xi, temp_theta_eta, temp_theta_omega : STD_LOGIC_VECTOR (N+1 downto 0):= (others => 'Z');
signal temp_ce: std_logic :='Z';

begin
	--------0--------1---------2-------------
	--------1234567890123456789012-----------
	temp_theta_w <= temp_theta_w(N) & theta_w;
	temp_theta_x <= temp_theta_x(N) & theta_x;

	process(clk)
	begin
		if clk='1' and clk'event then
			if ce = '1' then
					temp_ce	 <= ce;
					temp_theta_xi <= std_logic_vector(- (signed(temp_theta_x)+signed(temp_theta_w))); --get temp_theta_xi = -(theta_x+theta_w)
					temp_theta_eta <= std_logic_vector(signed(temp_theta_x) + (- signed(temp_theta_w))); --get temp_theta_eta = (theta_x-theta_w)	
					temp_theta_omega <= std_logic_vector((- signed(temp_theta_x)) + (signed(temp_theta_w))); --temp_theta_omega = -theta_eta
			end if;
		end if;
	end process;
	
	rdy <= temp_ce;
	theta_xi    <= temp_theta_xi(N+1 downto 1);
	theta_eta   <= temp_theta_eta(N+1 downto 1);
	theta_zeta  <= temp_theta_eta(N+1 downto 1);--theta_zeta = theta_eta
	theta_omega <= temp_theta_omega(N+1 downto 1);
end Behavioral;