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

-- Transforms an asynchronous reset signal into a synchronous one.
--
-- When ASYNC_RST_I is asserted, RST_O is also asynchronously asserted. Once
-- ASYNC_RST_I has been deasserted, RST_O is deasserted synchronous to CLK_I.
--
-- If param_FALLING_EDGE is set, RST_O is deasserted on the falling edge of
-- CLK_I. Otherwise, RST_O is deasserted on the CLK_I's rising edge.
--
-- ASYNC_RST_I deassertion to RST_O deassertion is 0.5 to 1 clock cycles.
--
-- Example:
--
-- ASYNC_RST_I  _______/~~~~~~~~~~~~~~~~~~~\____________________________
-- CLK_I        ____/~~~~\____/~~~~\____/~~~~\____/~~~~\____/~~~~\_____
-- RST_O        _______/~~~~~~~~~~~~~~~~~~~~~~~~~~~\___________________

entity AsyncReset is
  port (
    ASYNC_RST_I : in  std_logic := '0';
    CLK_I       : in  std_logic;
    RST_O       : out std_logic
    );
end entity;

architecture rtl of AsyncReset is
begin

  u_Synchronizer : entity work.Synchronizer
    generic map (
      param_RESET_VALUE  => '1'
      )
    port map (
      RST_I   => ASYNC_RST_I,
      CLK_I   => CLK_I,
      ASYNC_I => '0',
      SYNC_O  => RST_O
      );  

end architecture;
