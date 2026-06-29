#
# Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

set -ex

echo "gradlew param is $*"

if [ $1 == "clean" ];then
   echo "do nothing"
   exit 0
else
   DT_TASK_FLAG=$2
   echo "DT_TASK_FLAG is ${DT_TASK_FLAG}"
fi

echo "old NODE_HOME is ${NODE_HOME}"

# NODE_HOME的环境变量多配置了一个bin目录, 在这里去除掉
[[ "${NODE_HOME}" =~ .*\bin$ ]] && NODE_HOME=${NODE_HOME%\bin*}
echo "new NODE_HOME is ${NODE_HOME}"
echo "HM_SDK_HOME is ${HM_SDK_HOME}"
echo "OHOS_SDK_HOME is ${OHOS_SDK_HOME}"
echo "OHOS_BASE_SDK_HOME is ${OHOS_BASE_SDK_HOME}"

node -v
npm -v

# 初始化相关路径
APP_HOME="`pwd -P`"
TOOLS_INSTALL_DIR=${APP_HOME}

# 获得签名jar文件
cd ${APP_HOME}/hw_sign
chmod +x build.sh
./build.sh

# Setup npm
npm config set registry 
npm config set @ohos:registry 
npm config set strict-ssl false

# 安装ohpm, 若镜像中已存在ohpm，则无需重新安装
function init_ohpm
{
    # 下载
    cd ${TOOLS_INSTALL_DIR}
    commandlineVersion=2.3.1.0
    wget --no-check-certificate -q /artifactory/sz-software-release/devecomanagercloud/release/PackageManagerCLI/1.8.0/ohpm.zip
    unzip -oq ohpm.zip -d ohpm

    # 初始化
    OHPM_HOME=${TOOLS_INSTALL_DIR}/ohpm
    ${OHPM_HOME}/bin/init
    export PATH=${OHPM_HOME}/bin:${PATH}
    ohpm -v

    ohpm config set log_level debug

    # 配置仓库地址
    ohpm config set registry /artifactory/api/npm/product_npm/,/artifactory/api/npm/npm-central-repo/,/artifactory/api/ohpm/ohpm-center/,/artifactory/api/ohpm/product_ohpm/
    ohpm config set /artifactory/api/ohpm/product_ohpm/:_auth ""
    ohpm config set strict_ssl false
}

# 进入package目录安装依赖
function ohpm_install
{
    cd $1
    ohpm -v
    ohpm install
}

