library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ALU_control is
    port (  clk : in STD_LOGIC;
			reset : in STD_LOGIC;
            inst : in STD_LOGIC_VECTOR (31 downto 0);
			control_alu_op : in STD_LOGIC_VECTOR(2 downto 0);
			alu_op : out STD_LOGIC_VECTOR(2 downto 0));
end ALU_control; 

architecture Behavioral of ALU_control is
begin   
    process(clk, reset, control_alu_op)
        variable temp_alu_op: STD_LOGIC_VECTOR(2 downto 0);
    begin
        if (reset = "1") then
            temp_alu_op := "000";       
        else
            if (alu_op = "000") then
                case inst(5 downto 0) is
                    when "100000" =>
                        temp_alu_op := "010";

                    when "100010" =>
                        temp_alu_op := "110";

                    when "100100" =>
                        temp_alu_op := "000";

                    when "100101" =>
                        temp_alu_op := "001";

                    when "101010" =>
                        temp_alu_op := "111";

                    when others =>
                        temp_alu_op := "010";

                    end case;
            else
                temp_alu_op := control_alu_op;
            end if;
        end if;
        
        alu_op <= temp_alu_op; 
    end process;
end Behavioral;                       
                
        
            
