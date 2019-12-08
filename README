1. API-Server有以下几种认证方式
1.1 Https，客户端证书
客户端证书认证叫作TLS双向认证，也就是服务器客户端互相验证证书的正确性，在都正确的情况下协调通信加密方案。

为了使用这个方案，api－server需要用－client－ca－file＝选项来开启。CA_CERTIFICATE_FILE肯定包括一个或者多个认证中心，可以被用来验证呈现给api－server的客户端证书。客户端证书的／CN将作为用户名。

1.2 Token
用token唯一标识请求者，只要apiserver存在该token，则认为认证通过，但是如果需要新增Token，则需要重启kube-apiserver组件，实际效果不是很好。

当在命令行指定- -token-auth-file=SOMEFILE选项时，API服务器从文件中读取 bearer tokens。目前，tokens持续无限期。

令牌文件是一个至少包含3列的csv文件： token, user name, user uid，后跟可选的组名。注意，如果您有多个组，则列必须是双引号，例如：token,user,uid,"group1,group2,group3"

当通过客户端使用 bearer token 认证时，API服务器需要一个值为Bearer THETOKEN的授权头。bearer token必须是，可以放在HTTP请求头中且值不需要转码和引用的一个字符串。例如：如果bearer token是31ada4fd-adec-460c-809a-9e56ceb75269，它将会在HTTP头中按下面的方式呈现：

`Authorization: Bearer 31ada4fd-adec-460c-809a-9e56ceb75269`

1.3 引导token
在v1.6版本中，这个特性还是alpha特性。为了能够在新的集群中使用bootstrapping认证。Kubernetes包括一种动态管理的Bearer(持票人) token，这种token以Secrets的方式存储在kube-system命名空间中，在这个命名空间token可以被动态的管理和创建。Controller Manager有一个管理中心，如果token过期了就会删除。

1.4 Http Base 认证，基于用户名和密码
静态密码的方式是提前在某个文件中保存了用户名和密码的信息，然后在 apiserver 启动的时候通过参数 –basic-auth-file=SOMEFILE 指定文件的路径。apiserver 一旦启动，加载的用户名和密码信息就不会发生改变，任何对源文件的修改必须重启 apiserver 才能生效。

静态密码文件是 CSV 格式的文件，每行对应一个用户的信息，前面三列密码、用户名、用户 ID 是必须的，第四列是可选的组名（如果有多个组，必须用双引号）：

`password,user,uid,"group1,group2,group3"`

客户端在发送请求的时候需要在请求头部添加上 Authorization 字段，对应的值是 Basic BASE64ENCODED(USER:PASSWORD) 。apiserver 解析出客户端提供的用户名和密码，如果和文件中的某一行匹配，就认为认证成功。

1.5 Service Account Tokens 认证
有些情况下，我们希望在 pod 内部访问 apiserver，获取集群的信息，甚至对集群进行改动。针对这种情况，kubernetes 提供了一种特殊的认证方式：Service Account。 Service Account 是面向 namespace 的，每个 namespace 创建的时候，kubernetes 会自动在这个 namespace 下面创建一个默认的 Service Account；并且这个 Service Account 只能访问该 namespace 的资源。Service Account 和 pod、service、deployment 一样是 kubernetes 集群中的一种资源，用户也可以创建自己的 serviceaccount。

ServiceAccount 主要包含了三个内容：namespace、Token 和 CA。namespace 指定了 pod 所在的 namespace，CA 用于验证 apiserver 的证书，token 用作身份验证。它们都通过 mount 的方式保存在 pod 的文件系统中，其中 token 保存的路径是 /var/run/secrets/kubernetes.io/serviceaccount/token ，是 apiserver 通过私钥签发 token 的 base64 编码后的结果； CA 保存的路径是 /var/run/secrets/kubernetes.io/serviceaccount/ca.crt ，namespace 保存的路径是 /var/run/secrets/kubernetes.io/serviceaccount/namespace ，也是用 base64 编码。

如果 token 能够通过认证，那么请求的用户名将被设置为 system:serviceaccount:(NAMESPACE):(SERVICEACCOUNT) ，而请求的组名有两个： system:serviceaccounts 和 system:serviceaccounts:(NAMESPACE)。


2 用户账号和组
2.1 User Account说明
Kubernetes 并不会存储由认证插件从客户端请求中提取出的用户及所属组的信息，它们仅仅用于检验用户是否有权限执行其所请求的操作。

客户端访问API服务的途径通常有三种：kubectl、客户端库或者直接使用 REST接口进行请求。

