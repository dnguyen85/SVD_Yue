library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-------------------------------------------------------------------------------------
--
--
-- Definition of Ports
-- FSL_Clk		: Synchronous clock
-- FSL_Rst		: System reset, should always come from FSL bus
-- FSL_S_Clk		: Slave asynchronous clock
-- FSL_S_Read		: Read signal, requiring next available input to be read
-- FSL_S_Data		: Input data
-- FSL_S_CONTROL	: Control Bit, indicating the input data are control word
-- FSL_S_Exists	 	: Data Exist Bit, indicating data exist in the input FSL bus
-- FSL_M_Clk		: Master asynchronous clock
-- FSL_M_Write		: Write signal, enabling writing to output FSL bus
-- FSL_M_Data		: Output data
-- FSL_M_Control	: Control Bit, indicating the output data are contol word
-- FSL_M_Full		: Full Bit, indicating output FSL bus is full
--
-------------------------------------------------------------------------------
entity v5fsl is
	port (
		FSL_Clk		: in	std_logic;
		FSL_Rst		: in	std_logic;
		FSL_S_Clk	: out	std_logic;
		FSL_S_Read	: out	std_logic;
		FSL_S_Data	: in	std_logic_vector(0 to 31);
		FSL_S_Control	: in	std_logic;
		FSL_S_Exists	: in	std_logic;
		FSL_M_Clk	: out	std_logic;
		FSL_M_Write	: out	std_logic;
		FSL_M_Data	: out	std_logic_vector(0 to 31);
		FSL_M_Control	: out	std_logic;
		FSL_M_Full	: in	std_logic);

attribute SIGIS : string; 
attribute SIGIS of FSL_Clk : signal is "Clk"; 
attribute SIGIS of FSL_S_Clk : signal is "Clk"; 
attribute SIGIS of FSL_M_Clk : signal is "Clk"; 

end v5fsl;

architecture EXAMPLE of v5fsl is

	-- Total number of input data.
	constant NUMBER_OF_INPUT_WORDS  : natural := 3;

	-- Total number of output data
	constant NUMBER_OF_OUTPUT_WORDS : natural := 9;

	type STATE_TYPE is (Idle, Read_Inputs, Compute, Write_Outputs);

	signal state		: STATE_TYPE;
	
	---signal to CORDIC
	signal datain: std_logic_vector(0 to 95);
	signal dataout, output: std_logic_vector(0 to 287);
	signal count : natural range 0 to 23;
	signal fifo1_in, fifo2_in, fifo3_in : std_logic_vector(0 to 31);
	signal w_en_3, w_en_2, w_en_1,w_full_3, w_full_2, w_full_1, rdy, ce, in_rdy, in_drop, output_full, empty, read_output,out_rdy, fifo1_out_rdy, fifo2_out_rdy, fifo3_out_rdy, output_rdy: std_logic;
	
	-- Counters to store the number inputs read & outputs written
	signal nr_of_reads  : natural range 0 to NUMBER_OF_INPUT_WORDS - 1;
	signal nr_of_writes : natural range 0 to NUMBER_OF_OUTPUT_WORDS - 1;


component FIFO is
  generic (
	param_ADDR_WIDTH		: positive := 3;
	param_ADDR_WIDTH_WARNING  	: boolean  := true;
	param_DATA_WIDTH		: positive := 32;
	param_ALMOST_FULL_OFFSET  	: positive := 1;
	param_ALMOST_EMPTY_OFFSET 	: positive := 1;
	param_SYNCHRONOUS	 	: boolean  := false);
  port (
	-- Write Interface
	W_RST_I	 	: in  std_logic := '0';
	W_CLK_I	 	: in  std_logic;
	W_EN_I		: in  std_logic;
	W_DATA_I	: in  std_logic_vector(param_DATA_WIDTH-1 downto 0);
	W_READY_O	: out std_logic;
	W_FULL_O	: out std_logic;
	W_ALMOST_FULL_O : out std_logic;
	W_COUNT_O	: out std_logic_vector(param_ADDR_WIDTH downto 0);

	-- Read Interface
	R_RST_I		: in  std_logic := '0';
	R_CLK_I		: in  std_logic;
	R_EN_I		: in  std_logic;
	R_DATA_O	: out std_logic_vector(param_DATA_WIDTH-1 downto 0);
	R_READY_O	: out std_logic;
	R_EMPTY_O	: out std_logic;
	R_ALMOST_EMPTY_O: out std_logic;
	R_COUNT_O	: out std_logic_vector(param_ADDR_WIDTH downto 0));
  end component;

