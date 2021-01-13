/* @(#) pfcustom.c 98/01/26 1.3 */
#undef PF_USER_CUSTOM
#ifndef PF_USER_CUSTOM

/***************************************************************
** Call Custom Functions for pForth
**
** Create a file similar to this and compile it into pForth
** by setting -DPF_USER_CUSTOM="mycustom.c"
**
** Using this, you could, for example, call X11 from Forth.
** See "pf_cglue.c" for more information.
**
** Author: Phil Burk
** Copyright 1994 3DO, Phil Burk, Larry Polansky, David Rosenboom
**
** Permission to use, copy, modify, and/or distribute this
** software for any purpose with or without fee is hereby granted.
**
** THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL
** WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED
** WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL
** THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR
** CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING
** FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF
** CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
** OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
**
***************************************************************/


#include "pf_all.h"
#include <shmem.h>

static void pf_shmem_put(cell_t dest, cell_t source, cell_t nelems, cell_t pe);
static void pf_shmem_get(cell_t dest, cell_t source, cell_t nelems, cell_t pe);
/****************************************************************
** Step 1: Put your own special glue routines here
**     or link them in from another file or library.
****************************************************************/
/* This op switched on TOS to choose which shmem function to call
   The rest will be handled in FORTH code
*/

static void pf_shmem_put(cell_t dest, cell_t source, cell_t nelems, cell_t pe)
{
    /* 2 64 bit addrs + 64 bit len + 32 bit PE = 20 bytes */
    //fprintf(stderr, "SHMEM_PUT: %p %p  0x%08x 0x%08x\n", M_STACK(3), M_STACK(2), M_STACK(1), M_STACK(0));
    shmem_putmem((char*)dest, (char*)source, (size_t)nelems*2, (int)pe);
}

static void pf_shmem_get(cell_t dest, cell_t source, cell_t nelems, cell_t pe)
{
    //fprintf(stderr, "SHMEM_GET: %p %p  0x%08x 0x%08x\n", M_STACK(3), M_STACK(2), M_STACK(1), M_STACK(0));
    shmem_getmem((char*)dest, (char*)source, (size_t)nelems*2, (int)pe);
}

/****************************************************************
** Step 2: Create CustomFunctionTable.
**     Do not change the name of CustomFunctionTable!
**     It is used by the pForth kernel.
****************************************************************/

#ifdef PF_NO_GLOBAL_INIT
/******************
** If your loader does not support global initialization, then you
** must define PF_NO_GLOBAL_INIT and provide a function to fill
** the table. Some embedded system loaders require this!
** Do not change the name of LoadCustomFunctionTable()!
** It is called by the pForth kernel.
*/
#define NUM_CUSTOM_FUNCTIONS  (6)
CFunc0 CustomFunctionTable[NUM_CUSTOM_FUNCTIONS];

Err LoadCustomFunctionTable( void )
{
    return 0;
}

#else
/******************
** If your loader supports global initialization (most do.) then just
** create the table like this.
*/
CFunc0 CustomFunctionTable[] =
{
    (CFunc0) shmem_n_pes,
    (CFunc0) shmem_my_pe,
    (CFunc4) pf_shmem_put,
    (CFunc4) pf_shmem_get,
    (CFunc1) shmem_global_exit,
    (CFunc4) shmem_barrier,
    (CFunc0) shmem_barrier_all,
    (CFunc1) shmem_malloc,
    (CFunc8) shmem_broadcast64,
    (CFunc0) shmem_sync_all,
    (CFunc7) shmem_collect64,
    (CFunc7) shmem_fcollect64,
    (CFunc8) shmem_int_and_to_all,
    (CFunc8) shmem_int_max_to_all,
    (CFunc8) shmem_int_min_to_all,
    (CFunc8) shmem_int_sum_to_all,
    (CFunc8) shmem_int_prod_to_all,
    (CFunc8) shmem_int_or_to_all,
    (CFunc8) shmem_int_xor_to_all,
    (CFunc7) shmem_alltoall64,
};
#endif

