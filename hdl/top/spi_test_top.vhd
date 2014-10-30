-------------------------------------------------------------------------------
-- Title      : Top module for SPI test
-- Project    : 
-------------------------------------------------------------------------------
-- File       : spi_test_top.vhd
-- Author     : aylons  <aylons@LNLS190>
-- Company    : 
-- Created    : 2014-10-23
-- Last update: 2014-10-30
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Top module for SPI test. Outputs may be connected directly to pins
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

entity spi_test_top is
  generic(
    g_width : positive := 16
    );
  port(
    sys_clk_p_i : in  std_logic;
    sys_clk_n_i : in  std_logic;
    on_sw_i     : in  std_logic;
    on_led_o    : out std_logic;
    rst_i       : in  std_logic;

    --master
    spi_sck_o  : out std_logic;
    spi_mosi_o : out std_logic;
    spi_miso_i : in  std_logic;
    spi_ssel_o : out std_logic;

    --slave
    spi_sck_i  : in  std_logic;
    spi_mosi_i : in  std_logic;
    spi_miso_o : out std_logic;
    spi_ssel_i : in  std_logic;

    -- output
    nok_o : out std_logic_vector(g_width-1 downto 0);
    ok_o  : out std_logic_vector(g_width-1 downto 0)
    );

end entity spi_test_top;

architecture structural of spi_test_top is

  constant c_cpol        : std_logic := '0';
  constant c_cpha        : std_logic := '0';
  constant c_prefetch    : positive  := 1;
  constant c_spi_clk_div : positive  := 3;

  -- service signals
  signal clock    : std_logic;
  signal locked   : std_logic;
  signal locked_n : std_logic;

  -- master signals
  signal master_req, master_wren : std_logic;
  signal master_di               : std_logic_vector(g_width-1 downto 0);
  signal count_up                : std_logic;

  --slave signals
  signal slave_valid         : std_logic;
  signal slave_do            : std_logic_vector(g_width-1 downto 0);
  signal slave_ok, slave_nok : std_logic;

-- output signals
  signal ok_count, nok_count : std_logic_vector(g_width-1 downto 0);

-- debugging
  signal CONTROL : std_logic_vector(35 downto 0);

  component spi_master is
    generic (
      N              : positive;        -- width
      CPOL           : std_logic;
      CPHA           : std_logic;
      PREFETCH       : positive;
      SPI_2X_CLK_DIV : positive);
    port (
      sclk_i     : in  std_logic                       := 'X';
      pclk_i     : in  std_logic                       := 'X';
      rst_i      : in  std_logic                       := 'X';
      spi_ssel_o : out std_logic;
      spi_sck_o  : out std_logic;
      spi_mosi_o : out std_logic;
      spi_miso_i : in  std_logic                       := 'X';
      di_req_o   : out std_logic;
      di_i       : in  std_logic_vector (N-1 downto 0) := (others => 'X');
      wren_i     : in  std_logic                       := 'X';
      wr_ack_o   : out std_logic;
      do_valid_o : out std_logic;
      do_o       : out std_logic_vector (N-1 downto 0));
  end component spi_master;

  component spi_slave is
    generic (
      N        : positive;
      CPOL     : std_logic;
      CPHA     : std_logic;
      PREFETCH : positive);
    port (
      clk_i      : in  std_logic                       := 'X';
      spi_ssel_i : in  std_logic                       := 'X';
      spi_sck_i  : in  std_logic                       := 'X';
      spi_mosi_i : in  std_logic                       := 'X';
      spi_miso_o : out std_logic                       := 'X';
      di_req_o   : out std_logic;
      di_i       : in  std_logic_vector (N-1 downto 0) := (others => 'X');
      wren_i     : in  std_logic                       := 'X';
      wr_ack_o   : out std_logic;
      do_valid_o : out std_logic;
      do_o       : out std_logic_vector (N-1 downto 0));
  end component spi_slave;

  component simple_counter is
    generic (
      g_width : natural);
    port (
      clk_i  : in  std_logic;
      rst_i  : in  std_logic;
      ce_i   : in  std_logic;
      data_o : out std_logic_vector(g_width-1 downto 0));
  end component simple_counter;

  component slave_checker is
    generic (
      g_width : natural);
    port (
      clk_i       : in  std_logic;
      rst_i       : in  std_logic;
      spi_valid_i : in  std_logic;
      data_i      : in  std_logic_vector(g_width-1 downto 0);
      ok_o        : out std_logic;
      nok_o       : out std_logic);
  end component slave_checker;


  component master_controller is
    port (
      clk_i      : in  std_logic;
      rst_i      : in  std_logic;
      en_i       : in  std_logic;
      spi_req_i  : in  std_logic;
      spi_wen_o  : out std_logic;
      count_up_o : out std_logic);
  end component master_controller;

  component clk_wiz_v3_3 is
    port (
      CLK_IN1_P : in  std_logic;
      CLK_IN1_N : in  std_logic;
      CLK_OUT1  : out std_logic;
      RESET     : in  std_logic;
      LOCKED    : out std_logic);
  end component clk_wiz_v3_3;

  component chipscope_icon is
    port (
      CONTROL0 : inout std_logic_vector(35 downto 0));
  end component chipscope_icon;

  component chipscope_ila is
    port (
      CONTROL : inout std_logic_vector(35 downto 0);
      CLK     : in    std_logic;
      DATA    : in    std_logic_vector(63 downto 0);
      TRIG0   : in    std_logic_vector(7 downto 0));
  end component chipscope_ila;
  