# 环境适配
function build() {
    # 根据业务情况适配local.properties
    cd ${APP_HOME}
    echo "sdk.dir=${HM_SDK_HOME}"  > ./local.properties
    echo "nodejs.dir=${NODE_HOME}" >> ./local.properties

    # 根据业务情况安装ohpm三方库依赖
    ohpm_install "$APP_HOME"
    ohpm_install "$APP_HOME/common"
    ohpm_install "$APP_HOME/native"
    ohpm_install "$APP_HOME/feature/uikit"
    ohpm_install "$APP_HOME/feature/datetime"
    ohpm_install "$APP_HOME/feature/display"
    ohpm_install "$APP_HOME/feature/wifi"
    ohpm_install "$APP_HOME/feature/bluetooth"
    ohpm_install "$APP_HOME/feature/application"
    ohpm_install "$APP_HOME/feature/cloneapps"
    ohpm_install "$APP_HOME/feature/storage"
    ohpm_install "$APP_HOME/feature/privacy"
    ohpm_install "$APP_HOME/feature/developeroptions"
    ohpm_install "$APP_HOME/feature/reset"
    ohpm_install "$APP_HOME/feature/users"
    ohpm_install "$APP_HOME/feature/language"
    ohpm_install "$APP_HOME/feature/moreconnection"
    ohpm_install "$APP_HOME/feature/nearlink"
    ohpm_install "$APP_HOME/feature/notDisturb"
    ohpm_install "$APP_HOME/feature/aboutdevice"
    ohpm_install "$APP_HOME/feature/search"
    ohpm_install "$APP_HOME/feature/accessibility"
    ohpm_install "$APP_HOME/feature/systemUpdate"
    ohpm_install "$APP_HOME/feature/theme"
    ohpm_install "$APP_HOME/product/pc"
    ohpm_install "$APP_HOME/product/phone"
    cat ${HOME}/.npmrc | grep 'lockfile=false' || echo 'lockfile=false' >> ${HOME}/.npmrc


    # 根据业务情况，采用对应的构建命令，可以参考IDE构建日志中的命令
    cd ${APP_HOME}
    chmod +x hvigorw

    if [ "${DT_TASK_FLAG}" == "wearable" ];then
        ./hvigorw --mode module -p module=wearable_settings -p debuggable=false -p ohos-test-coverage=true -p buildMode=test assembleHap --parallel --incremental --no-daemon
        ./hvigorw --mode module -p module=wearable_settings@ohosTest -p debuggable=false -p ohos-test-coverage=true assembleHap packageTesting --no-daemon

        echo "-----------------handle DTPipeline.zip--------------------"
            hasPackageDTPipeline=0
            if [ -e "build/DTPipeline.zip" ];then
              file_size=$(stat -c%s filename)
              if [ $file_size -gt 0 ]; then
                echo "DTPipeline.zip is normal"
              else
                hasPackageDTPipeline=1
                rm -rf build/DTPipeline.zip
                echo "DTPipeline.zip size is 0"
              fi
            else
              hasPackageDTPipeline=1
              echo "build/DTPipeline.zip is not exist"
            fi
            if [ $hasPackageDTPipeline -eq 1 ];then
              pushd build/outputs
              if [ $? -ne 0 ];then
                     echo "build/outputs is not exist"
                     exit 1
              fi
              zip -r ../DTPipeline.zip ./*
              popd
            fi
        echo "After assembleHap packageTesting!"
    fi
    if [ "${DT_TASK_FLAG}" == "tv" ];then
		./hvigorw --mode module -p module=tv_settings -p debuggable=false -p ohos-test-coverage=true -p buildMode=test assembleHap --parallel --incremental --no-daemon
        ./hvigorw --mode module -p module=tv_settings@ohosTest -p debuggable=false -p ohos-test-coverage=true assembleHap packageTesting --no-daemon
 
        echo "-----------------handle DTPipeline.zip--------------------"
        	hasPackageDTPipeline=0
        	if [ -e "build/DTPipeline.zip" ];then
        	  file_size=$(stat -c%s build/DTPipeline.zip)
        	  if [ $file_size -gt 0 ]; then
        	    echo "DTPipeline.zip is normal"
        	  else
        	    hasPackageDTPipeline=1
        	    rm -rf build/DTPipeline.zip
        	    echo "DTPipeline.zip size is 0"
        	  fi
        	else
        	  hasPackageDTPipeline=1
        	  echo "build/DTPipeline.zip is not exist"
        	fi
        	if [ $hasPackageDTPipeline -eq 1 ];then
        	  pushd build/outputs
        	  if [ $? -ne 0 ];then
        	         echo "build/outputs is not exist"
        	         exit 1
        	  fi
        	  zip -r ../DTPipeline.zip ./*
        	  popd
        	fi
        echo "After assembleHap packageTesting!"
    fi
    if [ "${DT_TASK_FLAG}" == "dt_task" ];then
		./hvigorw --mode module -p module=phone_settings -p debuggable=false -p ohos-test-coverage=true -p buildMode=test assembleHap --parallel --incremental --no-daemon
        ./hvigorw --mode module -p module=phone_settings@ohosTest -p debuggable=false -p ohos-test-coverage=true assembleHap packageTesting --no-daemon

        echo "-----------------handle DTPipeline.zip--------------------"
        	hasPackageDTPipeline=0
        	if [ -e "build/DTPipeline.zip" ];then
        	  file_size=$(stat -c%s filename)
        	  if [ $file_size -gt 0 ]; then
        	    echo "DTPipeline.zip is normal"
        	  else
        	    hasPackageDTPipeline=1
        	    rm -rf build/DTPipeline.zip
        	    echo "DTPipeline.zip size is 0"
        	  fi
        	else
        	  hasPackageDTPipeline=1
        	  echo "build/DTPipeline.zip is not exist"
        	fi
        	if [ $hasPackageDTPipeline -eq 1 ];then
        	  pushd build/outputs
        	  if [ $? -ne 0 ];then
        	         echo "build/outputs is not exist"
        	         exit 1
        	  fi
        	  zip -r ../DTPipeline.zip ./*
        	  popd
        	fi
        echo "After assembleHap packageTesting!"
    fi

    ./hvigorw  assembleHap --mode module -p product=default -p debuggable=false



}

function main {
  local startTime=$(date '+%s')

  init_ohpm
  build

  local endTime=$(date '+%s')
  local elapsedTime=$(expr $endTime - $startTime)
  echo "build success in ${elapsedTime}s..."
}

main