library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library UNISIM;
use UNISIM.VComponents.all;

entity reset_dcm is
  generic(cycles : positive := 100);
  port (clk      : in  std_logic;
        locked_i : in  std_logic;
        reset_o  : out std_logic
        );                              --reset ='1' enable ,i.e. reset dcm

end reset_dcm;

architecture Behavioral of reset_dcm is
begin
  
  process(clk)
    variable count : positive := cycles;
  begin
    if rising_edge(clk) then
      
      if locked_i = '1' then
        count := count - 1;
      else
        count   := cycles;
        reset_o <= '1';
      end if;
      
      if count = 0 then
        reset_o <= '0';
      end if;
      
    end if;
  end process;

end Behavioral;
