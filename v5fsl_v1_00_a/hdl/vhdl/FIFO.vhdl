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

-- Full-featured all-purpose generalized FIFO.
--
-- By default, this FIFO operates with two independent read and write clocks
-- that may be completely asynchronous to each other. If a single clock is
-- used, the FIFO may be put into synchronous mode which will reduce
-- implementation resources and both write and read latency.
-- 
-- Both the address and data width of the FIFO are programmable. The FIFO 
-- capacity is automatically calculated from the address width. Arbitrary,
-- non-power-of-two-capacity FIFOs can be achieved by chaining individual
-- FIFO blocks with various address widths.
--
-- Asserting reset on either port will asynchronously reset the FIFO. In a 
-- reset condition, this means flags could deassert asynchronously. However,
-- the FIFO guarantees that flags will be held deasserted for at least a
-- full clock cycle and will only be reasserted synchronously.
--
-- Data is actually transfered whenever a port is both enabled and ready. To
-- support uninterruptable bursts and other advanced features, two exact sets
-- of flags are provided. First, programmable almost full and almost empty
-- flags can be configured to fixed offsets. Second, available write and read
-- count values indicate a  a numbers of guaranteed writes or reads that can
-- be burst without any gap. These counts may also be used to monitor the
-- state or utilization of the FIFO, e.g. telling when the FIFO is empty from
-- the write side, or e.g. calculating a high-water mark for FIFO resizing.
--
-- Latency:
--
-- Asynchronous write latency is 1 write plus 2.5 to 3 read  clock cycles.
-- Asynchronous read  latency is 1 read  plus 2.5 to 3 write clock cycles.
-- In synchronous mode, latency is 2 clock cycles in either direction.
-- Round-trip latency is simply the sum of write latency plus read latency.
--
-- To guarantee no stalls due only to FIFO latency, the address must be set
-- to 3 or more, except in synchronous mode, where this is guaranteed with an
-- address width of 2 or more. Depending on clock relationships and actual
-- application usage, a larger address width may be required, or a smaller
-- address width may work to never have stalls. By default the stated
-- conservative minimum is checked by the FIFO itself unless the warning is
-- explicitly suppressed with a FIFO parameter.
--
-- Required timing constraints:
--
-- From W_CLK_I to R_CLK_I in period(R_CLK_I).
-- From R_CLK_I to W_CLK_I in period(W_CLK_I).
--
-- The source clock period may not be smaller than the setup time plus hold
-- time of the target clock domain. This is guaranteed in e.g. most FPGAs,
-- but may need to be ensured by design or constraints in other technologies.
--
-- Example writes (param_ADDR_WIDTH=3, param_ALMOST_FULL_OFFSET=2):
--
-- W_RST_I   ~~\___________________________________________________________
-- W_CLK_I   /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
-- W_EN_I    __/~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\_____/~\___/~~~~~\___/~~~~~\_
-- W_DATA_I  ==<0|1|2|3|4|5|6|7|  8  |9|A|B|C>=====<D>===<E|F|G>===<H|I|J>=
-- W_READY_O __/~~~~~~~~~~~~~~~\___/~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- W_FULL_O  ~~\_______________/~~~\_______________________________________
-- W_AL..L_O ~~\___________/~~~~~~~~~~~\___/~\_________________________/~~~
-- W_COUNT_O 0 |8|7|6|5|4|3|2|1| 0 |3|2|4|3|2| 5 | 7 |  6  |5|   4   |3| 2 
--
-- Example reads (param_ADDR_WIDTH=3, param_ALMOST_EMPTY_OFFSET=4):
--
-- R_RST_I   ~~\___________________________________________________________
-- R_CLK_I   /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
-- R_EN_I    ________/~~~~~~~~~~~~~~~~~~~~~\_/~~~\_/~~~~~~~\___/~~~~~~~~~~~
-- R_DATA_I  ======< 0 |1|2|3|4|5|6|7|8>=<9| A |B| C |D|E|F|  G  |H|I|J>===
-- R_READY_O ______/~~~~~~~~~~~~~~~~~~~\_/~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\___
-- R_EMPTY_O ~~~~~~\___________________/~\_____________________________/~~~
-- R_AL..Y_O ~~~~~~~~\_________/~~~~~~~~~\_/~\___/~~~~~\___/~~~~~~~~~~~~~~~
-- R_COUNT_O   0   |4|8|7|6|6|5|4|3|2|1|0|5|4|6|5| 4 |3|6|5|  4  |3|2|1| 0

