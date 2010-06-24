----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:00:09 04/05/2009 
-- Design Name: 
-- Module Name:    CORDIC - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
--
-- ARCTAN 23 clk
-- P2R/R2P 28 clk
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.STD_LOGIC_ARITH.ALL;
--use IEEE.STD_LOGIC_SIGNED.ALL;
use IEEE.NUMERIC_STD.all;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity CORDIC is
    Generic( N : natural := 11; ARC : natural := 16; PR : natural := 19); --ARC is the latency of arctan. PR is the latency of p2r and r2p
    Port ( a_r : in  STD_LOGIC_VECTOR (N downto 0);
           a_i : in  STD_LOGIC_VECTOR (N  downto 0);
           b_r : in  STD_LOGIC_VECTOR (N downto 0);
           b_i : in  STD_LOGIC_VECTOR (N downto 0);
           c_r : in  STD_LOGIC_VECTOR (N downto 0);
           c_i : in  STD_LOGIC_VECTOR (N downto 0);
           d_r : in  STD_LOGIC_VECTOR (N downto 0);
           d_i : in  STD_LOGIC_VECTOR (N downto 0);
           U_H_w_r : out  STD_LOGIC_VECTOR (N downto 0);
           U_H_w_i : out  STD_LOGIC_VECTOR (N downto 0);
           U_H_x_r : out  STD_LOGIC_VECTOR (N downto 0);
           U_H_x_i : out  STD_LOGIC_VECTOR (N downto 0);
           U_H_y_r : out  STD_LOGIC_VECTOR (N downto 0);
           U_H_y_i : out  STD_LOGIC_VECTOR (N downto 0);
           U_H_z_r : out  STD_LOGIC_VECTOR (N downto 0);
           U_H_z_i : out  STD_LOGIC_VECTOR (N downto 0);
           p_r : out  STD_LOGIC_VECTOR (N downto 0);
           p_i : out  STD_LOGIC_VECTOR (N downto 0);
           s_r : out  STD_LOGIC_VECTOR (N downto 0);
           s_i : out  STD_LOGIC_VECTOR (N downto 0);
           r_r : out  STD_LOGIC_VECTOR (N downto 0);
           r_i : out  STD_LOGIC_VECTOR (N downto 0);
           q_r : out  STD_LOGIC_VECTOR (N downto 0);
           q_i : out  STD_LOGIC_VECTOR (N downto 0);
           V_w_r : out  STD_LOGIC_VECTOR (N downto 0);
           V_w_i : out  STD_LOGIC_VECTOR (N downto 0);
           V_x_r : out  STD_LOGIC_VECTOR (N downto 0);
           V_x_i : out  STD_LOGIC_VECTOR (N downto 0);
           V_y_r : out  STD_LOGIC_VECTOR (N downto 0);
           V_y_i : out  STD_LOGIC_VECTOR (N downto 0);
           V_z_r : out  STD_LOGIC_VECTOR (N downto 0);
           V_z_i : out  STD_LOGIC_VECTOR (N downto 0);
	   ce: IN std_logic;
	   clk: IN std_logic;
	   sclr: IN std_logic;
	   rdy: OUT std_logic);
end CORDIC;

architecture Behavioral of CORDIC is
component my_reg is
port (    X : in    std_logic;
         Z : out  std_logic;
        en, ck : in   std_logic);
end component;

component p2r_w is
	Generic( N : natural := 15);
	port (
	x_in: IN std_logic_VECTOR(N downto 0);
	y_in: IN std_logic_VECTOR(N downto 0);
	phase_in: IN std_logic_VECTOR(N downto 0);
	x_out: OUT std_logic_VECTOR(N downto 0);
	y_out: OUT std_logic_VECTOR(N downto 0);
	ce: IN std_logic;
	rdy: OUT std_logic;
	sclr: IN std_logic;
	clk: IN std_logic);
end component;

component stage_I is
	Generic( N : natural := 15);
    Port ( A : in  STD_LOGIC_VECTOR (N  downto 0);
           theta_A : in  STD_LOGIC_VECTOR (N  downto 0);
           B : in  STD_LOGIC_VECTOR (N  downto 0);
           theta_B : in  STD_LOGIC_VECTOR (N  downto 0);
           C : in  STD_LOGIC_VECTOR (N  downto 0);
           theta_C : in  STD_LOGIC_VECTOR (N  downto 0);
           D : in  STD_LOGIC_VECTOR (N  downto 0);
           theta_D : in  STD_LOGIC_VECTOR (N  downto 0);
           A_II : out  STD_LOGIC_VECTOR (N downto 0);
           theta_A_II : out  STD_LOGIC_VECTOR (N downto 0);
           B_II : out  STD_LOGIC_VECTOR (N downto 0);
           theta_B_II : out  STD_LOGIC_VECTOR (N downto 0);
           C_II : out  STD_LOGIC_VECTOR (N downto 0);
           theta_C_II : out  STD_LOGIC_VECTOR (N downto 0);
           D_II : out  STD_LOGIC_VECTOR (N downto 0);
           theta_D_II : out  STD_LOGIC_VECTOR (N downto 0);
	   ce: IN std_logic;
	   rdy: OUT std_logic;
	   clk: IN std_logic);
end component;

