import yaml
import os


#HOSTS_PATH = 'Z:/hosts'
#ANSIBLE_HOST_PATH = 'Z:/ansible_hosts'
HOSTS_PATH = '/etc/hosts'
ANSIBLE_HOST_PATH = '/etc/ansible/hosts'
ANSIBLE_CONFIG_PATH = '/etc/ansible/ansible.cfg'

def Add_hosts(host_data):
    print('Appending hosts file')
    try:
        with open(HOSTS_PATH,'a+') as f:
            for master in host_data['Master']:
                new_hosts = '\n' +  master['ip'] + ' ' + master['hostname']
                f.write(new_hosts)
                print(master['hostname']+' Appended')
            for node in host_data['Node']:
                new_hosts = '\n' + node['ip'] + ' ' + node['hostname']
                f.write(new_hosts)
                print(node['hostname']+' Appended')
    except Exception as ex:
        print(ex)

def Config_Ansible(host_data):
    print('Configuring Ansible')
    try:
        with open(ANSIBLE_HOST_PATH,'w+') as f:
            f.write('[master]')
            for master in host_data['Master']:
                new_hosts = '\n' + master['hostname'] + " ansible_ssh_user=root  ansible_ssh_pass='" + str(master["root_password"]) + "'"
                f.write(new_hosts)
            f.write('\n[node]')
            for node in host_data['Node']:
                new_hosts = '\n' + node['hostname'] + " ansible_ssh_user=root  ansible_ssh_pass='" + str(node["root_password"]) + "'"
                f.write(new_hosts)
        with open(ANSIBLE_CONFIG_PATH,'a+') as f:
            f.write('\nhost_key_checking = False')
    except Exception as ex:
        print(ex)

if __name__ == "__main__":
    fs = open("kubs.yaml","r")
    datas = yaml.load(fs,Loader=yaml.FullLoader)
    if(len(datas['Master'])<1):
        print('Need at least one Master host')
        exit(1)
    if(len(datas['Master'])<1):
        print('Need at least one Node host')
        exit(1)
    Add_hosts(datas)
    Config_Ansible(datas)
