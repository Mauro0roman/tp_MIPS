library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ALU is
    Port ( a : in STD_LOGIC_VECTOR(31 downto 0);
           b : in STD_LOGIC_VECTOR(31 downto 0);
           op : in STD_LOGIC_VECTOR(2 downto 0);
           result : out STD_LOGIC_VECTOR(31 downto 0);
           zero : out STD_LOGIC);
end ALU;

architecture Behavioral of ALU is
begin
    process(a, b, op)
        variable temp_result : STD_LOGIC_VECTOR(31 downto 0);
    begin
        -- Inicializamos el resultado y el flag zero
        result <= (others => '0');
        zero <= '0';

        -- Lógica de la ALU
        case op is
            when "000" =>
                -- AND
                temp_result := a and b;
            when "001" =>
                -- OR
                temp_result := a or b;
            when "010" =>
                -- Suma
                temp_result := (others => '0');
                temp_result := (others => '0') & a + b;
            when "110" =>
                -- Resta
                temp_result := (others => '0');
                temp_result := (others => '0') & a - b;
            when "111" =>
                -- Menor que
                if a < b then
                    temp_result := "00000000000000000000000000000001";
                    zero <= '1';
                else
                    temp_result := (others => '0');
                end if;
            when others =>
                -- Desplazamiento a la izquierda
                temp_result := b(15 downto 0) & (others => '0');
        end case;

        result <= temp_result;
    end process;
end Behavioral;