component MUX_1 is
    Generic( N : natural := 15);
    Port ( theta_c : in  STD_LOGIC_VECTOR (N downto 0);
           theta_d : in  STD_LOGIC_VECTOR (N downto 0);
           theta_alpha : out  STD_LOGIC_VECTOR (N downto 0);
           theta_beta : out  STD_LOGIC_VECTOR (N downto 0);
           theta_gamma : out  STD_LOGIC_VECTOR (N downto 0);
           theta_delta : out  STD_LOGIC_VECTOR (N downto 0);
           ce : in std_logic;
           rdy : out  std_logic;
           clk : in std_logic);
end component;

component MUX_0 is
    Generic( N : natural := 15);
    Port ( X : in STD_LOGIC_VECTOR (N downto 0);
           theta_m : in  STD_LOGIC_VECTOR (N downto 0);
           theta_1 : in  STD_LOGIC_VECTOR (N downto 0);
           theta_2 : in  STD_LOGIC_VECTOR (N downto 0);
           Z : out  STD_LOGIC_VECTOR (N downto 0);
           theta_out : out  STD_LOGIC_VECTOR (N downto 0);
           ce : in std_logic;
           rdy : out  std_logic;
           clk : in std_logic);
end component;

component r2p_w is
	Generic( N : natural := 15);
	port (
	x_in: IN std_logic_VECTOR(N downto 0);
	y_in: IN std_logic_VECTOR(N downto 0);
	x_out: OUT std_logic_VECTOR(N downto 0);
	phase_out: OUT std_logic_VECTOR(N downto 0);
	ce: IN std_logic;
	rdy: OUT std_logic;
	sclr: IN std_logic;
	clk: IN std_logic);
end component;

component shift_reg IS
Generic( N : natural := 15;
	 M : natural := 4);
port (    X : in    std_logic_vector(N  downto 0); -- 15-bit register
         Z : out  std_logic_vector(N  downto 0);
        ce: in   std_logic;
        clk : in std_logic);
END component;

component arctan_w is
	Generic( N : natural := 15);
	port (
	x_in: IN std_logic_VECTOR(N downto 0);
	y_in: IN std_logic_VECTOR(N downto 0);
	phase_out: OUT std_logic_VECTOR(N downto 0);
	ce: IN std_logic;
	rdy: OUT std_logic;
	sclr: IN std_logic;
	clk: IN std_logic);
end component;

component MUX_2 is
    Generic( N : natural := 15);
    Port ( theta_w : in  STD_LOGIC_VECTOR (N downto 0);
           theta_x : in  STD_LOGIC_VECTOR (N downto 0);
           theta_xi : out  STD_LOGIC_VECTOR (N downto 0);
           theta_eta : out  STD_LOGIC_VECTOR (N downto 0);
           theta_zeta : out  STD_LOGIC_VECTOR (N downto 0);
           theta_omega : out  STD_LOGIC_VECTOR (N downto 0);
           ce : in std_logic;
           rdy : out  std_logic;
           clk : in std_logic);
end component;

component MUX_3 is
    Generic( N : natural := 15);
    Port ( W : in  STD_LOGIC_VECTOR (N downto 0);
           X : in  STD_LOGIC_VECTOR (N downto 0);
           Y : in  STD_LOGIC_VECTOR (N downto 0);
           Z : in  STD_LOGIC_VECTOR (N downto 0);
           YX_sum : out  STD_LOGIC_VECTOR (N downto 0);
           ZW_diff : out  STD_LOGIC_VECTOR (N downto 0);
           YX_diff : out  STD_LOGIC_VECTOR (N downto 0);
           ZW_sum : out  STD_LOGIC_VECTOR (N downto 0);
           ce : in std_logic;
           rdy : out  std_logic;
           clk : in std_logic);
end component;

component MUX_4 is
    Generic( N : natural := 15);
    Port ( theta_sum : in  STD_LOGIC_VECTOR (N downto 0);
           theta_diff : in  STD_LOGIC_VECTOR (N downto 0);
           theta_lambda_N : out  STD_LOGIC_VECTOR (N downto 0);
           theta_rho : out  STD_LOGIC_VECTOR (N downto 0);
           ce : in std_logic;
           rdy : out  std_logic;
           clk : in std_logic);
end component;

component MUX_5 is
    Generic( N : natural := 15);
    Port ( theta_a : in  STD_LOGIC_VECTOR (N downto 0);
           theta_b : in  STD_LOGIC_VECTOR (N downto 0);
           theta_c : out  STD_LOGIC_VECTOR (N downto 0);
           ce : in std_logic;
           rdy : out  std_logic;
           clk : in std_logic);
end component;

