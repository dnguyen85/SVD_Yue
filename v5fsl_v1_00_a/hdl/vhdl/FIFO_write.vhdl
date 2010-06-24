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
use ieee.numeric_std.all;

-- Generalized FIFO write-port implementation.
--
-- See top-level FIFO for high-level information.
entity FIFO_write is
  generic (
    param_ADDR_WIDTH         : positive := 4;
    param_DATA_WIDTH         : positive := 32;
    param_ALMOST_FULL_OFFSET : positive := 1
    );
  port (

    -- User Interface
    W_RST_I         : in  std_logic;
    W_CLK_I         : in  std_logic;
    W_EN_I          : in  std_logic;
    W_DATA_I        : in  std_logic_vector(param_DATA_WIDTH-1 downto 0);
    W_FULL_O        : out std_logic;
    W_ALMOST_FULL_O : out std_logic;
    W_COUNT_O       : out std_logic_vector(param_ADDR_WIDTH downto 0);

    -- Memory Interface
    RAM_W_EN_O   : out std_logic;
    RAM_W_ADDR_O : out std_logic_vector(param_ADDR_WIDTH-1 downto 0);
    RAM_W_DATA_O : out std_logic_vector(param_DATA_WIDTH-1 downto 0);

    -- Pointer Interface
    PTR_W_O : out std_logic_vector(param_ADDR_WIDTH downto 0);
    PTR_R_I : in  std_logic_vector(param_ADDR_WIDTH downto 0)

    );
end entity;

architecture rtl of FIFO_write is

  -- Effective write-enable
  signal w_en : std_logic;

  -- Flags
  signal w_full        : std_logic                         := '1';
  signal w_almost_full : std_logic                         := '1';
  signal w_count       : std_logic_vector(W_COUNT_O'range) := (others => '1');

  -- Pointers
  signal w_ptr : unsigned(PTR_W_O'range) := (others => '0');
  signal r_ptr : unsigned(PTR_R_I'range);
  
begin

  -- Qualify all writes by the full condition.
  w_en <= W_EN_I and not w_full;

  -- Write directly to RAM. This could be pipelined, but would add
  -- unneccessary latency in the nominal case.
  block_write : block is
  begin
    RAM_W_EN_O   <= w_en;
    RAM_W_ADDR_O <= std_logic_vector(w_ptr(RAM_W_ADDR_O'range));
    RAM_W_DATA_O <= W_DATA_I;
  end block;

  -- On a write, increment the write pointer
  proc_pointers : process (W_CLK_I, W_RST_I) is
  begin
    if W_RST_I = '1' then
      w_ptr <= (others => '0');
    elsif rising_edge(W_CLK_I) then
      if w_en = '1' then
        w_ptr <= w_ptr + 1;
      end if;
    end if;
  end process;

  -- Output the effective write pointer: since writes go directly to RAM
  -- without extra pipelining, we output a pre-incremented write pointer
  -- so that it can start being passed to the read port as soon as possible.
  PTR_W_O <= std_logic_vector(w_ptr + 1) when w_en = '1' else std_logic_vector(w_ptr);

  -- Grab the incoming read pointer so we can do math on it.
  r_ptr <= unsigned(PTR_R_I);

  -- Flag implementation
  block_flags : block is
    constant const_FIFO_DEPTH  : positive := 2**param_ADDR_WIDTH;
    constant const_FULL        : positive := const_FIFO_DEPTH;
    constant const_ALMOST_FULL : positive := const_FULL-param_ALMOST_FULL_OFFSET;

    signal count : unsigned(w_count'range);
  begin

    -- Verify that the requested ALMOST_FULL_OFFSET is possible.
    assert
      param_ALMOST_FULL_OFFSET <= const_FIFO_DEPTH-1
      report "Invalid ALMOST_FULL_OFFSET (must be < 2**ADDR_WIDTH)" severity failure;

    -- Calculate the FIFO count that will be effective on the next clock
    -- cycle to allow all output flags to be synchronous.
    proc_count : process (r_ptr, w_en, w_ptr) is
    begin
      count <= w_ptr - r_ptr;
      if w_en = '1' then
        count <= (w_ptr + 1) - r_ptr;
      end if;
    end process;

    -- Output all FIFO flags synchronously to increase performance and cut
    -- long loops when flags are used as control.
    proc_flags : process (W_CLK_I, W_RST_I) is
    begin
      if W_RST_I = '1' then
        w_full        <= '1';
        w_almost_full <= '1';
        w_count       <= (others => '0');
      elsif rising_edge(W_CLK_I) then
        w_full        <= '0';
        w_almost_full <= '0';
        w_count       <= std_logic_vector(const_FIFO_DEPTH - count);
        if count(count'high) = '1' then
          w_full        <= '1';
          w_almost_full <= '1';
        elsif count >= const_ALMOST_FULL then
          w_almost_full <= '1';
        end if;
      end if;
    end process;

    -- Forward internal flags to ports
    W_FULL_O        <= w_full;
    W_ALMOST_FULL_O <= w_almost_full;
    W_COUNT_O       <= w_count;
    
  end block;
  
end architecture;
