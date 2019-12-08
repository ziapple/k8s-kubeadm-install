#!/bin/bash

# 只在 master 节点执行

# 查看完整配置选项 https://godoc.org/k8s.io/kubernetes/cmd/kubeadm/app/apis/kubeadm/v1beta2
rm -f ./kubeadm-config.yaml
cat <<EOF > ./kubeadm-config.yaml
apiVersion: kubeadm.k8s.io/v1beta2
kind: ClusterConfiguration
kubernetesVersion: v1.16.0
imageRepository: registry.cn-hangzhou.aliyuncs.com/google_containers
controlPlaneEndpoint: "apiserver.demo:6443"
networking:
  serviceSubnet: "10.96.0.0/16"
  podSubnet: "10.244.0.0/16"
  dnsDomain: "cluster.local"
EOF

# kubeadm init
# 根据您服务器网速的情况，您需要等候 3 - 10 分钟
# kubeadm init --config=kubeadm-config.yaml --upload-certs
kubeadm init --apiserver-advertise-address=192.168.3.22 \
 --pod-network-cidr=10.244.0.0/16 \
 --service-cidr=10.96.0.0/16 \
 --kubernetes-version=v1.16.0 \
 --image-repository=registry.cn-hangzhou.aliyuncs.com/google_containers 

# 配置 kubectl
rm -rf /root/.kube/
mkdir /root/.kube/
cp -i /etc/kubernetes/admin.conf /root/.kube/config

# 安装 calico 网络插件
# 参考文档 https://docs.projectcalico.org/v3.8/getting-started/kubernetes/
# rm -f calico.yaml
# wget https://docs.projectcalico.org/v3.8/manifests/calico.yaml
# sed -i "s#192\.168\.0\.0/16#${POD_SUBNET}#" calico.yaml
# kubectl apply -f calico.yaml

echo -e "\033[31;1m请确保您正在使用 https://kuboard.cn/install/install-k8s.html 上的最新K8S安装文档，并加入了在线答疑QQ群，以避免碰到问题时无人解答\033[0m"
