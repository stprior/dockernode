#! /bin/sh
# openrc-run for alpine linux
### BEGIN INIT INFO
# Provides:          frontui
# Required-Start:    $local_fs $remote_fs $network $syslog
# Required-Stop:     $local_fs $remote_fs $network $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Start/stop frontui server
### END INIT INFO

DESC="Frontui"
NAME=frontui
DATE=`date +%Y%m%d%H%M%S`
declare -r WORKINGDIR="$(pwd -P)/$(dirname $0)"
#WORKINGDIR=$W_DIR/splicious
PIDFILE=$WORKINGDIR/logs/$NAME.pid
LOGFILE=$WORKINGDIR/logs/$NAME-$DATE.log

if [ ! -d $WORKINGDIR/logs ]; then
   mkdir $WORKINGDIR/logs
fi

#if [ "$#" -ne 1 ] ; then
if [ $# -eq 0 ]; then
  cd $WORKINGDIR ; java -cp "libui/*" -Dhttp.port=9000 -Dconfig.file=ui.conf -Dplay.crypto.secret="s3cr3t" play.core.server.ProdServerStart 
fi

case "$1" in
    start)
        echo "Starting $DESC..."
        if [ ! -f $PIDFILE ]; then
            cd $WORKINGDIR
            nohup java -cp "libui/*" -Dhttp.port=9000 -Dconfig.file=ui.conf -Dplay.crypto.secret="s3cr3t" play.core.server.ProdServerStart < /dev/null > $LOGFILE 2>&1 &
            echo $! > $PIDFILE
            echo "$DESC started"
        else
            echo "$DESC is already running"
        fi
    ;;
    stop)
        if [ -f $PIDFILE ]; then
            PID=$(cat $PIDFILE);
            echo "Stopping $DESC..."
            kill $PID;
            echo "$DESC stopped"
            rm $PIDFILE
        else
            echo "$DESC is not running"
        fi
    ;;
    restart)
        if [ -f $PIDFILE ]; then
            PID=$(cat $PIDFILE);
            echo "Stopping $DESC...";
            kill $PID;
            echo "$DESC stopped";
            rm $PIDFILE
 
            echo "Starting $DESC..."
            cd $WORKINGDIR
            nohup java -cp "libui/*" -Dhttp.port=9000 -Dconfig.file=ui.conf -Dplay.crypto.secret="s3cr3t" play.core.server.ProdServerStart < /dev/null > $LOGFILE 2>&1 &
            echo $! > $PIDFILE
            echo "$DESC started"
        else
            echo "$DESC is not running"
        fi
    ;;
   *)
     echo "Usage: $0 start|stop|restart"
   ;;
esac
exit $?
