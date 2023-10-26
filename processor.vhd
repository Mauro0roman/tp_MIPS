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
    Port ( a : in STD_LOGIC_VECTOR(7 downto 0);
           b : in STD_LOGIC_VECTOR(7 downto 0);
           control : in STD_LOGIC_VECTOR(2 downto 0);
           result : out STD_LOGIC_VECTOR(7 downto 0);
           zero : out STD_LOGIC);
end component;

--DECLARACION DE SEÑALES--
    --ETAPA IF--
	signal	mux_1, mux_2, I_Addr, I_DataOut, reg_PC, PC_4, IF_ID_PC_4, IF_ID_inst: STD_LOGIC_VECTOR (31 downto 0);
		mux_sel, I_WrStb, I_RdStb: in STD_LOGIC;
		

    --ETAPA ID--
	port   (ctrl_u : in STD_LOGIC_VECTOR (31 downto 0);
		sign_ex : in STD_LOGIC_VECTOR (15 downto 0);
		IF_instruction : out STD_LOGIC_VECTOR (31 downto 0);
		IF_pc_4 : out STD_LOGIC_VECTOR (31 downto 0));

    --ETAPA EX--

    --ETAPA MEM--
     
    --ETAPA WB--    
        
begin 	
---------------------------------------------------------------------------------------------------------------
-- ETAPA IF
---------------------------------------------------------------------------------------------------------------
	Port map (
			clk => clk, 
			reset => reset, 
			mux_1 => mux_1,
			mux_sel => mux_sel,
			mux_2 => pc_4,
			pc_sel => mux_out,
			ins_mem_in => pc_out,
			

 
 
 
---------------------------------------------------------------------------------------------------------------
-- REGISTRO DE SEGMENTACION IF/ID
--------------------------------------------------------------------------------------------------------------- 
 
 
 
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