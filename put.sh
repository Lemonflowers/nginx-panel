#!/bin/bash


echo -e "\033[32m \033[0m"
echo -e "\033[33m处理中...请稍等片5秒,本脚本即是最终页面也是修复权限脚本。 \033[0m"
echo -e "\033[32m \033[0m"

sleep 5


# 清屏
clear

# 列出所有需要执行 chmod 777 的路径
paths=(
    "/etc/nginx"
    "/var/cache/nginx"
    "/var/log/nginx/log"
    "/var/log/nginx"
    "/etc/php.ini"
    "/etc/php/7.4/fpm/php.ini"
)

# 遍历每个路径并执行 chmod -R 777
for path in "${paths[@]}"; do
    if [ -e "$path" ]; then
        echo "正在修改权限: $path"
        chmod -R 777 "$path"
        echo "权限修改成功: $path"
    else
        echo "路径不存在: $path"
    fi
done

# 为 /root/.acme.sh 目录设置 nginx 用户的执行权限
if [ -d "/root/.acme.sh" ]; then
    echo "正在为 /root/.acme.sh 设置 nginx 用户的执行权限"
    sudo setfacl -m u:nginx:x /root/.acme.sh
    echo "权限设置成功: /root/.acme.sh"
else
    echo "路径不存在: /root/.acme.sh"
fi

# 获取服务器 IP 地址
IP_ADDRESS=$(hostname -I | awk '{print $1}')

# 清屏
clear

# 输出控制面板信息，设置红色和绿色字体
echo -e "\033[32m \033[0m"
echo -e "\033[32m欢迎使用 Sbed.net 反向面板！\033[0m"
echo -e "\033[32m \033[0m"
echo -e "\033[32m权限设置成功！nginx 已安装完成！\033[0m"
echo -e "\033[32m \033[0m"
echo -e "\033[32m初始面板： http://$IP_ADDRESS:8899/ \033[0m"
echo -e "\033[32m \033[0m"
echo -e "\033[32m初始账号: admin \033[0m"
echo -e "\033[32m \033[0m"
echo -e "\033[32m初始密码: 123456 \033[0m"
echo -e "\033[32m \033[0m"
echo -e "\033[31m首次安装,请依次执行下方命令,修正ACME补充！ \033[0m"
echo -e "\033[32m \033[0m"
echo -e "\033[32m如果您单纯执行的此命令是修复权限则代表修复成功！\033[0m"
echo -e "\033[32m \033[0m"
echo -e "\033[32mchmod +x ~/.acme.sh/acme.sh \033[0m"
echo -e "\033[32msource ~/.bashrc \033[0m"
echo -e "\033[32msource ~/.bash_profile \033[0m"
echo -e "\033[32macme.sh --set-default-ca --server letsencrypt \033[0m"
echo -e "\033[32m \033[0m"
