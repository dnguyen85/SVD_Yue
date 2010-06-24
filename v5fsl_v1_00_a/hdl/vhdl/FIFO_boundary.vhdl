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

-- Gray-code-based FIFO pointer boundary-crossing.
--
-- Asynchronous latency: 1 write clock plus 1.5 to 2 read clocks.
-- Synchronous  latency: 1 clock cycle.
--
-- Required timing constraints:
--
-- From W_CLK_I to R_CLK_I in period(R_CLK_I).
-- From R_CLK_I to W_CLK_I in period(W_CLK_I).
--
-- The source clock period may not be smaller than the setup time plus hold
-- time of the target clock domain. This is guaranteed in e.g. most FPGAs,
-- but may need to be ensured by design or constraints in other technologies.

entity FIFO_boundary is
  generic (
    param_ADDR_WIDTH  : natural := 4;
    param_SYNCHRONOUS : boolean := false
    );
  port (

    -- Source Interface
    S_RST_I : in std_logic;
    S_CLK_I : in std_logic;
    S_PTR_I : in std_logic_vector(param_ADDR_WIDTH downto 0);

    -- Target Interface
    T_RST_I : in  std_logic;
    T_CLK_I : in  std_logic;
    T_PTR_O : out std_logic_vector(param_ADDR_WIDTH downto 0) := (others => '0')
    );

end entity;

architecture rtl of FIFO_boundary is
begin

  -- In synchronous mode, boundary crossing is just a single register stage.
  if_SYNCHRONOUS : if param_SYNCHRONOUS generate
    process (S_CLK_I, S_RST_I) is
    begin
      if S_RST_I = '1' then
        T_PTR_O <= (others => '0');
      elsif rising_edge(S_CLK_I) then
        T_PTR_O <= S_PTR_I;
      end if;
    end process;
  end generate;

  -- In asynchronous mode, boundary crossing consists of generating a Gray
  -- code from the pointer in the source domain, synchronizing the Gray code
  -- into the target clock domain, then reconstructing the binary pointer.
  if_not_SYNCHRONOUS : if not param_SYNCHRONOUS generate
    block_gray : block is
      signal w_gray   : std_logic_vector(S_PTR_I'range);
      signal w_gray_d : std_logic_vector(S_PTR_I'range) := (others => '0');
      signal r_gray   : std_logic_vector(T_PTR_O'range);
      signal r_bin    : std_logic_vector(T_PTR_O'range);
    begin

      -- Generate a Gray code from the source pointer.
      u_w_gray : entity work.Binary2Gray
        generic map (
          param_WIDTH => param_ADDR_WIDTH+1
          )
        port map (
          BINARY_I => S_PTR_I,
          GRAY_O   => w_gray
          );

      -- Generate a registered, glitch-free version of the Gray code in the
      -- source domain. Because we want to get the pointer to the target
      -- domain as soon as possible, we register on the same rising edge as
      -- the pointer is updated in the source clock domain. This works
      -- because when the pointer is about to be incremented, our input
      -- pointer is pre-incremented by the FIFO port blocks.
      proc_w_gray_d : process (S_CLK_I, S_RST_I) is
      begin
        if S_RST_I = '1' then
          w_gray_d <= (others => '0');
        elsif rising_edge(S_CLK_I) then
          w_gray_d <= w_gray;
        end if;
      end process;

      -- For each bit in the Gray code, synchronize into the target clock
      -- domain with Synchronizer blocks. Although it's possible for these
      -- filters to be delayed because of metastability, we are guaranteed
      -- that we will never have two metastable filters -- and thus a
      -- potentially invalid pointer -- because our Gray code (along with our
      -- required timing constraints) ensures that only one bit can ever
      -- change at a time during a potential metastability window.
      for_r_gray : for i in r_gray'range generate
        u_Synchronizer : entity work.Synchronizer
          port map (
            RST_I   => T_RST_I,
            CLK_I   => T_CLK_I,
            ASYNC_I => w_gray_d(i),
            SYNC_O  => r_gray(i)
            );        
      end generate;

      -- Now we convert the synchronized Gray code back into binary.
      u_r_bin : entity work.Gray2Binary
        generic map (
          param_WIDTH => param_ADDR_WIDTH+1
          )
        port map (
          GRAY_I   => r_gray,
          BINARY_O => r_bin
          );

      -- Finally, we register the outgoing pointer, since Gray to binary
      -- conversion is logic-level intensive. Again, because we want to be
      -- able to use this pointer as soon as possible, we register on the
      -- falling edge of the target clock. We could reduce latency by
      -- synchronizing directly onto the target clock falling edge and
      -- skipping this register stage completely, but that would make it
      -- difficult to meet timing and wouldn't reduce latency enough to
      -- change overall FIFO minimum address width requirements.
      proc_r_ptr : process (T_CLK_I, T_RST_I) is
      begin
        if T_RST_I = '1' then
          T_PTR_O <= (others => '0');
        elsif falling_edge(T_CLK_I) then
          T_PTR_O <= r_bin;
        end if;
      end process;
      
    end block;
  end generate;

end architecture;
