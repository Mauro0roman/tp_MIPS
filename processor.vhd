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
			reg_wr : out STD_LOGIC
			);
end component;
component ALU_control
	Port(
			clk : in STD_LOGIC;
			reset : in STD_LOGIC;
			inst : in std_logic_vector(31 downto 0);
			control_alu_op : in std_logic_vector(2 downto 0);
			alu_op : out std_logic_vector(2 downto 0)
		);
end component;
component memory
	Port ( 
		Addr : in std_logic_vector(31 downto 0);
        DataIn : in std_logic_vector(31 downto 0);
        RdStb : in std_logic ;
        WrStb : in std_logic ;
        Clk : in std_logic ;						  
        DataOut : out std_logic_vector(31 downto 0));
end component;

--DECLARACION DE SE�ALES--
    --ETAPA IF--
	signal	IF_I_Ins, IF_reg_PC, IF_pc_4,
			IF_ID_PC_4, IF_ID_inst: STD_LOGIC_VECTOR (31 downto 0);
	signal	IF_ctrl_mux_sel, PC_src: STD_LOGIC;
		

    --ETAPA ID--
	signal  ID_reg_dst, ID_branch, ID_mem_rd, ID_mem_wr, ID_reg_wr,
	 		ID_mem_to_reg, ID_alu_src, ctrl_ID_EX_MEM_read, ctrl_ID_EX_MEM_write, ctrl_ID_EX_MEM_toReg,
			ctrl_ID_EX_ALU_src, ctrl_ID_EX_branch, ctrl_ID_EX_reg_dst, ctrl_ID_EX_reg_wr: STD_LOGIC;
	signal	ID_data1_rd, ID_data2_rd, ID_sign_ex32, ID_Instruction, ID_EX_PC_4,
			ID_EX_data1_rd, ID_EX_data2_rd, ID_EX_sign_ex32: STD_LOGIC_VECTOR (31 downto 0);
	signal	ctrl_ID_EX_ALU_op, ID_alu_op: STD_LOGIC_VECTOR(2 downto 0);
	signal  ID_EX_inst1, ID_EX_inst2: std_logic_vector(4 downto 0);

    --ETAPA EX--
	signal  ctrl_EX_MEM_mem_read, ctrl_EX_MEM_mem_write, ctrl_EX_MEM_mem_toReg, ctrl_EX_MEM_reg_wr,
			EX_ALU_src, ctrl_EX_MEM_branch, EX_MEM_flagzero, EX_flagzero: std_logic;
	signal	EX_alu_op: STD_LOGIC_VECTOR(2 downto 0);
	signal  EX_MEM_reg_dst, EX_reg_dst: std_logic_vector(4 downto 0);
	signal 	EX_ALU_out, EX_MEM_ALU_out, EX_ALU_in2, EX_PCshift, EX_MEM_datawrite, EX_MEM_PCshift: STD_LOGIC_VECTOR (31 downto 0);
    --ETAPA MEM--
    signal MEM_WB_datawrite, MEM_WB_mem_data: std_logic_vector(31 downto 0); 
	signal MEM_WB_reg_dst: std_logic_vector(4 downto 0);
	signal ctrl_MEM_WB_mem_toReg, ctrl_MEM_WB_reg_wr : std_logic;
    --ETAPA WB--    
	signal WB_data_wr: std_logic_vector(31 downto 0); 
begin 	
---------------------------------------------------------------------------------------------------------------
-- ETAPA IF
---------------------------------------------------------------------------------------------------------------
IF_process: process(clk, reset)
begin
	if (reset = '1') then
		-- Lógica de reinicio
		IF_reg_PC <= (others => '0');
	end if;
	-- Lógica de la etapa IF

	IF_pc_4 <= IF_reg_PC + 4;
	if(PC_src = '0') then
		IF_reg_PC <= IF_pc_4;
	else 
		IF_reg_PC <= EX_MEM_PCshift;
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

ID_Instruction <= IF_ID_inst; 

