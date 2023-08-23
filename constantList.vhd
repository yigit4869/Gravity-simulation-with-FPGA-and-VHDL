
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

PACKAGE constantList is
--Particle constants
constant numberOfParticles : INTEGER := 32;
constant xComponent : INTEGER :=0;
constant yComponent  : INTEGER :=1;
constant zComponent  : INTEGER :=2;
constant massComponent  : INTEGER :=3;

--Width of each particle on the screen
constant particleDisplayWidth : INTEGER :=3;

--640x480 basys3
    --Horizontal
constant H_DISPLAY_cste : INTEGER := 640; --Nb Active pixels per line
constant H_FP_cste : INTEGER := 16; --Nb clocks front proch
constant H_PULSE_cste : INTEGER := 96; --Nb clocks horizontal proch
constant H_BP_cste : INTEGER := 48; --Nb clocks back proch
constant H_SIZE : INTEGER := 10;    
    --Vertical
constant V_DISPLAY_cste : INTEGER := 480; --Nb Active line per frame
constant V_FP_cste : INTEGER := 10; --Nb lines front proch
constant V_PULSE_cste : INTEGER := 2; --Nb lines horizontal proch
constant V_BP_cste : INTEGER := 33; --Nb lines back proch
constant V_SIZE: INTEGER := 9;
--VGA computations
constant H_START_PULSE_cste : INTEGER := H_DISPLAY_cste + H_FP_cste;
constant H_END_PULSE_cste : INTEGER := H_START_PULSE_cste + H_PULSE_cste ; 
constant V_START_PULSE_cste : INTEGER := V_DISPLAY_cste + V_FP_cste ; 
constant V_END_PULSE_cste : INTEGER := V_START_PULSE_cste + V_PULSE_cste; 
constant H_PERIOD_cste : INTEGER := H_DISPLAY_cste + H_FP_cste + H_PULSE_cste + H_BP_cste ; --number of pixel clocks per time
constant V_PERIOD_cste : INTEGER := V_DISPLAY_cste + V_FP_cste + V_PULSE_cste + V_BP_cste ; --NUMBER OF LINES PER FRAME

--used in the screen storage RAM
constant ADDR_WIDTH : INTEGER := 19; -- "-1" for rounding errors

--width of the x,y,z,mass data
constant componentWidth: INTEGER := 32;

--These latencies are recorded to obtain correct number of delays
constant subLatency : INTEGER := 12;
constant multLatency : INTEGER := 9;
constant addLatency : INTEGER := 12;
constant invSqRootLatency : INTEGER := 33;
constant fixedToFloatLatency : INTEGER := 7;
constant floatToFixedLatency : INTEGER := 7;

--Visual delay of 1 second, the "1/1" can be modified to increase/decrease the visual delay
constant compEngineFreq : INTEGER := 100000000;
constant visualDelayMax : INTEGER := compEngineFreq / 1;

--Use for position/mass array
type particle IS array(0 to 3) OF STD_LOGIC_VECTOR(componentWidth-1 downto 0);
type particleList IS array(numberOfParticles -1 downto 0) OF particle;

--Used for velocity and acceleration arrays
type coordinate IS array(0 to 2) OF SIGNED(componentWidth-1 downto 0);
type particleVectorList IS array(numberOfParticles -1 downto 0) OF coordinate;

end constantList;








