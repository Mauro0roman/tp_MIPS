library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity processor is
port(
	Clk         : in  std_logic;
	Reset       : in  std_logic;
	-- Instruction memory
	I_Addr      : out std_logic_vector(31 downto 0);
	I_RdStb     : out std_logic;
	I_WrStb     : out std_logic;
	I_DataOut   : out std_logic_vector(31 downto 0);
	I_DataIn    : in  std_logic_vector(31 downto 0);
	-- Data memory
	D_Addr      : out std_logic_vector(31 downto 0);
	D_RdStb     : out std_logic;
	D_WrStb     : out std_logic;
	D_DataOut   : out std_logic_vector(31 downto 0);
	D_DataIn    : in  std_logic_vector(31 downto 0)
);
end processor;

architecture processor_arq of processor is 

--DECLARACION DE COMPONENTES--

component registers 
    port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           wr : in STD_LOGIC;
           reg1_dr : in STD_LOGIC_VECTOR (4 downto 0);
           reg2_dr : in STD_LOGIC_VECTOR (4 downto 0);
           reg_wr : in STD_LOGIC_VECTOR (4 downto 0);
           data_wr : in STD_LOGIC_VECTOR (31 downto 0);
           data1_rd : out STD_LOGIC_VECTOR (31 downto 0);
           data2_rd : out STD_LOGIC_VECTOR (31 downto 0));
           
end component;
component ALU
    Port ( a : in STD_LOGIC_VECTOR(31 downto 0);
           b : in STD_LOGIC_VECTOR(31 downto 0);
           op : in STD_LOGIC_VECTOR(2 downto 0);
           result : out STD_LOGIC_VECTOR(31 downto 0);
           zero : out STD_LOGIC);
end component;
component control
	port (  clk : in STD_LOGIC;
			reset : in STD_LOGIC;
			inst : in STD_LOGIC_VECTOR (5 downto 0);
			reg_dst : out STD_LOGIC;
			branch : out STD_LOGIC;
			mem_rd : out STD_LOGIC;
			mem_wr : out STD_LOGIC;
			mem_to_reg : out STD_LOGIC;
			alu_op : out STD_LOGIC_VECTOR(2 downto 0);
			alu_src : out STD_LOGIC;
			reg_wr : out STD_LOGIC;

	)
end component;

--DECLARACION DE SE�ALES--
    --ETAPA IF--
	signal	IF_I_Ins, IF_reg_PC, branch_addr, IF_pc_4,
			IF_ID_PC_4, IF_ID_inst: in STD_LOGIC_VECTOR (31 downto 0);
			IF_ctrl_mux_sel: in STD_LOGIC;
		

    --ETAPA ID--
	signal 

    --ETAPA EX--

    --ETAPA MEM--
     
    --ETAPA WB--    
        
begin 	
---------------------------------------------------------------------------------------------------------------
-- ETAPA IF
---------------------------------------------------------------------------------------------------------------
IF_process: process (clk, reset, IF_ctrl_mux_sel, branch_addr, I_Addr, I_DataIn)
begin
	if (reset = '1') then
		-- Lógica de reinicio
		IF_reg_PC <= '0'';
	elsif rising_edge(clk) then
		-- Lógica de la etapa IF

		IF_pc_4 = IF_reg_PC + 4;
		if(IF_ctrl_mux_sel = '0') then
			IF_reg_PC <= IF_pc_4;
		else 
			IF_reg_PC <= branch_addr;
		end if;

		I_Addr <= IF_reg_PC;
		IF_I_Ins <= I_DataIn(to_integer(unsigned(I_Addr)));


		-- Asigna valores a las señales de salida
		
		I_RdStb <= 1;
		I_WrStb <= 0;
		-- ...

	end if;
end process IF_process;

 
 
 
---------------------------------------------------------------------------------------------------------------
-- REGISTRO DE SEGMENTACION IF/ID
--------------------------------------------------------------------------------------------------------------- 
IF_ID_process: process (clk, reset, IF_I_Ins, IF_pc_4)
begin
	if (reset = '1') then
		-- Lógica de reinicio
		IF_ID_inst <= '0';
		IF_ID_PC_4 <= '0';
	elsif rising_edge(clk) then
		IF_ID_inst <= IF_I_Ins;
		IF_ID_PC_4 <= IF_pc_4;
	end if;
end process IF_ID_process;
 
---------------------------------------------------------------------------------------------------------------
-- ETAPA ID
---------------------------------------------------------------------------------------------------------------
-- Instanciacion del banco de registros
Registers_inst:  registers 
	Port map (
			clk => clk, 
			reset => reset, 
			wr => RegWrite, 
			reg1_dr => ID_Instruction(25 downto 21), 
			reg2_dr => ID_Instruction( 20 downto 16), 
			reg_wr => WB_reg_wr, 
			data_wr => WB_data_wr , 
			data1_rd => ID_data1_rd ,
			data2_rd => ID_data2_rd ); 

 
 

---------------------------------------------------------------------------------------------------------------
-- REGISTRO DE SEGMENTACION ID/EX
---------------------------------------------------------------------------------------------------------------

 
---------------------------------------------------------------------------------------------------------------
-- ETAPA EX
---------------------------------------------------------------------------------------------------------------


---------------------------------------------------------------------------------------------------------------
-- REGISTRO DE SEGMENTACION EX/MEM
---------------------------------------------------------------------------------------------------------------


---------------------------------------------------------------------------------------------------------------
-- ETAPA MEM
---------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------
-- REGISTRO DE SEGMENTACION MEM/WB
---------------------------------------------------------------------------------------------------------------


---------------------------------------------------------------------------------------------------------------
-- ETAPA WB
---------------------------------------------------------------------------------------------------------------


end processor_arq;