component NSVD is
    Generic( N : natural := 15);
    Port (
    	   p_r : in  STD_LOGIC_VECTOR (N downto 0);
           p_i : in  STD_LOGIC_VECTOR (N downto 0);
           s_r : in  STD_LOGIC_VECTOR (N downto 0);
           s_i : in  STD_LOGIC_VECTOR (N downto 0);
           r_r : in  STD_LOGIC_VECTOR (N downto 0);
           r_i : in  STD_LOGIC_VECTOR (N downto 0);
           q_r : in  STD_LOGIC_VECTOR (N downto 0);
           q_i : in  STD_LOGIC_VECTOR (N downto 0);
           U_p_r : in  STD_LOGIC_VECTOR (N downto 0);
           U_p_i : in  STD_LOGIC_VECTOR (N downto 0);
           U_s_r : in  STD_LOGIC_VECTOR (N downto 0);
           U_s_i : in  STD_LOGIC_VECTOR (N downto 0);
           U_r_r : in  STD_LOGIC_VECTOR (N downto 0);
           U_r_i : in  STD_LOGIC_VECTOR (N downto 0);
           U_q_r : in  STD_LOGIC_VECTOR (N downto 0);
           U_q_i : in  STD_LOGIC_VECTOR (N downto 0);
           V_p_r : in  STD_LOGIC_VECTOR (N downto 0);
           V_p_i : in  STD_LOGIC_VECTOR (N downto 0);
           V_s_r : in  STD_LOGIC_VECTOR (N downto 0);
           V_s_i : in  STD_LOGIC_VECTOR (N downto 0);
           V_r_r : in  STD_LOGIC_VECTOR (N downto 0);
           V_r_i : in  STD_LOGIC_VECTOR (N downto 0);
           V_q_r : in  STD_LOGIC_VECTOR (N downto 0);
           V_q_i : in  STD_LOGIC_VECTOR (N downto 0);
           p_r_II : out  STD_LOGIC_VECTOR (N downto 0);
           p_i_II : out  STD_LOGIC_VECTOR (N downto 0);
           s_r_II : out  STD_LOGIC_VECTOR (N downto 0);
           s_i_II : out  STD_LOGIC_VECTOR (N downto 0);
           r_r_II : out  STD_LOGIC_VECTOR (N downto 0);
           r_i_II : out  STD_LOGIC_VECTOR (N downto 0);
           q_r_II : out  STD_LOGIC_VECTOR (N downto 0);
           q_i_II : out  STD_LOGIC_VECTOR (N downto 0);
           U_p_r_II : out  STD_LOGIC_VECTOR (N downto 0);
           U_p_i_II : out  STD_LOGIC_VECTOR (N downto 0);
           U_s_r_II : out  STD_LOGIC_VECTOR (N downto 0);
           U_s_i_II : out  STD_LOGIC_VECTOR (N downto 0);
           U_r_r_II : out  STD_LOGIC_VECTOR (N downto 0);
           U_r_i_II : out  STD_LOGIC_VECTOR (N downto 0);
           U_q_r_II : out  STD_LOGIC_VECTOR (N downto 0);
           U_q_i_II : out  STD_LOGIC_VECTOR (N downto 0);
           V_p_r_II : out  STD_LOGIC_VECTOR (N downto 0);
           V_p_i_II : out  STD_LOGIC_VECTOR (N downto 0);
           V_s_r_II : out  STD_LOGIC_VECTOR (N downto 0);
           V_s_i_II : out  STD_LOGIC_VECTOR (N downto 0);
           V_r_r_II : out  STD_LOGIC_VECTOR (N downto 0);
           V_r_i_II : out  STD_LOGIC_VECTOR (N downto 0);
           V_q_r_II : out  STD_LOGIC_VECTOR (N downto 0);
           V_q_i_II : out  STD_LOGIC_VECTOR (N downto 0);
	   ce: IN std_logic;
	   rdy: OUT std_logic;
	   clk: IN std_logic);
end component;

signal zero, one : std_logic_VECTOR(N downto 0);
--stage 1
--signal a_r_II, a_i_II, b_r_II, b_i_II, c_r_II, c_i_II, d_r_II, d_i_II : std_logic_VECTOR(N downto 0);
signal ce_1_I : std_logic;
signal A_l, theta_A_I, B_l, theta_B_I, C_l, theta_C_I, D_l, theta_D_I : std_logic_VECTOR(N downto 0);

signal A_II, theta_A_II, B_II, theta_B_II, C_II, theta_C_II, D_II, theta_D_II : std_logic_VECTOR(N downto 0);
signal ce_1_II : std_logic;
signal theta_alpha, theta_beta, theta_gamma, theta_delta: STD_LOGIC_VECTOR (N downto 0);

signal A_III, B_III, C_III, D_III : std_logic_VECTOR(N downto 0);
signal theta_A_prime, theta_B_prime, theta_C_prime, theta_D_prime: STD_LOGIC_VECTOR (N downto 0);  
signal ce_1_III : std_logic;

--stage 2
signal a_r_prime, a_i_prime, b_r_prime, b_i_prime, c_r_prime, c_i_prime, d_r_prime, d_i_prime : STD_LOGIC_VECTOR (N downto 0);
signal theta_psi_1_2 : STD_LOGIC_VECTOR (N downto 0);
signal theta_alpha_prime, theta_gamma_prime, theta_delta_prime: STD_LOGIC_VECTOR (N downto 0);
--signal ce_2 : std_logic;
signal ce_psi_1_2 : std_logic;
--stage 3 
signal theta_psi_3 : STD_LOGIC_VECTOR (N downto 0);
signal ce_3 : std_logic;
--stage 4 
signal w_r, w_i, x_r, x_i, y_r, y_i, z_r, z_i : STD_LOGIC_VECTOR (N downto 0);
signal theta_psi_4 : STD_LOGIC_VECTOR (N downto 0);
signal ce_3_I, ce_4, ce_4_I : std_logic;
signal V_a_r_4, V_a_i_4, V_d_r_4, V_d_i_4: STD_LOGIC_VECTOR (N downto 0);

