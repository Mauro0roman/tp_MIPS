library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity processor is
port(
	Clk         : in  std_logic;
	Reset       : in  std_logic;
	-- Instruction memory
	I_Addr      : out std_logic_vector(31 downto 0); --Sacarlo del rising edge y la lsita de sensibilidad
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
			IF_ID_PC_4, IF_ID_inst: STD_LOGIC_VECTOR (31 downto 0);
	signal	IF_ctrl_mux_sel: STD_LOGIC;
		

    --ETAPA ID--
	signal  ID_reg_dst, ID_branch, ID_mem_rd, ID_mem_wr,
	 		ID_mem_to_reg, ID_alu_src, ctrl_ID_EX_MEM_read, ctrl_ID_EX_MEM_write, ctrl_ID_EX_MEM_toReg,
			ctrl_ID_EX_ALU_src, ctrl_ID_EX_branch: STD_LOGIC;
	signal	ID_data1_rd, ID_data2_rd, ID_sign_ex32,
			ID_EX_data1_rd, ID_EX_data2_rd, ID_EX_sign_ex32: STD_LOGIC_VECTOR (31 downto 0);
	signal	ctrl_ID_EX_ALU_op, ID_alu_op: STD_LOGIC_VECTOR(2 downto 0);

    --ETAPA EX--

    --ETAPA MEM--
     
    --ETAPA WB--    
        
begin 	
---------------------------------------------------------------------------------------------------------------
-- ETAPA IF
---------------------------------------------------------------------------------------------------------------
IF_process: process (clk, reset, IF_ctrl_mux_sel)
begin
	if (reset = '1') then
		-- Lógica de reinicio
		IF_reg_PC <= (others => '0');
	end if;
	-- Lógica de la etapa IF

	IF_pc_4 <= IF_reg_PC + 4;
	if(IF_ctrl_mux_sel = '0') then
		IF_reg_PC <= IF_pc_4;
	else 
		IF_reg_PC <= branch_addr;
	end if;
	
end process IF_process;
I_RdStb <= '1';
I_WrStb <= '0';
I_Addr <= IF_reg_PC;
IF_I_Ins <= I_DataIn;

 
 
 
---------------------------------------------------------------------------------------------------------------
-- REGISTRO DE SEGMENTACION IF/ID
--------------------------------------------------------------------------------------------------------------- 
IF_ID_process: process (clk, reset, IF_I_Ins, IF_pc_4)
begin
	if (reset = '1') then
		-- Lógica de reinicio
		IF_ID_inst <= (others => '0');
		IF_ID_PC_4 <= (others => '0');
	elsif rising_edge(clk) then
		IF_ID_inst <= IF_I_Ins;
		IF_ID_PC_4 <= IF_pc_4;
	end if;
end process IF_ID_process;
 
---------------------------------------------------------------------------------------------------------------
-- ETAPA ID
---------------------------------------------------------------------------------------------------------------

IF_ID_inst => ID_Instruction; 

-- Instanciacion del banco de registros
Registers_inst:  registers 
	Port map (
			clk => clk, 
			reset => reset, 
			wr => RegWrite, 
			reg1_dr => ID_Instruction(25 downto 21), 
			reg2_dr => ID_Instruction( 20 downto 16), 
			reg_wr => WB_reg_wr, 
			data_wr => WB_data_wr, 
			data1_rd => ID_data1_rd,
			data2_rd => ID_data2_rd ); 
Control_inst: control
	Port map (
			clk => clk,
			reset => reset,
			inst => ID_Instruction,
			reg_dst => ID_reg_dst,
			branch => ID_branch,
			mem_rd => ID_mem_rd,
			mem_wr => ID_mem_wr,
			mem_to_reg => ID_mem_to_reg,
			alu_op => ID_alu_op,
			alu_src => ID_alu_src,
			reg_wr => ID_reg_wr);

ID_process: process(reset, ID_reg_dst)
begin
	if (reset = '1') then
		ID_data1_rd <= (others => '0');
		ID_data2_rd <= (others => '0');
		ID_Instruction <= (others => '0');
		ID_sign_ex32 <= (others => '0');
	end if;

	if(ID_reg_dst == '1') then
		WB_reg_wr <= ID_Instruction(15 downto 11);
	else
		WB_reg_wr <= ID_Instruction(20 downto 16);
	end if;
end process ID_process;
-- Sign Extend 16 a 32 -- 
ID_sign_ex32 <= "0000000000000000" & ID_Instruction(15 downto 0);

	

---------------------------------------------------------------------------------------------------------------
-- REGISTRO DE SEGMENTACION ID/EX
---------------------------------------------------------------------------------------------------------------
ID_EX_process: process (clk, reset)
begin
	if (reset = '1') then
		-- Lógica de reinicio
		IF_ID_inst <= (others => '0');
		IF_ID_PC_4 <= (others => '0');
		ID_EX_PC_4 <= (others => '0');
		ID_EX_data1_rd <= (others => '0');
		ID_EX_data2_rd <= (others => '0');
		ID_EX_sign_ex32 <= (others => '0');
		ctrl_ID_EX_MEM_read <= '0';
		ctrl_ID_EX_MEM_write <= '0';
		ctrl_ID_EX_MEM_toReg <= '0';
		ctrl_ID_EX_ALU_op <= (others => '0');
		ctrl_ID_EX_ALU_src <= '0';
		ctrl_ID_EX_branch <= '0';
|	-- Los rising edge son solo para crear registros
	elsif rising_edge(clk) then
		ID_EX_PC_4 <= IF_ID_PC_4;
		ID_EX_data1_rd <= ID_data1_rd;
		ID_EX_data2_rd <= ID_data2_rd;
		ID_EX_sign_ex32 <= ID_sign_ex32;
		ctrl_ID_EX_MEM_read <= ID_mem_rd;
		ctrl_ID_EX_MEM_write <= ID_mem_wr;
		ctrl_ID_EX_MEM_toReg <= ID_mem_to_reg;
		ctrl_ID_EX_ALU_op <= ID_alu_op;
		ctrl_ID_EX_ALU_src <= ID_alu_src;
		ctrl_ID_EX_branch <= ID_branch;
	end if;

end process ID_EX_process;

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
