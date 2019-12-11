---
感谢kubboard提供的素材,[原文地址](https://www.kubernetes.org.cn/5846.html)，
本文主要通过kubeadm安装用于个人或公司内部测试和开发环境，生产环境部署详见github另一篇k8s-ansible的ha部署

# 环境准备
通过virtualbox虚拟化两台centos机器，网络采用nat+netbridge方式，其中nat网口10.0.2.15/16,bridge网口192.168.3.22/16

***注意，k8s的网络集群配置一定要以birdge的网口为准，即192.168开头的，一般网口为enp0s8，nat无法实现集群互访***

- 192.168.3.22 master
- 192.168.3.23 node1

请确保：

- 我的任意节点 centos 版本在兼容列表中
- 我的任意节点 hostname 不是 localhost
- 我的任意节点 CPU 内核数量大于等于 2

# kubeadm的参数
kubeadm init 主要参数说明：
```sh
--apiserver-advertise-address string   设置 apiserver 绑定的 IP.
--apiserver-bind-port int32            设置apiserver 监听的端口. (默认 6443)
--apiserver-cert-extra-sans strings    api证书中指定额外的Subject Alternative Names (SANs) 可以是IP 也可以是DNS名称。 证书是和SAN绑定的。
--cert-dir string                      证书存放的目录 (默认 "/etc/kubernetes/pki")
--certificate-key string               kubeadm-cert secret 中 用于加密 control-plane 证书的key
--config string                        kubeadm 配置文件的路径.
--cri-socket string                    CRI socket 文件路径，如果为空 kubeadm 将自动发现相关的socket文件; 只有当机器中存在多个 CRI  socket 或者 存在非标准 CRI socket 时才指定.
--dry-run                              测试，并不真正执行;输出运行后的结果.
--feature-gates string                 指定启用哪些额外的feature 使用 key=value 对的形式。
-h, --help                                 帮助文档
--ignore-preflight-errors strings      忽略前置检查错误，被忽略的错误将被显示为警告. 例子: 'IsPrivilegedUser,Swap'. Value 'all' ignores errors from all checks.
--image-repository string              选择拉取 control plane images 的镜像repo (default "k8s.gcr.io")
--kubernetes-version string            选择K8S版本. (default "stable-1")
--node-name string                     指定node的名称，默认使用 node 的 hostname.
--pod-network-cidr string              指定 pod 的网络， control plane 会自动将 网络发布到其他节点的node，让其上启动的容器使用此网络
--service-cidr string                  指定service 的IP 范围. (default "10.96.0.0/12")
--service-dns-domain string            指定 service 的 dns 后缀, e.g. "myorg.internal". (default "cluster.local")
--skip-certificate-key-print           不打印 control-plane 用于加密证书的key.
--skip-phases strings                  跳过指定的阶段（phase）
--skip-token-print                     不打印 kubeadm init 生成的 default bootstrap token 
--token string                         指定 node 和control plane 之间，建立双向认证的token ，格式为 [a-z0-9]{6}\.[a-z0-9]{16} - e.g. abcdef.0123456789abcdef
--token-ttl duration                   token 自动删除的时间间隔。 (e.g. 1s, 2m, 3h). 如果设置为 '0', token 永不过期 (default 24h0m0s)
--upload-certs                         上传 control-plane 证书到 kubeadm-certs Secret
```
还有一种方式采用config配置文件的方式，详见kubeadm-init.yaml，完整配置可以[查看这里](https://godoc.org/k8s.io/kubernetes/cmd/kubeadm/app/apis/kubeadm/v1beta2)，
这里采用的是args参数方式，两者是一样的。

# 在master和node节点上安装kubelet
使用 root 身份在所有节点执行如下
```sh
sh install-kubelet.sh
```

# 初始化 master 节点
- 以 root 身份在 master 机器上执行
- 初始化 master 节点时，如果因为中间某些步骤的配置出错，想要重新初始化 master 节点，请先执行 kubeadm reset 操作
- POD_SUBNET 所使用的网段不能与 master节点/worker节点 所在的网段重叠。该字段的取值为一个 CIDR 值，如果您对 CIDR 这个概念还不熟悉，请不要修改这个字段的取值

```sh
sh init-master.sh
```

检查 master 初始化结果
```
# 只在 master 节点执行

# 执行如下命令，等待 3-10 分钟，直到所有的容器组处于 Running 状态
watch kubectl get pod -n kube-system -o wide

# 查看 master 节点初始化结果
kubectl get nodes -o wide
```

# 初始化 node 节点
根据master提示,直接`kubeadm join`
```sh
# 只在 master 节点执行
kubeadm token create --print-join-command

# kubeadm token create 命令的输出
kubeadm join 192.168.3.22:6443 --token ** --discovery-token-ca-cert-hash **
```

