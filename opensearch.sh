#!/bin/sh
#
# Opensearch control script
# description: Opensearch
# chkconfig: - 80 20
##########################################
#Base Directory (ex:/opt/opensearch)
BASEDIR=/opt/opensearch-1.2.3
#User to run Opensearch as
USER=opensearch
prog='Opensearch'
PIDFILE=$BASEDIR/opensearch.pid
START_SCRIPT="$BASEDIR/bin/opensearch -Enode.name=$HOSTNAME -Eplugins.security.disabled=true"
SHUTDOWN_WAIT=30
start() {
  echo -n "Starting $prog..."
  echo ""

  if [ -f $PIDFILE ]; then
  read ppid < $PIDFILE
    if [ `ps --pid $ppid 2> /dev/null | grep -c $ppid 2> /dev/null` -eq '1' ]; then
      echo -n "$prog is already running"
      failure
      echo
      return 1
    else
      rm -f $PIDFILE
    fi
  fi

  mkdir -p $(dirname $PIDFILE)
  chown $USER $(dirname $PIDFILE) || true

  if [ -r /etc/rc.d/init.d/functions ]; then
    echo "Using daemon"
    # Source function library.
    . /etc/init.d/functions
    daemon --user $USER "cd $BASEDIR; $START_SCRIPT & echo \$! > $PIDFILE" > /dev/null 2>&1 &
  else
    echo "Using su"
    su - $USER -c "cd $BASEDIR; $START_SCRIPT & echo \$! > $PIDFILE" > /dev/null 2>&1 &
  fi
}

stop() {
  echo -n $"Stopping $prog"
  echo ""
  count=0;

  if [ -f $PIDFILE ]; then
    read kpid < $PIDFILE
    let kwait=$SHUTDOWN_WAIT

    # Try issuing SIGTERM
    kill -15 $kpid
    until [ `ps --pid $kpid 2> /dev/null | grep -c $kpid 2> /dev/null` -eq '0' ] || [ $count -gt $kwait ]
    do
      sleep 1
      let count=$count+1;
    done
    if [ $count -gt $kwait ]; then
      kill -9 $kpid
    fi
  fi
  rm -f $PIDFILE
}

status() {
  if [ -f $PIDFILE ]; then
    read ppid < $PIDFILE
    if [ `ps --pid $ppid 2> /dev/null | grep -c $ppid 2> /dev/null` -eq '1' ]; then
      echo "$prog is running (pid $ppid)"
      return 0
    else
      echo "$prog dead but pid file exists"
      return 1
    fi
  fi
  echo "$prog is not running"
  return 3
}

case "$1" in
  start)
    start
    ;;
  stop)
    stop
    ;;
  restart)
    $0 stop
    $0 start
    ;;
  status)
    status
    ;;
  *)
    ## If no parameters are given, print which are available.
    echo "Usage: $0 {start|stop|status}"
    exit 1
    ;;
esac
