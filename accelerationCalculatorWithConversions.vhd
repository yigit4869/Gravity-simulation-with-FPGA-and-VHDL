library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

entity accelerationCalculatorWithConversions is
  Port (
    clk: in std_logic;
    ce: in std_logic;
    resetn: in std_logic;
    xi: in std_logic_vector(31 downto 0);
    yi: in std_logic_vector(31 downto 0);
    zi: in std_logic_vector(31 downto 0);
    xj: in std_logic_vector(31 downto 0);
    yj: in std_logic_vector(31 downto 0);
    zj: in std_logic_vector(31 downto 0);
    mj: in std_logic_vector(31 downto 0);
    axij: out std_logic_vector(31 downto 0);
    ayij: out std_logic_vector(31 downto 0);
    azij: out std_logic_vector(31 downto 0)
  );
end accelerationCalculatorWithConversions;

architecture Behavioral of accelerationCalculatorWithConversions is
  component delay1_mj
  port (
        clk: in std_logic;
        en : in std_logic;
        reset: in std_logic;
        input: in std_logic_vector(31 downto 0);
        output: out std_logic_vector(31 downto 0)
    );
end component;

component delay2_dd is
    port (
        clk: in std_logic;
        en : in std_logic;
        reset: in std_logic;
        input: in std_logic_vector(31 downto 0);
        output: out std_logic_vector(31 downto 0)
    );
end component;

component delay3_mr is
    port (
        clk: in std_logic;
        en : in std_logic;
        reset: in std_logic;
        input: in std_logic_vector(31 downto 0);
        output: out std_logic_vector(31 downto 0)
    );
end component;

 
  
  
  
  COMPONENT fixedToFloat
  PORT (
    aclk : IN STD_LOGIC;
    aclken : IN STD_LOGIC;
    aresetn : IN STD_LOGIC;
    s_axis_a_tvalid : IN STD_LOGIC;
    s_axis_a_tready : OUT STD_LOGIC;
    s_axis_a_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    m_axis_result_tvalid : OUT STD_LOGIC;
    m_axis_result_tready : IN STD_LOGIC;
    m_axis_result_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  );
END COMPONENT;

COMPONENT floatToFixed
  PORT (
    aclk : IN STD_LOGIC;
    aclken : IN STD_LOGIC;
    aresetn : IN STD_LOGIC;
    s_axis_a_tvalid : IN STD_LOGIC;
    s_axis_a_tready : OUT STD_LOGIC;
    s_axis_a_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    m_axis_result_tvalid : OUT STD_LOGIC;
    m_axis_result_tready : IN STD_LOGIC;
    m_axis_result_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  );
END COMPONENT;

  component subtractor is
    Port(
    
    aclk : IN STD_LOGIC;
    aclken : IN STD_LOGIC;
    aresetn : IN STD_LOGIC;
    s_axis_a_tvalid : IN STD_LOGIC;
    s_axis_a_tready : OUT STD_LOGIC;
    s_axis_a_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    s_axis_b_tvalid : IN STD_LOGIC;
    s_axis_b_tready : OUT STD_LOGIC;
    s_axis_b_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    m_axis_result_tvalid : OUT STD_LOGIC;
    m_axis_result_tready : IN STD_LOGIC;
    m_axis_result_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  
                );
  end component subtractor;
  
  COMPONENT multiplier
  PORT (
    aclk : IN STD_LOGIC;
    aclken : IN STD_LOGIC;
    aresetn : IN STD_LOGIC;
    s_axis_a_tvalid : IN STD_LOGIC;
    s_axis_a_tready : OUT STD_LOGIC;
    s_axis_a_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    s_axis_b_tvalid : IN STD_LOGIC;
    s_axis_b_tready : OUT STD_LOGIC;
    s_axis_b_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    m_axis_result_tvalid : OUT STD_LOGIC;
    m_axis_result_tready : IN STD_LOGIC;
    m_axis_result_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  );
END COMPONENT;

COMPONENT adder
  PORT (
    aclk : IN STD_LOGIC;
    aclken : IN STD_LOGIC;
    aresetn : IN STD_LOGIC;
    s_axis_a_tvalid : IN STD_LOGIC;
    s_axis_a_tready : OUT STD_LOGIC;
    s_axis_a_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    s_axis_b_tvalid : IN STD_LOGIC;
    s_axis_b_tready : OUT STD_LOGIC;
    s_axis_b_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    m_axis_result_tvalid : OUT STD_LOGIC;
    m_axis_result_tready : IN STD_LOGIC;
    m_axis_result_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  );
  
