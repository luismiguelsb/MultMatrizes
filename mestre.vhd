----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:32:23 11/26/2016 
-- Design Name: 
-- Module Name:    mestre - Behavioral 
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
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity mestre is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           start : in  STD_LOGIC;
           done : out  STD_LOGIC;
           idle : out  STD_LOGIC;
           ready : out  STD_LOGIC);
end mestre;

architecture Behavioral of mestre is

COMPONENT memoria1
  PORT (
    clka : IN STD_LOGIC;
    addra : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    clkb : IN STD_LOGIC;
    addrb : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    doutb : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
  );
END COMPONENT;

COMPONENT memoria2
  PORT (
    clka : IN STD_LOGIC;
    addra : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    clkb : IN STD_LOGIC;
    addrb : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    doutb : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
  );
END COMPONENT;

COMPONENT memoria3
  PORT (
    clka : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
  );
END COMPONENT;

--COMPONENT matrixmul	--multiciclo
--	PORT(
--		ap_clk : IN std_logic;
--		ap_rst : IN std_logic;
--		ap_start : IN std_logic;
--		
--		a_q0 : IN std_logic_vector(7 downto 0);
--		a_q1 : IN std_logic_vector(7 downto 0);
--		b_q0 : IN std_logic_vector(7 downto 0);
--		b_q1 : IN std_logic_vector(7 downto 0);  
--		
--		ap_done : OUT std_logic;
--		ap_idle : OUT std_logic;
--		ap_ready : OUT std_logic;
--		
--		a_address0 : OUT std_logic_vector(3 downto 0);
--		a_ce0 : OUT std_logic;
--		a_address1 : OUT std_logic_vector(3 downto 0);
--		a_ce1 : OUT std_logic;
--		
--		b_address0 : OUT std_logic_vector(3 downto 0);
--		b_ce0 : OUT std_logic;
--		b_address1 : OUT std_logic_vector(3 downto 0);
--		b_ce1 : OUT std_logic;
--		
--		res_address0 : OUT std_logic_vector(3 downto 0);
--		res_ce0 : OUT std_logic;
--		res_we0 : OUT std_logic;
--		res_d0 : OUT std_logic_vector(15 downto 0)
--		);
--	END COMPONENT;
	
COMPONENT matrixmul	--pipeline
	PORT(
		ap_clk : IN std_logic;
		ap_rst : IN std_logic;
		ap_start : IN std_logic;
		a_q0 : IN std_logic_vector(7 downto 0);
		b_q0 : IN std_logic_vector(7 downto 0);          
		ap_done : OUT std_logic;
		ap_idle : OUT std_logic;
		ap_ready : OUT std_logic;
		a_address0 : OUT std_logic_vector(3 downto 0);
		a_ce0 : OUT std_logic;
		b_address0 : OUT std_logic_vector(3 downto 0);
		b_ce0 : OUT std_logic;
		res_address0 : OUT std_logic_vector(3 downto 0);
		res_ce0 : OUT std_logic;
		res_we0 : OUT std_logic;
		res_d0 : OUT std_logic_vector(15 downto 0)
		);
	END COMPONENT;

	
signal		a_q0 :  std_logic_vector(7 downto 0);
signal		a_q1 :  std_logic_vector(7 downto 0);
signal		b_q0 :  std_logic_vector(7 downto 0);
signal		b_q1 :  std_logic_vector(7 downto 0);
signal		a_address0 :  std_logic_vector(3 downto 0);
signal		a_ce0 :  std_logic;
signal		a_address1 :  std_logic_vector(3 downto 0);
signal		a_ce1 :  std_logic;
signal		b_address0 :  std_logic_vector(3 downto 0);
signal		b_ce0 :  std_logic;
signal		b_address1 :  std_logic_vector(3 downto 0);
signal		b_ce1 :  std_logic;
signal		res_address0 :  std_logic_vector(3 downto 0);
signal		res_ce0 :  std_logic;
signal		res_we0 :  std_logic;
signal		res_d0 :  std_logic_vector(15 downto 0);
signal		dout_void :  std_logic_vector(15 downto 0);
signal 		dummy_vector: std_logic_vector(0 downto 0);

begin
  memA : memoria1
  PORT MAP (
    clka => a_ce0,
    addra => a_address0,
    douta => a_q0,
    clkb => a_ce1,
    addrb => a_address1,
    doutb => a_q1
  );
  
  memB : memoria2
  PORT MAP (
    clka => b_ce0,
    addra => b_address0,
    douta => b_q0,
    clkb => b_ce1,
    addrb => b_address1,
    doutb => b_q1
  );
  
  memRes : memoria3
  PORT MAP (
    clka => res_ce0,
    wea => not dummy_vector,
    addra => res_address0,
    dina => res_d0,
    douta => dout_void
  );

--  Inst_matrixmul: matrixmul PORT MAP(	--multiciclo
--		ap_clk => clk,
--		ap_rst => reset,
--		ap_start => start,
--		ap_done => done,
--		ap_idle => idle,
--		ap_ready => ready,
--		a_address0 => a_address0,
--		a_ce0 => a_ce0,
--		a_q0 => a_q0,
--		a_address1 => a_address1,
--		a_ce1 => a_ce1,
--		a_q1 => a_q1,
--		b_address0 => b_address0,
--		b_ce0 => b_ce0,
--		b_q0 => b_q0,
--		b_address1 => b_address1,
--		b_ce1 => b_ce1,
--		b_q1 => b_q1,
--		res_address0 => res_address0,
--		res_ce0 => res_ce0,
--		res_we0 => dummy_vector(0),
--		res_d0 => res_d0
--	);
	
	Inst_matrixmul: matrixmul PORT MAP(	--pipeline
		ap_clk => clk,
		ap_rst => reset,
		ap_start => start,
		ap_done => done,
		ap_idle => idle,
		ap_ready => ready,
		a_address0 => a_address0,
		a_ce0 => a_ce0,
		a_q0 => a_q0,
		b_address0 => b_address0,
		b_ce0 => b_ce0,
		b_q0 => b_q0,
		res_address0 => res_address0,
		res_ce0 => res_ce0,
		res_we0 => res_we0,
		res_d0 => res_d0
	);


end Behavioral;

