library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;

entity ALU is
    Port ( a : in STD_LOGIC_VECTOR(7 downto 0);
           b : in STD_LOGIC_VECTOR(7 downto 0);
           control : in STD_LOGIC_VECTOR(2 downto 0);
           result : out STD_LOGIC_VECTOR(7 downto 0);
           zero : out STD_LOGIC);
end ALU;

architecture Behavioral of ALU is
begin
    process(a, b, control)
        variable temp_result : STD_LOGIC_VECTOR(7 downto 0);
    begin        

        -- Lógica de la ALU
        case control is
            when "000" =>
                -- AND
                temp_result := a and b;
                
            when "001" =>
                -- OR
                temp_result := a or b;
                
            when "010" =>
                -- Suma
                temp_result := a + b;
                
            when "110" =>
                -- Resta            
                temp_result := a - b;
               
            when "111" =>
                -- Menor que
                if a < b then
                    temp_result := "00000001";
                else
                    temp_result := (others => '0');
                end if;
            when "100" =>
                -- Desplazamiento a la izquierda
                temp_result := b(6 downto 0) & "0";
                
            when others =>
            	temp_result := (others => '0');
                
        end case;
        if temp_result = "00000000" then
           zero <= '1';
        else
        	zero <= '0';
        end if;
        result <= temp_result;
    end process;
end Behavioral;
