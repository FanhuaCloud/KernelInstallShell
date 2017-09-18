#!/bin/bash

function Colorset() {
  #颜色配置
  echo=echo
  for cmd in echo /bin/echo; do
    $cmd >/dev/null 2>&1 || continue
    if ! $cmd -e "" | grep -qE '^-e'; then
      echo=$cmd
      break
    fi
  done
  CSI=$($echo -e "\033[")
  CEND="${CSI}0m"
  CDGREEN="${CSI}32m"
  CRED="${CSI}1;31m"
  CGREEN="${CSI}1;32m"
  CYELLOW="${CSI}1;33m"
  CBLUE="${CSI}1;34m"
  CMAGENTA="${CSI}1;35m"
  CCYAN="${CSI}1;36m"
  CSUCCESS="$CDGREEN"
  CFAILURE="$CRED"
  CQUESTION="$CMAGENTA"
  CWARNING="$CYELLOW"
  CMSG="$CCYAN"
}

function Logprefix() {
  #输出log
  echo -n ${CGREEN}'CraftYun >> '
}

function Checksystem() {
  cd
  Logprefix;echo ${CMSG}'[Info]检查系统'${CEND}
  #检查系统
  if [[ $(id -u) != '0' ]]; then
    Logprefix;echo ${CWARNING}'[Error]请使用root用户安装!'${CEND}
    exit
  fi

  if grep -Eqii "CentOS" /etc/issue || grep -Eq "CentOS" /etc/*-release; then
    DISTRO='CentOS'
  else
    DISTRO='unknow'
  fi

  if [[ ${DISTRO} == 'unknow' ]]; then
    Logprefix;echo ${CWARNING}'[Error]请使用Centos系统安装!'${CEND}
    exit
  fi

  if grep -Eqi "release 5." /etc/redhat-release; then
      RHEL_Version='5'
  elif grep -Eqi "release 6." /etc/redhat-release; then
      RHEL_Version='6'
  elif grep -Eqi "release 7." /etc/redhat-release; then
      RHEL_Version='7'
  fi

  # if [[ ${RHEL_Version} != '7' ]]; then
  #   Logprefix;echo ${CWARNING}'[Error]请使用Centos7安装!'${CEND}
  #   exit
  # fi

  if [[ `getconf WORD_BIT` = '32' && `getconf LONG_BIT` = '64' ]] ; then
      OS_Bit='64'
  else
      OS_Bit='32'
  fi

  # if [[ ${OS_Bit} == '32' ]]; then
  #   Logprefix;echo ${CWARNING}'[Error]请使用64位Centos!'${CEND}
  #   exit
  # fi
}

function Coloseselinux() {
  #关闭selinux
  Logprefix;echo ${CMSG}'[Info]关闭Selinux'${CEND}
  [ -s /etc/selinux/config ] && sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
  setenforce 0 >/dev/null 2>&1
}

function Installbasesoftware() {
  #安装基础软件
  Logprefix;echo ${CMSG}'[Info]安装基础软件'${CEND}
  Logprefix;echo ${CMSG}'[Info]安装epel源'${CEND}
  yum -y install epel-release
  Logprefix;echo ${CMSG}'[Info]安装wget'${CEND}
  yum -y install wget
  Logprefix;echo ${CMSG}'[Info]安装lrzsz'${CEND}
  yum -y install lrzsz
  Logprefix;echo ${CMSG}'[Info]安装依赖'${CEND}
  yum -y install ncurses-devel openssl-devel
  Logprefix;echo ${CMSG}'[Info]安装zip unzip'${CEND}
  yum -y install unzip zip
  Logprefix;echo ${CMSG}'[Info]安装Development Tools'${CEND}
  yum -y groupinstall "Development Tools"
}

function Askuser() {
  KernelName=$(whiptail --inputbox "请输入内核版本" --nocancel 10 100 3>&1 1>&2 2>&3)
  fstr=`echo ${KernelName} | cut -d \. -f 1`
}

function MakeKernel() {
  Logprefix;echo ${CMSG}'[Info]开始下载内核'${CEND}
  wget http://mirrors.163.com/kernel/linux/kernel/v${fstr}.x/linux-${KernelName}.tar.xz
  Logprefix;echo ${CMSG}'[Info]解压内核'${CEND}
  tar -xf linux-${KernelName}.tar.xz -C /usr/src/
  cd /usr/src/linux-${KernelName}
  make menuconfig
  make
}

function InstallKernel() {
  make modules_install
  make install
}

function InstallOK() {
  Logprefix;echo ${CMSG}'[Info]安装完成'${CEND}
}

Colorset
Checksystem
Coloseselinux
Askuser
Installbasesoftware
MakeKernel
InstallKernel
InstallOK