END component;

 COMPONENT invSqroot
  PORT (
    aclk : IN STD_LOGIC;
    aclken : IN STD_LOGIC;
    aresetn : IN STD_LOGIC;
    s_axis_a_tvalid : IN STD_LOGIC;
    s_axis_a_tready : OUT STD_LOGIC;
    s_axis_a_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    m_axis_result_tvalid : OUT STD_LOGIC;
    m_axis_result_tready : IN STD_LOGIC;
    m_axis_result_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  );
END COMPONENT;
 signal xint, yint, zint: integer range -10000 to 10000;  
 signal axij_conv, ayij_conv, azij_conv: std_logic_vector(31 downto 0);
 signal xi_conv, yi_conv, zi_conv, xj_conv, yj_conv, zj_conv, mj_conv: std_logic_vector(31 downto 0);
 signal rx_i,ry_i,rz_i,rx_sq, ry_sq, rz_sq, dd_xy, dd_ze, dd, ddsq, mrx, mry, mrz, dd3, d: std_logic_vector(31 downto 0);
 signal EPS: std_logic_vector (31 downto 0) := x"2D1BC3B8";
 signal resetn_inv : std_logic;
 signal mj_delayed, mrx_delayed, mry_delayed, mrz_delayed, d_delayed: std_logic_Vector(31 downto 0);
  
begin
resetn_inv <= not resetn;
azij <= "00000000000000000000000000000000";
--xint <= TO_INTEGER(SIGNED(axij));
--yint <= TO_INTEGER(SIGNED(ayij));
--zint <= TO_INTEGER(SIGNED(azij));
    fixed_converter_xi: fixedToFloat
    PORT MAP (
    aclk => clk,
    aclken => ce,
    aresetn => resetn_inv,
    s_axis_a_tvalid => '1',
    s_axis_a_tdata => xi ,
    m_axis_result_tready => '1',
    m_axis_result_tdata => xi_conv
  );
   fixed_converter_yi: fixedToFloat
    PORT MAP (
    aclk => clk,
    aclken => ce,
    aresetn => resetn_inv,
    s_axis_a_tvalid => '1',
    s_axis_a_tdata => yi ,
    m_axis_result_tready => '1',
    m_axis_result_tdata => yi_conv
  );
   fixed_converter_zi: fixedToFloat
    PORT MAP (
    aclk => clk,
    aclken => ce,
    aresetn => resetn_inv,
    s_axis_a_tvalid => '1',
    s_axis_a_tdata => zi ,
    m_axis_result_tready => '1',
    m_axis_result_tdata => zi_conv
  );
   fixed_converter_xj: fixedToFloat
    PORT MAP (
    aclk => clk,
    aclken => ce,
    aresetn => resetn_inv,
    s_axis_a_tvalid => '1',
    s_axis_a_tdata => xj ,
    m_axis_result_tready => '1',
    m_axis_result_tdata => xj_conv
  );
   fixed_converter_yj: fixedToFloat
    PORT MAP (
    aclk => clk,
    aclken => ce,
    aresetn => resetn_inv,
    s_axis_a_tvalid => '1',
    s_axis_a_tdata => yj ,
    m_axis_result_tready => '1',
    m_axis_result_tdata => yj_conv
  );
   
   -- fixed_converter_zj: fixedToFloat
    -- PORT MAP (
    -- aclk => clk,
    -- aclken => ce,
    -- aresetn => resetn_inv,
    -- s_axis_a_tvalid => '1',
    -- s_axis_a_tdata => zj ,
    -- m_axis_result_tready => '1',
    -- m_axis_result_tdata => zj_conv  
  -- ); 
  
  fixed_converter_mj: fixedToFloat
    PORT MAP (
    aclk => clk,
    aclken => ce,
    aresetn => resetn_inv,
    s_axis_a_tvalid => '1',
    s_axis_a_tdata => mj ,
    m_axis_result_tready => '1',
    m_axis_result_tdata => mj_conv
  );
    
  get_rx: subtractor
    port map(  aclk => clk,
      aclken => ce,
      aresetn => resetn_inv,
      s_axis_a_tvalid => '1',
      m_axis_result_tready => '1',
      s_axis_b_tvalid => '1',
     
      s_axis_a_tdata => xj_conv,
      s_axis_b_tdata => xi_conv,
      m_axis_Result_tdata => rx_i
                );

  get_ry: subtractor
    port map(  aclk => clk,
      aclken => ce,
      aresetn => resetn_inv,
      s_axis_a_tvalid => '1',
      m_axis_result_tready => '1',
      s_axis_b_tvalid => '1',
     
      s_axis_a_tdata => yj_conv,
      s_axis_b_tdata => yi_conv,
      m_axis_Result_tdata => ry_i
                );

 --  get_rz: subtractor
    -- port map(  aclk => clk,
     --  aclken => ce,
     --  aresetn => resetn_inv,
     --  s_axis_a_tvalid => '1',
     --  m_axis_result_tready => '1',
     -- s_axis_b_tvalid => '1',
     -- 
    --   s_axis_a_tdata => zj_conv,
     --  s_axis_b_tdata => zi_conv,
     --  m_axis_Result_tdata => rz_i
              --  );

    get_rxsq: multiplier
    PORT MAP (
    aclk => clk,
      aclken => ce,
      aresetn => resetn_inv,
      s_axis_a_tvalid => '1',
      m_axis_result_tready => '1',
      s_axis_b_tvalid => '1',
     
      s_axis_a_tdata => rx_i,
      s_axis_b_tdata => rx_i,
      m_axis_Result_tdata => rx_sq
                );
    
    get_rysq: multiplier
    PORT MAP (
    aclk => clk,
      aclken => ce,
      aresetn => resetn_inv,
      s_axis_a_tvalid => '1',
      m_axis_result_tready => '1',
      s_axis_b_tvalid => '1',
     
      s_axis_a_tdata => ry_i,
      s_axis_b_tdata => ry_i,
      m_axis_Result_tdata => ry_sq
                );

