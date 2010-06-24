--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:    10:45:51 09/23/08
-- Design Name:    
-- Module Name:    my_reg - Behavioral
-- Project Name:   
-- Target Device:  
-- Tool versions:  
-- Description:
--
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.STD_LOGIC_ARITH.ALL;
--use IEEE.STD_LOGIC_SIGNED.ALL;
use IEEE.NUMERIC_STD.all;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity my_reg is
port (    X : in    std_logic; -- 8-bit register
         Z : out  std_logic;
        en, ck : in   std_logic);
end my_reg;

architecture Behavioral of my_reg is
-- register = storage = internal signal declaration
signal temp : std_logic;
begin
process(ck) -- ck triggers the execution
begin
    if ck='1' and ck'event then 
		if en = '1' then temp <= X; 
		end if;
	end if;
end process;
-- wire temp to d_out
Z <= temp; -- concurrent statement wires temp to the output port

end Behavioral;