--stage 5 
signal W_l, X_l, Y_l, Z_l, theta_W_I, theta_X_I, theta_Y_I, theta_Z_I : STD_LOGIC_VECTOR (N downto 0);
signal ce_5_I : std_logic;
signal V_a_r_5, V_a_i_5, V_b_r_5, V_b_i_5, V_c_r_5, V_c_i_5, V_d_r_5, V_d_i_5 : STD_LOGIC_VECTOR (N downto 0);

signal W_II, X_II, Y_II, Z_II, theta_W_II, theta_X_II, theta_Y_II, theta_Z_II : STD_LOGIC_VECTOR (N downto 0);
signal theta_xi, theta_eta, theta_zeta, theta_omega : STD_LOGIC_VECTOR (N downto 0);
signal theta_a_U_5, theta_d_U_5 : STD_LOGIC_VECTOR (N downto 0);
signal ce_5_II : std_logic;

signal W_III, X_III, Y_III, Z_III : STD_LOGIC_VECTOR (N downto 0);
signal theta_W_prime, theta_X_prime, theta_Y_prime, theta_Z_prime: STD_LOGIC_VECTOR (N downto 0);
signal theta_a_U_6, theta_d_U_6 : STD_LOGIC_VECTOR (N downto 0);
signal ce_5_III : std_logic;
signal YX_sum, ZW_diff, YX_diff, ZW_sum : STD_LOGIC_VECTOR (N downto 0);
--stage 6 
signal w_r_prime, w_i_prime, x_r_prime, x_i_prime, y_r_prime, y_i_prime, z_r_prime, z_i_prime : STD_LOGIC_VECTOR (N downto 0);
signal theta_sum, theta_diff, theta_lambda_N_1_6, theta_lambda_N_2_6, theta_rho_1_6, theta_rho_2_6 : STD_LOGIC_VECTOR (N downto 0);
signal theta_zeta_prime, theta_omega_prime: STD_LOGIC_VECTOR (N downto 0);
signal ce_6, ce_sum, ce_6_I : std_logic;
signal ce_lambda_6, ce_rho_1_6 : std_logic;
signal V_W_6, V_X_6, V_Y_6, V_Z_6, V_W_6_i, V_X_6_i, V_Y_6_i, V_Z_6_i, V_theta_W_6, V_theta_X_6, V_theta_Y_6, V_theta_Z_6: STD_LOGIC_VECTOR (N downto 0);
signal U_theta_W, U_theta_Z, U_theta_W_prime, U_theta_Z_prime, V_theta_W_prime, V_theta_X_prime, V_theta_Y_prime, V_theta_Z_prime: STD_LOGIC_VECTOR (N downto 0);
--stage 7 
signal w_r_7, w_i_7, x_r_7, x_i_7, y_r_7, y_i_7, z_r_7, z_i_7 : STD_LOGIC_VECTOR (N downto 0);
signal theta_rho_7, theta_lambda_N_7, theta_rho_s_7, theta_lambda_N_s_7  : STD_LOGIC_VECTOR (N downto 0);
signal ce_7_I, ce_7_II : std_logic;
signal p_r_I, p_i_I, s_r_I, s_i_I, r_r_I, r_i_I, q_r_I, q_i_I : STD_LOGIC_VECTOR (N downto 0);
signal U_w_r_7, U_w_i_7, U_z_r_7, U_z_i_7, V_w_r_7, V_w_i_7, V_x_r_7, V_x_i_7, V_y_r_7, V_y_i_7, V_z_r_7, V_z_i_7 : STD_LOGIC_VECTOR (N downto 0);
signal U_w_r_7_I, U_w_i_7_I, U_x_r_7_I, U_x_i_7_I, U_y_r_7_I, U_y_i_7_I, U_z_r_7_I, U_z_i_7_I, V_w_r_7_I, V_w_i_7_I, V_x_r_7_I, V_x_i_7_I, V_y_r_7_I, V_y_i_7_I, V_z_r_7_I, V_z_i_7_I : STD_LOGIC_VECTOR (N downto 0);

begin
---------12345678901234567890
zero <= (others => '0');

