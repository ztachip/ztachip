-- Generator : SpinalHDL v1.9.3    git head : 029104c77a54c53f1edda327a3bea333f7d65fd9
-- Component : VexRiscvForSim
-- Git hash  : 5ef1bc775fdbe942875dd7906f22aa98e6cffaaf

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;

package pkg_enum is
  type BranchCtrlEnum is (INC,B,JAL,JALR);
  type ShiftCtrlEnum is (DISABLE_1,SLL_1,SRL_1,SRA_1);
  type AluBitwiseCtrlEnum is (XOR_1,OR_1,AND_1);
  type EnvCtrlEnum is (NONE,XRET);
  type Src2CtrlEnum is (RS,IMI,IMS,PC);
  type AluCtrlEnum is (ADD_SUB,SLT_SLTU,BITWISE);
  type Src1CtrlEnum is (RS,IMU,PC_INCREMENT,URS1);

  function pkg_mux (sel : std_logic; one : BranchCtrlEnum; zero : BranchCtrlEnum) return BranchCtrlEnum;
  subtype BranchCtrlEnum_seq_type is std_logic_vector(1 downto 0);
  constant BranchCtrlEnum_seq_INC : BranchCtrlEnum_seq_type := "00";
  constant BranchCtrlEnum_seq_B : BranchCtrlEnum_seq_type := "01";
  constant BranchCtrlEnum_seq_JAL : BranchCtrlEnum_seq_type := "10";
  constant BranchCtrlEnum_seq_JALR : BranchCtrlEnum_seq_type := "11";

  function pkg_mux (sel : std_logic; one : ShiftCtrlEnum; zero : ShiftCtrlEnum) return ShiftCtrlEnum;
  subtype ShiftCtrlEnum_seq_type is std_logic_vector(1 downto 0);
  constant ShiftCtrlEnum_seq_DISABLE_1 : ShiftCtrlEnum_seq_type := "00";
  constant ShiftCtrlEnum_seq_SLL_1 : ShiftCtrlEnum_seq_type := "01";
  constant ShiftCtrlEnum_seq_SRL_1 : ShiftCtrlEnum_seq_type := "10";
  constant ShiftCtrlEnum_seq_SRA_1 : ShiftCtrlEnum_seq_type := "11";

  function pkg_mux (sel : std_logic; one : AluBitwiseCtrlEnum; zero : AluBitwiseCtrlEnum) return AluBitwiseCtrlEnum;
  subtype AluBitwiseCtrlEnum_seq_type is std_logic_vector(1 downto 0);
  constant AluBitwiseCtrlEnum_seq_XOR_1 : AluBitwiseCtrlEnum_seq_type := "00";
  constant AluBitwiseCtrlEnum_seq_OR_1 : AluBitwiseCtrlEnum_seq_type := "01";
  constant AluBitwiseCtrlEnum_seq_AND_1 : AluBitwiseCtrlEnum_seq_type := "10";

  function pkg_mux (sel : std_logic; one : EnvCtrlEnum; zero : EnvCtrlEnum) return EnvCtrlEnum;
  subtype EnvCtrlEnum_seq_type is std_logic_vector(0 downto 0);
  constant EnvCtrlEnum_seq_NONE : EnvCtrlEnum_seq_type := "0";
  constant EnvCtrlEnum_seq_XRET : EnvCtrlEnum_seq_type := "1";

  function pkg_mux (sel : std_logic; one : Src2CtrlEnum; zero : Src2CtrlEnum) return Src2CtrlEnum;
  subtype Src2CtrlEnum_seq_type is std_logic_vector(1 downto 0);
  constant Src2CtrlEnum_seq_RS : Src2CtrlEnum_seq_type := "00";
  constant Src2CtrlEnum_seq_IMI : Src2CtrlEnum_seq_type := "01";
  constant Src2CtrlEnum_seq_IMS : Src2CtrlEnum_seq_type := "10";
  constant Src2CtrlEnum_seq_PC : Src2CtrlEnum_seq_type := "11";

  function pkg_mux (sel : std_logic; one : AluCtrlEnum; zero : AluCtrlEnum) return AluCtrlEnum;
  subtype AluCtrlEnum_seq_type is std_logic_vector(1 downto 0);
  constant AluCtrlEnum_seq_ADD_SUB : AluCtrlEnum_seq_type := "00";
  constant AluCtrlEnum_seq_SLT_SLTU : AluCtrlEnum_seq_type := "01";
  constant AluCtrlEnum_seq_BITWISE : AluCtrlEnum_seq_type := "10";

  function pkg_mux (sel : std_logic; one : Src1CtrlEnum; zero : Src1CtrlEnum) return Src1CtrlEnum;
  subtype Src1CtrlEnum_seq_type is std_logic_vector(1 downto 0);
  constant Src1CtrlEnum_seq_RS : Src1CtrlEnum_seq_type := "00";
  constant Src1CtrlEnum_seq_IMU : Src1CtrlEnum_seq_type := "01";
  constant Src1CtrlEnum_seq_PC_INCREMENT : Src1CtrlEnum_seq_type := "10";
  constant Src1CtrlEnum_seq_URS1 : Src1CtrlEnum_seq_type := "11";

end pkg_enum;

package body pkg_enum is
  function pkg_mux (sel : std_logic; one : BranchCtrlEnum; zero : BranchCtrlEnum) return BranchCtrlEnum is
  begin
    if sel = '1' then
      return one;
    else
      return zero;
    end if;
  end pkg_mux;

  function pkg_mux (sel : std_logic; one : ShiftCtrlEnum; zero : ShiftCtrlEnum) return ShiftCtrlEnum is
  begin
    if sel = '1' then
      return one;
    else
      return zero;
    end if;
  end pkg_mux;

  function pkg_mux (sel : std_logic; one : AluBitwiseCtrlEnum; zero : AluBitwiseCtrlEnum) return AluBitwiseCtrlEnum is
  begin
    if sel = '1' then
      return one;
    else
      return zero;
    end if;
  end pkg_mux;

  function pkg_mux (sel : std_logic; one : EnvCtrlEnum; zero : EnvCtrlEnum) return EnvCtrlEnum is
  begin
    if sel = '1' then
      return one;
    else
      return zero;
    end if;
  end pkg_mux;

  function pkg_mux (sel : std_logic; one : Src2CtrlEnum; zero : Src2CtrlEnum) return Src2CtrlEnum is
  begin
    if sel = '1' then
      return one;
    else
      return zero;
    end if;
  end pkg_mux;

  function pkg_mux (sel : std_logic; one : AluCtrlEnum; zero : AluCtrlEnum) return AluCtrlEnum is
  begin
    if sel = '1' then
      return one;
    else
      return zero;
    end if;
  end pkg_mux;

  function pkg_mux (sel : std_logic; one : Src1CtrlEnum; zero : Src1CtrlEnum) return Src1CtrlEnum is
  begin
    if sel = '1' then
      return one;
    else
      return zero;
    end if;
  end pkg_mux;

end pkg_enum;


library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

package pkg_scala2hdl is
  function pkg_extract (that : std_logic_vector; bitId : integer) return std_logic;
  function pkg_extract (that : std_logic_vector; base : unsigned; size : integer) return std_logic_vector;
  function pkg_cat (a : std_logic_vector; b : std_logic_vector) return std_logic_vector;
  function pkg_not (value : std_logic_vector) return std_logic_vector;
  function pkg_extract (that : unsigned; bitId : integer) return std_logic;
  function pkg_extract (that : unsigned; base : unsigned; size : integer) return unsigned;
  function pkg_cat (a : unsigned; b : unsigned) return unsigned;
  function pkg_not (value : unsigned) return unsigned;
  function pkg_extract (that : signed; bitId : integer) return std_logic;
  function pkg_extract (that : signed; base : unsigned; size : integer) return signed;
  function pkg_cat (a : signed; b : signed) return signed;
  function pkg_not (value : signed) return signed;

  function pkg_mux (sel : std_logic; one : std_logic; zero : std_logic) return std_logic;
  function pkg_mux (sel : std_logic; one : std_logic_vector; zero : std_logic_vector) return std_logic_vector;
  function pkg_mux (sel : std_logic; one : unsigned; zero : unsigned) return unsigned;
  function pkg_mux (sel : std_logic; one : signed; zero : signed) return signed;

  function pkg_toStdLogic (value : boolean) return std_logic;
  function pkg_toStdLogicVector (value : std_logic) return std_logic_vector;
  function pkg_toUnsigned (value : std_logic) return unsigned;
  function pkg_toSigned (value : std_logic) return signed;
  function pkg_stdLogicVector (lit : std_logic_vector) return std_logic_vector;
  function pkg_unsigned (lit : unsigned) return unsigned;
  function pkg_signed (lit : signed) return signed;

  function pkg_resize (that : std_logic_vector; width : integer) return std_logic_vector;
  function pkg_resize (that : unsigned; width : integer) return unsigned;
  function pkg_resize (that : signed; width : integer) return signed;

  function pkg_extract (that : std_logic_vector; high : integer; low : integer) return std_logic_vector;
  function pkg_extract (that : unsigned; high : integer; low : integer) return unsigned;
  function pkg_extract (that : signed; high : integer; low : integer) return signed;

  function pkg_shiftRight (that : std_logic_vector; size : natural) return std_logic_vector;
  function pkg_shiftRight (that : std_logic_vector; size : unsigned) return std_logic_vector;
  function pkg_shiftLeft (that : std_logic_vector; size : natural) return std_logic_vector;
  function pkg_shiftLeft (that : std_logic_vector; size : unsigned) return std_logic_vector;

  function pkg_shiftRight (that : unsigned; size : natural) return unsigned;
  function pkg_shiftRight (that : unsigned; size : unsigned) return unsigned;
  function pkg_shiftLeft (that : unsigned; size : natural) return unsigned;
  function pkg_shiftLeft (that : unsigned; size : unsigned) return unsigned;

  function pkg_shiftRight (that : signed; size : natural) return signed;
  function pkg_shiftRight (that : signed; size : unsigned) return signed;
  function pkg_shiftLeft (that : signed; size : natural) return signed;
  function pkg_shiftLeft (that : signed; size : unsigned; w : integer) return signed;

  function pkg_rotateLeft (that : std_logic_vector; size : unsigned) return std_logic_vector;
end  pkg_scala2hdl;

package body pkg_scala2hdl is
  function pkg_extract (that : std_logic_vector; bitId : integer) return std_logic is
    alias temp : std_logic_vector(that'length-1 downto 0) is that;
  begin
    if bitId >= temp'length then
      return 'U';
    end if;
    return temp(bitId);
  end pkg_extract;

  function pkg_extract (that : std_logic_vector; base : unsigned; size : integer) return std_logic_vector is
    alias temp : std_logic_vector(that'length-1 downto 0) is that;    constant elementCount : integer := temp'length - size + 1;
    type tableType is array (0 to elementCount-1) of std_logic_vector(size-1 downto 0);
    variable table : tableType;
  begin
    for i in 0 to elementCount-1 loop
      table(i) := temp(i + size - 1 downto i);
    end loop;
    if base + size >= elementCount then
      return (size-1 downto 0 => 'U');
    end if;
    return table(to_integer(base));
  end pkg_extract;

  function pkg_cat (a : std_logic_vector; b : std_logic_vector) return std_logic_vector is
    variable cat : std_logic_vector(a'length + b'length-1 downto 0);
  begin
    cat := a & b;
    return cat;
  end pkg_cat;

  function pkg_not (value : std_logic_vector) return std_logic_vector is
    variable ret : std_logic_vector(value'length-1 downto 0);
  begin
    ret := not value;
    return ret;
  end pkg_not;

  function pkg_extract (that : unsigned; bitId : integer) return std_logic is
    alias temp : unsigned(that'length-1 downto 0) is that;
  begin
    if bitId >= temp'length then
      return 'U';
    end if;
    return temp(bitId);
  end pkg_extract;

  function pkg_extract (that : unsigned; base : unsigned; size : integer) return unsigned is
    alias temp : unsigned(that'length-1 downto 0) is that;    constant elementCount : integer := temp'length - size + 1;
    type tableType is array (0 to elementCount-1) of unsigned(size-1 downto 0);
    variable table : tableType;
  begin
    for i in 0 to elementCount-1 loop
      table(i) := temp(i + size - 1 downto i);
    end loop;
    if base + size >= elementCount then
      return (size-1 downto 0 => 'U');
    end if;
    return table(to_integer(base));
  end pkg_extract;

  function pkg_cat (a : unsigned; b : unsigned) return unsigned is
    variable cat : unsigned(a'length + b'length-1 downto 0);
  begin
    cat := a & b;
    return cat;
  end pkg_cat;

  function pkg_not (value : unsigned) return unsigned is
    variable ret : unsigned(value'length-1 downto 0);
  begin
    ret := not value;
    return ret;
  end pkg_not;

  function pkg_extract (that : signed; bitId : integer) return std_logic is
    alias temp : signed(that'length-1 downto 0) is that;
  begin
    if bitId >= temp'length then
      return 'U';
    end if;
    return temp(bitId);
  end pkg_extract;

  function pkg_extract (that : signed; base : unsigned; size : integer) return signed is
    alias temp : signed(that'length-1 downto 0) is that;    constant elementCount : integer := temp'length - size + 1;
    type tableType is array (0 to elementCount-1) of signed(size-1 downto 0);
    variable table : tableType;
  begin
    for i in 0 to elementCount-1 loop
      table(i) := temp(i + size - 1 downto i);
    end loop;
    if base + size >= elementCount then
      return (size-1 downto 0 => 'U');
    end if;
    return table(to_integer(base));
  end pkg_extract;

  function pkg_cat (a : signed; b : signed) return signed is
    variable cat : signed(a'length + b'length-1 downto 0);
  begin
    cat := a & b;
    return cat;
  end pkg_cat;

  function pkg_not (value : signed) return signed is
    variable ret : signed(value'length-1 downto 0);
  begin
    ret := not value;
    return ret;
  end pkg_not;


  -- unsigned shifts
  function pkg_shiftRight (that : unsigned; size : natural) return unsigned is
    variable ret : unsigned(that'length-1 downto 0);
  begin
    if size >= that'length then
      return "";
    else
      ret := shift_right(that,size);
      return ret(that'length-1-size downto 0);
    end if;
  end pkg_shiftRight;

  function pkg_shiftRight (that : unsigned; size : unsigned) return unsigned is
    variable ret : unsigned(that'length-1 downto 0);
  begin
    ret := shift_right(that,to_integer(size));
    return ret;
  end pkg_shiftRight;

  function pkg_shiftLeft (that : unsigned; size : natural) return unsigned is
  begin
    return shift_left(resize(that,that'length + size),size);
  end pkg_shiftLeft;

  function pkg_shiftLeft (that : unsigned; size : unsigned) return unsigned is
  begin
    return shift_left(resize(that,that'length + 2**size'length - 1),to_integer(size));
  end pkg_shiftLeft;

  -- std_logic_vector shifts
  function pkg_shiftRight (that : std_logic_vector; size : natural) return std_logic_vector is
  begin
    return std_logic_vector(pkg_shiftRight(unsigned(that),size));
  end pkg_shiftRight;

  function pkg_shiftRight (that : std_logic_vector; size : unsigned) return std_logic_vector is
  begin
    return std_logic_vector(pkg_shiftRight(unsigned(that),size));
  end pkg_shiftRight;

  function pkg_shiftLeft (that : std_logic_vector; size : natural) return std_logic_vector is
  begin
    return std_logic_vector(pkg_shiftLeft(unsigned(that),size));
  end pkg_shiftLeft;

  function pkg_shiftLeft (that : std_logic_vector; size : unsigned) return std_logic_vector is
  begin
    return std_logic_vector(pkg_shiftLeft(unsigned(that),size));
  end pkg_shiftLeft;

  -- signed shifts
  function pkg_shiftRight (that : signed; size : natural) return signed is
  begin
    return signed(pkg_shiftRight(unsigned(that),size));
  end pkg_shiftRight;

  function pkg_shiftRight (that : signed; size : unsigned) return signed is
  begin
    return shift_right(that,to_integer(size));
  end pkg_shiftRight;

  function pkg_shiftLeft (that : signed; size : natural) return signed is
  begin
    return signed(pkg_shiftLeft(unsigned(that),size));
  end pkg_shiftLeft;

  function pkg_shiftLeft (that : signed; size : unsigned; w : integer) return signed is
  begin
    return shift_left(resize(that,w),to_integer(size));
  end pkg_shiftLeft;

  function pkg_rotateLeft (that : std_logic_vector; size : unsigned) return std_logic_vector is
  begin
    return std_logic_vector(rotate_left(unsigned(that),to_integer(size)));
  end pkg_rotateLeft;

  function pkg_extract (that : std_logic_vector; high : integer; low : integer) return std_logic_vector is
    alias temp : std_logic_vector(that'length-1 downto 0) is that;
  begin
    return temp(high downto low);
  end pkg_extract;

  function pkg_extract (that : unsigned; high : integer; low : integer) return unsigned is
    alias temp : unsigned(that'length-1 downto 0) is that;
  begin
    return temp(high downto low);
  end pkg_extract;

  function pkg_extract (that : signed; high : integer; low : integer) return signed is
    alias temp : signed(that'length-1 downto 0) is that;
  begin
    return temp(high downto low);
  end pkg_extract;

  function pkg_mux (sel : std_logic; one : std_logic; zero : std_logic) return std_logic is
  begin
    if sel = '1' then
      return one;
    else
      return zero;
    end if;
  end pkg_mux;

  function pkg_mux (sel : std_logic; one : std_logic_vector; zero : std_logic_vector) return std_logic_vector is
    variable ret : std_logic_vector(zero'range);
  begin
    if sel = '1' then
      ret := one;
    else
      ret := zero;
    end if;
    return ret;
  end pkg_mux;

  function pkg_mux (sel : std_logic; one : unsigned; zero : unsigned) return unsigned is
    variable ret : unsigned(zero'range);
  begin
    if sel = '1' then
      ret := one;
    else
      ret := zero;
    end if;
    return ret;
  end pkg_mux;

  function pkg_mux (sel : std_logic; one : signed; zero : signed) return signed is
    variable ret : signed(zero'range);
  begin
    if sel = '1' then
      ret := one;
    else
      ret := zero;
    end if;
    return ret;
  end pkg_mux;

  function pkg_toStdLogic (value : boolean) return std_logic is
  begin
    if value = true then
      return '1';
    else
      return '0';
    end if;
  end pkg_toStdLogic;

  function pkg_toStdLogicVector (value : std_logic) return std_logic_vector is
    variable ret : std_logic_vector(0 downto 0);
  begin
    ret(0) := value;
    return ret;
  end pkg_toStdLogicVector;

  function pkg_toUnsigned (value : std_logic) return unsigned is
    variable ret : unsigned(0 downto 0);
  begin
    ret(0) := value;
    return ret;
  end pkg_toUnsigned;

  function pkg_toSigned (value : std_logic) return signed is
    variable ret : signed(0 downto 0);
  begin
    ret(0) := value;
    return ret;
  end pkg_toSigned;

  function pkg_stdLogicVector (lit : std_logic_vector) return std_logic_vector is
    alias ret : std_logic_vector(lit'length-1 downto 0) is lit;
  begin
    return std_logic_vector(ret);
  end pkg_stdLogicVector;

  function pkg_unsigned (lit : unsigned) return unsigned is
    alias ret : unsigned(lit'length-1 downto 0) is lit;
  begin
    return unsigned(ret);
  end pkg_unsigned;

  function pkg_signed (lit : signed) return signed is
    alias ret : signed(lit'length-1 downto 0) is lit;
  begin
    return signed(ret);
  end pkg_signed;

  function pkg_resize (that : std_logic_vector; width : integer) return std_logic_vector is
  begin
    return std_logic_vector(resize(unsigned(that),width));
  end pkg_resize;

  function pkg_resize (that : unsigned; width : integer) return unsigned is
    variable ret : unsigned(width-1 downto 0);
  begin
    if that'length = 0 then
       ret := (others => '0');
    else
       ret := resize(that,width);
    end if;
    return ret;
  end pkg_resize;
  function pkg_resize (that : signed; width : integer) return signed is
    alias temp : signed(that'length-1 downto 0) is that;
    variable ret : signed(width-1 downto 0);
  begin
    if temp'length = 0 then
       ret := (others => '0');
    elsif temp'length >= width then
       ret := temp(width-1 downto 0);
    else
       ret := resize(temp,width);
    end if;
    return ret;
  end pkg_resize;
end pkg_scala2hdl;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.pkg_scala2hdl.all;
use work.all;
use work.pkg_enum.all;


entity InstructionCache is
  port(
    io_flush : in std_logic;
    io_cpu_prefetch_isValid : in std_logic;
    io_cpu_prefetch_haltIt : out std_logic;
    io_cpu_prefetch_pc : in unsigned(31 downto 0);
    io_cpu_fetch_isValid : in std_logic;
    io_cpu_fetch_isStuck : in std_logic;
    io_cpu_fetch_isRemoved : in std_logic;
    io_cpu_fetch_pc : in unsigned(31 downto 0);
    io_cpu_fetch_data : out std_logic_vector(31 downto 0);
    io_cpu_fetch_mmuRsp_physicalAddress : in unsigned(31 downto 0);
    io_cpu_fetch_mmuRsp_isIoAccess : in std_logic;
    io_cpu_fetch_mmuRsp_isPaging : in std_logic;
    io_cpu_fetch_mmuRsp_allowRead : in std_logic;
    io_cpu_fetch_mmuRsp_allowWrite : in std_logic;
    io_cpu_fetch_mmuRsp_allowExecute : in std_logic;
    io_cpu_fetch_mmuRsp_exception : in std_logic;
    io_cpu_fetch_mmuRsp_refilling : in std_logic;
    io_cpu_fetch_mmuRsp_bypassTranslation : in std_logic;
    io_cpu_fetch_physicalAddress : out unsigned(31 downto 0);
    io_cpu_decode_isValid : in std_logic;
    io_cpu_decode_isStuck : in std_logic;
    io_cpu_decode_pc : in unsigned(31 downto 0);
    io_cpu_decode_physicalAddress : out unsigned(31 downto 0);
    io_cpu_decode_data : out std_logic_vector(31 downto 0);
    io_cpu_decode_cacheMiss : out std_logic;
    io_cpu_decode_error : out std_logic;
    io_cpu_decode_mmuRefilling : out std_logic;
    io_cpu_decode_mmuException : out std_logic;
    io_cpu_decode_isUser : in std_logic;
    io_cpu_fill_valid : in std_logic;
    io_cpu_fill_payload : in unsigned(31 downto 0);
    io_mem_cmd_valid : out std_logic;
    io_mem_cmd_ready : in std_logic;
    io_mem_cmd_payload_address : out unsigned(31 downto 0);
    io_mem_cmd_payload_size : out unsigned(2 downto 0);
    io_mem_rsp_valid : in std_logic;
    io_mem_rsp_payload_data : in std_logic_vector(31 downto 0);
    io_mem_rsp_payload_error : in std_logic;
    io_mainClk : in std_logic;
    resetCtrl_systemReset : in std_logic
  );
end InstructionCache;

architecture arch of InstructionCache is
  signal zz_banks_0_port0 : std_logic_vector(31 downto 0);
  signal zz_banks_1_port0 : std_logic_vector(31 downto 0);
  signal zz_ways_0_tags_port0 : std_logic_vector(21 downto 0);
  signal zz_ways_1_tags_port0 : std_logic_vector(21 downto 0);
  signal io_mem_cmd_valid_read_buffer : std_logic;
  signal io_cpu_fetch_data_read_buffer : std_logic_vector(31 downto 0);
  signal zz_ways_0_tags_port : std_logic_vector(21 downto 0);
  signal zz_ways_1_tags_port : std_logic_vector(21 downto 0);
  signal zz_fetchStage_hit_error : std_logic;
  signal zz_fetchStage_hit_data : std_logic_vector(31 downto 0);
  attribute keep : boolean;
  attribute syn_keep : boolean;

  signal zz_1 : std_logic;
  signal zz_2 : std_logic;
  signal zz_3 : std_logic;
  signal zz_4 : std_logic;
  signal lineLoader_fire : std_logic;
  signal lineLoader_valid : std_logic;
  signal lineLoader_address : unsigned(31 downto 0);
  attribute keep of lineLoader_address : signal is true;
  attribute syn_keep of lineLoader_address : signal is true;
  signal lineLoader_hadError : std_logic;
  signal lineLoader_flushPending : std_logic;
  signal lineLoader_flushCounter : unsigned(7 downto 0);
  signal when_InstructionCache_l338 : std_logic;
  signal zz_when_InstructionCache_l342 : std_logic;
  signal when_InstructionCache_l342 : std_logic;
  signal when_InstructionCache_l351 : std_logic;
  signal lineLoader_cmdSent : std_logic;
  signal io_mem_cmd_fire : std_logic;
  signal when_Utils_l538 : std_logic;
  signal lineLoader_wayToAllocate_willIncrement : std_logic;
  signal lineLoader_wayToAllocate_willClear : std_logic;
  signal lineLoader_wayToAllocate_valueNext : unsigned(0 downto 0);
  signal lineLoader_wayToAllocate_value : unsigned(0 downto 0);
  signal lineLoader_wayToAllocate_willOverflowIfInc : std_logic;
  signal lineLoader_wayToAllocate_willOverflow : std_logic;
  signal lineLoader_wordIndex : unsigned(2 downto 0);
  attribute keep of lineLoader_wordIndex : signal is true;
  attribute syn_keep of lineLoader_wordIndex : signal is true;
  signal lineLoader_write_tag_0_valid : std_logic;
  signal lineLoader_write_tag_0_payload_address : unsigned(6 downto 0);
  signal lineLoader_write_tag_0_payload_data_valid : std_logic;
  signal lineLoader_write_tag_0_payload_data_error : std_logic;
  signal lineLoader_write_tag_0_payload_data_address : unsigned(19 downto 0);
  signal lineLoader_write_tag_1_valid : std_logic;
  signal lineLoader_write_tag_1_payload_address : unsigned(6 downto 0);
  signal lineLoader_write_tag_1_payload_data_valid : std_logic;
  signal lineLoader_write_tag_1_payload_data_error : std_logic;
  signal lineLoader_write_tag_1_payload_data_address : unsigned(19 downto 0);
  signal lineLoader_write_data_0_valid : std_logic;
  signal lineLoader_write_data_0_payload_address : unsigned(9 downto 0);
  signal lineLoader_write_data_0_payload_data : std_logic_vector(31 downto 0);
  signal lineLoader_write_data_1_valid : std_logic;
  signal lineLoader_write_data_1_payload_address : unsigned(9 downto 0);
  signal lineLoader_write_data_1_payload_data : std_logic_vector(31 downto 0);
  signal when_InstructionCache_l401 : std_logic;
  signal zz_fetchStage_read_banksValue_0_dataMem : unsigned(9 downto 0);
  signal zz_fetchStage_read_banksValue_0_dataMem_1 : std_logic;
  signal fetchStage_read_banksValue_0_dataMem : std_logic_vector(31 downto 0);
  signal fetchStage_read_banksValue_0_data : std_logic_vector(31 downto 0);
  signal zz_fetchStage_read_banksValue_1_dataMem : unsigned(9 downto 0);
  signal zz_fetchStage_read_banksValue_1_dataMem_1 : std_logic;
  signal fetchStage_read_banksValue_1_dataMem : std_logic_vector(31 downto 0);
  signal fetchStage_read_banksValue_1_data : std_logic_vector(31 downto 0);
  signal zz_fetchStage_read_waysValues_0_tag_valid : unsigned(6 downto 0);
  signal zz_fetchStage_read_waysValues_0_tag_valid_1 : std_logic;
  signal fetchStage_read_waysValues_0_tag_valid : std_logic;
  signal fetchStage_read_waysValues_0_tag_error : std_logic;
  signal fetchStage_read_waysValues_0_tag_address : unsigned(19 downto 0);
  signal zz_fetchStage_read_waysValues_0_tag_valid_2 : std_logic_vector(21 downto 0);
  signal zz_fetchStage_read_waysValues_1_tag_valid : unsigned(6 downto 0);
  signal zz_fetchStage_read_waysValues_1_tag_valid_1 : std_logic;
  signal fetchStage_read_waysValues_1_tag_valid : std_logic;
  signal fetchStage_read_waysValues_1_tag_error : std_logic;
  signal fetchStage_read_waysValues_1_tag_address : unsigned(19 downto 0);
  signal zz_fetchStage_read_waysValues_1_tag_valid_2 : std_logic_vector(21 downto 0);
  signal fetchStage_hit_hits_0 : std_logic;
  signal fetchStage_hit_hits_1 : std_logic;
  signal fetchStage_hit_valid : std_logic;
  signal fetchStage_hit_wayId : unsigned(0 downto 0);
  signal fetchStage_hit_error : std_logic;
  signal fetchStage_hit_data : std_logic_vector(31 downto 0);
  signal fetchStage_hit_word : std_logic_vector(31 downto 0);
  signal when_InstructionCache_l435 : std_logic;
  signal io_cpu_fetch_data_regNextWhen : std_logic_vector(31 downto 0);
  signal when_InstructionCache_l459 : std_logic;
  signal decodeStage_mmuRsp_physicalAddress : unsigned(31 downto 0);
  signal decodeStage_mmuRsp_isIoAccess : std_logic;
  signal decodeStage_mmuRsp_isPaging : std_logic;
  signal decodeStage_mmuRsp_allowRead : std_logic;
  signal decodeStage_mmuRsp_allowWrite : std_logic;
  signal decodeStage_mmuRsp_allowExecute : std_logic;
  signal decodeStage_mmuRsp_exception : std_logic;
  signal decodeStage_mmuRsp_refilling : std_logic;
  signal decodeStage_mmuRsp_bypassTranslation : std_logic;
  signal when_InstructionCache_l459_1 : std_logic;
  signal decodeStage_hit_valid : std_logic;
  signal when_InstructionCache_l459_2 : std_logic;
  signal decodeStage_hit_error : std_logic;
  type banks_0_type is array (0 to 1023) of std_logic_vector(31 downto 0);
  signal banks_0 : banks_0_type;
  type banks_1_type is array (0 to 1023) of std_logic_vector(31 downto 0);
  signal banks_1 : banks_1_type;
  type ways_0_tags_type is array (0 to 127) of std_logic_vector(21 downto 0);
  signal ways_0_tags : ways_0_tags_type;
  type ways_1_tags_type is array (0 to 127) of std_logic_vector(21 downto 0);
  signal ways_1_tags : ways_1_tags_type;
begin
  io_mem_cmd_valid <= io_mem_cmd_valid_read_buffer;
  io_cpu_fetch_data <= io_cpu_fetch_data_read_buffer;
  zz_ways_0_tags_port <= pkg_cat(std_logic_vector(lineLoader_write_tag_0_payload_data_address),pkg_cat(pkg_toStdLogicVector(lineLoader_write_tag_0_payload_data_error),pkg_toStdLogicVector(lineLoader_write_tag_0_payload_data_valid)));
  zz_ways_1_tags_port <= pkg_cat(std_logic_vector(lineLoader_write_tag_1_payload_data_address),pkg_cat(pkg_toStdLogicVector(lineLoader_write_tag_1_payload_data_error),pkg_toStdLogicVector(lineLoader_write_tag_1_payload_data_valid)));
  process(io_mainClk)
  begin
    if rising_edge(io_mainClk) then
      if zz_2 = '1' then
        banks_0(to_integer(lineLoader_write_data_0_payload_address)) <= lineLoader_write_data_0_payload_data;
      end if;
    end if;
  end process;

  process(io_mainClk)
  begin
    if rising_edge(io_mainClk) then
      if zz_fetchStage_read_banksValue_0_dataMem_1 = '1' then
        zz_banks_0_port0 <= banks_0(to_integer(zz_fetchStage_read_banksValue_0_dataMem));
      end if;
    end if;
  end process;

  process(io_mainClk)
  begin
    if rising_edge(io_mainClk) then
      if zz_1 = '1' then
        banks_1(to_integer(lineLoader_write_data_1_payload_address)) <= lineLoader_write_data_1_payload_data;
      end if;
    end if;
  end process;

  process(io_mainClk)
  begin
    if rising_edge(io_mainClk) then
      if zz_fetchStage_read_banksValue_1_dataMem_1 = '1' then
        zz_banks_1_port0 <= banks_1(to_integer(zz_fetchStage_read_banksValue_1_dataMem));
      end if;
    end if;
  end process;

  process(io_mainClk)
  begin
    if rising_edge(io_mainClk) then
      if zz_4 = '1' then
        ways_0_tags(to_integer(lineLoader_write_tag_0_payload_address)) <= zz_ways_0_tags_port;
      end if;
    end if;
  end process;

  process(io_mainClk)
  begin
    if rising_edge(io_mainClk) then
      if zz_fetchStage_read_waysValues_0_tag_valid_1 = '1' then
        zz_ways_0_tags_port0 <= ways_0_tags(to_integer(zz_fetchStage_read_waysValues_0_tag_valid));
      end if;
    end if;
  end process;

  process(io_mainClk)
  begin
    if rising_edge(io_mainClk) then
      if zz_3 = '1' then
        ways_1_tags(to_integer(lineLoader_write_tag_1_payload_address)) <= zz_ways_1_tags_port;
      end if;
    end if;
  end process;

  process(io_mainClk)
  begin
    if rising_edge(io_mainClk) then
      if zz_fetchStage_read_waysValues_1_tag_valid_1 = '1' then
        zz_ways_1_tags_port0 <= ways_1_tags(to_integer(zz_fetchStage_read_waysValues_1_tag_valid));
      end if;
    end if;
  end process;

  process(fetchStage_hit_wayId,fetchStage_read_waysValues_0_tag_error,fetchStage_read_banksValue_0_data,fetchStage_read_waysValues_1_tag_error,fetchStage_read_banksValue_1_data)
  begin
    case fetchStage_hit_wayId is
      when "0" =>
        zz_fetchStage_hit_error <= fetchStage_read_waysValues_0_tag_error;
        zz_fetchStage_hit_data <= fetchStage_read_banksValue_0_data;
      when others =>
        zz_fetchStage_hit_error <= fetchStage_read_waysValues_1_tag_error;
        zz_fetchStage_hit_data <= fetchStage_read_banksValue_1_data;
    end case;
  end process;

  process(lineLoader_write_data_1_valid)
  begin
    zz_1 <= pkg_toStdLogic(false);
    if lineLoader_write_data_1_valid = '1' then
      zz_1 <= pkg_toStdLogic(true);
    end if;
  end process;

  process(lineLoader_write_data_0_valid)
  begin
    zz_2 <= pkg_toStdLogic(false);
    if lineLoader_write_data_0_valid = '1' then
      zz_2 <= pkg_toStdLogic(true);
    end if;
  end process;

  process(lineLoader_write_tag_1_valid)
  begin
    zz_3 <= pkg_toStdLogic(false);
    if lineLoader_write_tag_1_valid = '1' then
      zz_3 <= pkg_toStdLogic(true);
    end if;
  end process;

  process(lineLoader_write_tag_0_valid)
  begin
    zz_4 <= pkg_toStdLogic(false);
    if lineLoader_write_tag_0_valid = '1' then
      zz_4 <= pkg_toStdLogic(true);
    end if;
  end process;

  process(io_mem_rsp_valid,when_InstructionCache_l401)
  begin
    lineLoader_fire <= pkg_toStdLogic(false);
    if io_mem_rsp_valid = '1' then
      if when_InstructionCache_l401 = '1' then
        lineLoader_fire <= pkg_toStdLogic(true);
      end if;
    end if;
  end process;

  process(lineLoader_valid,lineLoader_flushPending,when_InstructionCache_l338,when_InstructionCache_l342,io_flush)
  begin
    io_cpu_prefetch_haltIt <= (lineLoader_valid or lineLoader_flushPending);
    if when_InstructionCache_l338 = '1' then
      io_cpu_prefetch_haltIt <= pkg_toStdLogic(true);
    end if;
    if when_InstructionCache_l342 = '1' then
      io_cpu_prefetch_haltIt <= pkg_toStdLogic(true);
    end if;
    if io_flush = '1' then
      io_cpu_prefetch_haltIt <= pkg_toStdLogic(true);
    end if;
  end process;

  when_InstructionCache_l338 <= (not pkg_extract(lineLoader_flushCounter,7));
  when_InstructionCache_l342 <= (not zz_when_InstructionCache_l342);
  when_InstructionCache_l351 <= (lineLoader_flushPending and (not (lineLoader_valid or io_cpu_fetch_isValid)));
  io_mem_cmd_fire <= (io_mem_cmd_valid_read_buffer and io_mem_cmd_ready);
  io_mem_cmd_valid_read_buffer <= (lineLoader_valid and (not lineLoader_cmdSent));
  io_mem_cmd_payload_address <= unsigned(pkg_cat(std_logic_vector(pkg_extract(lineLoader_address,31,5)),std_logic_vector(pkg_unsigned("00000"))));
  io_mem_cmd_payload_size <= pkg_unsigned("101");
  when_Utils_l538 <= (not lineLoader_valid);
  process(when_Utils_l538)
  begin
    lineLoader_wayToAllocate_willIncrement <= pkg_toStdLogic(false);
    if when_Utils_l538 = '1' then
      lineLoader_wayToAllocate_willIncrement <= pkg_toStdLogic(true);
    end if;
  end process;

  lineLoader_wayToAllocate_willClear <= pkg_toStdLogic(false);
  lineLoader_wayToAllocate_willOverflowIfInc <= pkg_toStdLogic(lineLoader_wayToAllocate_value = pkg_unsigned("1"));
  lineLoader_wayToAllocate_willOverflow <= (lineLoader_wayToAllocate_willOverflowIfInc and lineLoader_wayToAllocate_willIncrement);
  process(lineLoader_wayToAllocate_value,lineLoader_wayToAllocate_willIncrement,lineLoader_wayToAllocate_willClear)
  begin
    lineLoader_wayToAllocate_valueNext <= (lineLoader_wayToAllocate_value + unsigned(pkg_toStdLogicVector(lineLoader_wayToAllocate_willIncrement)));
    if lineLoader_wayToAllocate_willClear = '1' then
      lineLoader_wayToAllocate_valueNext <= pkg_unsigned("0");
    end if;
  end process;

  lineLoader_write_tag_0_valid <= ((pkg_toStdLogic(lineLoader_wayToAllocate_value = pkg_unsigned("0")) and lineLoader_fire) or (not pkg_extract(lineLoader_flushCounter,7)));
  lineLoader_write_tag_0_payload_address <= pkg_mux(pkg_extract(lineLoader_flushCounter,7),pkg_extract(lineLoader_address,11,5),pkg_extract(lineLoader_flushCounter,6,0));
  lineLoader_write_tag_0_payload_data_valid <= pkg_extract(lineLoader_flushCounter,7);
  lineLoader_write_tag_0_payload_data_error <= (lineLoader_hadError or io_mem_rsp_payload_error);
  lineLoader_write_tag_0_payload_data_address <= pkg_extract(lineLoader_address,31,12);
  lineLoader_write_tag_1_valid <= ((pkg_toStdLogic(lineLoader_wayToAllocate_value = pkg_unsigned("1")) and lineLoader_fire) or (not pkg_extract(lineLoader_flushCounter,7)));
  lineLoader_write_tag_1_payload_address <= pkg_mux(pkg_extract(lineLoader_flushCounter,7),pkg_extract(lineLoader_address,11,5),pkg_extract(lineLoader_flushCounter,6,0));
  lineLoader_write_tag_1_payload_data_valid <= pkg_extract(lineLoader_flushCounter,7);
  lineLoader_write_tag_1_payload_data_error <= (lineLoader_hadError or io_mem_rsp_payload_error);
  lineLoader_write_tag_1_payload_data_address <= pkg_extract(lineLoader_address,31,12);
  lineLoader_write_data_0_valid <= (io_mem_rsp_valid and pkg_toStdLogic(lineLoader_wayToAllocate_value = pkg_unsigned("0")));
  lineLoader_write_data_0_payload_address <= unsigned(pkg_cat(std_logic_vector(pkg_extract(lineLoader_address,11,5)),std_logic_vector(lineLoader_wordIndex)));
  lineLoader_write_data_0_payload_data <= io_mem_rsp_payload_data;
  lineLoader_write_data_1_valid <= (io_mem_rsp_valid and pkg_toStdLogic(lineLoader_wayToAllocate_value = pkg_unsigned("1")));
  lineLoader_write_data_1_payload_address <= unsigned(pkg_cat(std_logic_vector(pkg_extract(lineLoader_address,11,5)),std_logic_vector(lineLoader_wordIndex)));
  lineLoader_write_data_1_payload_data <= io_mem_rsp_payload_data;
  when_InstructionCache_l401 <= pkg_toStdLogic(lineLoader_wordIndex = pkg_unsigned("111"));
  zz_fetchStage_read_banksValue_0_dataMem <= pkg_extract(io_cpu_prefetch_pc,11,2);
  zz_fetchStage_read_banksValue_0_dataMem_1 <= (not io_cpu_fetch_isStuck);
  fetchStage_read_banksValue_0_dataMem <= zz_banks_0_port0;
  fetchStage_read_banksValue_0_data <= pkg_extract(fetchStage_read_banksValue_0_dataMem,31,0);
  zz_fetchStage_read_banksValue_1_dataMem <= pkg_extract(io_cpu_prefetch_pc,11,2);
  zz_fetchStage_read_banksValue_1_dataMem_1 <= (not io_cpu_fetch_isStuck);
  fetchStage_read_banksValue_1_dataMem <= zz_banks_1_port0;
  fetchStage_read_banksValue_1_data <= pkg_extract(fetchStage_read_banksValue_1_dataMem,31,0);
  zz_fetchStage_read_waysValues_0_tag_valid <= pkg_extract(io_cpu_prefetch_pc,11,5);
  zz_fetchStage_read_waysValues_0_tag_valid_1 <= (not io_cpu_fetch_isStuck);
  zz_fetchStage_read_waysValues_0_tag_valid_2 <= zz_ways_0_tags_port0;
  fetchStage_read_waysValues_0_tag_valid <= pkg_extract(zz_fetchStage_read_waysValues_0_tag_valid_2,0);
  fetchStage_read_waysValues_0_tag_error <= pkg_extract(zz_fetchStage_read_waysValues_0_tag_valid_2,1);
  fetchStage_read_waysValues_0_tag_address <= unsigned(pkg_extract(zz_fetchStage_read_waysValues_0_tag_valid_2,21,2));
  zz_fetchStage_read_waysValues_1_tag_valid <= pkg_extract(io_cpu_prefetch_pc,11,5);
  zz_fetchStage_read_waysValues_1_tag_valid_1 <= (not io_cpu_fetch_isStuck);
  zz_fetchStage_read_waysValues_1_tag_valid_2 <= zz_ways_1_tags_port0;
  fetchStage_read_waysValues_1_tag_valid <= pkg_extract(zz_fetchStage_read_waysValues_1_tag_valid_2,0);
  fetchStage_read_waysValues_1_tag_error <= pkg_extract(zz_fetchStage_read_waysValues_1_tag_valid_2,1);
  fetchStage_read_waysValues_1_tag_address <= unsigned(pkg_extract(zz_fetchStage_read_waysValues_1_tag_valid_2,21,2));
  fetchStage_hit_hits_0 <= (fetchStage_read_waysValues_0_tag_valid and pkg_toStdLogic(fetchStage_read_waysValues_0_tag_address = pkg_extract(io_cpu_fetch_mmuRsp_physicalAddress,31,12)));
  fetchStage_hit_hits_1 <= (fetchStage_read_waysValues_1_tag_valid and pkg_toStdLogic(fetchStage_read_waysValues_1_tag_address = pkg_extract(io_cpu_fetch_mmuRsp_physicalAddress,31,12)));
  fetchStage_hit_valid <= pkg_toStdLogic(pkg_cat(pkg_toStdLogicVector(fetchStage_hit_hits_1),pkg_toStdLogicVector(fetchStage_hit_hits_0)) /= pkg_stdLogicVector("00"));
  fetchStage_hit_wayId <= unsigned(pkg_toStdLogicVector(fetchStage_hit_hits_1));
  fetchStage_hit_error <= zz_fetchStage_hit_error;
  fetchStage_hit_data <= zz_fetchStage_hit_data;
  fetchStage_hit_word <= fetchStage_hit_data;
  io_cpu_fetch_data_read_buffer <= fetchStage_hit_word;
  when_InstructionCache_l435 <= (not io_cpu_decode_isStuck);
  io_cpu_decode_data <= io_cpu_fetch_data_regNextWhen;
  io_cpu_fetch_physicalAddress <= io_cpu_fetch_mmuRsp_physicalAddress;
  when_InstructionCache_l459 <= (not io_cpu_decode_isStuck);
  when_InstructionCache_l459_1 <= (not io_cpu_decode_isStuck);
  when_InstructionCache_l459_2 <= (not io_cpu_decode_isStuck);
  io_cpu_decode_cacheMiss <= (not decodeStage_hit_valid);
  io_cpu_decode_error <= (decodeStage_hit_error or ((not decodeStage_mmuRsp_isPaging) and (decodeStage_mmuRsp_exception or (not decodeStage_mmuRsp_allowExecute))));
  io_cpu_decode_mmuRefilling <= decodeStage_mmuRsp_refilling;
  io_cpu_decode_mmuException <= (((not decodeStage_mmuRsp_refilling) and decodeStage_mmuRsp_isPaging) and (decodeStage_mmuRsp_exception or (not decodeStage_mmuRsp_allowExecute)));
  io_cpu_decode_physicalAddress <= decodeStage_mmuRsp_physicalAddress;
  process(io_mainClk, resetCtrl_systemReset)
  begin
    if resetCtrl_systemReset = '1' then
      lineLoader_valid <= pkg_toStdLogic(false);
      lineLoader_hadError <= pkg_toStdLogic(false);
      lineLoader_flushPending <= pkg_toStdLogic(true);
      lineLoader_cmdSent <= pkg_toStdLogic(false);
      lineLoader_wayToAllocate_value <= pkg_unsigned("0");
      lineLoader_wordIndex <= pkg_unsigned("000");
    elsif rising_edge(io_mainClk) then
      if lineLoader_fire = '1' then
        lineLoader_valid <= pkg_toStdLogic(false);
      end if;
      if lineLoader_fire = '1' then
        lineLoader_hadError <= pkg_toStdLogic(false);
      end if;
      if io_cpu_fill_valid = '1' then
        lineLoader_valid <= pkg_toStdLogic(true);
      end if;
      if io_flush = '1' then
        lineLoader_flushPending <= pkg_toStdLogic(true);
      end if;
      if when_InstructionCache_l351 = '1' then
        lineLoader_flushPending <= pkg_toStdLogic(false);
      end if;
      if io_mem_cmd_fire = '1' then
        lineLoader_cmdSent <= pkg_toStdLogic(true);
      end if;
      if lineLoader_fire = '1' then
        lineLoader_cmdSent <= pkg_toStdLogic(false);
      end if;
      lineLoader_wayToAllocate_value <= lineLoader_wayToAllocate_valueNext;
      if io_mem_rsp_valid = '1' then
        lineLoader_wordIndex <= (lineLoader_wordIndex + pkg_unsigned("001"));
        if io_mem_rsp_payload_error = '1' then
          lineLoader_hadError <= pkg_toStdLogic(true);
        end if;
      end if;
    end if;
  end process;

  process(io_mainClk)
  begin
    if rising_edge(io_mainClk) then
      if io_cpu_fill_valid = '1' then
        lineLoader_address <= io_cpu_fill_payload;
      end if;
      if when_InstructionCache_l338 = '1' then
        lineLoader_flushCounter <= (lineLoader_flushCounter + pkg_unsigned("00000001"));
      end if;
      zz_when_InstructionCache_l342 <= pkg_extract(lineLoader_flushCounter,7);
      if when_InstructionCache_l351 = '1' then
        lineLoader_flushCounter <= pkg_unsigned("00000000");
      end if;
      if when_InstructionCache_l435 = '1' then
        io_cpu_fetch_data_regNextWhen <= io_cpu_fetch_data_read_buffer;
      end if;
      if when_InstructionCache_l459 = '1' then
        decodeStage_mmuRsp_physicalAddress <= io_cpu_fetch_mmuRsp_physicalAddress;
        decodeStage_mmuRsp_isIoAccess <= io_cpu_fetch_mmuRsp_isIoAccess;
        decodeStage_mmuRsp_isPaging <= io_cpu_fetch_mmuRsp_isPaging;
        decodeStage_mmuRsp_allowRead <= io_cpu_fetch_mmuRsp_allowRead;
        decodeStage_mmuRsp_allowWrite <= io_cpu_fetch_mmuRsp_allowWrite;
        decodeStage_mmuRsp_allowExecute <= io_cpu_fetch_mmuRsp_allowExecute;
        decodeStage_mmuRsp_exception <= io_cpu_fetch_mmuRsp_exception;
        decodeStage_mmuRsp_refilling <= io_cpu_fetch_mmuRsp_refilling;
        decodeStage_mmuRsp_bypassTranslation <= io_cpu_fetch_mmuRsp_bypassTranslation;
      end if;
      if when_InstructionCache_l459_1 = '1' then
        decodeStage_hit_valid <= fetchStage_hit_valid;
      end if;
      if when_InstructionCache_l459_2 = '1' then
        decodeStage_hit_error <= fetchStage_hit_error;
      end if;
    end if;
  end process;

end arch;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.pkg_scala2hdl.all;
use work.all;
use work.pkg_enum.all;


entity DataCache is
  port(
    io_cpu_execute_isValid : in std_logic;
    io_cpu_execute_address : in unsigned(31 downto 0);
    io_cpu_execute_haltIt : out std_logic;
    io_cpu_execute_args_wr : in std_logic;
    io_cpu_execute_args_size : in unsigned(1 downto 0);
    io_cpu_execute_args_totalyConsistent : in std_logic;
    io_cpu_execute_refilling : out std_logic;
    io_cpu_memory_isValid : in std_logic;
    io_cpu_memory_isStuck : in std_logic;
    io_cpu_memory_isWrite : out std_logic;
    io_cpu_memory_address : in unsigned(31 downto 0);
    io_cpu_memory_mmuRsp_physicalAddress : in unsigned(31 downto 0);
    io_cpu_memory_mmuRsp_isIoAccess : in std_logic;
    io_cpu_memory_mmuRsp_isPaging : in std_logic;
    io_cpu_memory_mmuRsp_allowRead : in std_logic;
    io_cpu_memory_mmuRsp_allowWrite : in std_logic;
    io_cpu_memory_mmuRsp_allowExecute : in std_logic;
    io_cpu_memory_mmuRsp_exception : in std_logic;
    io_cpu_memory_mmuRsp_refilling : in std_logic;
    io_cpu_memory_mmuRsp_bypassTranslation : in std_logic;
    io_cpu_writeBack_isValid : in std_logic;
    io_cpu_writeBack_isStuck : in std_logic;
    io_cpu_writeBack_isFiring : in std_logic;
    io_cpu_writeBack_isUser : in std_logic;
    io_cpu_writeBack_haltIt : out std_logic;
    io_cpu_writeBack_isWrite : out std_logic;
    io_cpu_writeBack_storeData : in std_logic_vector(31 downto 0);
    io_cpu_writeBack_data : out std_logic_vector(31 downto 0);
    io_cpu_writeBack_address : in unsigned(31 downto 0);
    io_cpu_writeBack_mmuException : out std_logic;
    io_cpu_writeBack_unalignedAccess : out std_logic;
    io_cpu_writeBack_accessError : out std_logic;
    io_cpu_writeBack_keepMemRspData : out std_logic;
    io_cpu_writeBack_fence_SW : in std_logic;
    io_cpu_writeBack_fence_SR : in std_logic;
    io_cpu_writeBack_fence_SO : in std_logic;
    io_cpu_writeBack_fence_SI : in std_logic;
    io_cpu_writeBack_fence_PW : in std_logic;
    io_cpu_writeBack_fence_PR : in std_logic;
    io_cpu_writeBack_fence_PO : in std_logic;
    io_cpu_writeBack_fence_PI : in std_logic;
    io_cpu_writeBack_fence_FM : in std_logic_vector(3 downto 0);
    io_cpu_writeBack_exclusiveOk : out std_logic;
    io_cpu_redo : out std_logic;
    io_cpu_flush_valid : in std_logic;
    io_cpu_flush_ready : out std_logic;
    io_cpu_flush_payload_singleLine : in std_logic;
    io_cpu_flush_payload_lineId : in unsigned(7 downto 0);
    io_cpu_writesPending : out std_logic;
    io_mem_cmd_valid : out std_logic;
    io_mem_cmd_ready : in std_logic;
    io_mem_cmd_payload_wr : out std_logic;
    io_mem_cmd_payload_uncached : out std_logic;
    io_mem_cmd_payload_address : out unsigned(31 downto 0);
    io_mem_cmd_payload_data : out std_logic_vector(31 downto 0);
    io_mem_cmd_payload_mask : out std_logic_vector(3 downto 0);
    io_mem_cmd_payload_size : out unsigned(2 downto 0);
    io_mem_cmd_payload_last : out std_logic;
    io_mem_rsp_valid : in std_logic;
    io_mem_rsp_payload_last : in std_logic;
    io_mem_rsp_payload_data : in std_logic_vector(31 downto 0);
    io_mem_rsp_payload_error : in std_logic;
    io_mainClk : in std_logic;
    resetCtrl_systemReset : in std_logic
  );
end DataCache;

architecture arch of DataCache is
  signal zz_ways_0_tags_port0 : std_logic_vector(20 downto 0);
  signal zz_ways_0_data_port0 : std_logic_vector(31 downto 0);
  signal io_mem_cmd_valid_read_buffer : std_logic;
  signal io_cpu_flush_ready_read_buffer : std_logic;
  signal io_cpu_redo_read_buffer : std_logic;
  signal io_cpu_writeBack_accessError_read_buffer : std_logic;
  signal io_cpu_writeBack_mmuException_read_buffer : std_logic;
  signal io_cpu_writeBack_unalignedAccess_read_buffer : std_logic;
  signal io_cpu_writeBack_haltIt_read_buffer : std_logic;
  signal zz_ways_0_tags_port : std_logic_vector(20 downto 0);

  signal zz_1 : std_logic;
  signal zz_2 : std_logic;
  signal haltCpu : std_logic;
  signal tagsReadCmd_valid : std_logic;
  signal tagsReadCmd_payload : unsigned(7 downto 0);
  signal tagsWriteCmd_valid : std_logic;
  signal tagsWriteCmd_payload_way : std_logic_vector(0 downto 0);
  signal tagsWriteCmd_payload_address : unsigned(7 downto 0);
  signal tagsWriteCmd_payload_data_valid : std_logic;
  signal tagsWriteCmd_payload_data_error : std_logic;
  signal tagsWriteCmd_payload_data_address : unsigned(18 downto 0);
  signal tagsWriteLastCmd_valid : std_logic;
  signal tagsWriteLastCmd_payload_way : std_logic_vector(0 downto 0);
  signal tagsWriteLastCmd_payload_address : unsigned(7 downto 0);
  signal tagsWriteLastCmd_payload_data_valid : std_logic;
  signal tagsWriteLastCmd_payload_data_error : std_logic;
  signal tagsWriteLastCmd_payload_data_address : unsigned(18 downto 0);
  signal dataReadCmd_valid : std_logic;
  signal dataReadCmd_payload : unsigned(10 downto 0);
  signal dataWriteCmd_valid : std_logic;
  signal dataWriteCmd_payload_way : std_logic_vector(0 downto 0);
  signal dataWriteCmd_payload_address : unsigned(10 downto 0);
  signal dataWriteCmd_payload_data : std_logic_vector(31 downto 0);
  signal dataWriteCmd_payload_mask : std_logic_vector(3 downto 0);
  signal zz_ways_0_tagsReadRsp_valid : std_logic;
  signal ways_0_tagsReadRsp_valid : std_logic;
  signal ways_0_tagsReadRsp_error : std_logic;
  signal ways_0_tagsReadRsp_address : unsigned(18 downto 0);
  signal zz_ways_0_tagsReadRsp_valid_1 : std_logic_vector(20 downto 0);
  signal zz_ways_0_dataReadRspMem : std_logic;
  signal ways_0_dataReadRspMem : std_logic_vector(31 downto 0);
  signal ways_0_dataReadRsp : std_logic_vector(31 downto 0);
  signal when_DataCache_l645 : std_logic;
  signal when_DataCache_l648 : std_logic;
  signal when_DataCache_l667 : std_logic;
  signal rspSync : std_logic;
  signal rspLast : std_logic;
  signal memCmdSent : std_logic;
  signal io_mem_cmd_fire : std_logic;
  signal when_DataCache_l689 : std_logic;
  signal zz_stage0_mask : std_logic_vector(3 downto 0);
  signal stage0_mask : std_logic_vector(3 downto 0);
  signal stage0_dataColisions : std_logic_vector(0 downto 0);
  signal stage0_wayInvalidate : std_logic_vector(0 downto 0);
  signal stage0_isAmo : std_logic;
  signal when_DataCache_l776 : std_logic;
  signal stageA_request_wr : std_logic;
  signal stageA_request_size : unsigned(1 downto 0);
  signal stageA_request_totalyConsistent : std_logic;
  signal when_DataCache_l776_1 : std_logic;
  signal stageA_mask : std_logic_vector(3 downto 0);
  signal stageA_isAmo : std_logic;
  signal stageA_isLrsc : std_logic;
  signal stageA_wayHits : std_logic_vector(0 downto 0);
  signal when_DataCache_l776_2 : std_logic;
  signal stageA_wayInvalidate : std_logic_vector(0 downto 0);
  signal when_DataCache_l776_3 : std_logic;
  signal stage0_dataColisions_regNextWhen : std_logic_vector(0 downto 0);
  signal zz_stageA_dataColisions : std_logic_vector(0 downto 0);
  signal stageA_dataColisions : std_logic_vector(0 downto 0);
  signal when_DataCache_l827 : std_logic;
  signal stageB_request_wr : std_logic;
  signal stageB_request_size : unsigned(1 downto 0);
  signal stageB_request_totalyConsistent : std_logic;
  signal stageB_mmuRspFreeze : std_logic;
  signal when_DataCache_l829 : std_logic;
  signal stageB_mmuRsp_physicalAddress : unsigned(31 downto 0);
  signal stageB_mmuRsp_isIoAccess : std_logic;
  signal stageB_mmuRsp_isPaging : std_logic;
  signal stageB_mmuRsp_allowRead : std_logic;
  signal stageB_mmuRsp_allowWrite : std_logic;
  signal stageB_mmuRsp_allowExecute : std_logic;
  signal stageB_mmuRsp_exception : std_logic;
  signal stageB_mmuRsp_refilling : std_logic;
  signal stageB_mmuRsp_bypassTranslation : std_logic;
  signal when_DataCache_l826 : std_logic;
  signal stageB_tagsReadRsp_0_valid : std_logic;
  signal stageB_tagsReadRsp_0_error : std_logic;
  signal stageB_tagsReadRsp_0_address : unsigned(18 downto 0);
  signal when_DataCache_l826_1 : std_logic;
  signal stageB_dataReadRsp_0 : std_logic_vector(31 downto 0);
  signal when_DataCache_l825 : std_logic;
  signal stageB_wayInvalidate : std_logic_vector(0 downto 0);
  signal stageB_consistancyHazard : std_logic;
  signal when_DataCache_l825_1 : std_logic;
  signal stageB_dataColisions : std_logic_vector(0 downto 0);
  signal when_DataCache_l825_2 : std_logic;
  signal stageB_unaligned : std_logic;
  signal when_DataCache_l825_3 : std_logic;
  signal stageB_waysHitsBeforeInvalidate : std_logic_vector(0 downto 0);
  signal stageB_waysHits : std_logic_vector(0 downto 0);
  signal stageB_waysHit : std_logic;
  signal stageB_dataMux : std_logic_vector(31 downto 0);
  signal when_DataCache_l825_4 : std_logic;
  signal stageB_mask : std_logic_vector(3 downto 0);
  signal stageB_loaderValid : std_logic;
  signal stageB_ioMemRspMuxed : std_logic_vector(31 downto 0);
  signal stageB_flusher_waitDone : std_logic;
  signal stageB_flusher_hold : std_logic;
  signal stageB_flusher_counter : unsigned(8 downto 0);
  signal when_DataCache_l855 : std_logic;
  signal when_DataCache_l861 : std_logic;
  signal when_DataCache_l863 : std_logic;
  signal stageB_flusher_start : std_logic;
  signal when_DataCache_l877 : std_logic;
  signal stageB_isAmo : std_logic;
  signal stageB_isAmoCached : std_logic;
  signal stageB_isExternalLsrc : std_logic;
  signal stageB_isExternalAmo : std_logic;
  signal stageB_requestDataBypass : std_logic_vector(31 downto 0);
  signal stageB_cpuWriteToCache : std_logic;
  signal when_DataCache_l931 : std_logic;
  signal stageB_badPermissions : std_logic;
  signal stageB_loadStoreFault : std_logic;
  signal stageB_bypassCache : std_logic;
  signal when_DataCache_l1000 : std_logic;
  signal when_DataCache_l1009 : std_logic;
  signal when_DataCache_l1014 : std_logic;
  signal when_DataCache_l1025 : std_logic;
  signal when_DataCache_l1037 : std_logic;
  signal when_DataCache_l996 : std_logic;
  signal when_DataCache_l1072 : std_logic;
  signal when_DataCache_l1081 : std_logic;
  signal loader_valid : std_logic;
  signal loader_counter_willIncrement : std_logic;
  signal loader_counter_willClear : std_logic;
  signal loader_counter_valueNext : unsigned(2 downto 0);
  signal loader_counter_value : unsigned(2 downto 0);
  signal loader_counter_willOverflowIfInc : std_logic;
  signal loader_counter_willOverflow : std_logic;
  signal loader_waysAllocator : std_logic_vector(0 downto 0);
  signal loader_error : std_logic;
  signal loader_kill : std_logic;
  signal loader_killReg : std_logic;
  signal when_DataCache_l1097 : std_logic;
  signal loader_done : std_logic;
  signal when_DataCache_l1125 : std_logic;
  signal loader_valid_regNext : std_logic;
  signal when_DataCache_l1129 : std_logic;
  signal when_DataCache_l1132 : std_logic;
  type ways_0_tags_type is array (0 to 255) of std_logic_vector(20 downto 0);
  signal ways_0_tags : ways_0_tags_type;
  type ways_0_data_type is array (0 to 2047) of std_logic_vector(7 downto 0);
  signal ways_0_data_symbol0 : ways_0_data_type;
  signal ways_0_data_symbol1 : ways_0_data_type;
  signal ways_0_data_symbol2 : ways_0_data_type;
  signal ways_0_data_symbol3 : ways_0_data_type;
  signal zz_7 : std_logic_vector(7 downto 0);
  signal zz_8 : std_logic_vector(7 downto 0);
  signal zz_9 : std_logic_vector(7 downto 0);
  signal zz_10 : std_logic_vector(7 downto 0);
begin
  io_mem_cmd_valid <= io_mem_cmd_valid_read_buffer;
  io_cpu_flush_ready <= io_cpu_flush_ready_read_buffer;
  io_cpu_redo <= io_cpu_redo_read_buffer;
  io_cpu_writeBack_accessError <= io_cpu_writeBack_accessError_read_buffer;
  io_cpu_writeBack_mmuException <= io_cpu_writeBack_mmuException_read_buffer;
  io_cpu_writeBack_unalignedAccess <= io_cpu_writeBack_unalignedAccess_read_buffer;
  io_cpu_writeBack_haltIt <= io_cpu_writeBack_haltIt_read_buffer;
  zz_ways_0_tags_port <= pkg_cat(std_logic_vector(tagsWriteCmd_payload_data_address),pkg_cat(pkg_toStdLogicVector(tagsWriteCmd_payload_data_error),pkg_toStdLogicVector(tagsWriteCmd_payload_data_valid)));
  process(io_mainClk)
  begin
    if rising_edge(io_mainClk) then
      if zz_ways_0_tagsReadRsp_valid = '1' then
        zz_ways_0_tags_port0 <= ways_0_tags(to_integer(tagsReadCmd_payload));
      end if;
    end if;
  end process;

  process(io_mainClk)
  begin
    if rising_edge(io_mainClk) then
      if zz_2 = '1' then
        ways_0_tags(to_integer(tagsWriteCmd_payload_address)) <= zz_ways_0_tags_port;
      end if;
    end if;
  end process;

  process (zz_7, zz_8, zz_9, zz_10)
  begin
    zz_ways_0_data_port0 <= zz_10 & zz_9 & zz_8 & zz_7;
  end process;
  process(io_mainClk)
  begin
    if rising_edge(io_mainClk) then
      if zz_ways_0_dataReadRspMem = '1' then
        zz_7 <= ways_0_data_symbol0(to_integer(dataReadCmd_payload));
        zz_8 <= ways_0_data_symbol1(to_integer(dataReadCmd_payload));
        zz_9 <= ways_0_data_symbol2(to_integer(dataReadCmd_payload));
        zz_10 <= ways_0_data_symbol3(to_integer(dataReadCmd_payload));
      end if;
    end if;
  end process;

  process(io_mainClk)
  begin
    if rising_edge(io_mainClk) then
      if dataWriteCmd_payload_mask(0) = '1' and zz_1 = '1' then
        ways_0_data_symbol0(to_integer(dataWriteCmd_payload_address)) <= dataWriteCmd_payload_data(7 downto 0);
      end if;
      if dataWriteCmd_payload_mask(1) = '1' and zz_1 = '1' then
        ways_0_data_symbol1(to_integer(dataWriteCmd_payload_address)) <= dataWriteCmd_payload_data(15 downto 8);
      end if;
      if dataWriteCmd_payload_mask(2) = '1' and zz_1 = '1' then
        ways_0_data_symbol2(to_integer(dataWriteCmd_payload_address)) <= dataWriteCmd_payload_data(23 downto 16);
      end if;
      if dataWriteCmd_payload_mask(3) = '1' and zz_1 = '1' then
        ways_0_data_symbol3(to_integer(dataWriteCmd_payload_address)) <= dataWriteCmd_payload_data(31 downto 24);
      end if;
    end if;
  end process;

  process(when_DataCache_l648)
  begin
    zz_1 <= pkg_toStdLogic(false);
    if when_DataCache_l648 = '1' then
      zz_1 <= pkg_toStdLogic(true);
    end if;
  end process;

  process(when_DataCache_l645)
  begin
    zz_2 <= pkg_toStdLogic(false);
    if when_DataCache_l645 = '1' then
      zz_2 <= pkg_toStdLogic(true);
    end if;
  end process;

  haltCpu <= pkg_toStdLogic(false);
  zz_ways_0_tagsReadRsp_valid <= (tagsReadCmd_valid and (not io_cpu_memory_isStuck));
  zz_ways_0_tagsReadRsp_valid_1 <= zz_ways_0_tags_port0;
  ways_0_tagsReadRsp_valid <= pkg_extract(zz_ways_0_tagsReadRsp_valid_1,0);
  ways_0_tagsReadRsp_error <= pkg_extract(zz_ways_0_tagsReadRsp_valid_1,1);
  ways_0_tagsReadRsp_address <= unsigned(pkg_extract(zz_ways_0_tagsReadRsp_valid_1,20,2));
  zz_ways_0_dataReadRspMem <= (dataReadCmd_valid and (not io_cpu_memory_isStuck));
  ways_0_dataReadRspMem <= zz_ways_0_data_port0;
  ways_0_dataReadRsp <= pkg_extract(ways_0_dataReadRspMem,31,0);
  when_DataCache_l645 <= (tagsWriteCmd_valid and pkg_extract(tagsWriteCmd_payload_way,0));
  when_DataCache_l648 <= (dataWriteCmd_valid and pkg_extract(dataWriteCmd_payload_way,0));
  process(when_DataCache_l667)
  begin
    tagsReadCmd_valid <= pkg_toStdLogic(false);
    if when_DataCache_l667 = '1' then
      tagsReadCmd_valid <= pkg_toStdLogic(true);
    end if;
  end process;

  process(when_DataCache_l667,io_cpu_execute_address)
  begin
    tagsReadCmd_payload <= pkg_unsigned("XXXXXXXX");
    if when_DataCache_l667 = '1' then
      tagsReadCmd_payload <= pkg_extract(io_cpu_execute_address,12,5);
    end if;
  end process;

  process(when_DataCache_l667)
  begin
    dataReadCmd_valid <= pkg_toStdLogic(false);
    if when_DataCache_l667 = '1' then
      dataReadCmd_valid <= pkg_toStdLogic(true);
    end if;
  end process;

  process(when_DataCache_l667,io_cpu_execute_address)
  begin
    dataReadCmd_payload <= pkg_unsigned("XXXXXXXXXXX");
    if when_DataCache_l667 = '1' then
      dataReadCmd_payload <= pkg_extract(io_cpu_execute_address,12,2);
    end if;
  end process;

  process(when_DataCache_l855,io_cpu_writeBack_isValid,when_DataCache_l1072,loader_done)
  begin
    tagsWriteCmd_valid <= pkg_toStdLogic(false);
    if when_DataCache_l855 = '1' then
      tagsWriteCmd_valid <= pkg_toStdLogic(true);
    end if;
    if io_cpu_writeBack_isValid = '1' then
      if when_DataCache_l1072 = '1' then
        tagsWriteCmd_valid <= pkg_toStdLogic(false);
      end if;
    end if;
    if loader_done = '1' then
      tagsWriteCmd_valid <= pkg_toStdLogic(true);
    end if;
  end process;

  process(when_DataCache_l855,loader_done,loader_waysAllocator)
  begin
    tagsWriteCmd_payload_way <= pkg_stdLogicVector("X");
    if when_DataCache_l855 = '1' then
      tagsWriteCmd_payload_way <= pkg_stdLogicVector("1");
    end if;
    if loader_done = '1' then
      tagsWriteCmd_payload_way <= loader_waysAllocator;
    end if;
  end process;

  process(when_DataCache_l855,stageB_flusher_counter,loader_done,stageB_mmuRsp_physicalAddress)
  begin
    tagsWriteCmd_payload_address <= pkg_unsigned("XXXXXXXX");
    if when_DataCache_l855 = '1' then
      tagsWriteCmd_payload_address <= pkg_resize(stageB_flusher_counter,8);
    end if;
    if loader_done = '1' then
      tagsWriteCmd_payload_address <= pkg_extract(stageB_mmuRsp_physicalAddress,12,5);
    end if;
  end process;

  process(when_DataCache_l855,loader_done,loader_kill,loader_killReg)
  begin
    tagsWriteCmd_payload_data_valid <= 'X';
    if when_DataCache_l855 = '1' then
      tagsWriteCmd_payload_data_valid <= pkg_toStdLogic(false);
    end if;
    if loader_done = '1' then
      tagsWriteCmd_payload_data_valid <= (not (loader_kill or loader_killReg));
    end if;
  end process;

  process(loader_done,loader_error,io_mem_rsp_valid,io_mem_rsp_payload_error)
  begin
    tagsWriteCmd_payload_data_error <= 'X';
    if loader_done = '1' then
      tagsWriteCmd_payload_data_error <= (loader_error or (io_mem_rsp_valid and io_mem_rsp_payload_error));
    end if;
  end process;

  process(loader_done,stageB_mmuRsp_physicalAddress)
  begin
    tagsWriteCmd_payload_data_address <= pkg_unsigned("XXXXXXXXXXXXXXXXXXX");
    if loader_done = '1' then
      tagsWriteCmd_payload_data_address <= pkg_extract(stageB_mmuRsp_physicalAddress,31,13);
    end if;
  end process;

  process(stageB_cpuWriteToCache,when_DataCache_l931,io_cpu_writeBack_isValid,when_DataCache_l1072,when_DataCache_l1097)
  begin
    dataWriteCmd_valid <= pkg_toStdLogic(false);
    if stageB_cpuWriteToCache = '1' then
      if when_DataCache_l931 = '1' then
        dataWriteCmd_valid <= pkg_toStdLogic(true);
      end if;
    end if;
    if io_cpu_writeBack_isValid = '1' then
      if when_DataCache_l1072 = '1' then
        dataWriteCmd_valid <= pkg_toStdLogic(false);
      end if;
    end if;
    if when_DataCache_l1097 = '1' then
      dataWriteCmd_valid <= pkg_toStdLogic(true);
    end if;
  end process;

  process(stageB_cpuWriteToCache,stageB_waysHits,when_DataCache_l1097,loader_waysAllocator)
  begin
    dataWriteCmd_payload_way <= pkg_stdLogicVector("X");
    if stageB_cpuWriteToCache = '1' then
      dataWriteCmd_payload_way <= stageB_waysHits;
    end if;
    if when_DataCache_l1097 = '1' then
      dataWriteCmd_payload_way <= loader_waysAllocator;
    end if;
  end process;

  process(stageB_cpuWriteToCache,stageB_mmuRsp_physicalAddress,when_DataCache_l1097,loader_counter_value)
  begin
    dataWriteCmd_payload_address <= pkg_unsigned("XXXXXXXXXXX");
    if stageB_cpuWriteToCache = '1' then
      dataWriteCmd_payload_address <= pkg_extract(stageB_mmuRsp_physicalAddress,12,2);
    end if;
    if when_DataCache_l1097 = '1' then
      dataWriteCmd_payload_address <= unsigned(pkg_cat(std_logic_vector(pkg_extract(stageB_mmuRsp_physicalAddress,12,5)),std_logic_vector(loader_counter_value)));
    end if;
  end process;

  process(stageB_cpuWriteToCache,stageB_requestDataBypass,when_DataCache_l1097,io_mem_rsp_payload_data)
  begin
    dataWriteCmd_payload_data <= pkg_stdLogicVector("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX");
    if stageB_cpuWriteToCache = '1' then
      dataWriteCmd_payload_data(31 downto 0) <= stageB_requestDataBypass;
    end if;
    if when_DataCache_l1097 = '1' then
      dataWriteCmd_payload_data <= io_mem_rsp_payload_data;
    end if;
  end process;

  process(stageB_cpuWriteToCache,stageB_mask,when_DataCache_l1097)
  begin
    dataWriteCmd_payload_mask <= pkg_stdLogicVector("XXXX");
    if stageB_cpuWriteToCache = '1' then
      dataWriteCmd_payload_mask <= pkg_stdLogicVector("0000");
      if pkg_extract(pkg_unsigned("1"),0) = '1' then
        dataWriteCmd_payload_mask(3 downto 0) <= stageB_mask;
      end if;
    end if;
    if when_DataCache_l1097 = '1' then
      dataWriteCmd_payload_mask <= pkg_stdLogicVector("1111");
    end if;
  end process;

  when_DataCache_l667 <= (io_cpu_execute_isValid and (not io_cpu_memory_isStuck));
  process(when_DataCache_l855)
  begin
    io_cpu_execute_haltIt <= pkg_toStdLogic(false);
    if when_DataCache_l855 = '1' then
      io_cpu_execute_haltIt <= pkg_toStdLogic(true);
    end if;
  end process;

  rspSync <= pkg_toStdLogic(true);
  rspLast <= pkg_toStdLogic(true);
  io_mem_cmd_fire <= (io_mem_cmd_valid_read_buffer and io_mem_cmd_ready);
  when_DataCache_l689 <= (not io_cpu_writeBack_isStuck);
  process(io_cpu_execute_args_size)
  begin
    zz_stage0_mask <= pkg_stdLogicVector("XXXX");
    case io_cpu_execute_args_size is
      when "00" =>
        zz_stage0_mask <= pkg_stdLogicVector("0001");
      when "01" =>
        zz_stage0_mask <= pkg_stdLogicVector("0011");
      when "10" =>
        zz_stage0_mask <= pkg_stdLogicVector("1111");
      when others =>
    end case;
  end process;

  stage0_mask <= std_logic_vector(shift_left(unsigned(zz_stage0_mask),to_integer(pkg_extract(io_cpu_execute_address,1,0))));
  stage0_dataColisions(0) <= (((dataWriteCmd_valid and pkg_extract(dataWriteCmd_payload_way,0)) and pkg_toStdLogic(dataWriteCmd_payload_address = pkg_extract(io_cpu_execute_address,12,2))) and pkg_toStdLogic((stage0_mask and pkg_extract(dataWriteCmd_payload_mask,3,0)) /= pkg_stdLogicVector("0000")));
  stage0_wayInvalidate <= pkg_stdLogicVector("0");
  stage0_isAmo <= pkg_toStdLogic(false);
  when_DataCache_l776 <= (not io_cpu_memory_isStuck);
  when_DataCache_l776_1 <= (not io_cpu_memory_isStuck);
  io_cpu_memory_isWrite <= stageA_request_wr;
  stageA_isAmo <= pkg_toStdLogic(false);
  stageA_isLrsc <= pkg_toStdLogic(false);
  stageA_wayHits <= pkg_toStdLogicVector((pkg_toStdLogic(pkg_extract(io_cpu_memory_mmuRsp_physicalAddress,31,13) = ways_0_tagsReadRsp_address) and ways_0_tagsReadRsp_valid));
  when_DataCache_l776_2 <= (not io_cpu_memory_isStuck);
  when_DataCache_l776_3 <= (not io_cpu_memory_isStuck);
  zz_stageA_dataColisions(0) <= (((dataWriteCmd_valid and pkg_extract(dataWriteCmd_payload_way,0)) and pkg_toStdLogic(dataWriteCmd_payload_address = pkg_extract(io_cpu_memory_address,12,2))) and pkg_toStdLogic((stageA_mask and pkg_extract(dataWriteCmd_payload_mask,3,0)) /= pkg_stdLogicVector("0000")));
  stageA_dataColisions <= (stage0_dataColisions_regNextWhen or zz_stageA_dataColisions);
  when_DataCache_l827 <= (not io_cpu_writeBack_isStuck);
  process(when_DataCache_l1132)
  begin
    stageB_mmuRspFreeze <= pkg_toStdLogic(false);
    if when_DataCache_l1132 = '1' then
      stageB_mmuRspFreeze <= pkg_toStdLogic(true);
    end if;
  end process;

  when_DataCache_l829 <= ((not io_cpu_writeBack_isStuck) and (not stageB_mmuRspFreeze));
  when_DataCache_l826 <= (not io_cpu_writeBack_isStuck);
  when_DataCache_l826_1 <= (not io_cpu_writeBack_isStuck);
  when_DataCache_l825 <= (not io_cpu_writeBack_isStuck);
  stageB_consistancyHazard <= pkg_toStdLogic(false);
  when_DataCache_l825_1 <= (not io_cpu_writeBack_isStuck);
  when_DataCache_l825_2 <= (not io_cpu_writeBack_isStuck);
  when_DataCache_l825_3 <= (not io_cpu_writeBack_isStuck);
  stageB_waysHits <= (stageB_waysHitsBeforeInvalidate and pkg_not(stageB_wayInvalidate));
  stageB_waysHit <= pkg_toStdLogic(stageB_waysHits /= pkg_stdLogicVector("0"));
  stageB_dataMux <= stageB_dataReadRsp_0;
  when_DataCache_l825_4 <= (not io_cpu_writeBack_isStuck);
  process(io_cpu_writeBack_isValid,stageB_isExternalAmo,when_DataCache_l996,when_DataCache_l1009,io_mem_cmd_ready,when_DataCache_l1072)
  begin
    stageB_loaderValid <= pkg_toStdLogic(false);
    if io_cpu_writeBack_isValid = '1' then
      if stageB_isExternalAmo = '0' then
        if when_DataCache_l996 = '0' then
          if when_DataCache_l1009 = '0' then
            if io_mem_cmd_ready = '1' then
              stageB_loaderValid <= pkg_toStdLogic(true);
            end if;
          end if;
        end if;
      end if;
    end if;
    if io_cpu_writeBack_isValid = '1' then
      if when_DataCache_l1072 = '1' then
        stageB_loaderValid <= pkg_toStdLogic(false);
      end if;
    end if;
  end process;

  stageB_ioMemRspMuxed <= pkg_extract(io_mem_rsp_payload_data,31,0);
  process(io_cpu_writeBack_isValid,stageB_isExternalAmo,when_DataCache_l996,when_DataCache_l1000,when_DataCache_l1009,when_DataCache_l1014,when_DataCache_l1072)
  begin
    io_cpu_writeBack_haltIt_read_buffer <= pkg_toStdLogic(true);
    if io_cpu_writeBack_isValid = '1' then
      if stageB_isExternalAmo = '0' then
        if when_DataCache_l996 = '1' then
          if when_DataCache_l1000 = '1' then
            io_cpu_writeBack_haltIt_read_buffer <= pkg_toStdLogic(false);
          end if;
        else
          if when_DataCache_l1009 = '1' then
            if when_DataCache_l1014 = '1' then
              io_cpu_writeBack_haltIt_read_buffer <= pkg_toStdLogic(false);
            end if;
          end if;
        end if;
      end if;
    end if;
    if io_cpu_writeBack_isValid = '1' then
      if when_DataCache_l1072 = '1' then
        io_cpu_writeBack_haltIt_read_buffer <= pkg_toStdLogic(false);
      end if;
    end if;
  end process;

  stageB_flusher_hold <= pkg_toStdLogic(false);
  when_DataCache_l855 <= (not pkg_extract(stageB_flusher_counter,8));
  when_DataCache_l861 <= (not stageB_flusher_hold);
  when_DataCache_l863 <= (io_cpu_flush_valid and io_cpu_flush_payload_singleLine);
  io_cpu_flush_ready_read_buffer <= (stageB_flusher_waitDone and pkg_extract(stageB_flusher_counter,8));
  when_DataCache_l877 <= (io_cpu_flush_valid and io_cpu_flush_payload_singleLine);
  stageB_isAmo <= pkg_toStdLogic(false);
  stageB_isAmoCached <= pkg_toStdLogic(false);
  stageB_isExternalLsrc <= pkg_toStdLogic(false);
  stageB_isExternalAmo <= pkg_toStdLogic(false);
  stageB_requestDataBypass <= io_cpu_writeBack_storeData;
  process(io_cpu_writeBack_isValid,stageB_isExternalAmo,when_DataCache_l996,when_DataCache_l1009)
  begin
    stageB_cpuWriteToCache <= pkg_toStdLogic(false);
    if io_cpu_writeBack_isValid = '1' then
      if stageB_isExternalAmo = '0' then
        if when_DataCache_l996 = '0' then
          if when_DataCache_l1009 = '1' then
            stageB_cpuWriteToCache <= pkg_toStdLogic(true);
          end if;
        end if;
      end if;
    end if;
  end process;

  when_DataCache_l931 <= (stageB_request_wr and stageB_waysHit);
  stageB_badPermissions <= (((not stageB_mmuRsp_allowWrite) and stageB_request_wr) or ((not stageB_mmuRsp_allowRead) and ((not stageB_request_wr) or stageB_isAmo)));
  stageB_loadStoreFault <= (io_cpu_writeBack_isValid and (stageB_mmuRsp_exception or stageB_badPermissions));
  process(io_cpu_writeBack_isValid,stageB_isExternalAmo,when_DataCache_l996,when_DataCache_l1009,when_DataCache_l1025,when_DataCache_l1081,when_DataCache_l1129)
  begin
    io_cpu_redo_read_buffer <= pkg_toStdLogic(false);
    if io_cpu_writeBack_isValid = '1' then
      if stageB_isExternalAmo = '0' then
        if when_DataCache_l996 = '0' then
          if when_DataCache_l1009 = '1' then
            if when_DataCache_l1025 = '1' then
              io_cpu_redo_read_buffer <= pkg_toStdLogic(true);
            end if;
          end if;
        end if;
      end if;
    end if;
    if io_cpu_writeBack_isValid = '1' then
      if when_DataCache_l1081 = '1' then
        io_cpu_redo_read_buffer <= pkg_toStdLogic(true);
      end if;
    end if;
    if when_DataCache_l1129 = '1' then
      io_cpu_redo_read_buffer <= pkg_toStdLogic(true);
    end if;
  end process;

  process(stageB_bypassCache,stageB_request_wr,io_mem_rsp_valid,io_mem_rsp_payload_error,stageB_waysHits,stageB_tagsReadRsp_0_error,stageB_loadStoreFault,stageB_mmuRsp_isPaging)
  begin
    io_cpu_writeBack_accessError_read_buffer <= pkg_toStdLogic(false);
    if stageB_bypassCache = '1' then
      io_cpu_writeBack_accessError_read_buffer <= ((((not stageB_request_wr) and pkg_toStdLogic(true)) and io_mem_rsp_valid) and io_mem_rsp_payload_error);
    else
      io_cpu_writeBack_accessError_read_buffer <= (pkg_toStdLogic((stageB_waysHits and pkg_toStdLogicVector(stageB_tagsReadRsp_0_error)) /= pkg_stdLogicVector("0")) or (stageB_loadStoreFault and (not stageB_mmuRsp_isPaging)));
    end if;
  end process;

  io_cpu_writeBack_mmuException_read_buffer <= (stageB_loadStoreFault and stageB_mmuRsp_isPaging);
  io_cpu_writeBack_unalignedAccess_read_buffer <= (io_cpu_writeBack_isValid and stageB_unaligned);
  io_cpu_writeBack_isWrite <= stageB_request_wr;
  process(io_cpu_writeBack_isValid,stageB_isExternalAmo,when_DataCache_l996,memCmdSent,when_DataCache_l1009,stageB_request_wr,when_DataCache_l1037,when_DataCache_l1072)
  begin
    io_mem_cmd_valid_read_buffer <= pkg_toStdLogic(false);
    if io_cpu_writeBack_isValid = '1' then
      if stageB_isExternalAmo = '0' then
        if when_DataCache_l996 = '1' then
          io_mem_cmd_valid_read_buffer <= (not memCmdSent);
        else
          if when_DataCache_l1009 = '1' then
            if stageB_request_wr = '1' then
              io_mem_cmd_valid_read_buffer <= pkg_toStdLogic(true);
            end if;
          else
            if when_DataCache_l1037 = '1' then
              io_mem_cmd_valid_read_buffer <= pkg_toStdLogic(true);
            end if;
          end if;
        end if;
      end if;
    end if;
    if io_cpu_writeBack_isValid = '1' then
      if when_DataCache_l1072 = '1' then
        io_mem_cmd_valid_read_buffer <= pkg_toStdLogic(false);
      end if;
    end if;
  end process;

  process(stageB_mmuRsp_physicalAddress,io_cpu_writeBack_isValid,stageB_isExternalAmo,when_DataCache_l996,when_DataCache_l1009)
  begin
    io_mem_cmd_payload_address <= stageB_mmuRsp_physicalAddress;
    if io_cpu_writeBack_isValid = '1' then
      if stageB_isExternalAmo = '0' then
        if when_DataCache_l996 = '0' then
          if when_DataCache_l1009 = '0' then
            io_mem_cmd_payload_address(4 downto 0) <= pkg_unsigned("00000");
          end if;
        end if;
      end if;
    end if;
  end process;

  io_mem_cmd_payload_last <= pkg_toStdLogic(true);
  process(stageB_request_wr,io_cpu_writeBack_isValid,stageB_isExternalAmo,when_DataCache_l996,when_DataCache_l1009)
  begin
    io_mem_cmd_payload_wr <= stageB_request_wr;
    if io_cpu_writeBack_isValid = '1' then
      if stageB_isExternalAmo = '0' then
        if when_DataCache_l996 = '0' then
          if when_DataCache_l1009 = '0' then
            io_mem_cmd_payload_wr <= pkg_toStdLogic(false);
          end if;
        end if;
      end if;
    end if;
  end process;

  io_mem_cmd_payload_mask <= stageB_mask;
  io_mem_cmd_payload_data <= stageB_requestDataBypass;
  io_mem_cmd_payload_uncached <= stageB_mmuRsp_isIoAccess;
  process(stageB_request_size,io_cpu_writeBack_isValid,stageB_isExternalAmo,when_DataCache_l996,when_DataCache_l1009)
  begin
    io_mem_cmd_payload_size <= pkg_resize(stageB_request_size,3);
    if io_cpu_writeBack_isValid = '1' then
      if stageB_isExternalAmo = '0' then
        if when_DataCache_l996 = '0' then
          if when_DataCache_l1009 = '0' then
            io_mem_cmd_payload_size <= pkg_unsigned("101");
          end if;
        end if;
      end if;
    end if;
  end process;

  stageB_bypassCache <= ((stageB_mmuRsp_isIoAccess or stageB_isExternalLsrc) or stageB_isExternalAmo);
  io_cpu_writeBack_keepMemRspData <= pkg_toStdLogic(false);
  when_DataCache_l1000 <= pkg_mux((not stageB_request_wr),(io_mem_rsp_valid and rspSync),io_mem_cmd_ready);
  when_DataCache_l1009 <= (stageB_waysHit or (stageB_request_wr and (not stageB_isAmoCached)));
  when_DataCache_l1014 <= ((not stageB_request_wr) or io_mem_cmd_ready);
  when_DataCache_l1025 <= (((not stageB_request_wr) or stageB_isAmoCached) and pkg_toStdLogic((stageB_dataColisions and stageB_waysHits) /= pkg_stdLogicVector("0")));
  when_DataCache_l1037 <= (not memCmdSent);
  when_DataCache_l996 <= (stageB_mmuRsp_isIoAccess or stageB_isExternalLsrc);
  process(stageB_bypassCache,stageB_ioMemRspMuxed,stageB_dataMux)
  begin
    if stageB_bypassCache = '1' then
      io_cpu_writeBack_data <= stageB_ioMemRspMuxed;
    else
      io_cpu_writeBack_data <= stageB_dataMux;
    end if;
  end process;

  when_DataCache_l1072 <= ((((stageB_consistancyHazard or stageB_mmuRsp_refilling) or io_cpu_writeBack_accessError_read_buffer) or io_cpu_writeBack_mmuException_read_buffer) or io_cpu_writeBack_unalignedAccess_read_buffer);
  when_DataCache_l1081 <= (stageB_mmuRsp_refilling or stageB_consistancyHazard);
  process(when_DataCache_l1097)
  begin
    loader_counter_willIncrement <= pkg_toStdLogic(false);
    if when_DataCache_l1097 = '1' then
      loader_counter_willIncrement <= pkg_toStdLogic(true);
    end if;
  end process;

  loader_counter_willClear <= pkg_toStdLogic(false);
  loader_counter_willOverflowIfInc <= pkg_toStdLogic(loader_counter_value = pkg_unsigned("111"));
  loader_counter_willOverflow <= (loader_counter_willOverflowIfInc and loader_counter_willIncrement);
  process(loader_counter_value,loader_counter_willIncrement,loader_counter_willClear)
  begin
    loader_counter_valueNext <= (loader_counter_value + pkg_resize(unsigned(pkg_toStdLogicVector(loader_counter_willIncrement)),3));
    if loader_counter_willClear = '1' then
      loader_counter_valueNext <= pkg_unsigned("000");
    end if;
  end process;

  loader_kill <= pkg_toStdLogic(false);
  when_DataCache_l1097 <= ((loader_valid and io_mem_rsp_valid) and rspLast);
  loader_done <= loader_counter_willOverflow;
  when_DataCache_l1125 <= (not loader_valid);
  when_DataCache_l1129 <= (loader_valid and (not loader_valid_regNext));
  io_cpu_execute_refilling <= loader_valid;
  when_DataCache_l1132 <= (stageB_loaderValid or loader_valid);
  process(io_mainClk)
  begin
    if rising_edge(io_mainClk) then
      tagsWriteLastCmd_valid <= tagsWriteCmd_valid;
      tagsWriteLastCmd_payload_way <= tagsWriteCmd_payload_way;
      tagsWriteLastCmd_payload_address <= tagsWriteCmd_payload_address;
      tagsWriteLastCmd_payload_data_valid <= tagsWriteCmd_payload_data_valid;
      tagsWriteLastCmd_payload_data_error <= tagsWriteCmd_payload_data_error;
      tagsWriteLastCmd_payload_data_address <= tagsWriteCmd_payload_data_address;
      if when_DataCache_l776 = '1' then
        stageA_request_wr <= io_cpu_execute_args_wr;
        stageA_request_size <= io_cpu_execute_args_size;
        stageA_request_totalyConsistent <= io_cpu_execute_args_totalyConsistent;
      end if;
      if when_DataCache_l776_1 = '1' then
        stageA_mask <= stage0_mask;
      end if;
      if when_DataCache_l776_2 = '1' then
        stageA_wayInvalidate <= stage0_wayInvalidate;
      end if;
      if when_DataCache_l776_3 = '1' then
        stage0_dataColisions_regNextWhen <= stage0_dataColisions;
      end if;
      if when_DataCache_l827 = '1' then
        stageB_request_wr <= stageA_request_wr;
        stageB_request_size <= stageA_request_size;
        stageB_request_totalyConsistent <= stageA_request_totalyConsistent;
      end if;
      if when_DataCache_l829 = '1' then
        stageB_mmuRsp_physicalAddress <= io_cpu_memory_mmuRsp_physicalAddress;
        stageB_mmuRsp_isIoAccess <= io_cpu_memory_mmuRsp_isIoAccess;
        stageB_mmuRsp_isPaging <= io_cpu_memory_mmuRsp_isPaging;
        stageB_mmuRsp_allowRead <= io_cpu_memory_mmuRsp_allowRead;
        stageB_mmuRsp_allowWrite <= io_cpu_memory_mmuRsp_allowWrite;
        stageB_mmuRsp_allowExecute <= io_cpu_memory_mmuRsp_allowExecute;
        stageB_mmuRsp_exception <= io_cpu_memory_mmuRsp_exception;
        stageB_mmuRsp_refilling <= io_cpu_memory_mmuRsp_refilling;
        stageB_mmuRsp_bypassTranslation <= io_cpu_memory_mmuRsp_bypassTranslation;
      end if;
      if when_DataCache_l826 = '1' then
        stageB_tagsReadRsp_0_valid <= ways_0_tagsReadRsp_valid;
        stageB_tagsReadRsp_0_error <= ways_0_tagsReadRsp_error;
        stageB_tagsReadRsp_0_address <= ways_0_tagsReadRsp_address;
      end if;
      if when_DataCache_l826_1 = '1' then
        stageB_dataReadRsp_0 <= ways_0_dataReadRsp;
      end if;
      if when_DataCache_l825 = '1' then
        stageB_wayInvalidate <= stageA_wayInvalidate;
      end if;
      if when_DataCache_l825_1 = '1' then
        stageB_dataColisions <= stageA_dataColisions;
      end if;
      if when_DataCache_l825_2 = '1' then
        stageB_unaligned <= pkg_toStdLogic(pkg_cat(pkg_toStdLogicVector((pkg_toStdLogic(stageA_request_size = pkg_unsigned("10")) and pkg_toStdLogic(pkg_extract(io_cpu_memory_address,1,0) /= pkg_unsigned("00")))),pkg_toStdLogicVector((pkg_toStdLogic(stageA_request_size = pkg_unsigned("01")) and pkg_toStdLogic(pkg_extract(io_cpu_memory_address,0,0) /= pkg_unsigned("0"))))) /= pkg_stdLogicVector("00"));
      end if;
      if when_DataCache_l825_3 = '1' then
        stageB_waysHitsBeforeInvalidate <= stageA_wayHits;
      end if;
      if when_DataCache_l825_4 = '1' then
        stageB_mask <= stageA_mask;
      end if;
      loader_valid_regNext <= loader_valid;
    end if;
  end process;

  process(io_mainClk, resetCtrl_systemReset)
  begin
    if resetCtrl_systemReset = '1' then
      memCmdSent <= pkg_toStdLogic(false);
      stageB_flusher_waitDone <= pkg_toStdLogic(false);
      stageB_flusher_counter <= pkg_unsigned("000000000");
      stageB_flusher_start <= pkg_toStdLogic(true);
      loader_valid <= pkg_toStdLogic(false);
      loader_counter_value <= pkg_unsigned("000");
      loader_waysAllocator <= pkg_stdLogicVector("1");
      loader_error <= pkg_toStdLogic(false);
      loader_killReg <= pkg_toStdLogic(false);
    elsif rising_edge(io_mainClk) then
      if io_mem_cmd_fire = '1' then
        memCmdSent <= pkg_toStdLogic(true);
      end if;
      if when_DataCache_l689 = '1' then
        memCmdSent <= pkg_toStdLogic(false);
      end if;
      if io_cpu_flush_ready_read_buffer = '1' then
        stageB_flusher_waitDone <= pkg_toStdLogic(false);
      end if;
      if when_DataCache_l855 = '1' then
        if when_DataCache_l861 = '1' then
          stageB_flusher_counter <= (stageB_flusher_counter + pkg_unsigned("000000001"));
          if when_DataCache_l863 = '1' then
            stageB_flusher_counter(8) <= pkg_toStdLogic(true);
          end if;
        end if;
      end if;
      stageB_flusher_start <= (((((((not stageB_flusher_waitDone) and (not stageB_flusher_start)) and io_cpu_flush_valid) and (not io_cpu_execute_isValid)) and (not io_cpu_memory_isValid)) and (not io_cpu_writeBack_isValid)) and (not io_cpu_redo_read_buffer));
      if stageB_flusher_start = '1' then
        stageB_flusher_waitDone <= pkg_toStdLogic(true);
        stageB_flusher_counter <= pkg_unsigned("000000000");
        if when_DataCache_l877 = '1' then
          stageB_flusher_counter <= unsigned(pkg_cat(std_logic_vector(pkg_unsigned("0")),std_logic_vector(io_cpu_flush_payload_lineId)));
        end if;
      end if;
      assert (not ((io_cpu_writeBack_isValid and (not io_cpu_writeBack_haltIt_read_buffer)) and io_cpu_writeBack_isStuck)) = '1' report "writeBack stuck by another plugin is not allowed"  severity ERROR;
      if stageB_loaderValid = '1' then
        loader_valid <= pkg_toStdLogic(true);
      end if;
      loader_counter_value <= loader_counter_valueNext;
      if loader_kill = '1' then
        loader_killReg <= pkg_toStdLogic(true);
      end if;
      if when_DataCache_l1097 = '1' then
        loader_error <= (loader_error or io_mem_rsp_payload_error);
      end if;
      if loader_done = '1' then
        loader_valid <= pkg_toStdLogic(false);
        loader_error <= pkg_toStdLogic(false);
        loader_killReg <= pkg_toStdLogic(false);
      end if;
      if when_DataCache_l1125 = '1' then
        loader_waysAllocator <= pkg_resize(pkg_cat(loader_waysAllocator,pkg_toStdLogicVector(pkg_extract(loader_waysAllocator,0))),1);
      end if;
    end if;
  end process;

end arch;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.pkg_scala2hdl.all;
use work.all;
use work.pkg_enum.all;


entity BufferCC is
  port(
    io_dataIn : in std_logic;
    io_dataOut : out std_logic;
    io_mainClk : in std_logic
  );
end BufferCC;

architecture arch of BufferCC is
  attribute async_reg : string;

  signal buffers_0 : std_logic;
  attribute async_reg of buffers_0 : signal is "true";
  signal buffers_1 : std_logic;
  attribute async_reg of buffers_1 : signal is "true";
begin
  io_dataOut <= buffers_1;
  process(io_mainClk)
  begin
    if rising_edge(io_mainClk) then
      buffers_0 <= io_dataIn;
      buffers_1 <= buffers_0;
    end if;
  end process;

end arch;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.pkg_scala2hdl.all;
use work.all;
use work.pkg_enum.all;


entity VexRiscv is
  port(
    dBus_cmd_valid : out std_logic;
    dBus_cmd_ready : in std_logic;
    dBus_cmd_payload_wr : out std_logic;
    dBus_cmd_payload_uncached : out std_logic;
    dBus_cmd_payload_address : out unsigned(31 downto 0);
    dBus_cmd_payload_data : out std_logic_vector(31 downto 0);
    dBus_cmd_payload_mask : out std_logic_vector(3 downto 0);
    dBus_cmd_payload_size : out unsigned(2 downto 0);
    dBus_cmd_payload_last : out std_logic;
    dBus_rsp_valid : in std_logic;
    dBus_rsp_payload_last : in std_logic;
    dBus_rsp_payload_data : in std_logic_vector(31 downto 0);
    dBus_rsp_payload_error : in std_logic;
    timerInterrupt : in std_logic;
    externalInterrupt : in std_logic;
    softwareInterrupt : in std_logic;
    iBus_cmd_valid : out std_logic;
    iBus_cmd_ready : in std_logic;
    iBus_cmd_payload_address : out unsigned(31 downto 0);
    iBus_cmd_payload_size : out unsigned(2 downto 0);
    iBus_rsp_valid : in std_logic;
    iBus_rsp_payload_data : in std_logic_vector(31 downto 0);
    iBus_rsp_payload_error : in std_logic;
    io_mainClk : in std_logic;
    resetCtrl_systemReset : in std_logic
  );
end VexRiscv;

architecture arch of VexRiscv is
  signal IBusCachedPlugin_cache_io_flush : std_logic;
  signal IBusCachedPlugin_cache_io_cpu_prefetch_isValid : std_logic;
  signal IBusCachedPlugin_cache_io_cpu_fetch_isValid : std_logic;
  signal IBusCachedPlugin_cache_io_cpu_fetch_isStuck : std_logic;
  signal IBusCachedPlugin_cache_io_cpu_fetch_isRemoved : std_logic;
  signal IBusCachedPlugin_cache_io_cpu_decode_isValid : std_logic;
  signal IBusCachedPlugin_cache_io_cpu_decode_isStuck : std_logic;
  signal IBusCachedPlugin_cache_io_cpu_decode_isUser : std_logic;
  signal IBusCachedPlugin_cache_io_cpu_fill_valid : std_logic;
  signal dataCache_1_io_cpu_execute_isValid : std_logic;
  signal dataCache_1_io_cpu_execute_address : unsigned(31 downto 0);
  signal dataCache_1_io_cpu_memory_isValid : std_logic;
  signal dataCache_1_io_cpu_memory_address : unsigned(31 downto 0);
  signal dataCache_1_io_cpu_memory_mmuRsp_isIoAccess : std_logic;
  signal dataCache_1_io_cpu_writeBack_isValid : std_logic;
  signal dataCache_1_io_cpu_writeBack_isUser : std_logic;
  signal dataCache_1_io_cpu_writeBack_storeData : std_logic_vector(31 downto 0);
  signal dataCache_1_io_cpu_writeBack_address : unsigned(31 downto 0);
  signal dataCache_1_io_cpu_writeBack_fence_SW : std_logic;
  signal dataCache_1_io_cpu_writeBack_fence_SR : std_logic;
  signal dataCache_1_io_cpu_writeBack_fence_SO : std_logic;
  signal dataCache_1_io_cpu_writeBack_fence_SI : std_logic;
  signal dataCache_1_io_cpu_writeBack_fence_PW : std_logic;
  signal dataCache_1_io_cpu_writeBack_fence_PR : std_logic;
  signal dataCache_1_io_cpu_writeBack_fence_PO : std_logic;
  signal dataCache_1_io_cpu_writeBack_fence_PI : std_logic;
  signal dataCache_1_io_cpu_writeBack_fence_FM : std_logic_vector(3 downto 0);
  signal dataCache_1_io_cpu_flush_valid : std_logic;
  signal dataCache_1_io_cpu_flush_payload_singleLine : std_logic;
  signal dataCache_1_io_cpu_flush_payload_lineId : unsigned(7 downto 0);
  signal zz_RegFilePlugin_regFile_port0 : std_logic_vector(31 downto 0);
  signal zz_RegFilePlugin_regFile_port0_1 : std_logic_vector(31 downto 0);
  signal IBusCachedPlugin_cache_io_cpu_prefetch_haltIt : std_logic;
  signal IBusCachedPlugin_cache_io_cpu_fetch_data : std_logic_vector(31 downto 0);
  signal IBusCachedPlugin_cache_io_cpu_fetch_physicalAddress : unsigned(31 downto 0);
  signal IBusCachedPlugin_cache_io_cpu_decode_error : std_logic;
  signal IBusCachedPlugin_cache_io_cpu_decode_mmuRefilling : std_logic;
  signal IBusCachedPlugin_cache_io_cpu_decode_mmuException : std_logic;
  signal IBusCachedPlugin_cache_io_cpu_decode_data : std_logic_vector(31 downto 0);
  signal IBusCachedPlugin_cache_io_cpu_decode_cacheMiss : std_logic;
  signal IBusCachedPlugin_cache_io_cpu_decode_physicalAddress : unsigned(31 downto 0);
  signal IBusCachedPlugin_cache_io_mem_cmd_valid : std_logic;
  signal IBusCachedPlugin_cache_io_mem_cmd_payload_address : unsigned(31 downto 0);
  signal IBusCachedPlugin_cache_io_mem_cmd_payload_size : unsigned(2 downto 0);
  signal dataCache_1_io_cpu_execute_haltIt : std_logic;
  signal dataCache_1_io_cpu_execute_refilling : std_logic;
  signal dataCache_1_io_cpu_memory_isWrite : std_logic;
  signal dataCache_1_io_cpu_writeBack_haltIt : std_logic;
  signal dataCache_1_io_cpu_writeBack_data : std_logic_vector(31 downto 0);
  signal dataCache_1_io_cpu_writeBack_mmuException : std_logic;
  signal dataCache_1_io_cpu_writeBack_unalignedAccess : std_logic;
  signal dataCache_1_io_cpu_writeBack_accessError : std_logic;
  signal dataCache_1_io_cpu_writeBack_isWrite : std_logic;
  signal dataCache_1_io_cpu_writeBack_keepMemRspData : std_logic;
  signal dataCache_1_io_cpu_writeBack_exclusiveOk : std_logic;
  signal dataCache_1_io_cpu_flush_ready : std_logic;
  signal dataCache_1_io_cpu_redo : std_logic;
  signal dataCache_1_io_cpu_writesPending : std_logic;
  signal dataCache_1_io_mem_cmd_valid : std_logic;
  signal dataCache_1_io_mem_cmd_payload_wr : std_logic;
  signal dataCache_1_io_mem_cmd_payload_uncached : std_logic;
  signal dataCache_1_io_mem_cmd_payload_address : unsigned(31 downto 0);
  signal dataCache_1_io_mem_cmd_payload_data : std_logic_vector(31 downto 0);
  signal dataCache_1_io_mem_cmd_payload_mask : std_logic_vector(3 downto 0);
  signal dataCache_1_io_mem_cmd_payload_size : unsigned(2 downto 0);
  signal dataCache_1_io_mem_cmd_payload_last : std_logic;
  signal zz_decode_LEGAL_INSTRUCTION : std_logic_vector(31 downto 0);
  signal zz_decode_LEGAL_INSTRUCTION_1 : std_logic_vector(31 downto 0);
  signal zz_decode_LEGAL_INSTRUCTION_2 : std_logic_vector(31 downto 0);
  signal zz_decode_LEGAL_INSTRUCTION_3 : std_logic;
  signal zz_decode_LEGAL_INSTRUCTION_4 : std_logic_vector(0 downto 0);
  signal zz_decode_LEGAL_INSTRUCTION_5 : std_logic_vector(11 downto 0);
  signal zz_decode_LEGAL_INSTRUCTION_6 : std_logic_vector(31 downto 0);
  signal zz_decode_LEGAL_INSTRUCTION_7 : std_logic_vector(31 downto 0);
  signal zz_decode_LEGAL_INSTRUCTION_8 : std_logic_vector(31 downto 0);
  signal zz_decode_LEGAL_INSTRUCTION_9 : std_logic;
  signal zz_decode_LEGAL_INSTRUCTION_10 : std_logic_vector(0 downto 0);
  signal zz_decode_LEGAL_INSTRUCTION_11 : std_logic_vector(5 downto 0);
  signal zz_decode_LEGAL_INSTRUCTION_12 : std_logic_vector(31 downto 0);
  signal zz_decode_LEGAL_INSTRUCTION_13 : std_logic_vector(31 downto 0);
  signal zz_decode_LEGAL_INSTRUCTION_14 : std_logic_vector(31 downto 0);
  signal zz_decode_LEGAL_INSTRUCTION_15 : std_logic;
  signal zz_decode_LEGAL_INSTRUCTION_16 : std_logic;
  signal zz_IBusCachedPlugin_jump_pcLoad_payload_5 : unsigned(31 downto 0);
  signal zz_IBusCachedPlugin_jump_pcLoad_payload_6 : unsigned(1 downto 0);
  signal zz_IBusCachedPlugin_predictionJumpInterface_payload_4 : std_logic;
  signal zz_IBusCachedPlugin_predictionJumpInterface_payload_5 : std_logic;
  signal zz_IBusCachedPlugin_predictionJumpInterface_payload_6 : std_logic;
  signal zz_writeBack_DBusCachedPlugin_rspShifted : std_logic_vector(7 downto 0);
  signal zz_writeBack_DBusCachedPlugin_rspShifted_1 : unsigned(1 downto 0);
  signal zz_writeBack_DBusCachedPlugin_rspShifted_2 : std_logic_vector(7 downto 0);
  signal zz_writeBack_DBusCachedPlugin_rspShifted_3 : unsigned(0 downto 0);
  signal zz_when : std_logic;
  signal zz_zz_decode_IS_RS2_SIGNED : std_logic_vector(31 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_1 : std_logic_vector(31 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_2 : std_logic_vector(31 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_3 : std_logic_vector(31 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_4 : std_logic_vector(0 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_5 : std_logic_vector(0 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_6 : std_logic;
  signal zz_zz_decode_IS_RS2_SIGNED_7 : std_logic_vector(0 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_8 : std_logic_vector(31 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_9 : std_logic_vector(24 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_10 : std_logic_vector(31 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_11 : std_logic_vector(31 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_12 : std_logic_vector(0 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_13 : std_logic_vector(31 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_14 : std_logic_vector(0 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_15 : std_logic_vector(31 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_16 : std_logic_vector(0 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_17 : std_logic_vector(31 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_18 : std_logic_vector(0 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_19 : std_logic;
  signal zz_zz_decode_IS_RS2_SIGNED_20 : std_logic_vector(31 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_21 : std_logic_vector(31 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_22 : std_logic_vector(0 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_23 : std_logic;
  signal zz_zz_decode_IS_RS2_SIGNED_24 : std_logic_vector(19 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_25 : std_logic_vector(1 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_26 : std_logic_vector(31 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_27 : std_logic_vector(31 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_28 : std_logic_vector(31 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_29 : std_logic_vector(31 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_30 : std_logic_vector(1 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_31 : std_logic;
  signal zz_zz_decode_IS_RS2_SIGNED_32 : std_logic_vector(31 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_33 : std_logic_vector(31 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_34 : std_logic_vector(0 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_35 : std_logic_vector(0 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_36 : std_logic_vector(31 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_37 : std_logic_vector(0 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_38 : std_logic_vector(31 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_39 : std_logic_vector(16 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_40 : std_logic_vector(0 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_41 : std_logic_vector(31 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_42 : std_logic_vector(0 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_43 : std_logic;
  signal zz_zz_decode_IS_RS2_SIGNED_44 : std_logic;
  signal zz_zz_decode_IS_RS2_SIGNED_45 : std_logic;
  signal zz_zz_decode_IS_RS2_SIGNED_46 : std_logic_vector(0 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_47 : std_logic_vector(0 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_48 : std_logic_vector(31 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_49 : std_logic_vector(1 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_50 : std_logic_vector(31 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_51 : std_logic_vector(31 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_52 : std_logic_vector(13 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_53 : std_logic_vector(0 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_54 : std_logic_vector(31 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_55 : std_logic_vector(0 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_56 : std_logic;
  signal zz_zz_decode_IS_RS2_SIGNED_57 : std_logic;
  signal zz_zz_decode_IS_RS2_SIGNED_58 : std_logic_vector(31 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_59 : std_logic_vector(0 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_60 : std_logic_vector(2 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_61 : std_logic;
  signal zz_zz_decode_IS_RS2_SIGNED_62 : std_logic_vector(31 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_63 : std_logic_vector(0 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_64 : std_logic_vector(31 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_65 : std_logic_vector(31 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_66 : std_logic_vector(0 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_67 : std_logic_vector(31 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_68 : std_logic_vector(31 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_69 : std_logic_vector(0 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_70 : std_logic_vector(0 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_71 : std_logic_vector(3 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_72 : std_logic;
  signal zz_zz_decode_IS_RS2_SIGNED_73 : std_logic_vector(31 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_74 : std_logic_vector(0 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_75 : std_logic_vector(31 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_76 : std_logic_vector(31 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_77 : std_logic_vector(1 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_78 : std_logic;
  signal zz_zz_decode_IS_RS2_SIGNED_79 : std_logic_vector(31 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_80 : std_logic;
  signal zz_zz_decode_IS_RS2_SIGNED_81 : std_logic_vector(31 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_82 : std_logic_vector(10 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_83 : std_logic_vector(5 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_84 : std_logic_vector(0 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_85 : std_logic_vector(31 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_86 : std_logic_vector(31 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_87 : std_logic_vector(3 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_88 : std_logic;
  signal zz_zz_decode_IS_RS2_SIGNED_89 : std_logic_vector(31 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_90 : std_logic_vector(0 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_91 : std_logic_vector(31 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_92 : std_logic_vector(31 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_93 : std_logic_vector(1 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_94 : std_logic;
  signal zz_zz_decode_IS_RS2_SIGNED_95 : std_logic;
  signal zz_zz_decode_IS_RS2_SIGNED_96 : std_logic_vector(5 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_97 : std_logic;
  signal zz_zz_decode_IS_RS2_SIGNED_98 : std_logic_vector(0 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_99 : std_logic_vector(0 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_100 : std_logic_vector(31 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_101 : std_logic_vector(31 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_102 : std_logic_vector(0 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_103 : std_logic_vector(1 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_104 : std_logic;
  signal zz_zz_decode_IS_RS2_SIGNED_105 : std_logic_vector(31 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_106 : std_logic_vector(1 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_107 : std_logic_vector(7 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_108 : std_logic;
  signal zz_zz_decode_IS_RS2_SIGNED_109 : std_logic;
  signal zz_zz_decode_IS_RS2_SIGNED_110 : std_logic_vector(31 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_111 : std_logic_vector(0 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_112 : std_logic_vector(0 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_113 : std_logic_vector(31 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_114 : std_logic_vector(31 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_115 : std_logic_vector(0 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_116 : std_logic_vector(5 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_117 : std_logic;
  signal zz_zz_decode_IS_RS2_SIGNED_118 : std_logic_vector(0 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_119 : std_logic_vector(31 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_120 : std_logic_vector(3 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_121 : std_logic;
  signal zz_zz_decode_IS_RS2_SIGNED_122 : std_logic_vector(0 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_123 : std_logic_vector(31 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_124 : std_logic_vector(0 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_125 : std_logic_vector(31 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_126 : std_logic_vector(0 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_127 : std_logic_vector(0 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_128 : std_logic_vector(31 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_129 : std_logic_vector(0 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_130 : std_logic_vector(3 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_131 : std_logic;
  signal zz_zz_decode_IS_RS2_SIGNED_132 : std_logic;
  signal zz_zz_decode_IS_RS2_SIGNED_133 : std_logic_vector(0 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_134 : std_logic_vector(31 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_135 : std_logic_vector(0 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_136 : std_logic_vector(31 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_137 : std_logic_vector(0 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_138 : std_logic_vector(0 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_139 : std_logic_vector(31 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_140 : std_logic_vector(0 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_141 : std_logic_vector(1 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_142 : std_logic_vector(1 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_143 : std_logic_vector(31 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_144 : std_logic_vector(31 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_145 : std_logic_vector(1 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_146 : std_logic_vector(0 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_147 : std_logic_vector(31 downto 0);
  signal zz_zz_decode_IS_RS2_SIGNED_148 : std_logic_vector(0 downto 0);
  signal zz_RegFilePlugin_regFile_port : std_logic;
  signal zz_decode_RegFilePlugin_rs1Data : std_logic;
  signal zz_RegFilePlugin_regFile_port_1 : std_logic;
  signal zz_decode_RegFilePlugin_rs2Data : std_logic;
  signal zz_execute_BranchPlugin_branch_src2_6 : std_logic_vector(0 downto 0);
  signal zz_execute_BranchPlugin_branch_src2_7 : std_logic_vector(7 downto 0);
  signal zz_execute_BranchPlugin_branch_src2_8 : std_logic;
  signal zz_execute_BranchPlugin_branch_src2_9 : std_logic_vector(0 downto 0);
  signal zz_execute_BranchPlugin_branch_src2_10 : std_logic_vector(0 downto 0);
  attribute keep : boolean;
  attribute syn_keep : boolean;

  signal memory_MUL_LOW : signed(51 downto 0);
  signal memory_MUL_HH : signed(33 downto 0);
  signal execute_MUL_HH : signed(33 downto 0);
  signal execute_MUL_HL : signed(33 downto 0);
  signal execute_MUL_LH : signed(33 downto 0);
  signal execute_MUL_LL : unsigned(31 downto 0);
  signal execute_SHIFT_RIGHT : std_logic_vector(31 downto 0);
  signal execute_REGFILE_WRITE_DATA : std_logic_vector(31 downto 0);
  signal memory_MEMORY_STORE_DATA_RF : std_logic_vector(31 downto 0);
  signal execute_MEMORY_STORE_DATA_RF : std_logic_vector(31 downto 0);
  signal decode_PREDICTION_HAD_BRANCHED2 : std_logic;
  signal decode_SRC2_FORCE_ZERO : std_logic;
  signal zz_decode_to_execute_BRANCH_CTRL : BranchCtrlEnum_seq_type;
  signal zz_decode_to_execute_BRANCH_CTRL_1 : BranchCtrlEnum_seq_type;
  signal decode_IS_RS2_SIGNED : std_logic;
  signal decode_IS_RS1_SIGNED : std_logic;
  signal decode_IS_DIV : std_logic;
  signal memory_IS_MUL : std_logic;
  signal execute_IS_MUL : std_logic;
  signal decode_IS_MUL : std_logic;
  signal zz_execute_to_memory_SHIFT_CTRL : ShiftCtrlEnum_seq_type;
  signal zz_execute_to_memory_SHIFT_CTRL_1 : ShiftCtrlEnum_seq_type;
  signal decode_SHIFT_CTRL : ShiftCtrlEnum_seq_type;
  signal zz_decode_SHIFT_CTRL : ShiftCtrlEnum_seq_type;
  signal zz_decode_to_execute_SHIFT_CTRL : ShiftCtrlEnum_seq_type;
  signal zz_decode_to_execute_SHIFT_CTRL_1 : ShiftCtrlEnum_seq_type;
  signal decode_ALU_BITWISE_CTRL : AluBitwiseCtrlEnum_seq_type;
  signal zz_decode_ALU_BITWISE_CTRL : AluBitwiseCtrlEnum_seq_type;
  signal zz_decode_to_execute_ALU_BITWISE_CTRL : AluBitwiseCtrlEnum_seq_type;
  signal zz_decode_to_execute_ALU_BITWISE_CTRL_1 : AluBitwiseCtrlEnum_seq_type;
  signal decode_SRC_LESS_UNSIGNED : std_logic;
  signal zz_memory_to_writeBack_ENV_CTRL : EnvCtrlEnum_seq_type;
  signal zz_memory_to_writeBack_ENV_CTRL_1 : EnvCtrlEnum_seq_type;
  signal zz_execute_to_memory_ENV_CTRL : EnvCtrlEnum_seq_type;
  signal zz_execute_to_memory_ENV_CTRL_1 : EnvCtrlEnum_seq_type;
  signal decode_ENV_CTRL : EnvCtrlEnum_seq_type;
  signal zz_decode_ENV_CTRL : EnvCtrlEnum_seq_type;
  signal zz_decode_to_execute_ENV_CTRL : EnvCtrlEnum_seq_type;
  signal zz_decode_to_execute_ENV_CTRL_1 : EnvCtrlEnum_seq_type;
  signal decode_IS_CSR : std_logic;
  signal decode_MEMORY_MANAGMENT : std_logic;
  signal memory_MEMORY_WR : std_logic;
  signal decode_MEMORY_WR : std_logic;
  signal execute_BYPASSABLE_MEMORY_STAGE : std_logic;
  signal decode_BYPASSABLE_MEMORY_STAGE : std_logic;
  signal decode_BYPASSABLE_EXECUTE_STAGE : std_logic;
  signal decode_SRC2_CTRL : Src2CtrlEnum_seq_type;
  signal zz_decode_SRC2_CTRL : Src2CtrlEnum_seq_type;
  signal zz_decode_to_execute_SRC2_CTRL : Src2CtrlEnum_seq_type;
  signal zz_decode_to_execute_SRC2_CTRL_1 : Src2CtrlEnum_seq_type;
  signal decode_ALU_CTRL : AluCtrlEnum_seq_type;
  signal zz_decode_ALU_CTRL : AluCtrlEnum_seq_type;
  signal zz_decode_to_execute_ALU_CTRL : AluCtrlEnum_seq_type;
  signal zz_decode_to_execute_ALU_CTRL_1 : AluCtrlEnum_seq_type;
  signal decode_SRC1_CTRL : Src1CtrlEnum_seq_type;
  signal zz_decode_SRC1_CTRL : Src1CtrlEnum_seq_type;
  signal zz_decode_to_execute_SRC1_CTRL : Src1CtrlEnum_seq_type;
  signal zz_decode_to_execute_SRC1_CTRL_1 : Src1CtrlEnum_seq_type;
  signal decode_CSR_READ_OPCODE : std_logic;
  signal decode_CSR_WRITE_OPCODE : std_logic;
  signal decode_MEMORY_FORCE_CONSTISTENCY : std_logic;
  signal writeBack_FORMAL_PC_NEXT : unsigned(31 downto 0);
  signal memory_FORMAL_PC_NEXT : unsigned(31 downto 0);
  signal execute_FORMAL_PC_NEXT : unsigned(31 downto 0);
  signal decode_FORMAL_PC_NEXT : unsigned(31 downto 0);
  signal memory_PC : unsigned(31 downto 0);
  signal execute_BRANCH_CALC : unsigned(31 downto 0);
  signal execute_BRANCH_DO : std_logic;
  signal execute_PC : unsigned(31 downto 0);
  signal execute_PREDICTION_HAD_BRANCHED2 : std_logic;
  signal execute_BRANCH_COND_RESULT : std_logic;
  signal execute_BRANCH_CTRL : BranchCtrlEnum_seq_type;
  signal zz_execute_BRANCH_CTRL : BranchCtrlEnum_seq_type;
  signal execute_IS_RS1_SIGNED : std_logic;
  signal execute_IS_DIV : std_logic;
  signal execute_IS_RS2_SIGNED : std_logic;
  signal memory_IS_DIV : std_logic;
  signal writeBack_IS_MUL : std_logic;
  signal writeBack_MUL_HH : signed(33 downto 0);
  signal writeBack_MUL_LOW : signed(51 downto 0);
  signal memory_MUL_HL : signed(33 downto 0);
  signal memory_MUL_LH : signed(33 downto 0);
  signal memory_MUL_LL : unsigned(31 downto 0);
  signal decode_RS2_USE : std_logic;
  signal decode_RS1_USE : std_logic;
  signal execute_REGFILE_WRITE_VALID : std_logic;
  signal execute_BYPASSABLE_EXECUTE_STAGE : std_logic;
  signal memory_REGFILE_WRITE_VALID : std_logic;
  signal memory_INSTRUCTION : std_logic_vector(31 downto 0);
  signal memory_BYPASSABLE_MEMORY_STAGE : std_logic;
  signal writeBack_REGFILE_WRITE_VALID : std_logic;
  signal decode_RS2 : std_logic_vector(31 downto 0);
  signal decode_RS1 : std_logic_vector(31 downto 0);
  signal memory_SHIFT_RIGHT : std_logic_vector(31 downto 0);
  signal zz_decode_RS2 : std_logic_vector(31 downto 0);
  signal memory_SHIFT_CTRL : ShiftCtrlEnum_seq_type;
  signal zz_memory_SHIFT_CTRL : ShiftCtrlEnum_seq_type;
  signal execute_SHIFT_CTRL : ShiftCtrlEnum_seq_type;
  signal zz_execute_SHIFT_CTRL : ShiftCtrlEnum_seq_type;
  signal execute_SRC_LESS_UNSIGNED : std_logic;
  signal execute_SRC2_FORCE_ZERO : std_logic;
  signal execute_SRC_USE_SUB_LESS : std_logic;
  signal zz_execute_to_memory_PC : unsigned(31 downto 0);
  signal execute_SRC2_CTRL : Src2CtrlEnum_seq_type;
  signal zz_execute_SRC2_CTRL : Src2CtrlEnum_seq_type;
  signal execute_SRC1_CTRL : Src1CtrlEnum_seq_type;
  signal zz_execute_SRC1_CTRL : Src1CtrlEnum_seq_type;
  signal decode_SRC_USE_SUB_LESS : std_logic;
  signal decode_SRC_ADD_ZERO : std_logic;
  signal execute_SRC_ADD_SUB : std_logic_vector(31 downto 0);
  signal execute_SRC_LESS : std_logic;
  signal execute_ALU_CTRL : AluCtrlEnum_seq_type;
  signal zz_execute_ALU_CTRL : AluCtrlEnum_seq_type;
  signal execute_SRC2 : std_logic_vector(31 downto 0);
  signal execute_ALU_BITWISE_CTRL : AluBitwiseCtrlEnum_seq_type;
  signal zz_execute_ALU_BITWISE_CTRL : AluBitwiseCtrlEnum_seq_type;
  signal zz_lastStageRegFileWrite_payload_address : std_logic_vector(31 downto 0);
  signal zz_lastStageRegFileWrite_valid : std_logic;
  signal zz_1 : std_logic;
  signal decode_INSTRUCTION_ANTICIPATED : std_logic_vector(31 downto 0);
  signal decode_REGFILE_WRITE_VALID : std_logic;
  signal decode_LEGAL_INSTRUCTION : std_logic;
  signal zz_decode_BRANCH_CTRL : BranchCtrlEnum_seq_type;
  signal zz_decode_SHIFT_CTRL_1 : ShiftCtrlEnum_seq_type;
  signal zz_decode_ALU_BITWISE_CTRL_1 : AluBitwiseCtrlEnum_seq_type;
  signal zz_decode_ENV_CTRL_1 : EnvCtrlEnum_seq_type;
  signal zz_decode_SRC2_CTRL_1 : Src2CtrlEnum_seq_type;
  signal zz_decode_ALU_CTRL_1 : AluCtrlEnum_seq_type;
  signal zz_decode_SRC1_CTRL_1 : Src1CtrlEnum_seq_type;
  signal zz_decode_RS2_1 : std_logic_vector(31 downto 0);
  signal execute_SRC1 : std_logic_vector(31 downto 0);
  signal execute_CSR_READ_OPCODE : std_logic;
  signal execute_CSR_WRITE_OPCODE : std_logic;
  signal execute_IS_CSR : std_logic;
  signal memory_ENV_CTRL : EnvCtrlEnum_seq_type;
  signal zz_memory_ENV_CTRL : EnvCtrlEnum_seq_type;
  signal execute_ENV_CTRL : EnvCtrlEnum_seq_type;
  signal zz_execute_ENV_CTRL : EnvCtrlEnum_seq_type;
  signal writeBack_ENV_CTRL : EnvCtrlEnum_seq_type;
  signal zz_writeBack_ENV_CTRL : EnvCtrlEnum_seq_type;
  signal zz_decode_RS2_2 : std_logic_vector(31 downto 0);
  signal writeBack_MEMORY_WR : std_logic;
  signal writeBack_MEMORY_STORE_DATA_RF : std_logic_vector(31 downto 0);
  signal writeBack_REGFILE_WRITE_DATA : std_logic_vector(31 downto 0);
  signal writeBack_MEMORY_ENABLE : std_logic;
  signal memory_REGFILE_WRITE_DATA : std_logic_vector(31 downto 0);
  signal memory_MEMORY_ENABLE : std_logic;
  signal execute_MEMORY_FORCE_CONSTISTENCY : std_logic;
  signal execute_RS1 : std_logic_vector(31 downto 0);
  attribute keep of execute_RS1 : signal is true;
  attribute syn_keep of execute_RS1 : signal is true;
  signal execute_MEMORY_MANAGMENT : std_logic;
  signal execute_RS2 : std_logic_vector(31 downto 0);
  attribute keep of execute_RS2 : signal is true;
  attribute syn_keep of execute_RS2 : signal is true;
  signal execute_MEMORY_WR : std_logic;
  signal execute_SRC_ADD : std_logic_vector(31 downto 0);
  signal execute_MEMORY_ENABLE : std_logic;
  signal execute_INSTRUCTION : std_logic_vector(31 downto 0);
  signal decode_MEMORY_ENABLE : std_logic;
  signal decode_FLUSH_ALL : std_logic;
  signal IBusCachedPlugin_rsp_issueDetected_4 : std_logic;
  signal IBusCachedPlugin_rsp_issueDetected_3 : std_logic;
  signal IBusCachedPlugin_rsp_issueDetected_2 : std_logic;
  signal IBusCachedPlugin_rsp_issueDetected_1 : std_logic;
  signal decode_BRANCH_CTRL : BranchCtrlEnum_seq_type;
  signal zz_decode_BRANCH_CTRL_1 : BranchCtrlEnum_seq_type;
  signal decode_INSTRUCTION : std_logic_vector(31 downto 0);
  signal zz_execute_to_memory_FORMAL_PC_NEXT : unsigned(31 downto 0);
  signal zz_decode_to_execute_FORMAL_PC_NEXT : unsigned(31 downto 0);
  signal decode_PC : unsigned(31 downto 0);
  signal writeBack_PC : unsigned(31 downto 0);
  signal writeBack_INSTRUCTION : std_logic_vector(31 downto 0);
  signal decode_arbitration_haltItself : std_logic;
  signal decode_arbitration_haltByOther : std_logic;
  signal decode_arbitration_removeIt : std_logic;
  signal decode_arbitration_flushIt : std_logic;
  signal decode_arbitration_flushNext : std_logic;
  signal decode_arbitration_isValid : std_logic;
  signal decode_arbitration_isStuck : std_logic;
  signal decode_arbitration_isStuckByOthers : std_logic;
  signal decode_arbitration_isFlushed : std_logic;
  signal decode_arbitration_isMoving : std_logic;
  signal decode_arbitration_isFiring : std_logic;
  signal execute_arbitration_haltItself : std_logic;
  signal execute_arbitration_haltByOther : std_logic;
  signal execute_arbitration_removeIt : std_logic;
  signal execute_arbitration_flushIt : std_logic;
  signal execute_arbitration_flushNext : std_logic;
  signal execute_arbitration_isValid : std_logic;
  signal execute_arbitration_isStuck : std_logic;
  signal execute_arbitration_isStuckByOthers : std_logic;
  signal execute_arbitration_isFlushed : std_logic;
  signal execute_arbitration_isMoving : std_logic;
  signal execute_arbitration_isFiring : std_logic;
  signal memory_arbitration_haltItself : std_logic;
  signal memory_arbitration_haltByOther : std_logic;
  signal memory_arbitration_removeIt : std_logic;
  signal memory_arbitration_flushIt : std_logic;
  signal memory_arbitration_flushNext : std_logic;
  signal memory_arbitration_isValid : std_logic;
  signal memory_arbitration_isStuck : std_logic;
  signal memory_arbitration_isStuckByOthers : std_logic;
  signal memory_arbitration_isFlushed : std_logic;
  signal memory_arbitration_isMoving : std_logic;
  signal memory_arbitration_isFiring : std_logic;
  signal writeBack_arbitration_haltItself : std_logic;
  signal writeBack_arbitration_haltByOther : std_logic;
  signal writeBack_arbitration_removeIt : std_logic;
  signal writeBack_arbitration_flushIt : std_logic;
  signal writeBack_arbitration_flushNext : std_logic;
  signal writeBack_arbitration_isValid : std_logic;
  signal writeBack_arbitration_isStuck : std_logic;
  signal writeBack_arbitration_isStuckByOthers : std_logic;
  signal writeBack_arbitration_isFlushed : std_logic;
  signal writeBack_arbitration_isMoving : std_logic;
  signal writeBack_arbitration_isFiring : std_logic;
  signal lastStageInstruction : std_logic_vector(31 downto 0);
  signal lastStagePc : unsigned(31 downto 0);
  signal lastStageIsValid : std_logic;
  signal lastStageIsFiring : std_logic;
  signal IBusCachedPlugin_fetcherHalt : std_logic;
  signal IBusCachedPlugin_forceNoDecodeCond : std_logic;
  signal IBusCachedPlugin_incomingInstruction : std_logic;
  signal IBusCachedPlugin_predictionJumpInterface_valid : std_logic;
  signal IBusCachedPlugin_predictionJumpInterface_payload : unsigned(31 downto 0);
  attribute keep of IBusCachedPlugin_predictionJumpInterface_payload : signal is true;
  attribute syn_keep of IBusCachedPlugin_predictionJumpInterface_payload : signal is true;
  signal IBusCachedPlugin_decodePrediction_cmd_hadBranch : std_logic;
  signal IBusCachedPlugin_decodePrediction_rsp_wasWrong : std_logic;
  signal IBusCachedPlugin_pcValids_0 : std_logic;
  signal IBusCachedPlugin_pcValids_1 : std_logic;
  signal IBusCachedPlugin_pcValids_2 : std_logic;
  signal IBusCachedPlugin_pcValids_3 : std_logic;
  signal IBusCachedPlugin_decodeExceptionPort_valid : std_logic;
  signal IBusCachedPlugin_decodeExceptionPort_payload_code : unsigned(3 downto 0);
  signal IBusCachedPlugin_decodeExceptionPort_payload_badAddr : unsigned(31 downto 0);
  signal IBusCachedPlugin_mmuBus_cmd_0_isValid : std_logic;
  signal IBusCachedPlugin_mmuBus_cmd_0_isStuck : std_logic;
  signal IBusCachedPlugin_mmuBus_cmd_0_virtualAddress : unsigned(31 downto 0);
  signal IBusCachedPlugin_mmuBus_cmd_0_bypassTranslation : std_logic;
  signal IBusCachedPlugin_mmuBus_rsp_physicalAddress : unsigned(31 downto 0);
  signal IBusCachedPlugin_mmuBus_rsp_isIoAccess : std_logic;
  signal IBusCachedPlugin_mmuBus_rsp_isPaging : std_logic;
  signal IBusCachedPlugin_mmuBus_rsp_allowRead : std_logic;
  signal IBusCachedPlugin_mmuBus_rsp_allowWrite : std_logic;
  signal IBusCachedPlugin_mmuBus_rsp_allowExecute : std_logic;
  signal IBusCachedPlugin_mmuBus_rsp_exception : std_logic;
  signal IBusCachedPlugin_mmuBus_rsp_refilling : std_logic;
  signal IBusCachedPlugin_mmuBus_rsp_bypassTranslation : std_logic;
  signal IBusCachedPlugin_mmuBus_end : std_logic;
  signal IBusCachedPlugin_mmuBus_busy : std_logic;
  signal DBusCachedPlugin_mmuBus_cmd_0_isValid : std_logic;
  signal DBusCachedPlugin_mmuBus_cmd_0_isStuck : std_logic;
  signal DBusCachedPlugin_mmuBus_cmd_0_virtualAddress : unsigned(31 downto 0);
  signal DBusCachedPlugin_mmuBus_cmd_0_bypassTranslation : std_logic;
  signal DBusCachedPlugin_mmuBus_rsp_physicalAddress : unsigned(31 downto 0);
  signal DBusCachedPlugin_mmuBus_rsp_isIoAccess : std_logic;
  signal DBusCachedPlugin_mmuBus_rsp_isPaging : std_logic;
  signal DBusCachedPlugin_mmuBus_rsp_allowRead : std_logic;
  signal DBusCachedPlugin_mmuBus_rsp_allowWrite : std_logic;
  signal DBusCachedPlugin_mmuBus_rsp_allowExecute : std_logic;
  signal DBusCachedPlugin_mmuBus_rsp_exception : std_logic;
  signal DBusCachedPlugin_mmuBus_rsp_refilling : std_logic;
  signal DBusCachedPlugin_mmuBus_rsp_bypassTranslation : std_logic;
  signal DBusCachedPlugin_mmuBus_end : std_logic;
  signal DBusCachedPlugin_mmuBus_busy : std_logic;
  signal DBusCachedPlugin_redoBranch_valid : std_logic;
  signal DBusCachedPlugin_redoBranch_payload : unsigned(31 downto 0);
  signal DBusCachedPlugin_exceptionBus_valid : std_logic;
  signal DBusCachedPlugin_exceptionBus_payload_code : unsigned(3 downto 0);
  signal DBusCachedPlugin_exceptionBus_payload_badAddr : unsigned(31 downto 0);
  signal CsrPlugin_csrMapping_readDataSignal : std_logic_vector(31 downto 0);
  signal CsrPlugin_csrMapping_readDataInit : std_logic_vector(31 downto 0);
  signal CsrPlugin_csrMapping_writeDataSignal : std_logic_vector(31 downto 0);
  signal CsrPlugin_csrMapping_allowCsrSignal : std_logic;
  signal CsrPlugin_csrMapping_hazardFree : std_logic;
  signal CsrPlugin_csrMapping_doForceFailCsr : std_logic;
  signal CsrPlugin_inWfi : std_logic;
  signal CsrPlugin_thirdPartyWake : std_logic;
  signal CsrPlugin_jumpInterface_valid : std_logic;
  signal CsrPlugin_jumpInterface_payload : unsigned(31 downto 0);
  signal CsrPlugin_exceptionPendings_0 : std_logic;
  signal CsrPlugin_exceptionPendings_1 : std_logic;
  signal CsrPlugin_exceptionPendings_2 : std_logic;
  signal CsrPlugin_exceptionPendings_3 : std_logic;
  signal contextSwitching : std_logic;
  signal CsrPlugin_privilege : unsigned(1 downto 0);
  signal CsrPlugin_forceMachineWire : std_logic;
  signal CsrPlugin_allowInterrupts : std_logic;
  signal CsrPlugin_allowException : std_logic;
  signal CsrPlugin_allowEbreakException : std_logic;
  signal CsrPlugin_xretAwayFromMachine : std_logic;
  signal decodeExceptionPort_valid : std_logic;
  signal decodeExceptionPort_payload_code : unsigned(3 downto 0);
  signal decodeExceptionPort_payload_badAddr : unsigned(31 downto 0);
  signal BranchPlugin_jumpInterface_valid : std_logic;
  signal BranchPlugin_jumpInterface_payload : unsigned(31 downto 0);
  signal BranchPlugin_branchExceptionPort_valid : std_logic;
  signal BranchPlugin_branchExceptionPort_payload_code : unsigned(3 downto 0);
  signal BranchPlugin_branchExceptionPort_payload_badAddr : unsigned(31 downto 0);
  signal BranchPlugin_inDebugNoFetchFlag : std_logic;
  signal IBusCachedPlugin_externalFlush : std_logic;
  signal IBusCachedPlugin_jump_pcLoad_valid : std_logic;
  signal IBusCachedPlugin_jump_pcLoad_payload : unsigned(31 downto 0);
  signal zz_IBusCachedPlugin_jump_pcLoad_payload : unsigned(3 downto 0);
  signal zz_IBusCachedPlugin_jump_pcLoad_payload_1 : std_logic_vector(3 downto 0);
  signal zz_IBusCachedPlugin_jump_pcLoad_payload_2 : std_logic;
  signal zz_IBusCachedPlugin_jump_pcLoad_payload_3 : std_logic;
  signal zz_IBusCachedPlugin_jump_pcLoad_payload_4 : std_logic;
  signal IBusCachedPlugin_fetchPc_output_valid : std_logic;
  signal IBusCachedPlugin_fetchPc_output_ready : std_logic;
  signal IBusCachedPlugin_fetchPc_output_payload : unsigned(31 downto 0);
  signal IBusCachedPlugin_fetchPc_pcReg : unsigned(31 downto 0);
  signal IBusCachedPlugin_fetchPc_correction : std_logic;
  signal IBusCachedPlugin_fetchPc_correctionReg : std_logic;
  signal IBusCachedPlugin_fetchPc_output_fire : std_logic;
  signal IBusCachedPlugin_fetchPc_corrected : std_logic;
  signal IBusCachedPlugin_fetchPc_pcRegPropagate : std_logic;
  signal IBusCachedPlugin_fetchPc_booted : std_logic;
  signal IBusCachedPlugin_fetchPc_inc : std_logic;
  signal when_Fetcher_l133 : std_logic;
  signal when_Fetcher_l133_1 : std_logic;
  signal IBusCachedPlugin_fetchPc_pc : unsigned(31 downto 0);
  signal IBusCachedPlugin_fetchPc_redo_valid : std_logic;
  signal IBusCachedPlugin_fetchPc_redo_payload : unsigned(31 downto 0);
  signal IBusCachedPlugin_fetchPc_flushed : std_logic;
  signal when_Fetcher_l160 : std_logic;
  signal IBusCachedPlugin_iBusRsp_redoFetch : std_logic;
  signal IBusCachedPlugin_iBusRsp_stages_0_input_valid : std_logic;
  signal IBusCachedPlugin_iBusRsp_stages_0_input_ready : std_logic;
  signal IBusCachedPlugin_iBusRsp_stages_0_input_payload : unsigned(31 downto 0);
  signal IBusCachedPlugin_iBusRsp_stages_0_output_valid : std_logic;
  signal IBusCachedPlugin_iBusRsp_stages_0_output_ready : std_logic;
  signal IBusCachedPlugin_iBusRsp_stages_0_output_payload : unsigned(31 downto 0);
  signal IBusCachedPlugin_iBusRsp_stages_0_halt : std_logic;
  signal IBusCachedPlugin_iBusRsp_stages_1_input_valid : std_logic;
  signal IBusCachedPlugin_iBusRsp_stages_1_input_ready : std_logic;
  signal IBusCachedPlugin_iBusRsp_stages_1_input_payload : unsigned(31 downto 0);
  signal IBusCachedPlugin_iBusRsp_stages_1_output_valid : std_logic;
  signal IBusCachedPlugin_iBusRsp_stages_1_output_ready : std_logic;
  signal IBusCachedPlugin_iBusRsp_stages_1_output_payload : unsigned(31 downto 0);
  signal IBusCachedPlugin_iBusRsp_stages_1_halt : std_logic;
  signal IBusCachedPlugin_iBusRsp_stages_2_input_valid : std_logic;
  signal IBusCachedPlugin_iBusRsp_stages_2_input_ready : std_logic;
  signal IBusCachedPlugin_iBusRsp_stages_2_input_payload : unsigned(31 downto 0);
  signal IBusCachedPlugin_iBusRsp_stages_2_output_valid : std_logic;
  signal IBusCachedPlugin_iBusRsp_stages_2_output_ready : std_logic;
  signal IBusCachedPlugin_iBusRsp_stages_2_output_payload : unsigned(31 downto 0);
  signal IBusCachedPlugin_iBusRsp_stages_2_halt : std_logic;
  signal zz_IBusCachedPlugin_iBusRsp_stages_0_input_ready : std_logic;
  signal zz_IBusCachedPlugin_iBusRsp_stages_1_input_ready : std_logic;
  signal zz_IBusCachedPlugin_iBusRsp_stages_2_input_ready : std_logic;
  signal IBusCachedPlugin_iBusRsp_flush : std_logic;
  signal zz_IBusCachedPlugin_iBusRsp_stages_0_output_ready : std_logic;
  signal zz_IBusCachedPlugin_iBusRsp_stages_1_input_valid : std_logic;
  signal zz_IBusCachedPlugin_iBusRsp_stages_1_input_valid_1 : std_logic;
  signal IBusCachedPlugin_iBusRsp_stages_1_output_m2sPipe_valid : std_logic;
  signal IBusCachedPlugin_iBusRsp_stages_1_output_m2sPipe_ready : std_logic;
  signal IBusCachedPlugin_iBusRsp_stages_1_output_m2sPipe_payload : unsigned(31 downto 0);
  signal zz_IBusCachedPlugin_iBusRsp_stages_1_output_m2sPipe_valid : std_logic;
  signal zz_IBusCachedPlugin_iBusRsp_stages_1_output_m2sPipe_payload : unsigned(31 downto 0);
  signal IBusCachedPlugin_iBusRsp_readyForError : std_logic;
  signal IBusCachedPlugin_iBusRsp_output_valid : std_logic;
  signal IBusCachedPlugin_iBusRsp_output_ready : std_logic;
  signal IBusCachedPlugin_iBusRsp_output_payload_pc : unsigned(31 downto 0);
  signal IBusCachedPlugin_iBusRsp_output_payload_rsp_error : std_logic;
  signal IBusCachedPlugin_iBusRsp_output_payload_rsp_inst : std_logic_vector(31 downto 0);
  signal IBusCachedPlugin_iBusRsp_output_payload_isRvc : std_logic;
  signal when_Fetcher_l242 : std_logic;
  signal when_Fetcher_l322 : std_logic;
  signal IBusCachedPlugin_injector_nextPcCalc_valids_0 : std_logic;
  signal when_Fetcher_l331 : std_logic;
  signal IBusCachedPlugin_injector_nextPcCalc_valids_1 : std_logic;
  signal when_Fetcher_l331_1 : std_logic;
  signal IBusCachedPlugin_injector_nextPcCalc_valids_2 : std_logic;
  signal when_Fetcher_l331_2 : std_logic;
  signal IBusCachedPlugin_injector_nextPcCalc_valids_3 : std_logic;
  signal when_Fetcher_l331_3 : std_logic;
  signal IBusCachedPlugin_injector_nextPcCalc_valids_4 : std_logic;
  signal when_Fetcher_l331_4 : std_logic;
  signal zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch : std_logic;
  signal zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch_1 : std_logic_vector(18 downto 0);
  signal zz_2 : std_logic;
  signal zz_3 : std_logic_vector(10 downto 0);
  signal zz_4 : std_logic;
  signal zz_5 : std_logic_vector(18 downto 0);
  signal zz_6 : std_logic;
  signal zz_IBusCachedPlugin_predictionJumpInterface_payload : std_logic;
  signal zz_IBusCachedPlugin_predictionJumpInterface_payload_1 : std_logic_vector(10 downto 0);
  signal zz_IBusCachedPlugin_predictionJumpInterface_payload_2 : std_logic;
  signal zz_IBusCachedPlugin_predictionJumpInterface_payload_3 : std_logic_vector(18 downto 0);
  signal IBusCachedPlugin_rspCounter : unsigned(31 downto 0);
  signal IBusCachedPlugin_s0_tightlyCoupledHit : std_logic;
  signal IBusCachedPlugin_s1_tightlyCoupledHit : std_logic;
  signal IBusCachedPlugin_s2_tightlyCoupledHit : std_logic;
  signal IBusCachedPlugin_rsp_iBusRspOutputHalt : std_logic;
  signal IBusCachedPlugin_rsp_issueDetected : std_logic;
  signal IBusCachedPlugin_rsp_redoFetch : std_logic;
  signal when_IBusCachedPlugin_l245 : std_logic;
  signal when_IBusCachedPlugin_l250 : std_logic;
  signal when_IBusCachedPlugin_l256 : std_logic;
  signal when_IBusCachedPlugin_l262 : std_logic;
  signal when_IBusCachedPlugin_l273 : std_logic;
  signal DBusCachedPlugin_rspCounter : unsigned(31 downto 0);
  signal when_DBusCachedPlugin_l343 : std_logic;
  signal execute_DBusCachedPlugin_size : unsigned(1 downto 0);
  signal zz_execute_MEMORY_STORE_DATA_RF : std_logic_vector(31 downto 0);
  signal system_cpu_dataCache_1_io_cpu_flush_isStall : std_logic;
  signal when_DBusCachedPlugin_l385 : std_logic;
  signal when_DBusCachedPlugin_l401 : std_logic;
  signal when_DBusCachedPlugin_l463 : std_logic;
  signal when_DBusCachedPlugin_l524 : std_logic;
  signal when_DBusCachedPlugin_l544 : std_logic;
  signal writeBack_DBusCachedPlugin_rspData : std_logic_vector(31 downto 0);
  signal writeBack_DBusCachedPlugin_rspSplits_0 : std_logic_vector(7 downto 0);
  signal writeBack_DBusCachedPlugin_rspSplits_1 : std_logic_vector(7 downto 0);
  signal writeBack_DBusCachedPlugin_rspSplits_2 : std_logic_vector(7 downto 0);
  signal writeBack_DBusCachedPlugin_rspSplits_3 : std_logic_vector(7 downto 0);
  signal writeBack_DBusCachedPlugin_rspShifted : std_logic_vector(31 downto 0);
  signal writeBack_DBusCachedPlugin_rspRf : std_logic_vector(31 downto 0);
  signal switch_Misc_l227 : std_logic_vector(1 downto 0);
  signal zz_writeBack_DBusCachedPlugin_rspFormated : std_logic;
  signal zz_writeBack_DBusCachedPlugin_rspFormated_1 : std_logic_vector(31 downto 0);
  signal zz_writeBack_DBusCachedPlugin_rspFormated_2 : std_logic;
  signal zz_writeBack_DBusCachedPlugin_rspFormated_3 : std_logic_vector(31 downto 0);
  signal writeBack_DBusCachedPlugin_rspFormated : std_logic_vector(31 downto 0);
  signal when_DBusCachedPlugin_l571 : std_logic;
  signal CsrPlugin_misa_base : unsigned(1 downto 0);
  signal CsrPlugin_misa_extensions : std_logic_vector(25 downto 0);
  signal CsrPlugin_mtvec_mode : std_logic_vector(1 downto 0);
  signal CsrPlugin_mtvec_base : unsigned(29 downto 0);
  signal CsrPlugin_mepc : unsigned(31 downto 0);
  signal CsrPlugin_mstatus_MIE : std_logic;
  signal CsrPlugin_mstatus_MPIE : std_logic;
  signal CsrPlugin_mstatus_MPP : unsigned(1 downto 0);
  signal CsrPlugin_mip_MEIP : std_logic;
  signal CsrPlugin_mip_MTIP : std_logic;
  signal CsrPlugin_mip_MSIP : std_logic;
  signal CsrPlugin_mie_MEIE : std_logic;
  signal CsrPlugin_mie_MTIE : std_logic;
  signal CsrPlugin_mie_MSIE : std_logic;
  signal CsrPlugin_mcause_interrupt : std_logic;
  signal CsrPlugin_mcause_exceptionCode : unsigned(3 downto 0);
  signal CsrPlugin_mtval : unsigned(31 downto 0);
  signal CsrPlugin_mcycle : unsigned(63 downto 0);
  signal CsrPlugin_minstret : unsigned(63 downto 0);
  signal zz_when_CsrPlugin_l1302 : std_logic;
  signal zz_when_CsrPlugin_l1302_1 : std_logic;
  signal zz_when_CsrPlugin_l1302_2 : std_logic;
  signal CsrPlugin_exceptionPortCtrl_exceptionValids_decode : std_logic;
  signal CsrPlugin_exceptionPortCtrl_exceptionValids_execute : std_logic;
  signal CsrPlugin_exceptionPortCtrl_exceptionValids_memory : std_logic;
  signal CsrPlugin_exceptionPortCtrl_exceptionValids_writeBack : std_logic;
  signal CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_decode : std_logic;
  signal CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_execute : std_logic;
  signal CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_memory : std_logic;
  signal CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_writeBack : std_logic;
  signal CsrPlugin_exceptionPortCtrl_exceptionContext_code : unsigned(3 downto 0);
  signal CsrPlugin_exceptionPortCtrl_exceptionContext_badAddr : unsigned(31 downto 0);
  signal CsrPlugin_exceptionPortCtrl_exceptionTargetPrivilegeUncapped : unsigned(1 downto 0);
  signal CsrPlugin_exceptionPortCtrl_exceptionTargetPrivilege : unsigned(1 downto 0);
  signal zz_CsrPlugin_exceptionPortCtrl_exceptionContext_code : unsigned(1 downto 0);
  signal zz_CsrPlugin_exceptionPortCtrl_exceptionContext_code_1 : std_logic;
  signal when_CsrPlugin_l1259 : std_logic;
  signal when_CsrPlugin_l1259_1 : std_logic;
  signal when_CsrPlugin_l1259_2 : std_logic;
  signal when_CsrPlugin_l1259_3 : std_logic;
  signal when_CsrPlugin_l1272 : std_logic;
  signal CsrPlugin_interrupt_valid : std_logic;
  signal CsrPlugin_interrupt_code : unsigned(3 downto 0);
  signal CsrPlugin_interrupt_targetPrivilege : unsigned(1 downto 0);
  signal when_CsrPlugin_l1296 : std_logic;
  signal when_CsrPlugin_l1302 : std_logic;
  signal when_CsrPlugin_l1302_1 : std_logic;
  signal when_CsrPlugin_l1302_2 : std_logic;
  signal CsrPlugin_exception : std_logic;
  signal CsrPlugin_lastStageWasWfi : std_logic;
  signal CsrPlugin_pipelineLiberator_pcValids_0 : std_logic;
  signal CsrPlugin_pipelineLiberator_pcValids_1 : std_logic;
  signal CsrPlugin_pipelineLiberator_pcValids_2 : std_logic;
  signal CsrPlugin_pipelineLiberator_active : std_logic;
  signal when_CsrPlugin_l1335 : std_logic;
  signal when_CsrPlugin_l1335_1 : std_logic;
  signal when_CsrPlugin_l1335_2 : std_logic;
  signal when_CsrPlugin_l1340 : std_logic;
  signal CsrPlugin_pipelineLiberator_done : std_logic;
  signal when_CsrPlugin_l1346 : std_logic;
  signal CsrPlugin_interruptJump : std_logic;
  signal CsrPlugin_hadException : std_logic;
  signal CsrPlugin_targetPrivilege : unsigned(1 downto 0);
  signal CsrPlugin_trapCause : unsigned(3 downto 0);
  signal CsrPlugin_trapCauseEbreakDebug : std_logic;
  signal CsrPlugin_xtvec_mode : std_logic_vector(1 downto 0);
  signal CsrPlugin_xtvec_base : unsigned(29 downto 0);
  signal CsrPlugin_trapEnterDebug : std_logic;
  signal when_CsrPlugin_l1390 : std_logic;
  signal when_CsrPlugin_l1398 : std_logic;
  signal when_CsrPlugin_l1456 : std_logic;
  signal switch_CsrPlugin_l1460 : std_logic_vector(1 downto 0);
  signal execute_CsrPlugin_wfiWake : std_logic;
  signal when_CsrPlugin_l1527 : std_logic;
  signal execute_CsrPlugin_blockedBySideEffects : std_logic;
  signal execute_CsrPlugin_illegalAccess : std_logic;
  signal execute_CsrPlugin_illegalInstruction : std_logic;
  signal when_CsrPlugin_l1547 : std_logic;
  signal when_CsrPlugin_l1548 : std_logic;
  signal execute_CsrPlugin_writeInstruction : std_logic;
  signal execute_CsrPlugin_readInstruction : std_logic;
  signal execute_CsrPlugin_writeEnable : std_logic;
  signal execute_CsrPlugin_readEnable : std_logic;
  signal execute_CsrPlugin_readToWriteData : std_logic_vector(31 downto 0);
  signal switch_Misc_l227_1 : std_logic;
  signal zz_CsrPlugin_csrMapping_writeDataSignal : std_logic_vector(31 downto 0);
  signal when_CsrPlugin_l1587 : std_logic;
  signal when_CsrPlugin_l1591 : std_logic;
  signal execute_CsrPlugin_csrAddress : std_logic_vector(11 downto 0);
  signal zz_decode_IS_RS2_SIGNED : std_logic_vector(30 downto 0);
  signal zz_decode_IS_RS2_SIGNED_1 : std_logic;
  signal zz_decode_IS_RS2_SIGNED_2 : std_logic;
  signal zz_decode_IS_RS2_SIGNED_3 : std_logic;
  signal zz_decode_IS_RS2_SIGNED_4 : std_logic;
  signal zz_decode_IS_RS2_SIGNED_5 : std_logic;
  signal zz_decode_SRC1_CTRL_2 : Src1CtrlEnum_seq_type;
  signal zz_decode_ALU_CTRL_2 : AluCtrlEnum_seq_type;
  signal zz_decode_SRC2_CTRL_2 : Src2CtrlEnum_seq_type;
  signal zz_decode_ENV_CTRL_2 : EnvCtrlEnum_seq_type;
  signal zz_decode_ALU_BITWISE_CTRL_2 : AluBitwiseCtrlEnum_seq_type;
  signal zz_decode_SHIFT_CTRL_2 : ShiftCtrlEnum_seq_type;
  signal zz_decode_BRANCH_CTRL_2 : BranchCtrlEnum_seq_type;
  signal when_RegFilePlugin_l63 : std_logic;
  signal decode_RegFilePlugin_regFileReadAddress1 : unsigned(4 downto 0);
  signal decode_RegFilePlugin_regFileReadAddress2 : unsigned(4 downto 0);
  signal decode_RegFilePlugin_rs1Data : std_logic_vector(31 downto 0);
  signal decode_RegFilePlugin_rs2Data : std_logic_vector(31 downto 0);
  signal lastStageRegFileWrite_valid : std_logic;
  signal lastStageRegFileWrite_payload_address : unsigned(4 downto 0);
  signal lastStageRegFileWrite_payload_data : std_logic_vector(31 downto 0);
  signal zz_10 : std_logic;
  signal execute_IntAluPlugin_bitwise : std_logic_vector(31 downto 0);
  signal zz_execute_REGFILE_WRITE_DATA : std_logic_vector(31 downto 0);
  signal zz_execute_SRC1 : std_logic_vector(31 downto 0);
  signal zz_execute_SRC2 : std_logic;
  signal zz_execute_SRC2_1 : std_logic_vector(19 downto 0);
  signal zz_execute_SRC2_2 : std_logic;
  signal zz_execute_SRC2_3 : std_logic_vector(19 downto 0);
  signal zz_execute_SRC2_4 : std_logic_vector(31 downto 0);
  signal execute_SrcPlugin_addSub : std_logic_vector(31 downto 0);
  signal execute_SrcPlugin_less : std_logic;
  signal execute_FullBarrelShifterPlugin_amplitude : unsigned(4 downto 0);
  signal zz_execute_FullBarrelShifterPlugin_reversed : std_logic_vector(31 downto 0);
  signal execute_FullBarrelShifterPlugin_reversed : std_logic_vector(31 downto 0);
  signal zz_decode_RS2_3 : std_logic_vector(31 downto 0);
  signal HazardSimplePlugin_src0Hazard : std_logic;
  signal HazardSimplePlugin_src1Hazard : std_logic;
  signal HazardSimplePlugin_writeBackWrites_valid : std_logic;
  signal HazardSimplePlugin_writeBackWrites_payload_address : std_logic_vector(4 downto 0);
  signal HazardSimplePlugin_writeBackWrites_payload_data : std_logic_vector(31 downto 0);
  signal HazardSimplePlugin_writeBackBuffer_valid : std_logic;
  signal HazardSimplePlugin_writeBackBuffer_payload_address : std_logic_vector(4 downto 0);
  signal HazardSimplePlugin_writeBackBuffer_payload_data : std_logic_vector(31 downto 0);
  signal HazardSimplePlugin_addr0Match : std_logic;
  signal HazardSimplePlugin_addr1Match : std_logic;
  signal when_HazardSimplePlugin_l47 : std_logic;
  signal when_HazardSimplePlugin_l48 : std_logic;
  signal when_HazardSimplePlugin_l51 : std_logic;
  signal when_HazardSimplePlugin_l45 : std_logic;
  signal when_HazardSimplePlugin_l57 : std_logic;
  signal when_HazardSimplePlugin_l58 : std_logic;
  signal when_HazardSimplePlugin_l48_1 : std_logic;
  signal when_HazardSimplePlugin_l51_1 : std_logic;
  signal when_HazardSimplePlugin_l45_1 : std_logic;
  signal when_HazardSimplePlugin_l57_1 : std_logic;
  signal when_HazardSimplePlugin_l58_1 : std_logic;
  signal when_HazardSimplePlugin_l48_2 : std_logic;
  signal when_HazardSimplePlugin_l51_2 : std_logic;
  signal when_HazardSimplePlugin_l45_2 : std_logic;
  signal when_HazardSimplePlugin_l57_2 : std_logic;
  signal when_HazardSimplePlugin_l58_2 : std_logic;
  signal when_HazardSimplePlugin_l105 : std_logic;
  signal when_HazardSimplePlugin_l108 : std_logic;
  signal when_HazardSimplePlugin_l113 : std_logic;
  signal execute_MulPlugin_aSigned : std_logic;
  signal execute_MulPlugin_bSigned : std_logic;
  signal execute_MulPlugin_a : std_logic_vector(31 downto 0);
  signal execute_MulPlugin_b : std_logic_vector(31 downto 0);
  signal switch_MulPlugin_l87 : std_logic_vector(1 downto 0);
  signal execute_MulPlugin_aULow : unsigned(15 downto 0);
  signal execute_MulPlugin_bULow : unsigned(15 downto 0);
  signal execute_MulPlugin_aSLow : signed(16 downto 0);
  signal execute_MulPlugin_bSLow : signed(16 downto 0);
  signal execute_MulPlugin_aHigh : signed(16 downto 0);
  signal execute_MulPlugin_bHigh : signed(16 downto 0);
  signal writeBack_MulPlugin_result : signed(65 downto 0);
  signal when_MulPlugin_l147 : std_logic;
  signal switch_MulPlugin_l148 : std_logic_vector(1 downto 0);
  signal memory_DivPlugin_rs1 : unsigned(32 downto 0);
  signal memory_DivPlugin_rs2 : unsigned(31 downto 0);
  signal memory_DivPlugin_accumulator : unsigned(64 downto 0);
  signal memory_DivPlugin_frontendOk : std_logic;
  signal memory_DivPlugin_div_needRevert : std_logic;
  signal memory_DivPlugin_div_counter_willIncrement : std_logic;
  signal memory_DivPlugin_div_counter_willClear : std_logic;
  signal memory_DivPlugin_div_counter_valueNext : unsigned(5 downto 0);
  signal memory_DivPlugin_div_counter_value : unsigned(5 downto 0);
  signal memory_DivPlugin_div_counter_willOverflowIfInc : std_logic;
  signal memory_DivPlugin_div_counter_willOverflow : std_logic;
  signal memory_DivPlugin_div_done : std_logic;
  signal when_MulDivIterativePlugin_l126 : std_logic;
  signal when_MulDivIterativePlugin_l126_1 : std_logic;
  signal memory_DivPlugin_div_result : std_logic_vector(31 downto 0);
  signal when_MulDivIterativePlugin_l128 : std_logic;
  signal when_MulDivIterativePlugin_l129 : std_logic;
  signal when_MulDivIterativePlugin_l132 : std_logic;
  signal zz_memory_DivPlugin_div_stage_0_remainderShifted : unsigned(31 downto 0);
  signal memory_DivPlugin_div_stage_0_remainderShifted : unsigned(32 downto 0);
  signal memory_DivPlugin_div_stage_0_remainderMinusDenominator : unsigned(32 downto 0);
  signal memory_DivPlugin_div_stage_0_outRemainder : unsigned(31 downto 0);
  signal memory_DivPlugin_div_stage_0_outNumerator : unsigned(31 downto 0);
  signal when_MulDivIterativePlugin_l151 : std_logic;
  signal zz_memory_DivPlugin_div_result : unsigned(31 downto 0);
  signal when_MulDivIterativePlugin_l162 : std_logic;
  signal zz_memory_DivPlugin_rs2 : std_logic;
  signal zz_memory_DivPlugin_rs1 : std_logic;
  signal zz_memory_DivPlugin_rs1_1 : std_logic_vector(32 downto 0);
  signal execute_BranchPlugin_eq : std_logic;
  signal switch_Misc_l227_2 : std_logic_vector(2 downto 0);
  signal zz_execute_BRANCH_COND_RESULT : std_logic;
  signal zz_execute_BRANCH_COND_RESULT_1 : std_logic;
  signal zz_execute_BranchPlugin_missAlignedTarget : std_logic;
  signal zz_execute_BranchPlugin_missAlignedTarget_1 : std_logic_vector(19 downto 0);
  signal zz_execute_BranchPlugin_missAlignedTarget_2 : std_logic;
  signal zz_execute_BranchPlugin_missAlignedTarget_3 : std_logic_vector(10 downto 0);
  signal zz_execute_BranchPlugin_missAlignedTarget_4 : std_logic;
  signal zz_execute_BranchPlugin_missAlignedTarget_5 : std_logic_vector(18 downto 0);
  signal zz_execute_BranchPlugin_missAlignedTarget_6 : std_logic;
  signal execute_BranchPlugin_missAlignedTarget : std_logic;
  signal execute_BranchPlugin_branch_src1 : unsigned(31 downto 0);
  signal execute_BranchPlugin_branch_src2 : unsigned(31 downto 0);
  signal zz_execute_BranchPlugin_branch_src2 : std_logic;
  signal zz_execute_BranchPlugin_branch_src2_1 : std_logic_vector(19 downto 0);
  signal zz_execute_BranchPlugin_branch_src2_2 : std_logic;
  signal zz_execute_BranchPlugin_branch_src2_3 : std_logic_vector(10 downto 0);
  signal zz_execute_BranchPlugin_branch_src2_4 : std_logic;
  signal zz_execute_BranchPlugin_branch_src2_5 : std_logic_vector(18 downto 0);
  signal execute_BranchPlugin_branchAdder : unsigned(31 downto 0);
  signal when_BranchPlugin_l304 : std_logic;
  signal when_Pipeline_l124 : std_logic;
  signal decode_to_execute_PC : unsigned(31 downto 0);
  signal when_Pipeline_l124_1 : std_logic;
  signal execute_to_memory_PC : unsigned(31 downto 0);
  signal when_Pipeline_l124_2 : std_logic;
  signal memory_to_writeBack_PC : unsigned(31 downto 0);
  signal when_Pipeline_l124_3 : std_logic;
  signal decode_to_execute_INSTRUCTION : std_logic_vector(31 downto 0);
  signal when_Pipeline_l124_4 : std_logic;
  signal execute_to_memory_INSTRUCTION : std_logic_vector(31 downto 0);
  signal when_Pipeline_l124_5 : std_logic;
  signal memory_to_writeBack_INSTRUCTION : std_logic_vector(31 downto 0);
  signal when_Pipeline_l124_6 : std_logic;
  signal decode_to_execute_FORMAL_PC_NEXT : unsigned(31 downto 0);
  signal when_Pipeline_l124_7 : std_logic;
  signal execute_to_memory_FORMAL_PC_NEXT : unsigned(31 downto 0);
  signal when_Pipeline_l124_8 : std_logic;
  signal memory_to_writeBack_FORMAL_PC_NEXT : unsigned(31 downto 0);
  signal when_Pipeline_l124_9 : std_logic;
  signal decode_to_execute_MEMORY_FORCE_CONSTISTENCY : std_logic;
  signal when_Pipeline_l124_10 : std_logic;
  signal decode_to_execute_CSR_WRITE_OPCODE : std_logic;
  signal when_Pipeline_l124_11 : std_logic;
  signal decode_to_execute_CSR_READ_OPCODE : std_logic;
  signal when_Pipeline_l124_12 : std_logic;
  signal decode_to_execute_SRC1_CTRL : Src1CtrlEnum_seq_type;
  signal when_Pipeline_l124_13 : std_logic;
  signal decode_to_execute_SRC_USE_SUB_LESS : std_logic;
  signal when_Pipeline_l124_14 : std_logic;
  signal decode_to_execute_MEMORY_ENABLE : std_logic;
  signal when_Pipeline_l124_15 : std_logic;
  signal execute_to_memory_MEMORY_ENABLE : std_logic;
  signal when_Pipeline_l124_16 : std_logic;
  signal memory_to_writeBack_MEMORY_ENABLE : std_logic;
  signal when_Pipeline_l124_17 : std_logic;
  signal decode_to_execute_ALU_CTRL : AluCtrlEnum_seq_type;
  signal when_Pipeline_l124_18 : std_logic;
  signal decode_to_execute_SRC2_CTRL : Src2CtrlEnum_seq_type;
  signal when_Pipeline_l124_19 : std_logic;
  signal decode_to_execute_REGFILE_WRITE_VALID : std_logic;
  signal when_Pipeline_l124_20 : std_logic;
  signal execute_to_memory_REGFILE_WRITE_VALID : std_logic;
  signal when_Pipeline_l124_21 : std_logic;
  signal memory_to_writeBack_REGFILE_WRITE_VALID : std_logic;
  signal when_Pipeline_l124_22 : std_logic;
  signal decode_to_execute_BYPASSABLE_EXECUTE_STAGE : std_logic;
  signal when_Pipeline_l124_23 : std_logic;
  signal decode_to_execute_BYPASSABLE_MEMORY_STAGE : std_logic;
  signal when_Pipeline_l124_24 : std_logic;
  signal execute_to_memory_BYPASSABLE_MEMORY_STAGE : std_logic;
  signal when_Pipeline_l124_25 : std_logic;
  signal decode_to_execute_MEMORY_WR : std_logic;
  signal when_Pipeline_l124_26 : std_logic;
  signal execute_to_memory_MEMORY_WR : std_logic;
  signal when_Pipeline_l124_27 : std_logic;
  signal memory_to_writeBack_MEMORY_WR : std_logic;
  signal when_Pipeline_l124_28 : std_logic;
  signal decode_to_execute_MEMORY_MANAGMENT : std_logic;
  signal when_Pipeline_l124_29 : std_logic;
  signal decode_to_execute_IS_CSR : std_logic;
  signal when_Pipeline_l124_30 : std_logic;
  signal decode_to_execute_ENV_CTRL : EnvCtrlEnum_seq_type;
  signal when_Pipeline_l124_31 : std_logic;
  signal execute_to_memory_ENV_CTRL : EnvCtrlEnum_seq_type;
  signal when_Pipeline_l124_32 : std_logic;
  signal memory_to_writeBack_ENV_CTRL : EnvCtrlEnum_seq_type;
  signal when_Pipeline_l124_33 : std_logic;
  signal decode_to_execute_SRC_LESS_UNSIGNED : std_logic;
  signal when_Pipeline_l124_34 : std_logic;
  signal decode_to_execute_ALU_BITWISE_CTRL : AluBitwiseCtrlEnum_seq_type;
  signal when_Pipeline_l124_35 : std_logic;
  signal decode_to_execute_SHIFT_CTRL : ShiftCtrlEnum_seq_type;
  signal when_Pipeline_l124_36 : std_logic;
  signal execute_to_memory_SHIFT_CTRL : ShiftCtrlEnum_seq_type;
  signal when_Pipeline_l124_37 : std_logic;
  signal decode_to_execute_IS_MUL : std_logic;
  signal when_Pipeline_l124_38 : std_logic;
  signal execute_to_memory_IS_MUL : std_logic;
  signal when_Pipeline_l124_39 : std_logic;
  signal memory_to_writeBack_IS_MUL : std_logic;
  signal when_Pipeline_l124_40 : std_logic;
  signal decode_to_execute_IS_DIV : std_logic;
  signal when_Pipeline_l124_41 : std_logic;
  signal execute_to_memory_IS_DIV : std_logic;
  signal when_Pipeline_l124_42 : std_logic;
  signal decode_to_execute_IS_RS1_SIGNED : std_logic;
  signal when_Pipeline_l124_43 : std_logic;
  signal decode_to_execute_IS_RS2_SIGNED : std_logic;
  signal when_Pipeline_l124_44 : std_logic;
  signal decode_to_execute_BRANCH_CTRL : BranchCtrlEnum_seq_type;
  signal when_Pipeline_l124_45 : std_logic;
  signal decode_to_execute_RS1 : std_logic_vector(31 downto 0);
  signal when_Pipeline_l124_46 : std_logic;
  signal decode_to_execute_RS2 : std_logic_vector(31 downto 0);
  signal when_Pipeline_l124_47 : std_logic;
  signal decode_to_execute_SRC2_FORCE_ZERO : std_logic;
  signal when_Pipeline_l124_48 : std_logic;
  signal decode_to_execute_PREDICTION_HAD_BRANCHED2 : std_logic;
  signal when_Pipeline_l124_49 : std_logic;
  signal execute_to_memory_MEMORY_STORE_DATA_RF : std_logic_vector(31 downto 0);
  signal when_Pipeline_l124_50 : std_logic;
  signal memory_to_writeBack_MEMORY_STORE_DATA_RF : std_logic_vector(31 downto 0);
  signal when_Pipeline_l124_51 : std_logic;
  signal execute_to_memory_REGFILE_WRITE_DATA : std_logic_vector(31 downto 0);
  signal when_Pipeline_l124_52 : std_logic;
  signal memory_to_writeBack_REGFILE_WRITE_DATA : std_logic_vector(31 downto 0);
  signal when_Pipeline_l124_53 : std_logic;
  signal execute_to_memory_SHIFT_RIGHT : std_logic_vector(31 downto 0);
  signal when_Pipeline_l124_54 : std_logic;
  signal execute_to_memory_MUL_LL : unsigned(31 downto 0);
  signal when_Pipeline_l124_55 : std_logic;
  signal execute_to_memory_MUL_LH : signed(33 downto 0);
  signal when_Pipeline_l124_56 : std_logic;
  signal execute_to_memory_MUL_HL : signed(33 downto 0);
  signal when_Pipeline_l124_57 : std_logic;
  signal execute_to_memory_MUL_HH : signed(33 downto 0);
  signal when_Pipeline_l124_58 : std_logic;
  signal memory_to_writeBack_MUL_HH : signed(33 downto 0);
  signal when_Pipeline_l124_59 : std_logic;
  signal memory_to_writeBack_MUL_LOW : signed(51 downto 0);
  signal when_Pipeline_l151 : std_logic;
  signal when_Pipeline_l154 : std_logic;
  signal when_Pipeline_l151_1 : std_logic;
  signal when_Pipeline_l154_1 : std_logic;
  signal when_Pipeline_l151_2 : std_logic;
  signal when_Pipeline_l154_2 : std_logic;
  signal when_CsrPlugin_l1669 : std_logic;
  signal execute_CsrPlugin_csr_768 : std_logic;
  signal when_CsrPlugin_l1669_1 : std_logic;
  signal execute_CsrPlugin_csr_836 : std_logic;
  signal when_CsrPlugin_l1669_2 : std_logic;
  signal execute_CsrPlugin_csr_772 : std_logic;
  signal when_CsrPlugin_l1669_3 : std_logic;
  signal execute_CsrPlugin_csr_834 : std_logic;
  signal switch_CsrPlugin_l1031 : std_logic_vector(1 downto 0);
  signal zz_CsrPlugin_csrMapping_readDataInit : std_logic_vector(31 downto 0);
  signal zz_CsrPlugin_csrMapping_readDataInit_1 : std_logic_vector(31 downto 0);
  signal zz_CsrPlugin_csrMapping_readDataInit_2 : std_logic_vector(31 downto 0);
  signal zz_CsrPlugin_csrMapping_readDataInit_3 : std_logic_vector(31 downto 0);
  signal when_CsrPlugin_l1702 : std_logic;
  signal zz_when_CsrPlugin_l1709 : unsigned(11 downto 0);
  signal when_CsrPlugin_l1709 : std_logic;
  signal when_CsrPlugin_l1719 : std_logic;
  signal when_CsrPlugin_l1717 : std_logic;
  signal when_CsrPlugin_l1725 : std_logic;
  type RegFilePlugin_regFile_type is array (0 to 31) of std_logic_vector(31 downto 0);
  signal RegFilePlugin_regFile : RegFilePlugin_regFile_type;
begin
  zz_when <= pkg_toStdLogic(pkg_cat(pkg_toStdLogicVector(decodeExceptionPort_valid),pkg_toStdLogicVector(IBusCachedPlugin_decodeExceptionPort_valid)) /= pkg_stdLogicVector("00"));
  zz_decode_RegFilePlugin_rs1Data <= pkg_toStdLogic(true);
  zz_decode_RegFilePlugin_rs2Data <= pkg_toStdLogic(true);
  zz_IBusCachedPlugin_jump_pcLoad_payload_6 <= unsigned(pkg_cat(pkg_toStdLogicVector(zz_IBusCachedPlugin_jump_pcLoad_payload_4),pkg_toStdLogicVector(zz_IBusCachedPlugin_jump_pcLoad_payload_3)));
  zz_writeBack_DBusCachedPlugin_rspShifted_1 <= pkg_extract(dataCache_1_io_cpu_writeBack_address,1,0);
  zz_writeBack_DBusCachedPlugin_rspShifted_3 <= pkg_extract(dataCache_1_io_cpu_writeBack_address,1,1);
  zz_decode_LEGAL_INSTRUCTION <= pkg_stdLogicVector("00000000000000000001000001111111");
  zz_decode_LEGAL_INSTRUCTION_1 <= (decode_INSTRUCTION and pkg_stdLogicVector("00000000000000000010000001111111"));
  zz_decode_LEGAL_INSTRUCTION_2 <= pkg_stdLogicVector("00000000000000000010000001110011");
  zz_decode_LEGAL_INSTRUCTION_3 <= pkg_toStdLogic((decode_INSTRUCTION and pkg_stdLogicVector("00000000000000000100000001111111")) = pkg_stdLogicVector("00000000000000000100000001100011"));
  zz_decode_LEGAL_INSTRUCTION_4 <= pkg_toStdLogicVector(pkg_toStdLogic((decode_INSTRUCTION and pkg_stdLogicVector("00000000000000000010000001111111")) = pkg_stdLogicVector("00000000000000000010000000010011")));
  zz_decode_LEGAL_INSTRUCTION_5 <= pkg_cat(pkg_toStdLogicVector(pkg_toStdLogic((decode_INSTRUCTION and pkg_stdLogicVector("00000000000000000001000001111111")) = pkg_stdLogicVector("00000000000000000000000000010011"))),pkg_cat(pkg_toStdLogicVector(pkg_toStdLogic((decode_INSTRUCTION and pkg_stdLogicVector("00000000000000000110000000111111")) = pkg_stdLogicVector("00000000000000000000000000100011"))),pkg_cat(pkg_toStdLogicVector(pkg_toStdLogic((decode_INSTRUCTION and zz_decode_LEGAL_INSTRUCTION_6) = pkg_stdLogicVector("00000000000000000000000000000011"))),pkg_cat(pkg_toStdLogicVector(pkg_toStdLogic(zz_decode_LEGAL_INSTRUCTION_7 = zz_decode_LEGAL_INSTRUCTION_8)),pkg_cat(pkg_toStdLogicVector(zz_decode_LEGAL_INSTRUCTION_9),pkg_cat(zz_decode_LEGAL_INSTRUCTION_10,zz_decode_LEGAL_INSTRUCTION_11))))));
  zz_decode_LEGAL_INSTRUCTION_6 <= pkg_stdLogicVector("00000000000000000010000001111111");
  zz_decode_LEGAL_INSTRUCTION_7 <= (decode_INSTRUCTION and pkg_stdLogicVector("00000000000000000101000001011111"));
  zz_decode_LEGAL_INSTRUCTION_8 <= pkg_stdLogicVector("00000000000000000000000000000011");
  zz_decode_LEGAL_INSTRUCTION_9 <= pkg_toStdLogic((decode_INSTRUCTION and pkg_stdLogicVector("00000000000000000111000001111011")) = pkg_stdLogicVector("00000000000000000000000001100011"));
  zz_decode_LEGAL_INSTRUCTION_10 <= pkg_toStdLogicVector(pkg_toStdLogic((decode_INSTRUCTION and pkg_stdLogicVector("00000000000000000110000001111111")) = pkg_stdLogicVector("00000000000000000000000000001111")));
  zz_decode_LEGAL_INSTRUCTION_11 <= pkg_cat(pkg_toStdLogicVector(pkg_toStdLogic((decode_INSTRUCTION and pkg_stdLogicVector("11111100000000000000000001111111")) = pkg_stdLogicVector("00000000000000000000000000110011"))),pkg_cat(pkg_toStdLogicVector(pkg_toStdLogic((decode_INSTRUCTION and pkg_stdLogicVector("00000001111100000111000001111111")) = pkg_stdLogicVector("00000000000000000101000000001111"))),pkg_cat(pkg_toStdLogicVector(pkg_toStdLogic((decode_INSTRUCTION and zz_decode_LEGAL_INSTRUCTION_12) = pkg_stdLogicVector("00000000000000000101000000010011"))),pkg_cat(pkg_toStdLogicVector(pkg_toStdLogic(zz_decode_LEGAL_INSTRUCTION_13 = zz_decode_LEGAL_INSTRUCTION_14)),pkg_cat(pkg_toStdLogicVector(zz_decode_LEGAL_INSTRUCTION_15),pkg_toStdLogicVector(zz_decode_LEGAL_INSTRUCTION_16))))));
  zz_decode_LEGAL_INSTRUCTION_12 <= pkg_stdLogicVector("10111110000000000111000001011111");
  zz_decode_LEGAL_INSTRUCTION_13 <= (decode_INSTRUCTION and pkg_stdLogicVector("11111110000000000011000001011111"));
  zz_decode_LEGAL_INSTRUCTION_14 <= pkg_stdLogicVector("00000000000000000001000000010011");
  zz_decode_LEGAL_INSTRUCTION_15 <= pkg_toStdLogic((decode_INSTRUCTION and pkg_stdLogicVector("10111110000000000111000001111111")) = pkg_stdLogicVector("00000000000000000000000000110011"));
  zz_decode_LEGAL_INSTRUCTION_16 <= pkg_toStdLogic((decode_INSTRUCTION and pkg_stdLogicVector("11011111111111111111111111111111")) = pkg_stdLogicVector("00010000001000000000000001110011"));
  zz_IBusCachedPlugin_predictionJumpInterface_payload_4 <= pkg_extract(decode_INSTRUCTION,31);
  zz_IBusCachedPlugin_predictionJumpInterface_payload_5 <= pkg_extract(decode_INSTRUCTION,31);
  zz_IBusCachedPlugin_predictionJumpInterface_payload_6 <= pkg_extract(decode_INSTRUCTION,7);
  zz_zz_decode_IS_RS2_SIGNED <= (decode_INSTRUCTION and pkg_stdLogicVector("00000000000000000000000000011100"));
  zz_zz_decode_IS_RS2_SIGNED_1 <= pkg_stdLogicVector("00000000000000000000000000000100");
  zz_zz_decode_IS_RS2_SIGNED_2 <= (decode_INSTRUCTION and pkg_stdLogicVector("00000000000000000000000001011000"));
  zz_zz_decode_IS_RS2_SIGNED_3 <= pkg_stdLogicVector("00000000000000000000000001000000");
  zz_zz_decode_IS_RS2_SIGNED_4 <= pkg_toStdLogicVector(zz_decode_IS_RS2_SIGNED_5);
  zz_zz_decode_IS_RS2_SIGNED_5 <= pkg_stdLogicVector("0");
  zz_zz_decode_IS_RS2_SIGNED_6 <= pkg_toStdLogic(pkg_toStdLogicVector(pkg_toStdLogic((decode_INSTRUCTION and pkg_stdLogicVector("00000010000000000100000001100100")) = pkg_stdLogicVector("00000010000000000100000000100000"))) /= pkg_stdLogicVector("0"));
  zz_zz_decode_IS_RS2_SIGNED_7 <= pkg_toStdLogicVector(pkg_toStdLogic(pkg_toStdLogicVector(pkg_toStdLogic((decode_INSTRUCTION and zz_zz_decode_IS_RS2_SIGNED_8) = pkg_stdLogicVector("00000010000000000000000000110000"))) /= pkg_stdLogicVector("0")));
  zz_zz_decode_IS_RS2_SIGNED_9 <= pkg_cat(pkg_toStdLogicVector(pkg_toStdLogic(pkg_toStdLogicVector(pkg_toStdLogic(zz_zz_decode_IS_RS2_SIGNED_10 = zz_zz_decode_IS_RS2_SIGNED_11)) /= pkg_stdLogicVector("0"))),pkg_cat(pkg_toStdLogicVector(pkg_toStdLogic(pkg_cat(zz_zz_decode_IS_RS2_SIGNED_12,zz_zz_decode_IS_RS2_SIGNED_14) /= pkg_stdLogicVector("00"))),pkg_cat(pkg_toStdLogicVector(pkg_toStdLogic(zz_zz_decode_IS_RS2_SIGNED_16 /= zz_zz_decode_IS_RS2_SIGNED_18)),pkg_cat(pkg_toStdLogicVector(zz_zz_decode_IS_RS2_SIGNED_19),pkg_cat(zz_zz_decode_IS_RS2_SIGNED_22,zz_zz_decode_IS_RS2_SIGNED_24)))));
  zz_zz_decode_IS_RS2_SIGNED_8 <= pkg_stdLogicVector("00000010000000000100000001110100");
  zz_zz_decode_IS_RS2_SIGNED_10 <= (decode_INSTRUCTION and pkg_stdLogicVector("00000010000000000111000001010100"));
  zz_zz_decode_IS_RS2_SIGNED_11 <= pkg_stdLogicVector("00000000000000000101000000010000");
  zz_zz_decode_IS_RS2_SIGNED_12 <= pkg_toStdLogicVector(pkg_toStdLogic((decode_INSTRUCTION and zz_zz_decode_IS_RS2_SIGNED_13) = pkg_stdLogicVector("01000000000000000001000000010000")));
  zz_zz_decode_IS_RS2_SIGNED_14 <= pkg_toStdLogicVector(pkg_toStdLogic((decode_INSTRUCTION and zz_zz_decode_IS_RS2_SIGNED_15) = pkg_stdLogicVector("00000000000000000001000000010000")));
  zz_zz_decode_IS_RS2_SIGNED_16 <= pkg_toStdLogicVector(pkg_toStdLogic((decode_INSTRUCTION and zz_zz_decode_IS_RS2_SIGNED_17) = pkg_stdLogicVector("00000000000000000000000000100100")));
  zz_zz_decode_IS_RS2_SIGNED_18 <= pkg_stdLogicVector("0");
  zz_zz_decode_IS_RS2_SIGNED_19 <= pkg_toStdLogic(pkg_toStdLogicVector(pkg_toStdLogic(zz_zz_decode_IS_RS2_SIGNED_20 = zz_zz_decode_IS_RS2_SIGNED_21)) /= pkg_stdLogicVector("0"));
  zz_zz_decode_IS_RS2_SIGNED_22 <= pkg_toStdLogicVector(pkg_toStdLogic(pkg_toStdLogicVector(zz_zz_decode_IS_RS2_SIGNED_23) /= pkg_stdLogicVector("0")));
  zz_zz_decode_IS_RS2_SIGNED_24 <= pkg_cat(pkg_toStdLogicVector(pkg_toStdLogic(zz_zz_decode_IS_RS2_SIGNED_25 /= zz_zz_decode_IS_RS2_SIGNED_30)),pkg_cat(pkg_toStdLogicVector(zz_zz_decode_IS_RS2_SIGNED_31),pkg_cat(zz_zz_decode_IS_RS2_SIGNED_34,zz_zz_decode_IS_RS2_SIGNED_39)));
  zz_zz_decode_IS_RS2_SIGNED_13 <= pkg_stdLogicVector("01000000000000000011000001010100");
  zz_zz_decode_IS_RS2_SIGNED_15 <= pkg_stdLogicVector("00000010000000000111000001010100");
  zz_zz_decode_IS_RS2_SIGNED_17 <= pkg_stdLogicVector("00000000000000000000000001100100");
  zz_zz_decode_IS_RS2_SIGNED_20 <= (decode_INSTRUCTION and pkg_stdLogicVector("00000000000000000001000000000000"));
  zz_zz_decode_IS_RS2_SIGNED_21 <= pkg_stdLogicVector("00000000000000000001000000000000");
  zz_zz_decode_IS_RS2_SIGNED_23 <= pkg_toStdLogic((decode_INSTRUCTION and pkg_stdLogicVector("00000000000000000011000000000000")) = pkg_stdLogicVector("00000000000000000010000000000000"));
  zz_zz_decode_IS_RS2_SIGNED_25 <= pkg_cat(pkg_toStdLogicVector(pkg_toStdLogic(zz_zz_decode_IS_RS2_SIGNED_26 = zz_zz_decode_IS_RS2_SIGNED_27)),pkg_toStdLogicVector(pkg_toStdLogic(zz_zz_decode_IS_RS2_SIGNED_28 = zz_zz_decode_IS_RS2_SIGNED_29)));
  zz_zz_decode_IS_RS2_SIGNED_30 <= pkg_stdLogicVector("00");
  zz_zz_decode_IS_RS2_SIGNED_31 <= pkg_toStdLogic(pkg_toStdLogicVector(pkg_toStdLogic(zz_zz_decode_IS_RS2_SIGNED_32 = zz_zz_decode_IS_RS2_SIGNED_33)) /= pkg_stdLogicVector("0"));
  zz_zz_decode_IS_RS2_SIGNED_34 <= pkg_toStdLogicVector(pkg_toStdLogic(pkg_cat(zz_zz_decode_IS_RS2_SIGNED_35,zz_zz_decode_IS_RS2_SIGNED_37) /= pkg_stdLogicVector("00")));
  zz_zz_decode_IS_RS2_SIGNED_39 <= pkg_cat(pkg_toStdLogicVector(pkg_toStdLogic(zz_zz_decode_IS_RS2_SIGNED_40 /= zz_zz_decode_IS_RS2_SIGNED_42)),pkg_cat(pkg_toStdLogicVector(zz_zz_decode_IS_RS2_SIGNED_43),pkg_cat(zz_zz_decode_IS_RS2_SIGNED_46,zz_zz_decode_IS_RS2_SIGNED_52)));
  zz_zz_decode_IS_RS2_SIGNED_26 <= (decode_INSTRUCTION and pkg_stdLogicVector("00000000000000000010000000010000"));
  zz_zz_decode_IS_RS2_SIGNED_27 <= pkg_stdLogicVector("00000000000000000010000000000000");
  zz_zz_decode_IS_RS2_SIGNED_28 <= (decode_INSTRUCTION and pkg_stdLogicVector("00000000000000000101000000000000"));
  zz_zz_decode_IS_RS2_SIGNED_29 <= pkg_stdLogicVector("00000000000000000001000000000000");
  zz_zz_decode_IS_RS2_SIGNED_32 <= (decode_INSTRUCTION and pkg_stdLogicVector("00000000000000000011000001010000"));
  zz_zz_decode_IS_RS2_SIGNED_33 <= pkg_stdLogicVector("00000000000000000000000001010000");
  zz_zz_decode_IS_RS2_SIGNED_35 <= pkg_toStdLogicVector(pkg_toStdLogic((decode_INSTRUCTION and zz_zz_decode_IS_RS2_SIGNED_36) = pkg_stdLogicVector("00000000000000000001000001010000")));
  zz_zz_decode_IS_RS2_SIGNED_37 <= pkg_toStdLogicVector(pkg_toStdLogic((decode_INSTRUCTION and zz_zz_decode_IS_RS2_SIGNED_38) = pkg_stdLogicVector("00000000000000000010000001010000")));
  zz_zz_decode_IS_RS2_SIGNED_40 <= pkg_toStdLogicVector(pkg_toStdLogic((decode_INSTRUCTION and zz_zz_decode_IS_RS2_SIGNED_41) = pkg_stdLogicVector("00000000000000000100000000001000")));
  zz_zz_decode_IS_RS2_SIGNED_42 <= pkg_stdLogicVector("0");
  zz_zz_decode_IS_RS2_SIGNED_43 <= pkg_toStdLogic(pkg_cat(pkg_toStdLogicVector(zz_zz_decode_IS_RS2_SIGNED_44),pkg_toStdLogicVector(zz_zz_decode_IS_RS2_SIGNED_45)) /= pkg_stdLogicVector("00"));
  zz_zz_decode_IS_RS2_SIGNED_46 <= pkg_toStdLogicVector(pkg_toStdLogic(pkg_cat(zz_zz_decode_IS_RS2_SIGNED_47,zz_zz_decode_IS_RS2_SIGNED_49) /= pkg_stdLogicVector("000")));
  zz_zz_decode_IS_RS2_SIGNED_52 <= pkg_cat(pkg_toStdLogicVector(pkg_toStdLogic(zz_zz_decode_IS_RS2_SIGNED_53 /= zz_zz_decode_IS_RS2_SIGNED_55)),pkg_cat(pkg_toStdLogicVector(zz_zz_decode_IS_RS2_SIGNED_56),pkg_cat(zz_zz_decode_IS_RS2_SIGNED_69,zz_zz_decode_IS_RS2_SIGNED_82)));
  zz_zz_decode_IS_RS2_SIGNED_36 <= pkg_stdLogicVector("00000000000000000001000001010000");
  zz_zz_decode_IS_RS2_SIGNED_38 <= pkg_stdLogicVector("00000000000000000010000001010000");
  zz_zz_decode_IS_RS2_SIGNED_41 <= pkg_stdLogicVector("00000000000000000100000001001000");
  zz_zz_decode_IS_RS2_SIGNED_44 <= pkg_toStdLogic((decode_INSTRUCTION and pkg_stdLogicVector("00000000000000000000000000110100")) = pkg_stdLogicVector("00000000000000000000000000100000"));
  zz_zz_decode_IS_RS2_SIGNED_45 <= pkg_toStdLogic((decode_INSTRUCTION and pkg_stdLogicVector("00000000000000000000000001100100")) = pkg_stdLogicVector("00000000000000000000000000100000"));
  zz_zz_decode_IS_RS2_SIGNED_47 <= pkg_toStdLogicVector(pkg_toStdLogic((decode_INSTRUCTION and zz_zz_decode_IS_RS2_SIGNED_48) = pkg_stdLogicVector("00000000000000000000000001000000")));
  zz_zz_decode_IS_RS2_SIGNED_49 <= pkg_cat(pkg_toStdLogicVector(zz_decode_IS_RS2_SIGNED_2),pkg_toStdLogicVector(pkg_toStdLogic(zz_zz_decode_IS_RS2_SIGNED_50 = zz_zz_decode_IS_RS2_SIGNED_51)));
  zz_zz_decode_IS_RS2_SIGNED_53 <= pkg_toStdLogicVector(pkg_toStdLogic((decode_INSTRUCTION and zz_zz_decode_IS_RS2_SIGNED_54) = pkg_stdLogicVector("00000000000000000000000000100000")));
  zz_zz_decode_IS_RS2_SIGNED_55 <= pkg_stdLogicVector("0");
  zz_zz_decode_IS_RS2_SIGNED_56 <= pkg_toStdLogic(pkg_cat(pkg_toStdLogicVector(zz_zz_decode_IS_RS2_SIGNED_57),pkg_cat(zz_zz_decode_IS_RS2_SIGNED_59,zz_zz_decode_IS_RS2_SIGNED_60)) /= pkg_stdLogicVector("00000"));
  zz_zz_decode_IS_RS2_SIGNED_69 <= pkg_toStdLogicVector(pkg_toStdLogic(pkg_cat(zz_zz_decode_IS_RS2_SIGNED_70,zz_zz_decode_IS_RS2_SIGNED_71) /= pkg_stdLogicVector("00000")));
  zz_zz_decode_IS_RS2_SIGNED_82 <= pkg_cat(pkg_toStdLogicVector(pkg_toStdLogic(zz_zz_decode_IS_RS2_SIGNED_83 /= zz_zz_decode_IS_RS2_SIGNED_96)),pkg_cat(pkg_toStdLogicVector(zz_zz_decode_IS_RS2_SIGNED_97),pkg_cat(zz_zz_decode_IS_RS2_SIGNED_102,zz_zz_decode_IS_RS2_SIGNED_107)));
  zz_zz_decode_IS_RS2_SIGNED_48 <= pkg_stdLogicVector("00000000000000000000000001010000");
  zz_zz_decode_IS_RS2_SIGNED_50 <= (decode_INSTRUCTION and pkg_stdLogicVector("00000000000000000011000001000000"));
  zz_zz_decode_IS_RS2_SIGNED_51 <= pkg_stdLogicVector("00000000000000000000000001000000");
  zz_zz_decode_IS_RS2_SIGNED_54 <= pkg_stdLogicVector("00000000000000000000000000100000");
  zz_zz_decode_IS_RS2_SIGNED_57 <= pkg_toStdLogic((decode_INSTRUCTION and zz_zz_decode_IS_RS2_SIGNED_58) = pkg_stdLogicVector("00000000000000000000000001000000"));
  zz_zz_decode_IS_RS2_SIGNED_59 <= pkg_toStdLogicVector(zz_decode_IS_RS2_SIGNED_3);
  zz_zz_decode_IS_RS2_SIGNED_60 <= pkg_cat(pkg_toStdLogicVector(zz_zz_decode_IS_RS2_SIGNED_61),pkg_cat(zz_zz_decode_IS_RS2_SIGNED_63,zz_zz_decode_IS_RS2_SIGNED_66));
  zz_zz_decode_IS_RS2_SIGNED_70 <= pkg_toStdLogicVector(zz_decode_IS_RS2_SIGNED_3);
  zz_zz_decode_IS_RS2_SIGNED_71 <= pkg_cat(pkg_toStdLogicVector(zz_zz_decode_IS_RS2_SIGNED_72),pkg_cat(zz_zz_decode_IS_RS2_SIGNED_74,zz_zz_decode_IS_RS2_SIGNED_77));
  zz_zz_decode_IS_RS2_SIGNED_83 <= pkg_cat(pkg_toStdLogicVector(zz_decode_IS_RS2_SIGNED_4),pkg_cat(zz_zz_decode_IS_RS2_SIGNED_84,zz_zz_decode_IS_RS2_SIGNED_87));
  zz_zz_decode_IS_RS2_SIGNED_96 <= pkg_stdLogicVector("000000");
  zz_zz_decode_IS_RS2_SIGNED_97 <= pkg_toStdLogic(pkg_cat(zz_zz_decode_IS_RS2_SIGNED_98,zz_zz_decode_IS_RS2_SIGNED_99) /= pkg_stdLogicVector("00"));
  zz_zz_decode_IS_RS2_SIGNED_102 <= pkg_toStdLogicVector(pkg_toStdLogic(zz_zz_decode_IS_RS2_SIGNED_103 /= zz_zz_decode_IS_RS2_SIGNED_106));
  zz_zz_decode_IS_RS2_SIGNED_107 <= pkg_cat(pkg_toStdLogicVector(zz_zz_decode_IS_RS2_SIGNED_108),pkg_cat(zz_zz_decode_IS_RS2_SIGNED_111,zz_zz_decode_IS_RS2_SIGNED_116));
  zz_zz_decode_IS_RS2_SIGNED_58 <= pkg_stdLogicVector("00000000000000000000000001000000");
  zz_zz_decode_IS_RS2_SIGNED_61 <= pkg_toStdLogic((decode_INSTRUCTION and zz_zz_decode_IS_RS2_SIGNED_62) = pkg_stdLogicVector("00000000000000000100000000100000"));
  zz_zz_decode_IS_RS2_SIGNED_63 <= pkg_toStdLogicVector(pkg_toStdLogic(zz_zz_decode_IS_RS2_SIGNED_64 = zz_zz_decode_IS_RS2_SIGNED_65));
  zz_zz_decode_IS_RS2_SIGNED_66 <= pkg_toStdLogicVector(pkg_toStdLogic(zz_zz_decode_IS_RS2_SIGNED_67 = zz_zz_decode_IS_RS2_SIGNED_68));
  zz_zz_decode_IS_RS2_SIGNED_72 <= pkg_toStdLogic((decode_INSTRUCTION and zz_zz_decode_IS_RS2_SIGNED_73) = pkg_stdLogicVector("00000000000000000010000000010000"));
  zz_zz_decode_IS_RS2_SIGNED_74 <= pkg_toStdLogicVector(pkg_toStdLogic(zz_zz_decode_IS_RS2_SIGNED_75 = zz_zz_decode_IS_RS2_SIGNED_76));
  zz_zz_decode_IS_RS2_SIGNED_77 <= pkg_cat(pkg_toStdLogicVector(zz_zz_decode_IS_RS2_SIGNED_78),pkg_toStdLogicVector(zz_zz_decode_IS_RS2_SIGNED_80));
  zz_zz_decode_IS_RS2_SIGNED_84 <= pkg_toStdLogicVector(pkg_toStdLogic(zz_zz_decode_IS_RS2_SIGNED_85 = zz_zz_decode_IS_RS2_SIGNED_86));
  zz_zz_decode_IS_RS2_SIGNED_87 <= pkg_cat(pkg_toStdLogicVector(zz_zz_decode_IS_RS2_SIGNED_88),pkg_cat(zz_zz_decode_IS_RS2_SIGNED_90,zz_zz_decode_IS_RS2_SIGNED_93));
  zz_zz_decode_IS_RS2_SIGNED_98 <= pkg_toStdLogicVector(zz_decode_IS_RS2_SIGNED_3);
  zz_zz_decode_IS_RS2_SIGNED_99 <= pkg_toStdLogicVector(pkg_toStdLogic(zz_zz_decode_IS_RS2_SIGNED_100 = zz_zz_decode_IS_RS2_SIGNED_101));
  zz_zz_decode_IS_RS2_SIGNED_103 <= pkg_cat(pkg_toStdLogicVector(zz_decode_IS_RS2_SIGNED_3),pkg_toStdLogicVector(zz_zz_decode_IS_RS2_SIGNED_104));
  zz_zz_decode_IS_RS2_SIGNED_106 <= pkg_stdLogicVector("00");
  zz_zz_decode_IS_RS2_SIGNED_108 <= pkg_toStdLogic(pkg_toStdLogicVector(zz_zz_decode_IS_RS2_SIGNED_109) /= pkg_stdLogicVector("0"));
  zz_zz_decode_IS_RS2_SIGNED_111 <= pkg_toStdLogicVector(pkg_toStdLogic(zz_zz_decode_IS_RS2_SIGNED_112 /= zz_zz_decode_IS_RS2_SIGNED_115));
  zz_zz_decode_IS_RS2_SIGNED_116 <= pkg_cat(pkg_toStdLogicVector(zz_zz_decode_IS_RS2_SIGNED_117),pkg_cat(zz_zz_decode_IS_RS2_SIGNED_126,zz_zz_decode_IS_RS2_SIGNED_130));
  zz_zz_decode_IS_RS2_SIGNED_62 <= pkg_stdLogicVector("00000000000000000100000000100000");
  zz_zz_decode_IS_RS2_SIGNED_64 <= (decode_INSTRUCTION and pkg_stdLogicVector("00000000000000000000000000110000"));
  zz_zz_decode_IS_RS2_SIGNED_65 <= pkg_stdLogicVector("00000000000000000000000000010000");
  zz_zz_decode_IS_RS2_SIGNED_67 <= (decode_INSTRUCTION and pkg_stdLogicVector("00000010000000000000000000100000"));
  zz_zz_decode_IS_RS2_SIGNED_68 <= pkg_stdLogicVector("00000000000000000000000000100000");
  zz_zz_decode_IS_RS2_SIGNED_73 <= pkg_stdLogicVector("00000000000000000010000000110000");
  zz_zz_decode_IS_RS2_SIGNED_75 <= (decode_INSTRUCTION and pkg_stdLogicVector("00000000000000000001000000110000"));
  zz_zz_decode_IS_RS2_SIGNED_76 <= pkg_stdLogicVector("00000000000000000000000000010000");
  zz_zz_decode_IS_RS2_SIGNED_78 <= pkg_toStdLogic((decode_INSTRUCTION and zz_zz_decode_IS_RS2_SIGNED_79) = pkg_stdLogicVector("00000000000000000010000000100000"));
  zz_zz_decode_IS_RS2_SIGNED_80 <= pkg_toStdLogic((decode_INSTRUCTION and zz_zz_decode_IS_RS2_SIGNED_81) = pkg_stdLogicVector("00000000000000000000000000100000"));
  zz_zz_decode_IS_RS2_SIGNED_85 <= (decode_INSTRUCTION and pkg_stdLogicVector("00000000000000000001000000010000"));
  zz_zz_decode_IS_RS2_SIGNED_86 <= pkg_stdLogicVector("00000000000000000001000000010000");
  zz_zz_decode_IS_RS2_SIGNED_88 <= pkg_toStdLogic((decode_INSTRUCTION and zz_zz_decode_IS_RS2_SIGNED_89) = pkg_stdLogicVector("00000000000000000010000000010000"));
  zz_zz_decode_IS_RS2_SIGNED_90 <= pkg_toStdLogicVector(pkg_toStdLogic(zz_zz_decode_IS_RS2_SIGNED_91 = zz_zz_decode_IS_RS2_SIGNED_92));
  zz_zz_decode_IS_RS2_SIGNED_93 <= pkg_cat(pkg_toStdLogicVector(zz_zz_decode_IS_RS2_SIGNED_94),pkg_toStdLogicVector(zz_zz_decode_IS_RS2_SIGNED_95));
  zz_zz_decode_IS_RS2_SIGNED_100 <= (decode_INSTRUCTION and pkg_stdLogicVector("00000000000000000000000001110000"));
  zz_zz_decode_IS_RS2_SIGNED_101 <= pkg_stdLogicVector("00000000000000000000000000100000");
  zz_zz_decode_IS_RS2_SIGNED_104 <= pkg_toStdLogic((decode_INSTRUCTION and zz_zz_decode_IS_RS2_SIGNED_105) = pkg_stdLogicVector("00000000000000000000000000000000"));
  zz_zz_decode_IS_RS2_SIGNED_109 <= pkg_toStdLogic((decode_INSTRUCTION and zz_zz_decode_IS_RS2_SIGNED_110) = pkg_stdLogicVector("00000000000000000100000000010000"));
  zz_zz_decode_IS_RS2_SIGNED_112 <= pkg_toStdLogicVector(pkg_toStdLogic(zz_zz_decode_IS_RS2_SIGNED_113 = zz_zz_decode_IS_RS2_SIGNED_114));
  zz_zz_decode_IS_RS2_SIGNED_115 <= pkg_stdLogicVector("0");
  zz_zz_decode_IS_RS2_SIGNED_117 <= pkg_toStdLogic(pkg_cat(zz_zz_decode_IS_RS2_SIGNED_118,zz_zz_decode_IS_RS2_SIGNED_120) /= pkg_stdLogicVector("00000"));
  zz_zz_decode_IS_RS2_SIGNED_126 <= pkg_toStdLogicVector(pkg_toStdLogic(zz_zz_decode_IS_RS2_SIGNED_127 /= zz_zz_decode_IS_RS2_SIGNED_129));
  zz_zz_decode_IS_RS2_SIGNED_130 <= pkg_cat(pkg_toStdLogicVector(zz_zz_decode_IS_RS2_SIGNED_131),pkg_cat(zz_zz_decode_IS_RS2_SIGNED_137,zz_zz_decode_IS_RS2_SIGNED_141));
  zz_zz_decode_IS_RS2_SIGNED_79 <= pkg_stdLogicVector("00000010000000000010000001100000");
  zz_zz_decode_IS_RS2_SIGNED_81 <= pkg_stdLogicVector("00000010000000000011000000100000");
  zz_zz_decode_IS_RS2_SIGNED_89 <= pkg_stdLogicVector("00000000000000000010000000010000");
  zz_zz_decode_IS_RS2_SIGNED_91 <= (decode_INSTRUCTION and pkg_stdLogicVector("00000000000000000000000001010000"));
  zz_zz_decode_IS_RS2_SIGNED_92 <= pkg_stdLogicVector("00000000000000000000000000010000");
  zz_zz_decode_IS_RS2_SIGNED_94 <= pkg_toStdLogic((decode_INSTRUCTION and pkg_stdLogicVector("00000000000000000000000000001100")) = pkg_stdLogicVector("00000000000000000000000000000100"));
  zz_zz_decode_IS_RS2_SIGNED_95 <= pkg_toStdLogic((decode_INSTRUCTION and pkg_stdLogicVector("00000000000000000000000000101000")) = pkg_stdLogicVector("00000000000000000000000000000000"));
  zz_zz_decode_IS_RS2_SIGNED_105 <= pkg_stdLogicVector("00000000000000000000000000100000");
  zz_zz_decode_IS_RS2_SIGNED_110 <= pkg_stdLogicVector("00000000000000000100000000010100");
  zz_zz_decode_IS_RS2_SIGNED_113 <= (decode_INSTRUCTION and pkg_stdLogicVector("00000000000000000110000000010100"));
  zz_zz_decode_IS_RS2_SIGNED_114 <= pkg_stdLogicVector("00000000000000000010000000010000");
  zz_zz_decode_IS_RS2_SIGNED_118 <= pkg_toStdLogicVector(pkg_toStdLogic((decode_INSTRUCTION and zz_zz_decode_IS_RS2_SIGNED_119) = pkg_stdLogicVector("00000000000000000000000000000000")));
  zz_zz_decode_IS_RS2_SIGNED_120 <= pkg_cat(pkg_toStdLogicVector(zz_decode_IS_RS2_SIGNED_2),pkg_cat(pkg_toStdLogicVector(zz_zz_decode_IS_RS2_SIGNED_121),pkg_cat(zz_zz_decode_IS_RS2_SIGNED_122,zz_zz_decode_IS_RS2_SIGNED_124)));
  zz_zz_decode_IS_RS2_SIGNED_127 <= pkg_toStdLogicVector(pkg_toStdLogic((decode_INSTRUCTION and zz_zz_decode_IS_RS2_SIGNED_128) = pkg_stdLogicVector("00000000000000000000000000000000")));
  zz_zz_decode_IS_RS2_SIGNED_129 <= pkg_stdLogicVector("0");
  zz_zz_decode_IS_RS2_SIGNED_131 <= pkg_toStdLogic(pkg_cat(pkg_toStdLogicVector(zz_zz_decode_IS_RS2_SIGNED_132),pkg_cat(zz_zz_decode_IS_RS2_SIGNED_133,zz_zz_decode_IS_RS2_SIGNED_135)) /= pkg_stdLogicVector("000"));
  zz_zz_decode_IS_RS2_SIGNED_137 <= pkg_toStdLogicVector(pkg_toStdLogic(pkg_cat(zz_zz_decode_IS_RS2_SIGNED_138,zz_zz_decode_IS_RS2_SIGNED_140) /= pkg_stdLogicVector("00")));
  zz_zz_decode_IS_RS2_SIGNED_141 <= pkg_cat(pkg_toStdLogicVector(pkg_toStdLogic(zz_zz_decode_IS_RS2_SIGNED_142 /= zz_zz_decode_IS_RS2_SIGNED_145)),pkg_toStdLogicVector(pkg_toStdLogic(zz_zz_decode_IS_RS2_SIGNED_146 /= zz_zz_decode_IS_RS2_SIGNED_148)));
  zz_zz_decode_IS_RS2_SIGNED_119 <= pkg_stdLogicVector("00000000000000000000000001000100");
  zz_zz_decode_IS_RS2_SIGNED_121 <= pkg_toStdLogic((decode_INSTRUCTION and pkg_stdLogicVector("00000000000000000110000000000100")) = pkg_stdLogicVector("00000000000000000010000000000000"));
  zz_zz_decode_IS_RS2_SIGNED_122 <= pkg_toStdLogicVector(pkg_toStdLogic((decode_INSTRUCTION and zz_zz_decode_IS_RS2_SIGNED_123) = pkg_stdLogicVector("00000000000000000001000000000000")));
  zz_zz_decode_IS_RS2_SIGNED_124 <= pkg_toStdLogicVector(pkg_toStdLogic((decode_INSTRUCTION and zz_zz_decode_IS_RS2_SIGNED_125) = pkg_stdLogicVector("00000000000000000100000000000000")));
  zz_zz_decode_IS_RS2_SIGNED_128 <= pkg_stdLogicVector("00000000000000000000000001011000");
  zz_zz_decode_IS_RS2_SIGNED_132 <= pkg_toStdLogic((decode_INSTRUCTION and pkg_stdLogicVector("00000000000000000000000001000100")) = pkg_stdLogicVector("00000000000000000000000001000000"));
  zz_zz_decode_IS_RS2_SIGNED_133 <= pkg_toStdLogicVector(pkg_toStdLogic((decode_INSTRUCTION and zz_zz_decode_IS_RS2_SIGNED_134) = pkg_stdLogicVector("00000000000000000010000000010000")));
  zz_zz_decode_IS_RS2_SIGNED_135 <= pkg_toStdLogicVector(pkg_toStdLogic((decode_INSTRUCTION and zz_zz_decode_IS_RS2_SIGNED_136) = pkg_stdLogicVector("01000000000000000000000000110000")));
  zz_zz_decode_IS_RS2_SIGNED_138 <= pkg_toStdLogicVector(pkg_toStdLogic((decode_INSTRUCTION and zz_zz_decode_IS_RS2_SIGNED_139) = pkg_stdLogicVector("00000000000000000000000000000100")));
  zz_zz_decode_IS_RS2_SIGNED_140 <= pkg_toStdLogicVector(zz_decode_IS_RS2_SIGNED_1);
  zz_zz_decode_IS_RS2_SIGNED_142 <= pkg_cat(pkg_toStdLogicVector(pkg_toStdLogic(zz_zz_decode_IS_RS2_SIGNED_143 = zz_zz_decode_IS_RS2_SIGNED_144)),pkg_toStdLogicVector(zz_decode_IS_RS2_SIGNED_1));
  zz_zz_decode_IS_RS2_SIGNED_145 <= pkg_stdLogicVector("00");
  zz_zz_decode_IS_RS2_SIGNED_146 <= pkg_toStdLogicVector(pkg_toStdLogic((decode_INSTRUCTION and zz_zz_decode_IS_RS2_SIGNED_147) = pkg_stdLogicVector("00000000000000000001000000001000")));
  zz_zz_decode_IS_RS2_SIGNED_148 <= pkg_stdLogicVector("0");
  zz_zz_decode_IS_RS2_SIGNED_123 <= pkg_stdLogicVector("00000000000000000101000000000100");
  zz_zz_decode_IS_RS2_SIGNED_125 <= pkg_stdLogicVector("00000000000000000100000001010000");
  zz_zz_decode_IS_RS2_SIGNED_134 <= pkg_stdLogicVector("00000000000000000010000000010100");
  zz_zz_decode_IS_RS2_SIGNED_136 <= pkg_stdLogicVector("01000000000000000000000000110100");
  zz_zz_decode_IS_RS2_SIGNED_139 <= pkg_stdLogicVector("00000000000000000000000000010100");
  zz_zz_decode_IS_RS2_SIGNED_143 <= (decode_INSTRUCTION and pkg_stdLogicVector("00000000000000000000000001000100"));
  zz_zz_decode_IS_RS2_SIGNED_144 <= pkg_stdLogicVector("00000000000000000000000000000100");
  zz_zz_decode_IS_RS2_SIGNED_147 <= pkg_stdLogicVector("00000000000000000101000001001000");
  zz_execute_BranchPlugin_branch_src2_6 <= pkg_toStdLogicVector(pkg_extract(execute_INSTRUCTION,31));
  zz_execute_BranchPlugin_branch_src2_7 <= pkg_extract(execute_INSTRUCTION,19,12);
  zz_execute_BranchPlugin_branch_src2_8 <= pkg_extract(execute_INSTRUCTION,20);
  zz_execute_BranchPlugin_branch_src2_9 <= pkg_toStdLogicVector(pkg_extract(execute_INSTRUCTION,31));
  zz_execute_BranchPlugin_branch_src2_10 <= pkg_toStdLogicVector(pkg_extract(execute_INSTRUCTION,7));
  process(io_mainClk)
  begin
    if rising_edge(io_mainClk) then
      if zz_decode_RegFilePlugin_rs1Data = '1' then
        zz_RegFilePlugin_regFile_port0 <= RegFilePlugin_regFile(to_integer(decode_RegFilePlugin_regFileReadAddress1));
      end if;
    end if;
  end process;

  process(io_mainClk)
  begin
    if rising_edge(io_mainClk) then
      if zz_decode_RegFilePlugin_rs2Data = '1' then
        zz_RegFilePlugin_regFile_port0_1 <= RegFilePlugin_regFile(to_integer(decode_RegFilePlugin_regFileReadAddress2));
      end if;
    end if;
  end process;

  process(io_mainClk)
  begin
    if rising_edge(io_mainClk) then
      if zz_1 = '1' then
        RegFilePlugin_regFile(to_integer(lastStageRegFileWrite_payload_address)) <= lastStageRegFileWrite_payload_data;
      end if;
    end if;
  end process;

  IBusCachedPlugin_cache : entity work.InstructionCache
    port map ( 
      io_flush => IBusCachedPlugin_cache_io_flush,
      io_cpu_prefetch_isValid => IBusCachedPlugin_cache_io_cpu_prefetch_isValid,
      io_cpu_prefetch_haltIt => IBusCachedPlugin_cache_io_cpu_prefetch_haltIt,
      io_cpu_prefetch_pc => IBusCachedPlugin_iBusRsp_stages_0_input_payload,
      io_cpu_fetch_isValid => IBusCachedPlugin_cache_io_cpu_fetch_isValid,
      io_cpu_fetch_isStuck => IBusCachedPlugin_cache_io_cpu_fetch_isStuck,
      io_cpu_fetch_isRemoved => IBusCachedPlugin_cache_io_cpu_fetch_isRemoved,
      io_cpu_fetch_pc => IBusCachedPlugin_iBusRsp_stages_1_input_payload,
      io_cpu_fetch_data => IBusCachedPlugin_cache_io_cpu_fetch_data,
      io_cpu_fetch_mmuRsp_physicalAddress => IBusCachedPlugin_mmuBus_rsp_physicalAddress,
      io_cpu_fetch_mmuRsp_isIoAccess => IBusCachedPlugin_mmuBus_rsp_isIoAccess,
      io_cpu_fetch_mmuRsp_isPaging => IBusCachedPlugin_mmuBus_rsp_isPaging,
      io_cpu_fetch_mmuRsp_allowRead => IBusCachedPlugin_mmuBus_rsp_allowRead,
      io_cpu_fetch_mmuRsp_allowWrite => IBusCachedPlugin_mmuBus_rsp_allowWrite,
      io_cpu_fetch_mmuRsp_allowExecute => IBusCachedPlugin_mmuBus_rsp_allowExecute,
      io_cpu_fetch_mmuRsp_exception => IBusCachedPlugin_mmuBus_rsp_exception,
      io_cpu_fetch_mmuRsp_refilling => IBusCachedPlugin_mmuBus_rsp_refilling,
      io_cpu_fetch_mmuRsp_bypassTranslation => IBusCachedPlugin_mmuBus_rsp_bypassTranslation,
      io_cpu_fetch_physicalAddress => IBusCachedPlugin_cache_io_cpu_fetch_physicalAddress,
      io_cpu_decode_isValid => IBusCachedPlugin_cache_io_cpu_decode_isValid,
      io_cpu_decode_isStuck => IBusCachedPlugin_cache_io_cpu_decode_isStuck,
      io_cpu_decode_pc => IBusCachedPlugin_iBusRsp_stages_2_input_payload,
      io_cpu_decode_physicalAddress => IBusCachedPlugin_cache_io_cpu_decode_physicalAddress,
      io_cpu_decode_data => IBusCachedPlugin_cache_io_cpu_decode_data,
      io_cpu_decode_cacheMiss => IBusCachedPlugin_cache_io_cpu_decode_cacheMiss,
      io_cpu_decode_error => IBusCachedPlugin_cache_io_cpu_decode_error,
      io_cpu_decode_mmuRefilling => IBusCachedPlugin_cache_io_cpu_decode_mmuRefilling,
      io_cpu_decode_mmuException => IBusCachedPlugin_cache_io_cpu_decode_mmuException,
      io_cpu_decode_isUser => IBusCachedPlugin_cache_io_cpu_decode_isUser,
      io_cpu_fill_valid => IBusCachedPlugin_cache_io_cpu_fill_valid,
      io_cpu_fill_payload => IBusCachedPlugin_cache_io_cpu_decode_physicalAddress,
      io_mem_cmd_valid => IBusCachedPlugin_cache_io_mem_cmd_valid,
      io_mem_cmd_ready => iBus_cmd_ready,
      io_mem_cmd_payload_address => IBusCachedPlugin_cache_io_mem_cmd_payload_address,
      io_mem_cmd_payload_size => IBusCachedPlugin_cache_io_mem_cmd_payload_size,
      io_mem_rsp_valid => iBus_rsp_valid,
      io_mem_rsp_payload_data => iBus_rsp_payload_data,
      io_mem_rsp_payload_error => iBus_rsp_payload_error,
      io_mainClk => io_mainClk,
      resetCtrl_systemReset => resetCtrl_systemReset 
    );
  dataCache_1 : entity work.DataCache
    port map ( 
      io_cpu_execute_isValid => dataCache_1_io_cpu_execute_isValid,
      io_cpu_execute_address => dataCache_1_io_cpu_execute_address,
      io_cpu_execute_haltIt => dataCache_1_io_cpu_execute_haltIt,
      io_cpu_execute_args_wr => execute_MEMORY_WR,
      io_cpu_execute_args_size => execute_DBusCachedPlugin_size,
      io_cpu_execute_args_totalyConsistent => execute_MEMORY_FORCE_CONSTISTENCY,
      io_cpu_execute_refilling => dataCache_1_io_cpu_execute_refilling,
      io_cpu_memory_isValid => dataCache_1_io_cpu_memory_isValid,
      io_cpu_memory_isStuck => memory_arbitration_isStuck,
      io_cpu_memory_isWrite => dataCache_1_io_cpu_memory_isWrite,
      io_cpu_memory_address => dataCache_1_io_cpu_memory_address,
      io_cpu_memory_mmuRsp_physicalAddress => DBusCachedPlugin_mmuBus_rsp_physicalAddress,
      io_cpu_memory_mmuRsp_isIoAccess => dataCache_1_io_cpu_memory_mmuRsp_isIoAccess,
      io_cpu_memory_mmuRsp_isPaging => DBusCachedPlugin_mmuBus_rsp_isPaging,
      io_cpu_memory_mmuRsp_allowRead => DBusCachedPlugin_mmuBus_rsp_allowRead,
      io_cpu_memory_mmuRsp_allowWrite => DBusCachedPlugin_mmuBus_rsp_allowWrite,
      io_cpu_memory_mmuRsp_allowExecute => DBusCachedPlugin_mmuBus_rsp_allowExecute,
      io_cpu_memory_mmuRsp_exception => DBusCachedPlugin_mmuBus_rsp_exception,
      io_cpu_memory_mmuRsp_refilling => DBusCachedPlugin_mmuBus_rsp_refilling,
      io_cpu_memory_mmuRsp_bypassTranslation => DBusCachedPlugin_mmuBus_rsp_bypassTranslation,
      io_cpu_writeBack_isValid => dataCache_1_io_cpu_writeBack_isValid,
      io_cpu_writeBack_isStuck => writeBack_arbitration_isStuck,
      io_cpu_writeBack_isFiring => writeBack_arbitration_isFiring,
      io_cpu_writeBack_isUser => dataCache_1_io_cpu_writeBack_isUser,
      io_cpu_writeBack_haltIt => dataCache_1_io_cpu_writeBack_haltIt,
      io_cpu_writeBack_isWrite => dataCache_1_io_cpu_writeBack_isWrite,
      io_cpu_writeBack_storeData => dataCache_1_io_cpu_writeBack_storeData,
      io_cpu_writeBack_data => dataCache_1_io_cpu_writeBack_data,
      io_cpu_writeBack_address => dataCache_1_io_cpu_writeBack_address,
      io_cpu_writeBack_mmuException => dataCache_1_io_cpu_writeBack_mmuException,
      io_cpu_writeBack_unalignedAccess => dataCache_1_io_cpu_writeBack_unalignedAccess,
      io_cpu_writeBack_accessError => dataCache_1_io_cpu_writeBack_accessError,
      io_cpu_writeBack_keepMemRspData => dataCache_1_io_cpu_writeBack_keepMemRspData,
      io_cpu_writeBack_fence_SW => dataCache_1_io_cpu_writeBack_fence_SW,
      io_cpu_writeBack_fence_SR => dataCache_1_io_cpu_writeBack_fence_SR,
      io_cpu_writeBack_fence_SO => dataCache_1_io_cpu_writeBack_fence_SO,
      io_cpu_writeBack_fence_SI => dataCache_1_io_cpu_writeBack_fence_SI,
      io_cpu_writeBack_fence_PW => dataCache_1_io_cpu_writeBack_fence_PW,
      io_cpu_writeBack_fence_PR => dataCache_1_io_cpu_writeBack_fence_PR,
      io_cpu_writeBack_fence_PO => dataCache_1_io_cpu_writeBack_fence_PO,
      io_cpu_writeBack_fence_PI => dataCache_1_io_cpu_writeBack_fence_PI,
      io_cpu_writeBack_fence_FM => dataCache_1_io_cpu_writeBack_fence_FM,
      io_cpu_writeBack_exclusiveOk => dataCache_1_io_cpu_writeBack_exclusiveOk,
      io_cpu_redo => dataCache_1_io_cpu_redo,
      io_cpu_flush_valid => dataCache_1_io_cpu_flush_valid,
      io_cpu_flush_ready => dataCache_1_io_cpu_flush_ready,
      io_cpu_flush_payload_singleLine => dataCache_1_io_cpu_flush_payload_singleLine,
      io_cpu_flush_payload_lineId => dataCache_1_io_cpu_flush_payload_lineId,
      io_cpu_writesPending => dataCache_1_io_cpu_writesPending,
      io_mem_cmd_valid => dataCache_1_io_mem_cmd_valid,
      io_mem_cmd_ready => dBus_cmd_ready,
      io_mem_cmd_payload_wr => dataCache_1_io_mem_cmd_payload_wr,
      io_mem_cmd_payload_uncached => dataCache_1_io_mem_cmd_payload_uncached,
      io_mem_cmd_payload_address => dataCache_1_io_mem_cmd_payload_address,
      io_mem_cmd_payload_data => dataCache_1_io_mem_cmd_payload_data,
      io_mem_cmd_payload_mask => dataCache_1_io_mem_cmd_payload_mask,
      io_mem_cmd_payload_size => dataCache_1_io_mem_cmd_payload_size,
      io_mem_cmd_payload_last => dataCache_1_io_mem_cmd_payload_last,
      io_mem_rsp_valid => dBus_rsp_valid,
      io_mem_rsp_payload_last => dBus_rsp_payload_last,
      io_mem_rsp_payload_data => dBus_rsp_payload_data,
      io_mem_rsp_payload_error => dBus_rsp_payload_error,
      io_mainClk => io_mainClk,
      resetCtrl_systemReset => resetCtrl_systemReset 
    );
  process(zz_IBusCachedPlugin_jump_pcLoad_payload_6,DBusCachedPlugin_redoBranch_payload,CsrPlugin_jumpInterface_payload,BranchPlugin_jumpInterface_payload,IBusCachedPlugin_predictionJumpInterface_payload)
  begin
    case zz_IBusCachedPlugin_jump_pcLoad_payload_6 is
      when "00" =>
        zz_IBusCachedPlugin_jump_pcLoad_payload_5 <= DBusCachedPlugin_redoBranch_payload;
      when "01" =>
        zz_IBusCachedPlugin_jump_pcLoad_payload_5 <= CsrPlugin_jumpInterface_payload;
      when "10" =>
        zz_IBusCachedPlugin_jump_pcLoad_payload_5 <= BranchPlugin_jumpInterface_payload;
      when others =>
        zz_IBusCachedPlugin_jump_pcLoad_payload_5 <= IBusCachedPlugin_predictionJumpInterface_payload;
    end case;
  end process;

  process(zz_writeBack_DBusCachedPlugin_rspShifted_1,writeBack_DBusCachedPlugin_rspSplits_0,writeBack_DBusCachedPlugin_rspSplits_1,writeBack_DBusCachedPlugin_rspSplits_2,writeBack_DBusCachedPlugin_rspSplits_3)
  begin
    case zz_writeBack_DBusCachedPlugin_rspShifted_1 is
      when "00" =>
        zz_writeBack_DBusCachedPlugin_rspShifted <= writeBack_DBusCachedPlugin_rspSplits_0;
      when "01" =>
        zz_writeBack_DBusCachedPlugin_rspShifted <= writeBack_DBusCachedPlugin_rspSplits_1;
      when "10" =>
        zz_writeBack_DBusCachedPlugin_rspShifted <= writeBack_DBusCachedPlugin_rspSplits_2;
      when others =>
        zz_writeBack_DBusCachedPlugin_rspShifted <= writeBack_DBusCachedPlugin_rspSplits_3;
    end case;
  end process;

  process(zz_writeBack_DBusCachedPlugin_rspShifted_3,writeBack_DBusCachedPlugin_rspSplits_1,writeBack_DBusCachedPlugin_rspSplits_3)
  begin
    case zz_writeBack_DBusCachedPlugin_rspShifted_3 is
      when "0" =>
        zz_writeBack_DBusCachedPlugin_rspShifted_2 <= writeBack_DBusCachedPlugin_rspSplits_1;
      when others =>
        zz_writeBack_DBusCachedPlugin_rspShifted_2 <= writeBack_DBusCachedPlugin_rspSplits_3;
    end case;
  end process;

  memory_MUL_LOW <= (((pkg_signed("0000000000000000000000000000000000000000000000000000") + pkg_resize(signed(pkg_cat(pkg_toStdLogicVector(pkg_toStdLogic(false)),std_logic_vector(memory_MUL_LL))),52)) + pkg_resize(pkg_shiftLeft(memory_MUL_LH,16),52)) + pkg_resize(pkg_shiftLeft(memory_MUL_HL,16),52));
  memory_MUL_HH <= execute_to_memory_MUL_HH;
  execute_MUL_HH <= (execute_MulPlugin_aHigh * execute_MulPlugin_bHigh);
  execute_MUL_HL <= (execute_MulPlugin_aHigh * execute_MulPlugin_bSLow);
  execute_MUL_LH <= (execute_MulPlugin_aSLow * execute_MulPlugin_bHigh);
  execute_MUL_LL <= (execute_MulPlugin_aULow * execute_MulPlugin_bULow);
  execute_SHIFT_RIGHT <= std_logic_vector(pkg_extract(pkg_shiftRight(signed(pkg_cat(pkg_toStdLogicVector((pkg_toStdLogic(execute_SHIFT_CTRL = ShiftCtrlEnum_seq_SRA_1) and pkg_extract(execute_FullBarrelShifterPlugin_reversed,31))),execute_FullBarrelShifterPlugin_reversed)),execute_FullBarrelShifterPlugin_amplitude),31,0));
  execute_REGFILE_WRITE_DATA <= zz_execute_REGFILE_WRITE_DATA;
  memory_MEMORY_STORE_DATA_RF <= execute_to_memory_MEMORY_STORE_DATA_RF;
  execute_MEMORY_STORE_DATA_RF <= zz_execute_MEMORY_STORE_DATA_RF;
  decode_PREDICTION_HAD_BRANCHED2 <= IBusCachedPlugin_decodePrediction_cmd_hadBranch;
  decode_SRC2_FORCE_ZERO <= (decode_SRC_ADD_ZERO and (not decode_SRC_USE_SUB_LESS));
  zz_decode_to_execute_BRANCH_CTRL <= zz_decode_to_execute_BRANCH_CTRL_1;
  decode_IS_RS2_SIGNED <= pkg_extract(zz_decode_IS_RS2_SIGNED,28);
  decode_IS_RS1_SIGNED <= pkg_extract(zz_decode_IS_RS2_SIGNED,27);
  decode_IS_DIV <= pkg_extract(zz_decode_IS_RS2_SIGNED,26);
  memory_IS_MUL <= execute_to_memory_IS_MUL;
  execute_IS_MUL <= decode_to_execute_IS_MUL;
  decode_IS_MUL <= pkg_extract(zz_decode_IS_RS2_SIGNED,25);
  zz_execute_to_memory_SHIFT_CTRL <= zz_execute_to_memory_SHIFT_CTRL_1;
  decode_SHIFT_CTRL <= zz_decode_SHIFT_CTRL;
  zz_decode_to_execute_SHIFT_CTRL <= zz_decode_to_execute_SHIFT_CTRL_1;
  decode_ALU_BITWISE_CTRL <= zz_decode_ALU_BITWISE_CTRL;
  zz_decode_to_execute_ALU_BITWISE_CTRL <= zz_decode_to_execute_ALU_BITWISE_CTRL_1;
  decode_SRC_LESS_UNSIGNED <= pkg_extract(zz_decode_IS_RS2_SIGNED,19);
  zz_memory_to_writeBack_ENV_CTRL <= zz_memory_to_writeBack_ENV_CTRL_1;
  zz_execute_to_memory_ENV_CTRL <= zz_execute_to_memory_ENV_CTRL_1;
  decode_ENV_CTRL <= zz_decode_ENV_CTRL;
  zz_decode_to_execute_ENV_CTRL <= zz_decode_to_execute_ENV_CTRL_1;
  decode_IS_CSR <= pkg_extract(zz_decode_IS_RS2_SIGNED,17);
  decode_MEMORY_MANAGMENT <= pkg_extract(zz_decode_IS_RS2_SIGNED,16);
  memory_MEMORY_WR <= execute_to_memory_MEMORY_WR;
  decode_MEMORY_WR <= pkg_extract(zz_decode_IS_RS2_SIGNED,13);
  execute_BYPASSABLE_MEMORY_STAGE <= decode_to_execute_BYPASSABLE_MEMORY_STAGE;
  decode_BYPASSABLE_MEMORY_STAGE <= pkg_extract(zz_decode_IS_RS2_SIGNED,12);
  decode_BYPASSABLE_EXECUTE_STAGE <= pkg_extract(zz_decode_IS_RS2_SIGNED,11);
  decode_SRC2_CTRL <= zz_decode_SRC2_CTRL;
  zz_decode_to_execute_SRC2_CTRL <= zz_decode_to_execute_SRC2_CTRL_1;
  decode_ALU_CTRL <= zz_decode_ALU_CTRL;
  zz_decode_to_execute_ALU_CTRL <= zz_decode_to_execute_ALU_CTRL_1;
  decode_SRC1_CTRL <= zz_decode_SRC1_CTRL;
  zz_decode_to_execute_SRC1_CTRL <= zz_decode_to_execute_SRC1_CTRL_1;
  decode_CSR_READ_OPCODE <= pkg_toStdLogic(pkg_extract(decode_INSTRUCTION,13,7) /= pkg_stdLogicVector("0100000"));
  decode_CSR_WRITE_OPCODE <= (not ((pkg_toStdLogic(pkg_extract(decode_INSTRUCTION,14,13) = pkg_stdLogicVector("01")) and pkg_toStdLogic(pkg_extract(decode_INSTRUCTION,19,15) = pkg_stdLogicVector("00000"))) or (pkg_toStdLogic(pkg_extract(decode_INSTRUCTION,14,13) = pkg_stdLogicVector("11")) and pkg_toStdLogic(pkg_extract(decode_INSTRUCTION,19,15) = pkg_stdLogicVector("00000")))));
  decode_MEMORY_FORCE_CONSTISTENCY <= pkg_toStdLogic(false);
  writeBack_FORMAL_PC_NEXT <= memory_to_writeBack_FORMAL_PC_NEXT;
  memory_FORMAL_PC_NEXT <= execute_to_memory_FORMAL_PC_NEXT;
  execute_FORMAL_PC_NEXT <= decode_to_execute_FORMAL_PC_NEXT;
  decode_FORMAL_PC_NEXT <= (decode_PC + pkg_unsigned("00000000000000000000000000000100"));
  memory_PC <= execute_to_memory_PC;
  execute_BRANCH_CALC <= unsigned(pkg_cat(std_logic_vector(pkg_extract(execute_BranchPlugin_branchAdder,31,1)),std_logic_vector(pkg_unsigned("0"))));
  execute_BRANCH_DO <= (pkg_toStdLogic(execute_PREDICTION_HAD_BRANCHED2 /= execute_BRANCH_COND_RESULT) or execute_BranchPlugin_missAlignedTarget);
  execute_PC <= decode_to_execute_PC;
  execute_PREDICTION_HAD_BRANCHED2 <= decode_to_execute_PREDICTION_HAD_BRANCHED2;
  execute_BRANCH_COND_RESULT <= zz_execute_BRANCH_COND_RESULT_1;
  execute_BRANCH_CTRL <= zz_execute_BRANCH_CTRL;
  execute_IS_RS1_SIGNED <= decode_to_execute_IS_RS1_SIGNED;
  execute_IS_DIV <= decode_to_execute_IS_DIV;
  execute_IS_RS2_SIGNED <= decode_to_execute_IS_RS2_SIGNED;
  memory_IS_DIV <= execute_to_memory_IS_DIV;
  writeBack_IS_MUL <= memory_to_writeBack_IS_MUL;
  writeBack_MUL_HH <= memory_to_writeBack_MUL_HH;
  writeBack_MUL_LOW <= memory_to_writeBack_MUL_LOW;
  memory_MUL_HL <= execute_to_memory_MUL_HL;
  memory_MUL_LH <= execute_to_memory_MUL_LH;
  memory_MUL_LL <= execute_to_memory_MUL_LL;
  decode_RS2_USE <= pkg_extract(zz_decode_IS_RS2_SIGNED,15);
  decode_RS1_USE <= pkg_extract(zz_decode_IS_RS2_SIGNED,5);
  execute_REGFILE_WRITE_VALID <= decode_to_execute_REGFILE_WRITE_VALID;
  execute_BYPASSABLE_EXECUTE_STAGE <= decode_to_execute_BYPASSABLE_EXECUTE_STAGE;
  memory_REGFILE_WRITE_VALID <= execute_to_memory_REGFILE_WRITE_VALID;
  memory_INSTRUCTION <= execute_to_memory_INSTRUCTION;
  memory_BYPASSABLE_MEMORY_STAGE <= execute_to_memory_BYPASSABLE_MEMORY_STAGE;
  writeBack_REGFILE_WRITE_VALID <= memory_to_writeBack_REGFILE_WRITE_VALID;
  process(decode_RegFilePlugin_rs2Data,HazardSimplePlugin_writeBackBuffer_valid,HazardSimplePlugin_addr1Match,HazardSimplePlugin_writeBackBuffer_payload_data,when_HazardSimplePlugin_l45,when_HazardSimplePlugin_l47,when_HazardSimplePlugin_l51,zz_decode_RS2_2,when_HazardSimplePlugin_l45_1,memory_BYPASSABLE_MEMORY_STAGE,when_HazardSimplePlugin_l51_1,zz_decode_RS2,when_HazardSimplePlugin_l45_2,execute_BYPASSABLE_EXECUTE_STAGE,when_HazardSimplePlugin_l51_2,zz_decode_RS2_1)
  begin
    decode_RS2 <= decode_RegFilePlugin_rs2Data;
    if HazardSimplePlugin_writeBackBuffer_valid = '1' then
      if HazardSimplePlugin_addr1Match = '1' then
        decode_RS2 <= HazardSimplePlugin_writeBackBuffer_payload_data;
      end if;
    end if;
    if when_HazardSimplePlugin_l45 = '1' then
      if when_HazardSimplePlugin_l47 = '1' then
        if when_HazardSimplePlugin_l51 = '1' then
          decode_RS2 <= zz_decode_RS2_2;
        end if;
      end if;
    end if;
    if when_HazardSimplePlugin_l45_1 = '1' then
      if memory_BYPASSABLE_MEMORY_STAGE = '1' then
        if when_HazardSimplePlugin_l51_1 = '1' then
          decode_RS2 <= zz_decode_RS2;
        end if;
      end if;
    end if;
    if when_HazardSimplePlugin_l45_2 = '1' then
      if execute_BYPASSABLE_EXECUTE_STAGE = '1' then
        if when_HazardSimplePlugin_l51_2 = '1' then
          decode_RS2 <= zz_decode_RS2_1;
        end if;
      end if;
    end if;
  end process;

  process(decode_RegFilePlugin_rs1Data,HazardSimplePlugin_writeBackBuffer_valid,HazardSimplePlugin_addr0Match,HazardSimplePlugin_writeBackBuffer_payload_data,when_HazardSimplePlugin_l45,when_HazardSimplePlugin_l47,when_HazardSimplePlugin_l48,zz_decode_RS2_2,when_HazardSimplePlugin_l45_1,memory_BYPASSABLE_MEMORY_STAGE,when_HazardSimplePlugin_l48_1,zz_decode_RS2,when_HazardSimplePlugin_l45_2,execute_BYPASSABLE_EXECUTE_STAGE,when_HazardSimplePlugin_l48_2,zz_decode_RS2_1)
  begin
    decode_RS1 <= decode_RegFilePlugin_rs1Data;
    if HazardSimplePlugin_writeBackBuffer_valid = '1' then
      if HazardSimplePlugin_addr0Match = '1' then
        decode_RS1 <= HazardSimplePlugin_writeBackBuffer_payload_data;
      end if;
    end if;
    if when_HazardSimplePlugin_l45 = '1' then
      if when_HazardSimplePlugin_l47 = '1' then
        if when_HazardSimplePlugin_l48 = '1' then
          decode_RS1 <= zz_decode_RS2_2;
        end if;
      end if;
    end if;
    if when_HazardSimplePlugin_l45_1 = '1' then
      if memory_BYPASSABLE_MEMORY_STAGE = '1' then
        if when_HazardSimplePlugin_l48_1 = '1' then
          decode_RS1 <= zz_decode_RS2;
        end if;
      end if;
    end if;
    if when_HazardSimplePlugin_l45_2 = '1' then
      if execute_BYPASSABLE_EXECUTE_STAGE = '1' then
        if when_HazardSimplePlugin_l48_2 = '1' then
          decode_RS1 <= zz_decode_RS2_1;
        end if;
      end if;
    end if;
  end process;

  memory_SHIFT_RIGHT <= execute_to_memory_SHIFT_RIGHT;
  process(memory_REGFILE_WRITE_DATA,memory_arbitration_isValid,memory_SHIFT_CTRL,zz_decode_RS2_3,memory_SHIFT_RIGHT,when_MulDivIterativePlugin_l128,memory_DivPlugin_div_result)
  begin
    zz_decode_RS2 <= memory_REGFILE_WRITE_DATA;
    if memory_arbitration_isValid = '1' then
      case memory_SHIFT_CTRL is
        when ShiftCtrlEnum_seq_SLL_1 =>
          zz_decode_RS2 <= zz_decode_RS2_3;
        when ShiftCtrlEnum_seq_SRL_1 | ShiftCtrlEnum_seq_SRA_1 =>
          zz_decode_RS2 <= memory_SHIFT_RIGHT;
        when others =>
      end case;
    end if;
    if when_MulDivIterativePlugin_l128 = '1' then
      zz_decode_RS2 <= memory_DivPlugin_div_result;
    end if;
  end process;

  memory_SHIFT_CTRL <= zz_memory_SHIFT_CTRL;
  execute_SHIFT_CTRL <= zz_execute_SHIFT_CTRL;
  execute_SRC_LESS_UNSIGNED <= decode_to_execute_SRC_LESS_UNSIGNED;
  execute_SRC2_FORCE_ZERO <= decode_to_execute_SRC2_FORCE_ZERO;
  execute_SRC_USE_SUB_LESS <= decode_to_execute_SRC_USE_SUB_LESS;
  zz_execute_to_memory_PC <= execute_PC;
  execute_SRC2_CTRL <= zz_execute_SRC2_CTRL;
  execute_SRC1_CTRL <= zz_execute_SRC1_CTRL;
  decode_SRC_USE_SUB_LESS <= pkg_extract(zz_decode_IS_RS2_SIGNED,3);
  decode_SRC_ADD_ZERO <= pkg_extract(zz_decode_IS_RS2_SIGNED,22);
  execute_SRC_ADD_SUB <= execute_SrcPlugin_addSub;
  execute_SRC_LESS <= execute_SrcPlugin_less;
  execute_ALU_CTRL <= zz_execute_ALU_CTRL;
  execute_SRC2 <= zz_execute_SRC2_4;
  execute_ALU_BITWISE_CTRL <= zz_execute_ALU_BITWISE_CTRL;
  zz_lastStageRegFileWrite_payload_address <= writeBack_INSTRUCTION;
  zz_lastStageRegFileWrite_valid <= writeBack_REGFILE_WRITE_VALID;
  process(lastStageRegFileWrite_valid)
  begin
    zz_1 <= pkg_toStdLogic(false);
    if lastStageRegFileWrite_valid = '1' then
      zz_1 <= pkg_toStdLogic(true);
    end if;
  end process;

  decode_INSTRUCTION_ANTICIPATED <= pkg_mux(decode_arbitration_isStuck,decode_INSTRUCTION,IBusCachedPlugin_cache_io_cpu_fetch_data);
  process(zz_decode_IS_RS2_SIGNED,when_RegFilePlugin_l63)
  begin
    decode_REGFILE_WRITE_VALID <= pkg_extract(zz_decode_IS_RS2_SIGNED,10);
    if when_RegFilePlugin_l63 = '1' then
      decode_REGFILE_WRITE_VALID <= pkg_toStdLogic(false);
    end if;
  end process;

  decode_LEGAL_INSTRUCTION <= pkg_toStdLogic(pkg_cat(pkg_toStdLogicVector(pkg_toStdLogic((decode_INSTRUCTION and pkg_stdLogicVector("00000000000000000000000001011111")) = pkg_stdLogicVector("00000000000000000000000000010111"))),pkg_cat(pkg_toStdLogicVector(pkg_toStdLogic((decode_INSTRUCTION and pkg_stdLogicVector("00000000000000000000000001111111")) = pkg_stdLogicVector("00000000000000000000000001101111"))),pkg_cat(pkg_toStdLogicVector(pkg_toStdLogic((decode_INSTRUCTION and zz_decode_LEGAL_INSTRUCTION) = pkg_stdLogicVector("00000000000000000001000001110011"))),pkg_cat(pkg_toStdLogicVector(pkg_toStdLogic(zz_decode_LEGAL_INSTRUCTION_1 = zz_decode_LEGAL_INSTRUCTION_2)),pkg_cat(pkg_toStdLogicVector(zz_decode_LEGAL_INSTRUCTION_3),pkg_cat(zz_decode_LEGAL_INSTRUCTION_4,zz_decode_LEGAL_INSTRUCTION_5)))))) /= pkg_stdLogicVector("000000000000000000"));
  process(execute_REGFILE_WRITE_DATA,when_CsrPlugin_l1587,CsrPlugin_csrMapping_readDataSignal)
  begin
    zz_decode_RS2_1 <= execute_REGFILE_WRITE_DATA;
    if when_CsrPlugin_l1587 = '1' then
      zz_decode_RS2_1 <= CsrPlugin_csrMapping_readDataSignal;
    end if;
  end process;

  execute_SRC1 <= zz_execute_SRC1;
  execute_CSR_READ_OPCODE <= decode_to_execute_CSR_READ_OPCODE;
  execute_CSR_WRITE_OPCODE <= decode_to_execute_CSR_WRITE_OPCODE;
  execute_IS_CSR <= decode_to_execute_IS_CSR;
  memory_ENV_CTRL <= zz_memory_ENV_CTRL;
  execute_ENV_CTRL <= zz_execute_ENV_CTRL;
  writeBack_ENV_CTRL <= zz_writeBack_ENV_CTRL;
  process(writeBack_REGFILE_WRITE_DATA,when_DBusCachedPlugin_l571,writeBack_DBusCachedPlugin_rspFormated,when_MulPlugin_l147,switch_MulPlugin_l148,writeBack_MUL_LOW,writeBack_MulPlugin_result)
  begin
    zz_decode_RS2_2 <= writeBack_REGFILE_WRITE_DATA;
    if when_DBusCachedPlugin_l571 = '1' then
      zz_decode_RS2_2 <= writeBack_DBusCachedPlugin_rspFormated;
    end if;
    if when_MulPlugin_l147 = '1' then
      case switch_MulPlugin_l148 is
        when "00" =>
          zz_decode_RS2_2 <= std_logic_vector(pkg_extract(writeBack_MUL_LOW,31,0));
        when others =>
          zz_decode_RS2_2 <= std_logic_vector(pkg_extract(writeBack_MulPlugin_result,63,32));
      end case;
    end if;
  end process;

  writeBack_MEMORY_WR <= memory_to_writeBack_MEMORY_WR;
  writeBack_MEMORY_STORE_DATA_RF <= memory_to_writeBack_MEMORY_STORE_DATA_RF;
  writeBack_REGFILE_WRITE_DATA <= memory_to_writeBack_REGFILE_WRITE_DATA;
  writeBack_MEMORY_ENABLE <= memory_to_writeBack_MEMORY_ENABLE;
  memory_REGFILE_WRITE_DATA <= execute_to_memory_REGFILE_WRITE_DATA;
  memory_MEMORY_ENABLE <= execute_to_memory_MEMORY_ENABLE;
  execute_MEMORY_FORCE_CONSTISTENCY <= decode_to_execute_MEMORY_FORCE_CONSTISTENCY;
  execute_RS1 <= decode_to_execute_RS1;
  execute_MEMORY_MANAGMENT <= decode_to_execute_MEMORY_MANAGMENT;
  execute_RS2 <= decode_to_execute_RS2;
  execute_MEMORY_WR <= decode_to_execute_MEMORY_WR;
  execute_SRC_ADD <= execute_SrcPlugin_addSub;
  execute_MEMORY_ENABLE <= decode_to_execute_MEMORY_ENABLE;
  execute_INSTRUCTION <= decode_to_execute_INSTRUCTION;
  decode_MEMORY_ENABLE <= pkg_extract(zz_decode_IS_RS2_SIGNED,4);
  decode_FLUSH_ALL <= pkg_extract(zz_decode_IS_RS2_SIGNED,0);
  process(IBusCachedPlugin_rsp_issueDetected_3,when_IBusCachedPlugin_l262)
  begin
    IBusCachedPlugin_rsp_issueDetected_4 <= IBusCachedPlugin_rsp_issueDetected_3;
    if when_IBusCachedPlugin_l262 = '1' then
      IBusCachedPlugin_rsp_issueDetected_4 <= pkg_toStdLogic(true);
    end if;
  end process;

  process(IBusCachedPlugin_rsp_issueDetected_2,when_IBusCachedPlugin_l256)
  begin
    IBusCachedPlugin_rsp_issueDetected_3 <= IBusCachedPlugin_rsp_issueDetected_2;
    if when_IBusCachedPlugin_l256 = '1' then
      IBusCachedPlugin_rsp_issueDetected_3 <= pkg_toStdLogic(true);
    end if;
  end process;

  process(IBusCachedPlugin_rsp_issueDetected_1,when_IBusCachedPlugin_l250)
  begin
    IBusCachedPlugin_rsp_issueDetected_2 <= IBusCachedPlugin_rsp_issueDetected_1;
    if when_IBusCachedPlugin_l250 = '1' then
      IBusCachedPlugin_rsp_issueDetected_2 <= pkg_toStdLogic(true);
    end if;
  end process;

  process(IBusCachedPlugin_rsp_issueDetected,when_IBusCachedPlugin_l245)
  begin
    IBusCachedPlugin_rsp_issueDetected_1 <= IBusCachedPlugin_rsp_issueDetected;
    if when_IBusCachedPlugin_l245 = '1' then
      IBusCachedPlugin_rsp_issueDetected_1 <= pkg_toStdLogic(true);
    end if;
  end process;

  decode_BRANCH_CTRL <= zz_decode_BRANCH_CTRL_1;
  decode_INSTRUCTION <= IBusCachedPlugin_iBusRsp_output_payload_rsp_inst;
  process(execute_FORMAL_PC_NEXT,BranchPlugin_jumpInterface_valid,BranchPlugin_jumpInterface_payload)
  begin
    zz_execute_to_memory_FORMAL_PC_NEXT <= execute_FORMAL_PC_NEXT;
    if BranchPlugin_jumpInterface_valid = '1' then
      zz_execute_to_memory_FORMAL_PC_NEXT <= BranchPlugin_jumpInterface_payload;
    end if;
  end process;

  process(decode_FORMAL_PC_NEXT,IBusCachedPlugin_predictionJumpInterface_valid,IBusCachedPlugin_predictionJumpInterface_payload)
  begin
    zz_decode_to_execute_FORMAL_PC_NEXT <= decode_FORMAL_PC_NEXT;
    if IBusCachedPlugin_predictionJumpInterface_valid = '1' then
      zz_decode_to_execute_FORMAL_PC_NEXT <= IBusCachedPlugin_predictionJumpInterface_payload;
    end if;
  end process;

  decode_PC <= IBusCachedPlugin_iBusRsp_output_payload_pc;
  writeBack_PC <= memory_to_writeBack_PC;
  writeBack_INSTRUCTION <= memory_to_writeBack_INSTRUCTION;
  process(when_DBusCachedPlugin_l343)
  begin
    decode_arbitration_haltItself <= pkg_toStdLogic(false);
    if when_DBusCachedPlugin_l343 = '1' then
      decode_arbitration_haltItself <= pkg_toStdLogic(true);
    end if;
  end process;

  process(CsrPlugin_pipelineLiberator_active,when_CsrPlugin_l1527,when_HazardSimplePlugin_l113)
  begin
    decode_arbitration_haltByOther <= pkg_toStdLogic(false);
    if CsrPlugin_pipelineLiberator_active = '1' then
      decode_arbitration_haltByOther <= pkg_toStdLogic(true);
    end if;
    if when_CsrPlugin_l1527 = '1' then
      decode_arbitration_haltByOther <= pkg_toStdLogic(true);
    end if;
    if when_HazardSimplePlugin_l113 = '1' then
      decode_arbitration_haltByOther <= pkg_toStdLogic(true);
    end if;
  end process;

  process(zz_when,decode_arbitration_isFlushed)
  begin
    decode_arbitration_removeIt <= pkg_toStdLogic(false);
    if zz_when = '1' then
      decode_arbitration_removeIt <= pkg_toStdLogic(true);
    end if;
    if decode_arbitration_isFlushed = '1' then
      decode_arbitration_removeIt <= pkg_toStdLogic(true);
    end if;
  end process;

  decode_arbitration_flushIt <= pkg_toStdLogic(false);
  process(IBusCachedPlugin_predictionJumpInterface_valid,zz_when)
  begin
    decode_arbitration_flushNext <= pkg_toStdLogic(false);
    if IBusCachedPlugin_predictionJumpInterface_valid = '1' then
      decode_arbitration_flushNext <= pkg_toStdLogic(true);
    end if;
    if zz_when = '1' then
      decode_arbitration_flushNext <= pkg_toStdLogic(true);
    end if;
  end process;

  process(when_DBusCachedPlugin_l385,when_CsrPlugin_l1591,execute_CsrPlugin_blockedBySideEffects)
  begin
    execute_arbitration_haltItself <= pkg_toStdLogic(false);
    if when_DBusCachedPlugin_l385 = '1' then
      execute_arbitration_haltItself <= pkg_toStdLogic(true);
    end if;
    if when_CsrPlugin_l1591 = '1' then
      if execute_CsrPlugin_blockedBySideEffects = '1' then
        execute_arbitration_haltItself <= pkg_toStdLogic(true);
      end if;
    end if;
  end process;

  process(when_DBusCachedPlugin_l401)
  begin
    execute_arbitration_haltByOther <= pkg_toStdLogic(false);
    if when_DBusCachedPlugin_l401 = '1' then
      execute_arbitration_haltByOther <= pkg_toStdLogic(true);
    end if;
  end process;

  process(BranchPlugin_branchExceptionPort_valid,execute_arbitration_isFlushed)
  begin
    execute_arbitration_removeIt <= pkg_toStdLogic(false);
    if BranchPlugin_branchExceptionPort_valid = '1' then
      execute_arbitration_removeIt <= pkg_toStdLogic(true);
    end if;
    if execute_arbitration_isFlushed = '1' then
      execute_arbitration_removeIt <= pkg_toStdLogic(true);
    end if;
  end process;

  execute_arbitration_flushIt <= pkg_toStdLogic(false);
  process(BranchPlugin_branchExceptionPort_valid,BranchPlugin_jumpInterface_valid)
  begin
    execute_arbitration_flushNext <= pkg_toStdLogic(false);
    if BranchPlugin_branchExceptionPort_valid = '1' then
      execute_arbitration_flushNext <= pkg_toStdLogic(true);
    end if;
    if BranchPlugin_jumpInterface_valid = '1' then
      execute_arbitration_flushNext <= pkg_toStdLogic(true);
    end if;
  end process;

  process(when_MulDivIterativePlugin_l128,when_MulDivIterativePlugin_l129)
  begin
    memory_arbitration_haltItself <= pkg_toStdLogic(false);
    if when_MulDivIterativePlugin_l128 = '1' then
      if when_MulDivIterativePlugin_l129 = '1' then
        memory_arbitration_haltItself <= pkg_toStdLogic(true);
      end if;
    end if;
  end process;

  memory_arbitration_haltByOther <= pkg_toStdLogic(false);
  process(memory_arbitration_isFlushed)
  begin
    memory_arbitration_removeIt <= pkg_toStdLogic(false);
    if memory_arbitration_isFlushed = '1' then
      memory_arbitration_removeIt <= pkg_toStdLogic(true);
    end if;
  end process;

  memory_arbitration_flushIt <= pkg_toStdLogic(false);
  memory_arbitration_flushNext <= pkg_toStdLogic(false);
  process(when_DBusCachedPlugin_l544)
  begin
    writeBack_arbitration_haltItself <= pkg_toStdLogic(false);
    if when_DBusCachedPlugin_l544 = '1' then
      writeBack_arbitration_haltItself <= pkg_toStdLogic(true);
    end if;
  end process;

  writeBack_arbitration_haltByOther <= pkg_toStdLogic(false);
  process(DBusCachedPlugin_exceptionBus_valid,writeBack_arbitration_isFlushed)
  begin
    writeBack_arbitration_removeIt <= pkg_toStdLogic(false);
    if DBusCachedPlugin_exceptionBus_valid = '1' then
      writeBack_arbitration_removeIt <= pkg_toStdLogic(true);
    end if;
    if writeBack_arbitration_isFlushed = '1' then
      writeBack_arbitration_removeIt <= pkg_toStdLogic(true);
    end if;
  end process;

  process(DBusCachedPlugin_redoBranch_valid)
  begin
    writeBack_arbitration_flushIt <= pkg_toStdLogic(false);
    if DBusCachedPlugin_redoBranch_valid = '1' then
      writeBack_arbitration_flushIt <= pkg_toStdLogic(true);
    end if;
  end process;

  process(DBusCachedPlugin_redoBranch_valid,DBusCachedPlugin_exceptionBus_valid,when_CsrPlugin_l1390,when_CsrPlugin_l1456)
  begin
    writeBack_arbitration_flushNext <= pkg_toStdLogic(false);
    if DBusCachedPlugin_redoBranch_valid = '1' then
      writeBack_arbitration_flushNext <= pkg_toStdLogic(true);
    end if;
    if DBusCachedPlugin_exceptionBus_valid = '1' then
      writeBack_arbitration_flushNext <= pkg_toStdLogic(true);
    end if;
    if when_CsrPlugin_l1390 = '1' then
      writeBack_arbitration_flushNext <= pkg_toStdLogic(true);
    end if;
    if when_CsrPlugin_l1456 = '1' then
      writeBack_arbitration_flushNext <= pkg_toStdLogic(true);
    end if;
  end process;

  lastStageInstruction <= writeBack_INSTRUCTION;
  lastStagePc <= writeBack_PC;
  lastStageIsValid <= writeBack_arbitration_isValid;
  lastStageIsFiring <= writeBack_arbitration_isFiring;
  process(when_CsrPlugin_l1272,when_CsrPlugin_l1390,when_CsrPlugin_l1456)
  begin
    IBusCachedPlugin_fetcherHalt <= pkg_toStdLogic(false);
    if when_CsrPlugin_l1272 = '1' then
      IBusCachedPlugin_fetcherHalt <= pkg_toStdLogic(true);
    end if;
    if when_CsrPlugin_l1390 = '1' then
      IBusCachedPlugin_fetcherHalt <= pkg_toStdLogic(true);
    end if;
    if when_CsrPlugin_l1456 = '1' then
      IBusCachedPlugin_fetcherHalt <= pkg_toStdLogic(true);
    end if;
  end process;

  IBusCachedPlugin_forceNoDecodeCond <= pkg_toStdLogic(false);
  process(when_Fetcher_l242)
  begin
    IBusCachedPlugin_incomingInstruction <= pkg_toStdLogic(false);
    if when_Fetcher_l242 = '1' then
      IBusCachedPlugin_incomingInstruction <= pkg_toStdLogic(true);
    end if;
  end process;

  process(when_CsrPlugin_l1702,when_CsrPlugin_l1709)
  begin
    CsrPlugin_csrMapping_allowCsrSignal <= pkg_toStdLogic(false);
    if when_CsrPlugin_l1702 = '1' then
      CsrPlugin_csrMapping_allowCsrSignal <= pkg_toStdLogic(true);
    end if;
    if when_CsrPlugin_l1709 = '1' then
      CsrPlugin_csrMapping_allowCsrSignal <= pkg_toStdLogic(true);
    end if;
  end process;

  CsrPlugin_csrMapping_doForceFailCsr <= pkg_toStdLogic(false);
  CsrPlugin_csrMapping_readDataSignal <= CsrPlugin_csrMapping_readDataInit;
  CsrPlugin_inWfi <= pkg_toStdLogic(false);
  CsrPlugin_thirdPartyWake <= pkg_toStdLogic(false);
  process(when_CsrPlugin_l1390,when_CsrPlugin_l1456)
  begin
    CsrPlugin_jumpInterface_valid <= pkg_toStdLogic(false);
    if when_CsrPlugin_l1390 = '1' then
      CsrPlugin_jumpInterface_valid <= pkg_toStdLogic(true);
    end if;
    if when_CsrPlugin_l1456 = '1' then
      CsrPlugin_jumpInterface_valid <= pkg_toStdLogic(true);
    end if;
  end process;

  process(when_CsrPlugin_l1390,CsrPlugin_xtvec_base,when_CsrPlugin_l1456,switch_CsrPlugin_l1460,CsrPlugin_mepc)
  begin
    CsrPlugin_jumpInterface_payload <= pkg_unsigned("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX");
    if when_CsrPlugin_l1390 = '1' then
      CsrPlugin_jumpInterface_payload <= unsigned(pkg_cat(std_logic_vector(CsrPlugin_xtvec_base),std_logic_vector(pkg_unsigned("00"))));
    end if;
    if when_CsrPlugin_l1456 = '1' then
      case switch_CsrPlugin_l1460 is
        when "11" =>
          CsrPlugin_jumpInterface_payload <= CsrPlugin_mepc;
        when others =>
      end case;
    end if;
  end process;

  CsrPlugin_forceMachineWire <= pkg_toStdLogic(false);
  CsrPlugin_allowInterrupts <= pkg_toStdLogic(true);
  CsrPlugin_allowException <= pkg_toStdLogic(true);
  CsrPlugin_allowEbreakException <= pkg_toStdLogic(true);
  CsrPlugin_xretAwayFromMachine <= pkg_toStdLogic(false);
  BranchPlugin_inDebugNoFetchFlag <= pkg_toStdLogic(false);
  IBusCachedPlugin_externalFlush <= pkg_toStdLogic(pkg_cat(pkg_toStdLogicVector(writeBack_arbitration_flushNext),pkg_cat(pkg_toStdLogicVector(memory_arbitration_flushNext),pkg_cat(pkg_toStdLogicVector(execute_arbitration_flushNext),pkg_toStdLogicVector(decode_arbitration_flushNext)))) /= pkg_stdLogicVector("0000"));
  IBusCachedPlugin_jump_pcLoad_valid <= pkg_toStdLogic(pkg_cat(pkg_toStdLogicVector(BranchPlugin_jumpInterface_valid),pkg_cat(pkg_toStdLogicVector(CsrPlugin_jumpInterface_valid),pkg_cat(pkg_toStdLogicVector(DBusCachedPlugin_redoBranch_valid),pkg_toStdLogicVector(IBusCachedPlugin_predictionJumpInterface_valid)))) /= pkg_stdLogicVector("0000"));
  zz_IBusCachedPlugin_jump_pcLoad_payload <= unsigned(pkg_cat(pkg_toStdLogicVector(IBusCachedPlugin_predictionJumpInterface_valid),pkg_cat(pkg_toStdLogicVector(BranchPlugin_jumpInterface_valid),pkg_cat(pkg_toStdLogicVector(CsrPlugin_jumpInterface_valid),pkg_toStdLogicVector(DBusCachedPlugin_redoBranch_valid)))));
  zz_IBusCachedPlugin_jump_pcLoad_payload_1 <= std_logic_vector((zz_IBusCachedPlugin_jump_pcLoad_payload and pkg_not((zz_IBusCachedPlugin_jump_pcLoad_payload - pkg_unsigned("0001")))));
  zz_IBusCachedPlugin_jump_pcLoad_payload_2 <= pkg_extract(zz_IBusCachedPlugin_jump_pcLoad_payload_1,3);
  zz_IBusCachedPlugin_jump_pcLoad_payload_3 <= (pkg_extract(zz_IBusCachedPlugin_jump_pcLoad_payload_1,1) or zz_IBusCachedPlugin_jump_pcLoad_payload_2);
  zz_IBusCachedPlugin_jump_pcLoad_payload_4 <= (pkg_extract(zz_IBusCachedPlugin_jump_pcLoad_payload_1,2) or zz_IBusCachedPlugin_jump_pcLoad_payload_2);
  IBusCachedPlugin_jump_pcLoad_payload <= zz_IBusCachedPlugin_jump_pcLoad_payload_5;
  process(IBusCachedPlugin_fetchPc_redo_valid,IBusCachedPlugin_jump_pcLoad_valid)
  begin
    IBusCachedPlugin_fetchPc_correction <= pkg_toStdLogic(false);
    if IBusCachedPlugin_fetchPc_redo_valid = '1' then
      IBusCachedPlugin_fetchPc_correction <= pkg_toStdLogic(true);
    end if;
    if IBusCachedPlugin_jump_pcLoad_valid = '1' then
      IBusCachedPlugin_fetchPc_correction <= pkg_toStdLogic(true);
    end if;
  end process;

  IBusCachedPlugin_fetchPc_output_fire <= (IBusCachedPlugin_fetchPc_output_valid and IBusCachedPlugin_fetchPc_output_ready);
  IBusCachedPlugin_fetchPc_corrected <= (IBusCachedPlugin_fetchPc_correction or IBusCachedPlugin_fetchPc_correctionReg);
  process(IBusCachedPlugin_iBusRsp_stages_1_input_ready)
  begin
    IBusCachedPlugin_fetchPc_pcRegPropagate <= pkg_toStdLogic(false);
    if IBusCachedPlugin_iBusRsp_stages_1_input_ready = '1' then
      IBusCachedPlugin_fetchPc_pcRegPropagate <= pkg_toStdLogic(true);
    end if;
  end process;

  when_Fetcher_l133 <= (IBusCachedPlugin_fetchPc_correction or IBusCachedPlugin_fetchPc_pcRegPropagate);
  when_Fetcher_l133_1 <= ((not IBusCachedPlugin_fetchPc_output_valid) and IBusCachedPlugin_fetchPc_output_ready);
  process(IBusCachedPlugin_fetchPc_pcReg,IBusCachedPlugin_fetchPc_inc,IBusCachedPlugin_fetchPc_redo_valid,IBusCachedPlugin_fetchPc_redo_payload,IBusCachedPlugin_jump_pcLoad_valid,IBusCachedPlugin_jump_pcLoad_payload)
  begin
    IBusCachedPlugin_fetchPc_pc <= (IBusCachedPlugin_fetchPc_pcReg + pkg_resize(unsigned(pkg_cat(pkg_toStdLogicVector(IBusCachedPlugin_fetchPc_inc),pkg_stdLogicVector("00"))),32));
    if IBusCachedPlugin_fetchPc_redo_valid = '1' then
      IBusCachedPlugin_fetchPc_pc <= IBusCachedPlugin_fetchPc_redo_payload;
    end if;
    if IBusCachedPlugin_jump_pcLoad_valid = '1' then
      IBusCachedPlugin_fetchPc_pc <= IBusCachedPlugin_jump_pcLoad_payload;
    end if;
    IBusCachedPlugin_fetchPc_pc(0) <= pkg_toStdLogic(false);
    IBusCachedPlugin_fetchPc_pc(1) <= pkg_toStdLogic(false);
  end process;

  process(IBusCachedPlugin_fetchPc_redo_valid,IBusCachedPlugin_jump_pcLoad_valid)
  begin
    IBusCachedPlugin_fetchPc_flushed <= pkg_toStdLogic(false);
    if IBusCachedPlugin_fetchPc_redo_valid = '1' then
      IBusCachedPlugin_fetchPc_flushed <= pkg_toStdLogic(true);
    end if;
    if IBusCachedPlugin_jump_pcLoad_valid = '1' then
      IBusCachedPlugin_fetchPc_flushed <= pkg_toStdLogic(true);
    end if;
  end process;

  when_Fetcher_l160 <= (IBusCachedPlugin_fetchPc_booted and ((IBusCachedPlugin_fetchPc_output_ready or IBusCachedPlugin_fetchPc_correction) or IBusCachedPlugin_fetchPc_pcRegPropagate));
  IBusCachedPlugin_fetchPc_output_valid <= ((not IBusCachedPlugin_fetcherHalt) and IBusCachedPlugin_fetchPc_booted);
  IBusCachedPlugin_fetchPc_output_payload <= IBusCachedPlugin_fetchPc_pc;
  process(IBusCachedPlugin_rsp_redoFetch)
  begin
    IBusCachedPlugin_iBusRsp_redoFetch <= pkg_toStdLogic(false);
    if IBusCachedPlugin_rsp_redoFetch = '1' then
      IBusCachedPlugin_iBusRsp_redoFetch <= pkg_toStdLogic(true);
    end if;
  end process;

  IBusCachedPlugin_iBusRsp_stages_0_input_valid <= IBusCachedPlugin_fetchPc_output_valid;
  IBusCachedPlugin_fetchPc_output_ready <= IBusCachedPlugin_iBusRsp_stages_0_input_ready;
  IBusCachedPlugin_iBusRsp_stages_0_input_payload <= IBusCachedPlugin_fetchPc_output_payload;
  process(IBusCachedPlugin_cache_io_cpu_prefetch_haltIt)
  begin
    IBusCachedPlugin_iBusRsp_stages_0_halt <= pkg_toStdLogic(false);
    if IBusCachedPlugin_cache_io_cpu_prefetch_haltIt = '1' then
      IBusCachedPlugin_iBusRsp_stages_0_halt <= pkg_toStdLogic(true);
    end if;
  end process;

  zz_IBusCachedPlugin_iBusRsp_stages_0_input_ready <= (not IBusCachedPlugin_iBusRsp_stages_0_halt);
  IBusCachedPlugin_iBusRsp_stages_0_input_ready <= (IBusCachedPlugin_iBusRsp_stages_0_output_ready and zz_IBusCachedPlugin_iBusRsp_stages_0_input_ready);
  IBusCachedPlugin_iBusRsp_stages_0_output_valid <= (IBusCachedPlugin_iBusRsp_stages_0_input_valid and zz_IBusCachedPlugin_iBusRsp_stages_0_input_ready);
  IBusCachedPlugin_iBusRsp_stages_0_output_payload <= IBusCachedPlugin_iBusRsp_stages_0_input_payload;
  process(IBusCachedPlugin_mmuBus_busy)
  begin
    IBusCachedPlugin_iBusRsp_stages_1_halt <= pkg_toStdLogic(false);
    if IBusCachedPlugin_mmuBus_busy = '1' then
      IBusCachedPlugin_iBusRsp_stages_1_halt <= pkg_toStdLogic(true);
    end if;
  end process;

  zz_IBusCachedPlugin_iBusRsp_stages_1_input_ready <= (not IBusCachedPlugin_iBusRsp_stages_1_halt);
  IBusCachedPlugin_iBusRsp_stages_1_input_ready <= (IBusCachedPlugin_iBusRsp_stages_1_output_ready and zz_IBusCachedPlugin_iBusRsp_stages_1_input_ready);
  IBusCachedPlugin_iBusRsp_stages_1_output_valid <= (IBusCachedPlugin_iBusRsp_stages_1_input_valid and zz_IBusCachedPlugin_iBusRsp_stages_1_input_ready);
  IBusCachedPlugin_iBusRsp_stages_1_output_payload <= IBusCachedPlugin_iBusRsp_stages_1_input_payload;
  process(when_IBusCachedPlugin_l273)
  begin
    IBusCachedPlugin_iBusRsp_stages_2_halt <= pkg_toStdLogic(false);
    if when_IBusCachedPlugin_l273 = '1' then
      IBusCachedPlugin_iBusRsp_stages_2_halt <= pkg_toStdLogic(true);
    end if;
  end process;

  zz_IBusCachedPlugin_iBusRsp_stages_2_input_ready <= (not IBusCachedPlugin_iBusRsp_stages_2_halt);
  IBusCachedPlugin_iBusRsp_stages_2_input_ready <= (IBusCachedPlugin_iBusRsp_stages_2_output_ready and zz_IBusCachedPlugin_iBusRsp_stages_2_input_ready);
  IBusCachedPlugin_iBusRsp_stages_2_output_valid <= (IBusCachedPlugin_iBusRsp_stages_2_input_valid and zz_IBusCachedPlugin_iBusRsp_stages_2_input_ready);
  IBusCachedPlugin_iBusRsp_stages_2_output_payload <= IBusCachedPlugin_iBusRsp_stages_2_input_payload;
  IBusCachedPlugin_fetchPc_redo_valid <= IBusCachedPlugin_iBusRsp_redoFetch;
  IBusCachedPlugin_fetchPc_redo_payload <= IBusCachedPlugin_iBusRsp_stages_2_input_payload;
  IBusCachedPlugin_iBusRsp_flush <= ((decode_arbitration_removeIt or (decode_arbitration_flushNext and (not decode_arbitration_isStuck))) or IBusCachedPlugin_iBusRsp_redoFetch);
  IBusCachedPlugin_iBusRsp_stages_0_output_ready <= zz_IBusCachedPlugin_iBusRsp_stages_0_output_ready;
  zz_IBusCachedPlugin_iBusRsp_stages_0_output_ready <= ((pkg_toStdLogic(false) and (not zz_IBusCachedPlugin_iBusRsp_stages_1_input_valid)) or IBusCachedPlugin_iBusRsp_stages_1_input_ready);
  zz_IBusCachedPlugin_iBusRsp_stages_1_input_valid <= zz_IBusCachedPlugin_iBusRsp_stages_1_input_valid_1;
  IBusCachedPlugin_iBusRsp_stages_1_input_valid <= zz_IBusCachedPlugin_iBusRsp_stages_1_input_valid;
  IBusCachedPlugin_iBusRsp_stages_1_input_payload <= IBusCachedPlugin_fetchPc_pcReg;
  IBusCachedPlugin_iBusRsp_stages_1_output_ready <= ((pkg_toStdLogic(false) and (not IBusCachedPlugin_iBusRsp_stages_1_output_m2sPipe_valid)) or IBusCachedPlugin_iBusRsp_stages_1_output_m2sPipe_ready);
  IBusCachedPlugin_iBusRsp_stages_1_output_m2sPipe_valid <= zz_IBusCachedPlugin_iBusRsp_stages_1_output_m2sPipe_valid;
  IBusCachedPlugin_iBusRsp_stages_1_output_m2sPipe_payload <= zz_IBusCachedPlugin_iBusRsp_stages_1_output_m2sPipe_payload;
  IBusCachedPlugin_iBusRsp_stages_2_input_valid <= IBusCachedPlugin_iBusRsp_stages_1_output_m2sPipe_valid;
  IBusCachedPlugin_iBusRsp_stages_1_output_m2sPipe_ready <= IBusCachedPlugin_iBusRsp_stages_2_input_ready;
  IBusCachedPlugin_iBusRsp_stages_2_input_payload <= IBusCachedPlugin_iBusRsp_stages_1_output_m2sPipe_payload;
  process(when_Fetcher_l322)
  begin
    IBusCachedPlugin_iBusRsp_readyForError <= pkg_toStdLogic(true);
    if when_Fetcher_l322 = '1' then
      IBusCachedPlugin_iBusRsp_readyForError <= pkg_toStdLogic(false);
    end if;
  end process;

  when_Fetcher_l242 <= (IBusCachedPlugin_iBusRsp_stages_1_input_valid or IBusCachedPlugin_iBusRsp_stages_2_input_valid);
  when_Fetcher_l322 <= (not IBusCachedPlugin_pcValids_0);
  when_Fetcher_l331 <= (not (not IBusCachedPlugin_iBusRsp_stages_1_input_ready));
  when_Fetcher_l331_1 <= (not (not IBusCachedPlugin_iBusRsp_stages_2_input_ready));
  when_Fetcher_l331_2 <= (not execute_arbitration_isStuck);
  when_Fetcher_l331_3 <= (not memory_arbitration_isStuck);
  when_Fetcher_l331_4 <= (not writeBack_arbitration_isStuck);
  IBusCachedPlugin_pcValids_0 <= IBusCachedPlugin_injector_nextPcCalc_valids_1;
  IBusCachedPlugin_pcValids_1 <= IBusCachedPlugin_injector_nextPcCalc_valids_2;
  IBusCachedPlugin_pcValids_2 <= IBusCachedPlugin_injector_nextPcCalc_valids_3;
  IBusCachedPlugin_pcValids_3 <= IBusCachedPlugin_injector_nextPcCalc_valids_4;
  IBusCachedPlugin_iBusRsp_output_ready <= (not decode_arbitration_isStuck);
  process(IBusCachedPlugin_iBusRsp_output_valid,IBusCachedPlugin_forceNoDecodeCond)
  begin
    decode_arbitration_isValid <= IBusCachedPlugin_iBusRsp_output_valid;
    if IBusCachedPlugin_forceNoDecodeCond = '1' then
      decode_arbitration_isValid <= pkg_toStdLogic(false);
    end if;
  end process;

  zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch <= pkg_extract(pkg_cat(pkg_cat(pkg_cat(pkg_toStdLogicVector(pkg_extract(decode_INSTRUCTION,31)),pkg_toStdLogicVector(pkg_extract(decode_INSTRUCTION,7))),pkg_extract(decode_INSTRUCTION,30,25)),pkg_extract(decode_INSTRUCTION,11,8)),11);
  process(zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch)
  begin
    zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch_1(18) <= zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch;
    zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch_1(17) <= zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch;
    zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch_1(16) <= zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch;
    zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch_1(15) <= zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch;
    zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch_1(14) <= zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch;
    zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch_1(13) <= zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch;
    zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch_1(12) <= zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch;
    zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch_1(11) <= zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch;
    zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch_1(10) <= zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch;
    zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch_1(9) <= zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch;
    zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch_1(8) <= zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch;
    zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch_1(7) <= zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch;
    zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch_1(6) <= zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch;
    zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch_1(5) <= zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch;
    zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch_1(4) <= zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch;
    zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch_1(3) <= zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch;
    zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch_1(2) <= zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch;
    zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch_1(1) <= zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch;
    zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch_1(0) <= zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch;
  end process;

  process(decode_BRANCH_CTRL,zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch_1,decode_INSTRUCTION,zz_6)
  begin
    IBusCachedPlugin_decodePrediction_cmd_hadBranch <= (pkg_toStdLogic(decode_BRANCH_CTRL = BranchCtrlEnum_seq_JAL) or (pkg_toStdLogic(decode_BRANCH_CTRL = BranchCtrlEnum_seq_B) and pkg_extract(pkg_cat(pkg_cat(zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch_1,pkg_cat(pkg_cat(pkg_cat(pkg_toStdLogicVector(pkg_extract(decode_INSTRUCTION,31)),pkg_toStdLogicVector(pkg_extract(decode_INSTRUCTION,7))),pkg_extract(decode_INSTRUCTION,30,25)),pkg_extract(decode_INSTRUCTION,11,8))),pkg_toStdLogicVector(pkg_toStdLogic(false))),31)));
    if zz_6 = '1' then
      IBusCachedPlugin_decodePrediction_cmd_hadBranch <= pkg_toStdLogic(false);
    end if;
  end process;

  zz_2 <= pkg_extract(pkg_cat(pkg_cat(pkg_cat(pkg_toStdLogicVector(pkg_extract(decode_INSTRUCTION,31)),pkg_extract(decode_INSTRUCTION,19,12)),pkg_toStdLogicVector(pkg_extract(decode_INSTRUCTION,20))),pkg_extract(decode_INSTRUCTION,30,21)),19);
  process(zz_2)
  begin
    zz_3(10) <= zz_2;
    zz_3(9) <= zz_2;
    zz_3(8) <= zz_2;
    zz_3(7) <= zz_2;
    zz_3(6) <= zz_2;
    zz_3(5) <= zz_2;
    zz_3(4) <= zz_2;
    zz_3(3) <= zz_2;
    zz_3(2) <= zz_2;
    zz_3(1) <= zz_2;
    zz_3(0) <= zz_2;
  end process;

  zz_4 <= pkg_extract(pkg_cat(pkg_cat(pkg_cat(pkg_toStdLogicVector(pkg_extract(decode_INSTRUCTION,31)),pkg_toStdLogicVector(pkg_extract(decode_INSTRUCTION,7))),pkg_extract(decode_INSTRUCTION,30,25)),pkg_extract(decode_INSTRUCTION,11,8)),11);
  process(zz_4)
  begin
    zz_5(18) <= zz_4;
    zz_5(17) <= zz_4;
    zz_5(16) <= zz_4;
    zz_5(15) <= zz_4;
    zz_5(14) <= zz_4;
    zz_5(13) <= zz_4;
    zz_5(12) <= zz_4;
    zz_5(11) <= zz_4;
    zz_5(10) <= zz_4;
    zz_5(9) <= zz_4;
    zz_5(8) <= zz_4;
    zz_5(7) <= zz_4;
    zz_5(6) <= zz_4;
    zz_5(5) <= zz_4;
    zz_5(4) <= zz_4;
    zz_5(3) <= zz_4;
    zz_5(2) <= zz_4;
    zz_5(1) <= zz_4;
    zz_5(0) <= zz_4;
  end process;

  process(decode_BRANCH_CTRL,zz_3,decode_INSTRUCTION,zz_5)
  begin
    case decode_BRANCH_CTRL is
      when BranchCtrlEnum_seq_JAL =>
        zz_6 <= pkg_extract(pkg_cat(pkg_cat(zz_3,pkg_cat(pkg_cat(pkg_cat(pkg_toStdLogicVector(pkg_extract(decode_INSTRUCTION,31)),pkg_extract(decode_INSTRUCTION,19,12)),pkg_toStdLogicVector(pkg_extract(decode_INSTRUCTION,20))),pkg_extract(decode_INSTRUCTION,30,21))),pkg_toStdLogicVector(pkg_toStdLogic(false))),1);
      when others =>
        zz_6 <= pkg_extract(pkg_cat(pkg_cat(zz_5,pkg_cat(pkg_cat(pkg_cat(pkg_toStdLogicVector(pkg_extract(decode_INSTRUCTION,31)),pkg_toStdLogicVector(pkg_extract(decode_INSTRUCTION,7))),pkg_extract(decode_INSTRUCTION,30,25)),pkg_extract(decode_INSTRUCTION,11,8))),pkg_toStdLogicVector(pkg_toStdLogic(false))),1);
    end case;
  end process;

  IBusCachedPlugin_predictionJumpInterface_valid <= (decode_arbitration_isValid and IBusCachedPlugin_decodePrediction_cmd_hadBranch);
  zz_IBusCachedPlugin_predictionJumpInterface_payload <= pkg_extract(pkg_cat(pkg_cat(pkg_cat(pkg_toStdLogicVector(pkg_extract(decode_INSTRUCTION,31)),pkg_extract(decode_INSTRUCTION,19,12)),pkg_toStdLogicVector(pkg_extract(decode_INSTRUCTION,20))),pkg_extract(decode_INSTRUCTION,30,21)),19);
  process(zz_IBusCachedPlugin_predictionJumpInterface_payload)
  begin
    zz_IBusCachedPlugin_predictionJumpInterface_payload_1(10) <= zz_IBusCachedPlugin_predictionJumpInterface_payload;
    zz_IBusCachedPlugin_predictionJumpInterface_payload_1(9) <= zz_IBusCachedPlugin_predictionJumpInterface_payload;
    zz_IBusCachedPlugin_predictionJumpInterface_payload_1(8) <= zz_IBusCachedPlugin_predictionJumpInterface_payload;
    zz_IBusCachedPlugin_predictionJumpInterface_payload_1(7) <= zz_IBusCachedPlugin_predictionJumpInterface_payload;
    zz_IBusCachedPlugin_predictionJumpInterface_payload_1(6) <= zz_IBusCachedPlugin_predictionJumpInterface_payload;
    zz_IBusCachedPlugin_predictionJumpInterface_payload_1(5) <= zz_IBusCachedPlugin_predictionJumpInterface_payload;
    zz_IBusCachedPlugin_predictionJumpInterface_payload_1(4) <= zz_IBusCachedPlugin_predictionJumpInterface_payload;
    zz_IBusCachedPlugin_predictionJumpInterface_payload_1(3) <= zz_IBusCachedPlugin_predictionJumpInterface_payload;
    zz_IBusCachedPlugin_predictionJumpInterface_payload_1(2) <= zz_IBusCachedPlugin_predictionJumpInterface_payload;
    zz_IBusCachedPlugin_predictionJumpInterface_payload_1(1) <= zz_IBusCachedPlugin_predictionJumpInterface_payload;
    zz_IBusCachedPlugin_predictionJumpInterface_payload_1(0) <= zz_IBusCachedPlugin_predictionJumpInterface_payload;
  end process;

  zz_IBusCachedPlugin_predictionJumpInterface_payload_2 <= pkg_extract(pkg_cat(pkg_cat(pkg_cat(pkg_toStdLogicVector(pkg_extract(decode_INSTRUCTION,31)),pkg_toStdLogicVector(pkg_extract(decode_INSTRUCTION,7))),pkg_extract(decode_INSTRUCTION,30,25)),pkg_extract(decode_INSTRUCTION,11,8)),11);
  process(zz_IBusCachedPlugin_predictionJumpInterface_payload_2)
  begin
    zz_IBusCachedPlugin_predictionJumpInterface_payload_3(18) <= zz_IBusCachedPlugin_predictionJumpInterface_payload_2;
    zz_IBusCachedPlugin_predictionJumpInterface_payload_3(17) <= zz_IBusCachedPlugin_predictionJumpInterface_payload_2;
    zz_IBusCachedPlugin_predictionJumpInterface_payload_3(16) <= zz_IBusCachedPlugin_predictionJumpInterface_payload_2;
    zz_IBusCachedPlugin_predictionJumpInterface_payload_3(15) <= zz_IBusCachedPlugin_predictionJumpInterface_payload_2;
    zz_IBusCachedPlugin_predictionJumpInterface_payload_3(14) <= zz_IBusCachedPlugin_predictionJumpInterface_payload_2;
    zz_IBusCachedPlugin_predictionJumpInterface_payload_3(13) <= zz_IBusCachedPlugin_predictionJumpInterface_payload_2;
    zz_IBusCachedPlugin_predictionJumpInterface_payload_3(12) <= zz_IBusCachedPlugin_predictionJumpInterface_payload_2;
    zz_IBusCachedPlugin_predictionJumpInterface_payload_3(11) <= zz_IBusCachedPlugin_predictionJumpInterface_payload_2;
    zz_IBusCachedPlugin_predictionJumpInterface_payload_3(10) <= zz_IBusCachedPlugin_predictionJumpInterface_payload_2;
    zz_IBusCachedPlugin_predictionJumpInterface_payload_3(9) <= zz_IBusCachedPlugin_predictionJumpInterface_payload_2;
    zz_IBusCachedPlugin_predictionJumpInterface_payload_3(8) <= zz_IBusCachedPlugin_predictionJumpInterface_payload_2;
    zz_IBusCachedPlugin_predictionJumpInterface_payload_3(7) <= zz_IBusCachedPlugin_predictionJumpInterface_payload_2;
    zz_IBusCachedPlugin_predictionJumpInterface_payload_3(6) <= zz_IBusCachedPlugin_predictionJumpInterface_payload_2;
    zz_IBusCachedPlugin_predictionJumpInterface_payload_3(5) <= zz_IBusCachedPlugin_predictionJumpInterface_payload_2;
    zz_IBusCachedPlugin_predictionJumpInterface_payload_3(4) <= zz_IBusCachedPlugin_predictionJumpInterface_payload_2;
    zz_IBusCachedPlugin_predictionJumpInterface_payload_3(3) <= zz_IBusCachedPlugin_predictionJumpInterface_payload_2;
    zz_IBusCachedPlugin_predictionJumpInterface_payload_3(2) <= zz_IBusCachedPlugin_predictionJumpInterface_payload_2;
    zz_IBusCachedPlugin_predictionJumpInterface_payload_3(1) <= zz_IBusCachedPlugin_predictionJumpInterface_payload_2;
    zz_IBusCachedPlugin_predictionJumpInterface_payload_3(0) <= zz_IBusCachedPlugin_predictionJumpInterface_payload_2;
  end process;

  IBusCachedPlugin_predictionJumpInterface_payload <= (decode_PC + unsigned(pkg_mux(pkg_toStdLogic(decode_BRANCH_CTRL = BranchCtrlEnum_seq_JAL),pkg_cat(pkg_cat(zz_IBusCachedPlugin_predictionJumpInterface_payload_1,pkg_cat(pkg_cat(pkg_cat(pkg_toStdLogicVector(zz_IBusCachedPlugin_predictionJumpInterface_payload_4),pkg_extract(decode_INSTRUCTION,19,12)),pkg_toStdLogicVector(pkg_extract(decode_INSTRUCTION,20))),pkg_extract(decode_INSTRUCTION,30,21))),pkg_toStdLogicVector(pkg_toStdLogic(false))),pkg_cat(pkg_cat(zz_IBusCachedPlugin_predictionJumpInterface_payload_3,pkg_cat(pkg_cat(pkg_cat(pkg_toStdLogicVector(zz_IBusCachedPlugin_predictionJumpInterface_payload_5),pkg_toStdLogicVector(zz_IBusCachedPlugin_predictionJumpInterface_payload_6)),pkg_extract(decode_INSTRUCTION,30,25)),pkg_extract(decode_INSTRUCTION,11,8))),pkg_toStdLogicVector(pkg_toStdLogic(false))))));
  iBus_cmd_valid <= IBusCachedPlugin_cache_io_mem_cmd_valid;
  process(IBusCachedPlugin_cache_io_mem_cmd_payload_address)
  begin
    iBus_cmd_payload_address <= IBusCachedPlugin_cache_io_mem_cmd_payload_address;
    iBus_cmd_payload_address <= IBusCachedPlugin_cache_io_mem_cmd_payload_address;
  end process;

  iBus_cmd_payload_size <= IBusCachedPlugin_cache_io_mem_cmd_payload_size;
  IBusCachedPlugin_s0_tightlyCoupledHit <= pkg_toStdLogic(false);
  IBusCachedPlugin_cache_io_cpu_prefetch_isValid <= (IBusCachedPlugin_iBusRsp_stages_0_input_valid and (not IBusCachedPlugin_s0_tightlyCoupledHit));
  IBusCachedPlugin_cache_io_cpu_fetch_isValid <= (IBusCachedPlugin_iBusRsp_stages_1_input_valid and (not IBusCachedPlugin_s1_tightlyCoupledHit));
  IBusCachedPlugin_cache_io_cpu_fetch_isStuck <= (not IBusCachedPlugin_iBusRsp_stages_1_input_ready);
  IBusCachedPlugin_mmuBus_cmd_0_isValid <= IBusCachedPlugin_cache_io_cpu_fetch_isValid;
  IBusCachedPlugin_mmuBus_cmd_0_isStuck <= (not IBusCachedPlugin_iBusRsp_stages_1_input_ready);
  IBusCachedPlugin_mmuBus_cmd_0_virtualAddress <= IBusCachedPlugin_iBusRsp_stages_1_input_payload;
  IBusCachedPlugin_mmuBus_cmd_0_bypassTranslation <= pkg_toStdLogic(false);
  IBusCachedPlugin_mmuBus_end <= (IBusCachedPlugin_iBusRsp_stages_1_input_ready or IBusCachedPlugin_externalFlush);
  IBusCachedPlugin_cache_io_cpu_decode_isValid <= (IBusCachedPlugin_iBusRsp_stages_2_input_valid and (not IBusCachedPlugin_s2_tightlyCoupledHit));
  IBusCachedPlugin_cache_io_cpu_decode_isStuck <= (not IBusCachedPlugin_iBusRsp_stages_2_input_ready);
  IBusCachedPlugin_cache_io_cpu_decode_isUser <= pkg_toStdLogic(CsrPlugin_privilege = pkg_unsigned("00"));
  IBusCachedPlugin_rsp_iBusRspOutputHalt <= pkg_toStdLogic(false);
  IBusCachedPlugin_rsp_issueDetected <= pkg_toStdLogic(false);
  process(when_IBusCachedPlugin_l245,when_IBusCachedPlugin_l256)
  begin
    IBusCachedPlugin_rsp_redoFetch <= pkg_toStdLogic(false);
    if when_IBusCachedPlugin_l245 = '1' then
      IBusCachedPlugin_rsp_redoFetch <= pkg_toStdLogic(true);
    end if;
    if when_IBusCachedPlugin_l256 = '1' then
      IBusCachedPlugin_rsp_redoFetch <= pkg_toStdLogic(true);
    end if;
  end process;

  process(IBusCachedPlugin_rsp_redoFetch,IBusCachedPlugin_cache_io_cpu_decode_mmuRefilling,when_IBusCachedPlugin_l256)
  begin
    IBusCachedPlugin_cache_io_cpu_fill_valid <= (IBusCachedPlugin_rsp_redoFetch and (not IBusCachedPlugin_cache_io_cpu_decode_mmuRefilling));
    if when_IBusCachedPlugin_l256 = '1' then
      IBusCachedPlugin_cache_io_cpu_fill_valid <= pkg_toStdLogic(true);
    end if;
  end process;

  process(when_IBusCachedPlugin_l250,IBusCachedPlugin_iBusRsp_readyForError,when_IBusCachedPlugin_l262)
  begin
    IBusCachedPlugin_decodeExceptionPort_valid <= pkg_toStdLogic(false);
    if when_IBusCachedPlugin_l250 = '1' then
      IBusCachedPlugin_decodeExceptionPort_valid <= IBusCachedPlugin_iBusRsp_readyForError;
    end if;
    if when_IBusCachedPlugin_l262 = '1' then
      IBusCachedPlugin_decodeExceptionPort_valid <= IBusCachedPlugin_iBusRsp_readyForError;
    end if;
  end process;

  process(when_IBusCachedPlugin_l250,when_IBusCachedPlugin_l262)
  begin
    IBusCachedPlugin_decodeExceptionPort_payload_code <= pkg_unsigned("XXXX");
    if when_IBusCachedPlugin_l250 = '1' then
      IBusCachedPlugin_decodeExceptionPort_payload_code <= pkg_unsigned("1100");
    end if;
    if when_IBusCachedPlugin_l262 = '1' then
      IBusCachedPlugin_decodeExceptionPort_payload_code <= pkg_unsigned("0001");
    end if;
  end process;

  IBusCachedPlugin_decodeExceptionPort_payload_badAddr <= unsigned(pkg_cat(std_logic_vector(pkg_extract(IBusCachedPlugin_iBusRsp_stages_2_input_payload,31,2)),std_logic_vector(pkg_unsigned("00"))));
  when_IBusCachedPlugin_l245 <= ((IBusCachedPlugin_cache_io_cpu_decode_isValid and IBusCachedPlugin_cache_io_cpu_decode_mmuRefilling) and (not IBusCachedPlugin_rsp_issueDetected));
  when_IBusCachedPlugin_l250 <= ((IBusCachedPlugin_cache_io_cpu_decode_isValid and IBusCachedPlugin_cache_io_cpu_decode_mmuException) and (not IBusCachedPlugin_rsp_issueDetected_1));
  when_IBusCachedPlugin_l256 <= ((IBusCachedPlugin_cache_io_cpu_decode_isValid and IBusCachedPlugin_cache_io_cpu_decode_cacheMiss) and (not IBusCachedPlugin_rsp_issueDetected_2));
  when_IBusCachedPlugin_l262 <= ((IBusCachedPlugin_cache_io_cpu_decode_isValid and IBusCachedPlugin_cache_io_cpu_decode_error) and (not IBusCachedPlugin_rsp_issueDetected_3));
  when_IBusCachedPlugin_l273 <= (IBusCachedPlugin_rsp_issueDetected_4 or IBusCachedPlugin_rsp_iBusRspOutputHalt);
  IBusCachedPlugin_iBusRsp_output_valid <= IBusCachedPlugin_iBusRsp_stages_2_output_valid;
  IBusCachedPlugin_iBusRsp_stages_2_output_ready <= IBusCachedPlugin_iBusRsp_output_ready;
  IBusCachedPlugin_iBusRsp_output_payload_rsp_inst <= IBusCachedPlugin_cache_io_cpu_decode_data;
  IBusCachedPlugin_iBusRsp_output_payload_pc <= IBusCachedPlugin_iBusRsp_stages_2_output_payload;
  IBusCachedPlugin_cache_io_flush <= (decode_arbitration_isValid and decode_FLUSH_ALL);
  dBus_cmd_valid <= dataCache_1_io_mem_cmd_valid;
  dBus_cmd_payload_wr <= dataCache_1_io_mem_cmd_payload_wr;
  dBus_cmd_payload_uncached <= dataCache_1_io_mem_cmd_payload_uncached;
  dBus_cmd_payload_address <= dataCache_1_io_mem_cmd_payload_address;
  dBus_cmd_payload_data <= dataCache_1_io_mem_cmd_payload_data;
  dBus_cmd_payload_mask <= dataCache_1_io_mem_cmd_payload_mask;
  dBus_cmd_payload_size <= dataCache_1_io_mem_cmd_payload_size;
  dBus_cmd_payload_last <= dataCache_1_io_mem_cmd_payload_last;
  when_DBusCachedPlugin_l343 <= ((DBusCachedPlugin_mmuBus_busy and decode_arbitration_isValid) and decode_MEMORY_ENABLE);
  execute_DBusCachedPlugin_size <= unsigned(pkg_extract(execute_INSTRUCTION,13,12));
  dataCache_1_io_cpu_execute_isValid <= (execute_arbitration_isValid and execute_MEMORY_ENABLE);
  dataCache_1_io_cpu_execute_address <= unsigned(execute_SRC_ADD);
  process(execute_DBusCachedPlugin_size,execute_RS2)
  begin
    case execute_DBusCachedPlugin_size is
      when "00" =>
        zz_execute_MEMORY_STORE_DATA_RF <= pkg_cat(pkg_cat(pkg_cat(pkg_extract(execute_RS2,7,0),pkg_extract(execute_RS2,7,0)),pkg_extract(execute_RS2,7,0)),pkg_extract(execute_RS2,7,0));
      when "01" =>
        zz_execute_MEMORY_STORE_DATA_RF <= pkg_cat(pkg_extract(execute_RS2,15,0),pkg_extract(execute_RS2,15,0));
      when others =>
        zz_execute_MEMORY_STORE_DATA_RF <= pkg_extract(execute_RS2,31,0);
    end case;
  end process;

  dataCache_1_io_cpu_flush_valid <= (execute_arbitration_isValid and execute_MEMORY_MANAGMENT);
  dataCache_1_io_cpu_flush_payload_singleLine <= pkg_toStdLogic(pkg_extract(execute_INSTRUCTION,19,15) /= pkg_stdLogicVector("00000"));
  dataCache_1_io_cpu_flush_payload_lineId <= pkg_resize(unsigned(pkg_shiftRight(execute_RS1,5)),8);
  system_cpu_dataCache_1_io_cpu_flush_isStall <= (dataCache_1_io_cpu_flush_valid and (not dataCache_1_io_cpu_flush_ready));
  when_DBusCachedPlugin_l385 <= (system_cpu_dataCache_1_io_cpu_flush_isStall or dataCache_1_io_cpu_execute_haltIt);
  when_DBusCachedPlugin_l401 <= (dataCache_1_io_cpu_execute_refilling and execute_arbitration_isValid);
  dataCache_1_io_cpu_memory_isValid <= (memory_arbitration_isValid and memory_MEMORY_ENABLE);
  dataCache_1_io_cpu_memory_address <= unsigned(memory_REGFILE_WRITE_DATA);
  DBusCachedPlugin_mmuBus_cmd_0_isValid <= dataCache_1_io_cpu_memory_isValid;
  DBusCachedPlugin_mmuBus_cmd_0_isStuck <= memory_arbitration_isStuck;
  DBusCachedPlugin_mmuBus_cmd_0_virtualAddress <= dataCache_1_io_cpu_memory_address;
  DBusCachedPlugin_mmuBus_cmd_0_bypassTranslation <= pkg_toStdLogic(false);
  DBusCachedPlugin_mmuBus_end <= ((not memory_arbitration_isStuck) or memory_arbitration_removeIt);
  process(DBusCachedPlugin_mmuBus_rsp_isIoAccess,when_DBusCachedPlugin_l463)
  begin
    dataCache_1_io_cpu_memory_mmuRsp_isIoAccess <= DBusCachedPlugin_mmuBus_rsp_isIoAccess;
    if when_DBusCachedPlugin_l463 = '1' then
      dataCache_1_io_cpu_memory_mmuRsp_isIoAccess <= pkg_toStdLogic(true);
    end if;
  end process;

  when_DBusCachedPlugin_l463 <= (pkg_toStdLogic(false) and (not dataCache_1_io_cpu_memory_isWrite));
  process(writeBack_arbitration_isValid,writeBack_MEMORY_ENABLE,writeBack_arbitration_haltByOther)
  begin
    dataCache_1_io_cpu_writeBack_isValid <= (writeBack_arbitration_isValid and writeBack_MEMORY_ENABLE);
    if writeBack_arbitration_haltByOther = '1' then
      dataCache_1_io_cpu_writeBack_isValid <= pkg_toStdLogic(false);
    end if;
  end process;

  dataCache_1_io_cpu_writeBack_isUser <= pkg_toStdLogic(CsrPlugin_privilege = pkg_unsigned("00"));
  dataCache_1_io_cpu_writeBack_address <= unsigned(writeBack_REGFILE_WRITE_DATA);
  dataCache_1_io_cpu_writeBack_storeData(31 downto 0) <= writeBack_MEMORY_STORE_DATA_RF;
  process(when_DBusCachedPlugin_l524,dataCache_1_io_cpu_redo)
  begin
    DBusCachedPlugin_redoBranch_valid <= pkg_toStdLogic(false);
    if when_DBusCachedPlugin_l524 = '1' then
      if dataCache_1_io_cpu_redo = '1' then
        DBusCachedPlugin_redoBranch_valid <= pkg_toStdLogic(true);
      end if;
    end if;
  end process;

  DBusCachedPlugin_redoBranch_payload <= writeBack_PC;
  process(when_DBusCachedPlugin_l524,dataCache_1_io_cpu_writeBack_accessError,dataCache_1_io_cpu_writeBack_mmuException,dataCache_1_io_cpu_writeBack_unalignedAccess,dataCache_1_io_cpu_redo)
  begin
    DBusCachedPlugin_exceptionBus_valid <= pkg_toStdLogic(false);
    if when_DBusCachedPlugin_l524 = '1' then
      if dataCache_1_io_cpu_writeBack_accessError = '1' then
        DBusCachedPlugin_exceptionBus_valid <= pkg_toStdLogic(true);
      end if;
      if dataCache_1_io_cpu_writeBack_mmuException = '1' then
        DBusCachedPlugin_exceptionBus_valid <= pkg_toStdLogic(true);
      end if;
      if dataCache_1_io_cpu_writeBack_unalignedAccess = '1' then
        DBusCachedPlugin_exceptionBus_valid <= pkg_toStdLogic(true);
      end if;
      if dataCache_1_io_cpu_redo = '1' then
        DBusCachedPlugin_exceptionBus_valid <= pkg_toStdLogic(false);
      end if;
    end if;
  end process;

  DBusCachedPlugin_exceptionBus_payload_badAddr <= unsigned(writeBack_REGFILE_WRITE_DATA);
  process(when_DBusCachedPlugin_l524,dataCache_1_io_cpu_writeBack_accessError,writeBack_MEMORY_WR,dataCache_1_io_cpu_writeBack_mmuException,dataCache_1_io_cpu_writeBack_unalignedAccess)
  begin
    DBusCachedPlugin_exceptionBus_payload_code <= pkg_unsigned("XXXX");
    if when_DBusCachedPlugin_l524 = '1' then
      if dataCache_1_io_cpu_writeBack_accessError = '1' then
        DBusCachedPlugin_exceptionBus_payload_code <= pkg_resize(pkg_mux(writeBack_MEMORY_WR,pkg_unsigned("111"),pkg_unsigned("101")),4);
      end if;
      if dataCache_1_io_cpu_writeBack_mmuException = '1' then
        DBusCachedPlugin_exceptionBus_payload_code <= pkg_mux(writeBack_MEMORY_WR,pkg_unsigned("1111"),pkg_unsigned("1101"));
      end if;
      if dataCache_1_io_cpu_writeBack_unalignedAccess = '1' then
        DBusCachedPlugin_exceptionBus_payload_code <= pkg_resize(pkg_mux(writeBack_MEMORY_WR,pkg_unsigned("110"),pkg_unsigned("100")),4);
      end if;
    end if;
  end process;

  when_DBusCachedPlugin_l524 <= (writeBack_arbitration_isValid and writeBack_MEMORY_ENABLE);
  when_DBusCachedPlugin_l544 <= (dataCache_1_io_cpu_writeBack_isValid and dataCache_1_io_cpu_writeBack_haltIt);
  writeBack_DBusCachedPlugin_rspData <= dataCache_1_io_cpu_writeBack_data;
  writeBack_DBusCachedPlugin_rspSplits_0 <= pkg_extract(writeBack_DBusCachedPlugin_rspData,7,0);
  writeBack_DBusCachedPlugin_rspSplits_1 <= pkg_extract(writeBack_DBusCachedPlugin_rspData,15,8);
  writeBack_DBusCachedPlugin_rspSplits_2 <= pkg_extract(writeBack_DBusCachedPlugin_rspData,23,16);
  writeBack_DBusCachedPlugin_rspSplits_3 <= pkg_extract(writeBack_DBusCachedPlugin_rspData,31,24);
  process(zz_writeBack_DBusCachedPlugin_rspShifted,zz_writeBack_DBusCachedPlugin_rspShifted_2,writeBack_DBusCachedPlugin_rspSplits_2,writeBack_DBusCachedPlugin_rspSplits_3)
  begin
    writeBack_DBusCachedPlugin_rspShifted(7 downto 0) <= zz_writeBack_DBusCachedPlugin_rspShifted;
    writeBack_DBusCachedPlugin_rspShifted(15 downto 8) <= zz_writeBack_DBusCachedPlugin_rspShifted_2;
    writeBack_DBusCachedPlugin_rspShifted(23 downto 16) <= writeBack_DBusCachedPlugin_rspSplits_2;
    writeBack_DBusCachedPlugin_rspShifted(31 downto 24) <= writeBack_DBusCachedPlugin_rspSplits_3;
  end process;

  writeBack_DBusCachedPlugin_rspRf <= pkg_extract(writeBack_DBusCachedPlugin_rspShifted,31,0);
  switch_Misc_l227 <= pkg_extract(writeBack_INSTRUCTION,13,12);
  zz_writeBack_DBusCachedPlugin_rspFormated <= (pkg_extract(writeBack_DBusCachedPlugin_rspRf,7) and (not pkg_extract(writeBack_INSTRUCTION,14)));
  process(zz_writeBack_DBusCachedPlugin_rspFormated,writeBack_DBusCachedPlugin_rspRf)
  begin
    zz_writeBack_DBusCachedPlugin_rspFormated_1(31) <= zz_writeBack_DBusCachedPlugin_rspFormated;
    zz_writeBack_DBusCachedPlugin_rspFormated_1(30) <= zz_writeBack_DBusCachedPlugin_rspFormated;
    zz_writeBack_DBusCachedPlugin_rspFormated_1(29) <= zz_writeBack_DBusCachedPlugin_rspFormated;
    zz_writeBack_DBusCachedPlugin_rspFormated_1(28) <= zz_writeBack_DBusCachedPlugin_rspFormated;
    zz_writeBack_DBusCachedPlugin_rspFormated_1(27) <= zz_writeBack_DBusCachedPlugin_rspFormated;
    zz_writeBack_DBusCachedPlugin_rspFormated_1(26) <= zz_writeBack_DBusCachedPlugin_rspFormated;
    zz_writeBack_DBusCachedPlugin_rspFormated_1(25) <= zz_writeBack_DBusCachedPlugin_rspFormated;
    zz_writeBack_DBusCachedPlugin_rspFormated_1(24) <= zz_writeBack_DBusCachedPlugin_rspFormated;
    zz_writeBack_DBusCachedPlugin_rspFormated_1(23) <= zz_writeBack_DBusCachedPlugin_rspFormated;
    zz_writeBack_DBusCachedPlugin_rspFormated_1(22) <= zz_writeBack_DBusCachedPlugin_rspFormated;
    zz_writeBack_DBusCachedPlugin_rspFormated_1(21) <= zz_writeBack_DBusCachedPlugin_rspFormated;
    zz_writeBack_DBusCachedPlugin_rspFormated_1(20) <= zz_writeBack_DBusCachedPlugin_rspFormated;
    zz_writeBack_DBusCachedPlugin_rspFormated_1(19) <= zz_writeBack_DBusCachedPlugin_rspFormated;
    zz_writeBack_DBusCachedPlugin_rspFormated_1(18) <= zz_writeBack_DBusCachedPlugin_rspFormated;
    zz_writeBack_DBusCachedPlugin_rspFormated_1(17) <= zz_writeBack_DBusCachedPlugin_rspFormated;
    zz_writeBack_DBusCachedPlugin_rspFormated_1(16) <= zz_writeBack_DBusCachedPlugin_rspFormated;
    zz_writeBack_DBusCachedPlugin_rspFormated_1(15) <= zz_writeBack_DBusCachedPlugin_rspFormated;
    zz_writeBack_DBusCachedPlugin_rspFormated_1(14) <= zz_writeBack_DBusCachedPlugin_rspFormated;
    zz_writeBack_DBusCachedPlugin_rspFormated_1(13) <= zz_writeBack_DBusCachedPlugin_rspFormated;
    zz_writeBack_DBusCachedPlugin_rspFormated_1(12) <= zz_writeBack_DBusCachedPlugin_rspFormated;
    zz_writeBack_DBusCachedPlugin_rspFormated_1(11) <= zz_writeBack_DBusCachedPlugin_rspFormated;
    zz_writeBack_DBusCachedPlugin_rspFormated_1(10) <= zz_writeBack_DBusCachedPlugin_rspFormated;
    zz_writeBack_DBusCachedPlugin_rspFormated_1(9) <= zz_writeBack_DBusCachedPlugin_rspFormated;
    zz_writeBack_DBusCachedPlugin_rspFormated_1(8) <= zz_writeBack_DBusCachedPlugin_rspFormated;
    zz_writeBack_DBusCachedPlugin_rspFormated_1(7 downto 0) <= pkg_extract(writeBack_DBusCachedPlugin_rspRf,7,0);
  end process;

  zz_writeBack_DBusCachedPlugin_rspFormated_2 <= (pkg_extract(writeBack_DBusCachedPlugin_rspRf,15) and (not pkg_extract(writeBack_INSTRUCTION,14)));
  process(zz_writeBack_DBusCachedPlugin_rspFormated_2,writeBack_DBusCachedPlugin_rspRf)
  begin
    zz_writeBack_DBusCachedPlugin_rspFormated_3(31) <= zz_writeBack_DBusCachedPlugin_rspFormated_2;
    zz_writeBack_DBusCachedPlugin_rspFormated_3(30) <= zz_writeBack_DBusCachedPlugin_rspFormated_2;
    zz_writeBack_DBusCachedPlugin_rspFormated_3(29) <= zz_writeBack_DBusCachedPlugin_rspFormated_2;
    zz_writeBack_DBusCachedPlugin_rspFormated_3(28) <= zz_writeBack_DBusCachedPlugin_rspFormated_2;
    zz_writeBack_DBusCachedPlugin_rspFormated_3(27) <= zz_writeBack_DBusCachedPlugin_rspFormated_2;
    zz_writeBack_DBusCachedPlugin_rspFormated_3(26) <= zz_writeBack_DBusCachedPlugin_rspFormated_2;
    zz_writeBack_DBusCachedPlugin_rspFormated_3(25) <= zz_writeBack_DBusCachedPlugin_rspFormated_2;
    zz_writeBack_DBusCachedPlugin_rspFormated_3(24) <= zz_writeBack_DBusCachedPlugin_rspFormated_2;
    zz_writeBack_DBusCachedPlugin_rspFormated_3(23) <= zz_writeBack_DBusCachedPlugin_rspFormated_2;
    zz_writeBack_DBusCachedPlugin_rspFormated_3(22) <= zz_writeBack_DBusCachedPlugin_rspFormated_2;
    zz_writeBack_DBusCachedPlugin_rspFormated_3(21) <= zz_writeBack_DBusCachedPlugin_rspFormated_2;
    zz_writeBack_DBusCachedPlugin_rspFormated_3(20) <= zz_writeBack_DBusCachedPlugin_rspFormated_2;
    zz_writeBack_DBusCachedPlugin_rspFormated_3(19) <= zz_writeBack_DBusCachedPlugin_rspFormated_2;
    zz_writeBack_DBusCachedPlugin_rspFormated_3(18) <= zz_writeBack_DBusCachedPlugin_rspFormated_2;
    zz_writeBack_DBusCachedPlugin_rspFormated_3(17) <= zz_writeBack_DBusCachedPlugin_rspFormated_2;
    zz_writeBack_DBusCachedPlugin_rspFormated_3(16) <= zz_writeBack_DBusCachedPlugin_rspFormated_2;
    zz_writeBack_DBusCachedPlugin_rspFormated_3(15 downto 0) <= pkg_extract(writeBack_DBusCachedPlugin_rspRf,15,0);
  end process;

  process(switch_Misc_l227,zz_writeBack_DBusCachedPlugin_rspFormated_1,zz_writeBack_DBusCachedPlugin_rspFormated_3,writeBack_DBusCachedPlugin_rspRf)
  begin
    case switch_Misc_l227 is
      when "00" =>
        writeBack_DBusCachedPlugin_rspFormated <= zz_writeBack_DBusCachedPlugin_rspFormated_1;
      when "01" =>
        writeBack_DBusCachedPlugin_rspFormated <= zz_writeBack_DBusCachedPlugin_rspFormated_3;
      when others =>
        writeBack_DBusCachedPlugin_rspFormated <= writeBack_DBusCachedPlugin_rspRf;
    end case;
  end process;

  when_DBusCachedPlugin_l571 <= (writeBack_arbitration_isValid and writeBack_MEMORY_ENABLE);
  process(CsrPlugin_forceMachineWire)
  begin
    CsrPlugin_privilege <= pkg_unsigned("11");
    if CsrPlugin_forceMachineWire = '1' then
      CsrPlugin_privilege <= pkg_unsigned("11");
    end if;
  end process;

  CsrPlugin_misa_base <= pkg_unsigned("01");
  CsrPlugin_misa_extensions <= pkg_stdLogicVector("00000000000000000001000010");
  CsrPlugin_mtvec_mode <= pkg_stdLogicVector("00");
  CsrPlugin_mtvec_base <= pkg_unsigned("100000000000000000000000001000");
  zz_when_CsrPlugin_l1302 <= (CsrPlugin_mip_MTIP and CsrPlugin_mie_MTIE);
  zz_when_CsrPlugin_l1302_1 <= (CsrPlugin_mip_MSIP and CsrPlugin_mie_MSIE);
  zz_when_CsrPlugin_l1302_2 <= (CsrPlugin_mip_MEIP and CsrPlugin_mie_MEIE);
  CsrPlugin_exceptionPortCtrl_exceptionTargetPrivilegeUncapped <= pkg_unsigned("11");
  CsrPlugin_exceptionPortCtrl_exceptionTargetPrivilege <= pkg_mux(pkg_toStdLogic(CsrPlugin_privilege < CsrPlugin_exceptionPortCtrl_exceptionTargetPrivilegeUncapped),CsrPlugin_exceptionPortCtrl_exceptionTargetPrivilegeUncapped,CsrPlugin_privilege);
  zz_CsrPlugin_exceptionPortCtrl_exceptionContext_code <= unsigned(pkg_cat(pkg_toStdLogicVector(decodeExceptionPort_valid),pkg_toStdLogicVector(IBusCachedPlugin_decodeExceptionPort_valid)));
  zz_CsrPlugin_exceptionPortCtrl_exceptionContext_code_1 <= pkg_extract(std_logic_vector((zz_CsrPlugin_exceptionPortCtrl_exceptionContext_code and pkg_not((zz_CsrPlugin_exceptionPortCtrl_exceptionContext_code - pkg_unsigned("01"))))),0);
  process(CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_decode,zz_when,decode_arbitration_isFlushed)
  begin
    CsrPlugin_exceptionPortCtrl_exceptionValids_decode <= CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_decode;
    if zz_when = '1' then
      CsrPlugin_exceptionPortCtrl_exceptionValids_decode <= pkg_toStdLogic(true);
    end if;
    if decode_arbitration_isFlushed = '1' then
      CsrPlugin_exceptionPortCtrl_exceptionValids_decode <= pkg_toStdLogic(false);
    end if;
  end process;

  process(CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_execute,BranchPlugin_branchExceptionPort_valid,execute_arbitration_isFlushed)
  begin
    CsrPlugin_exceptionPortCtrl_exceptionValids_execute <= CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_execute;
    if BranchPlugin_branchExceptionPort_valid = '1' then
      CsrPlugin_exceptionPortCtrl_exceptionValids_execute <= pkg_toStdLogic(true);
    end if;
    if execute_arbitration_isFlushed = '1' then
      CsrPlugin_exceptionPortCtrl_exceptionValids_execute <= pkg_toStdLogic(false);
    end if;
  end process;

  process(CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_memory,memory_arbitration_isFlushed)
  begin
    CsrPlugin_exceptionPortCtrl_exceptionValids_memory <= CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_memory;
    if memory_arbitration_isFlushed = '1' then
      CsrPlugin_exceptionPortCtrl_exceptionValids_memory <= pkg_toStdLogic(false);
    end if;
  end process;

  process(CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_writeBack,DBusCachedPlugin_exceptionBus_valid,writeBack_arbitration_isFlushed)
  begin
    CsrPlugin_exceptionPortCtrl_exceptionValids_writeBack <= CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_writeBack;
    if DBusCachedPlugin_exceptionBus_valid = '1' then
      CsrPlugin_exceptionPortCtrl_exceptionValids_writeBack <= pkg_toStdLogic(true);
    end if;
    if writeBack_arbitration_isFlushed = '1' then
      CsrPlugin_exceptionPortCtrl_exceptionValids_writeBack <= pkg_toStdLogic(false);
    end if;
  end process;

  when_CsrPlugin_l1259 <= (not decode_arbitration_isStuck);
  when_CsrPlugin_l1259_1 <= (not execute_arbitration_isStuck);
  when_CsrPlugin_l1259_2 <= (not memory_arbitration_isStuck);
  when_CsrPlugin_l1259_3 <= (not writeBack_arbitration_isStuck);
  when_CsrPlugin_l1272 <= pkg_toStdLogic(pkg_cat(pkg_toStdLogicVector(CsrPlugin_exceptionPortCtrl_exceptionValids_writeBack),pkg_cat(pkg_toStdLogicVector(CsrPlugin_exceptionPortCtrl_exceptionValids_memory),pkg_cat(pkg_toStdLogicVector(CsrPlugin_exceptionPortCtrl_exceptionValids_execute),pkg_toStdLogicVector(CsrPlugin_exceptionPortCtrl_exceptionValids_decode)))) /= pkg_stdLogicVector("0000"));
  CsrPlugin_exceptionPendings_0 <= CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_decode;
  CsrPlugin_exceptionPendings_1 <= CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_execute;
  CsrPlugin_exceptionPendings_2 <= CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_memory;
  CsrPlugin_exceptionPendings_3 <= CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_writeBack;
  when_CsrPlugin_l1296 <= (CsrPlugin_mstatus_MIE or pkg_toStdLogic(CsrPlugin_privilege < pkg_unsigned("11")));
  when_CsrPlugin_l1302 <= ((zz_when_CsrPlugin_l1302 and pkg_toStdLogic(true)) and (not pkg_toStdLogic(false)));
  when_CsrPlugin_l1302_1 <= ((zz_when_CsrPlugin_l1302_1 and pkg_toStdLogic(true)) and (not pkg_toStdLogic(false)));
  when_CsrPlugin_l1302_2 <= ((zz_when_CsrPlugin_l1302_2 and pkg_toStdLogic(true)) and (not pkg_toStdLogic(false)));
  CsrPlugin_exception <= (CsrPlugin_exceptionPortCtrl_exceptionValids_writeBack and CsrPlugin_allowException);
  CsrPlugin_lastStageWasWfi <= pkg_toStdLogic(false);
  CsrPlugin_pipelineLiberator_active <= ((CsrPlugin_interrupt_valid and CsrPlugin_allowInterrupts) and decode_arbitration_isValid);
  when_CsrPlugin_l1335 <= (not execute_arbitration_isStuck);
  when_CsrPlugin_l1335_1 <= (not memory_arbitration_isStuck);
  when_CsrPlugin_l1335_2 <= (not writeBack_arbitration_isStuck);
  when_CsrPlugin_l1340 <= ((not CsrPlugin_pipelineLiberator_active) or decode_arbitration_removeIt);
  process(CsrPlugin_pipelineLiberator_pcValids_2,when_CsrPlugin_l1346,CsrPlugin_hadException)
  begin
    CsrPlugin_pipelineLiberator_done <= CsrPlugin_pipelineLiberator_pcValids_2;
    if when_CsrPlugin_l1346 = '1' then
      CsrPlugin_pipelineLiberator_done <= pkg_toStdLogic(false);
    end if;
    if CsrPlugin_hadException = '1' then
      CsrPlugin_pipelineLiberator_done <= pkg_toStdLogic(false);
    end if;
  end process;

  when_CsrPlugin_l1346 <= pkg_toStdLogic(pkg_cat(pkg_toStdLogicVector(CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_writeBack),pkg_cat(pkg_toStdLogicVector(CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_memory),pkg_toStdLogicVector(CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_execute))) /= pkg_stdLogicVector("000"));
  CsrPlugin_interruptJump <= ((CsrPlugin_interrupt_valid and CsrPlugin_pipelineLiberator_done) and CsrPlugin_allowInterrupts);
  process(CsrPlugin_interrupt_targetPrivilege,CsrPlugin_hadException,CsrPlugin_exceptionPortCtrl_exceptionTargetPrivilege)
  begin
    CsrPlugin_targetPrivilege <= CsrPlugin_interrupt_targetPrivilege;
    if CsrPlugin_hadException = '1' then
      CsrPlugin_targetPrivilege <= CsrPlugin_exceptionPortCtrl_exceptionTargetPrivilege;
    end if;
  end process;

  process(CsrPlugin_interrupt_code,CsrPlugin_hadException,CsrPlugin_exceptionPortCtrl_exceptionContext_code)
  begin
    CsrPlugin_trapCause <= pkg_resize(CsrPlugin_interrupt_code,4);
    if CsrPlugin_hadException = '1' then
      CsrPlugin_trapCause <= CsrPlugin_exceptionPortCtrl_exceptionContext_code;
    end if;
  end process;

  CsrPlugin_trapCauseEbreakDebug <= pkg_toStdLogic(false);
  process(CsrPlugin_targetPrivilege,CsrPlugin_mtvec_mode)
  begin
    CsrPlugin_xtvec_mode <= pkg_stdLogicVector("XX");
    case CsrPlugin_targetPrivilege is
      when "11" =>
        CsrPlugin_xtvec_mode <= CsrPlugin_mtvec_mode;
      when others =>
    end case;
  end process;

  process(CsrPlugin_targetPrivilege,CsrPlugin_mtvec_base)
  begin
    CsrPlugin_xtvec_base <= pkg_unsigned("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX");
    case CsrPlugin_targetPrivilege is
      when "11" =>
        CsrPlugin_xtvec_base <= CsrPlugin_mtvec_base;
      when others =>
    end case;
  end process;

  CsrPlugin_trapEnterDebug <= pkg_toStdLogic(false);
  when_CsrPlugin_l1390 <= (CsrPlugin_hadException or CsrPlugin_interruptJump);
  when_CsrPlugin_l1398 <= (not CsrPlugin_trapEnterDebug);
  when_CsrPlugin_l1456 <= (writeBack_arbitration_isValid and pkg_toStdLogic(writeBack_ENV_CTRL = EnvCtrlEnum_seq_XRET));
  switch_CsrPlugin_l1460 <= pkg_extract(writeBack_INSTRUCTION,29,28);
  contextSwitching <= CsrPlugin_jumpInterface_valid;
  when_CsrPlugin_l1527 <= pkg_toStdLogic(pkg_cat(pkg_toStdLogicVector((writeBack_arbitration_isValid and pkg_toStdLogic(writeBack_ENV_CTRL = EnvCtrlEnum_seq_XRET))),pkg_cat(pkg_toStdLogicVector((memory_arbitration_isValid and pkg_toStdLogic(memory_ENV_CTRL = EnvCtrlEnum_seq_XRET))),pkg_toStdLogicVector((execute_arbitration_isValid and pkg_toStdLogic(execute_ENV_CTRL = EnvCtrlEnum_seq_XRET))))) /= pkg_stdLogicVector("000"));
  execute_CsrPlugin_blockedBySideEffects <= (pkg_toStdLogic(pkg_cat(pkg_toStdLogicVector(writeBack_arbitration_isValid),pkg_toStdLogicVector(memory_arbitration_isValid)) /= pkg_stdLogicVector("00")) or pkg_toStdLogic(false));
  process(execute_CsrPlugin_csr_768,execute_CsrPlugin_csr_836,execute_CsrPlugin_csr_772,execute_CsrPlugin_csr_834,execute_CSR_READ_OPCODE,CsrPlugin_csrMapping_allowCsrSignal,when_CsrPlugin_l1719,when_CsrPlugin_l1725)
  begin
    execute_CsrPlugin_illegalAccess <= pkg_toStdLogic(true);
    if execute_CsrPlugin_csr_768 = '1' then
      execute_CsrPlugin_illegalAccess <= pkg_toStdLogic(false);
    end if;
    if execute_CsrPlugin_csr_836 = '1' then
      execute_CsrPlugin_illegalAccess <= pkg_toStdLogic(false);
    end if;
    if execute_CsrPlugin_csr_772 = '1' then
      execute_CsrPlugin_illegalAccess <= pkg_toStdLogic(false);
    end if;
    if execute_CsrPlugin_csr_834 = '1' then
      if execute_CSR_READ_OPCODE = '1' then
        execute_CsrPlugin_illegalAccess <= pkg_toStdLogic(false);
      end if;
    end if;
    if CsrPlugin_csrMapping_allowCsrSignal = '1' then
      execute_CsrPlugin_illegalAccess <= pkg_toStdLogic(false);
    end if;
    if when_CsrPlugin_l1719 = '1' then
      execute_CsrPlugin_illegalAccess <= pkg_toStdLogic(true);
    end if;
    if when_CsrPlugin_l1725 = '1' then
      execute_CsrPlugin_illegalAccess <= pkg_toStdLogic(false);
    end if;
  end process;

  process(when_CsrPlugin_l1547,when_CsrPlugin_l1548)
  begin
    execute_CsrPlugin_illegalInstruction <= pkg_toStdLogic(false);
    if when_CsrPlugin_l1547 = '1' then
      if when_CsrPlugin_l1548 = '1' then
        execute_CsrPlugin_illegalInstruction <= pkg_toStdLogic(true);
      end if;
    end if;
  end process;

  when_CsrPlugin_l1547 <= (execute_arbitration_isValid and pkg_toStdLogic(execute_ENV_CTRL = EnvCtrlEnum_seq_XRET));
  when_CsrPlugin_l1548 <= pkg_toStdLogic(CsrPlugin_privilege < unsigned(pkg_extract(execute_INSTRUCTION,29,28)));
  process(execute_arbitration_isValid,execute_IS_CSR,execute_CSR_WRITE_OPCODE,when_CsrPlugin_l1719)
  begin
    execute_CsrPlugin_writeInstruction <= ((execute_arbitration_isValid and execute_IS_CSR) and execute_CSR_WRITE_OPCODE);
    if when_CsrPlugin_l1719 = '1' then
      execute_CsrPlugin_writeInstruction <= pkg_toStdLogic(false);
    end if;
  end process;

  process(execute_arbitration_isValid,execute_IS_CSR,execute_CSR_READ_OPCODE,when_CsrPlugin_l1719)
  begin
    execute_CsrPlugin_readInstruction <= ((execute_arbitration_isValid and execute_IS_CSR) and execute_CSR_READ_OPCODE);
    if when_CsrPlugin_l1719 = '1' then
      execute_CsrPlugin_readInstruction <= pkg_toStdLogic(false);
    end if;
  end process;

  execute_CsrPlugin_writeEnable <= (execute_CsrPlugin_writeInstruction and (not execute_arbitration_isStuck));
  execute_CsrPlugin_readEnable <= (execute_CsrPlugin_readInstruction and (not execute_arbitration_isStuck));
  CsrPlugin_csrMapping_hazardFree <= (not execute_CsrPlugin_blockedBySideEffects);
  execute_CsrPlugin_readToWriteData <= CsrPlugin_csrMapping_readDataSignal;
  switch_Misc_l227_1 <= pkg_extract(execute_INSTRUCTION,13);
  process(switch_Misc_l227_1,execute_SRC1,execute_INSTRUCTION,execute_CsrPlugin_readToWriteData)
  begin
    case switch_Misc_l227_1 is
      when '0' =>
        zz_CsrPlugin_csrMapping_writeDataSignal <= execute_SRC1;
      when others =>
        zz_CsrPlugin_csrMapping_writeDataSignal <= pkg_mux(pkg_extract(execute_INSTRUCTION,12),(execute_CsrPlugin_readToWriteData and pkg_not(execute_SRC1)),(execute_CsrPlugin_readToWriteData or execute_SRC1));
    end case;
  end process;

  CsrPlugin_csrMapping_writeDataSignal <= zz_CsrPlugin_csrMapping_writeDataSignal;
  when_CsrPlugin_l1587 <= (execute_arbitration_isValid and execute_IS_CSR);
  when_CsrPlugin_l1591 <= (execute_arbitration_isValid and (execute_IS_CSR or pkg_toStdLogic(false)));
  execute_CsrPlugin_csrAddress <= pkg_extract(execute_INSTRUCTION,31,20);
  zz_decode_IS_RS2_SIGNED_1 <= pkg_toStdLogic((decode_INSTRUCTION and pkg_stdLogicVector("00000000000000000100000001010000")) = pkg_stdLogicVector("00000000000000000100000001010000"));
  zz_decode_IS_RS2_SIGNED_2 <= pkg_toStdLogic((decode_INSTRUCTION and pkg_stdLogicVector("00000000000000000000000000011000")) = pkg_stdLogicVector("00000000000000000000000000000000"));
  zz_decode_IS_RS2_SIGNED_3 <= pkg_toStdLogic((decode_INSTRUCTION and pkg_stdLogicVector("00000000000000000000000000000100")) = pkg_stdLogicVector("00000000000000000000000000000100"));
  zz_decode_IS_RS2_SIGNED_4 <= pkg_toStdLogic((decode_INSTRUCTION and pkg_stdLogicVector("00000000000000000000000001001000")) = pkg_stdLogicVector("00000000000000000000000001001000"));
  zz_decode_IS_RS2_SIGNED_5 <= pkg_toStdLogic((decode_INSTRUCTION and pkg_stdLogicVector("00000000000000000001000000000000")) = pkg_stdLogicVector("00000000000000000000000000000000"));
  zz_decode_IS_RS2_SIGNED <= pkg_cat(pkg_toStdLogicVector(pkg_toStdLogic(pkg_cat(pkg_toStdLogicVector(zz_decode_IS_RS2_SIGNED_4),pkg_toStdLogicVector(pkg_toStdLogic(zz_zz_decode_IS_RS2_SIGNED = zz_zz_decode_IS_RS2_SIGNED_1))) /= pkg_stdLogicVector("00"))),pkg_cat(pkg_toStdLogicVector(pkg_toStdLogic(pkg_toStdLogicVector(pkg_toStdLogic(zz_zz_decode_IS_RS2_SIGNED_2 = zz_zz_decode_IS_RS2_SIGNED_3)) /= pkg_stdLogicVector("0"))),pkg_cat(pkg_toStdLogicVector(pkg_toStdLogic(pkg_toStdLogicVector(zz_decode_IS_RS2_SIGNED_5) /= pkg_stdLogicVector("0"))),pkg_cat(pkg_toStdLogicVector(pkg_toStdLogic(zz_zz_decode_IS_RS2_SIGNED_4 /= zz_zz_decode_IS_RS2_SIGNED_5)),pkg_cat(pkg_toStdLogicVector(zz_zz_decode_IS_RS2_SIGNED_6),pkg_cat(zz_zz_decode_IS_RS2_SIGNED_7,zz_zz_decode_IS_RS2_SIGNED_9))))));
  zz_decode_SRC1_CTRL_2 <= pkg_extract(zz_decode_IS_RS2_SIGNED,2,1);
  zz_decode_SRC1_CTRL_1 <= zz_decode_SRC1_CTRL_2;
  zz_decode_ALU_CTRL_2 <= pkg_extract(zz_decode_IS_RS2_SIGNED,7,6);
  zz_decode_ALU_CTRL_1 <= zz_decode_ALU_CTRL_2;
  zz_decode_SRC2_CTRL_2 <= pkg_extract(zz_decode_IS_RS2_SIGNED,9,8);
  zz_decode_SRC2_CTRL_1 <= zz_decode_SRC2_CTRL_2;
  zz_decode_ENV_CTRL_2 <= pkg_extract(zz_decode_IS_RS2_SIGNED,18,18);
  zz_decode_ENV_CTRL_1 <= zz_decode_ENV_CTRL_2;
  zz_decode_ALU_BITWISE_CTRL_2 <= pkg_extract(zz_decode_IS_RS2_SIGNED,21,20);
  zz_decode_ALU_BITWISE_CTRL_1 <= zz_decode_ALU_BITWISE_CTRL_2;
  zz_decode_SHIFT_CTRL_2 <= pkg_extract(zz_decode_IS_RS2_SIGNED,24,23);
  zz_decode_SHIFT_CTRL_1 <= zz_decode_SHIFT_CTRL_2;
  zz_decode_BRANCH_CTRL_2 <= pkg_extract(zz_decode_IS_RS2_SIGNED,30,29);
  zz_decode_BRANCH_CTRL <= zz_decode_BRANCH_CTRL_2;
  decodeExceptionPort_valid <= (decode_arbitration_isValid and (not decode_LEGAL_INSTRUCTION));
  decodeExceptionPort_payload_code <= pkg_unsigned("0010");
  decodeExceptionPort_payload_badAddr <= unsigned(decode_INSTRUCTION);
  IBusCachedPlugin_mmuBus_rsp_physicalAddress <= IBusCachedPlugin_mmuBus_cmd_0_virtualAddress;
  IBusCachedPlugin_mmuBus_rsp_allowRead <= pkg_toStdLogic(true);
  IBusCachedPlugin_mmuBus_rsp_allowWrite <= pkg_toStdLogic(true);
  IBusCachedPlugin_mmuBus_rsp_allowExecute <= pkg_toStdLogic(true);
  IBusCachedPlugin_mmuBus_rsp_isIoAccess <= pkg_toStdLogic(pkg_extract(IBusCachedPlugin_mmuBus_rsp_physicalAddress,31,31) = pkg_unsigned("1"));
  IBusCachedPlugin_mmuBus_rsp_isPaging <= pkg_toStdLogic(false);
  IBusCachedPlugin_mmuBus_rsp_exception <= pkg_toStdLogic(false);
  IBusCachedPlugin_mmuBus_rsp_refilling <= pkg_toStdLogic(false);
  IBusCachedPlugin_mmuBus_busy <= pkg_toStdLogic(false);
  DBusCachedPlugin_mmuBus_rsp_physicalAddress <= DBusCachedPlugin_mmuBus_cmd_0_virtualAddress;
  DBusCachedPlugin_mmuBus_rsp_allowRead <= pkg_toStdLogic(true);
  DBusCachedPlugin_mmuBus_rsp_allowWrite <= pkg_toStdLogic(true);
  DBusCachedPlugin_mmuBus_rsp_allowExecute <= pkg_toStdLogic(true);
  DBusCachedPlugin_mmuBus_rsp_isIoAccess <= pkg_toStdLogic(pkg_extract(DBusCachedPlugin_mmuBus_rsp_physicalAddress,31,31) = pkg_unsigned("1"));
  DBusCachedPlugin_mmuBus_rsp_isPaging <= pkg_toStdLogic(false);
  DBusCachedPlugin_mmuBus_rsp_exception <= pkg_toStdLogic(false);
  DBusCachedPlugin_mmuBus_rsp_refilling <= pkg_toStdLogic(false);
  DBusCachedPlugin_mmuBus_busy <= pkg_toStdLogic(false);
  when_RegFilePlugin_l63 <= pkg_toStdLogic(pkg_extract(decode_INSTRUCTION,11,7) = pkg_stdLogicVector("00000"));
  decode_RegFilePlugin_regFileReadAddress1 <= unsigned(pkg_extract(decode_INSTRUCTION_ANTICIPATED,19,15));
  decode_RegFilePlugin_regFileReadAddress2 <= unsigned(pkg_extract(decode_INSTRUCTION_ANTICIPATED,24,20));
  decode_RegFilePlugin_rs1Data <= zz_RegFilePlugin_regFile_port0;
  decode_RegFilePlugin_rs2Data <= zz_RegFilePlugin_regFile_port0_1;
  process(zz_lastStageRegFileWrite_valid,writeBack_arbitration_isFiring,zz_10)
  begin
    lastStageRegFileWrite_valid <= (zz_lastStageRegFileWrite_valid and writeBack_arbitration_isFiring);
    if zz_10 = '1' then
      lastStageRegFileWrite_valid <= pkg_toStdLogic(true);
    end if;
  end process;

  process(zz_lastStageRegFileWrite_payload_address,zz_10)
  begin
    lastStageRegFileWrite_payload_address <= unsigned(pkg_extract(zz_lastStageRegFileWrite_payload_address,11,7));
    if zz_10 = '1' then
      lastStageRegFileWrite_payload_address <= pkg_unsigned("00000");
    end if;
  end process;

  process(zz_decode_RS2_2,zz_10)
  begin
    lastStageRegFileWrite_payload_data <= zz_decode_RS2_2;
    if zz_10 = '1' then
      lastStageRegFileWrite_payload_data <= pkg_stdLogicVector("00000000000000000000000000000000");
    end if;
  end process;

  process(execute_ALU_BITWISE_CTRL,execute_SRC1,execute_SRC2)
  begin
    case execute_ALU_BITWISE_CTRL is
      when AluBitwiseCtrlEnum_seq_AND_1 =>
        execute_IntAluPlugin_bitwise <= (execute_SRC1 and execute_SRC2);
      when AluBitwiseCtrlEnum_seq_OR_1 =>
        execute_IntAluPlugin_bitwise <= (execute_SRC1 or execute_SRC2);
      when others =>
        execute_IntAluPlugin_bitwise <= (execute_SRC1 xor execute_SRC2);
    end case;
  end process;

  process(execute_ALU_CTRL,execute_IntAluPlugin_bitwise,execute_SRC_LESS,execute_SRC_ADD_SUB)
  begin
    case execute_ALU_CTRL is
      when AluCtrlEnum_seq_BITWISE =>
        zz_execute_REGFILE_WRITE_DATA <= execute_IntAluPlugin_bitwise;
      when AluCtrlEnum_seq_SLT_SLTU =>
        zz_execute_REGFILE_WRITE_DATA <= pkg_resize(pkg_toStdLogicVector(execute_SRC_LESS),32);
      when others =>
        zz_execute_REGFILE_WRITE_DATA <= execute_SRC_ADD_SUB;
    end case;
  end process;

  process(execute_SRC1_CTRL,execute_RS1,execute_INSTRUCTION)
  begin
    case execute_SRC1_CTRL is
      when Src1CtrlEnum_seq_RS =>
        zz_execute_SRC1 <= execute_RS1;
      when Src1CtrlEnum_seq_PC_INCREMENT =>
        zz_execute_SRC1 <= pkg_resize(pkg_stdLogicVector("100"),32);
      when Src1CtrlEnum_seq_IMU =>
        zz_execute_SRC1 <= pkg_cat(pkg_extract(execute_INSTRUCTION,31,12),std_logic_vector(pkg_unsigned("000000000000")));
      when others =>
        zz_execute_SRC1 <= pkg_resize(pkg_extract(execute_INSTRUCTION,19,15),32);
    end case;
  end process;

  zz_execute_SRC2 <= pkg_extract(execute_INSTRUCTION,31);
  process(zz_execute_SRC2)
  begin
    zz_execute_SRC2_1(19) <= zz_execute_SRC2;
    zz_execute_SRC2_1(18) <= zz_execute_SRC2;
    zz_execute_SRC2_1(17) <= zz_execute_SRC2;
    zz_execute_SRC2_1(16) <= zz_execute_SRC2;
    zz_execute_SRC2_1(15) <= zz_execute_SRC2;
    zz_execute_SRC2_1(14) <= zz_execute_SRC2;
    zz_execute_SRC2_1(13) <= zz_execute_SRC2;
    zz_execute_SRC2_1(12) <= zz_execute_SRC2;
    zz_execute_SRC2_1(11) <= zz_execute_SRC2;
    zz_execute_SRC2_1(10) <= zz_execute_SRC2;
    zz_execute_SRC2_1(9) <= zz_execute_SRC2;
    zz_execute_SRC2_1(8) <= zz_execute_SRC2;
    zz_execute_SRC2_1(7) <= zz_execute_SRC2;
    zz_execute_SRC2_1(6) <= zz_execute_SRC2;
    zz_execute_SRC2_1(5) <= zz_execute_SRC2;
    zz_execute_SRC2_1(4) <= zz_execute_SRC2;
    zz_execute_SRC2_1(3) <= zz_execute_SRC2;
    zz_execute_SRC2_1(2) <= zz_execute_SRC2;
    zz_execute_SRC2_1(1) <= zz_execute_SRC2;
    zz_execute_SRC2_1(0) <= zz_execute_SRC2;
  end process;

  zz_execute_SRC2_2 <= pkg_extract(pkg_cat(pkg_extract(execute_INSTRUCTION,31,25),pkg_extract(execute_INSTRUCTION,11,7)),11);
  process(zz_execute_SRC2_2)
  begin
    zz_execute_SRC2_3(19) <= zz_execute_SRC2_2;
    zz_execute_SRC2_3(18) <= zz_execute_SRC2_2;
    zz_execute_SRC2_3(17) <= zz_execute_SRC2_2;
    zz_execute_SRC2_3(16) <= zz_execute_SRC2_2;
    zz_execute_SRC2_3(15) <= zz_execute_SRC2_2;
    zz_execute_SRC2_3(14) <= zz_execute_SRC2_2;
    zz_execute_SRC2_3(13) <= zz_execute_SRC2_2;
    zz_execute_SRC2_3(12) <= zz_execute_SRC2_2;
    zz_execute_SRC2_3(11) <= zz_execute_SRC2_2;
    zz_execute_SRC2_3(10) <= zz_execute_SRC2_2;
    zz_execute_SRC2_3(9) <= zz_execute_SRC2_2;
    zz_execute_SRC2_3(8) <= zz_execute_SRC2_2;
    zz_execute_SRC2_3(7) <= zz_execute_SRC2_2;
    zz_execute_SRC2_3(6) <= zz_execute_SRC2_2;
    zz_execute_SRC2_3(5) <= zz_execute_SRC2_2;
    zz_execute_SRC2_3(4) <= zz_execute_SRC2_2;
    zz_execute_SRC2_3(3) <= zz_execute_SRC2_2;
    zz_execute_SRC2_3(2) <= zz_execute_SRC2_2;
    zz_execute_SRC2_3(1) <= zz_execute_SRC2_2;
    zz_execute_SRC2_3(0) <= zz_execute_SRC2_2;
  end process;

  process(execute_SRC2_CTRL,execute_RS2,zz_execute_SRC2_1,execute_INSTRUCTION,zz_execute_SRC2_3,zz_execute_to_memory_PC)
  begin
    case execute_SRC2_CTRL is
      when Src2CtrlEnum_seq_RS =>
        zz_execute_SRC2_4 <= execute_RS2;
      when Src2CtrlEnum_seq_IMI =>
        zz_execute_SRC2_4 <= pkg_cat(zz_execute_SRC2_1,pkg_extract(execute_INSTRUCTION,31,20));
      when Src2CtrlEnum_seq_IMS =>
        zz_execute_SRC2_4 <= pkg_cat(zz_execute_SRC2_3,pkg_cat(pkg_extract(execute_INSTRUCTION,31,25),pkg_extract(execute_INSTRUCTION,11,7)));
      when others =>
        zz_execute_SRC2_4 <= std_logic_vector(zz_execute_to_memory_PC);
    end case;
  end process;

  process(execute_SRC1,execute_SRC_USE_SUB_LESS,execute_SRC2,execute_SRC2_FORCE_ZERO)
  begin
    execute_SrcPlugin_addSub <= std_logic_vector(((signed(execute_SRC1) + signed(pkg_mux(execute_SRC_USE_SUB_LESS,pkg_not(execute_SRC2),execute_SRC2))) + pkg_mux(execute_SRC_USE_SUB_LESS,pkg_signed("00000000000000000000000000000001"),pkg_signed("00000000000000000000000000000000"))));
    if execute_SRC2_FORCE_ZERO = '1' then
      execute_SrcPlugin_addSub <= execute_SRC1;
    end if;
  end process;

  execute_SrcPlugin_less <= pkg_mux(pkg_toStdLogic(pkg_extract(execute_SRC1,31) = pkg_extract(execute_SRC2,31)),pkg_extract(execute_SrcPlugin_addSub,31),pkg_mux(execute_SRC_LESS_UNSIGNED,pkg_extract(execute_SRC2,31),pkg_extract(execute_SRC1,31)));
  execute_FullBarrelShifterPlugin_amplitude <= unsigned(pkg_extract(execute_SRC2,4,0));
  process(execute_SRC1)
  begin
    zz_execute_FullBarrelShifterPlugin_reversed(0) <= pkg_extract(execute_SRC1,31);
    zz_execute_FullBarrelShifterPlugin_reversed(1) <= pkg_extract(execute_SRC1,30);
    zz_execute_FullBarrelShifterPlugin_reversed(2) <= pkg_extract(execute_SRC1,29);
    zz_execute_FullBarrelShifterPlugin_reversed(3) <= pkg_extract(execute_SRC1,28);
    zz_execute_FullBarrelShifterPlugin_reversed(4) <= pkg_extract(execute_SRC1,27);
    zz_execute_FullBarrelShifterPlugin_reversed(5) <= pkg_extract(execute_SRC1,26);
    zz_execute_FullBarrelShifterPlugin_reversed(6) <= pkg_extract(execute_SRC1,25);
    zz_execute_FullBarrelShifterPlugin_reversed(7) <= pkg_extract(execute_SRC1,24);
    zz_execute_FullBarrelShifterPlugin_reversed(8) <= pkg_extract(execute_SRC1,23);
    zz_execute_FullBarrelShifterPlugin_reversed(9) <= pkg_extract(execute_SRC1,22);
    zz_execute_FullBarrelShifterPlugin_reversed(10) <= pkg_extract(execute_SRC1,21);
    zz_execute_FullBarrelShifterPlugin_reversed(11) <= pkg_extract(execute_SRC1,20);
    zz_execute_FullBarrelShifterPlugin_reversed(12) <= pkg_extract(execute_SRC1,19);
    zz_execute_FullBarrelShifterPlugin_reversed(13) <= pkg_extract(execute_SRC1,18);
    zz_execute_FullBarrelShifterPlugin_reversed(14) <= pkg_extract(execute_SRC1,17);
    zz_execute_FullBarrelShifterPlugin_reversed(15) <= pkg_extract(execute_SRC1,16);
    zz_execute_FullBarrelShifterPlugin_reversed(16) <= pkg_extract(execute_SRC1,15);
    zz_execute_FullBarrelShifterPlugin_reversed(17) <= pkg_extract(execute_SRC1,14);
    zz_execute_FullBarrelShifterPlugin_reversed(18) <= pkg_extract(execute_SRC1,13);
    zz_execute_FullBarrelShifterPlugin_reversed(19) <= pkg_extract(execute_SRC1,12);
    zz_execute_FullBarrelShifterPlugin_reversed(20) <= pkg_extract(execute_SRC1,11);
    zz_execute_FullBarrelShifterPlugin_reversed(21) <= pkg_extract(execute_SRC1,10);
    zz_execute_FullBarrelShifterPlugin_reversed(22) <= pkg_extract(execute_SRC1,9);
    zz_execute_FullBarrelShifterPlugin_reversed(23) <= pkg_extract(execute_SRC1,8);
    zz_execute_FullBarrelShifterPlugin_reversed(24) <= pkg_extract(execute_SRC1,7);
    zz_execute_FullBarrelShifterPlugin_reversed(25) <= pkg_extract(execute_SRC1,6);
    zz_execute_FullBarrelShifterPlugin_reversed(26) <= pkg_extract(execute_SRC1,5);
    zz_execute_FullBarrelShifterPlugin_reversed(27) <= pkg_extract(execute_SRC1,4);
    zz_execute_FullBarrelShifterPlugin_reversed(28) <= pkg_extract(execute_SRC1,3);
    zz_execute_FullBarrelShifterPlugin_reversed(29) <= pkg_extract(execute_SRC1,2);
    zz_execute_FullBarrelShifterPlugin_reversed(30) <= pkg_extract(execute_SRC1,1);
    zz_execute_FullBarrelShifterPlugin_reversed(31) <= pkg_extract(execute_SRC1,0);
  end process;

  execute_FullBarrelShifterPlugin_reversed <= pkg_mux(pkg_toStdLogic(execute_SHIFT_CTRL = ShiftCtrlEnum_seq_SLL_1),zz_execute_FullBarrelShifterPlugin_reversed,execute_SRC1);
  process(memory_SHIFT_RIGHT)
  begin
    zz_decode_RS2_3(0) <= pkg_extract(memory_SHIFT_RIGHT,31);
    zz_decode_RS2_3(1) <= pkg_extract(memory_SHIFT_RIGHT,30);
    zz_decode_RS2_3(2) <= pkg_extract(memory_SHIFT_RIGHT,29);
    zz_decode_RS2_3(3) <= pkg_extract(memory_SHIFT_RIGHT,28);
    zz_decode_RS2_3(4) <= pkg_extract(memory_SHIFT_RIGHT,27);
    zz_decode_RS2_3(5) <= pkg_extract(memory_SHIFT_RIGHT,26);
    zz_decode_RS2_3(6) <= pkg_extract(memory_SHIFT_RIGHT,25);
    zz_decode_RS2_3(7) <= pkg_extract(memory_SHIFT_RIGHT,24);
    zz_decode_RS2_3(8) <= pkg_extract(memory_SHIFT_RIGHT,23);
    zz_decode_RS2_3(9) <= pkg_extract(memory_SHIFT_RIGHT,22);
    zz_decode_RS2_3(10) <= pkg_extract(memory_SHIFT_RIGHT,21);
    zz_decode_RS2_3(11) <= pkg_extract(memory_SHIFT_RIGHT,20);
    zz_decode_RS2_3(12) <= pkg_extract(memory_SHIFT_RIGHT,19);
    zz_decode_RS2_3(13) <= pkg_extract(memory_SHIFT_RIGHT,18);
    zz_decode_RS2_3(14) <= pkg_extract(memory_SHIFT_RIGHT,17);
    zz_decode_RS2_3(15) <= pkg_extract(memory_SHIFT_RIGHT,16);
    zz_decode_RS2_3(16) <= pkg_extract(memory_SHIFT_RIGHT,15);
    zz_decode_RS2_3(17) <= pkg_extract(memory_SHIFT_RIGHT,14);
    zz_decode_RS2_3(18) <= pkg_extract(memory_SHIFT_RIGHT,13);
    zz_decode_RS2_3(19) <= pkg_extract(memory_SHIFT_RIGHT,12);
    zz_decode_RS2_3(20) <= pkg_extract(memory_SHIFT_RIGHT,11);
    zz_decode_RS2_3(21) <= pkg_extract(memory_SHIFT_RIGHT,10);
    zz_decode_RS2_3(22) <= pkg_extract(memory_SHIFT_RIGHT,9);
    zz_decode_RS2_3(23) <= pkg_extract(memory_SHIFT_RIGHT,8);
    zz_decode_RS2_3(24) <= pkg_extract(memory_SHIFT_RIGHT,7);
    zz_decode_RS2_3(25) <= pkg_extract(memory_SHIFT_RIGHT,6);
    zz_decode_RS2_3(26) <= pkg_extract(memory_SHIFT_RIGHT,5);
    zz_decode_RS2_3(27) <= pkg_extract(memory_SHIFT_RIGHT,4);
    zz_decode_RS2_3(28) <= pkg_extract(memory_SHIFT_RIGHT,3);
    zz_decode_RS2_3(29) <= pkg_extract(memory_SHIFT_RIGHT,2);
    zz_decode_RS2_3(30) <= pkg_extract(memory_SHIFT_RIGHT,1);
    zz_decode_RS2_3(31) <= pkg_extract(memory_SHIFT_RIGHT,0);
  end process;

  process(when_HazardSimplePlugin_l57,when_HazardSimplePlugin_l58,when_HazardSimplePlugin_l48,when_HazardSimplePlugin_l57_1,when_HazardSimplePlugin_l58_1,when_HazardSimplePlugin_l48_1,when_HazardSimplePlugin_l57_2,when_HazardSimplePlugin_l58_2,when_HazardSimplePlugin_l48_2,when_HazardSimplePlugin_l105)
  begin
    HazardSimplePlugin_src0Hazard <= pkg_toStdLogic(false);
    if when_HazardSimplePlugin_l57 = '1' then
      if when_HazardSimplePlugin_l58 = '1' then
        if when_HazardSimplePlugin_l48 = '1' then
          HazardSimplePlugin_src0Hazard <= pkg_toStdLogic(true);
        end if;
      end if;
    end if;
    if when_HazardSimplePlugin_l57_1 = '1' then
      if when_HazardSimplePlugin_l58_1 = '1' then
        if when_HazardSimplePlugin_l48_1 = '1' then
          HazardSimplePlugin_src0Hazard <= pkg_toStdLogic(true);
        end if;
      end if;
    end if;
    if when_HazardSimplePlugin_l57_2 = '1' then
      if when_HazardSimplePlugin_l58_2 = '1' then
        if when_HazardSimplePlugin_l48_2 = '1' then
          HazardSimplePlugin_src0Hazard <= pkg_toStdLogic(true);
        end if;
      end if;
    end if;
    if when_HazardSimplePlugin_l105 = '1' then
      HazardSimplePlugin_src0Hazard <= pkg_toStdLogic(false);
    end if;
  end process;

  process(when_HazardSimplePlugin_l57,when_HazardSimplePlugin_l58,when_HazardSimplePlugin_l51,when_HazardSimplePlugin_l57_1,when_HazardSimplePlugin_l58_1,when_HazardSimplePlugin_l51_1,when_HazardSimplePlugin_l57_2,when_HazardSimplePlugin_l58_2,when_HazardSimplePlugin_l51_2,when_HazardSimplePlugin_l108)
  begin
    HazardSimplePlugin_src1Hazard <= pkg_toStdLogic(false);
    if when_HazardSimplePlugin_l57 = '1' then
      if when_HazardSimplePlugin_l58 = '1' then
        if when_HazardSimplePlugin_l51 = '1' then
          HazardSimplePlugin_src1Hazard <= pkg_toStdLogic(true);
        end if;
      end if;
    end if;
    if when_HazardSimplePlugin_l57_1 = '1' then
      if when_HazardSimplePlugin_l58_1 = '1' then
        if when_HazardSimplePlugin_l51_1 = '1' then
          HazardSimplePlugin_src1Hazard <= pkg_toStdLogic(true);
        end if;
      end if;
    end if;
    if when_HazardSimplePlugin_l57_2 = '1' then
      if when_HazardSimplePlugin_l58_2 = '1' then
        if when_HazardSimplePlugin_l51_2 = '1' then
          HazardSimplePlugin_src1Hazard <= pkg_toStdLogic(true);
        end if;
      end if;
    end if;
    if when_HazardSimplePlugin_l108 = '1' then
      HazardSimplePlugin_src1Hazard <= pkg_toStdLogic(false);
    end if;
  end process;

  HazardSimplePlugin_writeBackWrites_valid <= (zz_lastStageRegFileWrite_valid and writeBack_arbitration_isFiring);
  HazardSimplePlugin_writeBackWrites_payload_address <= pkg_extract(zz_lastStageRegFileWrite_payload_address,11,7);
  HazardSimplePlugin_writeBackWrites_payload_data <= zz_decode_RS2_2;
  HazardSimplePlugin_addr0Match <= pkg_toStdLogic(HazardSimplePlugin_writeBackBuffer_payload_address = pkg_extract(decode_INSTRUCTION,19,15));
  HazardSimplePlugin_addr1Match <= pkg_toStdLogic(HazardSimplePlugin_writeBackBuffer_payload_address = pkg_extract(decode_INSTRUCTION,24,20));
  when_HazardSimplePlugin_l47 <= pkg_toStdLogic(true);
  when_HazardSimplePlugin_l48 <= pkg_toStdLogic(pkg_extract(writeBack_INSTRUCTION,11,7) = pkg_extract(decode_INSTRUCTION,19,15));
  when_HazardSimplePlugin_l51 <= pkg_toStdLogic(pkg_extract(writeBack_INSTRUCTION,11,7) = pkg_extract(decode_INSTRUCTION,24,20));
  when_HazardSimplePlugin_l45 <= (writeBack_arbitration_isValid and writeBack_REGFILE_WRITE_VALID);
  when_HazardSimplePlugin_l57 <= (writeBack_arbitration_isValid and writeBack_REGFILE_WRITE_VALID);
  when_HazardSimplePlugin_l58 <= (pkg_toStdLogic(false) or (not when_HazardSimplePlugin_l47));
  when_HazardSimplePlugin_l48_1 <= pkg_toStdLogic(pkg_extract(memory_INSTRUCTION,11,7) = pkg_extract(decode_INSTRUCTION,19,15));
  when_HazardSimplePlugin_l51_1 <= pkg_toStdLogic(pkg_extract(memory_INSTRUCTION,11,7) = pkg_extract(decode_INSTRUCTION,24,20));
  when_HazardSimplePlugin_l45_1 <= (memory_arbitration_isValid and memory_REGFILE_WRITE_VALID);
  when_HazardSimplePlugin_l57_1 <= (memory_arbitration_isValid and memory_REGFILE_WRITE_VALID);
  when_HazardSimplePlugin_l58_1 <= (pkg_toStdLogic(false) or (not memory_BYPASSABLE_MEMORY_STAGE));
  when_HazardSimplePlugin_l48_2 <= pkg_toStdLogic(pkg_extract(execute_INSTRUCTION,11,7) = pkg_extract(decode_INSTRUCTION,19,15));
  when_HazardSimplePlugin_l51_2 <= pkg_toStdLogic(pkg_extract(execute_INSTRUCTION,11,7) = pkg_extract(decode_INSTRUCTION,24,20));
  when_HazardSimplePlugin_l45_2 <= (execute_arbitration_isValid and execute_REGFILE_WRITE_VALID);
  when_HazardSimplePlugin_l57_2 <= (execute_arbitration_isValid and execute_REGFILE_WRITE_VALID);
  when_HazardSimplePlugin_l58_2 <= (pkg_toStdLogic(false) or (not execute_BYPASSABLE_EXECUTE_STAGE));
  when_HazardSimplePlugin_l105 <= (not decode_RS1_USE);
  when_HazardSimplePlugin_l108 <= (not decode_RS2_USE);
  when_HazardSimplePlugin_l113 <= (decode_arbitration_isValid and (HazardSimplePlugin_src0Hazard or HazardSimplePlugin_src1Hazard));
  execute_MulPlugin_a <= execute_RS1;
  execute_MulPlugin_b <= execute_RS2;
  switch_MulPlugin_l87 <= pkg_extract(execute_INSTRUCTION,13,12);
  process(switch_MulPlugin_l87)
  begin
    case switch_MulPlugin_l87 is
      when "01" =>
        execute_MulPlugin_aSigned <= pkg_toStdLogic(true);
      when "10" =>
        execute_MulPlugin_aSigned <= pkg_toStdLogic(true);
      when others =>
        execute_MulPlugin_aSigned <= pkg_toStdLogic(false);
    end case;
  end process;

  process(switch_MulPlugin_l87)
  begin
    case switch_MulPlugin_l87 is
      when "01" =>
        execute_MulPlugin_bSigned <= pkg_toStdLogic(true);
      when "10" =>
        execute_MulPlugin_bSigned <= pkg_toStdLogic(false);
      when others =>
        execute_MulPlugin_bSigned <= pkg_toStdLogic(false);
    end case;
  end process;

  execute_MulPlugin_aULow <= unsigned(pkg_extract(execute_MulPlugin_a,15,0));
  execute_MulPlugin_bULow <= unsigned(pkg_extract(execute_MulPlugin_b,15,0));
  execute_MulPlugin_aSLow <= signed(pkg_cat(pkg_toStdLogicVector(pkg_toStdLogic(false)),pkg_extract(execute_MulPlugin_a,15,0)));
  execute_MulPlugin_bSLow <= signed(pkg_cat(pkg_toStdLogicVector(pkg_toStdLogic(false)),pkg_extract(execute_MulPlugin_b,15,0)));
  execute_MulPlugin_aHigh <= signed(pkg_cat(pkg_toStdLogicVector((execute_MulPlugin_aSigned and pkg_extract(execute_MulPlugin_a,31))),pkg_extract(execute_MulPlugin_a,31,16)));
  execute_MulPlugin_bHigh <= signed(pkg_cat(pkg_toStdLogicVector((execute_MulPlugin_bSigned and pkg_extract(execute_MulPlugin_b,31))),pkg_extract(execute_MulPlugin_b,31,16)));
  writeBack_MulPlugin_result <= (pkg_resize(writeBack_MUL_LOW,66) + pkg_shiftLeft(writeBack_MUL_HH,32));
  when_MulPlugin_l147 <= (writeBack_arbitration_isValid and writeBack_IS_MUL);
  switch_MulPlugin_l148 <= pkg_extract(writeBack_INSTRUCTION,13,12);
  memory_DivPlugin_frontendOk <= pkg_toStdLogic(true);
  process(when_MulDivIterativePlugin_l128,when_MulDivIterativePlugin_l132)
  begin
    memory_DivPlugin_div_counter_willIncrement <= pkg_toStdLogic(false);
    if when_MulDivIterativePlugin_l128 = '1' then
      if when_MulDivIterativePlugin_l132 = '1' then
        memory_DivPlugin_div_counter_willIncrement <= pkg_toStdLogic(true);
      end if;
    end if;
  end process;

  process(when_MulDivIterativePlugin_l162)
  begin
    memory_DivPlugin_div_counter_willClear <= pkg_toStdLogic(false);
    if when_MulDivIterativePlugin_l162 = '1' then
      memory_DivPlugin_div_counter_willClear <= pkg_toStdLogic(true);
    end if;
  end process;

  memory_DivPlugin_div_counter_willOverflowIfInc <= pkg_toStdLogic(memory_DivPlugin_div_counter_value = pkg_unsigned("100001"));
  memory_DivPlugin_div_counter_willOverflow <= (memory_DivPlugin_div_counter_willOverflowIfInc and memory_DivPlugin_div_counter_willIncrement);
  process(memory_DivPlugin_div_counter_willOverflow,memory_DivPlugin_div_counter_value,memory_DivPlugin_div_counter_willIncrement,memory_DivPlugin_div_counter_willClear)
  begin
    if memory_DivPlugin_div_counter_willOverflow = '1' then
      memory_DivPlugin_div_counter_valueNext <= pkg_unsigned("000000");
    else
      memory_DivPlugin_div_counter_valueNext <= (memory_DivPlugin_div_counter_value + pkg_resize(unsigned(pkg_toStdLogicVector(memory_DivPlugin_div_counter_willIncrement)),6));
    end if;
    if memory_DivPlugin_div_counter_willClear = '1' then
      memory_DivPlugin_div_counter_valueNext <= pkg_unsigned("000000");
    end if;
  end process;

  when_MulDivIterativePlugin_l126 <= pkg_toStdLogic(memory_DivPlugin_div_counter_value = pkg_unsigned("100000"));
  when_MulDivIterativePlugin_l126_1 <= (not memory_arbitration_isStuck);
  when_MulDivIterativePlugin_l128 <= (memory_arbitration_isValid and memory_IS_DIV);
  when_MulDivIterativePlugin_l129 <= ((not memory_DivPlugin_frontendOk) or (not memory_DivPlugin_div_done));
  when_MulDivIterativePlugin_l132 <= (memory_DivPlugin_frontendOk and (not memory_DivPlugin_div_done));
  zz_memory_DivPlugin_div_stage_0_remainderShifted <= pkg_extract(memory_DivPlugin_rs1,31,0);
  memory_DivPlugin_div_stage_0_remainderShifted <= unsigned(pkg_cat(std_logic_vector(pkg_extract(memory_DivPlugin_accumulator,31,0)),pkg_toStdLogicVector(pkg_extract(zz_memory_DivPlugin_div_stage_0_remainderShifted,31))));
  memory_DivPlugin_div_stage_0_remainderMinusDenominator <= (memory_DivPlugin_div_stage_0_remainderShifted - pkg_resize(memory_DivPlugin_rs2,33));
  memory_DivPlugin_div_stage_0_outRemainder <= pkg_mux((not pkg_extract(memory_DivPlugin_div_stage_0_remainderMinusDenominator,32)),pkg_resize(memory_DivPlugin_div_stage_0_remainderMinusDenominator,32),pkg_resize(memory_DivPlugin_div_stage_0_remainderShifted,32));
  memory_DivPlugin_div_stage_0_outNumerator <= pkg_resize(unsigned(pkg_cat(std_logic_vector(zz_memory_DivPlugin_div_stage_0_remainderShifted),pkg_toStdLogicVector((not pkg_extract(memory_DivPlugin_div_stage_0_remainderMinusDenominator,32))))),32);
  when_MulDivIterativePlugin_l151 <= pkg_toStdLogic(memory_DivPlugin_div_counter_value = pkg_unsigned("100000"));
  zz_memory_DivPlugin_div_result <= pkg_mux(pkg_extract(memory_INSTRUCTION,13),pkg_extract(memory_DivPlugin_accumulator,31,0),pkg_extract(memory_DivPlugin_rs1,31,0));
  when_MulDivIterativePlugin_l162 <= (not memory_arbitration_isStuck);
  zz_memory_DivPlugin_rs2 <= (pkg_extract(execute_RS2,31) and execute_IS_RS2_SIGNED);
  zz_memory_DivPlugin_rs1 <= (pkg_toStdLogic(false) or ((execute_IS_DIV and pkg_extract(execute_RS1,31)) and execute_IS_RS1_SIGNED));
  process(execute_IS_RS1_SIGNED,execute_RS1)
  begin
    zz_memory_DivPlugin_rs1_1(32) <= (execute_IS_RS1_SIGNED and pkg_extract(execute_RS1,31));
    zz_memory_DivPlugin_rs1_1(31 downto 0) <= execute_RS1;
  end process;

  execute_BranchPlugin_eq <= pkg_toStdLogic(execute_SRC1 = execute_SRC2);
  switch_Misc_l227_2 <= pkg_extract(execute_INSTRUCTION,14,12);
  process(switch_Misc_l227_2,execute_BranchPlugin_eq,execute_SRC_LESS)
  begin
    case switch_Misc_l227_2 is
      when "000" =>
        zz_execute_BRANCH_COND_RESULT <= execute_BranchPlugin_eq;
      when "001" =>
        zz_execute_BRANCH_COND_RESULT <= (not execute_BranchPlugin_eq);
      when "101" =>
        zz_execute_BRANCH_COND_RESULT <= (not execute_SRC_LESS);
      when "111" =>
        zz_execute_BRANCH_COND_RESULT <= (not execute_SRC_LESS);
      when others =>
        zz_execute_BRANCH_COND_RESULT <= execute_SRC_LESS;
    end case;
  end process;

  process(execute_BRANCH_CTRL,zz_execute_BRANCH_COND_RESULT)
  begin
    case execute_BRANCH_CTRL is
      when BranchCtrlEnum_seq_INC =>
        zz_execute_BRANCH_COND_RESULT_1 <= pkg_toStdLogic(false);
      when BranchCtrlEnum_seq_JAL =>
        zz_execute_BRANCH_COND_RESULT_1 <= pkg_toStdLogic(true);
      when BranchCtrlEnum_seq_JALR =>
        zz_execute_BRANCH_COND_RESULT_1 <= pkg_toStdLogic(true);
      when others =>
        zz_execute_BRANCH_COND_RESULT_1 <= zz_execute_BRANCH_COND_RESULT;
    end case;
  end process;

  zz_execute_BranchPlugin_missAlignedTarget <= pkg_extract(execute_INSTRUCTION,31);
  process(zz_execute_BranchPlugin_missAlignedTarget)
  begin
    zz_execute_BranchPlugin_missAlignedTarget_1(19) <= zz_execute_BranchPlugin_missAlignedTarget;
    zz_execute_BranchPlugin_missAlignedTarget_1(18) <= zz_execute_BranchPlugin_missAlignedTarget;
    zz_execute_BranchPlugin_missAlignedTarget_1(17) <= zz_execute_BranchPlugin_missAlignedTarget;
    zz_execute_BranchPlugin_missAlignedTarget_1(16) <= zz_execute_BranchPlugin_missAlignedTarget;
    zz_execute_BranchPlugin_missAlignedTarget_1(15) <= zz_execute_BranchPlugin_missAlignedTarget;
    zz_execute_BranchPlugin_missAlignedTarget_1(14) <= zz_execute_BranchPlugin_missAlignedTarget;
    zz_execute_BranchPlugin_missAlignedTarget_1(13) <= zz_execute_BranchPlugin_missAlignedTarget;
    zz_execute_BranchPlugin_missAlignedTarget_1(12) <= zz_execute_BranchPlugin_missAlignedTarget;
    zz_execute_BranchPlugin_missAlignedTarget_1(11) <= zz_execute_BranchPlugin_missAlignedTarget;
    zz_execute_BranchPlugin_missAlignedTarget_1(10) <= zz_execute_BranchPlugin_missAlignedTarget;
    zz_execute_BranchPlugin_missAlignedTarget_1(9) <= zz_execute_BranchPlugin_missAlignedTarget;
    zz_execute_BranchPlugin_missAlignedTarget_1(8) <= zz_execute_BranchPlugin_missAlignedTarget;
    zz_execute_BranchPlugin_missAlignedTarget_1(7) <= zz_execute_BranchPlugin_missAlignedTarget;
    zz_execute_BranchPlugin_missAlignedTarget_1(6) <= zz_execute_BranchPlugin_missAlignedTarget;
    zz_execute_BranchPlugin_missAlignedTarget_1(5) <= zz_execute_BranchPlugin_missAlignedTarget;
    zz_execute_BranchPlugin_missAlignedTarget_1(4) <= zz_execute_BranchPlugin_missAlignedTarget;
    zz_execute_BranchPlugin_missAlignedTarget_1(3) <= zz_execute_BranchPlugin_missAlignedTarget;
    zz_execute_BranchPlugin_missAlignedTarget_1(2) <= zz_execute_BranchPlugin_missAlignedTarget;
    zz_execute_BranchPlugin_missAlignedTarget_1(1) <= zz_execute_BranchPlugin_missAlignedTarget;
    zz_execute_BranchPlugin_missAlignedTarget_1(0) <= zz_execute_BranchPlugin_missAlignedTarget;
  end process;

  zz_execute_BranchPlugin_missAlignedTarget_2 <= pkg_extract(pkg_cat(pkg_cat(pkg_cat(pkg_toStdLogicVector(pkg_extract(execute_INSTRUCTION,31)),pkg_extract(execute_INSTRUCTION,19,12)),pkg_toStdLogicVector(pkg_extract(execute_INSTRUCTION,20))),pkg_extract(execute_INSTRUCTION,30,21)),19);
  process(zz_execute_BranchPlugin_missAlignedTarget_2)
  begin
    zz_execute_BranchPlugin_missAlignedTarget_3(10) <= zz_execute_BranchPlugin_missAlignedTarget_2;
    zz_execute_BranchPlugin_missAlignedTarget_3(9) <= zz_execute_BranchPlugin_missAlignedTarget_2;
    zz_execute_BranchPlugin_missAlignedTarget_3(8) <= zz_execute_BranchPlugin_missAlignedTarget_2;
    zz_execute_BranchPlugin_missAlignedTarget_3(7) <= zz_execute_BranchPlugin_missAlignedTarget_2;
    zz_execute_BranchPlugin_missAlignedTarget_3(6) <= zz_execute_BranchPlugin_missAlignedTarget_2;
    zz_execute_BranchPlugin_missAlignedTarget_3(5) <= zz_execute_BranchPlugin_missAlignedTarget_2;
    zz_execute_BranchPlugin_missAlignedTarget_3(4) <= zz_execute_BranchPlugin_missAlignedTarget_2;
    zz_execute_BranchPlugin_missAlignedTarget_3(3) <= zz_execute_BranchPlugin_missAlignedTarget_2;
    zz_execute_BranchPlugin_missAlignedTarget_3(2) <= zz_execute_BranchPlugin_missAlignedTarget_2;
    zz_execute_BranchPlugin_missAlignedTarget_3(1) <= zz_execute_BranchPlugin_missAlignedTarget_2;
    zz_execute_BranchPlugin_missAlignedTarget_3(0) <= zz_execute_BranchPlugin_missAlignedTarget_2;
  end process;

  zz_execute_BranchPlugin_missAlignedTarget_4 <= pkg_extract(pkg_cat(pkg_cat(pkg_cat(pkg_toStdLogicVector(pkg_extract(execute_INSTRUCTION,31)),pkg_toStdLogicVector(pkg_extract(execute_INSTRUCTION,7))),pkg_extract(execute_INSTRUCTION,30,25)),pkg_extract(execute_INSTRUCTION,11,8)),11);
  process(zz_execute_BranchPlugin_missAlignedTarget_4)
  begin
    zz_execute_BranchPlugin_missAlignedTarget_5(18) <= zz_execute_BranchPlugin_missAlignedTarget_4;
    zz_execute_BranchPlugin_missAlignedTarget_5(17) <= zz_execute_BranchPlugin_missAlignedTarget_4;
    zz_execute_BranchPlugin_missAlignedTarget_5(16) <= zz_execute_BranchPlugin_missAlignedTarget_4;
    zz_execute_BranchPlugin_missAlignedTarget_5(15) <= zz_execute_BranchPlugin_missAlignedTarget_4;
    zz_execute_BranchPlugin_missAlignedTarget_5(14) <= zz_execute_BranchPlugin_missAlignedTarget_4;
    zz_execute_BranchPlugin_missAlignedTarget_5(13) <= zz_execute_BranchPlugin_missAlignedTarget_4;
    zz_execute_BranchPlugin_missAlignedTarget_5(12) <= zz_execute_BranchPlugin_missAlignedTarget_4;
    zz_execute_BranchPlugin_missAlignedTarget_5(11) <= zz_execute_BranchPlugin_missAlignedTarget_4;
    zz_execute_BranchPlugin_missAlignedTarget_5(10) <= zz_execute_BranchPlugin_missAlignedTarget_4;
    zz_execute_BranchPlugin_missAlignedTarget_5(9) <= zz_execute_BranchPlugin_missAlignedTarget_4;
    zz_execute_BranchPlugin_missAlignedTarget_5(8) <= zz_execute_BranchPlugin_missAlignedTarget_4;
    zz_execute_BranchPlugin_missAlignedTarget_5(7) <= zz_execute_BranchPlugin_missAlignedTarget_4;
    zz_execute_BranchPlugin_missAlignedTarget_5(6) <= zz_execute_BranchPlugin_missAlignedTarget_4;
    zz_execute_BranchPlugin_missAlignedTarget_5(5) <= zz_execute_BranchPlugin_missAlignedTarget_4;
    zz_execute_BranchPlugin_missAlignedTarget_5(4) <= zz_execute_BranchPlugin_missAlignedTarget_4;
    zz_execute_BranchPlugin_missAlignedTarget_5(3) <= zz_execute_BranchPlugin_missAlignedTarget_4;
    zz_execute_BranchPlugin_missAlignedTarget_5(2) <= zz_execute_BranchPlugin_missAlignedTarget_4;
    zz_execute_BranchPlugin_missAlignedTarget_5(1) <= zz_execute_BranchPlugin_missAlignedTarget_4;
    zz_execute_BranchPlugin_missAlignedTarget_5(0) <= zz_execute_BranchPlugin_missAlignedTarget_4;
  end process;

  process(execute_BRANCH_CTRL,zz_execute_BranchPlugin_missAlignedTarget_1,execute_INSTRUCTION,execute_RS1,zz_execute_BranchPlugin_missAlignedTarget_3,zz_execute_BranchPlugin_missAlignedTarget_5)
  begin
    case execute_BRANCH_CTRL is
      when BranchCtrlEnum_seq_JALR =>
        zz_execute_BranchPlugin_missAlignedTarget_6 <= (pkg_extract(pkg_cat(zz_execute_BranchPlugin_missAlignedTarget_1,pkg_extract(execute_INSTRUCTION,31,20)),1) xor pkg_extract(execute_RS1,1));
      when BranchCtrlEnum_seq_JAL =>
        zz_execute_BranchPlugin_missAlignedTarget_6 <= pkg_extract(pkg_cat(pkg_cat(zz_execute_BranchPlugin_missAlignedTarget_3,pkg_cat(pkg_cat(pkg_cat(pkg_toStdLogicVector(pkg_extract(execute_INSTRUCTION,31)),pkg_extract(execute_INSTRUCTION,19,12)),pkg_toStdLogicVector(pkg_extract(execute_INSTRUCTION,20))),pkg_extract(execute_INSTRUCTION,30,21))),pkg_toStdLogicVector(pkg_toStdLogic(false))),1);
      when others =>
        zz_execute_BranchPlugin_missAlignedTarget_6 <= pkg_extract(pkg_cat(pkg_cat(zz_execute_BranchPlugin_missAlignedTarget_5,pkg_cat(pkg_cat(pkg_cat(pkg_toStdLogicVector(pkg_extract(execute_INSTRUCTION,31)),pkg_toStdLogicVector(pkg_extract(execute_INSTRUCTION,7))),pkg_extract(execute_INSTRUCTION,30,25)),pkg_extract(execute_INSTRUCTION,11,8))),pkg_toStdLogicVector(pkg_toStdLogic(false))),1);
    end case;
  end process;

  execute_BranchPlugin_missAlignedTarget <= (execute_BRANCH_COND_RESULT and zz_execute_BranchPlugin_missAlignedTarget_6);
  process(execute_BRANCH_CTRL,execute_RS1,execute_PC)
  begin
    case execute_BRANCH_CTRL is
      when BranchCtrlEnum_seq_JALR =>
        execute_BranchPlugin_branch_src1 <= unsigned(execute_RS1);
      when others =>
        execute_BranchPlugin_branch_src1 <= execute_PC;
    end case;
  end process;

  zz_execute_BranchPlugin_branch_src2 <= pkg_extract(execute_INSTRUCTION,31);
  process(zz_execute_BranchPlugin_branch_src2)
  begin
    zz_execute_BranchPlugin_branch_src2_1(19) <= zz_execute_BranchPlugin_branch_src2;
    zz_execute_BranchPlugin_branch_src2_1(18) <= zz_execute_BranchPlugin_branch_src2;
    zz_execute_BranchPlugin_branch_src2_1(17) <= zz_execute_BranchPlugin_branch_src2;
    zz_execute_BranchPlugin_branch_src2_1(16) <= zz_execute_BranchPlugin_branch_src2;
    zz_execute_BranchPlugin_branch_src2_1(15) <= zz_execute_BranchPlugin_branch_src2;
    zz_execute_BranchPlugin_branch_src2_1(14) <= zz_execute_BranchPlugin_branch_src2;
    zz_execute_BranchPlugin_branch_src2_1(13) <= zz_execute_BranchPlugin_branch_src2;
    zz_execute_BranchPlugin_branch_src2_1(12) <= zz_execute_BranchPlugin_branch_src2;
    zz_execute_BranchPlugin_branch_src2_1(11) <= zz_execute_BranchPlugin_branch_src2;
    zz_execute_BranchPlugin_branch_src2_1(10) <= zz_execute_BranchPlugin_branch_src2;
    zz_execute_BranchPlugin_branch_src2_1(9) <= zz_execute_BranchPlugin_branch_src2;
    zz_execute_BranchPlugin_branch_src2_1(8) <= zz_execute_BranchPlugin_branch_src2;
    zz_execute_BranchPlugin_branch_src2_1(7) <= zz_execute_BranchPlugin_branch_src2;
    zz_execute_BranchPlugin_branch_src2_1(6) <= zz_execute_BranchPlugin_branch_src2;
    zz_execute_BranchPlugin_branch_src2_1(5) <= zz_execute_BranchPlugin_branch_src2;
    zz_execute_BranchPlugin_branch_src2_1(4) <= zz_execute_BranchPlugin_branch_src2;
    zz_execute_BranchPlugin_branch_src2_1(3) <= zz_execute_BranchPlugin_branch_src2;
    zz_execute_BranchPlugin_branch_src2_1(2) <= zz_execute_BranchPlugin_branch_src2;
    zz_execute_BranchPlugin_branch_src2_1(1) <= zz_execute_BranchPlugin_branch_src2;
    zz_execute_BranchPlugin_branch_src2_1(0) <= zz_execute_BranchPlugin_branch_src2;
  end process;

  process(execute_BRANCH_CTRL,zz_execute_BranchPlugin_branch_src2_1,execute_INSTRUCTION,zz_execute_BranchPlugin_branch_src2_3,zz_execute_BranchPlugin_branch_src2_6,zz_execute_BranchPlugin_branch_src2_7,zz_execute_BranchPlugin_branch_src2_8,zz_execute_BranchPlugin_branch_src2_5,zz_execute_BranchPlugin_branch_src2_9,zz_execute_BranchPlugin_branch_src2_10,execute_PREDICTION_HAD_BRANCHED2)
  begin
    case execute_BRANCH_CTRL is
      when BranchCtrlEnum_seq_JALR =>
        execute_BranchPlugin_branch_src2 <= unsigned(pkg_cat(zz_execute_BranchPlugin_branch_src2_1,pkg_extract(execute_INSTRUCTION,31,20)));
      when others =>
        execute_BranchPlugin_branch_src2 <= unsigned(pkg_mux(pkg_toStdLogic(execute_BRANCH_CTRL = BranchCtrlEnum_seq_JAL),pkg_cat(pkg_cat(zz_execute_BranchPlugin_branch_src2_3,pkg_cat(pkg_cat(pkg_cat(zz_execute_BranchPlugin_branch_src2_6,zz_execute_BranchPlugin_branch_src2_7),pkg_toStdLogicVector(zz_execute_BranchPlugin_branch_src2_8)),pkg_extract(execute_INSTRUCTION,30,21))),pkg_toStdLogicVector(pkg_toStdLogic(false))),pkg_cat(pkg_cat(zz_execute_BranchPlugin_branch_src2_5,pkg_cat(pkg_cat(pkg_cat(zz_execute_BranchPlugin_branch_src2_9,zz_execute_BranchPlugin_branch_src2_10),pkg_extract(execute_INSTRUCTION,30,25)),pkg_extract(execute_INSTRUCTION,11,8))),pkg_toStdLogicVector(pkg_toStdLogic(false)))));
        if execute_PREDICTION_HAD_BRANCHED2 = '1' then
          execute_BranchPlugin_branch_src2 <= pkg_resize(unsigned(pkg_stdLogicVector("100")),32);
        end if;
    end case;
  end process;

  zz_execute_BranchPlugin_branch_src2_2 <= pkg_extract(pkg_cat(pkg_cat(pkg_cat(pkg_toStdLogicVector(pkg_extract(execute_INSTRUCTION,31)),pkg_extract(execute_INSTRUCTION,19,12)),pkg_toStdLogicVector(pkg_extract(execute_INSTRUCTION,20))),pkg_extract(execute_INSTRUCTION,30,21)),19);
  process(zz_execute_BranchPlugin_branch_src2_2)
  begin
    zz_execute_BranchPlugin_branch_src2_3(10) <= zz_execute_BranchPlugin_branch_src2_2;
    zz_execute_BranchPlugin_branch_src2_3(9) <= zz_execute_BranchPlugin_branch_src2_2;
    zz_execute_BranchPlugin_branch_src2_3(8) <= zz_execute_BranchPlugin_branch_src2_2;
    zz_execute_BranchPlugin_branch_src2_3(7) <= zz_execute_BranchPlugin_branch_src2_2;
    zz_execute_BranchPlugin_branch_src2_3(6) <= zz_execute_BranchPlugin_branch_src2_2;
    zz_execute_BranchPlugin_branch_src2_3(5) <= zz_execute_BranchPlugin_branch_src2_2;
    zz_execute_BranchPlugin_branch_src2_3(4) <= zz_execute_BranchPlugin_branch_src2_2;
    zz_execute_BranchPlugin_branch_src2_3(3) <= zz_execute_BranchPlugin_branch_src2_2;
    zz_execute_BranchPlugin_branch_src2_3(2) <= zz_execute_BranchPlugin_branch_src2_2;
    zz_execute_BranchPlugin_branch_src2_3(1) <= zz_execute_BranchPlugin_branch_src2_2;
    zz_execute_BranchPlugin_branch_src2_3(0) <= zz_execute_BranchPlugin_branch_src2_2;
  end process;

  zz_execute_BranchPlugin_branch_src2_4 <= pkg_extract(pkg_cat(pkg_cat(pkg_cat(pkg_toStdLogicVector(pkg_extract(execute_INSTRUCTION,31)),pkg_toStdLogicVector(pkg_extract(execute_INSTRUCTION,7))),pkg_extract(execute_INSTRUCTION,30,25)),pkg_extract(execute_INSTRUCTION,11,8)),11);
  process(zz_execute_BranchPlugin_branch_src2_4)
  begin
    zz_execute_BranchPlugin_branch_src2_5(18) <= zz_execute_BranchPlugin_branch_src2_4;
    zz_execute_BranchPlugin_branch_src2_5(17) <= zz_execute_BranchPlugin_branch_src2_4;
    zz_execute_BranchPlugin_branch_src2_5(16) <= zz_execute_BranchPlugin_branch_src2_4;
    zz_execute_BranchPlugin_branch_src2_5(15) <= zz_execute_BranchPlugin_branch_src2_4;
    zz_execute_BranchPlugin_branch_src2_5(14) <= zz_execute_BranchPlugin_branch_src2_4;
    zz_execute_BranchPlugin_branch_src2_5(13) <= zz_execute_BranchPlugin_branch_src2_4;
    zz_execute_BranchPlugin_branch_src2_5(12) <= zz_execute_BranchPlugin_branch_src2_4;
    zz_execute_BranchPlugin_branch_src2_5(11) <= zz_execute_BranchPlugin_branch_src2_4;
    zz_execute_BranchPlugin_branch_src2_5(10) <= zz_execute_BranchPlugin_branch_src2_4;
    zz_execute_BranchPlugin_branch_src2_5(9) <= zz_execute_BranchPlugin_branch_src2_4;
    zz_execute_BranchPlugin_branch_src2_5(8) <= zz_execute_BranchPlugin_branch_src2_4;
    zz_execute_BranchPlugin_branch_src2_5(7) <= zz_execute_BranchPlugin_branch_src2_4;
    zz_execute_BranchPlugin_branch_src2_5(6) <= zz_execute_BranchPlugin_branch_src2_4;
    zz_execute_BranchPlugin_branch_src2_5(5) <= zz_execute_BranchPlugin_branch_src2_4;
    zz_execute_BranchPlugin_branch_src2_5(4) <= zz_execute_BranchPlugin_branch_src2_4;
    zz_execute_BranchPlugin_branch_src2_5(3) <= zz_execute_BranchPlugin_branch_src2_4;
    zz_execute_BranchPlugin_branch_src2_5(2) <= zz_execute_BranchPlugin_branch_src2_4;
    zz_execute_BranchPlugin_branch_src2_5(1) <= zz_execute_BranchPlugin_branch_src2_4;
    zz_execute_BranchPlugin_branch_src2_5(0) <= zz_execute_BranchPlugin_branch_src2_4;
  end process;

  execute_BranchPlugin_branchAdder <= (execute_BranchPlugin_branch_src1 + execute_BranchPlugin_branch_src2);
  BranchPlugin_jumpInterface_valid <= ((execute_arbitration_isValid and execute_BRANCH_DO) and (not pkg_toStdLogic(false)));
  BranchPlugin_jumpInterface_payload <= execute_BRANCH_CALC;
  process(execute_arbitration_isValid,execute_BRANCH_DO,execute_BRANCH_CALC,when_BranchPlugin_l304)
  begin
    BranchPlugin_branchExceptionPort_valid <= (execute_arbitration_isValid and (execute_BRANCH_DO and pkg_extract(execute_BRANCH_CALC,1)));
    if when_BranchPlugin_l304 = '1' then
      BranchPlugin_branchExceptionPort_valid <= pkg_toStdLogic(false);
    end if;
  end process;

  BranchPlugin_branchExceptionPort_payload_code <= pkg_unsigned("0000");
  BranchPlugin_branchExceptionPort_payload_badAddr <= execute_BRANCH_CALC;
  when_BranchPlugin_l304 <= pkg_toStdLogic(false);
  IBusCachedPlugin_decodePrediction_rsp_wasWrong <= BranchPlugin_jumpInterface_valid;
  when_Pipeline_l124 <= (not execute_arbitration_isStuck);
  when_Pipeline_l124_1 <= (not memory_arbitration_isStuck);
  when_Pipeline_l124_2 <= ((not writeBack_arbitration_isStuck) and (not CsrPlugin_exceptionPortCtrl_exceptionValids_writeBack));
  when_Pipeline_l124_3 <= (not execute_arbitration_isStuck);
  when_Pipeline_l124_4 <= (not memory_arbitration_isStuck);
  when_Pipeline_l124_5 <= (not writeBack_arbitration_isStuck);
  when_Pipeline_l124_6 <= (not execute_arbitration_isStuck);
  when_Pipeline_l124_7 <= (not memory_arbitration_isStuck);
  when_Pipeline_l124_8 <= (not writeBack_arbitration_isStuck);
  when_Pipeline_l124_9 <= (not execute_arbitration_isStuck);
  when_Pipeline_l124_10 <= (not execute_arbitration_isStuck);
  when_Pipeline_l124_11 <= (not execute_arbitration_isStuck);
  zz_decode_to_execute_SRC1_CTRL_1 <= decode_SRC1_CTRL;
  zz_decode_SRC1_CTRL <= zz_decode_SRC1_CTRL_1;
  when_Pipeline_l124_12 <= (not execute_arbitration_isStuck);
  zz_execute_SRC1_CTRL <= decode_to_execute_SRC1_CTRL;
  when_Pipeline_l124_13 <= (not execute_arbitration_isStuck);
  when_Pipeline_l124_14 <= (not execute_arbitration_isStuck);
  when_Pipeline_l124_15 <= (not memory_arbitration_isStuck);
  when_Pipeline_l124_16 <= (not writeBack_arbitration_isStuck);
  zz_decode_to_execute_ALU_CTRL_1 <= decode_ALU_CTRL;
  zz_decode_ALU_CTRL <= zz_decode_ALU_CTRL_1;
  when_Pipeline_l124_17 <= (not execute_arbitration_isStuck);
  zz_execute_ALU_CTRL <= decode_to_execute_ALU_CTRL;
  zz_decode_to_execute_SRC2_CTRL_1 <= decode_SRC2_CTRL;
  zz_decode_SRC2_CTRL <= zz_decode_SRC2_CTRL_1;
  when_Pipeline_l124_18 <= (not execute_arbitration_isStuck);
  zz_execute_SRC2_CTRL <= decode_to_execute_SRC2_CTRL;
  when_Pipeline_l124_19 <= (not execute_arbitration_isStuck);
  when_Pipeline_l124_20 <= (not memory_arbitration_isStuck);
  when_Pipeline_l124_21 <= (not writeBack_arbitration_isStuck);
  when_Pipeline_l124_22 <= (not execute_arbitration_isStuck);
  when_Pipeline_l124_23 <= (not execute_arbitration_isStuck);
  when_Pipeline_l124_24 <= (not memory_arbitration_isStuck);
  when_Pipeline_l124_25 <= (not execute_arbitration_isStuck);
  when_Pipeline_l124_26 <= (not memory_arbitration_isStuck);
  when_Pipeline_l124_27 <= (not writeBack_arbitration_isStuck);
  when_Pipeline_l124_28 <= (not execute_arbitration_isStuck);
  when_Pipeline_l124_29 <= (not execute_arbitration_isStuck);
  zz_decode_to_execute_ENV_CTRL_1 <= decode_ENV_CTRL;
  zz_execute_to_memory_ENV_CTRL_1 <= execute_ENV_CTRL;
  zz_memory_to_writeBack_ENV_CTRL_1 <= memory_ENV_CTRL;
  zz_decode_ENV_CTRL <= zz_decode_ENV_CTRL_1;
  when_Pipeline_l124_30 <= (not execute_arbitration_isStuck);
  zz_execute_ENV_CTRL <= decode_to_execute_ENV_CTRL;
  when_Pipeline_l124_31 <= (not memory_arbitration_isStuck);
  zz_memory_ENV_CTRL <= execute_to_memory_ENV_CTRL;
  when_Pipeline_l124_32 <= (not writeBack_arbitration_isStuck);
  zz_writeBack_ENV_CTRL <= memory_to_writeBack_ENV_CTRL;
  when_Pipeline_l124_33 <= (not execute_arbitration_isStuck);
  zz_decode_to_execute_ALU_BITWISE_CTRL_1 <= decode_ALU_BITWISE_CTRL;
  zz_decode_ALU_BITWISE_CTRL <= zz_decode_ALU_BITWISE_CTRL_1;
  when_Pipeline_l124_34 <= (not execute_arbitration_isStuck);
  zz_execute_ALU_BITWISE_CTRL <= decode_to_execute_ALU_BITWISE_CTRL;
  zz_decode_to_execute_SHIFT_CTRL_1 <= decode_SHIFT_CTRL;
  zz_execute_to_memory_SHIFT_CTRL_1 <= execute_SHIFT_CTRL;
  zz_decode_SHIFT_CTRL <= zz_decode_SHIFT_CTRL_1;
  when_Pipeline_l124_35 <= (not execute_arbitration_isStuck);
  zz_execute_SHIFT_CTRL <= decode_to_execute_SHIFT_CTRL;
  when_Pipeline_l124_36 <= (not memory_arbitration_isStuck);
  zz_memory_SHIFT_CTRL <= execute_to_memory_SHIFT_CTRL;
  when_Pipeline_l124_37 <= (not execute_arbitration_isStuck);
  when_Pipeline_l124_38 <= (not memory_arbitration_isStuck);
  when_Pipeline_l124_39 <= (not writeBack_arbitration_isStuck);
  when_Pipeline_l124_40 <= (not execute_arbitration_isStuck);
  when_Pipeline_l124_41 <= (not memory_arbitration_isStuck);
  when_Pipeline_l124_42 <= (not execute_arbitration_isStuck);
  when_Pipeline_l124_43 <= (not execute_arbitration_isStuck);
  zz_decode_to_execute_BRANCH_CTRL_1 <= decode_BRANCH_CTRL;
  zz_decode_BRANCH_CTRL_1 <= zz_decode_BRANCH_CTRL;
  when_Pipeline_l124_44 <= (not execute_arbitration_isStuck);
  zz_execute_BRANCH_CTRL <= decode_to_execute_BRANCH_CTRL;
  when_Pipeline_l124_45 <= (not execute_arbitration_isStuck);
  when_Pipeline_l124_46 <= (not execute_arbitration_isStuck);
  when_Pipeline_l124_47 <= (not execute_arbitration_isStuck);
  when_Pipeline_l124_48 <= (not execute_arbitration_isStuck);
  when_Pipeline_l124_49 <= (not memory_arbitration_isStuck);
  when_Pipeline_l124_50 <= (not writeBack_arbitration_isStuck);
  when_Pipeline_l124_51 <= (not memory_arbitration_isStuck);
  when_Pipeline_l124_52 <= (not writeBack_arbitration_isStuck);
  when_Pipeline_l124_53 <= (not memory_arbitration_isStuck);
  when_Pipeline_l124_54 <= (not memory_arbitration_isStuck);
  when_Pipeline_l124_55 <= (not memory_arbitration_isStuck);
  when_Pipeline_l124_56 <= (not memory_arbitration_isStuck);
  when_Pipeline_l124_57 <= (not memory_arbitration_isStuck);
  when_Pipeline_l124_58 <= (not writeBack_arbitration_isStuck);
  when_Pipeline_l124_59 <= (not writeBack_arbitration_isStuck);
  decode_arbitration_isFlushed <= (pkg_toStdLogic(pkg_cat(pkg_toStdLogicVector(writeBack_arbitration_flushNext),pkg_cat(pkg_toStdLogicVector(memory_arbitration_flushNext),pkg_toStdLogicVector(execute_arbitration_flushNext))) /= pkg_stdLogicVector("000")) or pkg_toStdLogic(pkg_cat(pkg_toStdLogicVector(writeBack_arbitration_flushIt),pkg_cat(pkg_toStdLogicVector(memory_arbitration_flushIt),pkg_cat(pkg_toStdLogicVector(execute_arbitration_flushIt),pkg_toStdLogicVector(decode_arbitration_flushIt)))) /= pkg_stdLogicVector("0000")));
  execute_arbitration_isFlushed <= (pkg_toStdLogic(pkg_cat(pkg_toStdLogicVector(writeBack_arbitration_flushNext),pkg_toStdLogicVector(memory_arbitration_flushNext)) /= pkg_stdLogicVector("00")) or pkg_toStdLogic(pkg_cat(pkg_toStdLogicVector(writeBack_arbitration_flushIt),pkg_cat(pkg_toStdLogicVector(memory_arbitration_flushIt),pkg_toStdLogicVector(execute_arbitration_flushIt))) /= pkg_stdLogicVector("000")));
  memory_arbitration_isFlushed <= (pkg_toStdLogic(pkg_toStdLogicVector(writeBack_arbitration_flushNext) /= pkg_stdLogicVector("0")) or pkg_toStdLogic(pkg_cat(pkg_toStdLogicVector(writeBack_arbitration_flushIt),pkg_toStdLogicVector(memory_arbitration_flushIt)) /= pkg_stdLogicVector("00")));
  writeBack_arbitration_isFlushed <= (pkg_toStdLogic(false) or pkg_toStdLogic(pkg_toStdLogicVector(writeBack_arbitration_flushIt) /= pkg_stdLogicVector("0")));
  decode_arbitration_isStuckByOthers <= (decode_arbitration_haltByOther or (((pkg_toStdLogic(false) or execute_arbitration_isStuck) or memory_arbitration_isStuck) or writeBack_arbitration_isStuck));
  decode_arbitration_isStuck <= (decode_arbitration_haltItself or decode_arbitration_isStuckByOthers);
  decode_arbitration_isMoving <= ((not decode_arbitration_isStuck) and (not decode_arbitration_removeIt));
  decode_arbitration_isFiring <= ((decode_arbitration_isValid and (not decode_arbitration_isStuck)) and (not decode_arbitration_removeIt));
  execute_arbitration_isStuckByOthers <= (execute_arbitration_haltByOther or ((pkg_toStdLogic(false) or memory_arbitration_isStuck) or writeBack_arbitration_isStuck));
  execute_arbitration_isStuck <= (execute_arbitration_haltItself or execute_arbitration_isStuckByOthers);
  execute_arbitration_isMoving <= ((not execute_arbitration_isStuck) and (not execute_arbitration_removeIt));
  execute_arbitration_isFiring <= ((execute_arbitration_isValid and (not execute_arbitration_isStuck)) and (not execute_arbitration_removeIt));
  memory_arbitration_isStuckByOthers <= (memory_arbitration_haltByOther or (pkg_toStdLogic(false) or writeBack_arbitration_isStuck));
  memory_arbitration_isStuck <= (memory_arbitration_haltItself or memory_arbitration_isStuckByOthers);
  memory_arbitration_isMoving <= ((not memory_arbitration_isStuck) and (not memory_arbitration_removeIt));
  memory_arbitration_isFiring <= ((memory_arbitration_isValid and (not memory_arbitration_isStuck)) and (not memory_arbitration_removeIt));
  writeBack_arbitration_isStuckByOthers <= (writeBack_arbitration_haltByOther or pkg_toStdLogic(false));
  writeBack_arbitration_isStuck <= (writeBack_arbitration_haltItself or writeBack_arbitration_isStuckByOthers);
  writeBack_arbitration_isMoving <= ((not writeBack_arbitration_isStuck) and (not writeBack_arbitration_removeIt));
  writeBack_arbitration_isFiring <= ((writeBack_arbitration_isValid and (not writeBack_arbitration_isStuck)) and (not writeBack_arbitration_removeIt));
  when_Pipeline_l151 <= ((not execute_arbitration_isStuck) or execute_arbitration_removeIt);
  when_Pipeline_l154 <= ((not decode_arbitration_isStuck) and (not decode_arbitration_removeIt));
  when_Pipeline_l151_1 <= ((not memory_arbitration_isStuck) or memory_arbitration_removeIt);
  when_Pipeline_l154_1 <= ((not execute_arbitration_isStuck) and (not execute_arbitration_removeIt));
  when_Pipeline_l151_2 <= ((not writeBack_arbitration_isStuck) or writeBack_arbitration_removeIt);
  when_Pipeline_l154_2 <= ((not memory_arbitration_isStuck) and (not memory_arbitration_removeIt));
  when_CsrPlugin_l1669 <= (not execute_arbitration_isStuck);
  when_CsrPlugin_l1669_1 <= (not execute_arbitration_isStuck);
  when_CsrPlugin_l1669_2 <= (not execute_arbitration_isStuck);
  when_CsrPlugin_l1669_3 <= (not execute_arbitration_isStuck);
  switch_CsrPlugin_l1031 <= pkg_extract(CsrPlugin_csrMapping_writeDataSignal,12,11);
  process(execute_CsrPlugin_csr_768,CsrPlugin_mstatus_MPIE,CsrPlugin_mstatus_MIE,CsrPlugin_mstatus_MPP)
  begin
    zz_CsrPlugin_csrMapping_readDataInit <= pkg_stdLogicVector("00000000000000000000000000000000");
    if execute_CsrPlugin_csr_768 = '1' then
      zz_CsrPlugin_csrMapping_readDataInit(7 downto 7) <= pkg_toStdLogicVector(CsrPlugin_mstatus_MPIE);
      zz_CsrPlugin_csrMapping_readDataInit(3 downto 3) <= pkg_toStdLogicVector(CsrPlugin_mstatus_MIE);
      zz_CsrPlugin_csrMapping_readDataInit(12 downto 11) <= std_logic_vector(CsrPlugin_mstatus_MPP);
    end if;
  end process;

  process(execute_CsrPlugin_csr_836,CsrPlugin_mip_MEIP,CsrPlugin_mip_MTIP,CsrPlugin_mip_MSIP)
  begin
    zz_CsrPlugin_csrMapping_readDataInit_1 <= pkg_stdLogicVector("00000000000000000000000000000000");
    if execute_CsrPlugin_csr_836 = '1' then
      zz_CsrPlugin_csrMapping_readDataInit_1(11 downto 11) <= pkg_toStdLogicVector(CsrPlugin_mip_MEIP);
      zz_CsrPlugin_csrMapping_readDataInit_1(7 downto 7) <= pkg_toStdLogicVector(CsrPlugin_mip_MTIP);
      zz_CsrPlugin_csrMapping_readDataInit_1(3 downto 3) <= pkg_toStdLogicVector(CsrPlugin_mip_MSIP);
    end if;
  end process;

  process(execute_CsrPlugin_csr_772,CsrPlugin_mie_MEIE,CsrPlugin_mie_MTIE,CsrPlugin_mie_MSIE)
  begin
    zz_CsrPlugin_csrMapping_readDataInit_2 <= pkg_stdLogicVector("00000000000000000000000000000000");
    if execute_CsrPlugin_csr_772 = '1' then
      zz_CsrPlugin_csrMapping_readDataInit_2(11 downto 11) <= pkg_toStdLogicVector(CsrPlugin_mie_MEIE);
      zz_CsrPlugin_csrMapping_readDataInit_2(7 downto 7) <= pkg_toStdLogicVector(CsrPlugin_mie_MTIE);
      zz_CsrPlugin_csrMapping_readDataInit_2(3 downto 3) <= pkg_toStdLogicVector(CsrPlugin_mie_MSIE);
    end if;
  end process;

  process(execute_CsrPlugin_csr_834,CsrPlugin_mcause_interrupt,CsrPlugin_mcause_exceptionCode)
  begin
    zz_CsrPlugin_csrMapping_readDataInit_3 <= pkg_stdLogicVector("00000000000000000000000000000000");
    if execute_CsrPlugin_csr_834 = '1' then
      zz_CsrPlugin_csrMapping_readDataInit_3(31 downto 31) <= pkg_toStdLogicVector(CsrPlugin_mcause_interrupt);
      zz_CsrPlugin_csrMapping_readDataInit_3(3 downto 0) <= std_logic_vector(CsrPlugin_mcause_exceptionCode);
    end if;
  end process;

  CsrPlugin_csrMapping_readDataInit <= ((zz_CsrPlugin_csrMapping_readDataInit or zz_CsrPlugin_csrMapping_readDataInit_1) or (zz_CsrPlugin_csrMapping_readDataInit_2 or zz_CsrPlugin_csrMapping_readDataInit_3));
  when_CsrPlugin_l1702 <= ((execute_arbitration_isValid and execute_IS_CSR) and (pkg_toStdLogic(pkg_cat(pkg_extract(execute_CsrPlugin_csrAddress,11,2),pkg_stdLogicVector("00")) = pkg_stdLogicVector("001110100000")) or pkg_toStdLogic(pkg_cat(pkg_extract(execute_CsrPlugin_csrAddress,11,4),pkg_stdLogicVector("0000")) = pkg_stdLogicVector("001110110000"))));
  zz_when_CsrPlugin_l1709 <= unsigned((execute_CsrPlugin_csrAddress and pkg_stdLogicVector("111101100000")));
  when_CsrPlugin_l1709 <= (((execute_arbitration_isValid and execute_IS_CSR) and pkg_toStdLogic(pkg_unsigned("00011") <= unsigned(pkg_extract(execute_CsrPlugin_csrAddress,4,0)))) and ((pkg_toStdLogic(zz_when_CsrPlugin_l1709 = pkg_unsigned("101100000000")) or ((pkg_toStdLogic(zz_when_CsrPlugin_l1709 = pkg_unsigned("110000000000")) and (not execute_CsrPlugin_writeInstruction)) and pkg_toStdLogic(CsrPlugin_privilege = pkg_unsigned("11")))) or pkg_toStdLogic(unsigned((execute_CsrPlugin_csrAddress and pkg_stdLogicVector("111111100000"))) = pkg_unsigned("001100100000"))));
  process(CsrPlugin_csrMapping_doForceFailCsr,when_CsrPlugin_l1717)
  begin
    when_CsrPlugin_l1719 <= CsrPlugin_csrMapping_doForceFailCsr;
    if when_CsrPlugin_l1717 = '1' then
      when_CsrPlugin_l1719 <= pkg_toStdLogic(true);
    end if;
  end process;

  when_CsrPlugin_l1717 <= pkg_toStdLogic(CsrPlugin_privilege < unsigned(pkg_extract(execute_CsrPlugin_csrAddress,9,8)));
  when_CsrPlugin_l1725 <= ((not execute_arbitration_isValid) or (not execute_IS_CSR));
  process(io_mainClk, resetCtrl_systemReset)
  begin
    if resetCtrl_systemReset = '1' then
      IBusCachedPlugin_fetchPc_pcReg <= pkg_unsigned("00000000000000000100000000000000");
      IBusCachedPlugin_fetchPc_correctionReg <= pkg_toStdLogic(false);
      IBusCachedPlugin_fetchPc_booted <= pkg_toStdLogic(false);
      IBusCachedPlugin_fetchPc_inc <= pkg_toStdLogic(false);
      zz_IBusCachedPlugin_iBusRsp_stages_1_input_valid_1 <= pkg_toStdLogic(false);
      zz_IBusCachedPlugin_iBusRsp_stages_1_output_m2sPipe_valid <= pkg_toStdLogic(false);
      IBusCachedPlugin_injector_nextPcCalc_valids_0 <= pkg_toStdLogic(false);
      IBusCachedPlugin_injector_nextPcCalc_valids_1 <= pkg_toStdLogic(false);
      IBusCachedPlugin_injector_nextPcCalc_valids_2 <= pkg_toStdLogic(false);
      IBusCachedPlugin_injector_nextPcCalc_valids_3 <= pkg_toStdLogic(false);
      IBusCachedPlugin_injector_nextPcCalc_valids_4 <= pkg_toStdLogic(false);
      IBusCachedPlugin_rspCounter <= pkg_unsigned("00000000000000000000000000000000");
      DBusCachedPlugin_rspCounter <= pkg_unsigned("00000000000000000000000000000000");
      CsrPlugin_mstatus_MIE <= pkg_toStdLogic(false);
      CsrPlugin_mstatus_MPIE <= pkg_toStdLogic(false);
      CsrPlugin_mstatus_MPP <= pkg_unsigned("11");
      CsrPlugin_mie_MEIE <= pkg_toStdLogic(false);
      CsrPlugin_mie_MTIE <= pkg_toStdLogic(false);
      CsrPlugin_mie_MSIE <= pkg_toStdLogic(false);
      CsrPlugin_mcycle <= pkg_unsigned("0000000000000000000000000000000000000000000000000000000000000000");
      CsrPlugin_minstret <= pkg_unsigned("0000000000000000000000000000000000000000000000000000000000000000");
      CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_decode <= pkg_toStdLogic(false);
      CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_execute <= pkg_toStdLogic(false);
      CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_memory <= pkg_toStdLogic(false);
      CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_writeBack <= pkg_toStdLogic(false);
      CsrPlugin_interrupt_valid <= pkg_toStdLogic(false);
      CsrPlugin_pipelineLiberator_pcValids_0 <= pkg_toStdLogic(false);
      CsrPlugin_pipelineLiberator_pcValids_1 <= pkg_toStdLogic(false);
      CsrPlugin_pipelineLiberator_pcValids_2 <= pkg_toStdLogic(false);
      CsrPlugin_hadException <= pkg_toStdLogic(false);
      execute_CsrPlugin_wfiWake <= pkg_toStdLogic(false);
      zz_10 <= pkg_toStdLogic(true);
      HazardSimplePlugin_writeBackBuffer_valid <= pkg_toStdLogic(false);
      memory_DivPlugin_div_counter_value <= pkg_unsigned("000000");
      execute_arbitration_isValid <= pkg_toStdLogic(false);
      memory_arbitration_isValid <= pkg_toStdLogic(false);
      writeBack_arbitration_isValid <= pkg_toStdLogic(false);
    elsif rising_edge(io_mainClk) then
      if IBusCachedPlugin_fetchPc_correction = '1' then
        IBusCachedPlugin_fetchPc_correctionReg <= pkg_toStdLogic(true);
      end if;
      if IBusCachedPlugin_fetchPc_output_fire = '1' then
        IBusCachedPlugin_fetchPc_correctionReg <= pkg_toStdLogic(false);
      end if;
      IBusCachedPlugin_fetchPc_booted <= pkg_toStdLogic(true);
      if when_Fetcher_l133 = '1' then
        IBusCachedPlugin_fetchPc_inc <= pkg_toStdLogic(false);
      end if;
      if IBusCachedPlugin_fetchPc_output_fire = '1' then
        IBusCachedPlugin_fetchPc_inc <= pkg_toStdLogic(true);
      end if;
      if when_Fetcher_l133_1 = '1' then
        IBusCachedPlugin_fetchPc_inc <= pkg_toStdLogic(false);
      end if;
      if when_Fetcher_l160 = '1' then
        IBusCachedPlugin_fetchPc_pcReg <= IBusCachedPlugin_fetchPc_pc;
      end if;
      if IBusCachedPlugin_iBusRsp_flush = '1' then
        zz_IBusCachedPlugin_iBusRsp_stages_1_input_valid_1 <= pkg_toStdLogic(false);
      end if;
      if zz_IBusCachedPlugin_iBusRsp_stages_0_output_ready = '1' then
        zz_IBusCachedPlugin_iBusRsp_stages_1_input_valid_1 <= (IBusCachedPlugin_iBusRsp_stages_0_output_valid and (not pkg_toStdLogic(false)));
      end if;
      if IBusCachedPlugin_iBusRsp_flush = '1' then
        zz_IBusCachedPlugin_iBusRsp_stages_1_output_m2sPipe_valid <= pkg_toStdLogic(false);
      end if;
      if IBusCachedPlugin_iBusRsp_stages_1_output_ready = '1' then
        zz_IBusCachedPlugin_iBusRsp_stages_1_output_m2sPipe_valid <= (IBusCachedPlugin_iBusRsp_stages_1_output_valid and (not IBusCachedPlugin_iBusRsp_flush));
      end if;
      if IBusCachedPlugin_fetchPc_flushed = '1' then
        IBusCachedPlugin_injector_nextPcCalc_valids_0 <= pkg_toStdLogic(false);
      end if;
      if when_Fetcher_l331 = '1' then
        IBusCachedPlugin_injector_nextPcCalc_valids_0 <= pkg_toStdLogic(true);
      end if;
      if IBusCachedPlugin_fetchPc_flushed = '1' then
        IBusCachedPlugin_injector_nextPcCalc_valids_1 <= pkg_toStdLogic(false);
      end if;
      if when_Fetcher_l331_1 = '1' then
        IBusCachedPlugin_injector_nextPcCalc_valids_1 <= IBusCachedPlugin_injector_nextPcCalc_valids_0;
      end if;
      if IBusCachedPlugin_fetchPc_flushed = '1' then
        IBusCachedPlugin_injector_nextPcCalc_valids_1 <= pkg_toStdLogic(false);
      end if;
      if IBusCachedPlugin_fetchPc_flushed = '1' then
        IBusCachedPlugin_injector_nextPcCalc_valids_2 <= pkg_toStdLogic(false);
      end if;
      if when_Fetcher_l331_2 = '1' then
        IBusCachedPlugin_injector_nextPcCalc_valids_2 <= IBusCachedPlugin_injector_nextPcCalc_valids_1;
      end if;
      if IBusCachedPlugin_fetchPc_flushed = '1' then
        IBusCachedPlugin_injector_nextPcCalc_valids_2 <= pkg_toStdLogic(false);
      end if;
      if IBusCachedPlugin_fetchPc_flushed = '1' then
        IBusCachedPlugin_injector_nextPcCalc_valids_3 <= pkg_toStdLogic(false);
      end if;
      if when_Fetcher_l331_3 = '1' then
        IBusCachedPlugin_injector_nextPcCalc_valids_3 <= IBusCachedPlugin_injector_nextPcCalc_valids_2;
      end if;
      if IBusCachedPlugin_fetchPc_flushed = '1' then
        IBusCachedPlugin_injector_nextPcCalc_valids_3 <= pkg_toStdLogic(false);
      end if;
      if IBusCachedPlugin_fetchPc_flushed = '1' then
        IBusCachedPlugin_injector_nextPcCalc_valids_4 <= pkg_toStdLogic(false);
      end if;
      if when_Fetcher_l331_4 = '1' then
        IBusCachedPlugin_injector_nextPcCalc_valids_4 <= IBusCachedPlugin_injector_nextPcCalc_valids_3;
      end if;
      if IBusCachedPlugin_fetchPc_flushed = '1' then
        IBusCachedPlugin_injector_nextPcCalc_valids_4 <= pkg_toStdLogic(false);
      end if;
      if iBus_rsp_valid = '1' then
        IBusCachedPlugin_rspCounter <= (IBusCachedPlugin_rspCounter + pkg_unsigned("00000000000000000000000000000001"));
      end if;
      if dBus_rsp_valid = '1' then
        DBusCachedPlugin_rspCounter <= (DBusCachedPlugin_rspCounter + pkg_unsigned("00000000000000000000000000000001"));
      end if;
      CsrPlugin_mcycle <= (CsrPlugin_mcycle + pkg_unsigned("0000000000000000000000000000000000000000000000000000000000000001"));
      if writeBack_arbitration_isFiring = '1' then
        CsrPlugin_minstret <= (CsrPlugin_minstret + pkg_unsigned("0000000000000000000000000000000000000000000000000000000000000001"));
      end if;
      if when_CsrPlugin_l1259 = '1' then
        CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_decode <= pkg_toStdLogic(false);
      else
        CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_decode <= CsrPlugin_exceptionPortCtrl_exceptionValids_decode;
      end if;
      if when_CsrPlugin_l1259_1 = '1' then
        CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_execute <= (CsrPlugin_exceptionPortCtrl_exceptionValids_decode and (not decode_arbitration_isStuck));
      else
        CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_execute <= CsrPlugin_exceptionPortCtrl_exceptionValids_execute;
      end if;
      if when_CsrPlugin_l1259_2 = '1' then
        CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_memory <= (CsrPlugin_exceptionPortCtrl_exceptionValids_execute and (not execute_arbitration_isStuck));
      else
        CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_memory <= CsrPlugin_exceptionPortCtrl_exceptionValids_memory;
      end if;
      if when_CsrPlugin_l1259_3 = '1' then
        CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_writeBack <= (CsrPlugin_exceptionPortCtrl_exceptionValids_memory and (not memory_arbitration_isStuck));
      else
        CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_writeBack <= pkg_toStdLogic(false);
      end if;
      CsrPlugin_interrupt_valid <= pkg_toStdLogic(false);
      if when_CsrPlugin_l1296 = '1' then
        if when_CsrPlugin_l1302 = '1' then
          CsrPlugin_interrupt_valid <= pkg_toStdLogic(true);
        end if;
        if when_CsrPlugin_l1302_1 = '1' then
          CsrPlugin_interrupt_valid <= pkg_toStdLogic(true);
        end if;
        if when_CsrPlugin_l1302_2 = '1' then
          CsrPlugin_interrupt_valid <= pkg_toStdLogic(true);
        end if;
      end if;
      if CsrPlugin_pipelineLiberator_active = '1' then
        if when_CsrPlugin_l1335 = '1' then
          CsrPlugin_pipelineLiberator_pcValids_0 <= pkg_toStdLogic(true);
        end if;
        if when_CsrPlugin_l1335_1 = '1' then
          CsrPlugin_pipelineLiberator_pcValids_1 <= CsrPlugin_pipelineLiberator_pcValids_0;
        end if;
        if when_CsrPlugin_l1335_2 = '1' then
          CsrPlugin_pipelineLiberator_pcValids_2 <= CsrPlugin_pipelineLiberator_pcValids_1;
        end if;
      end if;
      if when_CsrPlugin_l1340 = '1' then
        CsrPlugin_pipelineLiberator_pcValids_0 <= pkg_toStdLogic(false);
        CsrPlugin_pipelineLiberator_pcValids_1 <= pkg_toStdLogic(false);
        CsrPlugin_pipelineLiberator_pcValids_2 <= pkg_toStdLogic(false);
      end if;
      if CsrPlugin_interruptJump = '1' then
        CsrPlugin_interrupt_valid <= pkg_toStdLogic(false);
      end if;
      CsrPlugin_hadException <= CsrPlugin_exception;
      if when_CsrPlugin_l1390 = '1' then
        if when_CsrPlugin_l1398 = '1' then
          case CsrPlugin_targetPrivilege is
            when "11" =>
              CsrPlugin_mstatus_MIE <= pkg_toStdLogic(false);
              CsrPlugin_mstatus_MPIE <= CsrPlugin_mstatus_MIE;
              CsrPlugin_mstatus_MPP <= CsrPlugin_privilege;
            when others =>
          end case;
        end if;
      end if;
      if when_CsrPlugin_l1456 = '1' then
        case switch_CsrPlugin_l1460 is
          when "11" =>
            CsrPlugin_mstatus_MPP <= pkg_unsigned("00");
            CsrPlugin_mstatus_MIE <= CsrPlugin_mstatus_MPIE;
            CsrPlugin_mstatus_MPIE <= pkg_toStdLogic(true);
          when others =>
        end case;
      end if;
      execute_CsrPlugin_wfiWake <= (pkg_toStdLogic(pkg_cat(pkg_toStdLogicVector(zz_when_CsrPlugin_l1302_2),pkg_cat(pkg_toStdLogicVector(zz_when_CsrPlugin_l1302_1),pkg_toStdLogicVector(zz_when_CsrPlugin_l1302))) /= pkg_stdLogicVector("000")) or CsrPlugin_thirdPartyWake);
      zz_10 <= pkg_toStdLogic(false);
      HazardSimplePlugin_writeBackBuffer_valid <= HazardSimplePlugin_writeBackWrites_valid;
      memory_DivPlugin_div_counter_value <= memory_DivPlugin_div_counter_valueNext;
      if when_Pipeline_l151 = '1' then
        execute_arbitration_isValid <= pkg_toStdLogic(false);
      end if;
      if when_Pipeline_l154 = '1' then
        execute_arbitration_isValid <= decode_arbitration_isValid;
      end if;
      if when_Pipeline_l151_1 = '1' then
        memory_arbitration_isValid <= pkg_toStdLogic(false);
      end if;
      if when_Pipeline_l154_1 = '1' then
        memory_arbitration_isValid <= execute_arbitration_isValid;
      end if;
      if when_Pipeline_l151_2 = '1' then
        writeBack_arbitration_isValid <= pkg_toStdLogic(false);
      end if;
      if when_Pipeline_l154_2 = '1' then
        writeBack_arbitration_isValid <= memory_arbitration_isValid;
      end if;
      if execute_CsrPlugin_csr_768 = '1' then
        if execute_CsrPlugin_writeEnable = '1' then
          CsrPlugin_mstatus_MPIE <= pkg_extract(CsrPlugin_csrMapping_writeDataSignal,7);
          CsrPlugin_mstatus_MIE <= pkg_extract(CsrPlugin_csrMapping_writeDataSignal,3);
          case switch_CsrPlugin_l1031 is
            when "11" =>
              CsrPlugin_mstatus_MPP <= pkg_unsigned("11");
            when others =>
          end case;
        end if;
      end if;
      if execute_CsrPlugin_csr_772 = '1' then
        if execute_CsrPlugin_writeEnable = '1' then
          CsrPlugin_mie_MEIE <= pkg_extract(CsrPlugin_csrMapping_writeDataSignal,11);
          CsrPlugin_mie_MTIE <= pkg_extract(CsrPlugin_csrMapping_writeDataSignal,7);
          CsrPlugin_mie_MSIE <= pkg_extract(CsrPlugin_csrMapping_writeDataSignal,3);
        end if;
      end if;
    end if;
  end process;

  process(io_mainClk)
  begin
    if rising_edge(io_mainClk) then
      if IBusCachedPlugin_iBusRsp_stages_1_output_ready = '1' then
        zz_IBusCachedPlugin_iBusRsp_stages_1_output_m2sPipe_payload <= IBusCachedPlugin_iBusRsp_stages_1_output_payload;
      end if;
      if IBusCachedPlugin_iBusRsp_stages_1_input_ready = '1' then
        IBusCachedPlugin_s1_tightlyCoupledHit <= IBusCachedPlugin_s0_tightlyCoupledHit;
      end if;
      if IBusCachedPlugin_iBusRsp_stages_2_input_ready = '1' then
        IBusCachedPlugin_s2_tightlyCoupledHit <= IBusCachedPlugin_s1_tightlyCoupledHit;
      end if;
      CsrPlugin_mip_MEIP <= externalInterrupt;
      CsrPlugin_mip_MTIP <= timerInterrupt;
      CsrPlugin_mip_MSIP <= softwareInterrupt;
      if zz_when = '1' then
        CsrPlugin_exceptionPortCtrl_exceptionContext_code <= pkg_mux(zz_CsrPlugin_exceptionPortCtrl_exceptionContext_code_1,IBusCachedPlugin_decodeExceptionPort_payload_code,decodeExceptionPort_payload_code);
        CsrPlugin_exceptionPortCtrl_exceptionContext_badAddr <= pkg_mux(zz_CsrPlugin_exceptionPortCtrl_exceptionContext_code_1,IBusCachedPlugin_decodeExceptionPort_payload_badAddr,decodeExceptionPort_payload_badAddr);
      end if;
      if BranchPlugin_branchExceptionPort_valid = '1' then
        CsrPlugin_exceptionPortCtrl_exceptionContext_code <= BranchPlugin_branchExceptionPort_payload_code;
        CsrPlugin_exceptionPortCtrl_exceptionContext_badAddr <= BranchPlugin_branchExceptionPort_payload_badAddr;
      end if;
      if DBusCachedPlugin_exceptionBus_valid = '1' then
        CsrPlugin_exceptionPortCtrl_exceptionContext_code <= DBusCachedPlugin_exceptionBus_payload_code;
        CsrPlugin_exceptionPortCtrl_exceptionContext_badAddr <= DBusCachedPlugin_exceptionBus_payload_badAddr;
      end if;
      if when_CsrPlugin_l1296 = '1' then
        if when_CsrPlugin_l1302 = '1' then
          CsrPlugin_interrupt_code <= pkg_unsigned("0111");
          CsrPlugin_interrupt_targetPrivilege <= pkg_unsigned("11");
        end if;
        if when_CsrPlugin_l1302_1 = '1' then
          CsrPlugin_interrupt_code <= pkg_unsigned("0011");
          CsrPlugin_interrupt_targetPrivilege <= pkg_unsigned("11");
        end if;
        if when_CsrPlugin_l1302_2 = '1' then
          CsrPlugin_interrupt_code <= pkg_unsigned("1011");
          CsrPlugin_interrupt_targetPrivilege <= pkg_unsigned("11");
        end if;
      end if;
      if when_CsrPlugin_l1390 = '1' then
        if when_CsrPlugin_l1398 = '1' then
          case CsrPlugin_targetPrivilege is
            when "11" =>
              CsrPlugin_mcause_interrupt <= (not CsrPlugin_hadException);
              CsrPlugin_mcause_exceptionCode <= CsrPlugin_trapCause;
              CsrPlugin_mepc <= writeBack_PC;
              if CsrPlugin_hadException = '1' then
                CsrPlugin_mtval <= CsrPlugin_exceptionPortCtrl_exceptionContext_badAddr;
              end if;
            when others =>
          end case;
        end if;
      end if;
      HazardSimplePlugin_writeBackBuffer_payload_address <= HazardSimplePlugin_writeBackWrites_payload_address;
      HazardSimplePlugin_writeBackBuffer_payload_data <= HazardSimplePlugin_writeBackWrites_payload_data;
      if when_MulDivIterativePlugin_l126 = '1' then
        memory_DivPlugin_div_done <= pkg_toStdLogic(true);
      end if;
      if when_MulDivIterativePlugin_l126_1 = '1' then
        memory_DivPlugin_div_done <= pkg_toStdLogic(false);
      end if;
      if when_MulDivIterativePlugin_l128 = '1' then
        if when_MulDivIterativePlugin_l132 = '1' then
          memory_DivPlugin_rs1(31 downto 0) <= memory_DivPlugin_div_stage_0_outNumerator;
          memory_DivPlugin_accumulator(31 downto 0) <= memory_DivPlugin_div_stage_0_outRemainder;
          if when_MulDivIterativePlugin_l151 = '1' then
            memory_DivPlugin_div_result <= pkg_resize(std_logic_vector(signed((unsigned(pkg_cat(pkg_toStdLogicVector(memory_DivPlugin_div_needRevert),std_logic_vector(pkg_mux(memory_DivPlugin_div_needRevert,pkg_not(zz_memory_DivPlugin_div_result),zz_memory_DivPlugin_div_result)))) + pkg_resize(unsigned(pkg_toStdLogicVector(memory_DivPlugin_div_needRevert)),33)))),32);
          end if;
        end if;
      end if;
      if when_MulDivIterativePlugin_l162 = '1' then
        memory_DivPlugin_accumulator <= pkg_unsigned("00000000000000000000000000000000000000000000000000000000000000000");
        memory_DivPlugin_rs1 <= (unsigned(pkg_mux(zz_memory_DivPlugin_rs1,pkg_not(zz_memory_DivPlugin_rs1_1),zz_memory_DivPlugin_rs1_1)) + pkg_resize(unsigned(pkg_toStdLogicVector(zz_memory_DivPlugin_rs1)),33));
        memory_DivPlugin_rs2 <= (unsigned(pkg_mux(zz_memory_DivPlugin_rs2,pkg_not(execute_RS2),execute_RS2)) + pkg_resize(unsigned(pkg_toStdLogicVector(zz_memory_DivPlugin_rs2)),32));
        memory_DivPlugin_div_needRevert <= ((zz_memory_DivPlugin_rs1 xor (zz_memory_DivPlugin_rs2 and (not pkg_extract(execute_INSTRUCTION,13)))) and (not ((pkg_toStdLogic(execute_RS2 = pkg_stdLogicVector("00000000000000000000000000000000")) and execute_IS_RS2_SIGNED) and (not pkg_extract(execute_INSTRUCTION,13)))));
      end if;
      if when_Pipeline_l124 = '1' then
        decode_to_execute_PC <= decode_PC;
      end if;
      if when_Pipeline_l124_1 = '1' then
        execute_to_memory_PC <= zz_execute_to_memory_PC;
      end if;
      if when_Pipeline_l124_2 = '1' then
        memory_to_writeBack_PC <= memory_PC;
      end if;
      if when_Pipeline_l124_3 = '1' then
        decode_to_execute_INSTRUCTION <= decode_INSTRUCTION;
      end if;
      if when_Pipeline_l124_4 = '1' then
        execute_to_memory_INSTRUCTION <= execute_INSTRUCTION;
      end if;
      if when_Pipeline_l124_5 = '1' then
        memory_to_writeBack_INSTRUCTION <= memory_INSTRUCTION;
      end if;
      if when_Pipeline_l124_6 = '1' then
        decode_to_execute_FORMAL_PC_NEXT <= zz_decode_to_execute_FORMAL_PC_NEXT;
      end if;
      if when_Pipeline_l124_7 = '1' then
        execute_to_memory_FORMAL_PC_NEXT <= zz_execute_to_memory_FORMAL_PC_NEXT;
      end if;
      if when_Pipeline_l124_8 = '1' then
        memory_to_writeBack_FORMAL_PC_NEXT <= memory_FORMAL_PC_NEXT;
      end if;
      if when_Pipeline_l124_9 = '1' then
        decode_to_execute_MEMORY_FORCE_CONSTISTENCY <= decode_MEMORY_FORCE_CONSTISTENCY;
      end if;
      if when_Pipeline_l124_10 = '1' then
        decode_to_execute_CSR_WRITE_OPCODE <= decode_CSR_WRITE_OPCODE;
      end if;
      if when_Pipeline_l124_11 = '1' then
        decode_to_execute_CSR_READ_OPCODE <= decode_CSR_READ_OPCODE;
      end if;
      if when_Pipeline_l124_12 = '1' then
        decode_to_execute_SRC1_CTRL <= zz_decode_to_execute_SRC1_CTRL;
      end if;
      if when_Pipeline_l124_13 = '1' then
        decode_to_execute_SRC_USE_SUB_LESS <= decode_SRC_USE_SUB_LESS;
      end if;
      if when_Pipeline_l124_14 = '1' then
        decode_to_execute_MEMORY_ENABLE <= decode_MEMORY_ENABLE;
      end if;
      if when_Pipeline_l124_15 = '1' then
        execute_to_memory_MEMORY_ENABLE <= execute_MEMORY_ENABLE;
      end if;
      if when_Pipeline_l124_16 = '1' then
        memory_to_writeBack_MEMORY_ENABLE <= memory_MEMORY_ENABLE;
      end if;
      if when_Pipeline_l124_17 = '1' then
        decode_to_execute_ALU_CTRL <= zz_decode_to_execute_ALU_CTRL;
      end if;
      if when_Pipeline_l124_18 = '1' then
        decode_to_execute_SRC2_CTRL <= zz_decode_to_execute_SRC2_CTRL;
      end if;
      if when_Pipeline_l124_19 = '1' then
        decode_to_execute_REGFILE_WRITE_VALID <= decode_REGFILE_WRITE_VALID;
      end if;
      if when_Pipeline_l124_20 = '1' then
        execute_to_memory_REGFILE_WRITE_VALID <= execute_REGFILE_WRITE_VALID;
      end if;
      if when_Pipeline_l124_21 = '1' then
        memory_to_writeBack_REGFILE_WRITE_VALID <= memory_REGFILE_WRITE_VALID;
      end if;
      if when_Pipeline_l124_22 = '1' then
        decode_to_execute_BYPASSABLE_EXECUTE_STAGE <= decode_BYPASSABLE_EXECUTE_STAGE;
      end if;
      if when_Pipeline_l124_23 = '1' then
        decode_to_execute_BYPASSABLE_MEMORY_STAGE <= decode_BYPASSABLE_MEMORY_STAGE;
      end if;
      if when_Pipeline_l124_24 = '1' then
        execute_to_memory_BYPASSABLE_MEMORY_STAGE <= execute_BYPASSABLE_MEMORY_STAGE;
      end if;
      if when_Pipeline_l124_25 = '1' then
        decode_to_execute_MEMORY_WR <= decode_MEMORY_WR;
      end if;
      if when_Pipeline_l124_26 = '1' then
        execute_to_memory_MEMORY_WR <= execute_MEMORY_WR;
      end if;
      if when_Pipeline_l124_27 = '1' then
        memory_to_writeBack_MEMORY_WR <= memory_MEMORY_WR;
      end if;
      if when_Pipeline_l124_28 = '1' then
        decode_to_execute_MEMORY_MANAGMENT <= decode_MEMORY_MANAGMENT;
      end if;
      if when_Pipeline_l124_29 = '1' then
        decode_to_execute_IS_CSR <= decode_IS_CSR;
      end if;
      if when_Pipeline_l124_30 = '1' then
        decode_to_execute_ENV_CTRL <= zz_decode_to_execute_ENV_CTRL;
      end if;
      if when_Pipeline_l124_31 = '1' then
        execute_to_memory_ENV_CTRL <= zz_execute_to_memory_ENV_CTRL;
      end if;
      if when_Pipeline_l124_32 = '1' then
        memory_to_writeBack_ENV_CTRL <= zz_memory_to_writeBack_ENV_CTRL;
      end if;
      if when_Pipeline_l124_33 = '1' then
        decode_to_execute_SRC_LESS_UNSIGNED <= decode_SRC_LESS_UNSIGNED;
      end if;
      if when_Pipeline_l124_34 = '1' then
        decode_to_execute_ALU_BITWISE_CTRL <= zz_decode_to_execute_ALU_BITWISE_CTRL;
      end if;
      if when_Pipeline_l124_35 = '1' then
        decode_to_execute_SHIFT_CTRL <= zz_decode_to_execute_SHIFT_CTRL;
      end if;
      if when_Pipeline_l124_36 = '1' then
        execute_to_memory_SHIFT_CTRL <= zz_execute_to_memory_SHIFT_CTRL;
      end if;
      if when_Pipeline_l124_37 = '1' then
        decode_to_execute_IS_MUL <= decode_IS_MUL;
      end if;
      if when_Pipeline_l124_38 = '1' then
        execute_to_memory_IS_MUL <= execute_IS_MUL;
      end if;
      if when_Pipeline_l124_39 = '1' then
        memory_to_writeBack_IS_MUL <= memory_IS_MUL;
      end if;
      if when_Pipeline_l124_40 = '1' then
        decode_to_execute_IS_DIV <= decode_IS_DIV;
      end if;
      if when_Pipeline_l124_41 = '1' then
        execute_to_memory_IS_DIV <= execute_IS_DIV;
      end if;
      if when_Pipeline_l124_42 = '1' then
        decode_to_execute_IS_RS1_SIGNED <= decode_IS_RS1_SIGNED;
      end if;
      if when_Pipeline_l124_43 = '1' then
        decode_to_execute_IS_RS2_SIGNED <= decode_IS_RS2_SIGNED;
      end if;
      if when_Pipeline_l124_44 = '1' then
        decode_to_execute_BRANCH_CTRL <= zz_decode_to_execute_BRANCH_CTRL;
      end if;
      if when_Pipeline_l124_45 = '1' then
        decode_to_execute_RS1 <= decode_RS1;
      end if;
      if when_Pipeline_l124_46 = '1' then
        decode_to_execute_RS2 <= decode_RS2;
      end if;
      if when_Pipeline_l124_47 = '1' then
        decode_to_execute_SRC2_FORCE_ZERO <= decode_SRC2_FORCE_ZERO;
      end if;
      if when_Pipeline_l124_48 = '1' then
        decode_to_execute_PREDICTION_HAD_BRANCHED2 <= decode_PREDICTION_HAD_BRANCHED2;
      end if;
      if when_Pipeline_l124_49 = '1' then
        execute_to_memory_MEMORY_STORE_DATA_RF <= execute_MEMORY_STORE_DATA_RF;
      end if;
      if when_Pipeline_l124_50 = '1' then
        memory_to_writeBack_MEMORY_STORE_DATA_RF <= memory_MEMORY_STORE_DATA_RF;
      end if;
      if when_Pipeline_l124_51 = '1' then
        execute_to_memory_REGFILE_WRITE_DATA <= zz_decode_RS2_1;
      end if;
      if when_Pipeline_l124_52 = '1' then
        memory_to_writeBack_REGFILE_WRITE_DATA <= zz_decode_RS2;
      end if;
      if when_Pipeline_l124_53 = '1' then
        execute_to_memory_SHIFT_RIGHT <= execute_SHIFT_RIGHT;
      end if;
      if when_Pipeline_l124_54 = '1' then
        execute_to_memory_MUL_LL <= execute_MUL_LL;
      end if;
      if when_Pipeline_l124_55 = '1' then
        execute_to_memory_MUL_LH <= execute_MUL_LH;
      end if;
      if when_Pipeline_l124_56 = '1' then
        execute_to_memory_MUL_HL <= execute_MUL_HL;
      end if;
      if when_Pipeline_l124_57 = '1' then
        execute_to_memory_MUL_HH <= execute_MUL_HH;
      end if;
      if when_Pipeline_l124_58 = '1' then
        memory_to_writeBack_MUL_HH <= memory_MUL_HH;
      end if;
      if when_Pipeline_l124_59 = '1' then
        memory_to_writeBack_MUL_LOW <= memory_MUL_LOW;
      end if;
      if when_CsrPlugin_l1669 = '1' then
        execute_CsrPlugin_csr_768 <= pkg_toStdLogic(pkg_extract(decode_INSTRUCTION,31,20) = pkg_stdLogicVector("001100000000"));
      end if;
      if when_CsrPlugin_l1669_1 = '1' then
        execute_CsrPlugin_csr_836 <= pkg_toStdLogic(pkg_extract(decode_INSTRUCTION,31,20) = pkg_stdLogicVector("001101000100"));
      end if;
      if when_CsrPlugin_l1669_2 = '1' then
        execute_CsrPlugin_csr_772 <= pkg_toStdLogic(pkg_extract(decode_INSTRUCTION,31,20) = pkg_stdLogicVector("001100000100"));
      end if;
      if when_CsrPlugin_l1669_3 = '1' then
        execute_CsrPlugin_csr_834 <= pkg_toStdLogic(pkg_extract(decode_INSTRUCTION,31,20) = pkg_stdLogicVector("001101000010"));
      end if;
      if execute_CsrPlugin_csr_836 = '1' then
        if execute_CsrPlugin_writeEnable = '1' then
          CsrPlugin_mip_MSIP <= pkg_extract(CsrPlugin_csrMapping_writeDataSignal,3);
        end if;
      end if;
    end if;
  end process;

end arch;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.pkg_scala2hdl.all;
use work.all;
use work.pkg_enum.all;


entity VexRiscvForSim is
  port(
    io_asyncReset : in std_logic;
    io_mainClk : in std_logic;
    io_iBus_ar_valid : out std_logic;
    io_iBus_ar_ready : in std_logic;
    io_iBus_ar_payload_addr : out unsigned(31 downto 0);
    io_iBus_ar_payload_id : out unsigned(0 downto 0);
    io_iBus_ar_payload_region : out std_logic_vector(3 downto 0);
    io_iBus_ar_payload_len : out unsigned(7 downto 0);
    io_iBus_ar_payload_size : out unsigned(2 downto 0);
    io_iBus_ar_payload_burst : out std_logic_vector(1 downto 0);
    io_iBus_ar_payload_lock : out std_logic_vector(0 downto 0);
    io_iBus_ar_payload_cache : out std_logic_vector(3 downto 0);
    io_iBus_ar_payload_qos : out std_logic_vector(3 downto 0);
    io_iBus_ar_payload_prot : out std_logic_vector(2 downto 0);
    io_iBus_r_valid : in std_logic;
    io_iBus_r_ready : out std_logic;
    io_iBus_r_payload_data : in std_logic_vector(31 downto 0);
    io_iBus_r_payload_id : in unsigned(0 downto 0);
    io_iBus_r_payload_resp : in std_logic_vector(1 downto 0);
    io_iBus_r_payload_last : in std_logic;
    io_dBus_aw_valid : out std_logic;
    io_dBus_aw_ready : in std_logic;
    io_dBus_aw_payload_addr : out unsigned(31 downto 0);
    io_dBus_aw_payload_id : out unsigned(0 downto 0);
    io_dBus_aw_payload_region : out std_logic_vector(3 downto 0);
    io_dBus_aw_payload_len : out unsigned(7 downto 0);
    io_dBus_aw_payload_size : out unsigned(2 downto 0);
    io_dBus_aw_payload_burst : out std_logic_vector(1 downto 0);
    io_dBus_aw_payload_lock : out std_logic_vector(0 downto 0);
    io_dBus_aw_payload_cache : out std_logic_vector(3 downto 0);
    io_dBus_aw_payload_qos : out std_logic_vector(3 downto 0);
    io_dBus_aw_payload_prot : out std_logic_vector(2 downto 0);
    io_dBus_w_valid : out std_logic;
    io_dBus_w_ready : in std_logic;
    io_dBus_w_payload_data : out std_logic_vector(31 downto 0);
    io_dBus_w_payload_strb : out std_logic_vector(3 downto 0);
    io_dBus_w_payload_last : out std_logic;
    io_dBus_b_valid : in std_logic;
    io_dBus_b_ready : out std_logic;
    io_dBus_b_payload_id : in unsigned(0 downto 0);
    io_dBus_b_payload_resp : in std_logic_vector(1 downto 0);
    io_dBus_ar_valid : out std_logic;
    io_dBus_ar_ready : in std_logic;
    io_dBus_ar_payload_addr : out unsigned(31 downto 0);
    io_dBus_ar_payload_id : out unsigned(0 downto 0);
    io_dBus_ar_payload_region : out std_logic_vector(3 downto 0);
    io_dBus_ar_payload_len : out unsigned(7 downto 0);
    io_dBus_ar_payload_size : out unsigned(2 downto 0);
    io_dBus_ar_payload_burst : out std_logic_vector(1 downto 0);
    io_dBus_ar_payload_lock : out std_logic_vector(0 downto 0);
    io_dBus_ar_payload_cache : out std_logic_vector(3 downto 0);
    io_dBus_ar_payload_qos : out std_logic_vector(3 downto 0);
    io_dBus_ar_payload_prot : out std_logic_vector(2 downto 0);
    io_dBus_r_valid : in std_logic;
    io_dBus_r_ready : out std_logic;
    io_dBus_r_payload_data : in std_logic_vector(31 downto 0);
    io_dBus_r_payload_id : in unsigned(0 downto 0);
    io_dBus_r_payload_resp : in std_logic_vector(1 downto 0);
    io_dBus_r_payload_last : in std_logic
  );
end VexRiscvForSim;

architecture arch of VexRiscvForSim is
  signal system_cpu_dBus_cmd_ready : std_logic;
  signal system_cpu_dBus_rsp_payload_last : std_logic;
  signal system_cpu_dBus_rsp_payload_error : std_logic;
  signal system_cpu_iBus_rsp_payload_error : std_logic;
  signal io_asyncReset_buffercc_io_dataOut : std_logic;
  signal system_cpu_dBus_cmd_valid : std_logic;
  signal system_cpu_dBus_cmd_payload_wr : std_logic;
  signal system_cpu_dBus_cmd_payload_uncached : std_logic;
  signal system_cpu_dBus_cmd_payload_address : unsigned(31 downto 0);
  signal system_cpu_dBus_cmd_payload_data : std_logic_vector(31 downto 0);
  signal system_cpu_dBus_cmd_payload_mask : std_logic_vector(3 downto 0);
  signal system_cpu_dBus_cmd_payload_size : unsigned(2 downto 0);
  signal system_cpu_dBus_cmd_payload_last : std_logic;
  signal system_cpu_iBus_cmd_valid : std_logic;
  signal system_cpu_iBus_cmd_payload_address : unsigned(31 downto 0);
  signal system_cpu_iBus_cmd_payload_size : unsigned(2 downto 0);

  signal resetCtrl_mainClkResetUnbuffered : std_logic;
  signal resetCtrl_systemClkResetCounter : unsigned(5 downto 0) := pkg_unsigned("000000");
  signal zz_when_VexRiscvForSim_l134 : unsigned(5 downto 0);
  signal when_VexRiscvForSim_l134 : std_logic;
  signal when_VexRiscvForSim_l138 : std_logic;
  signal resetCtrl_mainClkReset : std_logic;
  signal resetCtrl_systemReset : std_logic;
  signal system_timerInterrupt : std_logic;
  signal system_externalInterrupt : std_logic;
  signal zz_io_iBus_ar_payload_id : unsigned(0 downto 0);
  signal zz_io_iBus_ar_payload_region : std_logic_vector(3 downto 0);
  signal dbus_axi_arw_valid : std_logic;
  signal dbus_axi_arw_ready : std_logic;
  signal dbus_axi_arw_payload_addr : unsigned(31 downto 0);
  signal dbus_axi_arw_payload_len : unsigned(7 downto 0);
  signal dbus_axi_arw_payload_size : unsigned(2 downto 0);
  signal dbus_axi_arw_payload_cache : std_logic_vector(3 downto 0);
  signal dbus_axi_arw_payload_prot : std_logic_vector(2 downto 0);
  signal dbus_axi_arw_payload_write : std_logic;
  signal dbus_axi_w_valid : std_logic;
  signal dbus_axi_w_ready : std_logic;
  signal dbus_axi_w_payload_data : std_logic_vector(31 downto 0);
  signal dbus_axi_w_payload_strb : std_logic_vector(3 downto 0);
  signal dbus_axi_w_payload_last : std_logic;
  signal dbus_axi_b_valid : std_logic;
  signal dbus_axi_b_ready : std_logic;
  signal dbus_axi_b_payload_resp : std_logic_vector(1 downto 0);
  signal dbus_axi_r_valid : std_logic;
  signal dbus_axi_r_ready : std_logic;
  signal dbus_axi_r_payload_data : std_logic_vector(31 downto 0);
  signal dbus_axi_r_payload_resp : std_logic_vector(1 downto 0);
  signal dbus_axi_r_payload_last : std_logic;
  signal toplevel_system_cpu_dBus_cmd_fire : std_logic;
  signal when_Utils_l659 : std_logic;
  signal dbus_axi_b_fire : std_logic;
  signal zz_when_Utils_l687 : std_logic;
  signal zz_when_Utils_l687_1 : std_logic;
  signal zz_dBus_cmd_ready : unsigned(4 downto 0);
  signal zz_dBus_cmd_ready_1 : unsigned(4 downto 0);
  signal when_Utils_l687 : std_logic;
  signal when_Utils_l689 : std_logic;
  signal zz_dBus_cmd_ready_2 : std_logic;
  signal zz_dbus_axi_arw_valid : std_logic;
  signal zz_dBus_cmd_ready_3 : std_logic;
  signal zz_dbus_axi_arw_payload_write : std_logic;
  signal zz_dbus_axi_w_payload_last : std_logic;
  signal zz_dbus_axi_arw_valid_1 : std_logic;
  signal zz_when_Stream_l998 : std_logic;
  signal zz_dbus_axi_w_valid : std_logic;
  signal zz_when_Stream_l998_1 : std_logic;
  signal zz_when_Stream_l998_2 : std_logic;
  signal zz_when_Stream_l998_3 : std_logic;
  signal when_Stream_l998 : std_logic;
  signal when_Stream_l998_1 : std_logic;
  signal zz_1 : std_logic;
  signal zz_2 : std_logic;
  signal zz_dbus_axi_arw_valid_2 : std_logic;
  signal when_Stream_l439 : std_logic;
  signal zz_dbus_axi_w_valid_1 : std_logic;
  signal zz_io_dBus_ar_payload_id : unsigned(0 downto 0);
  signal zz_io_dBus_ar_payload_region : std_logic_vector(3 downto 0);
  signal zz_io_dBus_aw_payload_id : unsigned(0 downto 0);
  signal zz_io_dBus_aw_payload_region : std_logic_vector(3 downto 0);
begin
  io_asyncReset_buffercc : entity work.BufferCC
    port map ( 
      io_dataIn => io_asyncReset,
      io_dataOut => io_asyncReset_buffercc_io_dataOut,
      io_mainClk => io_mainClk 
    );
  system_cpu : entity work.VexRiscv
    port map ( 
      dBus_cmd_valid => system_cpu_dBus_cmd_valid,
      dBus_cmd_ready => system_cpu_dBus_cmd_ready,
      dBus_cmd_payload_wr => system_cpu_dBus_cmd_payload_wr,
      dBus_cmd_payload_uncached => system_cpu_dBus_cmd_payload_uncached,
      dBus_cmd_payload_address => system_cpu_dBus_cmd_payload_address,
      dBus_cmd_payload_data => system_cpu_dBus_cmd_payload_data,
      dBus_cmd_payload_mask => system_cpu_dBus_cmd_payload_mask,
      dBus_cmd_payload_size => system_cpu_dBus_cmd_payload_size,
      dBus_cmd_payload_last => system_cpu_dBus_cmd_payload_last,
      dBus_rsp_valid => dbus_axi_r_valid,
      dBus_rsp_payload_last => system_cpu_dBus_rsp_payload_last,
      dBus_rsp_payload_data => dbus_axi_r_payload_data,
      dBus_rsp_payload_error => system_cpu_dBus_rsp_payload_error,
      timerInterrupt => system_timerInterrupt,
      externalInterrupt => system_externalInterrupt,
      softwareInterrupt => pkg_toStdLogic(false),
      iBus_cmd_valid => system_cpu_iBus_cmd_valid,
      iBus_cmd_ready => io_iBus_ar_ready,
      iBus_cmd_payload_address => system_cpu_iBus_cmd_payload_address,
      iBus_cmd_payload_size => system_cpu_iBus_cmd_payload_size,
      iBus_rsp_valid => io_iBus_r_valid,
      iBus_rsp_payload_data => io_iBus_r_payload_data,
      iBus_rsp_payload_error => system_cpu_iBus_rsp_payload_error,
      io_mainClk => io_mainClk,
      resetCtrl_systemReset => resetCtrl_systemReset 
    );
  process(when_VexRiscvForSim_l134)
  begin
    resetCtrl_mainClkResetUnbuffered <= pkg_toStdLogic(false);
    if when_VexRiscvForSim_l134 = '1' then
      resetCtrl_mainClkResetUnbuffered <= pkg_toStdLogic(true);
    end if;
  end process;

  zz_when_VexRiscvForSim_l134(5 downto 0) <= pkg_unsigned("111111");
  when_VexRiscvForSim_l134 <= pkg_toStdLogic(resetCtrl_systemClkResetCounter /= zz_when_VexRiscvForSim_l134);
  when_VexRiscvForSim_l138 <= io_asyncReset_buffercc_io_dataOut;
  system_timerInterrupt <= pkg_toStdLogic(false);
  system_externalInterrupt <= pkg_toStdLogic(false);
  system_cpu_iBus_rsp_payload_error <= (not pkg_toStdLogic(io_iBus_r_payload_resp = pkg_stdLogicVector("00")));
  zz_io_iBus_ar_payload_id(0 downto 0) <= pkg_unsigned("0");
  zz_io_iBus_ar_payload_region(3 downto 0) <= pkg_stdLogicVector("0000");
  toplevel_system_cpu_dBus_cmd_fire <= (system_cpu_dBus_cmd_valid and system_cpu_dBus_cmd_ready);
  when_Utils_l659 <= (toplevel_system_cpu_dBus_cmd_fire and system_cpu_dBus_cmd_payload_wr);
  dbus_axi_b_fire <= (dbus_axi_b_valid and dbus_axi_b_ready);
  process(when_Utils_l659)
  begin
    zz_when_Utils_l687 <= pkg_toStdLogic(false);
    if when_Utils_l659 = '1' then
      zz_when_Utils_l687 <= pkg_toStdLogic(true);
    end if;
  end process;

  process(dbus_axi_b_fire)
  begin
    zz_when_Utils_l687_1 <= pkg_toStdLogic(false);
    if dbus_axi_b_fire = '1' then
      zz_when_Utils_l687_1 <= pkg_toStdLogic(true);
    end if;
  end process;

  when_Utils_l687 <= (zz_when_Utils_l687 and (not zz_when_Utils_l687_1));
  process(when_Utils_l687,when_Utils_l689)
  begin
    if when_Utils_l687 = '1' then
      zz_dBus_cmd_ready_1 <= pkg_unsigned("00001");
    else
      if when_Utils_l689 = '1' then
        zz_dBus_cmd_ready_1 <= pkg_unsigned("11111");
      else
        zz_dBus_cmd_ready_1 <= pkg_unsigned("00000");
      end if;
    end if;
  end process;

  when_Utils_l689 <= ((not zz_when_Utils_l687) and zz_when_Utils_l687_1);
  zz_dBus_cmd_ready_2 <= (not ((pkg_toStdLogic(zz_dBus_cmd_ready /= pkg_unsigned("00000")) and (not system_cpu_dBus_cmd_payload_wr)) or pkg_toStdLogic(zz_dBus_cmd_ready = pkg_unsigned("11111"))));
  zz_dbus_axi_arw_valid <= (system_cpu_dBus_cmd_valid and zz_dBus_cmd_ready_2);
  system_cpu_dBus_cmd_ready <= (zz_dBus_cmd_ready_3 and zz_dBus_cmd_ready_2);
  zz_dbus_axi_arw_payload_write <= system_cpu_dBus_cmd_payload_wr;
  zz_dbus_axi_w_payload_last <= system_cpu_dBus_cmd_payload_last;
  process(when_Stream_l998,when_Stream_l998_1)
  begin
    zz_dBus_cmd_ready_3 <= pkg_toStdLogic(true);
    if when_Stream_l998 = '1' then
      zz_dBus_cmd_ready_3 <= pkg_toStdLogic(false);
    end if;
    if when_Stream_l998_1 = '1' then
      zz_dBus_cmd_ready_3 <= pkg_toStdLogic(false);
    end if;
  end process;

  when_Stream_l998 <= ((not zz_when_Stream_l998) and zz_when_Stream_l998_2);
  when_Stream_l998_1 <= ((not zz_when_Stream_l998_1) and zz_when_Stream_l998_3);
  zz_dbus_axi_arw_valid_1 <= (zz_dbus_axi_arw_valid and zz_when_Stream_l998_2);
  zz_1 <= (zz_dbus_axi_arw_valid_1 and zz_when_Stream_l998);
  zz_dbus_axi_w_valid <= (zz_dbus_axi_arw_valid and zz_when_Stream_l998_3);
  process(zz_dbus_axi_arw_valid_1,zz_2)
  begin
    zz_dbus_axi_arw_valid_2 <= zz_dbus_axi_arw_valid_1;
    if zz_2 = '1' then
      zz_dbus_axi_arw_valid_2 <= pkg_toStdLogic(false);
    end if;
  end process;

  process(dbus_axi_arw_ready,zz_2)
  begin
    zz_when_Stream_l998 <= dbus_axi_arw_ready;
    if zz_2 = '1' then
      zz_when_Stream_l998 <= pkg_toStdLogic(true);
    end if;
  end process;

  when_Stream_l439 <= (not zz_dbus_axi_arw_payload_write);
  process(zz_dbus_axi_w_valid,when_Stream_l439)
  begin
    zz_dbus_axi_w_valid_1 <= zz_dbus_axi_w_valid;
    if when_Stream_l439 = '1' then
      zz_dbus_axi_w_valid_1 <= pkg_toStdLogic(false);
    end if;
  end process;

  process(dbus_axi_w_ready,when_Stream_l439)
  begin
    zz_when_Stream_l998_1 <= dbus_axi_w_ready;
    if when_Stream_l439 = '1' then
      zz_when_Stream_l998_1 <= pkg_toStdLogic(true);
    end if;
  end process;

  dbus_axi_arw_valid <= zz_dbus_axi_arw_valid_2;
  dbus_axi_arw_payload_write <= zz_dbus_axi_arw_payload_write;
  dbus_axi_arw_payload_prot <= pkg_stdLogicVector("010");
  dbus_axi_arw_payload_cache <= pkg_stdLogicVector("1111");
  dbus_axi_arw_payload_size <= pkg_unsigned("010");
  dbus_axi_arw_payload_addr <= system_cpu_dBus_cmd_payload_address;
  dbus_axi_arw_payload_len <= pkg_resize(pkg_mux(pkg_toStdLogic(system_cpu_dBus_cmd_payload_size = pkg_unsigned("101")),pkg_unsigned("111"),pkg_unsigned("000")),8);
  dbus_axi_w_valid <= zz_dbus_axi_w_valid_1;
  dbus_axi_w_payload_data <= system_cpu_dBus_cmd_payload_data;
  dbus_axi_w_payload_strb <= system_cpu_dBus_cmd_payload_mask;
  dbus_axi_w_payload_last <= zz_dbus_axi_w_payload_last;
  system_cpu_dBus_rsp_payload_error <= (not pkg_toStdLogic(dbus_axi_r_payload_resp = pkg_stdLogicVector("00")));
  dbus_axi_r_ready <= pkg_toStdLogic(true);
  dbus_axi_b_ready <= pkg_toStdLogic(true);
  dbus_axi_arw_ready <= pkg_mux(dbus_axi_arw_payload_write,io_dBus_aw_ready,io_dBus_ar_ready);
  dbus_axi_w_ready <= io_dBus_w_ready;
  dbus_axi_r_valid <= io_dBus_r_valid;
  dbus_axi_r_payload_data <= io_dBus_r_payload_data;
  dbus_axi_r_payload_resp <= io_dBus_r_payload_resp;
  dbus_axi_r_payload_last <= io_dBus_r_payload_last;
  dbus_axi_b_valid <= io_dBus_b_valid;
  dbus_axi_b_payload_resp <= io_dBus_b_payload_resp;
  zz_io_dBus_ar_payload_id(0 downto 0) <= pkg_unsigned("0");
  zz_io_dBus_ar_payload_region(3 downto 0) <= pkg_stdLogicVector("0000");
  zz_io_dBus_aw_payload_id(0 downto 0) <= pkg_unsigned("0");
  zz_io_dBus_aw_payload_region(3 downto 0) <= pkg_stdLogicVector("0000");
  io_iBus_ar_valid <= system_cpu_iBus_cmd_valid;
  io_iBus_ar_payload_addr <= system_cpu_iBus_cmd_payload_address;
  io_iBus_ar_payload_id <= zz_io_iBus_ar_payload_id;
  io_iBus_ar_payload_region <= zz_io_iBus_ar_payload_region;
  io_iBus_ar_payload_len <= pkg_unsigned("00000111");
  io_iBus_ar_payload_size <= pkg_unsigned("010");
  io_iBus_ar_payload_burst <= pkg_stdLogicVector("01");
  io_iBus_ar_payload_lock <= pkg_stdLogicVector("0");
  io_iBus_ar_payload_cache <= pkg_stdLogicVector("1111");
  io_iBus_ar_payload_qos <= pkg_stdLogicVector("0000");
  io_iBus_ar_payload_prot <= pkg_stdLogicVector("110");
  io_iBus_r_ready <= pkg_toStdLogic(true);
  io_dBus_aw_valid <= (dbus_axi_arw_valid and dbus_axi_arw_payload_write);
  io_dBus_aw_payload_addr <= dbus_axi_arw_payload_addr;
  io_dBus_aw_payload_id <= zz_io_dBus_aw_payload_id;
  io_dBus_aw_payload_region <= zz_io_dBus_aw_payload_region;
  io_dBus_aw_payload_len <= dbus_axi_arw_payload_len;
  io_dBus_aw_payload_size <= dbus_axi_arw_payload_size;
  io_dBus_aw_payload_burst <= pkg_stdLogicVector("01");
  io_dBus_aw_payload_lock <= pkg_stdLogicVector("0");
  io_dBus_aw_payload_cache <= dbus_axi_arw_payload_cache;
  io_dBus_aw_payload_qos <= pkg_stdLogicVector("0000");
  io_dBus_aw_payload_prot <= dbus_axi_arw_payload_prot;
  io_dBus_w_valid <= dbus_axi_w_valid;
  io_dBus_w_payload_data <= dbus_axi_w_payload_data;
  io_dBus_w_payload_strb <= dbus_axi_w_payload_strb;
  io_dBus_w_payload_last <= dbus_axi_w_payload_last;
  io_dBus_b_ready <= dbus_axi_b_ready;
  io_dBus_ar_valid <= (dbus_axi_arw_valid and (not dbus_axi_arw_payload_write));
  io_dBus_ar_payload_addr <= dbus_axi_arw_payload_addr;
  io_dBus_ar_payload_id <= zz_io_dBus_ar_payload_id;
  io_dBus_ar_payload_region <= zz_io_dBus_ar_payload_region;
  io_dBus_ar_payload_len <= dbus_axi_arw_payload_len;
  io_dBus_ar_payload_size <= dbus_axi_arw_payload_size;
  io_dBus_ar_payload_burst <= pkg_stdLogicVector("01");
  io_dBus_ar_payload_lock <= pkg_stdLogicVector("0");
  io_dBus_ar_payload_cache <= dbus_axi_arw_payload_cache;
  io_dBus_ar_payload_qos <= pkg_stdLogicVector("0000");
  io_dBus_ar_payload_prot <= dbus_axi_arw_payload_prot;
  io_dBus_r_ready <= dbus_axi_r_ready;
  process(io_mainClk)
  begin
    if rising_edge(io_mainClk) then
      if when_VexRiscvForSim_l134 = '1' then
        resetCtrl_systemClkResetCounter <= (resetCtrl_systemClkResetCounter + pkg_unsigned("000001"));
      end if;
      if when_VexRiscvForSim_l138 = '1' then
        resetCtrl_systemClkResetCounter <= pkg_unsigned("000000");
      end if;
    end if;
  end process;

  process(io_mainClk)
  begin
    if rising_edge(io_mainClk) then
      resetCtrl_mainClkReset <= resetCtrl_mainClkResetUnbuffered;
      resetCtrl_systemReset <= resetCtrl_mainClkResetUnbuffered;
    end if;
  end process;

  process(io_mainClk, resetCtrl_systemReset)
  begin
    if resetCtrl_systemReset = '1' then
      zz_dBus_cmd_ready <= pkg_unsigned("00000");
      zz_when_Stream_l998_2 <= pkg_toStdLogic(true);
      zz_when_Stream_l998_3 <= pkg_toStdLogic(true);
      zz_2 <= pkg_toStdLogic(false);
    elsif rising_edge(io_mainClk) then
      zz_dBus_cmd_ready <= (zz_dBus_cmd_ready + zz_dBus_cmd_ready_1);
      if zz_1 = '1' then
        zz_when_Stream_l998_2 <= pkg_toStdLogic(false);
      end if;
      if (zz_dbus_axi_w_valid and zz_when_Stream_l998_1) = '1' then
        zz_when_Stream_l998_3 <= pkg_toStdLogic(false);
      end if;
      if zz_dBus_cmd_ready_3 = '1' then
        zz_when_Stream_l998_2 <= pkg_toStdLogic(true);
        zz_when_Stream_l998_3 <= pkg_toStdLogic(true);
      end if;
      if zz_1 = '1' then
        zz_2 <= (not zz_dbus_axi_w_payload_last);
      end if;
    end if;
  end process;

end arch;

