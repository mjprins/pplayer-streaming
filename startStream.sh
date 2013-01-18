#/bin/sh!

if [ $# -ne 2 ]
then
    echo "Usage: $0  \"[audio|video]\" \"port\" "
    exit 1
fi

TYPE=$1
ADDRESS=$2
IP=`ifconfig  | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}'`
echo "IP=$IP"

if [ $TYPE == "audio" ]; then
    echo "Audio only"
    vlc --intf dummy pulse:// :live-caching=300 :sout='#transcode{acodec=vorb,ab=128,channels=2,samplerate=44100}:std{access=http,mux=ogg,dst='$IP:$ADDRESS'}'
elif [ $TYPE == "MP3" ]; then
    echo "MP3" 
    vlc --intf dummy pulse:// :live-caching=300 :sout='#transcode{acodec=mp3,ab=128,channels=2,samplerate=44100}:std{access=http,mux=mp3,dst='$IP:$ADDRESS'}'
elif [ $TYPE == "BOTH" ]; then
    echo "Trippel output"; 
    vlc --intf dummy pulse:// :live-caching=300 :sout='#duplicate{dst={transcode{acodec=mp3,ab=128,channels=2,samplerate=44100}:std{access=http,mux=mp3,dst='$IP:$ADDRESS/mp3'}},dst={transcode{acodec=vorb,ab=128,channels=2,samplerate=44100}:std{access=http,mux=ogg,dst='$IP:$ADDRESS/ogg'}},dst={transcode{acodec=mp3,ab=96}:duplicate{dst=std{access=livehttp{seglen=10,splitanywhere=true,delsegs=true,numsegs=5,index=/var/www/mystream.m3u8,index-url=http://'$IP'/streaming/mystream-########.ts},mux=ts,dst=/var/www/streaming/mystream-########.ts},select=audio}}}'                 
elif [ $TYPE == "HLS" ]; then
    vlc --intf dummy pulse:// :live-caching=300 :sout='#transcode{acodec=mp3,ab=96}:duplicate{dst=std{access=livehttp{seglen=10,splitanywhere=true,delsegs=true,numsegs=5,index=/var/www/mystream.m3u8,index-url=http://'$IP'/streaming/mystream-########.ts},mux=ts,dst=/var/www/streaming/mystream-########.ts},select=audio}'
    
    
    
    
    
else
    echo "Audio and video"
     #vlc --intf dummy screen:// :screen-fps=25.000000 :input-slave=pulse:// :live-caching=300 :sout='#transcode{vcodec=theo,vb=800,scale=1,acodec=vorb,ab=128,channels=2,samplerate=44100}:std{access=http,mux=ogg,dst='$ADDRESS'}'    
fi