one(N-2 downto 0) <= (others => '0');
one(N downto N-1) <=  "01"; --one <=  "001000000000";
-------------------------------------------------------------1-----------------------------------------------------------------------28
r2p_a_1: r2p_w generic map(N) port map (a_r, a_i, A_l, theta_A_I, ce, open, sclr, clk);
r2p_b_1: r2p_w generic map(N) port map (b_r, b_i, B_l, theta_B_I, ce, open, sclr, clk);
r2p_c_1: r2p_w generic map(N) port map (c_r, c_i, C_l, theta_C_I, ce, open, sclr, clk);
r2p_d_1: r2p_w generic map(N) port map (d_r, d_i, D_l, theta_D_I, ce, ce_1_I, sclr, clk);
-------------------------------------------------------------2------------------------------------------------------------------------1
mux_1_2: MUX_1 generic map(N) port map (theta_C_I, theta_D_I, theta_alpha, theta_beta, theta_gamma, theta_delta, ce_1_I, open, clk);
stage_I_2: stage_I generic map(N) port map (A_l, theta_A_I, B_l, theta_B_I, C_l, theta_C_I, D_l, theta_D_I, A_II, theta_A_II, B_II, theta_B_II, C_II, theta_C_II, D_II, theta_D_II, ce_1_I, ce_1_II, clk);
-------------------------------------------------------------------------------------------------------------------------------------1
mux_0_a_2: MUX_0 generic map(N) port map (A_II, theta_A_II, theta_alpha, theta_gamma, A_III, theta_A_prime, ce_1_II, open,     clk);
mux_0_b_2: MUX_0 generic map(N) port map (B_II, theta_B_II, theta_alpha, theta_delta, B_III, theta_B_prime, ce_1_II, open,     clk);
mux_0_c_2: MUX_0 generic map(N) port map (C_II, theta_C_II, theta_beta,  theta_gamma, C_III, theta_C_prime, ce_1_II, open,     clk); --theta_C_prime is zero anyway
mux_0_d_2: MUX_0 generic map(N) port map (D_II, theta_D_II, theta_beta,  theta_delta, D_III, theta_D_prime, ce_1_II, ce_1_III, clk); --theta_D_prime is zero
------------------------------------------------------------------------------------------------------------------------------------28
p2r_a_2: p2r_w generic map(N) port map (A_III, zero, theta_A_prime, a_r_prime, a_i_prime, ce_1_III, open, sclr, clk);--
p2r_b_2: p2r_w generic map(N) port map (B_III, zero, theta_B_prime, b_r_prime, b_i_prime, ce_1_III, open, sclr, clk);--
p2r_c_2: p2r_w generic map(N) port map (C_III, zero, zero,          c_r_prime, c_i_prime, ce_1_III, open, sclr, clk);--TAKEOUT
p2r_d_2: p2r_w generic map(N) port map (D_III, zero, zero,          d_r_prime, d_i_prime, ce_1_III, ce_3, sclr, clk);--TAKEOUT

arctan_psi_2: arctan_w generic map(N) port map(D_III, C_III, theta_psi_1_2, ce_1_III, ce_psi_1_2, sclr, clk);  --23
shift_reg_5_psi_2: shift_reg generic map(N, (PR-ARC)) port map (theta_psi_1_2, theta_psi_3, ce_psi_1_2, clk); --5
--for U to stage 6 mux_5   cycle = 86 = 3*28+2, alpha is equal with beta.
shift_reg_86_theta_alpha_2to6:  shift_reg generic map(N, 3*PR+2)  port map (theta_alpha, theta_alpha_prime, ce_1_II, clk);  --
--for V to stage 5 p2r clk cycle = 30  = 28+2
shift_reg_58_theta_gamma_2to4:  shift_reg generic map(N, PR+2)    port map (theta_gamma, theta_gamma_prime, ce_1_II, clk);  --
shift_reg_58_theta_delta_2to4:  shift_reg generic map(N, PR+2)    port map (theta_delta, theta_delta_prime, ce_1_II, clk);  --
-------------------------------------------------------------3----------------------------------------------------------------------0
--[ cos(theta_phi) -sin(theta_phi); sin(theta_phi)  cos(theta_phi)] is identity matrix
-------------------------------------------------------------4----------------------------------------------------------------------28
p2r_a_4: p2r_w generic map(N) port map (a_r_prime, b_r_prime, theta_psi_3, w_r, x_r, ce_3, open, sclr, clk); --keep
p2r_b_4: p2r_w generic map(N) port map (c_r_prime, d_r_prime, theta_psi_3, y_r, z_r, ce_3, open, sclr, clk); --keep
p2r_c_4: p2r_w generic map(N) port map (a_i_prime, b_i_prime, theta_psi_3, w_i, x_i, ce_3, open, sclr, clk); --Keep
p2r_d_4: p2r_w generic map(N) port map (c_i_prime, d_i_prime, theta_psi_3, y_i, z_i, ce_3, ce_4, sclr, clk); --TAKEOUT
--V clk cycle 29 = 1*28+1
shift_reg_29_theta_psi_4to5:  shift_reg generic map(N, PR+1)  port map (theta_psi_3, theta_psi_4, ce_3, clk);  --143

shift_reg_1_ce_3:  my_reg port map (ce_3, ce_3_I, ce_3, clk);  --143
--V p2r get from stage 2 to stage 5, convert [exp(1i*theta_gamma)  0; 0  exp(1i*theta_delta)] to rectangular form
p2r_V_a_5: p2r_w generic map(N) port map (one, zero, theta_gamma_prime, V_a_r_4, V_a_i_4, ce_3_I, open, sclr, clk); --keep
p2r_V_d_5: p2r_w generic map(N) port map (one, zero, theta_delta_prime, V_d_r_4, V_d_i_4, ce_3_I, ce_4_I, sclr, clk); --keep
-------------------------------------------------------------5----------------------------------------------------------------------28
--S r2p for Q decomposision
r2p_w_5: r2p_w generic map(N) port map (w_r, w_i, W_l, theta_W_I, ce_4, open, sclr, clk);--
r2p_x_5: r2p_w generic map(N) port map (x_r, x_i, X_l, theta_X_I, ce_4, open, sclr, clk);--
r2p_y_5: r2p_w generic map(N) port map (y_r, y_i, Y_l, theta_Y_I, ce_4, open, sclr, clk);--TAKEOUT
r2p_z_5: r2p_w generic map(N) port map (z_r, z_i, Z_l, theta_Z_I, ce_4, ce_5_I, sclr, clk);--TAKEOUT

