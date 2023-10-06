library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ALU_Testbench is
end ALU_Testbench;

architecture Behavioral of ALU_Testbench is
    -- Component declaration for the ALU
    component ALU
        Port ( a : in STD_LOGIC_VECTOR(31 downto 0);
               b : in STD_LOGIC_VECTOR(31 downto 0);
               control : in STD_LOGIC_VECTOR(2 downto 0);
               result : out STD_LOGIC_VECTOR(31 downto 0);
               zero : out STD_LOGIC);
    end component;

    -- Signals for Testbench
    signal a_tb, b_tb, result_tb : STD_LOGIC_VECTOR(31 downto 0);
    signal control_tb : STD_LOGIC_VECTOR(2 downto 0);
    signal zero_tb : STD_LOGIC;

begin
    -- Instantiate the ALU
    uut: ALU port map (a => a_tb, b => b_tb, control => control_tb, result => result_tb, zero => zero_tb);

    -- Stimulus process
    stimulus_process: process
    begin
        -- Test case 1: AND
        a_tb <= "00000000000000000000000000001111";
        b_tb <= "00000000000000000000000011110000";
        control_tb <= "000";
        wait for 10 ns;

        -- Test case 2: OR
        a_tb <= "00000000000000000000000000001111";
        b_tb <= "00000000000000000000000011110000";
        control_tb <= "001";
        wait for 10 ns;

        -- Test case 3: Suma
        a_tb <= "00000000000000000000000000001111";
        b_tb <= "00000000000000000000000011110000";
        control_tb <= "010";
        wait for 10 ns;

        -- Test case 4: Resta
        a_tb <= "00000000000000000000000000001111";
        b_tb <= "00000000000000000000000011110000";
        control_tb <= "110";
        wait for 10 ns;

        -- Test case 5: Menor que
        a_tb <= "00000000000000000000000000001111";
        b_tb <= "00000000000000000000000011110000";
        control_tb <= "111";
        wait for 10 ns;

        -- Test case 6: Desplazamiento a la izquierda
        a_tb <= "00000000000000000000000000001111";
        b_tb <= "00000000000000000000000011110000";
        control_tb <= "100";
        wait for 10 ns;

        -- Add more test cases as needed

        wait;
    end process;

end Behavioral;