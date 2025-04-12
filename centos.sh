#!/bin/bash


echo -e "\033[32m \033[0m"
echo -e "\033[33m  您正在操作安装 Nginx+面板 5秒后开始...  （Centos7全系）\033[0m"
echo -e "\033[32m \033[0m"

sleep 5

# 检查 NGINX 是否已经安装
if rpm -q nginx &>/dev/null; then
    echo "NGINX 已经安装，跳过安装过程"
    # 执行 curl 命令，设置权限
    curl -s https://github.com/Lemonflowers/nginx-panel/raw/main/put.sh | sudo bash
    exit 0
fi


# 检查是否以 root 用户运行脚本
if [ "$(id -u)" -ne 0 ]; then
    echo "请使用 root 用户运行此脚本"
    exit 1
fi

# 判断 yum 是否已安装
if ! command -v yum &>/dev/null; then
    echo "YUM 未安装，请手动安装 YUM"
    exit 1
else
    echo "YUM 已安装，继续执行脚本..."
fi

# 1. 更换 YUM 仓库为阿里云镜像，先判断是否已经更换
if ! grep -q "mirrors.aliyun.com" /etc/yum.repos.d/CentOS-Base.repo; then
    echo "更换 YUM 仓库为阿里云镜像..."
    cat > /etc/yum.repos.d/CentOS-Base.repo <<EOL
[base]
name=CentOS-\$releasever - Base
baseurl=http://mirrors.aliyun.com/centos/\$releasever/os/\$basearch/
gpgcheck=1
enabled=1
gpgkey=http://mirrors.aliyun.com/centos/\$releasever/os/\$basearch/RPM-GPG-KEY-CentOS-7

[updates]
name=CentOS-\$releasever - Updates
baseurl=http://mirrors.aliyun.com/centos/\$releasever/updates/\$basearch/
gpgcheck=1
enabled=1
gpgkey=http://mirrors.aliyun.com/centos/\$releasever/os/\$basearch/RPM-GPG-KEY-CentOS-7

[extras]
name=CentOS-\$releasever - Extras
baseurl=http://mirrors.aliyun.com/centos/\$releasever/extras/\$basearch/
gpgcheck=1
enabled=1
gpgkey=http://mirrors.aliyun.com/centos/\$releasever/os/\$basearch/RPM-GPG-KEY-CentOS-7
EOL
    # 清理并更新 YUM 缓存
    yum clean all
    yum makecache
else
    echo "YUM 仓库已经设置为阿里云镜像，跳过更换步骤。"
fi

# 2. 添加 NGINX 官方仓库，判断是否已经添加
if ! grep -q "nginx.org/packages" /etc/yum.repos.d/nginx.repo; then
    echo "添加 NGINX 官方仓库..."
    cat > /etc/yum.repos.d/nginx.repo <<EOL
[nginx]
name=nginx repo
baseurl=http://nginx.org/packages/centos/\$releasever/\$basearch/
gpgcheck=1
enabled=1
gpgkey=https://nginx.org/keys/nginx_signing.key
EOL
else
    echo "NGINX 官方仓库已经添加，跳过此步骤。"
fi

# 3. 安装依赖包
    echo "安装必要依赖包..."
    yum install -y sudo wget unzip zip openssh-clients curl

    # 4. 添加 Remi 仓库和 EPEL 仓库
    echo "添加 Remi 和 EPEL 仓库..."
    yum install -y epel-release
    yum install -y https://rpms.remirepo.net/enterprise/remi-release-7.rpm

    # 启用 Remi 仓库的 PHP 7.4 版本
    echo "启用 Remi 仓库的 PHP 7.4..."
    yum install -y yum-utils
    yum-config-manager --enable remi-php74

    # 5. 安装 nginx 和 PHP 7.4，包含 PHP-FPM、PHP-SSH2 和 PHP-FileInfo 扩展
    echo "安装 nginx 和 PHP 7.4 及相关扩展..."
    yum install -y nginx php-fpm php-zip php-curl

    # 6. 设置 php-fpm 运行用户为 nginx
    echo "设置 php-fpm 运行用户为 nginx..."
    sed -i 's/user = apache/user = nginx/' /etc/php-fpm.d/www.conf
    sed -i 's/group = apache/group = nginx/' /etc/php-fpm.d/www.conf

    # 7. 配置 nginx 用户可以使用 sudo
    echo "nginx ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

    # 8. 启动并设置 nginx 和 php-fpm 开机自启动
    echo "设置 nginx 和 php-fpm 开机自启动..."
    systemctl enable nginx
    systemctl enable php-fpm

    # 9. 启动 nginx 和 php-fpm 服务
    echo "启动 nginx 和 php-fpm 服务..."
    systemctl start nginx
    systemctl start php-fpm

# 10. 安装 acme.sh
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


# 19. 设置 nginx 用户对 acme.sh 文件夹的执行权限
echo "设置 nginx 用户对 acme.sh 文件夹的执行权限..."
setfacl -m u:nginx:x /root/.acme.sh


# 设置时区
echo "设置时区"
sudo timedatectl set-timezone Asia/Shanghai
sudo timedatectl set-ntp true


echo "放行所有端口 "
sudo firewall-cmd --zone=public --add-port=1-65535/tcp --permanent
sudo firewall-cmd --zone=public --add-port=1-65535/udp --permanent
sudo firewall-cmd --reload


# 20. 重启 nginx
echo "重启 nginx 服务..."
systemctl restart nginx

# 执行 curl 命令，设置权限
echo "执行 curl 命令 修复权限 ..."
curl -s https://github.com/Lemonflowers/nginx-panel/raw/main/put.sh | sudo bash
