## GoAgentX v1.3.33

* [MOD] 更新 goagent，修正可能的运行问题

*Released on 2013.09.10*

## GoAgentX v1.3.32

* [NEW] 更新 goagent 到 3.0.5
* [MOD] 禁用 goagent 自带 PAC 服务，防止可能的端口占用问题

*Released on 2013.08.22*

## GoAgentX v1.3.30

* [NEW] 更新 goagent 到 3.0.3

*Released on 2013.08.13*

## GoAgentX v1.3.29

* [FIX] 修正混淆 SSH 不能使用的问题
* [MOD] 修改 shadowsocks 加密方式的设置方式为下拉框

*Released on 2013.06.03*

## GoAgentX v1.3.28

* [NEW] 添加 obfuscate-ssh 支持
* [NEW] 更新 goagent 到 3.0.1，goagent-server 到 2.1.18
* [NEW] 更新 shadowsocks-libev 到 1.3
* [FIX] 修正 SSH 及 shadowsocks 不支持远程 DNS 的问题

*Released on 2013.05.28*

## GoAgentX v1.3.26

* [NEW] New English translation
* [NEW] 使用 [libev 版本 shadowsocks](https://github.com/madeye/shadowsocks-libev)
* [NEW] shadowsocks 增加 rc4 加密选项

*Released on 2013.05.11*

## GoAgentX v1.3.24

* [FIX] 修正 stunnel 在 10.8 下运行的问题

*Released on 2013.05.06*

## GoAgentX v1.3.20

* [NEW] 更新 stunnel 到 4.56
* [NEW] 更新对分享 PAC 到局域网的支持（请参考[《分享服务给局域网其他设备》](https://github.com/ohdarling/GoAgentX/wiki/Share-Services-to-Local-Network)）

*Released on 2013.05.04*

## GoAgentX v1.3.19

* [NEW] 更新 goagent 到 2.1.17
* [NEW] 添加 goagent 混淆选项设置
* [FIX] 修正 .python-egg-cache 可能导致 goagent 无法启动的问题
* [FIX] 修正由于 PAC 地址解决导致 GoAgentX 崩溃的问题
* [FIX] 回滚 goagent-server 部署脚本，修正可能部署失败的问题
* [FIX] 修正 goagent-server 密码设置可能无效的问题
* [MOD] 修改默认连接方式为 HK 和 HTTPS

*Released on 2013.05.01*

## GoAgentX v1.3.18

* [NEW] 更新 goagent 到 2.1.15
* [NEW] 更新 shadowsocks 到 1.0
* [NEW] 添加 goagent 和 shadowsocks 更新服务
* [NEW] goagent 添加“分享到局域网”选项，选中后同一局域网用户可以设置代理为本机局域网 IP 和 goagent 的端口
* [FIX] 修正 shadowsocks 对 IPv6 服务端地址的支持

*Released on 2013.04.14*

## GoAgnetX v1.3.14

* [NEW] 添加 Apple Script 操作支持

*Released on 2013.03.10*

## GoAgentX v1.3.13

* [NEW] 更新 goagent 到 1.3.13
* [NEW] 更新 shadowsocks 到 0.9.4

*Released on 2013.03.06*

## GoAgentX v1.3.12

* [FIX] 修正退出程序时会修改代理设置的问题
* [NEW] 修正系统对本地 PAC 文件支持不好的问题，现在可以直接在代理设置标签页选择本地 PAC 文件（需要选中使用自定义 PAC 地址）

*Released on 2012.12.06*

## GoAgentX v1.3.11

* [NEW] 使用 Reachability 监测网络状态来修正 SSH 服务的稳定性
* [MOD] 服务状态改变通知在 5 秒后自动隐藏
* [FIX] 修正第一次运行时选中的服务不正确的问题
* [FIX] 修正第一次运行时代理设置选项错误的问题
* [FIX] 修正使用菜单切换服务不会保存最后一次使用服务的问题
* [FIX] 修正 goagent 在 Mac OS X 10.8 下会出现 SSLError 的问题
* [FIX] 修正 stunnel 在 Mac OS X 10.8 下无法运行的问题
* [FIX] 修正 Mac OS X 10.8 下切换服务时会重新要求权限验证的问题

*Released on 2012.12.05*

## GoAgentX v1.3.10

* [NEW] 更新 goagent 到 2.1.9-11
* [NEW] 新增 shaodowsocks 支持
* [NEW] 在“其他设置”中新增“服务状态改变通知”设置

*Released on 2012.11.16*


## GoAgentX v1.3.9

* [NEW] 更新 goagent 到 2.1.7
* [NEW] 菜单栏图标增加服务停止时的指示图标

*Released on 2012.11.09*

## GoAgentX v1.3.8

* [NEW] 更新 goagent 到 2.1.5
* [NEW] 其他设置中添加“GoAgentX 窗口总是置顶”选项

*Released on 2012.11.2*


## GoAgnetX v1.3.7

* [NEW] SSH 服务允许非本机使用
* [NEW] 更新 goagent 到 2.1.3

*Released on 2012.10.27*

## GoAgnetX v1.3.6

* [MOD] 更新 goagent 到 2.0.4，修正 CN 服务器无法连接的问题

*Released on 2012.10.22*

## GoAgnetX v1.3.5

* [NEW] 更新 goagent 到 2.0.13，请注意一定需要重新部署服务端
* [NEW] 在代理设置标签中显示当前内置 PAC 服务地址
* [NEW] goagent 和 SSH 支持断线后自动重连
* [FIX] 修正应用 PAC 域名列表时会修改代理设置的问题

*Released on 2012.10.09*

## GoAgentX v1.3.3

* [NEW] 更新 goagent 到 2.0.2，请注意一定需要重新部署服务端
* [NEW] 增加 PHP Fetch 支持
* [NEW] 增加自定义 PAC 域名列表立即应用按钮
* [NEW] 增加指定自定义 GoAgentX PAC 服务端口功能，可以通过此功能避免 GoAgentX 随系统启动时要求输入密码的问题
* [NEW] Retina Display 支持
* [FIX] 修正自定义 PAC 域名列表导致任意网站都会使用代理的问题
* [MOD] 在切换服务菜单中隐藏 goagent 服务端部署
* [MOD] 移除 goagent golang 服务端部署

*Released on 2012.08.26*

## GoAgentX v1.3.2

* [NEW] SSH 服务支持指定私钥
* [FIX] 修正在 Mountain Lion 下反复要求提权的问题

此版本由 [qqshfox](https://github.com/qqshfox) 贡献。

*Released on 2012.08.21*

## GoAgentX v1.3.0

* [NEW] 支持自定义 PAC 域名列表
* [NEW] 支持部署 golang 版本 goagent 服务端
* [NEW] 添加导入 goagent 根证书功能
* [MOD] 更新 goagent 到 1.8.11
* [MOD] 更新 west-chamber 到 2012.07.09
* [MOD] 调整代理切换界面

*Released on 2012.07.10*

## GoAgentX v1.2.0

* [NEW] 集成 SSH 服务
* [NEW] 集成 stunnel 服务
* [NEW] 添加菜单栏图标切换服务功能
* [NEW] 添加菜单栏图标切换使用 PAC 和不使用 PAC 功能
* [FIX] 修正自动切换 PAC 时在 Safari 下不工作的 bug
* [FIX] 修正不使用 PAC 时没有设置 HTTPS 代理的 bug
* [FIX] 修正停止服务时，没有恢复代理设置为原始设置的 bug
* [MOD] 更新 goagent 到 1.8.5 稳定版
* [MOD] 更新西厢第3季到 20120505

*Released on 2012.05.07*

## GoAgentX v1.1.0

* [NEW] 集成 goagent 1.8.4，不再需要单独下载
* [NEW] 集成 west-chamber-season-3 20120428
* [NEW] 集成 PAC 支持

*Released on 2012.04.28*


## GoAgentX v1.0.5

* [NEW] 兼容 goagent 1.8.3
* [NEW] 添加自动更新支持
* [NEW] 增加 PPPoE 拨号的 PAC 自动设置支持
* [NEW] 支持自定义 PAC 地址

*Released on 2012.04.20*

## GoAgentX v1.0.4

* [NEW] 增加对 goagent v1.8.0 稳定版的兼容
* [NEW] 增加自动设置系统代理为 PAC 的选项
* [NEW] 增加 CRLF Injection 设置的选项
* [FIX] 修正自动设置代理时，以太网连接的代理可能没有正确设置的问题

*Released on 2012.04.07*

## GoAgentX v1.0.3

* [NEW] 增加 GoAgentX 启动时自动设置系统代理的功能

*Released on 2012.04.05*

## GoAgentX v1.0.2

* [NEW] 增加直接程序内设置 GoAgnetX 随用户登录启动功能

*Released on 2012.02.19*

## GoAgentX v1.0.1

* [FIX] 安装 goagent 总是失败

*Released on 2012.02.16*

## GoAgentX v1.0

* 首次发布

*Released on 2012.02.15*
