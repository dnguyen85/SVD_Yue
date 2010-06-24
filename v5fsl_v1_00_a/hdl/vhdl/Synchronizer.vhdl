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

-- Synchronizes an asynchronous input into a synchronous clock domain.
--
-- This synchronizer is more complex than a simple set of serial registers,
-- but has the advantage of being much lower latency.
--
-- Latency is 0.5 to 1 clock cycles.
--
-- Example:
--
-- RST_I    ______/~~~~~~~~\______________________________________________
-- CLK_I    __/~~\__/~~\__/~~\__/~~\__/~~\__/~~\__/~~\__/~~\__/~~\__/~~\__
-- ASYNC_I  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\______/~\__/~~~~~~\___________
-- SYNC_O   ~~~~~~\______________/~~~~~~~~~~~~~~\___________/~~~~~~~~\____

entity Synchronizer is
  generic (
    param_RESET_VALUE : std_logic := '0'
    );
  port (
    RST_I   : in  std_logic := '0';
    CLK_I   : in  std_logic;
    ASYNC_I : in  std_logic;
    SYNC_O  : out std_logic
    );
end entity;

architecture rtl of Synchronizer is

  -- Rising and falling synchronization chains
  signal sync_r : std_logic_vector(0 to 2) := (others => param_RESET_VALUE);
  signal sync_f : std_logic_vector(0 to 2) := (others => param_RESET_VALUE);

  -- Synchronization state flags
  signal one  : std_logic;
  signal rise : std_logic;

begin

  -- Rising edge synchronization starts with a rising edge capture, then
  -- alternates clock edges.
  proc_sync_r : process (CLK_I, RST_I) is
  begin
    if rising_edge(CLK_I) then
      sync_r(0) <= to_X01(ASYNC_I);
    end if;
    if falling_edge(CLK_I) then
      sync_r(1) <= sync_r(0);
    end if;
    if rising_edge(CLK_I) then
      sync_r(2) <= sync_r(1);
    end if;
    if RST_I = '1' then
      sync_r <= (others => param_RESET_VALUE);
    end if;
  end process;

  -- Falling edge synchronization starts with a falling edge capture, then
  -- alternates clock edges.
  proc_sync_f : process (CLK_I, RST_I) is
  begin
    if falling_edge(CLK_I) then
      sync_f(0) <= to_X01(ASYNC_I);
    end if;
    if rising_edge(CLK_I) then
      sync_f(1) <= sync_f(0);
    end if;
    if falling_edge(CLK_I) then
      sync_f(2) <= sync_f(1);
    end if;
    if RST_I = '1' then
      sync_f <= (others => param_RESET_VALUE);
    end if;
  end process;

  -- Generate synchronization chain flags. We only need a one and a rise
  -- flag, as if these are not set, then we implicitly know that there is
  -- either a zero or fall condition.
  one  <= sync_r(1) and sync_f(1);
  rise <= (not sync_r(2) and sync_r(1)) or (not sync_f(2) and sync_f(1));

  -- General final synchronized signal. We assert our output if we have
  -- detected a one or a rise, otherwise zero.
  SYNC_O <= one or rise;
  
end architecture;
