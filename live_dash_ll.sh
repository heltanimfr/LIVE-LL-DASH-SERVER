#!/bin/bash

OUT_DIR="/home/lcarmina/DEV/scripts/live_dash_ll/storage/"
mkdir -p "$OUT_DIR"

INPUT_FILE="Spring.mp4"

ffmpeg \
 -re -fflags +genpts -stream_loop -1 -i "$INPUT_FILE" \
 -flags +global_header -r 30000/1001 \
 -filter_complex "
 split=3[s0][s1][s2];
 [s0]scale=1920x1080,drawtext=fontfile=/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf:text='%{localtime\:%H\\\\\:%M\\\\\:%S}.%{eif\\:mod(n*1000/30000*1001\,1000)\\:d\\:3}':x=10:y=10:fontsize=24:fontcolor=white:box=1:boxcolor=0x00000099[v0];
 [s1]scale=1280x720,drawtext=fontfile=/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf:text='%{localtime\:%H\\\\\:%M\\\\\:%S}.%{eif\\:mod(n*1000/30000*1001\,1000)\\:d\\:3}':x=10:y=10:fontsize=24:fontcolor=white:box=1:boxcolor=0x00000099[v1];
 [s2]scale=768x432,drawtext=fontfile=/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf:text='%{localtime\:%H\\\\\:%M\\\\\:%S}.%{eif\\:mod(n*1000/30000*1001\,1000)\\:d\\:3}':x=10:y=10:fontsize=24:fontcolor=white:box=1:boxcolor=0x00000099[v2]
 " \
 -map [v0] -map [v1] -map [v2] -map 0:a:0 \
 -pix_fmt yuv420p -c:v libx264 \
 -b:v:0 5000K -minrate:v:0 5000K -maxrate:v:0 5000K -bufsize:v:0 500K \
 -b:v:1 3000K -minrate:v:1 3000K -maxrate:v:1 3000K -bufsize:v:1 300K \
 -b:v:2 1100K -minrate:v:2 1100K -maxrate:v:2 1100K -bufsize:v:2 110K \
 -g:v 30 -keyint_min:v 30 -sc_threshold:v 0 \
 -color_primaries bt709 -color_trc bt709 -colorspace bt709 \
 -c:a aac -ar 48000 -b:a 96k \
 -preset veryfast -tune zerolatency -x264-params nal-hrd=cbr \
 -adaptation_sets 'id=0,seg_duration=2.002,streams=v id=1,seg_duration=2.002,streams=a' \
 -use_timeline 0 -streaming 1 -window_size 5 -extra_window_size 2 -frag_type every_frame -ldash 1 \
 -utc_timing_url 'https://time.akamai.com?iso&amp;ms' -format_options 'movflags=cmaf' \
 -write_prft 1 -target_latency '3.0' -http_user_agent LCA_Synamedia_Broadcaster_v1.0 \
 -http_persistent 1 \
 -media_seg_name "chunk-stream_\$RepresentationID\$-\$Number%05d\$.m4s" \
 -init_seg_name "init-stream_\$RepresentationID\$.m4s" \
 -f dash "$OUT_DIR/out.mpd"