begin
	FSL_S_Read  <= FSL_S_Exists   when (state = Read_Inputs) else '0';
	FSL_M_Write <= (not FSL_M_Full) when (state = Write_Outputs) else '0';
	
	in_rdy <= '1' when state = Read_Inputs and (w_full_1 = '1' and w_full_2 = '1' and w_full_3 = '1');
	read_output <= '1' when (state = Write_Outputs and nr_of_writes = 0) else '0' when state = Write_Outputs and nr_of_writes > 0;
	out_rdy <= rdy when state = Compute else '0';
--FSM 
The_SW_accelerator : process (FSL_Clk) is
	begin  -- process The_SW_accelerator
	 if FSL_Clk'event and FSL_Clk = '1' then	 -- Rising clock edge
		if FSL_Rst = '1' then			-- Synchronous reset (active high)
			-- CAUTION: make sure your reset polarity is consistent with the
			-- system reset polarity
			state		<= Idle;
			nr_of_reads  <= 0;
			nr_of_writes <= 0;
			count 		<= 10;
		else
			case state is
			 when Idle =>
				if (FSL_S_Exists = '1') then
					nr_of_reads 	<= NUMBER_OF_INPUT_WORDS - 1;
					nr_of_writes <= NUMBER_OF_OUTPUT_WORDS - 1;
					w_en_3 <= '0';
					w_en_2 <= '0';
					w_en_1 <= '0';
					state		<= Read_Inputs;
					count 		<= 10;
				end if;

			 when Read_Inputs =>
				if (FSL_S_Exists = '1') then
					case nr_of_reads is 
						when 0 => 
							 
							 if (in_rdy ='1') then
								w_en_3 <= '0';
								w_en_2 <= '0';
								w_en_1 <= '0';
								if count = 0 then
									state <= Compute;
									in_drop <='1';
									ce <= '1';
								else
									count <= count - 1;
								end if;
							 else
							 	fifo3_in <= FSL_S_Data;
								 w_en_3 <= '1';
								 w_en_2 <= '0';
								 w_en_1 <= '0';
							 	nr_of_reads <= 2;
							 end if;
							 
						when 1 => 
							 fifo2_in <= FSL_S_Data;
							 w_en_3 <= '0';
							 w_en_2 <= '1';
							 w_en_1 <= '0';
							 nr_of_reads <= nr_of_reads - 1;
							 
						when 2 => 
							 fifo1_in <= FSL_S_Data;
							 w_en_3 <= '0';
							 w_en_2 <= '0';
							 w_en_1 <= '1';
							 nr_of_reads <= nr_of_reads - 1;
							 
						when others =>
							 null;
					end case;				
				end if;
				
			when Compute =>
			
				if output_full = '1' then
					in_drop <= '0';
					state <= Write_Outputs;
					ce <= '0';
					nr_of_writes <= NUMBER_OF_OUTPUT_WORDS - 1;
				else 
					state <= Compute;
				end if;

			when Write_Outputs =>
				if (FSL_M_Full = '0') then
					case nr_of_writes is
						when 0 =>
							FSL_M_Data <= output(256 to 287);
							if empty = '1' then
								state <= Idle;
							else
						 		nr_of_writes <= 8;
						 	end if;
						when 1 =>
							 FSL_M_Data <= output(224 to 255);
							 nr_of_writes <= nr_of_writes - 1;					 
				
						when 2 =>
							 FSL_M_Data <= output(192 to 223);
							 nr_of_writes <= nr_of_writes - 1;					 

						when 3 =>
							 FSL_M_Data <= output(160 to 191);
							 nr_of_writes <= nr_of_writes - 1;					 

						when 4 =>
							 FSL_M_Data <= output(128 to 159);
							 nr_of_writes <= nr_of_writes - 1;					 

						when 5 =>
							 FSL_M_Data <= output(96 to 127);
							 nr_of_writes <= nr_of_writes - 1;					 

						when 6 =>
							 FSL_M_Data <= output(64 to 95);
							 nr_of_writes <= nr_of_writes - 1;	

						when 7 =>
							 FSL_M_Data <= output(32 to 63);
							 nr_of_writes <= nr_of_writes - 1;					 

						when 8 =>
							 FSL_M_Data <= output(0 to 31);
							 nr_of_writes <= nr_of_writes - 1;
						when others =>
							null;			 

					end case;
				end if;
		end case;

		end if;

	 end if;
	end process The_SW_accelerator;

rdy <=ce;
dataout <= datain&datain&datain;