--V/4 from stage 5 to stage 6 ([ exp(1i*theta_gamma)  0; 0  exp(1i*theta_delta)]*[ cos(theta_psi)  sin(theta_psi); -sin(theta_psi)  cos(theta_psi)])
p2r_V_a_6: p2r_w generic map(N) port map (V_a_r_4, zero,    theta_psi_4, V_a_r_5, V_b_r_5, ce_4_I, open, sclr, clk); 
p2r_V_b_6: p2r_w generic map(N) port map (zero,    V_d_r_4, theta_psi_4, V_c_r_5, V_d_r_5, ce_4_I, open, sclr, clk); 
p2r_V_c_6: p2r_w generic map(N) port map (V_a_i_4, zero,    theta_psi_4, V_a_i_5, V_b_i_5, ce_4_I, open, sclr, clk); 
p2r_V_d_6: p2r_w generic map(N) port map (zero,    V_d_i_4, theta_psi_4, V_c_i_5, V_d_i_5, ce_4_I, open, sclr, clk); 
-------------------------------------------------------------6------------------------------------------------------------------------1
stage_I_6: stage_I generic map(N) port map (W_l, theta_W_I, X_l, theta_X_I, Y_l, theta_Y_I, Z_l, theta_Z_I,W_II, theta_W_II, X_II, theta_X_II, Y_II, theta_Y_II, Z_II, theta_Z_II, ce_5_I, ce_5_II, clk);

mux_2_6: MUX_2 generic map(N) port map (theta_W_I, theta_X_I, theta_xi, theta_eta, theta_zeta, theta_omega, ce_5_I, open, clk);
-------------------------------------------------------------------------------------------------------------------------------------1
mux_0_w_6: MUX_0 generic map(N) port map (W_II, theta_W_II, theta_xi,   theta_zeta,  W_III, theta_W_prime, ce_5_II, open, clk);
mux_0_x_6: MUX_0 generic map(N) port map (X_II, theta_X_II, theta_xi,   theta_omega, X_III, theta_X_prime, ce_5_II, open, clk);
mux_0_y_6: MUX_0 generic map(N) port map (Y_II, theta_Y_II, theta_eta,  theta_zeta,  Y_III, theta_Y_prime, ce_5_II, open, clk);--TAKEOUT
mux_0_z_6: MUX_0 generic map(N) port map (Z_II, theta_Z_II, theta_eta,  theta_omega, Z_III, theta_Z_prime, ce_5_II, open, clk);--TAKEOUT

mux_3_6: MUX_3 generic map(N) port map (W_II, X_II, Y_II, Z_II, YX_sum, ZW_diff, YX_diff, ZW_sum, ce_5_II, ce_5_III, clk);--Get 3 input

--V to mux_5 of stage 6
shift_reg_28_theta_zeta_U_6:  shift_reg generic map(N, PR)  port map (theta_zeta,  theta_zeta_prime,  ce_5_II, clk);--28
shift_reg_28_theta_omega_U_6: shift_reg generic map(N, PR)  port map (theta_omega, theta_omega_prime, ce_5_II, clk);--28

--V r2p from stage 5 to stage 6 (r2p) 
r2p_w_V_6: r2p_w generic map(N) port map (V_a_r_5, V_a_i_5, V_W_6, V_theta_W_6, ce_5_II, open, sclr,   clk);
r2p_x_V_6: r2p_w generic map(N) port map (V_b_r_5, V_b_i_5, V_X_6, V_theta_X_6, ce_5_II, open,  sclr,  clk);
r2p_y_V_6: r2p_w generic map(N) port map (V_c_r_5, V_c_i_5, V_Y_6, V_theta_Y_6, ce_5_II, open,  sclr,  clk);--TAKEOUT
r2p_z_V_6: r2p_w generic map(N) port map (V_d_r_5, V_d_i_5, V_Z_6, V_theta_Z_6, ce_5_II, ce_6_I, sclr,   clk);--TAKEOUT
-----------------------------------------------------------------------------------------------------------------------------------28
--S
p2r_w_6:   p2r_w generic map(N) port map (W_III, zero, theta_W_prime, w_r_prime, w_i_prime, ce_5_III, open, sclr,  clk);--TAKEOUT *_III=*_prime
p2r_x_6:   p2r_w generic map(N) port map (X_III, zero, theta_X_prime, x_r_prime, x_i_prime, ce_5_III, open, sclr, clk);--TAKEOUT
p2r_y_6:   p2r_w generic map(N) port map (Y_III, zero, theta_Y_prime, y_r_prime, y_i_prime, ce_5_III, open, sclr, clk);--TAKEOUT
p2r_z_6:   p2r_w generic map(N) port map (Z_III, zero, theta_Z_prime, z_r_prime, z_i_prime, ce_5_III, ce_6, sclr, clk);--TAKEOUT