/****************************************************************
** Step 3: Add custom functions to the dictionary.
**     Do not change the name of CompileCustomFunctions!
**     It is called by the pForth kernel.
****************************************************************/

#if (!defined(PF_NO_INIT)) && (!defined(PF_NO_SHELL))
Err CompileCustomFunctions( void )
{
    Err err;
    int i = 0;
/* Compile Forth words that call your custom functions.
** Make sure order of functions matches that in LoadCustomFunctionTable().
** Parameters are: Name in UPPER CASE, Function, Index, Mode, NumParams
*/
    err = CreateGlueToC( "PES", i++, C_RETURNS_VALUE, 0 );
    if( err < 0 ) return err;
    err = CreateGlueToC( "PE", i++, C_RETURNS_VALUE, 0 );
    if( err < 0 ) return err;
    err = CreateGlueToC( "PUT", i++, C_RETURNS_VOID, 4 );
    if( err < 0 ) return err;
    err = CreateGlueToC( "GET", i++, C_RETURNS_VOID, 4 );
    if( err < 0 ) return err;
    err = CreateGlueToC( "GLOBAL-EXIT", i++, C_RETURNS_VALUE, 1 );
    if( err < 0 ) return err;
    err = CreateGlueToC( "BARRIER", i++, C_RETURNS_VOID, 4 );
    if( err < 0 ) return err;
    err = CreateGlueToC( "BARRIER-ALL", i++, C_RETURNS_VOID, 0 );
    if( err < 0 ) return err;
    err = CreateGlueToC( "MALLOC", i++, C_RETURNS_VOID, 1 );
    if( err < 0 ) return err;
    err = CreateGlueToC( "BROADCAST", i++, C_RETURNS_VOID, 8 );
    if( err < 0 ) return err;
    err = CreateGlueToC( "SYNC", i++, C_RETURNS_VOID, 0 );
    if( err < 0 ) return err;
    err = CreateGlueToC( "COLLECT", i++, C_RETURNS_VOID, 7 );
    if( err < 0 ) return err;
    err = CreateGlueToC( "FCOLLECT", i++, C_RETURNS_VOID, 7 );
    if( err < 0 ) return err;
    err = CreateGlueToC( "AND-REDUCTION", i++, C_RETURNS_VOID, 8 );
    if( err < 0 ) return err;
    err = CreateGlueToC( "MAX-REDUCTION", i++, C_RETURNS_VOID, 8 );
    if( err < 0 ) return err;
    err = CreateGlueToC( "MIN-REDUCTION", i++, C_RETURNS_VOID, 8 );
    if( err < 0 ) return err;
    err = CreateGlueToC( "SUM-REDUCTION", i++, C_RETURNS_VOID, 8 );
    if( err < 0 ) return err;
    err = CreateGlueToC( "PROD-REDUCTION", i++, C_RETURNS_VOID, 8 );
    if( err < 0 ) return err;
    err = CreateGlueToC( "OR-REDUCTION", i++, C_RETURNS_VOID, 8 );
    if( err < 0 ) return err;
    err = CreateGlueToC( "XOR-REDUCTION", i++, C_RETURNS_VOID, 8 );
    if( err < 0 ) return err;
    err = CreateGlueToC( "ALL-TO-ALL", i++, C_RETURNS_VOID, 7 );
    if( err < 0 ) return err;

    return 0;
}
#else
Err CompileCustomFunctions( void ) { return 0; }
#endif

/****************************************************************
** Step 4: Recompile using compiler option PF_USER_CUSTOM
**         and link with your code.
**         Then rebuild the Forth using "pforth -i system.fth"
**         Test:   10 Ctest0 ( should print message then '11' )
****************************************************************/

#endif  /* PF_USER_CUSTOM */