--  get_rzsq: multiplier
   --  PORT MAP (
   --  aclk => clk,
   --    aclken => ce,
    --   aresetn => resetn_inv,
    --   s_axis_a_tvalid => '1',
    --  --  m_axis_result_tready => '1',
     --  s_axis_b_tvalid => '1',
     
     --  s_axis_a_tdata => rz_i,
     --  s_axis_b_tdata => rz_i,
     --  m_axis_Result_tdata => rz_sq
           --      );
  
get_ddxy: adder
  
  PORT MAP (
    aclk => clk,
      aclken => ce,
      aresetn => resetn_inv,
      s_axis_a_tvalid => '1',
      m_axis_result_tready => '1',
      s_axis_b_tvalid => '1',
     
      s_axis_a_tdata => rx_sq,
      s_axis_b_tdata => ry_sq,
      m_axis_Result_tdata => dd_xy
                );
                
   -- get_ddze: adder
  
  -- PORT MAP (
   --  aclk => clk,
     --  aclken => ce,
    --   aresetn => resetn_inv,
    --   s_axis_a_tvalid => '1',
     --  m_axis_result_tready => '1',
    --   s_axis_b_tvalid => '1',
     
     --  s_axis_a_tdata => rz_sq,
     --  s_axis_b_tdata => EPS,
     --  m_axis_Result_tdata => dd_ze
               --  );               
  
  get_dd: adder
  
  PORT MAP (
    aclk => clk,
      aclken => ce,
      aresetn => resetn_inv,
      s_axis_a_tvalid => '1',
      m_axis_result_tready => '1',
      s_axis_b_tvalid => '1',
     
      s_axis_a_tdata => dd_xy,
      s_axis_b_tdata => EPS,
      m_axis_Result_tdata => dd
                );
    
    get_ddsq: multiplier
    PORT MAP (
    aclk => clk,
      aclken => ce,
      aresetn => resetn_inv,
      s_axis_a_tvalid => '1',
      m_axis_result_tready => '1',
      s_axis_b_tvalid => '1',
     
      s_axis_a_tdata => dd,
      s_axis_b_tdata => dd,
      m_axis_Result_tdata => ddsq
                );
     
     
     delayed_mj: delay1_mj
     port map( 
        clk => clk,
        en => ce,
        reset => resetn_inv,
        input => mj_conv,
        output => mj_delayed
    );
    
    delayed_d : delay2_dd
    port map( 
        clk => clk,
        en => ce,
        reset => resetn_inv,
        input => dd,
        output => d_delayed
    );
    
    delayed_mrx : delay3_mr
    port map( 
        clk => clk,
        en => ce,
        reset => resetn_inv,
        input => mrx,
        output => mrx_delayed
    );
    delayed_mry : delay3_mr
    port map( 
        clk => clk,
        en => ce,
        reset => resetn_inv,
        input => mry,
        output => mry_delayed
    );
  --  delayed_mrz : delay3_mr
   -- port map( 
   --     clk => clk,
   --     en => ce,
   --     reset => resetn_inv,
   --     input => mrz,
   --     output => mrz_delayed
  --  );
     
     
    get_mrx: multiplier
    PORT MAP (
    aclk => clk,
      aclken => ce,
      aresetn => resetn_inv,
      s_axis_a_tvalid => '1',
      m_axis_result_tready => '1',
      s_axis_b_tvalid => '1',
     
      s_axis_a_tdata => mj_delayed,
      s_axis_b_tdata => rx_i,
      m_axis_Result_tdata => mrx
                );
                
    get_mry: multiplier
    PORT MAP (
    aclk => clk,
      aclken => ce,
      aresetn => resetn_inv,
      s_axis_a_tvalid => '1',
      m_axis_result_tready => '1',
      s_axis_b_tvalid => '1',
     
      s_axis_a_tdata => mj_delayed,
      s_axis_b_tdata => ry_i,
      m_axis_Result_tdata => mry
                );           
                
    --get_mrz: multiplier
    --PORT MAP (
    --aclk => clk,
    --  aclken => ce,
    --  aresetn => resetn_inv,
    --  s_axis_a_tvalid => '1',
    --  m_axis_result_tready => '1',
    --  s_axis_b_tvalid => '1',
     
     -- s_axis_a_tdata => mj_delayed,
     -- s_axis_b_tdata => rz_i,
     -- m_axis_Result_tdata => mrz
      --          );      
    
    get_dd3: multiplier
    PORT MAP (
    aclk => clk,
      aclken => ce,
      aresetn => resetn_inv,
      s_axis_a_tvalid => '1',
      m_axis_result_tready => '1',
      s_axis_b_tvalid => '1',
     
      s_axis_a_tdata => ddsq,
      s_axis_b_tdata => d_delayed,
      m_axis_Result_tdata => dd3
                );
                
  get_d : invSqroot
  PORT MAP (
    aclk => clk,
    aclken => ce,
    aresetn => resetn_inv,
    s_axis_a_tvalid => '1',
    s_axis_a_tdata => dd3,
    m_axis_result_tready => '1',
    m_axis_result_tdata => d
  );
  
   get_axij: multiplier
    PORT MAP (
    aclk => clk,
      aclken => ce,
      aresetn => resetn_inv,
      s_axis_a_tvalid => '1',
      m_axis_result_tready => '1',
      s_axis_b_tvalid => '1',
     
      s_axis_a_tdata => mrx_Delayed,
      s_axis_b_tdata => d,
      m_axis_Result_tdata => axij_conv
                );
     
     get_ayij: multiplier
    PORT MAP (
    aclk => clk,
      aclken => ce,
      aresetn => resetn_inv,
      s_axis_a_tvalid => '1',
      m_axis_result_tready => '1',
      s_axis_b_tvalid => '1',
     
      s_axis_a_tdata => mry_delayed,
      s_axis_b_tdata => d,
      m_axis_Result_tdata => ayij_conv
                );
                
   -- get_azij: multiplier
   -- PORT MAP (
   -- aclk => clk,
   --   aclken => ce,
   --   aresetn => resetn_inv,
   --   s_axis_a_tvalid => '1',
   --   m_axis_result_tready => '1',
   --   s_axis_b_tvalid => '1',
     
   --   s_axis_a_tdata => mrz_delayed,
   --   s_axis_b_tdata => d,
   --   m_axis_Result_tdata => azij_conv
     --           );
    float_converter_axij: floatToFixed
    PORT MAP (
    aclk => clk,
    aclken => ce,
    aresetn => resetn_inv,
    s_axis_a_tvalid => '1',
    s_axis_a_tdata => axij_conv ,
    m_axis_result_tready => '1',
    m_axis_result_tdata => axij
  );
   float_converter_ayij: floatToFixed
    PORT MAP (
    aclk => clk,
    aclken => ce,
    aresetn => resetn_inv,
    s_axis_a_tvalid => '1',
    s_axis_a_tdata => ayij_conv ,
    m_axis_result_tready => '1',
    m_axis_result_tdata => ayij
  );
  -- float_converter_azij: floatToFixed
  --  PORT MAP (
 --   aclk => clk,
 --   aclken => ce,
 --   aresetn => resetn_inv,
 --   s_axis_a_tvalid => '1',
  --  s_axis_a_tdata => azij_conv,
  --  m_axis_result_tready => '1',
  --  m_axis_result_tdata => azij
 -- );
end Behavioral;














