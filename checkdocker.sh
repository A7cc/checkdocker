#!/bin/bash

# 定义环境变量
docker=0
k8s=0
vm=0
and=6

# 查看/proc/1/cgroup
tmp1=`cat /proc/1/cgroup`
if [[ $(echo $tmp1 | grep "docker") != "" ]]; then
    docker=`expr $docker + 1`
elif  [[ $(echo $tmp1 | grep "kubepods") != "" ]]; then
    k8s=`expr $k8s + 1`
else
    vm=`expr $vm + 1`
fi

# 检查dockerenv文件
if [[ -f "/.dockerenv" ]]; then
    docker=`expr $docker + 1`
    k8s=`expr $k8s + 1`
else
    vm=`expr $vm + 1`
fi

# 检查mount信息
tmp1=`mount | grep '/docker'`
if [[  $(echo $tmp1 | grep "docker") != ""  ]]; then
    docker=`expr $docker + 1`
    k8s=`expr $k8s + 1`
else
    vm=`expr $vm + 1`
fi

# 查看硬盘信息
tmp1=`fdisk -l`
if [[  $(echo $tmp1) == ""  ]]; then
    docker=`expr $docker + 1`
    k8s=`expr $k8s + 1`
else
    vm=`expr $vm + 1`
fi

# 查看文件系统以及挂载点
tmp1=`df -h | egrep '(overlay|aufs)'`
if [[  $(echo $tmp1 | grep "/overlay") == ""  ]]; then
    docker=`expr $docker + 1`
    k8s=`expr $k8s + 1`
else
    vm=`expr $vm + 1`
fi

# 查看环境变量
tmp1=`env | grep 'KUBEPODS'`
if [[  $(echo $tmp1) != ""  ]]; then
    
    k8s=`expr $k8s + 1`
else
    docker=`expr $docker + 1`
    vm=`expr $vm + 1`
fi

# 输出结果
echo -e "\033[34m[*] 经过了 $and 条规则的检测，该环境命中规则情况：\033[0m"
echo -e "\033[31m\t该环境命中docker了 $docker 规则\033[0m"
echo -e "\033[31m\t该环境命中k8s了 $k8s 规则\033[0m"
echo -e "\033[31m\t该环境命中虚拟机了 $vm 规则\033[0m"
echo -e "\033[34m[*] 该机器其他信息：\033[0m"
echo -e "\033[32m\t主机名为：`hostname`\033[0m"
echo -e "\033[32m\t系统信息：`uname -a`\033[0m"

# 定义最大值的名字
and=$docker
maxname="docker" 
if [[  $docker -lt $k8s  ]]; then
    and=$k8s
    maxname="k8s"
fi
if [[  $and -lt $vm  ]]; then
    and=$vm
    maxname="虚拟机"
fi
echo -e "\033[34m[*] 综上所述，初步判断该环境为：\033[31m$maxname\033[34m，命中规则数为：$and\033[0m"