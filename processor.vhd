library IEEE;
  use IEEE.STD_LOGIC_1164.all;
  use IEEE.STD_LOGIC_UNSIGNED.all;

entity processor is
  port (
    Clk       : in  std_logic;
    Reset     : in  std_logic;
    -- Instruction memory
    I_Addr    : out std_logic_vector(31 downto 0);
    I_RdStb   : out std_logic;
    I_WrStb   : out std_logic;
    I_DataOut : out std_logic_vector(31 downto 0);
    I_DataIn  : in  std_logic_vector(31 downto 0);
    -- Data memory
    D_Addr    : out std_logic_vector(31 downto 0);
    D_RdStb   : out std_logic;
    D_WrStb   : out std_logic;
    D_DataOut : out std_logic_vector(31 downto 0);
    D_DataIn  : in  std_logic_vector(31 downto 0)
  );
end entity;

architecture processor_arq of processor is

  --DECLARACION DE COMPONENTES--
  component registers
    port (clk      : in  std_logic;
          reset    : in  std_logic;
          wr       : in  std_logic;
          reg1_dr  : in  std_logic_vector(4 downto 0);
          reg2_dr  : in  std_logic_vector(4 downto 0);
          reg_wr   : in  std_logic_vector(4 downto 0);
          data_wr  : in  std_logic_vector(31 downto 0);
          data1_rd : out std_logic_vector(31 downto 0);
          data2_rd : out std_logic_vector(31 downto 0)
         );
  end component;
  component ALU
    port (a      : in  std_logic_vector(31 downto 0);
          b      : in  std_logic_vector(31 downto 0);
          op     : in  std_logic_vector(2 downto 0);
          result : out std_logic_vector(31 downto 0);
          zero   : out std_logic
         );
  end component;
  component control
    port (clk        : in  std_logic;
          reset      : in  std_logic;
          inst       : in  std_logic_vector(31 downto 0);
          reg_dst    : out std_logic;
          branch     : out std_logic;
          mem_rd     : out std_logic;
          mem_wr     : out std_logic;
          mem_to_reg : out std_logic;
          alu_op     : out std_logic_vector(2 downto 0);
          alu_src    : out std_logic;
          reg_wr     : out std_logic
         );
  end component;
  component ALU_control
    port (
      clk            : in  std_logic;
      reset          : in  std_logic;
      inst           : in  std_logic_vector(31 downto 0);
      control_alu_op : in  std_logic_vector(2 downto 0);
      alu_op         : out std_logic_vector(2 downto 0)
    );
  end component;

  --DECLARACION DE SE�ALES--
  --ETAPA IF--
  signal IF_I_Ins, IF_reg_PC, IF_pc_4, IF_ID_PC_4, IF_ID_inst : std_logic_vector(31 downto 0);
  signal PC_src                                               : std_logic;

  --ETAPA ID--
  signal ID_reg_dst, ID_branch, ID_mem_rd, ID_mem_wr, ID_reg_wr, ID_mem_to_reg, ID_alu_src, ctrl_ID_EX_MEM_read, ctrl_ID_EX_MEM_write, ctrl_ID_EX_MEM_toReg, ctrl_ID_EX_ALU_src, ctrl_ID_EX_branch, ctrl_ID_EX_reg_dst, ctrl_ID_EX_reg_wr : std_logic;
  signal ID_data1_rd, ID_data2_rd, ID_sign_ex32, ID_Instruction, ID_EX_PC_4, ID_EX_data1_rd, ID_EX_data2_rd, ID_EX_sign_ex32                                                                                                              : std_logic_vector(31 downto 0);
  signal ctrl_ID_EX_ALU_op, ID_alu_op                                                                                                                                                                                                     : std_logic_vector(2 downto 0);
  signal ID_EX_inst1, ID_EX_inst2                                                                                                                                                                                                         : std_logic_vector(4 downto 0);

  --ETAPA EX--
  signal ctrl_EX_MEM_mem_read, ctrl_EX_MEM_mem_write, ctrl_EX_MEM_mem_toReg, ctrl_EX_MEM_reg_wr, ctrl_EX_MEM_branch, EX_MEM_flagzero, EX_flagzero             : std_logic;
  signal EX_alu_op                                                                                                                                            : std_logic_vector(2 downto 0);
  signal EX_MEM_reg_dst, EX_reg_dst                                                                                                                           : std_logic_vector(4 downto 0);
  signal EX_ALU_out, EX_MEM_ALU_out, EX_ALU_in2, EX_PCshift, EX_MEM_datawrite, EX_MEM_PCshift                                                                 : std_logic_vector(31 downto 0);
  --ETAPA MEM--
  signal MEM_WB_datawrite, MEM_WB_mem_data         : std_logic_vector(31 downto 0);
  signal MEM_WB_reg_dst                            : std_logic_vector(4 downto 0);
  signal ctrl_MEM_WB_mem_toReg, ctrl_MEM_WB_reg_wr : std_logic;
  --ETAPA WB--    
  signal WB_data_wr : std_logic_vector(31 downto 0);
