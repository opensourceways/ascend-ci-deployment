# 输入参数
ORGANIZATION="custom-org3"
REPOSITORY="repo1"
INSTALLATION_NAME="linux-arm64-npu-2"


NAMESPACE=${ORGANIZATION}

# 创建namespace
if ! kubectl get namespace "$NAMESPACE" &>/dev/null; then
    kubectl create namespace "$NAMESPACE"
fi

# 部署或者更新pvc, configmap
helm upgrade --install "${INSTALLATION_NAME}-config" -n "${NAMESPACE}" \
    ./${ORGANIZATION}/${REPOSITORY}/${INSTALLATION_NAME}/arc-config \
    -f ./${ORGANIZATION}/${REPOSITORY}/${INSTALLATION_NAME}/values.yaml


# 生成 runner-scale-set values.yaml
helm template \
   ./${ORGANIZATION}/${REPOSITORY}/${INSTALLATION_NAME}/arc \
    -f ./${ORGANIZATION}/${REPOSITORY}/${INSTALLATION_NAME}/values.yaml \
    --show-only templates/runner-scale-set-values.yaml.gotemp > ./runner-scale-set-values.yaml

# 部署 arc
helm upgrade --install "${INSTALLATION_NAME}" -n "${NAMESPACE}"\
    -f ./runner-scale-set-values.yaml \
    oci://ghcr.nju.edu.cn/actions/actions-runner-controller-charts/gha-runner-scale-set --version=0.10.1


