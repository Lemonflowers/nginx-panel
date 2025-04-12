#!/bin/bash

echo -e "\033[32m \033[0m"
echo -e "\033[33m  您正在操作安装 Nginx+面板 5秒后开始...  （Debian12）\033[0m"
echo -e "\033[32m \033[0m"

sleep 5


# 检查 NGINX 是否已安装
if dpkg -l | grep -q nginx; then
    echo "NGINX 已经安装，跳过安装过程"
    # 执行 curl 命令，设置权限
    curl -s https://github.com/Lemonflowers/nginx-panel/raw/main/put.sh | sudo bash
    exit 0
fi

# 更新包索引
echo "系统更新包索引..."
sudo apt update -y
sudo apt install acl -y
sudo apt install unzip -y

# 安装依赖包
echo "安装必要的依赖包..."
sudo apt install -y curl sduo gnupg2 ca-certificates lsb-release debian-archive-keyring apt-transport-https

# 导入 NGINX 官方仓库的 GPG 密钥
echo "导入 NGINX 官方仓库的 GPG 密钥..."
curl -fsSL https://nginx.org/keys/nginx_signing.key | sudo tee /etc/apt/trusted.gpg.d/nginx.asc > /dev/null

# 设置 NGINX 官方仓库
echo "设置 NGINX 官方仓库..."
echo "deb http://nginx.org/packages/debian/ $(lsb_release -c | awk '{print $2}') nginx" | sudo tee /etc/apt/sources.list.d/nginx.list

# 导入 PHP 7.4 的 GPG 密钥
echo "导入 PHP 7.4 的 GPG 密钥..."
curl -sSL https://packages.sury.org/php/apt.gpg | sudo tee /etc/apt/trusted.gpg.d/sury-archive-keyring.gpg > /dev/null

# 设置 PHP 7.4 仓库
echo "设置 PHP 7.4 仓库..."
echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/sury-php.list

# 更新包索引（再次更新以包括 NGINX 和 PHP 7.4 仓库）
echo "更新包索引..."
sudo apt update -y

# 安装 NGINX
echo "安装 NGINX..."
sudo apt install -y nginx

# 安装 PHP 7.4 和 PHP-FPM
echo "安装 PHP 7.4 和 PHP-FPM..."
sudo apt install -y php7.4-fpm php7.4-cli  php7.4-xml php7.4-mbstring php7.4-curl php7.4-zip


# 设置 php-fpm 运行用户为 nginx
echo "设置 PHP-FPM 运行用户为 nginx..."
sudo sed -i 's/^user = www-data/user = nginx/' /etc/php/7.4/fpm/pool.d/www.conf
sudo sed -i 's/^group = www-data/group = nginx/' /etc/php/7.4/fpm/pool.d/www.conf

# 配置 PHP-FPM 监听地址为 127.0.0.1:9000
echo "设置 PHP-FPM 监听在 127.0.0.1:9000..."
sudo sed -i 's|^listen = /run/php/php7.4-fpm.sock|listen = 127.0.0.1:9000|' /etc/php/7.4/fpm/pool.d/www.conf

# 配置 nginx 用户可以使用 sudo
echo "nginx ALL=(ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers > /dev/null

# 安装 acme.sh
echo "安装 acme.sh..."
curl https://get.acme.sh | sh -s email=your-email@123.com

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

# 设置 nginx 用户对 acme.sh 文件夹的执行权限
echo "设置 nginx 用户对 acme.sh 文件夹的执行权限..."
setfacl -m u:nginx:x /root/.acme.sh

 # 启动并设置 nginx 和 php-fpm 开机自启动
    echo "设置 nginx 和 php-fpm 开机自启动..."
    systemctl enable nginx
    systemctl enable php-fpm
    


# 设置时区
echo "设置时区"
sudo timedatectl set-timezone Asia/Shanghai
sudo timedatectl set-ntp true


echo "放行所有端口 "
sudo firewall-cmd --zone=public --add-port=1-65535/tcp --permanent
sudo firewall-cmd --zone=public --add-port=1-65535/udp --permanent
sudo firewall-cmd --reload


# 重启 nginx 和 php-fpm
echo "重启 nginx 和 PHP-FPM 服务..."
systemctl restart php7.4-fpm
systemctl restart nginx

# 执行 curl 命令，修复权限
echo "执行 curl 命令 修复权限 ..."
curl -s https://github.com/Lemonflowers/nginx-panel/raw/main/put.sh | sudo bash
