library ieee;
use ieee.std_logic_1164.all;
use work.CpuTypes.all;

entity PeripheryUnit is

    port (
        clk_i: in std_logic;
        rst_i: in std_logic;
        D: in PeripheryUnit_D;
        Q: out PeripheryUnit_Q);

end entity PeripheryUnit;

architecture ArchPeripheryUnit of PeripheryUnit is

    signal clk: std_logic;
    signal rst: std_logic;
    signal Local_D: PeripheryUnit_D;
    signal Local_Q: PeripheryUnit_Q;

    signal State: CpuTypesPeripheralState;
    signal NewState: CpuTypesPeripheralState;

    signal SelectedData: std_logic_vector(7 downto 0);
    signal DataToWrite: std_logic_vector(7 downto 0) := x"00";
    signal Address: std_logic_vector(15 downto 0) := x"0000";

begin

    clk <= clk_i;
    rst <= rst_i;
    Local_D <= D;
    Q <= Local_Q;

    Local_Q.Data <= DataToWrite;
    Local_Q.Address <= Address;

    -- Description: This process selects data from corresponding
    --              input depending on input setting.
    SelectDataLogic: process(Local_D)
    begin
        case Local_D.DataOrigin is
            when OriginRegisterA =>
                SelectedData <= Local_D.DataA;
                null;

            when OriginRegisterB =>
                SelectedData <= Local_D.DataB;
                null;

            when others =>
                SelectedData <= (others => '0');
                null;
        end case;
    end process SelectDataLogic;

    -- Description: This process samples address and data values
    --              and realizes internal registers for it.
    RegisterLogic: process(clk)
    begin
        if rising_edge(clk) then
            if Local_D.Write = false then
                Address <= Address;
                DataToWrite <= DataToWrite;
            else
                Address <= Local_D.Address;
                DataToWrite <= SelectedData;
            end if;
        end if;
    end process RegisterLogic;

    -- Description: This process realizes input logic for
    --              the local state machine.
    InputLogic: process(State, Local_D)
    begin
        case State is
            when PERIPHERY_RESET =>
                NewState <= PERIPHERY_WAIT;
                null;

            when PERIPHERY_WAIT =>
                if Local_D.Write = false then
                    NewState <= PERIPHERY_WAIT;
                else
                    NewState <= PERIPHERY_WRITE;
                end if;
                null;

            when PERIPHERY_WRITE =>
                NewState <= PERIPHERY_READY;
                null;

            when PERIPHERY_READY =>
                NewState <= PERIPHERY_WAIT;
                null;

            when others =>
                NewState <= PERIPHERY_RESET;
                null;
        end case;
    end process InputLogic;

    -- Description: This process handles state transitions of the
    --              local state machine.
    StateTransitionLogic: process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                State <= PERIPHERY_RESET;
            else
                State <= NewState;
            end if;
        end if;
    end process StateTransitionLogic;

    -- Description: This process realizes output logic of the
    --              local state machine.
    OutputLogic: process(State)
    begin
        case State is
            when PERIPHERY_RESET =>
                Local_Q.Write <= '0';
                Local_Q.Ready <= false;
                null;

            when PERIPHERY_WAIT =>
                Local_Q.Write <= '0';
                Local_Q.Ready <= false;
                null;

            when PERIPHERY_WRITE =>
                Local_Q.Write <= '1';
                Local_Q.Ready <= false;
                null;

            when PERIPHERY_READY =>
                Local_Q.Write <= '0';
                Local_Q.Ready <= true;
                null;

            when others =>
                Local_Q.Write <= '0';
                Local_Q.Ready <= false;
                null;
        end case;
    end process OutputLogic;

end architecture ArchPeripheryUnit;

