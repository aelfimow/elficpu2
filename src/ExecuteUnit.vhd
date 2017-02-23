library ieee;
use ieee.std_logic_1164.all;
use work.CpuTypes.all;

entity ExecuteUnit is

    port (
        clk_i: in std_logic;
        rst_i: in std_logic;
        D: in ExecuteUnit_D;
        Q: out ExecuteUnit_Q);

end entity ExecuteUnit;

architecture ArchExecuteUnit of ExecuteUnit is

    signal clk: std_logic;
    signal rst: std_logic;
    signal Local_D: ExecuteUnit_D;
    signal Local_Q: ExecuteUnit_Q;

    signal State: CpuTypesExecuteState := EXEC_RESET;
    signal NewState: CpuTypesExecuteState := EXEC_RESET;
    signal ExecStartState: CpuTypesExecuteState := EXEC_RESET;

begin

    clk <= clk_i;
    rst <= rst_i;
    Local_D <= D;
    Q <= Local_Q;

    -- Description: This process decodes operation code and
    --              determines execution state to start with.
    OpDecodeLogic: process(Local_D)
    begin
        case Local_D.Operation is
            when CpuTypesOpNop =>
                ExecStartState <= EXEC_WAIT;
                null;

            when CpuTypesOpLoadRegisterA =>
                ExecStartState <= EXEC_LOAD_A;
                null;

            when CpuTypesOpLoadRegisterB =>
                ExecStartState <= EXEC_LOAD_B;
                null;

            when CpuTypesOpHalt =>
                ExecStartState <= EXEC_HALT;
                null;

            when CpuTypesOpOutRegisterA =>
                ExecStartState <= EXEC_OUT_A;
                null;

            when CpuTypesOpOutRegisterB =>
                ExecStartState <= EXEC_OUT_B;
                null;

            when CpuTypesOpInitCounter =>
                ExecStartState <= EXEC_INIT_CNT;
                null;

            when CpuTypesOpDecCounter =>
                ExecStartState <= EXEC_DEC_CNT;
                null;

            when CpuTypesOpJnzAddr =>
                ExecStartState <= EXEC_JUMP_NZ;
                null;

            when CpuTypesOpJmpAddr =>
                ExecStartState <= EXEC_JUMP_ABSOLUTE;
                null;

            when others =>
                ExecStartState <= EXEC_WAIT;
                null;
        end case;
    end process OpDecodeLogic;

    -- Description: This process performs input logic for
    --              the execution unit state machine.
    InputLogic: process(State, Local_D, ExecStartState)
    begin
        case State is
            when EXEC_RESET =>
                NewState <= EXEC_WAIT;
                null;

            when EXEC_WAIT =>
                if Local_D.Execute = false then
                    NewState <= EXEC_WAIT;
                else
                    NewState <= ExecStartState;
                end if;
                null;

            when EXEC_HALT =>
                -- Stop execution, stay in this state and
                -- do nothing
                NewState <= EXEC_HALT;
                null;

            when EXEC_LOAD_A =>
                NewState <= EXEC_READY;
                null;

            when EXEC_LOAD_B =>
                NewState <= EXEC_READY;
                null;

            when EXEC_JUMP_ABSOLUTE =>
                NewState <= EXEC_READY;
                null;

            when EXEC_INIT_CNT =>
                NewState <= EXEC_WAIT_CNT_READY;
                null;

            when EXEC_WAIT_CNT_READY =>
                if Local_D.CntReady = false then
                    NewState <= EXEC_WAIT_CNT_READY;
                else
                    NewState <= EXEC_READY;
                end if;

            when EXEC_DEC_CNT =>
                NewState <= EXEC_READY;
                null;

            when EXEC_JUMP_NZ =>
                if Local_D.IsZero = false then
                    NewState <= EXEC_JUMP_ABSOLUTE;
                else
                    NewState <= EXEC_READY;
                end if;
                null;

            when EXEC_OUT_A =>
                NewState <= EXEC_WAIT_FOR_OUT;
                null;

            when EXEC_OUT_B =>
                NewState <= EXEC_WAIT_FOR_OUT;
                null;

            when EXEC_WAIT_FOR_OUT =>
                if Local_D.OutReady = false then
                    NewState <= EXEC_WAIT_FOR_OUT;
                else
                    NewState <= EXEC_READY;
                end if;
                null;

            when EXEC_READY =>
                NewState <= EXEC_WAIT;
                null;

            when others =>
                NewState <= EXEC_RESET;
                null;
        end case;
    end process InputLogic;

    -- Description: This process handles state transitions
    --              of the execution unit state machine.
    StateTransitionLogic: process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                State <= EXEC_RESET;
            else
                State <= NewState;
            end if;
        end if;
    end process StateTransitionLogic;

    -- Description: This process realizes output logic
    --              of the execution unit state machine.
    OutputLogic: process(State)
    begin
        case State is
            when EXEC_RESET =>
                Local_Q.Ready <= false;
                Local_Q.LoadA <= false;
                Local_Q.LoadB <= false;
                Local_Q.LoadPC <= false;
                Local_Q.LoadCnt <= false;
                Local_Q.DecCnt <= false;
                Local_Q.PortWrite <= false;
                Local_Q.DataOrigin <= OriginUnknown;
                null;

            when EXEC_WAIT =>
                Local_Q.Ready <= false;
                Local_Q.LoadA <= false;
                Local_Q.LoadB <= false;
                Local_Q.LoadPC <= false;
                Local_Q.LoadCnt <= false;
                Local_Q.DecCnt <= false;
                Local_Q.PortWrite <= false;
                Local_Q.DataOrigin <= OriginUnknown;
                null;

            when EXEC_HALT =>
                Local_Q.Ready <= false;
                Local_Q.LoadA <= false;
                Local_Q.LoadB <= false;
                Local_Q.LoadPC <= false;
                Local_Q.LoadCnt <= false;
                Local_Q.DecCnt <= false;
                Local_Q.PortWrite <= false;
                Local_Q.DataOrigin <= OriginUnknown;
                null;

            when EXEC_LOAD_A =>
                Local_Q.Ready <= false;
                Local_Q.LoadA <= true;
                Local_Q.LoadB <= false;
                Local_Q.LoadPC <= false;
                Local_Q.LoadCnt <= false;
                Local_Q.DecCnt <= false;
                Local_Q.PortWrite <= false;
                Local_Q.DataOrigin <= OriginUnknown;
                null;

            when EXEC_LOAD_B =>
                Local_Q.Ready <= false;
                Local_Q.LoadA <= false;
                Local_Q.LoadB <= true;
                Local_Q.LoadPC <= false;
                Local_Q.LoadCnt <= false;
                Local_Q.DecCnt <= false;
                Local_Q.PortWrite <= false;
                Local_Q.DataOrigin <= OriginUnknown;
                null;

            when EXEC_JUMP_ABSOLUTE =>
                Local_Q.Ready <= true;
                Local_Q.LoadA <= false;
                Local_Q.LoadB <= false;
                Local_Q.LoadPC <= true;
                Local_Q.LoadCnt <= false;
                Local_Q.DecCnt <= false;
                Local_Q.PortWrite <= false;
                Local_Q.DataOrigin <= OriginUnknown;
                null;

            when EXEC_READY =>
                Local_Q.Ready <= true;
                Local_Q.LoadA <= false;
                Local_Q.LoadB <= false;
                Local_Q.LoadPC <= false;
                Local_Q.LoadCnt <= false;
                Local_Q.DecCnt <= false;
                Local_Q.PortWrite <= false;
                Local_Q.DataOrigin <= OriginUnknown;
                null;

            when EXEC_INIT_CNT =>
                Local_Q.Ready <= false;
                Local_Q.LoadA <= false;
                Local_Q.LoadB <= false;
                Local_Q.LoadPC <= false;
                Local_Q.LoadCnt <= true;
                Local_Q.DecCnt <= false;
                Local_Q.PortWrite <= false;
                Local_Q.DataOrigin <= OriginUnknown;
                null;

            when EXEC_WAIT_CNT_READY =>
                Local_Q.Ready <= false;
                Local_Q.LoadA <= false;
                Local_Q.LoadB <= false;
                Local_Q.LoadPC <= false;
                Local_Q.LoadCnt <= false;
                Local_Q.DecCnt <= false;
                Local_Q.PortWrite <= false;
                Local_Q.DataOrigin <= OriginUnknown;
                null;

            when EXEC_DEC_CNT =>
                Local_Q.Ready <= false;
                Local_Q.LoadA <= false;
                Local_Q.LoadB <= false;
                Local_Q.LoadPC <= false;
                Local_Q.LoadCnt <= false;
                Local_Q.DecCnt <= true;
                Local_Q.PortWrite <= false;
                Local_Q.DataOrigin <= OriginUnknown;
                null;

            when EXEC_OUT_A =>
                Local_Q.Ready <= false;
                Local_Q.LoadA <= false;
                Local_Q.LoadB <= false;
                Local_Q.LoadPC <= false;
                Local_Q.LoadCnt <= false;
                Local_Q.DecCnt <= false;
                Local_Q.PortWrite <= true;
                Local_Q.DataOrigin <= OriginRegisterA;
                null;

            when EXEC_OUT_B =>
                Local_Q.Ready <= false;
                Local_Q.LoadA <= false;
                Local_Q.LoadB <= false;
                Local_Q.LoadPC <= false;
                Local_Q.LoadCnt <= false;
                Local_Q.DecCnt <= false;
                Local_Q.PortWrite <= true;
                Local_Q.DataOrigin <= OriginRegisterB;
                null;

            when EXEC_WAIT_FOR_OUT =>
                Local_Q.Ready <= false;
                Local_Q.LoadA <= false;
                Local_Q.LoadB <= false;
                Local_Q.LoadPC <= false;
                Local_Q.LoadCnt <= false;
                Local_Q.DecCnt <= false;
                Local_Q.PortWrite <= false;
                Local_Q.DataOrigin <= OriginUnknown;
                null;

            when others =>
                Local_Q.Ready <= false;
                Local_Q.LoadA <= false;
                Local_Q.LoadB <= false;
                Local_Q.LoadPC <= false;
                Local_Q.LoadCnt <= false;
                Local_Q.DecCnt <= false;
                Local_Q.PortWrite <= false;
                Local_Q.DataOrigin <= OriginUnknown;
                null;
        end case;
    end process OutputLogic;

end architecture ArchExecuteUnit;

