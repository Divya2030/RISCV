#-----------------------------------------------------------------------------
#
# Test all f{add|sub|mul|div|sqrt|sgnj}.s instructions with different rounding modes and flag status checks, including corner cases.
#

#include "riscv_test.h"
#include "test_macros.h"

RVTEST_RV32UF
RVTEST_CODE_BEGIN

  #-------------------------------------------------------------
  # Helper function to set rounding mode
  #-------------------------------------------------------------

  .macro set_rounding_mode, rounding_mode
    li t0, \rounding_mode
    csrw fcsr, t0
  .endm

  #-------------------------------------------------------------
  # Helper function to check flag status
  #-------------------------------------------------------------

  .macro check_flag_status, flag_expected
    csrr t0, fcsr
    andi t0, t0, \flag_expected
    bnez t0, 1f
    j fail
  1:
  .endm

  #-------------------------------------------------------------
  # RV32F Arithmetic tests with different rounding modes and flag status checks, including corner cases
  #-------------------------------------------------------------

  set_rounding_mode(0)    # Set rounding mode to round to nearest (default)

  TEST_FP_OP1_S( 0,  fsqrt.s, 0, 4.0, 2.0 );
  check_flag_status(0)    # Check flag status: No exception occurred
  TEST_FP_OP1_S( 1,  fsqrt.s, 1, 2.0, 1.41421356 );
  check_flag_status(0)    # Check flag status: No exception occurred
  TEST_FP_OP1_S( 2,  fsqrt.s, 0, 0.0, 0.0 );
  check_flag_status(0)    # Check flag status: No exception occurred
  TEST_FP_OP1_S( 3,  fsqrt.s, 1, -1.0, qNaNf );
  check_flag_status(1)    # Check flag status: Invalid Operation (sqrt of a negative number)

  TEST_FP_OP2_S( 4,  fadd.s, 0, 3.5, 2.5, 1.0 );
  check_flag_status(0)    # Check flag status: No exception occurred
  TEST_FP_OP2_S( 5,  fadd.s, 1, -1234, -1235.1, 1.1 );
  check_flag_status(0)    # Check flag status: No exception occurred
  TEST_FP_OP2_S( 6,  fadd.s, 1, 3.14159265, 3.14159265, 0.00000001 );
  check_flag_status(0)    # Check flag status: No exception occurred

  TEST_FP_OP2_S( 7,  fsub.s, 0, 1.5, 2.5, 1.0 );
  check_flag_status(0)    # Check flag status: No exception occurred
  TEST_FP_OP2_S( 8,  fsub.s, 1, -1234, -1235.1, -1.1 );
  check_flag_status(0)    # Check flag status: No exception occurred
  TEST_FP_OP2_S( 9,  fsub.s, 1, 3.14159265, 3.14159265, 0.00000001 );
  check_flag_status(0)    # Check flag status: No exception occurred

  TEST_FP_OP2_S(10,  fmul.s, 0, 2.5, 2.5, 1.0 );
  check_flag_status(0)    # Check flag status: No exception occurred
  TEST_FP_OP2_S(11,  fmul.s, 1, 1358.61, -1235.1, -1.1 );
  check_flag_status(0)    # Check flag status: No exception occurred
  TEST_FP_OP2_S(12,  fmul.s, 1, 3.14159265e-8, 3.14159265, 0.00000001 );
  check_flag_status(0)    # Check flag status: No exception occurred

  TEST_FP_OP2_S(13,  fdiv.s, 0, 3.0, 6.0, 2.0 );
  check_flag_status(0)    # Check flag status: No exception occurred
  TEST_FP_OP2_S(14,  fdiv.s, 1, 1358.61, -1235.1, -0.000000805744520732 );
  check_flag_status(0)    # Check flag status: No exception occurred
  TEST_FP_OP2_S(15,  fdiv.s, 1, 3.14159265e-8, 3.14159265, 1.0 );
  check_flag_status(0)    # Check flag status: No exception occurred

  #-------------------------------------------------------------
  # RV32F Sign and Compare tests with different rounding modes and flag status checks
  #-------------------------------------------------------------

  set_rounding_mode(1)    # Set rounding mode to round towards zero

  TEST_FP_OP1_S(16,  fsgnj.s, 0, 3.5, 3.5 );
  check_flag_status(0)    # Check flag status: No exception occurred
  TEST_FP_OP1_S(17,  fsgnj.s, 1, -1234, 1234 );
  check_flag_status(0)    # Check flag status: No exception occurred
  TEST_FP_OP1_S(18,  fsgnj.s, 0, 3.14159265, 3.14159265 );
  check_flag_status(0)    # Check flag status: No exception occurred

  set_rounding_mode(2)    # Set rounding mode to round towards positive infinity

  TEST_FP_OP1_S(19,  fsgnjn.s, 0, 3.5, -3.5 );
  check_flag_status(0)    # Check flag status: No exception occurred
  TEST_FP_OP1_S(20,  fsgnjn.s, 1, -1234, -1234 );
  check_flag_status(0)    # Check flag status: No exception occurred
  TEST_FP_OP1_S(21,  fsgnjn.s, 0, 3.14159265, -3.14159265 );
  check_flag_status(0)    # Check flag status: No exception occurred

  set_rounding_mode(3)    # Set rounding mode to round towards negative infinity

  TEST_FP_OP1_S(22,  fsgnjx.s, 0, 3.5, -3.5 );
  check_flag_status(0)    # Check flag status: No exception occurred
  TEST_FP_OP1_S(23,  fsgnjx.s, 1, -1234, 1234 );
  check_flag_status(0)    # Check flag status: No exception occurred
  TEST_FP_OP1_S(24,  fsgnjx.s, 0, 3.14159265, -3.14159265 );
  check_flag_status(0)    # Check flag status: No exception occurred

  set_rounding_mode(0)    # Reset rounding mode to round to nearest (default)

  #-------------------------------------------------------------
  # RV32F Corner cases
  #-------------------------------------------------------------

  # Test corner cases involving zero
  TEST_FP_OP2_S(25, fadd.s, 0, 0.0, 0.0, 0.0 );  # 0.0 + 0.0 = 0.0
  TEST_FP_OP2_S(26, fsub.s, 0, 0.0, 0.0, 0.0 );  # 0.0 - 0.0 = 0.0
  TEST_FP_OP2_S(27, fmul.s, 0, 0.0, 0.0, 0.0 );  # 0.0 * 0.0 = 0.0

  # Test corner case involving positive infinity
  TEST_FP_OP2_S(28, fadd.s, 0, Inf, Inf, Inf );   # Inf + Inf = Inf
  TEST_FP_OP2_S(29, fsub.s, 0, Inf, Inf, 0.0 );   # Inf - Inf = 0.0
  TEST_FP_OP2_S(30, fmul.s, 0, Inf, 0.0, 0.0 );   # Inf * 0.0 = 0.0
  TEST_FP_OP2_S(31, fdiv.s, 0, 0.0, Inf, 0.0 );   # 0.0 / Inf = 0.0

  # Test corner case involving NaN
  TEST_FP_OP2_S(32, fadd.s, 0, NaN, 1.0, NaN );   # NaN + 1.0 = NaN
  TEST_FP_OP2_S(33, fsub.s, 0, NaN, 1.0, NaN );   # NaN - 1.0 = NaN
  TEST_FP_OP2_S(34, fmul.s, 0, NaN, 1.0, NaN );   # NaN * 1.0 = NaN
  TEST_FP_OP2_S(35, fdiv.s, 0, NaN, 1.0, NaN );   # NaN / 1.0 = NaN

  # Test denormalized numbers
  TEST_FP_OP2_S(36, fmul.s, 0, 1.0e-38, 2.0e-38, 0.0 );  # Denormal * Denormal = 0.0

  # Test rounding modes with corner cases
  set_rounding_mode(1)    # Set rounding mode to round towards zero
  TEST_FP_OP2_S(37, fadd.s, 0, 1.5, 2.5, 3.0 );     # 1.5 + 2.5 = 3.0
  set_rounding_mode(2)    # Set rounding mode to round towards positive infinity
  TEST_FP_OP2_S(38, fadd.s, 0, 1.5, 2.5, 4.0 );     # 1.5 + 2.5 = 4.0
  set_rounding_mode(3)    # Set rounding mode to round towards negative infinity
  TEST_FP_OP2_S(39, fadd.s, 0, 1.5, 2.5, 3.0 );     # 1.5 + 2.5 = 3.0
  set_rounding_mode(0)    # Reset rounding mode to round to nearest (default)

  # Test positive and negative zero
  TEST_FP_OP1_S(40,  fsgnj.s, 0, 0.0, 0.0 );   # Positive zero
  TEST_FP_OP1_S(41,  fsgnjn.s, 0, 0.0, 0.0 );  # Negative zero
  TEST_FP_OP1_S(42,  fsgnjx.s, 0, 0.0, 0.0 );  # Negative zero

  TEST_PASSFAIL

RVTEST_CODE_END

  .data
RVTEST_DATA_BEGIN

  TEST_DATA

RVTEST_DATA_END
