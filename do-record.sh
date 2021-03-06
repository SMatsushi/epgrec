#!/bin/sh
echo "CHANNEL : $CHANNEL"
echo "DURATION: $DURATION"
echo "OUTPUT  : $OUTPUT"
echo "TUNER : $TUNER"
echo "TYPE : $TYPE"
echo "MODE : $MODE"
echo "SID  : $SID"

RECORDER=/usr/local/bin/recpt1
PERL=/usr/local/bin/perl
ENCPROG=/home/www/epgrec/tsencode5.pl
# ENCPROG=/home/www/epgrec/tsencode.pl
ENC2PROG=/home/www/epgrec/tsencode2.pl

if [ ${MODE} = 0 ]; then
   # MODE=0では必ず無加工のTSを吐き出すこと
   $RECORDER --b25 --strip --sid epg $CHANNEL $DURATION ${OUTPUT} >/dev/null
elif [ ${MODE} = 1 ]; then
   # 目的のSIDのみ残す
   $RECORDER --b25 --strip --sid $SID $CHANNEL $DURATION ${OUTPUT} >/dev/null
elif [ ${MODE} == 2 ]; then
    OUTPUT_TMP=${OUTPUT}_tmp.ts;
    OUTPUT_LOG=${OUTPUT}.log;
    $RECORDER --b25 --strip $CHANNEL $DURATION ${OUTPUT_TMP} >/dev/null
    # <-解像度は4:3で指定（理由は後述）
    $PERL $ENCPROG ${OUTPUT_TMP} ${OUTPUT} 640x360 ${OUTPUT_LOG}
#    if [ -f ${OUTPUT} ]; then
    if [ -s ${OUTPUT} ]; then
        echo ${OUTPUT} exists and non-zero. Removing ${OUTPUT_TMP} >> ${OUTPUT_LOG}
        mv ${OUTPUT_LOG} video/ts.log
        rm ${OUTPUT_TMP}
     else
        echo ${OUTPUT} does not exist. Moving ${OUTPUT_TMP} to video/ts.bad >> ${OUTPUT_LOG}
        mv ${OUTPUT_LOG} ${OUTPUT_TMP} video/ts.bad
     fi
#    $PERL $ENC2PROG ${OUTPUT}_tmp.ts t3.mp4 640x360
#     echo mv ${OUTPUT}_tmp.ts video/ts.ok >> video/tsencode.log
#     mv ${OUTPUT}_tmp.ts video/ts.ok

# mode 2 example is as follows
#elif [ ${MODE} = 2 ]; then
#   $RECORDER $CHANNEL $DURATION ${OUTPUT}.tmp.ts --b25 --strip
#   ffmpeg -i ${OUTPUT}.tmp.ts ... 適当なオプション ${OUTPUT}
fi
