library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.CpuTypes.all;

entity Counter is

    port (
        clk_i: in std_logic;
        rst_i: in std_logic;
        D: in Counter_D;
        Q: out Counter_Q);

end entity Counter;

architecture ArchCounter of Counter is

    signal clk: std_logic;
    signal rst: std_logic;
    signal CounterReg: std_logic_vector(31 downto 0) := x"00000000";
    signal DecResult: std_logic_vector(31 downto 0);
    signal Local_D: Counter_D;
    signal Local_Q: Counter_Q;
    signal ReadyPulse: boolean;

begin

    clk <= clk_i;
    rst <= rst_i;
    Local_D <= D;
    Q <= Local_Q;

    -- Compute decrement result from current counter value
    DecResult <= CounterReg - 1;

    -- Description: This process performs all counter related
    --              operations like loading with new value and
    --              descrementing.
    CounterRegLogic: process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                -- Reset is active, reset counter register
                CounterReg <= (others => '0');
            elsif Local_D.Load = true then
                -- Load register with new value
                CounterReg <= Local_D.Value;
            elsif Local_D.Decrement = true then
                -- Load register with new decrement value
                CounterReg <= DecResult;
            else
                -- Do nothing
                CounterReg <= CounterReg;
            end if;
        end if;
    end process CounterRegLogic;

    -- Description: This process determines new value of zero flag
    --              to output.
    ZeroFlagLogic: process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                -- Reset is active
                Local_Q.IsZero <= true;
            elsif CounterReg = x"00000000" then
                -- Counter register is really zero
                -- set zero flag
                Local_Q.IsZero <= true;
            else
                -- Counter register is not zero
                Local_Q.IsZero <= false;
            end if;
        end if;
    end process ZeroFlagLogic;

    -- Description: This process generates ready pulse signal
    --              to output.
    ReadyFlagLogic: process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                -- Reset is active
                Local_Q.Ready <= false;
                ReadyPulse <= false;
            elsif Local_D.Load = true or Local_D.Decrement = true then
                -- Counter is performing loading or decrementing
                -- so it is not ready
                Local_Q.Ready <= false;
                ReadyPulse <= true;
            elsif ReadyPulse = true then
                -- Generate ready pulse
                Local_Q.Ready <= true;
                ReadyPulse <= false;
            else
                -- No activity, no action
                Local_Q.Ready <= false;
                ReadyPulse <= false;
            end if;
        end if;
    end process ReadyFlagLogic;

end architecture ArchCounter;

