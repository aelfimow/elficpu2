library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.CpuTypes.all;

entity ProgramCounter is

    port (
        clk_i: in std_logic;
        rst_i: in std_logic;
        D: in ProgramCounter_D;
        Q: out ProgramCounter_Q);

end entity ProgramCounter;

architecture ArchProgramCounter of ProgramCounter is

    signal clk: std_logic;
    signal rst: std_logic;
    signal Local_D: ProgramCounter_D;
    signal Local_Q: ProgramCounter_Q;

    signal PC: std_logic_vector(15 downto 0);

begin

    clk <= clk_i;
    rst <= rst_i;
    Local_D <= D;
    Q <= Local_Q;

    Local_Q.Address <= PC;

    -- Description: This process performs PC register operations
    --              like loading, incrementing and resetting.
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                -- Reset is active, reset PC register
                PC <= (others => '0');
            elsif Local_D.Load = true then
                -- Load PC register with new value
                PC <= Local_D.Value;
            elsif Local_D.Increment = true then
                -- Count register
                PC <= PC + 1;
            else
                -- No action, do nothing
                PC <= PC;
            end if;
        end if;
    end process;

end architecture ArchProgramCounter;

