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

entity Binary2Gray is
  generic (
    param_WIDTH : natural := 8
    );
  port (
    BINARY_I : in  std_logic_vector(param_WIDTH-1 downto 0);
    GRAY_O   : out std_logic_vector(param_WIDTH-1 downto 0)
    );
end entity;

architecture rtl of Binary2Gray is
begin

  process (BINARY_I) is
    variable bin, gray : std_logic_vector(param_WIDTH-1 downto 0);
  begin
    bin                 := BINARY_I;
    gray(param_WIDTH-1) := bin(param_WIDTH-1);
    for i in param_WIDTH-2 downto 0 loop
      gray(i) := bin(i) xor bin(i+1);
    end loop;
    GRAY_O <= gray;
  end process;
  
end architecture;