entity FIFO is
  generic (
    param_ADDR_WIDTH          : positive := 3;
    param_ADDR_WIDTH_WARNING  : boolean  := true;
    param_DATA_WIDTH          : positive := 32;
    param_ALMOST_FULL_OFFSET  : positive := 1;
    param_ALMOST_EMPTY_OFFSET : positive := 1;
    param_SYNCHRONOUS         : boolean  := false
    );
  port (

    -- Write Interface
    W_RST_I         : in  std_logic := '0';
    W_CLK_I         : in  std_logic;
    W_EN_I          : in  std_logic;
    W_DATA_I        : in  std_logic_vector(param_DATA_WIDTH-1 downto 0);
    W_READY_O       : out std_logic;
    W_FULL_O        : out std_logic;
    W_ALMOST_FULL_O : out std_logic;
    W_COUNT_O       : out std_logic_vector(param_ADDR_WIDTH downto 0);

    -- Read Interface
    R_RST_I          : in  std_logic := '0';
    R_CLK_I          : in  std_logic;
    R_EN_I           : in  std_logic;
    R_DATA_O         : out std_logic_vector(param_DATA_WIDTH-1 downto 0);
    R_READY_O        : out std_logic;
    R_EMPTY_O        : out std_logic;
    R_ALMOST_EMPTY_O : out std_logic;
    R_COUNT_O        : out std_logic_vector(param_ADDR_WIDTH downto 0)

    );
end entity;

architecture rtl of FIFO is

  -- Internal reset signals
  signal w_r_rst : std_logic := '0';
  signal r_w_rst : std_logic := '0';
  signal w_rst   : std_logic;
  signal r_rst   : std_logic;

  -- Internal full and empty flags
  signal w_full  : std_logic;
  signal r_empty : std_logic;

  -- RAM write port signals
  signal ram_w_en   : std_logic;
  signal ram_w_addr : std_logic_vector(param_ADDR_WIDTH-1 downto 0);
  signal ram_w_data : std_logic_vector(param_DATA_WIDTH-1 downto 0);

  -- RAM read port signals
  signal ram_r_en   : std_logic;
  signal ram_r_addr : std_logic_vector(param_ADDR_WIDTH-1 downto 0);
  signal ram_r_data : std_logic_vector(param_DATA_WIDTH-1 downto 0);

  -- Read and write pointers, and their boundary-crossed versions
  signal w_ptr   : std_logic_vector(param_ADDR_WIDTH downto 0);
  signal r_ptr   : std_logic_vector(param_ADDR_WIDTH downto 0);
  signal r_w_ptr : std_logic_vector(param_ADDR_WIDTH downto 0);
  signal w_r_ptr : std_logic_vector(param_ADDR_WIDTH downto 0);
  