arctan_sum_6:        arctan_w generic map(N) port map(ZW_diff, YX_sum,    theta_sum,  ce_5_III, ce_sum,  sclr, clk); --latency 23
arctan_diff_6:       arctan_w generic map(N) port map(ZW_sum,  YX_diff,   theta_diff, ce_5_III, open, sclr, clk); --latency 23
-------
mux_4_6:   MUX_4 generic map(N) port map (theta_sum, theta_diff, theta_lambda_N_1_6, theta_rho_1_6, ce_sum, ce_lambda_6, clk); --1
-------
shift_reg_4_lambda_6: shift_reg generic map(N, PR-ARC-1) port map (theta_lambda_N_1_6, theta_lambda_N_2_6, ce_lambda_6, clk);--4
shift_reg_4_rho_6:    shift_reg generic map(N, PR-ARC-1) port map (theta_rho_1_6,      theta_rho_2_6,      ce_lambda_6, clk);--4

--U from stage 2&4 [exp(1i*theta_xi)  0; 0  exp(1i*theta_eta)] * [exp(1i*theta_alpha)  0; 0  exp(1i*theta_beta)] can be optimized
mux_5_a_U_6: MUX_5 generic map(N) port map (theta_alpha_prime, theta_xi,  U_theta_W, ce_5_II, open, clk );--1
mux_5_d_U_6: MUX_5 generic map(N) port map (theta_alpha_prime,  theta_eta, U_theta_Z, ce_5_II, open, clk );--1
-------
shift_reg_28_theta_W_U_6:  shift_reg generic map(N, PR)  port map (U_theta_W, U_theta_W_prime, ce_5_III, clk);--28
shift_reg_28_theta_Z_U_6:  shift_reg generic map(N, PR)  port map (U_theta_Z, U_theta_Z_prime, ce_5_III, clk);--28
--V from stage 2
mux_5_a_V_6: MUX_5 generic map(N) port map (V_theta_W_6, theta_zeta_prime,  V_theta_W_prime, ce_6_I, open, clk );--1
mux_5_b_V_6: MUX_5 generic map(N) port map (V_theta_X_6, theta_omega_prime, V_theta_X_prime, ce_6_I, open, clk );--1
mux_5_c_V_6: MUX_5 generic map(N) port map (V_theta_Y_6, theta_zeta_prime,  V_theta_Y_prime, ce_6_I, open, clk );--1
mux_5_d_V_6: MUX_5 generic map(N) port map (V_theta_Z_6, theta_omega_prime, V_theta_Z_prime, ce_6_I, open, clk );--1
shift_reg_1_W_V_6:    shift_reg generic map(N, 1)  port map (V_W_6, V_W_6_I, ce_6_I, clk);--1
shift_reg_1_X_V_6:    shift_reg generic map(N, 1)  port map (V_X_6, V_X_6_I, ce_6_I, clk);--1
shift_reg_1_Y_V_6:    shift_reg generic map(N, 1)  port map (V_Y_6, V_Y_6_I, ce_6_I, clk);--1
shift_reg_1_Z_V_6:    shift_reg generic map(N, 1)  port map (V_Z_6, V_Z_6_I, ce_6_I, clk);--1
-------------------------------------------------------------7----------------------------------------------------------------------28
--S
p2r_w_7: p2r_w generic map(N) port map (w_r_prime, y_r_prime, theta_lambda_N_2_6, w_r_7, y_r_7, ce_6, open, sclr, clk);
p2r_x_7: p2r_w generic map(N) port map (w_i_prime, y_i_prime, theta_lambda_N_2_6, w_i_7, y_i_7, ce_6, open, sclr, clk);
p2r_y_7: p2r_w generic map(N) port map (x_r_prime, z_r_prime, theta_lambda_N_2_6, x_r_7, z_r_7, ce_6, open, sclr, clk);
p2r_z_7: p2r_w generic map(N) port map (x_i_prime, z_i_prime, theta_lambda_N_2_6, x_i_7, z_i_7, ce_6, ce_7_I, sclr, clk);

--mux_6_rl_7: MUX_6_reg generic map (N, PR-1) port map (theta_rho_2_6, theta_lambda_N_2_6, theta_rho_7, theta_lambda_N_7, theta_rho_s_7, theta_lambda_N_s_7, ce_6, clk);--L is PR

shift_reg_28_rho_7:                  shift_reg generic map(N, PR)  port map (theta_rho_2_6,      theta_rho_7,      ce_6, clk); --
--from stage 6 for U
shift_reg_28_theta_lambda_U_7to8:    shift_reg generic map(N, PR)  port map (theta_lambda_N_2_6, theta_lambda_N_7, ce_6, clk);

--U p2r get from stage 6 to stage 8, change polar to reg form
p2r_U_w_7: p2r_w generic map(N) port map (one,     zero, U_theta_W_prime, U_w_r_7, U_w_i_7, ce_6, open, sclr, clk);
p2r_U_z_7: p2r_w generic map(N) port map (one,     zero, U_theta_Z_prime, U_z_r_7, U_z_i_7, ce_6, open, sclr, clk);

