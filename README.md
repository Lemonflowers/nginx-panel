
V1.40 完结 （将无持续更新）如有Bug,请与我反馈提供支持哦！
<per>
基于 yum apt dnf 安装的nginx开源 反向面板
反向代理 集成 HTTP2 WS GZIP 自定义缓存
四层转发 支持TCP/UDP
系统监控 实时宽带 累计流量 实时CPU 实时内存 实时磁盘
ACME集成 支持域名签证 域名自动续签
cloudfare 集成 支持DNS 全局API管理
图床模块 内置图床应用 开箱即用
日志管理
日志分析（基于PHP）
缓存管理 （文件）
5秒盾 （请求频率）
IP拉黑 全局模式
防跨站 （SSL）

centos7.6-7.9
curl -fsSL https://github.com/Lemonflowers/nginx-panel/raw/main/centos.sh | sudo bash

Debian（全系兼容）
curl -fsSL https://github.com/Lemonflowers/nginx-panel/raw/main/debian.sh | sudo bash

AlmaLinux（全系兼容）
curl -fsSL https://github.com/Lemonflowers/nginx-panel/raw/main/AlmaLinux.sh | sudo bash

登录地址为: http://服务器IP:8809
管理员账号和密码： admin/123456
安装完成 请安装SSH输出提示.手动补充 acme.sh的 命令

服务器配置要求
1H256M 5G HDD 

服务器要求端口  80,443  默认初次监听 8899为管理端口  
</per>





