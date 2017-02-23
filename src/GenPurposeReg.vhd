library ieee;
use ieee.std_logic_1164.all;
use work.CpuTypes.all;

entity GenPurposeReg is

    port (
        clk_i: in std_logic;
        rst_i: in std_logic;
        D: in GenPurposeReg_D;
        Q: out GenPurposeReg_Q);

end entity GenPurposeReg;

architecture ArchGenPurposeReg of GenPurposeReg is

    signal clk: std_logic;
    signal rst: std_logic;
    signal Local_D: GenPurposeReg_D;
    signal Local_Q: GenPurposeReg_Q;

    signal Reg: std_logic_vector(7 downto 0);

begin

    clk <= clk_i;
    rst <= rst_i;
    Local_D <= D;
    Q <= Local_Q;

    -- Set register directly to the output
    Local_Q.Data <= Reg;

    -- Description: This process performs operation on register
    --              like loading with new value or resetting.
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                -- Reset is active, reset register
                Reg <= (others => '0');
            elsif Local_D.Load = true then
                -- Load register with new value
                Reg <= Local_D.Value;
            else
                -- Do nothing
                Reg <= Reg;
            end if;
        end if;
    end process;

end architecture ArchGenPurposeReg;