--V p2r get from stage 6 to stage 8. 
p2r_V_w_7: p2r_w generic map(N) port map (V_W_6_I, zero, V_theta_W_prime, V_w_r_7, V_w_i_7, ce_6, open, sclr, clk); --keep
p2r_V_x_7: p2r_w generic map(N) port map (V_X_6_I, zero, V_theta_X_prime, V_x_r_7, V_x_i_7, ce_6, open, sclr, clk); --keep
p2r_V_y_7: p2r_w generic map(N) port map (V_Y_6_I, zero, V_theta_Y_prime, V_y_r_7, V_y_i_7, ce_6, open, sclr, clk); --keep
p2r_V_z_7: p2r_w generic map(N) port map (V_Z_6_I, zero, V_theta_Z_prime, V_z_r_7, V_z_i_7, ce_6, open, sclr, clk); --keep

-------------------------------------------------------------8----------------------------------------------------------------------28
w_1: p2r_w generic map(N) port map (w_r_7, x_r_7, theta_rho_7, p_r_I, s_r_I, ce_7_I, open,  sclr,    clk);
x_1: p2r_w generic map(N) port map (y_r_7, z_r_7, theta_rho_7, r_r_I, q_r_I, ce_7_I, open,  sclr,    clk);
y_1: p2r_w generic map(N) port map (w_i_7, x_i_7, theta_rho_7, p_i_I, s_i_I, ce_7_I, open,  sclr,    clk);
z_1: p2r_w generic map(N) port map (y_i_7, z_i_7, theta_rho_7, r_i_I, q_i_I, ce_7_I, ce_7_II, sclr,  clk);
--U originaly from stage 7
p2r_U_w_8: p2r_w generic map(N) port map (U_w_r_7, zero,    theta_lambda_N_7, U_w_r_7_I, U_y_r_7_I, ce_7_I, open, sclr, clk);
p2r_U_x_8: p2r_w generic map(N) port map (U_w_i_7, zero,    theta_lambda_N_7, U_w_i_7_I, U_y_i_7_I, ce_7_I, open, sclr, clk);
p2r_U_y_8: p2r_w generic map(N) port map (zero,    U_z_r_7, theta_lambda_N_7, U_x_r_7_I, U_z_r_7_I, ce_7_I, open, sclr, clk);
p2r_U_z_8: p2r_w generic map(N) port map (zero,    U_z_i_7, theta_lambda_N_7, U_x_i_7_I, U_z_i_7_I, ce_7_I, open, sclr, clk);

--V 
p2r_V_w_8: p2r_w generic map(N) port map (V_w_r_7, V_x_r_7, theta_rho_7, V_w_r_7_I, V_x_r_7_I, ce_7_I, open, sclr, clk);
p2r_V_x_8: p2r_w generic map(N) port map (V_y_r_7, V_z_r_7, theta_rho_7, V_y_r_7_I, V_z_r_7_I, ce_7_I, open, sclr, clk);
p2r_V_y_8: p2r_w generic map(N) port map (V_w_i_7, V_x_i_7, theta_rho_7, V_w_i_7_I, V_x_i_7_I, ce_7_I, open, sclr, clk);
p2r_V_z_8: p2r_w generic map(N) port map (V_y_i_7, V_z_i_7, theta_rho_7, V_y_i_7_I, V_z_i_7_I, ce_7_I, open, sclr, clk);
----------------------------------------------------------------------------------------------------------------------------------1
--omega_U_H: output port map (U_w_r_7_I, U_w_i_7_I, U_x_r_7_I, U_x_i_7_I, U_y_r_7_I, U_y_i_7_I, U_z_r_7_I, U_z_i_7_I, U_H_w_r, U_H_w_i, U_H_x_r, U_H_x_i, U_H_y_r, U_H_y_i, U_H_z_r, U_H_z_i,  ce_7_II, open, clk);
--omega_S:   output port map (p_r_I, p_i_I, s_r_I, s_i_I, r_r_I, r_i_I, q_r_I, q_i_I, p_r, p_i, s_r, s_i, r_r, r_i, q_r, q_i, ce_7_II, rdy, clk);
--omega_V:   output port map (V_w_r_7_I, V_w_i_7_I, V_x_r_7_I, V_x_i_7_I, V_y_r_7_I, V_y_i_7_I, V_z_r_7_I, V_z_i_7_I, V_w_r, V_w_i, V_x_r, V_x_i, V_y_r, V_y_i, V_z_r, V_z_i, ce_7_II, open, clk);
omega: NSVD generic map(N) port map (p_r_I, p_i_I, s_r_I, s_i_I, r_r_I, r_i_I, q_r_I, q_i_I,U_w_r_7_I, U_w_i_7_I, U_x_r_7_I, U_x_i_7_I, U_y_r_7_I, U_y_i_7_I, U_z_r_7_I, U_z_i_7_I, V_w_r_7_I, V_w_i_7_I, V_x_r_7_I, V_x_i_7_I, V_y_r_7_I, V_y_i_7_I, V_z_r_7_I, V_z_i_7_I, p_r, p_i, s_r, s_i, r_r, r_i, q_r, q_i, U_H_w_r, U_H_w_i, U_H_x_r, U_H_x_i, U_H_y_r, U_H_y_i, U_H_z_r, U_H_z_i, V_w_r, V_w_i, V_x_r, V_x_i, V_y_r, V_y_i, V_z_r, V_z_i, ce_7_II, rdy, clk);

end Behavioral;

