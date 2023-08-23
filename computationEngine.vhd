library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
library work;
use work.constantList.all;

entity computationEngine is
 Port (clk: in std_logic;
        rst: in std_logic;
        collection: out particleList);
        --collectionUpdated: out std_logic );
end computationEngine;

architecture Behavioral of computationEngine is

component accelerationCalculatorWithConversions

Port(clk: in std_logic;
    ce: in std_logic;
    resetn: in std_logic;
    xi: in std_logic_vector(componentWidth-1 downto 0);
    yi:in std_logic_vector(componentWidth-1 downto 0);
    zi:in std_logic_vector(componentWidth-1 downto 0);
    xj:in std_logic_vector(componentWidth-1 downto 0);
    yj:in std_logic_vector(componentWidth-1 downto 0);
    zj:in std_logic_vector(componentWidth-1 downto 0);
    mj:in std_logic_vector(componentWidth-1 downto 0);
    axij:out std_logic_vector(componentWidth-1 downto 0);
    ayij:out std_logic_vector(componentWidth-1 downto 0);
    azij:out std_logic_vector(componentWidth-1 downto 0));

end component;
component ROM
port (clka: in std_logic;
    ena:in std_logic;
    addra: in std_logic_vector(4 downto 0);
    douta: out std_logic_vector(127 downto 0);
    clkb:in std_logic;
    enb:in std_logic;
    addrb: in std_logic_vector(4 downto 0);
    doutb: out std_logic_vector(127 downto 0));
end component;

constant accCalcLatency: INTEGER := subLatency + multLatency + addLatency +
    invSqRootLatency  + fixedToFloatLatency + floatToFixedLatency;

signal positionWithMass: particlelist;
signal velocity, acceleration: particleVectorList;

type state is (start, initialize, visualDelay, find_ai, update_ai, update_v, update_pos, delay);

signal pState: state;
signal i,j: INTEGER range 0 to (numberOfParticles - 1);
signal ROMen: std_logic;
--ROM was made for 32 particles, hence 5 bits for addressing
signal ROMaddra, ROMaddrb : std_logic_vector(4 DOWNTO 0);
signal ROMdouta, ROMdoutb : Std_logic_vector(4*componentWidth-1 downto 0);

signal initEN: std_logic;
constant initmax: INTEGER:= (numberOfParticles/2 - 1);
signal xi,yi,zi,xj,yj,zj,mj,axij,ayij,azij: std_logic_vector(componentWidth-1 downto 0);
signal accCalcReset: std_logic;
signal accCalcEn: std_logic;
signal delayCount: INTEGER range 0 to visualDelayMax;
signal axi, ayi, azi: SIGNED(componentWidth-1 downto 0);
             
begin
collection <= positionWithMass;

initializationStorage_Inst: ROM 
port map(clka => clk,
    ena => ROMen,
    addra =>ROMaddra,
    douta => ROMdouta,
    clkb => clk,
    enb => ROMen,
    addrb => ROMaddrb,
    doutb => ROMdoutb);
 

accCalc_Inst: accelerationCalculatorWithConversions
port map ( clk => clk,
    ce=> accCalcEn,
    resetn=> accCalcReset,
    xi=>xi,
    yi=>yi,
    zi=>zi,
    xj=>xj,
    yj=>yj,
    zj=>zj,
    mj=>mj,
    axij=>axij,
    ayij=>ayij,
    azij=>azij);

ROMen <= '1' when pState = initialize else '0';
ROMaddra <= std_logic_vector(to_unsigned(i*2,5));
ROMaddrb <= std_logic_vector(to_unsigned(i*2 + 1,5));

xi <= positionWithMass(i)(xComponent) when pSTATE = find_ai
 else (others => '0');
yi <= positionWithMass(i)(yComponent) when pSTATE = find_ai
 else (others => '0');
zi <= positionWithMass(i)(zComponent) when pSTATE = find_ai
 else (others => '0');
xj <= positionWithMass(j)(xComponent) when pSTATE = find_ai
 else (others => '0');
yj <= positionWithMass(j)(yComponent) when pSTATE = find_ai
 else (others => '0');
zj <= positionWithMass(j)(zComponent) when pSTATE = find_ai
 else (others => '0'); 
mj <= positionWithMass(j)(massComponent) when pSTATE = find_ai
 else (others => '0');
 

accCalcEn <= '1' when pState = find_ai or pState = visualDelay or pState = delay else '0';
accCalcReset <= '1' when pState = start or pState = initialize else '0';

