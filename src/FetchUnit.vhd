library ieee;
use ieee.std_logic_1164.all;
use work.CpuTypes.all;

entity FetchUnit is

    port (
        clk_i: in std_logic;
        rst_i: in std_logic;
        D: in FetchUnit_D;
        Q: out FetchUnit_Q);

end entity FetchUnit;

architecture ArchFetchUnit of FetchUnit is

    signal clk: std_logic;
    signal rst: std_logic;

    signal State: CpuTypesFetchState;
    signal NewState: CpuTypesFetchState;
    signal Local_D: FetchUnit_D;
    signal Local_Q: FetchUnit_Q;
    signal SetExecute: boolean;
    signal StopOnParam0: boolean;
    signal StopOnParam1: boolean;
    signal StopOnParam2: boolean;
    signal StopOnParam3: boolean;

begin

    clk <= clk_i;
    rst <= rst_i;
    Local_D <= D;
    Q <= Local_Q;

    -- Description: This process decodes operation byte and sets
    --              corresponding flags for fetching state machine.
    process(Local_Q.Operation)
    begin
        case Local_Q.Operation is
            when CpuTypesOpNop =>
                SetExecute <= true;
                StopOnParam0 <= false;
                StopOnParam1 <= false;
                StopOnParam2 <= false;
                StopOnParam3 <= false;
                null;

            when CpuTypesOpLoadRegisterA =>
                SetExecute <= false;
                StopOnParam0 <= true;
                StopOnParam1 <= false;
                StopOnParam2 <= false;
                StopOnParam3 <= false;
                null;

            when CpuTypesOpLoadRegisterB =>
                SetExecute <= false;
                StopOnParam0 <= true;
                StopOnParam1 <= false;
                StopOnParam2 <= false;
                StopOnParam3 <= false;
                null;

            when CpuTypesOpHalt =>
                SetExecute <= false;
                StopOnParam0 <= false;
                StopOnParam1 <= false;
                StopOnParam2 <= false;
                StopOnParam3 <= false;
                null;

            when CpuTypesOpOutRegisterA =>
                SetExecute <= false;
                StopOnParam0 <= false;
                StopOnParam1 <= true;
                StopOnParam2 <= false;
                StopOnParam3 <= false;
                null;

            when CpuTypesOpOutRegisterB =>
                SetExecute <= false;
                StopOnParam0 <= false;
                StopOnParam1 <= true;
                StopOnParam2 <= false;
                StopOnParam3 <= false;
                null;

            when CpuTypesOpInitCounter =>
                SetExecute <= false;
                StopOnParam0 <= false;
                StopOnParam1 <= false;
                StopOnParam2 <= false;
                StopOnParam3 <= true;
                null;

            when CpuTypesOpDecCounter =>
                SetExecute <= true;
                StopOnParam0 <= false;
                StopOnParam1 <= false;
                StopOnParam2 <= false;
                StopOnParam3 <= false;
                null;

            when CpuTypesOpJnzAddr =>
                SetExecute <= false;
                StopOnParam0 <= false;
                StopOnParam1 <= true;
                StopOnParam2 <= false;
                StopOnParam3 <= false;
                null;

            when CpuTypesOpJmpAddr =>
                SetExecute <= false;
                StopOnParam0 <= false;
                StopOnParam1 <= true;
                StopOnParam2 <= false;
                StopOnParam3 <= false;
                null;

            when others =>
                SetExecute <= true;
                StopOnParam0 <= false;
                StopOnParam1 <= false;
                StopOnParam2 <= false;
                StopOnParam3 <= false;
                null;
        end case;
    end process;

    -- Description: This process decodes current state of the
    --              fetch state machine and determines so and
    --              with some help signals next state.
    InputLogic: process(State, SetExecute, StopOnParam0, StopOnParam1, StopOnParam2, StopOnParam3, Local_D)
    begin
        case State is
            when FETCH_RESET =>
                -- start fetching operation code byte
                NewState <= FETCH_OP_CODE;
                null;

            when FETCH_OP_CODE =>
                NewState <= FETCH_DECODE;
                null;

            when FETCH_DECODE =>
                if SetExecute = false then
                    -- continue fetching parameters
                    NewState <= FETCH_PARAM_0;
                else
                    -- stop fetching parameters
                    NewState <= FETCH_SET_EXEC;
                end if;
                null;

            when FETCH_PARAM_0 =>
                if StopOnParam0 = false then
                    -- continue fetching parameters
                    NewState <= FETCH_PARAM_1;
                else
                    -- stop fetching parameters
                    NewState <= FETCH_SET_EXEC;
                end if;
                null;

            when FETCH_PARAM_1 =>
                if StopOnParam1 = false then
                    -- continue fetching parameters
                    NewState <= FETCH_PARAM_2;
                else
                    -- stop fetching parameters
                    NewState <= FETCH_SET_EXEC;
                end if;
                null;

            when FETCH_PARAM_2 =>
                if StopOnParam2 = false then
                    -- continue fetching parameters
                    NewState <= FETCH_PARAM_3;
                else
                    -- stop fetching parameters
                    NewState <= FETCH_SET_EXEC;
                end if;
                null;

            when FETCH_PARAM_3 =>
                if StopOnParam3 = false then
                    -- continue fetching parameters
                    NewState <= FETCH_PARAM_4;
                else
                    -- stop fetching parameters
                    NewState <= FETCH_SET_EXEC;
                end if;
                null;

            when FETCH_PARAM_4 =>
                -- This state is last in the fetching chain
                -- Change state without checking any stop flags
                NewState <= FETCH_SET_EXEC;
                null;

            when FETCH_SET_EXEC =>
                NewState <= FETCH_WAIT_READY;
                null;

            when FETCH_WAIT_READY =>
                if Local_D.Ready = false then
                    -- External unit is not ready, do nothing here
                    NewState <= FETCH_WAIT_READY;
                else
                    -- External unit is ready, change state
                    NewState <= FETCH_OP_CODE;
                end if;
                null;

            when others =>
                -- something went wrong, reset state machine
                NewState <= FETCH_RESET;
                null;
        end case;
    end process InputLogic;

    -- Description: This process handles state transitio logic of
    --              fetching unit state machine.
    StateTransitionLogic: process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                -- reset is active, reset all local signals
                State <= FETCH_RESET;
                Local_Q.Param <= (others => '0');
                Local_Q.Operation <= CpuTypesOpNop;
            else
                -- Save new state machine state
                State <= NewState;

                -- Local signals as registers
                Local_Q.Operation <= Local_Q.Operation;
                Local_Q.Param <= Local_Q.Param;

                -- Check current state and perform corresponding action
                case State is
                    when FETCH_RESET =>
                        Local_Q.Param <= (others => '0');
                        Local_Q.Operation <= (others => '0');
                        null;

                    when FETCH_OP_CODE =>
                        Local_Q.Operation <= Local_D.Data;
                        null;

                    when FETCH_DECODE =>
                        -- do nothing here
                        null;

                    when FETCH_PARAM_0 =>
                        Local_Q.Param(7 downto 0) <= Local_D.Data;
                        null;

                    when FETCH_PARAM_1 =>
                        Local_Q.Param(15 downto 8) <= Local_D.Data;
                        null;

                    when FETCH_PARAM_2 =>
                        Local_Q.Param(23 downto 16) <= Local_D.Data;
                        null;

                    when FETCH_PARAM_3 =>
                        Local_Q.Param(31 downto 24) <= Local_D.Data;
                        null;

                    when FETCH_PARAM_4 =>
                        Local_Q.Param(39 downto 32) <= Local_D.Data;
                        null;

                    when FETCH_SET_EXEC =>
                        -- do nothing here
                        null;

                    when FETCH_WAIT_READY =>
                        -- do nothing here
                        null;

                    when others =>
                        -- do nothing here
                        null;
                end case;
            end if;
        end if;
    end process StateTransitionLogic;

    -- Description: This process decodes current state and
    --              sets corresponding output signals
    OutputLogic: process(State)
    begin
        case State is
            when FETCH_RESET =>
                Local_Q.Execute <= false;
                Local_Q.Increment <= false;
                null;

            when FETCH_OP_CODE =>
                Local_Q.Execute <= false;
                Local_Q.Increment <= true;
                null;

            when FETCH_DECODE =>
                Local_Q.Execute <= false;
                Local_Q.Increment <= false;
                null;

            when FETCH_PARAM_0 =>
                Local_Q.Execute <= false;
                Local_Q.Increment <= true;
                null;

            when FETCH_PARAM_1 =>
                Local_Q.Execute <= false;
                Local_Q.Increment <= true;
                null;

            when FETCH_PARAM_2 =>
                Local_Q.Execute <= false;
                Local_Q.Increment <= true;
                null;

            when FETCH_PARAM_3 =>
                Local_Q.Execute <= false;
                Local_Q.Increment <= true;
                null;

            when FETCH_PARAM_4 =>
                Local_Q.Execute <= false;
                Local_Q.Increment <= true;
                null;

            when FETCH_SET_EXEC =>
                Local_Q.Execute <= true;
                Local_Q.Increment <= false;
                null;

            when FETCH_WAIT_READY =>
                Local_Q.Execute <= false;
                Local_Q.Increment <= false;
                null;

            when others =>
                Local_Q.Execute <= false;
                Local_Q.Increment <= false;
                null;
        end case;
    end process OutputLogic;

end architecture ArchFetchUnit;

