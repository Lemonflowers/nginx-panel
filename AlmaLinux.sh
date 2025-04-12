#!/bin/bash

echo -e "\033[32m \033[0m"
echo -e "\033[33m  您正在操作安装 Nginx+面板 5秒后开始...  （AlmaLinux全系）\033[0m"
echo -e "\033[32m \033[0m"

sleep 5

# 检查 NGINX 是否已经安装
if rpm -q nginx &>/dev/null; then
    echo "NGINX 已经安装，跳过安装过程"
    # 执行 curl 命令，设置权限
    curl -s https://github.com/Lemonflowers/nginx-panel/raw/main/put.sh | sudo bash
    exit 0
fi

# 安装必要的工具
echo "安装必要工具..."
dnf -y install curl wget unzip vim yum-utils sudo openssh-clients

# 处理 NGINX 官方仓库配置
echo "处理 NGINX 官方仓库配置..."
cat > /etc/yum.repos.d/nginx.repo << EOF
[nginx]
name=nginx repo
baseurl=http://nginx.org/packages/centos/9/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://nginx.org/keys/nginx_signing.key
EOF

# 清理并更新缓存
dnf clean all
dnf makecache

# 安装 NGINX
echo "安装 NGINX..."
dnf -y install nginx

# 启动并设置 NGINX 开机启动
echo "启用 NGINX 服务..."
systemctl enable nginx
systemctl start nginx

# 安装 Remi 仓库并启用 PHP 7.4
echo "安装 Remi 仓库并启用 PHP 7.4 ..."
dnf -y install http://rpms.remirepo.net/enterprise/remi-release-9.rpm
dnf module reset php -y
dnf module enable php:remi-7.4 -y
dnf -y install php php-fpm  php-xml php-mbstring php-zip  php-curl


# 配置 PHP-FPM 运行用户为 nginx
echo "设置 PHP-FPM 运行用户为 nginx..."
if [ -f /etc/php-fpm.d/www.conf ]; then
    sed -i 's/user = apache/user = nginx/' /etc/php-fpm.d/www.conf
    sed -i 's/group = apache/group = nginx/' /etc/php-fpm.d/www.conf
else
    echo "/etc/php-fpm.d/www.conf 文件缺失！"
    exit 1
fi

# 修改 PHP-FPM 配置监听地址为 127.0.0.1:9000
echo "修改 PHP-FPM 配置，设置监听地址为 127.0.0.1:9000 ..."
if [ -f /etc/php-fpm.d/www.conf ]; then
    sed -i 's|listen = /run/php-fpm/www.sock|listen = 127.0.0.1:9000|' /etc/php-fpm.d/www.conf
else
    echo "/etc/php-fpm.d/www.conf 文件缺失！"
    exit 1
fi

# 删除 /run/php-fpm/www.sock 文件
echo "删除 /run/php-fpm/www.sock ..."
rm -rf /run/php-fpm/www.sock

# 删除 /etc/nginx/default.d 目录
echo "删除 /etc/nginx/default.d ..."
rm -rf /etc/nginx/default.d

# 启动并设置 PHP-FPM 开机启动
echo "启用 PHP-FPM 服务..."
systemctl enable php-fpm
systemctl start php-fpm

# 安装 acme.sh (SSL证书工具)
echo "安装 acme.sh依赖 ..."
sudo dnf install curl git -y

# 从源文件安装 acme.sh (SSL证书工具)
echo "Git acme.sh ..."
git clone https://github.com/acmesh-official/acme.sh.git
cd acme.sh
./acme.sh --install


# 修复权限问题，设置执行权限
echo "设置 acme.sh 文件夹权限..."
setfacl -R -m u:nginx:rwx /root/.acme.sh

# 配置 nginx 用户可以使用 sudo
echo "配置 nginx 用户可以使用 sudo..."
echo "nginx ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# 删除 nginx 配置文件和 conf.d 目录
echo "删除 /etc/nginx/nginx.conf 和 /etc/nginx/conf.d ..."
rm -rf /etc/nginx/nginx.conf
rm -rf /etc/nginx/conf.d

# 设置 日志翻滚权限问题
echo "设置 日志翻滚权限问题"
rm -f /etc/logrotate.d/nginx
curl -o /etc/logrotate.d/nginx https://github.com/Lemonflowers/nginx-panel/raw/main/nginx
sudo mkdir /var/log/nginx/log

# 下载并解压 nginx.zip 到 /etc/nginx
echo "下载并解压 nginx.zip 到 /etc/nginx ..."
curl -o /etc/nginx/nginx.zip https://github.com/Lemonflowers/nginx-panel/raw/main/nginx.zip
unzip -o /etc/nginx/nginx.zip -d /etc/nginx

# 删除原有的 /usr/share/nginx/html 
echo "删除 /usr/share/nginx/html"
rm -rf /usr/share/nginx/html


# 删除残留的 zip 文件
echo "删除残留的压缩包..."
rm -rf /etc/nginx/nginx.zip


# 设置时区
echo "设置时区"
sudo timedatectl set-timezone Asia/Shanghai
sudo timedatectl set-ntp true

echo "放行所有端口 "
sudo firewall-cmd --zone=public --add-port=1-65535/tcp --permanent
sudo firewall-cmd --zone=public --add-port=1-65535/udp --permanent
sudo firewall-cmd --reload

# 重启 NGINX 服务
echo "重启 NGINX 服务..."
systemctl restart nginx


# 执行 curl 命令，设置权限
echo "执行 curl 命令 修复权限 ..."
curl -s https://github.com/Lemonflowers/nginx-panel/raw/main/put.sh | sudo bash