begin

  on_led_o <= on_sw_i;

  clk_wiz_v3_3_1 : clk_wiz_v3_3
    port map (
      CLK_IN1_P => sys_clk_p_i,
      CLK_IN1_N => sys_clk_n_i,
      CLK_OUT1  => clock,
      RESET     => rst_i,
      LOCKED    => locked);

  locked_n <= not(locked);

  cmp_master_controller : master_controller
    port map (
      clk_i      => clock,
      en_i       => on_sw_i,
      rst_i      => locked_n,
      spi_req_i  => master_req,
      spi_wen_o  => master_wren,
      count_up_o => count_up);


  cmp_count_gen : simple_counter
    generic map (
      g_width => g_width)
    port map (
      clk_i  => clock,
      rst_i  => locked_n,
      ce_i   => count_up,
      data_o => master_di);

  cmp_master : spi_master
    generic map (
      N              => g_width,
      CPOL           => c_cpol,
      CPHA           => c_cpha,
      PREFETCH       => c_prefetch,
      SPI_2X_CLK_DIV => c_spi_clk_div)
    port map (
      sclk_i     => clock,
      pclk_i     => clock,
      rst_i      => locked_n,
      spi_ssel_o => spi_ssel_o,
      spi_sck_o  => spi_sck_o,
      spi_mosi_o => spi_mosi_o,
      spi_miso_i => spi_miso_i,
      di_req_o   => master_req,
      di_i       => master_di,
      wren_i     => master_wren,
      wr_ack_o   => open,
      do_valid_o => open,
      do_o       => open);


-----------------------------------------------------------------------------
  -- slave section

  cmp_spi_slave : spi_slave
    generic map (
      N        => g_width,
      CPOL     => c_cpol,
      CPHA     => c_cpha,
      PREFETCH => c_prefetch)
    port map (
      clk_i      => clock,
      spi_ssel_i => spi_ssel_i,
      spi_sck_i  => spi_sck_i,
      spi_mosi_i => spi_mosi_i,
      spi_miso_o => spi_miso_o,
      di_req_o   => open,
      di_i       => (others => '0'),
      wren_i     => '0',
      wr_ack_o   => open,
      do_valid_o => slave_valid,
      do_o       => slave_do);

  cmp_slave_checker : slave_checker
    generic map (
      g_width => g_width)
    port map (
      clk_i       => clock,
      rst_i       => locked_n,
      spi_valid_i => slave_valid,
      data_i      => slave_do,
      ok_o        => slave_ok,
      nok_o       => slave_nok);

  cmp_ok_counter : simple_counter
    generic map (
      g_width => g_width)
    port map (
      clk_i  => clock,
      rst_i  => locked_n,
      ce_i   => slave_ok,
      data_o => ok_count);

  cmp_nok_counter : simple_counter
    generic map (
      g_width => g_width)
    port map (
      clk_i  => clock,
      rst_i  => locked_n,
      ce_i   => slave_nok,
      data_o => nok_count);

  cmp_chipscope_icon : chipscope_icon
    port map (
      CONTROL0 => CONTROL);

  chipscope_ila_1 : chipscope_ila
    port map (
      CONTROL            => CONTROL,
      CLK                => clock,
      DATA(63 downto 48) => master_di(15 downto 0),
      DATA(47 downto 32) => ok_count(15 downto 0),
      DATA(31 downto 16) => nok_count(15 downto 0),
      DATA(15)           => slave_valid,
      DATA(14)           => slave_ok,
      DATA(13)           => slave_nok,
      DATA(12 downto 0)  => slave_do(12 downto 0),
      TRIG0(7)           => slave_valid,
      TRIG0(6 downto 2)  => (others => '0'),
      TRIG0(1)           => slave_ok,
      TRIG0(0)           => master_req);

  ok_o  <= ok_count;
  nok_o <= nok_count;

end architecture structural;