begin

  -- Validate our address width in synchronous mode
  assert
    not param_SYNCHRONOUS or
    (not param_ADDR_WIDTH_WARNING or param_ADDR_WIDTH >= 2)
    report "ADDR_WIDTH < 2 may result in stalls due to latency"
    severity warning;

  -- Validate our address width in asynchronous mode
  assert
    param_SYNCHRONOUS or
    (not param_ADDR_WIDTH_WARNING or param_ADDR_WIDTH >= 3)
    report "ADDR_WIDTH < 3 may result in stalls due to latency"
    severity warning;

  -- If in asynchronous mode, use AsyncReset blocks to generate clean cross-
  -- boundary resets.
  if_not_SYNCHRONOUS : if not param_SYNCHRONOUS generate
    u_w_r_AsyncReset : entity work.AsyncReset
      port map (
        ASYNC_RST_I => R_RST_I,
        CLK_I       => W_CLK_I,
        RST_O       => w_r_rst
        );
    u_r_w_AsyncReset : entity work.AsyncReset
      port map (
        ASYNC_RST_I => W_RST_I,
        CLK_I       => R_CLK_I,
        RST_O       => r_w_rst
        );
  end generate;

  -- In synchronous mode, cross-boundary resets are just a pass-through.
  if_SYNCHRONOUS : if param_SYNCHRONOUS generate
    w_r_rst <= R_RST_I;
    r_w_rst <= W_RST_I;
  end generate;

  -- Compute each domain's effective reset using the input reset and the
  -- previously generated cross-boundary reset.
  w_rst <= W_RST_I or w_r_rst;
  r_rst <= R_RST_I or r_w_rst;

  -- The FIFO write port implementation.
  u_FIFO_write : entity work.FIFO_write
    generic map (
      param_ADDR_WIDTH         => param_ADDR_WIDTH,
      param_DATA_WIDTH         => param_DATA_WIDTH,
      param_ALMOST_FULL_OFFSET => param_ALMOST_FULL_OFFSET
      )
    port map (
      W_RST_I         => w_rst,
      W_CLK_I         => W_CLK_I,
      W_EN_I          => W_EN_I,
      W_DATA_I        => W_DATA_I,
      W_FULL_O        => w_full,
      W_ALMOST_FULL_O => W_ALMOST_FULL_O,
      W_COUNT_O       => W_COUNT_O,
      RAM_W_EN_O      => ram_w_en,
      RAM_W_ADDR_O    => ram_w_addr,
      RAM_W_DATA_O    => ram_w_data,
      PTR_W_O         => w_ptr,
      PTR_R_I         => w_r_ptr
      );

  -- Generate output write ready and full flags.
  W_READY_O <= not w_full;
  W_FULL_O  <= w_full;

  -- The FIFO read port implementation.
  u_FIFO_read : entity work.FIFO_read
    generic map (
      param_ADDR_WIDTH          => param_ADDR_WIDTH,
      param_DATA_WIDTH          => param_DATA_WIDTH,
      param_ALMOST_EMPTY_OFFSET => param_ALMOST_EMPTY_OFFSET
      )
    port map (
      R_RST_I          => r_rst,
      R_CLK_I          => R_CLK_I,
      R_EN_I           => R_EN_I,
      R_DATA_O         => R_DATA_O,
      R_EMPTY_O        => r_empty,
      R_ALMOST_EMPTY_O => R_ALMOST_EMPTY_O,
      R_COUNT_O        => R_COUNT_O,
      RAM_R_EN_O       => ram_r_en,
      RAM_R_ADDR_O     => ram_r_addr,
      RAM_R_DATA_I     => ram_r_data,
      PTR_W_I          => r_w_ptr,
      PTR_R_O          => r_ptr
      );

  -- Generate output read ready and empty flags.
  R_READY_O <= not r_empty;
  R_EMPTY_O <= r_empty;

  -- The write pointer FIFO boundary.
  u_w_ptr_FIFO_boundary : entity work.FIFO_boundary
    generic map (
      param_ADDR_WIDTH  => param_ADDR_WIDTH,
      param_SYNCHRONOUS => param_SYNCHRONOUS
      )
    port map (
      S_RST_I => w_rst,
      S_CLK_I => W_CLK_I,
      S_PTR_I => w_ptr,
      T_RST_I => r_rst,
      T_CLK_I => R_CLK_I,
      T_PTR_O => r_w_ptr
      );

  -- The read pointer FIFO boundary.
  u_r_ptr_FIFO_boundary : entity work.FIFO_boundary
    generic map (
      param_ADDR_WIDTH  => param_ADDR_WIDTH,
      param_SYNCHRONOUS => param_SYNCHRONOUS
      )
    port map (
      S_RST_I => r_rst,
      S_CLK_I => R_CLK_I,
      S_PTR_I => r_ptr,
      T_RST_I => w_rst,
      T_CLK_I => W_CLK_I,
      T_PTR_O => w_r_ptr
      );

  -- The actual FIFO data storage dual-port RAM.
  u_RAM : entity work.RAM
    generic map (
      param_ADDR_WIDTH => param_ADDR_WIDTH,
      param_DATA_WIDTH => param_DATA_WIDTH
      )
    port map (
      A_CLK_I  => W_CLK_I,
      A_EN_I   => ram_w_en,
      A_ADDR_I => ram_w_addr,
      A_WE_I   => ram_w_en,
      A_DATA_I => ram_w_data,
      B_CLK_I  => R_CLK_I,
      B_EN_I   => ram_r_en,
      B_ADDR_I => ram_r_addr,
      B_DATA_O => ram_r_data
      );

end architecture;