-- Instanciacion del banco de registros
Registers_inst:  registers 
	Port map (
			clk => clk, 
			reset => reset, 
			wr => ctrl_MEM_WB_reg_wr, 
			reg1_dr => ID_Instruction(25 downto 21), 
			reg2_dr => ID_Instruction( 20 downto 16), 
			reg_wr => MEM_WB_reg_dst, 
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
		ID_EX_PC_4 <= (others => '0');
		ID_EX_data1_rd <= (others => '0');
		ID_EX_data2_rd <= (others => '0');
		ID_EX_sign_ex32 <= (others => '0');
		ctrl_ID_EX_reg_dst <= '0';
		ctrl_ID_EX_MEM_read <= '0';
		ctrl_ID_EX_MEM_write <= '0';
		ctrl_ID_EX_MEM_toReg <= '0';
		ctrl_ID_EX_ALU_op <= (others => '0');
		ctrl_ID_EX_ALU_src <= '0';
		ctrl_ID_EX_branch <= '0';
		ctrl_ID_EX_reg_wr <= '0';
	-- Los rising edge son solo para crear registros
	elsif rising_edge(clk) then
		ID_EX_PC_4 <= IF_ID_PC_4;
		ID_EX_data1_rd <= ID_data1_rd;
		ID_EX_data2_rd <= ID_data2_rd;
		ID_EX_sign_ex32 <= ID_sign_ex32;
		ID_EX_inst1 <= ID_Instruction(15 downto 11);
		ID_EX_inst2 <= ID_Instruction(20 downto 16);
		ctrl_ID_EX_reg_dst <= ID_reg_dst;
		ctrl_ID_EX_MEM_read <= ID_mem_rd;
		ctrl_ID_EX_MEM_write <= ID_mem_wr;
		ctrl_ID_EX_MEM_toReg <= ID_mem_to_reg;
		ctrl_ID_EX_ALU_op <= ID_alu_op;
		ctrl_ID_EX_ALU_src <= ID_alu_src;
		ctrl_ID_EX_branch <= ID_branch;
		ctrl_ID_EX_reg_wr <= ID_reg_wr;
	end if;

end process ID_EX_process;

---------------------------------------------------------------------------------------------------------------
-- ETAPA EX
---------------------------------------------------------------------------------------------------------------


EX_process: process (reset, ctrl_ID_EX_ALU_src)
begin
	if reset = "1" then

	end if;
	if ctrl_ID_EX_ALU_src = '1' then
		EX_ALU_in2 <= ID_EX_sign_ex32;
	else
		EX_ALU_in2 <= ID_EX_data2_rd;
	end if;

	if ctrl_ID_EX_reg_dst = '1' then
	EX_reg_dst <= ID_EX_inst1;
	else
	EX_reg_dst <= ID_EX_inst2;
	end if;

end process EX_process;
alu_control_inst: ALU_control
	port map(
			clk => clk,
			reset => reset,
			inst => ID_EX_sign_ex32,
			control_alu_op => ctrl_ID_EX_ALU_op,
			alu_op => EX_alu_op
			);
ALU_inst: ALU 
	port map (
			a => ID_EX_data1_rd,
            b => EX_ALU_in2,
            op => EX_alu_op,
            result => EX_ALU_out,
            zero => EX_flagzero
			);
EX_PCshift <= ID_EX_PC_4 & "00";


---------------------------------------------------------------------------------------------------------------
-- REGISTRO DE SEGMENTACION EX/MEM
---------------------------------------------------------------------------------------------------------------
EX_MEM_process: process (clk, reset)
begin
	if (reset = '1') then
		-- Lógica de reinicio
		EX_MEM_PCshift <= (others => "0");
		EX_MEM_ALU_out <= (others => "0");
		EX_MEM_flagzero <= "0";
		EX_MEM_reg_dst <= (others => "0");
		EX_MEM_datawrite <= (others => "0");
		ctrl_EX_MEM_branch <= "0";
		ctrl_EX_MEM_mem_read <= "0";
		ctrl_EX_MEM_mem_toReg <= "0";
		ctrl_EX_MEM_mem_write <= "0";
		ctrl_EX_MEM_reg_wr <= "0";

	-- Los rising edge son solo para crear registros
	elsif rising_edge(clk) then
		EX_MEM_PCshift <= EX_PCshift;
		EX_MEM_ALU_out <= EX_ALU_out;
		EX_MEM_flagzero <= EX_flagzero;
		EX_MEM_reg_dst <= EX_reg_dst;
		EX_MEM_datawrite <= ID_EX_data2_rd;
		ctrl_EX_MEM_branch <= ctrl_ID_EX_branch;
		ctrl_EX_MEM_mem_read <= ctrl_ID_EX_MEM_read;
		ctrl_EX_MEM_mem_toReg <= ctrl_ID_EX_MEM_toReg;
		ctrl_EX_MEM_mem_write <= ctrl_ID_EX_MEM_write;
		ctrl_EX_MEM_reg_wr <= ctrl_ID_EX_reg_wr;
	end if;

end process EX_MEM_process;

---------------------------------------------------------------------------------------------------------------
-- ETAPA MEM
---------------------------------------------------------------------------------------------------------------
MEM_process: process(reset)
begin	
	if ctrl_EX_MEM_branch and EX_MEM_flagzero then
		PC_src <= "1";
	else
		PC_src <= "0";
	end if;
end process MEM_process;
D_Addr <= EX_MEM_ALU_out;
D_DataOut <= EX_MEM_datawrite;
D_RdStb <= ctrl_EX_MEM_mem_read;
D_WrStb <= ctrl_EX_MEM_mem_write;
memory_inst: memory
	Port map( 
			Addr <= D_Addr,
			DataIn <= D_DataOut,
			RdStb <= D_DataOut,
			WrStb <= D_WrStb,
			Clk <= clk,					  
			DataOut <= D_DataIn);


---------------------------------------------------------------------------------------------------------------
-- REGISTRO DE SEGMENTACION MEM/WB
---------------------------------------------------------------------------------------------------------------
MEM_WB_process: process (clk, reset)
begin
	if (reset = '1') then
		-- Lógica de reinicio
		MEM_WB_reg_dst <= (others => "0");
		MEM_WB_datawrite <= (others => "0");
		MEM_WB_mem_data <= (others => "0");
		ctrl_MEM_WB_mem_toReg <= "0";
		ctrl_MEM_WB_reg_wr <= "0";
	
	elsif rising_edge(clk) then
		MEM_WB_mem_data <= D_DataIn;
		MEM_WB_reg_dst <= EX_MEM_reg_dst;
		MEM_WB_datawrite <= EX_MEM_datawrite;
		ctrl_MEM_WB_mem_toReg <= ctrl_EX_MEM_mem_toReg;
		ctrl_MEM_WB_reg_wr <= ctrl_EX_MEM_reg_wr;
		
	end if;

end process MEM_WB_process;


---------------------------------------------------------------------------------------------------------------
-- ETAPA WB
---------------------------------------------------------------------------------------------------------------
	WB_process: process(reset)
	begin 
		if ctrl_MEM_WB_mem_toReg = "1" then
			WB_data_wr <= MEM_WB_datawrite;
		else
			WB_data_wr <= MEM_WB_mem_data;
		end if;
	end process WB_process;
end processor_arq;
