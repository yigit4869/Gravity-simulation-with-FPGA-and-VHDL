library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
library work;
use work.constantList.all;

entity screenOutput is
 Port (clk : in std_logic;
reset : in std_logic;
readData : in std_logic_vector(3 downto 0);
readAddr : out std_logic_vector(ADDR_width -1 downto 0);
readEnable : out std_logic;
vSync : out std_logic;
hSync : out std_logic;
red : out std_logic_vector(3 downto 0);
green : out std_logic_vector(3 downto 0);
blue : out std_logic_vector(3 downto 0)
  );
end screenOutput;

architecture Behavioral of screenOutput is

component VGA_timing_controller
     port(
        clk: in STD_LOGIC;
        rst_inp: in STD_LOGIC;
        hsync_outp: out STD_LOGIC;
        vsync_outp: out STD_LOGIC;
        video_active_outp: out STD_LOGIC;
        H_position: out std_logic_vector(h_size-1 downto 0);
        V_position: out std_logic_vector(v_size-1 downto 0)
         );
end component;

signal vide_active: std_logic;
signal xVector: std_logic_vector(h_size-1 downto 0);
signal yVector: std_logic_vector(v_size-1 downto 0);
signal xInt: INTEGER range 0 to (h_period_cste-1);
signal yInt: INTEGER range 0 to (v_period_cste-1);

begin

VGA_timing_controller_0: VGA_timing_controller
port map (
        clk => clk,
        rst_inp => reset,
        hsync_outp => hSync,
        vsync_outp => vSync,
        video_active_outp => vide_active,
        H_position => xVector,
        V_position => yVector);

xInt <= TO_INTEGER(unsigned(xVector));
yInt <= TO_INTEGER(unsigned(yVector));

process(xINT, yINT)
begin

if ((xInt = h_period_cste-1) and (yInt = v_period_cste-1)) then
    readAddr <= (others => '0');
    
else
    readAddr <= std_logic_vector(TO_UNSIGNED(xInt + yInt*H_period_cste + 1,Addr_Width));
end if;

end process;   

readEnable <= '1';

red <= readData when vide_active = '1' else "0000";
green <= readData when vide_active = '1' else "0000";
blue <= readData when vide_active = '1' else "0000";

end Behavioral;