process 
begin 
    wait until rising_edge(clk);
    if rst = '1' then
        pState <= start;
    else
        case pState is 
        when start =>
        
        i <= 0;
        j <= 0;
        initEn <= '0';
        delayCount <= 0;
        velocity <= (others => (others => (others => '0')));
        
        axi <= (others => '0');
        ayi <= (others => '0');
        azi <= (others => '0');
        
        --collectionUpdated <= '0';  -- Reset the collectionUpdated signal
        
        pState <= initialize;
        
        when initialize =>
            --x(2j)
            if initEn = '1' then 
            positionWithMass (2*j)(xComponent) <= ROMdouta (4*componentWidth-1 downto 3*componentWidth);
            --y(2j)         
            positionWithMass (2*j)(yComponent) <= ROMdouta (3*componentWidth-1 downto 2*componentWidth);
            --z(2j)         
            positionWithMass (2*j)(zComponent) <= ROMdouta (2*componentWidth-1 downto componentWidth);
            --m(2j)          
            positionWithMass (2*j)(massComponent) <= ROMdouta (componentWidth-1 downto 0);
            
            --x(2j+1)          
            positionWithMass (2*j+1)(xComponent) <= ROMdoutb (4*componentWidth-1 downto 3*componentWidth);
            --y(2j+1)          
            positionWithMass (2*j+1)(yComponent) <= ROMdoutb (3*componentWidth-1 downto 2*componentWidth);
            --z(2j+1)         
            positionWithMass (2*j+1)(zComponent) <= ROMdoutb (2*componentWidth-1 downto componentWidth);
            --m(2j+1)            
            positionWithMass (2*j+1)(massComponent) <= ROMdoutb (componentWidth-1 downto 0);
            
            end if;
            
            -- after the first cycle, j is always one behind i
            -- this means j will write what i just read from
            -- initEn confirms that j won't write until 
            -- after first cycle   
                                
            if (j < initMax) then 
                i <= i + 1;
                j <= i;
                initEn <= '1';
                pState <= initialize;
            else
                i <= 0;
                j <= 0;
                initEn <= '0';
                pState <= visualDelay;
            
            end if;
                       
        when visualDelay => 
        
            if delayCount < VisualDelayMax then
                delayCount <= delayCount + 1;
                pState <= VisualDelay;
            else
                delayCount <= 0;
                pState <= find_ai;
            
            end if;
            
         --when find_ai =>
    -- Calculate acceleration components...
            --axi <= axi + SIGNED(axij);
            --ayi <= ayi + SIGNED(ayij);
            --azi <= azi + SIGNED(azij);
            -- Check if j is less than numberOfParticles - 1
           -- if j < numberOfParticles - 1 then
                -- If so, increment j and transition to delay_after_calculation state
               -- j <= j + 1;
              --  pState <= delay_after_calculation;
           -- else
                -- If not, reset j to 0 and transition to update_ai state
               -- j <= 0;
               -- pState <= update_ai;
           -- end if;   
            
        when find_ai =>
            
          if j < numberOfParticles - 1 then
              j <= j + 1;
              pState <= find_ai;
         else
              j <= 0;    
              pState <= delay;           
          end if;
            
         axi <= axi + SIGNED(axij);
         ayi <= ayi + SIGNED(ayij);
         azi <= azi + SIGNED(azij);
            
        
        when delay =>
            
            if delayCount < 120 then
               delayCount <= delayCount + 1;
                pState <= delay;
            else
                delayCount <= 0;
               pState <= update_ai;
            end if;
            
            axi <= axi + SIGNED(axij);
            ayi <= ayi + SIGNED(ayij);
            azi <= azi + SIGNED(azij); 
          -- when delay_after_calculation =>
               -- if delayCount < accCalcLatency + 100 then
                    --delayCount <= delayCount + 1;
                    --pState <= delay_after_calculation;
               -- else
                   -- delayCount <= 0;
                    -- Transition back to find_ai state (or to next state where you want to perform a calculation)
                    --pState <= find_ai;
                --end if;     
            
        when update_ai =>
            
            acceleration(i)(xComponent) <= axi;
            acceleration(i)(yComponent) <= ayi;
            acceleration(i)(zComponent) <= azi;
            
            axi <= (others => '0'); 
            ayi <= (others => '0');
            azi <= (others => '0');
            
            if i < numberOfParticles then
                i <= i + 1;
                pState <= find_ai;
            else
                i <= 0;
                pState <= update_v;
            end if;
            
            when update_v =>
                
                --for each particle in each dimension
                --velocity = velocity + acceleration
                for p in 0 to (numberOfParticles-1) loop
                    velocity(p)(xComponent) <= velocity(p)(xComponent) + acceleration(p)(xComponent);
                    velocity(p)(yComponent) <= velocity(p)(yComponent) + acceleration(p)(yComponent); 
                    velocity(p)(zComponent) <= velocity(p)(zComponent) + acceleration(p)(zComponent);        
                end loop;
                
                pState <= update_pos;
            
            when update_pos => 
                
                --for each particle in each dimension
                --position = position + velocity
                for p in 0 to (numberOfParticles-1) loop
                    positionWithMass(p)(xComponent) <= std_logic_vector(SIGNED(positionWithMass(p)(xComponent)) + velocity(p)(xComponent));
                    positionWithMass(p)(yComponent) <= std_logic_vector(SIGNED(positionWithMass(p)(yComponent)) + velocity(p)(yComponent)); 
                    positionWithMass(p)(zComponent) <= std_logic_vector(SIGNED(positionWithMass(p)(zComponent)) + velocity(p)(zComponent));
                    --collectionUpdated <= '1';  -- Set the collectionUpdated signal to indicate the collection list update  
                end loop;
               
                pState <= visualDelay;
                
             end case;
          end if;
      end process;                         
end Behavioral;











