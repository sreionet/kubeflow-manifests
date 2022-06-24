#!/bin/bash
G=`tput setaf 2`
C=`tput setaf 6`
Y=`tput setaf 3`
Q=`tput sgr0`

echo -e "${C}\n\n镜像下载脚本:${Q}"
echo -e "${C}pull_images.sh将读取images.txt中的镜像\n\n${Q}"

# 清理本地已有镜像
# echo "${C}start: 清理镜像${Q}"
# for rm_image in $(cat images.txt)
# do 
#  docker rmi $aliNexus$rm_image
# done
# echo -e "${C}end: 清理完成\n\n${Q}"

# pull
echo "${C}start: 开始拉取镜像...${Q}"
for pull_image in $(cat images.txt | grep -E 'gcr.io|quay.io|public.ecr.aws')
do    
  echo "${Y}    开始拉取$pull_image...${Q}"
  fileName=${pull_image//:/_}
  docker pull $pull_image
  if [[ $? != 0 ]]; then
    echo -e "\033[31m $pull_image \033[0m"
  fi
done
echo "${C}end: 镜像拉取完成...${Q}"

# push镜像
for image in  $(cat images.txt | grep -E 'gcr.io|quay.io|public.ecr.aws')
do
    echo "${Y}    开始推送$image...${Q}"
    registry_image_name=$(echo $image  | sed 's/\//./g'| sed 's#gcr.io.#registry.cn-hangzhou.aliyuncs.com/seam-kubeflow/#g;s#quay.io.#registry.cn-hangzhou.aliyuncs.com/seam-kubeflow/#g;s#public.ecr.aws.#registry.cn-hangzhou.aliyuncs.com/seam-kubeflow/#g')
    if [[ $registry_image_name =~ "sha256" ]];then
      # $(echo gcr.io/knative-releases/knative.dev/serving/cmd/queue@sha256:0b8e031170354950f3395876961452af1c62f7ab5161c9e71867392c11881962 | sed 's/@sha256.*//g'):$( date +"%Y%m%d")
      registry_image_name=$(echo $registry_image_name | sed 's/@sha256.*//g'):$( date +"%Y%m%d")
    fi
    docker tag $image $registry_image_name
    docker push $registry_image_name
done
echo -e "${C}end: push完成\n\n${Q}"


# push镜像
for image in  $(cat images.txt | grep -E 'gcr.io|quay.io|public.ecr.aws')
do
    echo "${Y}    开始推送$image...${Q}"
    registry_image_name=$(echo $image  | sed 's/\//./g'| sed 's#gcr.io.#registry.cn-hangzhou.aliyuncs.com/seam-kubeflow/#g;s#quay.io.#registry.cn-hangzhou.aliyuncs.com/seam-kubeflow/#g;s#public.ecr.aws.#registry.cn-hangzhou.aliyuncs.com/seam-kubeflow/#g')
    if [[ $registry_image_name =~ "sha256" ]];then
      # $(echo gcr.io/knative-releases/knative.dev/serving/cmd/queue@sha256:0b8e031170354950f3395876961452af1c62f7ab5161c9e71867392c11881962 | sed 's/@sha256.*//g'):$( date +"%Y%m%d")
      registry_image_name=$(echo $registry_image_name | sed 's/@sha256.*//g'):$( date +"%Y%m%d")
    fi
    echo -e "  - name: $image
    newName: $(echo $registry_image_name| awk -F ':' '{print $1}')
    newTag: $(echo $registry_image_name| awk -F ':' '{print $2}')" >> test.yaml
done
echo -e "${C}end: push完成\n\n${Q}"