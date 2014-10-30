-------------------------------------------------------------------------------
-- Title      : Simple Counter for SPI test
-- Project    : 
-------------------------------------------------------------------------------
-- File       : simple_counter.vhd
-- Author     : aylons  <aylons@LNLS190>
-- Company    : 
-- Created    : 2014-10-23
-- Last update: 2014-10-30
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Simples counter possible
-------------------------------------------------------------------------------
-- Copyright (c) 2014 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2014-10-23  1.0      aylons  Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library UNISIM;
use UNISIM.vcomponents.all;



-------------------------------------------------------------------------------

entity simple_counter is

  generic (
    g_width : natural := 16
    );

  port (
    clk_i  : in std_logic;
    rst_i  : in std_logic;
    ce_i   : in std_logic;
    data_o : out std_logic_vector(g_width-1 downto 0)
    );

end entity simple_counter;

-------------------------------------------------------------------------------

architecture behavioural of simple_counter is

  signal cur_value : unsigned(g_width-1 downto 0);
  
begin  -- architecture str

  count : process(clk_i)
  begin
    if rising_edge(clk_i) then
      if rst_i = '1' then
        cur_value <= (others => '0');
      else
        if ce_i = '1' then
          cur_value <= cur_value+to_unsigned(1, g_width);
        end if;
      end if;
    end if;
  end process;

  data_o <= std_logic_vector(cur_value);


end architecture behavioural;

-------------------------------------------------------------------------------