而可以执行此类请求的主体也被 Kubernetes 分为两类：现实中的“人”和 Pod 对象， 它们的用户身份分别对应于常规用户 (User Account ）和服务账号 （ Service Account） 。

Use Account（用户账号）：一般是指由独立于Kubernetes之外的其他服务管理的用 户账号，例如由管理员分发的密钥、Keystone一类的用户存储（账号库）、甚至是包 含有用户名和密码列表的文件等。Kubernetes中不存在表示此类用户账号的对象， 因此不能被直接添加进 Kubernetes 系统中 。
Service Account（服务账号）：是指由Kubernetes API 管理的账号，用于为Pod 之中的服务进程在访问Kubernetes API时提供身份标识（ identity ） 。Service Account通常要绑定于特定的命名空间，它们由 API Server 创建，或者通过 API 调用于动创建 ，附带着一组存储为Secret的用于访问API Server的凭据。

Kubernetes 有着以下几个内建的用于特殊目的的组 。

system:unauthenticated ：未能通过任何一个授权插件检验的账号，即未通过认证测 试的用户所属的组 。
system :authenticated ：认证成功后的用户自动加入的一个组，用于快捷引用所有正常通过认证的用户账号。
system : serviceaccounts ：当前系统上的所有 Service Account 对象。
system :serviceaccounts :<namespace＞：特定命名空间内所有的 Service Account 对象。

2.2 User Account实验
2.2.1 创建证书
* 创建user私钥
`sh
[root@node-01 ~]# cd /etc/kubernetes/pki/
[root@node-01 pki]# openssl genrsa -out billy.key 2048
`
* 创建证书签署请求
O=组织信息，CN=用户名
`sh
[root@node-01 pki]# openssl req -new -key billy.key -out billy.csr -subj "/O=jbt/CN=billy"
`
* 签署证书
`sh
[root@node-01 pki]# openssl  x509 -req -in billy.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out billy.crt -days 365
Signature ok
subject=/O=jbt/CN=billy
Getting CA Private Key
`
2.2.2 创建配置文件
创建配置文件主要有以下几个步骤：
`sh
kubectl config set-cluster --kubeconfig=/PATH/TO/SOMEFILE      #集群配置
kubectl config set-credentials NAME --kubeconfig=/PATH/TO/SOMEFILE #用户配置
kubectl config set-context    #context配置
kubectl config use-context    #切换context
`
`sh
--embed-certs=true的作用是否在配置文件中显示证书信息。
--kubeconfig=/root/billy.conf用于创建新的配置文件，如果不加此选项,则内容会添加到家目录下.kube/config文件中，可以使用use-context来切换不同的用户管理k8s集群。
context简单的理解就是用什么用户来管理哪个集群，即用户和集群的结
`
`sh
# 创建集群配置
kubectl config set-cluster k8s --server=https://10.31.90.200:8443 --certificate-authority=ca.crt --embed-certs=true --kubeconfig=/root/billy.conf
Cluster "k8s" set.
# 创建用户配置
kubectl config set-credentials billy --client-certificate=billy.crt --client-key=billy.key --embed-certs=true --kubeconfig=/root/billy.conf
User "billy" set.
# 创建context配置
kubectl config set-context billy@k8s --cluster=k8s --user=billy --kubeconfig=/root/billy.conf
Context "billy@k8s" created.
# 切换context
kubectl config use-context billy@k8s --kubeconfig=/root/billy.conf
# 查看配置文件
[root@node-01 pki]# kubectl config view --kubeconfig=/root/bill.conf
`
创建系统用户及k8s验证文件
`sh
[root@node-01 ~]# useradd billy     #创建什么用户名都可以
[root@node-01 ~]# mkdir /home/billy/.kube
[root@node-01 ~]# cp billy.conf /home/billy/.kube/config
[root@node-01 ~]# chown billy.billy -R /home/billy/.kube/
[root@node-01 ~]# su - billy
[billy@node-01 ~]$ kubectl get pod
Error from server (Forbidden): pods is forbidden: User "billy" cannot list resource "pods" in API group "" in the namespace "default"
#默认新用户是没有任何权限的。
`
## kubeconf只是规定了哪个用户访问哪个Kubenetes集群（API Server的VIP），会根据当前家目录的.kube/config配置文件下的user去访问集群，至于user是否有权限取决于RBAC的控制。
创建ClusterRole
`sh
[root@node-01 rbac]# cat cluster-reader.yaml 
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: cluster-reader
rules:
- apiGroups:
  - ""
  resources:
  - pods
  verbs:
  - get
  - list
  - watch
[root@node-01 rbac]# kubectl apply -f cluster-reader.yaml 
clusterrole.rbac.authorization.k8s.io/cluster-reader created
`
创建ClusterRoleBinding
`sh
[root@node-01 rbac]# cat billy-read-all-pods.yaml
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: billy-read-all-pods
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-reader
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: User
  name: billy
 
[root@node-01 rbac]# kubectl apply -f billy-read-all-pods.yaml 
clusterrolebinding.rbac.authorization.k8s.io/billy-read-all-pods created
`
验证结果,创建了ClusterRole和ClusterRoleBinding后就可以看到所有命名空间的pod了。
`sh
[billy@node-01 ~]$ kubectl get pod
NAME                         READY   STATUS    RESTARTS   AGE
nginx-demo-95bd675d5-66xrm   1/1     Running   0          18d
tomcat-5c5dcbc885-7vr68      1/1     Running   0          18d
 
[billy@node-01 ~]$ kubectl -n kube-system get pod
NAME                                        READY   STATUS    RESTARTS   AGE
canal-gd4qn                                 2/2     Running   0          21d
cert-manager-6464494858-wqpnb               1/1     Running   0          18d
coredns-7f65654f74-89x69                    1/1     Running   0          18d
coredns-7f65654f74-bznrl                    1/1     Running   2          54d
`
3. Service Account
至于ServiceAccount怎么授权，其实相对user account来说更简单，只需先创建ServiceAccount，然后创建role或者ClusterRole，最后在RoleBinding或ClusterRoleBinding绑定即可。以下简单做一个示例，就不在显示结果了，大家可以自己去验证。
创建完SA之后系统会自动创建一个secret，我们可以获取这个secret里面的token去登录dashboard，就可以看到相应有权限的资源。
`kubectl get secret billy-sa-token-9rc55 -o jsonpath={.data.token} |base64 -d`

4. 常见错误
unknown container "/system.slice/docker.service"
export KUBELET_EXTRA_ARGS="--runtime-cgroups=/systemd/system.slice --kubelet-cgroups=/systemd/system.slice --fail-swap-on=false"
systemctl restart kubelet

kubelet日志:/var/log/messages,systemctl status kubelet,journalctl -u kubelet --no-page

容器日志:
* kubectl describe pod {pod_name}
* tail -f /var/log/container/{pod_name} 最详细
* docker logs 最详细

kubeadm config print init-defaults > kubeadm-init.yaml

5. etcd的url访问
手动安装在/etc/etcd/ssl下找证书，kubeadm安装在/etc/kubernetes/manifest/etcd.yaml下找启动参数
curl -k --cert /etc/kubernetes/pki/etcd/server.crt --key /etc/kubernetes/pki/etcd/server.key  https://192.168.3.22:2379/version
查看所有key-value
curl -s https://10.0.2.15:2379/v2/keys/?recursive=true -k --cert /etc/kubernetes/pki/etcd/server.crt --key /etc/kubernetes/pki/etcd/server.key

6. apiserver的访问
apiserver的访问只能通过service account的方式
kubectl get sa -o json
export TOKEN=eyJhbGciOiJSUzI1NiIsImtpZCI6IlEyeVBvSVFaM2ZVTTlTaUY0UmFfRzNES2lHTmVzVmcwN1o3bmlxelZzVFUifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJkZWZhdWx0Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZXQubmFtZSI6ImRlZmF1bHQtdG9rZW4tNGRsOGsiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC5uYW1lIjoiZGVmYXVsdCIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6ImFjZDA2YTVhLTA1ODktNGRhMy1hNTg5LTA2Mjk2MmIzMGVjMCIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDpkZWZhdWx0OmRlZmF1bHQifQ.XkD7_O-lm6dqbJBiiAXIn8dNenH_AOpilDk1MW1jrCFvRmkoVhLnSsqSLgUGaSyHOYtzLJeJyjQ-AqiFtzrRnUPHRJNgVJndUNuW7eP_kWXSHK4A6_v5Nz0U4ndWT4e0uubbcbCtQ1sCC8uESCfAj3zTFrzxcTfVkD5Ztir6sdpvWfovT44vy63hqCYMC5X_lr-QRV-wyBSoLz2PHZNf3T3i8c4KoH7VeFsq-XJtM3KeGa1L-_M4aYGGVjR7QBTyaTN2DeRXi-C63MWTiEkKIf6bQV27FMkwJhNDfgWJYtTNKNIEpcr5aNAc7ZsrRNzrnh5oZfptT_gXWdMuNOmG1A
curl -s https://apiserver.demo:6443/openapi/v2  --header "Authorization: Bearer $TOKEN" --cacert /etc/kubernetes/pki/ca.crt | less

7. kubeadm的安装
kubeadm init --api-advertise-addresses=10.8.78.31 --external-etcd-endpoints=http://10.8.125.29:2379,http://10.8.104.16:2379,http://10.8.37.18:237
参数说明
·sh
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
·

