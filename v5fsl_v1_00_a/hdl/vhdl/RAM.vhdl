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

-- General purpose optionally-multiport registered RAM.
--
-- This RAM can be used either as a single-port RAM or a dual-port RAM. If
-- the target technology supports it, the dual-port RAM can also support dual
-- write ports. In dual-port mode, there are no dependencies between the two
-- clocks; they may be completely asynchronous to each another.
--
-- To use as a single port RAM, simply leave the second port disconnected. To
-- use as a standard dual-port RAM, port A must be used as the write port,
-- and port B's write enable and data input should be left unconnected. To
-- use as a dual write-port dual-port RAM, dual-write mode must be enabled,
-- and then both ports can be fully used.
--
-- Every port has an optional enable that may be left disconnected if the
-- RAM should always be enabled. When a port is not enabled, corresponding
-- writes are ignored and output holds the previously read value.
--
-- When reading and writing simultaneously on the same port, reads always
-- happen before writes. In dual-write mode, if two ports simultaneously
-- write to the same location, the result is undefined.
--
-- Latency:
--
-- Both read and write latency is 1 clock cycle.
-- 
-- Example usage (single-port):
--
-- A_CLK_I  __/~~\__/~~\__/~~\__/~~\__/~~\__/~~\__/~~\__/~~\__/~~\__/~~\__
-- A_EN_I   ___/~~~~~~~~~~~~~~~~~~~~~~~\_____/~~~~~\_____/~~~~~~~~~~~\____
-- A_ADDR_I ===<  0  |  1  |  2  |  3  |  4  |  0  |  1  |  2  |  3  >====
-- A_WE_I   ___/~~~~~\_____/~~~~~~~~~~~~~~~~~\_________________/~~~~~\____
-- A_DATA_I ===<  0  |  1  |  2  |  3  |  4  |  5  |  6  |  7  |  8  >====
-- A_DATA_O =======================================<     0     |  2  |  3
--
-- Example usage (dual-port):
--
-- A_CLK_I  __/~~\__/~~\__/~~\__/~~\__/~~\__/~~\__/~~\__/~~\__/~~\__/~~\__
-- A_EN_I   ___/~~~~~~~~~~~~~~~~~~~~~~~\_____/~~~~~\_____/~~~~~~~~~~~\____
-- A_ADDR_I ===<  0  |  1  |  2  |  3  |  4  |  0  |  1  |  2  |  3  >====
-- A_WE_I   ___/~~~~~\_____/~~~~~~~~~~~~~~~~~\_________________/~~~~~\____
-- A_DATA_I ===<  0  |  1  |  2  |  3  |  4  |  5  |  6  |  7  |  8  >====
-- A_DATA_O =======================================<     0     |  2  |  3
-- B_CLK_I  _/~~~~\_/~~~~\_/~~~~\_/~~~~\_/~~~~\_/~~~~\_/~~~~\_/~~~~\_/~~~~
-- B_EN_I   _________/~~~~~~~~~~~~~~~~~~~~~~~~~~~\_____/~~~~~~~~~~~~~~\___
-- B_ADDR_I ==<  4   |  3   |  2   |  1   |  0   |  1   |  2   |  3   | 4
-- B_DATA_O =======================<  2   |  1   |      0      |  2   | 3
--
-- Example usage (dual-port, dual-write mode):
--
-- A_CLK_I  __/~~\__/~~\__/~~\__/~~\__/~~\__/~~\__/~~\__/~~\__/~~\__/~~\__
-- A_EN_I   ___/~~~~~~~~~~~~~~~~~~~~~~~\_____/~~~~~\_____/~~~~~~~~~~~\____
-- A_ADDR_I ===<  0  |  1  |  2  |  3  |  4  |  0  |  1  |  2  |  3  >====
-- A_WE_I   ___/~~~~~\_____/~~~~~~~~~~~~~~~~~\_________________/~~~~~\____
-- A_DATA_I ===<  0  |  1  |  2  |  3  |  4  |  5  |  6  |  7  |  8  >====
-- A_DATA_O =======================================<     9     |  7  |  3
-- B_CLK_I  _/~~~~\_/~~~~\_/~~~~\_/~~~~\_/~~~~\_/~~~~\_/~~~~\_/~~~~\_/~~~~
-- B_EN_I   _________/~~~~~~~~~~~~~~~~~~~~~~~~~~~\______/~~~~~~~~~~~~~\___
-- B_ADDR_I ==<  4   |  3   |  2   |  1   |  0   |  1   |  2   |  3   | 4
-- B_WE_I   ________________/~~~~~~~~~~~~~~~~~~~~\________________________
-- B_DATA_I ================<  7   |  8   |  9   >========================
-- B_DATA_O =======================<  2   |  1   |      0      |  7   | 3
--
entity RAM is
  generic (
    param_ADDR_WIDTH : positive := 10;
    param_DATA_WIDTH : positive := 32;
    param_DUAL_WRITE : boolean  := false
    );
  port (

    -- Memory Port A
    A_CLK_I  : in  std_logic;
    A_EN_I   : in  std_logic := '1';
    A_ADDR_I : in  std_logic_vector(param_ADDR_WIDTH-1 downto 0);
    A_WE_I   : in  std_logic;
    A_DATA_I : in  std_logic_vector(param_DATA_WIDTH-1 downto 0);
    A_DATA_O : out std_logic_vector(param_DATA_WIDTH-1 downto 0);

    -- Memory Port B
    B_CLK_I  : in  std_logic                                     := '0';
    B_EN_I   : in  std_logic                                     := '1';
    B_ADDR_I : in  std_logic_vector(param_ADDR_WIDTH-1 downto 0) := (others => '-');
    B_WE_I   : in  std_logic                                     := '0';
    B_DATA_I : in  std_logic_vector(param_DATA_WIDTH-1 downto 0) := (others => '-');
    B_DATA_O : out std_logic_vector(param_DATA_WIDTH-1 downto 0)

    );
