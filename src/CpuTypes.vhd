library ieee;
use ieee.std_logic_1164.all;

package CpuTypes is

    type CpuTypesDataOrigin is (
        OriginRegisterA,
        OriginRegisterB,
        OriginConstant,
        OriginUnknown);

    type CpuTypesFetchState is (
        FETCH_RESET,
        FETCH_OP_CODE,
        FETCH_DECODE,
        FETCH_PARAM_0,
        FETCH_PARAM_1,
        FETCH_PARAM_2,
        FETCH_PARAM_3,
        FETCH_PARAM_4,
        FETCH_SET_EXEC,
        FETCH_WAIT_READY);

    type FetchUnit_D is record
        Data: std_logic_vector(7 downto 0);
        Ready: boolean;
    end record;

    type FetchUnit_Q is record
        Param: std_logic_vector(39 downto 0);
        Operation: std_logic_vector(7 downto 0);
        Execute: boolean;
        Increment: boolean;
    end record;

    component FetchUnit is

        port (
            clk_i: in std_logic;
            rst_i: std_logic;
            D: in FetchUnit_D;
            Q: out FetchUnit_Q);

    end component FetchUnit;

    type Counter_D is record
        Value: std_logic_vector(31 downto 0);
        Load: boolean;
        Decrement: boolean;
    end record;

    type Counter_Q is record
        Ready: boolean;
        IsZero: boolean;
    end record;

    component Counter is

        port (
            clk_i: in std_logic;
            rst_i: in std_logic;
            D: in Counter_D;
            Q: out Counter_Q);

    end component Counter;

    type GenPurposeReg_D is record
        Load: boolean;
        Value: std_logic_vector(7 downto 0);
    end record;

    type GenPurposeReg_Q is record
        Data: std_logic_vector(7 downto 0);
    end record;

    component GenPurposeReg is

        port (
            clk_i: in std_logic;
            rst_i: in std_logic;
            D: in GenPurposeReg_D;
            Q: out GenPurposeReg_Q);

    end component GenPurposeReg;

    type ProgramCounter_D is record
        Value: std_logic_vector(15 downto 0);
        Load: boolean;
        Increment: boolean;
    end record;

    type ProgramCounter_Q is record
        Address: std_logic_vector(15 downto 0);
    end record;

    component ProgramCounter is

        port (
            clk_i: in std_logic;
            rst_i: in std_logic;
            D: in ProgramCounter_D;
            Q: out ProgramCounter_Q);

    end component ProgramCounter;

    type CpuTypesExecuteState is (
        EXEC_RESET,
        EXEC_WAIT,
        EXEC_READY,
        EXEC_LOAD_A,
        EXEC_LOAD_B,
        EXEC_JUMP_ABSOLUTE,
        EXEC_JUMP_NZ,
        EXEC_INIT_CNT,
        EXEC_WAIT_CNT_READY,
        EXEC_DEC_CNT,
        EXEC_OUT_A,
        EXEC_OUT_B,
        EXEC_WAIT_FOR_OUT,
        EXEC_HALT);

    type ExecuteUnit_D is record
        Execute: boolean;
        Operation: std_logic_vector(7 downto 0);
        CntReady: boolean;
        IsZero: boolean;
        OutReady: boolean;
    end record;

    type ExecuteUnit_Q is record
        Ready: boolean;
        LoadA: boolean;
        LoadB: boolean;
        LoadPC: boolean;
        LoadCnt: boolean;
        DecCnt: boolean;
        PortWrite: boolean;
        DataOrigin: CpuTypesDataOrigin;
    end record;

    component ExecuteUnit is

        port (
            clk_i: in std_logic;
            rst_i: in std_logic;
            D: in ExecuteUnit_D;
            Q: out ExecuteUnit_Q);

    end component ExecuteUnit;

    type CpuTypesPeripheralState is (
        PERIPHERY_RESET,
        PERIPHERY_WAIT,
        PERIPHERY_WRITE,
        PERIPHERY_READY);

    type PeripheryUnit_D is record
        Address: std_logic_vector(15 downto 0);
        DataA: std_logic_vector(7 downto 0);
        DataB: std_logic_vector(7 downto 0);
        Write: boolean;
        DataOrigin: CpuTypesDataOrigin;
    end record;

    type PeripheryUnit_Q is record
        Address: std_logic_vector(15 downto 0);
        Data: std_logic_vector(7 downto 0);
        Write: std_logic;
        Ready: boolean;
    end record;

    component PeripheryUnit is

        port (
            clk_i: in std_logic;
            rst_i: in std_logic;
            D: in PeripheryUnit_D;
            Q: out PeripheryUnit_Q);

    end component PeripheryUnit;

    component ExecutableROM is
        port (
            addr_i: in std_logic_vector(15 downto 0);
            data_o: out std_logic_vector(7 downto 0));
    end component ExecutableROM;

    -- All possible operation code bytes
    constant CpuTypesOpNop: std_logic_vector(7 downto 0) := x"00";
    constant CpuTypesOpLoadRegisterA: std_logic_vector(7 downto 0) := x"01";
    constant CpuTypesOpLoadRegisterB: std_logic_vector(7 downto 0) := x"02";
    constant CpuTypesOpHalt: std_logic_vector(7 downto 0) := x"FF";
    constant CpuTypesOpOutRegisterA: std_logic_vector(7 downto 0) := x"03";
    constant CpuTypesOpOutRegisterB: std_logic_vector(7 downto 0) := x"04";
    constant CpuTypesOpInitCounter: std_logic_vector(7 downto 0) := x"05";
    constant CpuTypesOpDecCounter: std_logic_vector(7 downto 0) := x"06";
    constant CpuTypesOpJnzAddr: std_logic_vector(7 downto 0) := x"07";
    constant CpuTypesOpJmpAddr: std_logic_vector(7 downto 0) := x"08";

end package CpuTypes;

