
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
library work;
use work.constantList.all;

entity screenController is
  Port (clk : in STD_LOGIC;
        rst : in std_logic;
        collection: in particleList;
        writeEnable: out STD_logic; 
        writeAdress: out STD_LOGIC_VECTOR(ADDR_WIDTH-1 downto 0);
        writeData: out STD_LOGIC_VECTOR(3 downto 0));
        --collectionUpdated: in std_logic );  
  
end screenController;

architecture controller of screenController is

SIGNAL x: INTEGER range 0 to (H_PERIOD_cste - 1);
SIGNAL y: INTEGER range 0 to (V_PERIOD_cste - 1);
SIGNAL p: INTEGER range 0 to (numberOfParticles - 1);
SIGNAL particleExistshere: STD_LOGIC;

TYPE state is (start, checkP, evaluate, incXY);

SIGNAL pState: state;
SIGNAL particleX, particleY, particleM: INTEGER;

begin

writeEnable <= '1' when pState = incXY else '0';

writeAdress <= std_logic_vector(TO_UNSIGNED(x + y*H_PERIOD_cste, ADDR_WIDTH));

particleX <= TO_INTEGER(signed(collection(p)(xComponent)));
particleY <= TO_INTEGER(signed(collection(p)(yComponent)));
particleM <= TO_INTEGER(signed(collection(p)(massComponent)));


PROCESS
BEGIN
    WAIT UNTIL RISING_EDGE(clk);
    
    If (rst='1') then
    pState <= start;
    
    writedata <= "0000";
    
    else
        
        Case pState is
            When start =>
                x <= 0;
                y <= 0;
                p <= 0;
                particleExistsHere <= '0';
                pState <= checkP;
                
            When checkP =>
                IF ( (x > particleX - particleDisplayWidth) and
                 (x < particleX + particleDisplayWidth) and 
                (y > particleX - particleDisplayWidth) and 
                (y < particleX + particleDisplayWidth) and
                (particleM /= 0)) then
                particleExistsHere <= '1';
                --keeps current value otherwise
                
                END IF;
                
                if (p = numberOfParticles-1) then
                    p <= 0;
                    pState <= evaluate;
                else
                    p <= p + 1;
                    pState <= checkP;
                END if;
                
                
            When evaluate =>
                if particleExistsHere = '1' then
                    writeData <= "1111";
                else 
                    writeData <= "0000";
                end if;   
                
                particleExistsHere <= '0';
                pState <= incXY;
            
            
            When incXY =>
                if x = H_PERIOD_cste-1 then 
                    if y < V_PERIOD_cste-1 then
                        y <= y + 1;
                    else
                        y <= 0;
                    end if;
                end if;
                
                if x < H_PERIOD_cste-1 then
                    x <= x + 1;
                else
                    x <= 0;
                end if;
                
                pState <= checkP;
                
                
            end case;
    end if;
    
end process;                         
end controller;

