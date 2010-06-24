LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY shift_reg IS
Generic( N : natural := 15;
	 M : natural := 5);
port (   X : in    std_logic_vector(N  downto 0); -- 18-bit register
         Z : out  std_logic_vector(N  downto 0);
        ce: in   std_logic;
        clk : in std_logic);
END shift_reg;

ARCHITECTURE arch OF shift_reg IS

SUBTYPE sr_width IS STD_LOGIC_VECTOR(N DOWNTO 0);
TYPE sr_length IS ARRAY (M-1 DOWNTO 0) OF sr_width;

SIGNAL sr : sr_length;

BEGIN
    PROCESS (clk)
    BEGIN
        IF (clk'EVENT and clk = '1') THEN
            IF (ce = '1') THEN
                sr(M-1 DOWNTO 1) <= sr(M-2 DOWNTO 0);
                sr(0) <= X;
            END IF;
        END IF;
    END PROCESS;

    Z <= sr(M-1);

END arch;
