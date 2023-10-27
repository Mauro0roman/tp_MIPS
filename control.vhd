library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity control is
    port (  clk : in STD_LOGIC;
			reset : in STD_LOGIC;
			inst : in STD_LOGIC_VECTOR (31 downto 0);
			reg_dst : out STD_LOGIC;
			branch : out STD_LOGIC;
			mem_rd : out STD_LOGIC;
			mem_wr : out STD_LOGIC;
			mem_to_reg : out STD_LOGIC;
			alu_op : out STD_LOGIC_VECTOR(2 downto 0);
			alu_src : out STD_LOGIC;
			reg_wr : out STD_LOGIC;)
end control; 

Behavioral of control is
    signal funct :std_logic_vector(5 downto 0);
    
begin
    funct <= inst(31 downto 26);
    process(clk, reset)
    begin
        if (reset = "1") then

            reg_dst <= "0";
            branch <= "0";
            mem_rd <= "0";
            mem_wr <= "0";
            mem_to_reg <= "0";
            alu_op <= "000";
            alu_src <= "0";
            reg_wr <= "0"; 

        elsif rising_edge(clk) then        
            case funct is
                when "000000" =>
                    --Type R
                    reg_dst <= "1";
                    branch <= "0";
                    mem_rd <= "0";
                    mem_wr <= "0";
                    mem_to_reg <= "0";
                    alu_op <= "000";
                    alu_src <= "0";
                    reg_wr <= "1";

                when "100011" =>
                    -- Lw
                    reg_dst <= "0";
                    branch <= "0";
                    mem_rd <= "1";
                    mem_wr <= "0";
                    mem_to_reg <= "0";
                    alu_op <= "010";
                    alu_src <= "1";
                    reg_wr <= "1";

                when "101011" =>
                    -- Rw
                    reg_dst <= "0";
                    branch <= "0";
                    mem_rd <= "0";
                    mem_wr <= "1";
                    mem_to_reg <= "0";
                    alu_op <= "010";
                    alu_src <= "1";
                    reg_wr <= "0";
                
                when "000100" =>
                    -- Beq
                    reg_dst <= "0";
                    branch <= "1";
                    mem_rd <= "0";
                    mem_wr <= "0";
                    mem_to_reg <= "0";
                    alu_op <= "110";
                    alu_src <= "0";
                    reg_wr <= "0";   

                when "001111" =>
                    -- LUI
                    reg_dst <= "0";
                    branch <= "0";
                    mem_rd <= "0";
                    mem_wr <= "0";
                    mem_to_reg <= "0";
                    alu_op <= "101";
                    alu_src <= "1";
                    reg_wr <= "1"; 

                when "001000" =>
                    -- Addi
                    reg_dst <= "0";
                    branch <= "0";
                    mem_rd <= "0";
                    mem_wr <= "0";
                    mem_to_reg <= "0";
                    alu_op <= "010";
                    alu_src <= "1";
                    reg_wr <= "1";    
                
                when "001100" =>
                    -- Andi
                    reg_dst <= "0";
                    branch <= "0";
                    mem_rd <= "0";
                    mem_wr <= "0";
                    mem_to_reg <= "0";
                    alu_op <= "000";
                    alu_src <= "1";
                    reg_wr <= "1";  

                when "001101" =>
                    -- Ori
                    reg_dst <= "0";
                    branch <= "0";
                    mem_rd <= "0";
                    mem_wr <= "0";
                    mem_to_reg <= "0";
                    alu_op <= "001";
                    alu_src <= "1";
                    reg_wr <= "1"; 
                
                when others =>
                    -- Nop
                    reg_dst <= "0";
                    branch <= "0";
                    mem_rd <= "0";
                    mem_wr <= "0";
                    mem_to_reg <= "0";
                    alu_op <= "000";
                    alu_src <= "0";
                    reg_wr <= "0";  
            end case;
        end if;    
    end process;
end Behavioral;