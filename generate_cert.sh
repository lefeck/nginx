#!/bin/bash
#
usage()  
{  
    echo "Usage: $0 [-a [rsa|ecc]] [-d <domain>] [-n <name>] [-h]"  
    echo "  Options:"
    echo "    -a  algorithm.[rsa|ecc]"
    echo "    -d  domain.example: xxx.com,abc.org,*.abc.org"
    echo "    -n  server key name"   
    echo "    -h  help"  
    exit 1  
} 

srv_key_name="server"

while getopts "a:d:n:h" arg #选项后面的冒号表示该选项需要参数
do
    case $arg in
        a)
            alg=$OPTARG #算法
            ;;
        d)
            all_domain=$OPTARG #域名,逗号分隔
            ;;
        n)
            srv_key_name=$OPTARG #服务器证书名称
            ;;
        h)
            usage
            exit 0
            ;;
        ?)  #当有不认识的选项的时候arg为?
            usage
            exit 1
            ;;
    esac
done

domain="domain.com"
san="DNS:*.${domain},DNS:${domain}"
if [ -n "${all_domain}" ]; then
    #分割域名
    OLD_IFS="$IFS"  
    IFS="," 
    domain_array=($all_domain)
    IFS="$OLD_IFS"  

    domain_len=${#domain_array[@]} 
      
    domain=${domain_array[0]}
    san=""
    for ((i=0;i<domain_len;i++))
   {
    if [ $i = 0 ];then
        san="DNS:${domain_array[i]}"
    else
        san="${san},DNS:${domain_array[i]}"
    fi
   }
fi

ca_subj="/C=CN/ST=Hubei/L=Wuhan/O=MY/CN=MY CA"
server_subj="/C=CN/ST=Hubei/L=Wuhan/O=MY/CN=${domain}"
#其中C是Country，ST是state，L是local，O是Organization，OU是Organization Unit，CN是common name
days=14610 # 有效期40年
echo "san:${san}"

sdir="certs"
ca_key_file="${sdir}/ca.key"
ca_crt_file="${sdir}/ca.crt"
srv_key_file="${sdir}/${srv_key_name}.key"
srv_csr_file="${sdir}/${srv_key_name}.csr"
srv_crt_file="${sdir}/${srv_key_name}.crt"
srv_p12_file="${sdir}/${srv_key_name}.p12"
srv_fullchain_file="${sdir}/${srv_key_name}-fullchain.crt"
cfg_san_file="${sdir}/san.cnf"


#algorithm config
if [[ ${alg} = "rsa" ]] ; then
    rsa_len=2048
elif [[ ${alg} = "ecc" ]] ; then
    ecc_name=prime256v1
else 
    usage 
    exit 1
fi     #ifend

echo "algorithm:${alg}"

mkdir -p ${sdir}

if [ ! -f "${ca_key_file}" ]; then
    echo  "------------- gen ca key-----------------------"
    if [[ ${alg} = "rsa" ]] ; then
        openssl genrsa -out ${ca_key_file} ${rsa_len}
    elif [[ ${alg} = "ecc" ]] ; then
        openssl ecparam -out ${ca_key_file} -name ${ecc_name} -genkey
    fi     #ifend

    openssl req -new -x509 -days ${days} -key ${ca_key_file} -out ${ca_crt_file} -subj "${ca_subj}"
fi


if [ ! -f "${srv_key_file}" ]; then
    echo  "------------- gen server key-----------------------"
    if [[ ${alg} = "rsa" ]] ; then
        openssl genrsa -out ${srv_key_file} ${rsa_len}
    elif [[ ${alg} = "ecc" ]] ; then
        openssl ecparam -genkey -name ${ecc_name} -out ${srv_key_file}
    fi     #ifend

    openssl req -new  -sha256 -key ${srv_key_file} -out ${srv_csr_file} -subj "${server_subj}"

    printf "[ SAN ]\nauthorityKeyIdentifier=keyid,issuer\nbasicConstraints=CA:FALSE\nkeyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment\nsubjectAltName=${san}" > ${cfg_san_file}
    openssl x509 -req  -days ${days} -sha256 -CA ${ca_crt_file} -CAkey ${ca_key_file} -CAcreateserial -in ${srv_csr_file}  -out ${srv_crt_file} -extfile ${cfg_san_file} -extensions SAN
    cat ${srv_crt_file} ${ca_crt_file} > ${srv_fullchain_file}

    openssl pkcs12 -export -inkey ${srv_key_file} -in ${srv_crt_file} -CAfile ${ca_crt_file} -chain -out ${srv_p12_file}
fi