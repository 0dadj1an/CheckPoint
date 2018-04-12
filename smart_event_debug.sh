#!/bin/bash
#ivohrbacek@gmail.com


cpsemd_on(){

echo "===debug_start===" >> $RTDIR/log/cpsemd.elg
fw debug cpsemd on TDERROR_ALL_ALL=5
fw debug cpsemd on OPSEC_DEBUG_LEVEL=9

}

cpsead_on(){
echo "===debug_start===" >> $RTDIR/log/cpsead.elg
fw debug cpsead on TDERROR_ALL_ALL=5
fw debug cpsead on OPSEC_DEBUG_LEVEL=9

}


cpsemd_off(){

fw debug cpsemd off TDERROR_ALL_ALL=0
fw debug cpsemd off OPSEC_DEBUG_LEVEL=0
echo "===debug_stop===" >> $RTDIR/log/cpsemd.elg

}

cpsead_off(){
    
fw debug cpsead off TDERROR_ALL_ALL=0
fw debug cpsead off OPSEC_DEBUG_LEVEL=0
echo "===debug_stop===" >> $RTDIR/log/cpsead.elg
}

