-- Copyright © 2008 Wesley J. Landaker <wjl@icecavern.net>
-- 
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
-- 
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
-- 
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.

library ieee;
use ieee.std_logic_1164.all;

entity Gray2Binary is
  generic (
    param_WIDTH : natural := 8
    );
  port (
    GRAY_I   : in  std_logic_vector(param_WIDTH-1 downto 0);
    BINARY_O : out std_logic_vector(param_WIDTH-1 downto 0)
    );
end entity;

architecture rtl of Gray2Binary is
begin

  process (GRAY_I) is
    variable gray, bin : std_logic_vector(param_WIDTH-1 downto 0);
  begin
    gray               := GRAY_I;
    bin(param_WIDTH-1) := gray(param_WIDTH-1);
    for i in param_WIDTH-2 downto 0 loop
      bin(i) := gray(i) xor bin(i+1);
    end loop;
    BINARY_O <= bin;
  end process;
  
end architecture;
