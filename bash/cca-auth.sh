#!/bin/bash
temp0=`mktemp`
temp1=`mktemp`


cd `echo $(cd $(dirname $0) && pwd)`

auth_info=$(openssl rsautl -decrypt -inkey ~/.ssh/id_rsa -in ./cca-auth.rsa)



gakuseki=`echo ${auth_info} | awk -F, '{print $1}'`
anshonum=`echo ${auth_info} | awk -F, '{print $2}'`
web_url=`echo ${auth_info} | awk -F, '{print $3}'`

#echo ${auth_info}
#echo ${gakuseki}
#echo ${anshonum}
#echo ${web_url}

sleep 5s

echo `curl -G ${web_url} 2> /dev/null` > ${temp0}

sed -i "s/[\<,\>,\',\"]/\n/g" ${temp0}

auth_url=`cat ${temp0} | grep URL | sed -e "s/URL[\=]//g" -e "s/1[\;]//g"`

#echo ${auth_url}

echo `curl -G ${auth_url} 2> /dev/null` > ${temp0}

sed -i "s/[\<,\>]/\n/g" ${temp0}


cat ${temp0} | grep form | grep method > ${temp1}

sed -i "s/^form//g" ${temp1}

sed -i "s/target//g" ${temp1}

sed -i "s/\_parent//g" ${temp1}

#sed -i "s/\=/\,/g" ${temp1}

#sed -i "s/\"//g" ${temp1}

echo `cat ${temp0} | grep select | grep selected | grep -v submit | sed -e "s/option/name\=\"provider\"/g" -e "s/selected//g"` >> ${temp1}

cat ${temp0} | grep input | grep type | grep -v submit >> ${temp1}

sed -i "s/input//g" ${temp1}

sed -i "s/[\']/\"/g" ${temp1}

sed -i "s/[\/]$//g" ${temp1}

sed -i "s/^\ //g" ${temp1}

sed -i "s/\=/\,/g" ${temp1}

sed -i "s/\"\ /\"\|/g" ${temp1}

sed -i "s/\"//g" ${temp1}

#cat ${temp1}

cp /dev/null ${temp0}

while read auth_option;
	do
	var_1=`echo ${auth_option} | awk -F'|' '{print $1}'`
	var_2=`echo ${auth_option} | awk -F'|' '{print $2}'`
	var_3=`echo ${auth_option} | awk -F'|' '{print $3}'`
	var_4=`echo ${auth_option} | awk -F'|' '{print $4}'`
	IFS_BACKUP=$IFS
	IFS=$'\n'
	i=0
	for varset in "${var_1}" "${var_2}" "${var_3}" "${var_4}"
		do
		i=`expr $i + 1`
		vars=`echo $i : ${varset}`
		det_m=`echo ${vars} | grep method`
		det_a=`echo ${vars} | grep action`
		det_t=`echo ${vars} | grep type`
		det_n=`echo ${vars} | grep name`
		det_v=`echo ${vars} | grep value`
		if [ -n "$det_m" ]; then
			method=`echo ${vars} | awk -F, '{print $2}'`
		elif [ -n "$det_a" ]; then
			action=`echo ${vars} | awk -F, '{print $2}'`
		elif [ -n "$det_t" ]; then
			type=`echo ${vars} | awk -F, '{print $2}'`
		elif [ -n "$det_n" ]; then
			name=`echo ${vars} | awk -F, '{print $2}'`
		elif [ -n "$det_v" ]; then
			value=`echo ${vars} | awk -F, '{print $2}'`
		fi
	done
	IFS=$IFS_BACKUP
	if [ ${name} = "username" ];
		then
		value=${gakuseki}
	fi
	if [ ${name} = "password" ];
		then
		value=${anshonum}
	fi
	if [ ! "$method" = "none" ];
		then
		meth=${method}
		act=${action}
		echo "HTTP method is "${meth}" ."
		echo ""
		echo "Action target is at "${act}" ."
		echo ""
	fi
	if [ "$method" = "none" ]; then
		#echo ${name}" is "${value}" (Type: "${type}")"
		echo ${type}"|"${name}"|"${value} >> ${temp0}
		echo ""
	fi
	method="none"
	action="none"
	type="none"
	name="none"
	value="none"
done < ${temp1}

cat ${temp0} > ${temp1}

while read auth_option;
	do
	var_n=`echo ${auth_option} | awk -F'|' '{print $2}'`
	var_v=`echo ${auth_option} | awk -F'|' '{print $3}'`
	name=${var_n}
	value=${var_v}
	for vars in ${var_n} ${var_v}
		do
		det_n=`echo ${vars} | grep none`
		det_v=`echo ${vars} | grep none`
		if [ -n "$det_n" ]; then
			name=""
		fi
		if [ -n "$det_v" ]; then
			value=""
		fi
	done
	curl_option=${curl_option}${name}=${value}"&"
done < ${temp1}
auth_url=`dirname ${auth_url}`
curl_option=`echo ${curl_option} | sed -e "s/\ /\%20/g"`
command=`echo curl ${auth_url}/${act} -X ${meth} -d ${curl_option} -v`

echo "Issueing "${command}
clear
${command}

#cat ${temp0}

rm ${temp0}
rm ${temp1}

cd ~
