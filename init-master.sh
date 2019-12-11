#!/bin/bash

# 只在 master 节点执行
# 根据您服务器网速的情况，您需要等候 3 - 10 分钟
# kubeadm init --config=kubeadm-config.yaml --upload-certs
kubeadm init --apiserver-advertise-address=192.168.3.22 \
 --pod-network-cidr=10.244.0.0/16 \
 --service-cidr=10.96.0.0/16 \
 --kubernetes-version=v1.16.0 \
 --image-repository=registry.cn-hangzhou.aliyuncs.com/google_containers 
 --upload-certs

# 配置 kubectl
rm -rf /root/.kube/
mkdir /root/.kube/
cp -i /etc/kubernetes/admin.conf /root/.kube/config

# 安装 calico 网络插件
# 参考文档 https://docs.projectcalico.org/v3.8/getting-started/kubernetes/
rm -f calico.yaml
wget https://docs.projectcalico.org/v3.8/manifests/calico.yaml
sed -i "s#192\.168\.0\.0/16#10\.244\.0\.0#" calico.yaml
kubectl apply -f calico.yaml

# 安装flannel插件
# kubectl apply -f kube-flannel.yaml

echo -e "完成master安装！"