begin
  ---------------------------------------------------------------------------------------------------------------
  -- ETAPA IF
  ---------------------------------------------------------------------------------------------------------------
  IF_process: process (clk, reset)
  begin
    if (reset = '1') then
      -- Lógica de reinicio
      IF_reg_PC <= (others => '0');
    end if;
    -- Lógica de la etapa IF
    IF_pc_4 <= IF_reg_PC + 4;
    if (PC_src = '0') then
      IF_reg_PC <= IF_pc_4;
    else
      IF_reg_PC <= EX_MEM_PCshift;
    end if;

  end process;
  I_RdStb  <= '1';
  I_WrStb  <= '0';
  I_Addr   <= IF_reg_PC;
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
  end process;

  ---------------------------------------------------------------------------------------------------------------
  -- ETAPA ID
  ---------------------------------------------------------------------------------------------------------------
  ID_Instruction <= IF_ID_inst;

  -- Instanciacion del banco de registros
  Registers_inst: registers
    port map (
      clk      => clk,
      reset    => reset,
      wr       => ctrl_MEM_WB_reg_wr,
      reg1_dr  => ID_Instruction(25 downto 21),
      reg2_dr  => ID_Instruction(20 downto 16),
      reg_wr   => MEM_WB_reg_dst,
      data_wr  => WB_data_wr,
      data1_rd => ID_data1_rd,
      data2_rd => ID_data2_rd);
  Control_inst: control
    port map (
      clk        => clk,
      reset      => reset,
      inst       => ID_Instruction,
      reg_dst    => ID_reg_dst,
      branch     => ID_branch,
      mem_rd     => ID_mem_rd,
      mem_wr     => ID_mem_wr,
      mem_to_reg => ID_mem_to_reg,
      alu_op     => ID_alu_op,
      alu_src    => ID_alu_src,
      reg_wr     => ID_reg_wr);

  ID_process: process (reset, ID_reg_dst)
  begin
    if (reset = '1') then
      ID_data1_rd <= (others => '0');
      ID_data2_rd <= (others => '0');
      ID_Instruction <= (others => '0');
      ID_sign_ex32 <= (others => '0');
    end if;

  end process;
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

  end process;

  ---------------------------------------------------------------------------------------------------------------
  -- ETAPA EX
  ---------------------------------------------------------------------------------------------------------------

  EX_process: process (reset, ctrl_ID_EX_ALU_src)
  begin
    if reset = '1' then
      ID_EX_sign_ex32 <= (others => '0');
      EX_reg_dst <= (others => '0');
      EX_ALU_out <= (others => '0');
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

  end process;
  alu_control_inst: ALU_control
    port map (
      clk            => clk,
      reset          => reset,
      inst           => ID_EX_sign_ex32,
      control_alu_op => ctrl_ID_EX_ALU_op,
      alu_op         => EX_alu_op
    );
  ALU_inst: ALU
    port map (
      a      => ID_EX_data1_rd,
      b      => EX_ALU_in2,
      op     => EX_alu_op,
      result => EX_ALU_out,
      zero   => EX_flagzero
    );
  EX_PCshift <= ID_EX_PC_4(29 downto 0) & "00";

  ---------------------------------------------------------------------------------------------------------------
  -- REGISTRO DE SEGMENTACION EX/MEM
  ---------------------------------------------------------------------------------------------------------------

  EX_MEM_process: process (clk, reset)
  begin
    if (reset = '1') then
      -- Lógica de reinicio
      EX_MEM_PCshift <= (others => '0');
      EX_MEM_ALU_out <= (others => '0');
      EX_MEM_flagzero <= '0';
      EX_MEM_reg_dst <= (others => '0');
      EX_MEM_datawrite <= (others => '0');
      ctrl_EX_MEM_branch <= '0';
      ctrl_EX_MEM_mem_read <= '0';
      ctrl_EX_MEM_mem_toReg <= '0';
      ctrl_EX_MEM_mem_write <= '0';
      ctrl_EX_MEM_reg_wr <= '0';

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

  end process;

  ---------------------------------------------------------------------------------------------------------------
  -- ETAPA MEM
  ---------------------------------------------------------------------------------------------------------------

  MEM_process: process (reset)
  begin
    if ctrl_EX_MEM_branch and EX_MEM_flagzero then
      PC_src <= '1';
    else
      PC_src <= '0';
    end if;
  end process;
  D_Addr    <= EX_MEM_ALU_out;
  D_DataOut <= EX_MEM_datawrite;
  D_RdStb   <= ctrl_EX_MEM_mem_read;
  D_WrStb   <= ctrl_EX_MEM_mem_write;

  ---------------------------------------------------------------------------------------------------------------
  -- REGISTRO DE SEGMENTACION MEM/WB
  ---------------------------------------------------------------------------------------------------------------

  MEM_WB_process: process (clk, reset)
  begin
    if (reset = '1') then
      -- Lógica de reinicio
      MEM_WB_reg_dst <= (others => '0');
      MEM_WB_datawrite <= (others => '0');
      MEM_WB_mem_data <= (others => '0');
      ctrl_MEM_WB_mem_toReg <= '0';
      ctrl_MEM_WB_reg_wr <= '0';

    elsif rising_edge(clk) then
      MEM_WB_mem_data <= D_DataIn;
      MEM_WB_reg_dst <= EX_MEM_reg_dst;
      MEM_WB_datawrite <= EX_MEM_datawrite;
      ctrl_MEM_WB_mem_toReg <= ctrl_EX_MEM_mem_toReg;
      ctrl_MEM_WB_reg_wr <= ctrl_EX_MEM_reg_wr;

    end if;

  end process;

  ---------------------------------------------------------------------------------------------------------------
  -- ETAPA WB
  ---------------------------------------------------------------------------------------------------------------

  
  WB_data_wr <= MEM_WB_datawrite when (ctrl_MEM_WB_mem_toReg = '1') else MEM_WB_mem_data;
    
end architecture;