i_fifo1: FIFO generic map(
	param_ADDR_WIDTH		=>  4,
	param_ADDR_WIDTH_WARNING  	=>  true,
	param_DATA_WIDTH		=>  32,
	param_ALMOST_FULL_OFFSET 	=>  1,
	param_ALMOST_EMPTY_OFFSET 	=>  1,
	param_SYNCHRONOUS	 	=>  true
  ) port map (
	-- Write Interface
	W_RST_I	 	=> FSL_Rst,
	W_CLK_I	 	=> FSL_Clk,
	W_EN_I		=> w_en_1,
	W_DATA_I	=> fifo1_in,
	W_READY_O	=> open,
	W_FULL_O	=> w_full_1,
	W_ALMOST_FULL_O => open,
	W_COUNT_O	=> open,

	-- Read Interface
	R_RST_I		=> FSL_Rst,
	R_CLK_I		=> FSL_Clk,
	R_EN_I		=> in_drop,
	R_DATA_O	=> datain(0 to 31),
	R_READY_O	=> fifo1_out_rdy,
	R_EMPTY_O	=> open,
	R_ALMOST_EMPTY_O=> open,
	R_COUNT_O	=> open
  );
--fifo2
  i_fifo2: FIFO generic map(
	param_ADDR_WIDTH		=>  4,
	param_ADDR_WIDTH_WARNING  	=>  true,
	param_DATA_WIDTH		=>  32,
	param_ALMOST_FULL_OFFSET  	=>  1,
	param_ALMOST_EMPTY_OFFSET 	=>  1,
	param_SYNCHRONOUS		=>  true
  ) port map (
	-- Write Interface
	W_RST_I	 	=> FSL_Rst,
	W_CLK_I	 	=> FSL_Clk,
	W_EN_I		=> w_en_2,
	W_DATA_I	=> fifo2_in,
	W_READY_O	=> open,
	W_FULL_O	=> w_full_2,
	W_ALMOST_FULL_O => open,
	W_COUNT_O	=> open,

	-- Read Interface
	R_RST_I		=> FSL_Rst,
	R_CLK_I		=> FSL_Clk,
	R_EN_I		=> in_drop,
	R_DATA_O	=> datain(32 to 63),
	R_READY_O	=> fifo2_out_rdy,
	R_EMPTY_O	=> open,
	R_ALMOST_EMPTY_O=> open,
	R_COUNT_O	=> open
  );
  
--fifo3
  i_fifo3: FIFO generic map(
	param_ADDR_WIDTH		=>  4,
	param_ADDR_WIDTH_WARNING  	=>  true,
	param_DATA_WIDTH		=>  32,
	param_ALMOST_FULL_OFFSET  	=>  1,
	param_ALMOST_EMPTY_OFFSET 	=>  1,
	param_SYNCHRONOUS	 	=>  true
  ) port map (
	-- Write Interface
	W_RST_I	 	=> FSL_Rst,
	W_CLK_I	 	=> FSL_Clk,
	W_EN_I		=> w_en_3,
	W_DATA_I	=> fifo3_in,
	W_READY_O	=> open,
	W_FULL_O	=> w_full_3,
	W_ALMOST_FULL_O => open,
	W_COUNT_O	=> open,

	-- Read Interface
	R_RST_I		=> FSL_Rst,
	R_CLK_I		=> FSL_Clk,
	R_EN_I		=> in_drop,
	R_DATA_O	=> datain(64 to 95),
	R_READY_O	=> fifo3_out_rdy,
	R_EMPTY_O	=> open,
	R_ALMOST_EMPTY_O=> open,
	R_COUNT_O	=> open
  );

--fifoo
  o_fifo1: FIFO generic map(
	param_ADDR_WIDTH		=>  4,
	param_ADDR_WIDTH_WARNING  	=>  true,
	param_DATA_WIDTH		=>  288,
	param_ALMOST_FULL_OFFSET  	=>  1,
	param_ALMOST_EMPTY_OFFSET 	=>  1,
	param_SYNCHRONOUS	 	=>  true
  ) port map (
	-- Write Interface
	W_RST_I	 	=> FSL_Rst,
	W_CLK_I	 	=> FSL_Clk,
	W_EN_I		=> out_rdy,
	W_DATA_I	=> dataout,
	W_READY_O	=> output_rdy,
	W_FULL_O	=> output_full,
	W_ALMOST_FULL_O => open,
	W_COUNT_O	=> open,

	-- Read Interface
	R_RST_I		=> FSL_Rst,
	R_CLK_I		=> FSL_Clk,
	R_EN_I		=> read_output,
	R_DATA_O	=> output,
	R_READY_O	=> open,
	R_EMPTY_O	=> empty,
	R_ALMOST_EMPTY_O=> open,
	R_COUNT_O	=> open
  );
end architecture EXAMPLE;
