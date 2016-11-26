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
           inR : out  STD_LOGIC_VECTOR (7 downto 0));
end multMatriz;

architecture Behavioral of multMatriz is


type tpestado is (idle,s0,s1,s2,s3,s4,s5);
signal estado: tpestado;


begin


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
								if start = '0' then
									estado <= idle;
									else if compLinha = '1' then 
										estado <= idle;
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
								loadAcc <= '1'
								incI <= '1';
								if compI = 0 then estado <= s1;
									else
										estado <= s4;
								end if;
										
				when s4 =>
								loadI <= '1';
								writeMem <= '1';
								incColuna <= '1';
								if compColuna = '0' then estado <= s0;
									else
										estado <= s5;
								end if;
								
				when s5 => 
								loadColuna <= '1';
								incLinha <= '1';
								if compLinha = '1' then estado <= idle;
									else
										if compColuna = '0' then estado <= s0;
											else
												estado <= s5;
										end if;
								end if;
								
			end case;
		end if;
	end if;
end process;
								
										
											

end Behavioral;

