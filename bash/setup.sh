#!/bin/bash

install_dir=$HOME/.cca-auth
id_rsa=$HOME/.ssh/id_rsa
if [ ! -e ${id_rsa} ];
	then
		echo ${id_rsa}' does not exist. Run "ssh-keygen" and try again.'
fi
echo -n "Student ID?:"
read student_id
echo -n "Password?:"
read password
echo -n "URL?: "
read web_url
echo "Installing to "${install_dir}

if [ ! -e ${install_dir} ];
	then
		mkdir ${install_dir}
fi
echo ${student_id},${password},${web_url} | openssl rsautl -encrypt -inkey ${id_rsa} > ${install_dir}/cca-auth.rsa
cp ./cca-auth.sh ${install_dir}

echo "Script and encrypted password successfully installed at "${install_dir}
echo "Run "${install_dir}"/cca-auth.sh to authenticate. You may also add it to cron/crontab."
echo "Thanks and have fun!"
