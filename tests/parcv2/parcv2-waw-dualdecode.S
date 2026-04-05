//========================================================================
// parcv2-waw-dualdecode.S
//========================================================================

#include "parc-macros.h"

        TEST_PARC_BEGIN

        //--------------------------------------------------------------------
        // WAW hazard across simultaneously decoded instructions
        //--------------------------------------------------------------------
        // The two instructions below are intentionally aligned so they are
        // fetched and decoded together as one pair.
        //
        //   1) lbu   -> older writer to r8
        //   2) addiu -> younger writer to r8
        //
        // Correct in-order behavior requires the younger addiu to determine
        // the final value in r8. If WAW handling is wrong and both are issued
        // together, the older load can clobber r8 after addiu.

        la    $2, tdata_waw

        .align 3
waw_pair:
        lbu   $8, 0($2)
        addiu $8, $0, 0x007f

        TEST_CHECK_EQ( $8, 0x0000007f )

        addiu $9, $8, 1
        TEST_CHECK_EQ( $9, 0x00000080 )

        TEST_PARC_END

        //--------------------------------------------------------------------
        // Test data
        //--------------------------------------------------------------------

        .data
        .align 4

tdata_waw: .word 0x0000005a
