
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
library work;
use work.constantList.all;

entity VGA_timing_controller is
 Port (clk: in STD_LOGIC;
        rst_inp: in STD_LOGIC;
        hsync_outp: out STD_LOGIC;
        vsync_outp: out STD_LOGIC;
        video_active_outp: out STD_LOGIC;
        H_position: out std_logic_vector(h_size-1 downto 0);
        V_position: out std_logic_vector(v_size-1 downto 0)
         );
end VGA_timing_controller;

architecture Behavioral of VGA_timing_controller is

component reset_synchronizer is
    Port(
    clk: in std_logic;
    async_reset : in std_logic;
    sync_reset : out std_logic);
end component;
--component clk_wiz_1
--port
 --(-- Clock in ports
  -- Clock out ports
  --clk_out1          : out    std_logic;
  --clk_in1           : in     std_logic
-- );
--end component;
--signal clk1: std_logic;
signal reset: std_logic;
signal counter_pixel_sig: INTEGER range 0 to H_period_cste - 1 := 0;
signal counter_line_sig: INTEGER range 0 to V_period_cste - 1 := 0;
    
begin

H_position <= std_logic_vector(TO_UNSIGNED(counter_pixel_sig,H_size));
V_position <= std_logic_vector(TO_UNSIGNED(counter_line_sig,V_size));

reset_synchronizer_0: reset_synchronizer
port map ( async_reset => rst_inp,
            clk => clk,
            sync_reset => reset );
 
--clk_wiz: clk_wiz_1
--port map(clk_in1 => clk,
       -- clk_out1 => clk1); 
            
main_proc: process(clk)

begin

    if rising_edge(clk) then
        if reset = '1' then
            hsync_outp <= '1';
            vsync_outp <= '1';
            video_active_outp <= '1';
        else
            if (counter_pixel_sig = H_start_pulse_cste-1) then
                hsync_outp <= '0'; 
            elsif (counter_pixel_sig = H_end_pulse_cste-1) then
                hsync_outp <= '1';   
            end if;
            
            if (counter_pixel_sig = H_period_cste-1) and (counter_line_sig = V_start_pulse_cste-1) then
                vsync_outp <= '0';
            elsif (counter_pixel_sig = H_period_cste-1) and (counter_line_sig = V_end_pulse_cste-1) then
                vsync_outp <= '1';
                
            end if;

            --Active video
            if ((counter_line_sig < V_display_cste) and (counter_pixel_sig < h_display_cste)) then
                video_active_outp <= '1';
            --Blank periods
            else
                video_active_outp <= '0';
            end if;
       end if;
  end if;
end process;

counter_proc: process(clk)

begin

    if (rising_edge(clk)) then
        if reset = '1' then
            counter_pixel_sig <= 0;
            counter_line_sig <= 0;
            
        else
            if (counter_pixel_sig = h_period_cste-1) then
                counter_pixel_sig <= 0; 
                
                if (counter_line_sig = V_period_cste-1) then
                    counter_line_sig <= 0;
                
                else
                    counter_line_sig <= counter_line_sig + 1;
                
                end if;
                
             else
                 counter_pixel_sig <= counter_pixel_sig + 1;
             end if;
         end if;
     end if;
end process;           
end Behavioral;


