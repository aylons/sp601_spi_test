-------------------------------------------------------------------------------
-- Title      : Testbench for one SPI frequency
-- Project    : 
-------------------------------------------------------------------------------
-- File       : spi_single_test.vhd
-- Author     : aylons  <aylons@LNLS190>
-- Company    : 
-- Created    : 2014-11-01
-- Last update: 2014-11-03
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: This module tests one SPI channel
-------------------------------------------------------------------------------
-- Copyright (c) 2014 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2014-11-01  1.0      aylons  Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library UNISIM;
use UNISIM.vcomponents.all;

entity spi_single_test is
  generic(
    g_width : positive := 16
    );
  port(
    clk_i : in std_logic;
    rst_i   : in std_logic;

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

    chipscope_control : inout std_logic_vector(35 downto 0)
    );

end entity spi_single_test;

architecture structural of spi_single_test is

  constant c_cpol        : std_logic := '0';
  constant c_cpha        : std_logic := '0';
  constant c_prefetch    : positive  := 1;
  constant c_spi_clk_div : positive  := 1;

  -- service signals
  signal clock  : std_logic;
  signal enable : std_logic := '1';

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

  component chipscope_ila is
    port (
      CONTROL : inout std_logic_vector(35 downto 0);
      CLK     : in    std_logic;
      DATA    : in    std_logic_vector(63 downto 0);
      TRIG0   : in    std_logic_vector(7 downto 0));
  end component chipscope_ila;
  
begin

  cmp_master_controller : master_controller
    port map (
      clk_i      => clk_i,
      en_i       => enable,
      rst_i      => rst_i,
      spi_req_i  => master_req,
      spi_wen_o  => master_wren,
      count_up_o => count_up);


  cmp_count_gen : simple_counter
    generic map (
      g_width => g_width)
    port map (
      clk_i  => clk_i,
      rst_i  => rst_i,
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
      sclk_i     => clk_i,
      pclk_i     => clk_i,
      rst_i      => rst_i,
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
      clk_i      => clk_i,
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
      clk_i       => clk_i,
      rst_i       => rst_i,
      spi_valid_i => slave_valid,
      data_i      => slave_do,
      ok_o        => slave_ok,
      nok_o       => slave_nok);

  cmp_ok_counter : simple_counter
    generic map (
      g_width => g_width)
    port map (
      clk_i  => clk_i,
      rst_i  => rst_i,
      ce_i   => slave_ok,
      data_o => ok_count);

  cmp_nok_counter : simple_counter
    generic map (
      g_width => g_width)
    port map (
      clk_i  => clk_i,
      rst_i  => rst_i,
      ce_i   => slave_nok,
      data_o => nok_count);

  cmp_ila : chipscope_ila
    port map (
      CONTROL            => chipscope_control,
      CLK                => clk_i,
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

end architecture structural;
