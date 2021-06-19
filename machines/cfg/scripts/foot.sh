spid=`pidof sway`
path=/run/user/1000/sway-ipc.1000.$spid.sock
export SWAYSOCK=$path
foot --server