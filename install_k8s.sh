#/bin/bash

set -e

ALIYUN_REPO_PATH='resource/repo/CentOS-Base.repo'
EPEL_REPO_PATH='resource/repo/epel-7.repo'
HELP_INFO='install_k8s.sh [-r --repo] [-h --help]\n\t-h --help\tshow this help message'
REPO_BACKUP='/etc/repos.bak'


root_need() {
    if [[ $EUID -ne 0 ]]; then
        echo "Error:This script must be run as root!" 1>&2
        exit 1
    fi
}

Replace_Aliyun_Repo(){
    echo 'backup yum repo'
    cp -rf /etc/yum.repos.d $REPO_BACKUP
    echo 'replace yum repo to aliyun'
    cp $ALIYUN_REPO_PATH /etc/yum.repos.d/CentOS-Base.repo
    cp $EPEL_REPO_PATH /etc/yum.repos.d/epel-7.repo
    echo 'reconfig yum'
    yum clean all 
    yum makecache 
}

Install_Depend_Package(){
    echo 'Installing Ansible'
    yum install -y ansible
    echo 'Installing pip'
    yum -y install python-pip
    echo 'Install yaml'
    pip install --ignore-installed PyYaml
}

Alert_Msg_And_Exe_Install(){
    while true
    do
        read -r -p "Will re-config some system config? [y/n] " input
        case $input in
            [yY][eE][sS]|[yY])
                Replace_Aliyun_Repo
                Install_Depend_Package
                Unpackage_k8s
                python install_by_ansible.py
                break
                ;;

            [nN][oO]|[nN])
                echo "Exiting.."
                exit 1	       	
                ;;

            *)
                echo "Please input y or n"
                ;;
        esac
    done
}

Unpackage_k8s(){
    echo "Unpackage kubernetes"
    tar -xzvf resource/kubernetes/kubernetes-server-linux-amd64.tar.gz --strip-components=3 -C /usr/local/bin/ kubernetes/server/bin/kube{let,ctl,-apiserver,-controller-manager,-scheduler,-proxy}
    echo "Unpackage etcd"
    tar -xzvf resource/kubernetes/etcd-v3.3.10-linux-amd64.tar.gz --strip-components=1 -C /usr/local/bin/ etcd-v3.3.10-linux-amd64/etcd{,ctl}
}


root_need
ARGS=`getopt -o rh --long repo,help -n "$0" -- "$@"`
if [ $? != 0 ]; then
echo "Terminating..."
exit 1
fi
eval set -- "${ARGS}"
while true
do
    case "$1" in
        -h|--help)
            echo -e $HELP_INFO;
            exit 0
            ;;
        --)
            shift
            break
            ;;
        *)
            shift
            break
            ;;
    esac
done
Alert_Msg_And_Exe_Install