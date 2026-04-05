//========================================================================
// parcv2-nonalu-dualdecode.S
//========================================================================

#include "parc-macros.h"

        TEST_PARC_BEGIN

        //--------------------------------------------------------------------
        // Two non-ALU instructions decoded simultaneously
        //--------------------------------------------------------------------
        // The two stores are aligned so they are decoded from the same fetched
        // pair. Both are non-ALU operations.
        //
        // Correct behavior is to still execute both operations correctly even
        // though they cannot be paired for parallel ALU issue.

        la    $2, tdata_nonalu
        addiu $3, $0, 0x00aa
        addiu $4, $0, 0x0055

        .align 3
nonalu_pair:
        sb    $3, 0($2)
        sb    $4, 1($2)

        lbu   $5, 0($2)
        lbu   $6, 1($2)

        TEST_CHECK_EQ( $5, 0x000000aa )
        TEST_CHECK_EQ( $6, 0x00000055 )

        lhu   $7, 0($2)
        TEST_CHECK_EQ( $7, 0x000055aa )

        TEST_PARC_END

        //--------------------------------------------------------------------
        // Test data
        //--------------------------------------------------------------------

        .data
        .align 4

tdata_nonalu: .word 0x00000000
