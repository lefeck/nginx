## nginx install
```
while [[ true ]]; do
 git clone https://github.com/wangjinh/nginx.git
 cd nginx && chmod +x install-nginx.sh && ./install-nginx.sh 
 break
done
```

## 使用shell脚本生成自签名证书


shell脚本的使用说明如下：

- 脚本中使用openssl命令生成证书，执行前需要保证openssl命令可用。
- 脚本在centos 7和ubuntu 16.04中已经验证通过；在windows中的git bash里无法正确执行，不要在windows上的git bash里面执行脚本。
- 脚本命令格式如下：

```shell
./gen-cert.sh -a 算法 -d 域名 -n 证书文件名
```

脚本中的参数说明：

- -a 生成的证书中使用的算法，有rsa和ecc两种选项，rsa会生成2048位的key，ecc生成prime256v1的key；
- -d 证书中的域名，可以支持写多个域名，多个域名使用逗号分隔。第一个域名会作为CN（common name），这个参数里面所有的域名会写入证书的SAN（通过这可以一个证书支持多个不同域名）。
- -n 生成的服务器证书文件名。脚本生成的证书文件都放在certs目录下，如果目录下已经存在同名的证书文件则会跳过。第二次执行脚本时，如果-n参数指定为与第一次不同的名称，则会使用第一次生成的CA证书签发新的服务器证书。
- -h 查看脚本帮助。


### 脚本执行示例

执行命令下面命令生成证书，生成pkcs12格式证书过程中会提示输入证书密码，请保持两次输入一致。虽然输入密码时可以直接回车设为空，由于某些使用证书的场景必须要密码，所以最好设置一个密码。生成的文件中ca.crt与ca.key为CA证书的公钥与私钥；test.crt与test.key为服务器证书的公钥与私钥；test.p12为pkcs12格式的文件，包含了公私钥。

```shell
./gen-cert.sh -a ecc -d test.com,a.com,*.a.com -n test
```

![img](https://upload-images.jianshu.io/upload_images/16251782-5188ca5ccd90b8f1.png?)


[生成证书](https://www.jianshu.com/p/52fedb82ef53)


