----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:23:37 11/26/2016 
-- Design Name: 
-- Module Name:    multMatriz - Behavioral 
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity multMatriz is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           start : in  STD_LOGIC;
           done : out  STD_LOGIC;
           endA : out  STD_LOGIC_VECTOR (3 downto 0);
           endB : out  STD_LOGIC_VECTOR (3 downto 0);
           endR : out  STD_LOGIC_VECTOR (3 downto 0);
           memA : in  STD_LOGIC_VECTOR (3 downto 0);
           memB : in  STD_LOGIC_VECTOR (3 downto 0);
			  writeMem : out std_logic_vector(0 downto 0);
           inR : out  STD_LOGIC_VECTOR (7 downto 0));
end multMatriz;

architecture Behavioral of multMatriz is

--sinais
signal AddrA,AddrB,AddrR,Linha,Coluna,regI,outMux1,outMux2: std_logic_vector(3 downto 0);
signal loadAddrA,loadAddrB,loadAddrR,loadAcc,loadLinha,incLinha,loadColuna,compLinha,compColuna,CompI: std_logic;
signal incColuna,loadI, incI, selMux1, selMuxAcc, incR:std_logic;
signal outAcc, outMuxAcc,outMux3,outMult,outULA: std_logic_vector(7 downto 0);
signal selMux2,selMux3: std_logic_vector(1 downto 0);
type tpestado is (idle,s0,s1,s2,s3,s4,s5,s6,s7);
signal estado: tpestado;

begin

outMult<=outMux1*outMux2;
outULA<=outMult+outMux3;

process(clk, reset)
begin
	if reset = '1' then
		estado <= idle;
		else if rising_edge(clk) then
			case estado is
				when idle =>
								loadLinha <= '1';
								loadColuna <= '1';
								loadI <= '1';
								loadAddrR<='1';
								if start = '0' then
									estado <= idle;
									else if compLinha = '1' then 
										estado <= s7;
										else if compColuna = '1' then
											estado <= s5;
											else
												estado <= s0;
										end if;
									end if;
								end if;
				
				when s0 => 
								loadAcc <= '1';
								selMuxAcc <= '0';
								if compI = '1' then
									estado <= s4;
									else
										estado <= s1;
								end if;
				
				when s1 => 
								selMux1 <= '0';
								selMux2 <= "01";
								selMux3 <= "01";
								loadAddrA <= '1';
								estado <= s2;
								
				when s2 => 
								selMux1 <= '0';
								selMux2 <= "10";
								selMux3 <= "10";
								loadAddrB <= '1';
								estado <= s3;
						
				when s3 => 
								selMux1 <= '1';
								selMux2 <= "00";
								selMux3 <= "00";
								selMuxAcc <= '1';
								loadAcc <= '1';
								incI <= '1';
								if compI = '0' then estado <= s1;
									else
										estado <= s4;
								end if;
										
				when s4 =>
								loadI <= '1';
								writeMem <= "1";
								incColuna <= '1';
					         estado<=s5;
				when s5 =>
								incR<='1';
								if compColuna = '0' then estado <= s0;
									else
										estado <= s6;
								end if;
				when s6 => 
								loadColuna <= '1';
								incLinha <= '1';
								if compLinha = '1' then estado <= s7;
									else
										if compColuna = '0' then estado <= s0;
											else
												estado <= s5;
										end if;
								end if;
				when s7 =>  
								done<='1';
								estado<=idle;								
			end case;
		end if;
	end if;
end process;


--PO
outMuxAcc<= "00000000" when selMuxAcc='0' else
				outULA;
outMux1<="0100" when selMux1='0' else
			memB;
outMux2<=memA when selMux2="00" else
			Linha when selMux2="01" else
			regI when selMux2="10" else
			"0000";
outMux3<=outAcc when selMux3="00" else
			"0000"&regI when selMux3="01" else
			"0000"&Coluna when selMux3="10" else
			"00000000";
compLinha<='1' when Linha="0100" else
				'0';
compColuna<='1' when Coluna="0100" else
				'0';
compI<='1' when regI="0100" else
		  '0';


Registrador_rI: process(clk,reset)
begin
	if(reset='1')then
		regI<="0000";
	elsif(rising_edge(clk))then
		if(loadI='1')then
			regI<="0000";
		elsif(incI='1')then
			regI<=regI+"0001";
		end if;
	end if;
end process;

process(clk,reset) --coluna
begin
	if(reset='1')then
		Coluna<="0000";
	elsif(rising_edge(clk))then
		if(loadColuna='1')then
			Coluna<="0000";
		elsif(incColuna='1')then
			Coluna<=Coluna+"0001";
		end if;
	end if;
end process;

process(clk,reset) --linha
begin
	if(reset='1')then
		Linha<="0000";
	elsif(rising_edge(clk))then
		if(loadLinha='1')then
			Linha<="0000";
		elsif(incLinha='1')then
			Linha<=Linha+"0001";
		end if;
	end if;
end process;

Acc: process(clk,reset)
begin
	if(reset='1')then
		outAcc<="00000000";
	elsif(rising_edge(clk))then
		if(loadAcc='1')then
			outAcc<=outMuxAcc;
		end if;
	end if;
end process;

process(clk,reset) --AddrA
begin
	if(reset='1')then
		AddrA<="0000";
	elsif(rising_edge(clk))then
		if(loadAddrA='1')then
			AddrA<=outULA(3 downto 0);
		end if;
	end if;
end process;

process(clk,reset) --AddrB
begin
	if(reset='1')then
		AddrB<="0000";
	elsif(rising_edge(clk))then
		if(loadAddrB='1')then
			AddrB<=outULA(3 downto 0);
		end if;
	end if;
end process;

process(clk,reset) --AddrR
begin
	if(reset='1')then
		AddrR<="0000";
	elsif(rising_edge(clk))then
		if(loadAddrR='1')then
			AddrR<="0000";
		elsif(incR='1')then
		   AddrR<=AddrR+"0001";
		end if;
	end if;
end process;

endA<=AddrA;
endB<=AddrB;
endR<=AddrR;
inR<=outAcc;

end Behavioral;

