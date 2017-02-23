library ieee;
use ieee.std_logic_1164.all;
use work.CpuTypes.all;

entity ExecutableROM is
    port (
        addr_i: in std_logic_vector(15 downto 0);
        data_o: out std_logic_vector(7 downto 0));
end entity ExecutableROM;

architecture Arch_ExecutableROM of ExecutableROM is
begin

ROM: process(addr_i)
begin
    case addr_i is
        when x"0000" =>
            data_o <= x"01";
            null;
        when x"0001" =>
            data_o <= x"AA";
            null;
        when x"0002" =>
            data_o <= x"02";
            null;
        when x"0003" =>
            data_o <= x"BB";
            null;
        when x"0004" =>
            data_o <= x"05";
            null;
        when x"0005" =>
            data_o <= x"03";
            null;
        when x"0006" =>
            data_o <= x"00";
            null;
        when x"0007" =>
            data_o <= x"00";
            null;
        when x"0008" =>
            data_o <= x"00";
            null;
        when x"0009" =>
            data_o <= x"06";
            null;
        when x"000A" =>
            data_o <= x"07";
            null;
        when x"000B" =>
            data_o <= x"09";
            null;
        when x"000C" =>
            data_o <= x"00";
            null;
        when x"000D" =>
            data_o <= x"03";
            null;
        when x"000E" =>
            data_o <= x"CD";
            null;
        when x"000F" =>
            data_o <= x"AB";
            null;
        when x"0010" =>
            data_o <= x"04";
            null;
        when x"0011" =>
            data_o <= x"CD";
            null;
        when x"0012" =>
            data_o <= x"AB";
            null;
        when x"0013" =>
            data_o <= x"FF";
            null;
        when others =>
            data_o <= x"FF";
            null;
    end case;
end process ROM;

end architecture Arch_ExecutableROM;
