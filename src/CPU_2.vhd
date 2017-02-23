library ieee;
use ieee.std_logic_1164.all;
use work.CpuTypes.all;

entity CPU_2 is

    port (
        clk_i: in std_logic;
        rst_i: in std_logic;
        PortData_o: out std_logic_vector(7 downto 0);
        PortAddr_o: out std_logic_vector(15 downto 0);
        PortWrite_o: out std_logic);

end entity CPU_2;

architecture Arch_CPU_2 of CPU_2 is

    signal RomData: std_logic_vector(7 downto 0);
    signal RomAddr: std_logic_vector(15 downto 0);

    signal EU_D: ExecuteUnit_D;
    signal EU_Q: ExecuteUnit_Q;

    signal FU_D: FetchUnit_D;
    signal FU_Q: FetchUnit_Q;

    signal CNT_D: Counter_D;
    signal CNT_Q: Counter_Q;

    signal PC_D: ProgramCounter_D;
    signal PC_Q: ProgramCounter_Q;

    signal R0_D: GenPurposeReg_D;
    signal R0_Q: GenPurposeReg_Q;

    signal R1_D: GenPurposeReg_D;
    signal R1_Q: GenPurposeReg_Q;

    signal PU_D: PeripheryUnit_D;
    signal PU_Q: PeripheryUnit_Q;

begin

    -- Program ROM address and data bus
    RomAddr <= PC_Q.Address;

    FU_D.Data <= RomData;
    FU_D.Ready <= EU_Q.Ready;

    PC_D.Load <= EU_Q.LoadPC;
    PC_D.Increment <= FU_Q.Increment;
    PC_D.Value <= FU_Q.Param(15 downto 0);

    R0_D.Value <= FU_Q.Param(7 downto 0);
    R0_D.Load <= EU_Q.LoadA;

    R1_D.Value <= FU_Q.Param(7 downto 0);
    R1_D.Load <= EU_Q.LoadB;

    EU_D.CntReady <= CNT_Q.Ready;
    EU_D.IsZero <= CNT_Q.IsZero;
    EU_D.Execute <= FU_Q.Execute;
    EU_D.Operation <= FU_Q.Operation;
    EU_D.OutReady <= PU_Q.Ready;

    CNT_D.Load <= EU_Q.LoadCnt;
    CNT_D.Decrement <= EU_Q.DecCnt;
    CNT_D.Value <= FU_Q.Param(31 downto 0);

    PU_D.DataA <= R0_Q.Data;
    PU_D.DataB <= R1_Q.Data;
    PU_D.Address <= FU_Q.Param(15 downto 0);
    PU_D.Write <= EU_Q.PortWrite;
    PU_D.DataOrigin <= EU_Q.DataOrigin;

    PortWrite_o <= PU_Q.Write;
    PortAddr_o <= PU_Q.Address;
    PortData_o <= PU_Q.Data;

    EU: ExecuteUnit
    port map (
        clk_i => clk_i,
        rst_i => rst_i,
        D => EU_D,
        Q => EU_Q);

    FU: FetchUnit
    port map (
        clk_i => clk_i,
        rst_i => rst_i,
        D => FU_D,
        Q => FU_Q);

    PU: PeripheryUnit
    port map (
        clk_i => clk_i,
        rst_i => rst_i,
        D => PU_D,
        Q => PU_Q);

    CNT: Counter
    port map (
        clk_i => clk_i,
        rst_i => rst_i,
        D => CNT_D,
        Q => CNT_Q);

    PC: ProgramCounter
    port map (
        clk_i => clk_i,
        rst_i => rst_i,
        D => PC_D,
        Q => PC_Q);

    R0: GenPurposeReg
    port map (
        clk_i => clk_i,
        rst_i => rst_i,
        D => R0_D,
        Q => R0_Q);

    R1: GenPurposeReg
    port map (
        clk_i => clk_i,
        rst_i => rst_i,
        D => R1_D,
        Q => R1_Q);

    EXE_ROM: ExecutableROM
    port map (
        addr_i => RomAddr,
        data_o => RomData);

end architecture Arch_CPU_2;