end entity;

architecture rtl of RAM is

  -- Compute memory depth based on the given address width
  constant const_MEMORY_DEPTH : natural := 2**A_ADDR_I'length;

  -- Address and word subtype definitions
  subtype address_t is natural range 0 to const_MEMORY_DEPTH-1;
  subtype data_t is std_logic_vector(A_DATA_I'range);

  -- Memory type and variable/signal declaration. The shared variable
  -- memory definition is used if we are in dual-write mode. Otherwise,
  -- the signal version is used.
  type memory_t is array (0 to const_MEMORY_DEPTH-1) of data_t;
  shared variable memory_dw : memory_t;
  signal memory             : memory_t;
  
begin

  -- If we are not in dual-write mode, ensure that B_WE_I is not used.
  if_DUAL_WRITE : if not param_DUAL_WRITE generate
    assert B_WE_I = '0'
      report "Port B cannot be use for writes if not in DUAL_WRITE mode!"
      severity error;
  end generate;

  -- Implement our ports.
  proc_ports : process (A_CLK_I, B_CLK_I) is

    -- Write port implementation. Reads happen when the enable is asserted.
    -- Writes happen when the both enables are asserted. Reads always happen
    -- before writes. When the enable is not asserted, output data is held.
    procedure write_port (
      CLK_I         : in  std_logic;
      EN_I          : in  std_logic;
      ADDR_I        : in  std_logic_vector(param_ADDR_WIDTH-1 downto 0);
      WE_I          : in  std_logic;
      DATA_I        : in  std_logic_vector(param_DATA_WIDTH-1 downto 0);
      signal DATA_O : out std_logic_vector(param_DATA_WIDTH-1 downto 0)
      ) is
      variable address : address_t;
    begin
      address := to_integer(unsigned(ADDR_I));
      if EN_I = '1' then
        if param_DUAL_WRITE then
          DATA_O <= memory_dw(address);
        else
          DATA_O <= memory(address);
        end if;
        if WE_I = '1' then
          if param_DUAL_WRITE then
            memory_dw(address) := DATA_I;
          else
            memory(address) <= DATA_I;
          end if;
        end if;
      end if;
    end procedure;

    -- Read port implementation. Reads happen when the enable is asserted.
    -- When the enable is not asserted, output data is held.
    procedure read_port (
      CLK_I         : in  std_logic;
      EN_I          : in  std_logic;
      ADDR_I        : in  std_logic_vector(param_ADDR_WIDTH-1 downto 0);
      signal DATA_O : out std_logic_vector(param_DATA_WIDTH-1 downto 0)
      ) is
      variable address : address_t;
    begin
      address := to_integer(unsigned(ADDR_I));
      if EN_I = '1' then
        if param_DUAL_WRITE then
          DATA_O <= memory_dw(address);
        else
          DATA_O <= memory(address);
        end if;
      end if;
    end procedure;

  begin
    -- Port A is always a write port.
    if rising_edge(A_CLK_I) then
      write_port(A_CLK_I, A_EN_I, A_ADDR_I, A_WE_I, A_DATA_I, A_DATA_O);
    end if;

    -- Port B is a write port in dual-write mode, otherwise it's a read port.    
    if rising_edge(B_CLK_I) then
      if param_DUAL_WRITE then
        write_port(B_CLK_I, B_EN_I, B_ADDR_I, B_WE_I, B_DATA_I, B_DATA_O);
      else
        read_port(B_CLK_I, B_EN_I, B_ADDR_I, B_DATA_O);
      end if;
    end if;
  end process;
  
end architecture;
