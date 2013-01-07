#!/bin/ksh

export m_name u_name

function get_login_info {
echo "Please enter the machine name or ip address"
read m_name
echo "Please enter the user name to login"
read u_name
}

function remote_exec {
echo "Login to the machine $m_name with user $u_name,Please hint enter to continue or type r to reenter the login info or n to go to the main menue"
read $opt
ssh $u_name@$m_name "$@"
}

function change_password {
echo "Please enter the user name for password change"
read u_name
passwd $u_name
}

function services_running {
echo "Please enter the machine name or Ip address"
read m_name
echo "Please enter the user name to login"
read u_name
echo "Loging into the machine $m_name with user $u_name to find running service...
Please hint enter to continue or type r to reenter the login info or n to go to the main menue"
read opt
if [ "$opt" == 'n' ]; then
return 0
fi
#ssh $u_name@$m_name "echo '#######################RUNNING SERVICES -- START#################################';ps -ef"
ssh $u_name@$m_name "$@"
#echo "#######################RUNNING SERVICES -- END#################################"
}

function kill_pids {
  kill -9 $@
  if [ $? -eq 0 ]; then
    echo "The process are killed"
  fi
}

function kill_process {
echo "Do you want to kill a process using PID or program name"
echo "For pid type p and n for Program name"
read pid_opt
if [ "$pid_opt" == 'p' ]; then
   echo "Please enter PID or list of PID's with space"
   read pid_name
   kill_pid $pid_name
elif [ "$pid_opt" == 'n' ];then
   echo "Please enter the program name you want to kill"
   read p_name
   ps -ef | grep "$p_name" | grep -v grep
   echo "Please verify if you want to kill the above PIDs matching youe program name to confirm please enter 'y'"
   read k_opt

   if [ "$k_opt" == 'y' ]; then
   process_pids=`ps -ef | grep "$p_name" | grep -v grep | awk -F' ' '{print $2}'`
   kill_pid $process_ids
   else
    echo "going to main menu"
   fi
else
   echo "Invalid option"
fi
}


function check_space {

echo "Current logged into machine:$HOST and user`whoami` "
echo "If you want to check space in other system hit c else hit enter to continue"
read m_flag

if [ "$m_flag" == "c" ]; then
  m_falg=1
else
  m_flag=0
fi

echo "Please enter the options
      f- all filesystems
      sf- single filesystem
      d-only directory  a- directory size along with files"
read ds_opt


if [ "$ds_opt" == 'f' ]; then
    if [ $m_flag -eq 1 ];then
       services_running "df -h"
    else
       df -h
        fi
elif [ "$ds_opt" == 'sf' ]; then
    echo "Enter the file system name"
    read f_name
    if [ $m_flag -eq 1 ];then
       services_running "df -h $f_name"
    else
       df -h $f_name
        fi
elif [ "$ds_opt" == 'd' ]; then
    echo "Enter the dirctory name"
    read $d_name
    if [ $m_flag -eq 1 ];then
       services_running "du -s $d_name"
    else
       du -s $d_name
        fi
elif [ "$ds_opt" == 'a' ]; then
    echo "Enter the dirctory name"
    read $d_name
    if [ $m_flag -eq 1 ];then
       services_running "du $d_name"
    else
       du $d_name
       fi
else
    echo "invalid option"
fi


}



function menu {
echo "please Enter the operation you want to perform
      1-change passwd           2- see disk space
      3-login to other server   4- see services running
      5-see all open ports      6-show all java process
      7-kill appliation         8-exit"

read option

case $option in
 1) echo "changing password"
         change_password
         menu
    ;;
 2) echo "Chekcing Disk Space"
         check_space
         menu
    ;;
 3) echo "Login to other server"
          get_login_info
          remote_exec
          menu
    ;;
 4) echo "Finding services running"
         services_running "echo '####################### RUNNING SERVICES -- START#################################';ps -ef;echo '####################### RUNNING SERVICES -- END#################################'"
         menu
    ;;
 5) echo "Finding all open ports"
         services_running "echo '####################### ALL OPEN PORTS -- START#################################';netstat -tulpn;echo '####################### ALL OPEN PORTS -- END#################################'"
         menu
    ;;
 6) echo "Find all java process running"
#        java_process
         services_running "echo '####################### RUNNING JAVE SERVICES -- START#################################';ps -ef |grep java|grep -v grep;echo '####################### RUNNING JAVE SERVICES -- END#################################'"
         menu
    ;;
 7) echo "Kill appliaction"
         kill_process
         menu
    ;;
 8) echo "exiting"
         exit 0
    ;;
 *) echo "Invalid option Please try again";;
esac

}
#Function calls
menu
