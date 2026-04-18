#!/bin/bash
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

echo "old NODE_HOME is ${NODE_HOME}"

if [ $1 == "clean" ];then
   echo "do nothing"
   exit 0
else
   DT_TASK_FLAG=$2
   echo "DT_TASK_FLAG is ${DT_TASK_FLAG}"
fi

# NODE_HOME的环境变量多配置了一个bin目录, 在这里去除掉
[[ "${NODE_HOME}" =~ .*\bin$ ]] && NODE_HOME=${NODE_HOME%\bin*}
echo "new NODE_HOME is ${NODE_HOME}"
echo "HM_SDK_HOME is ${HM_SDK_HOME}"
echo "HOS_SDK_HOME is ${HOS_SDK_HOME}"
echo "OHOS_SDK_HOME is ${OHOS_SDK_HOME}"
node -v
npm -v

# 任务名赋值
compile_task=$1
echo "compile_task=>$1"

# 初始化相关路径
PROJECT_PATH="$(pwd -P)"
TOOLS_INSTALL_DIR=${PROJECT_PATH}
SDK_DIR_NAME=$(ls $HM_SDK_HOME|head -1)

# 获得签名jar文件
cd ${PROJECT_PATH}/hw_sign
if [ "${DT_TASK_FLAG}" == "wearable" ];then
    chmod +x build_watch.sh
    ./build_watch.sh
elif [ "${DT_TASK_FLAG}" == "tv" ];then
    chmod +x build_tv.sh
    ./build_tv.sh
else
    chmod +x build.sh
    ./build.sh
fi

# Setup npm
#npm config set registry
npm config set registry
npm config set @ohos:registry
npm config set strict-ssl false

# 进入package目录安装依赖
function ohpm_install() {
    cd $1
    ohpm -v
    ohpm install
}

function replace_sdk_files() {
  echo "replace sdk files start ====================="
  cd ${PROJECT_PATH}/
  cp -r ${PROJECT_PATH}/sdk/hms/* ${HOS_SDK_HOME}/${SDK_DIR_NAME}/hms
  cp -r ${PROJECT_PATH}/sdk/openharmony/* ${HOS_SDK_HOME}/${SDK_DIR_NAME}/openharmony
  echo "replace sdk files end ====================="
}

function replace_sdk_files_tv() {
  echo "replace tv sdk files start ====================="
  cd ${PROJECT_PATH}/
  cp -r ${PROJECT_PATH}/sdk/hms/* ${HOS_SDK_HOME}/${SDK_DIR_NAME}/hms
  cp -r ${PROJECT_PATH}/sdk/openharmony/* ${HOS_SDK_HOME}/${SDK_DIR_NAME}/openharmony
  echo "replace tv sdk files end ====================="
}

# 构建任务
function build() {
    # 根据业务情况适配local.properties
    cd ${PROJECT_PATH}
    echo "sdk.dir=${HM_SDK_HOME}"  > ./local.properties
    echo "nodejs.dir=${NODE_HOME}" >> ./local.properties

    # 根据业务情况安装ohpm三方库依赖
    ohpm_install "$PROJECT_PATH"
    ohpm_install "$PROJECT_PATH/common"
    ohpm_install "$PROJECT_PATH/feature/uikit"
    ohpm_install "$PROJECT_PATH/feature/datetime"
    ohpm_install "$PROJECT_PATH/feature/display"
    ohpm_install "$PROJECT_PATH/feature/wifi"
    ohpm_install "$PROJECT_PATH/feature/bluetooth"
    ohpm_install "$PROJECT_PATH/feature/application"
    ohpm_install "$PROJECT_PATH/feature/cloneapps"
    ohpm_install "$PROJECT_PATH/feature/storage"
    ohpm_install "$PROJECT_PATH/feature/privacy"
    ohpm_install "$PROJECT_PATH/feature/developeroptions"
    ohpm_install "$PROJECT_PATH/feature/reset"
    ohpm_install "$PROJECT_PATH/feature/language"
    ohpm_install "$PROJECT_PATH/feature/moreconnection"
    #ohpm_install "$PROJECT_PATH/feature/notDisturb"
    ohpm_install "$PROJECT_PATH/feature/aboutdevice"
    ohpm_install "$PROJECT_PATH/feature/search"
    ohpm_install "$PROJECT_PATH/feature/accessibility"
    ohpm_install "$PROJECT_PATH/feature/systemUpdate"
    ohpm_install "$PROJECT_PATH/feature/theme"
    #ohpm_install "$PROJECT_PATH/product/cockpit"
    ohpm_install "$PROJECT_PATH/product/phone"
    cat ${HOME}/.npmrc | grep 'lockfile=false' || echo 'lockfile=false' >> ${HOME}/.npmrc

    # 根据业务情况，采用对应的构建命令，可以参考IDE构建日志中的命令
    cd ${PROJECT_PATH}
    hvigorw clean --no-daemon

    if [ "${DT_TASK_FLAG}" == "dt_task" ];then
        replace_sdk_files
        hvigorw --mode module -p module=phone_settings -p debuggable=false -p ohos-test-coverage=true -p build_mode=test assembleHap --parallel --incremental --no-daemon
        hvigorw --mode module -p module=phone_settings@ohosTest -p debuggable=false -p ohos-test-coverage=true assembleHap packageTesting --no-daemon

        echo "-----------------handle DTPipeline.zip--------------------"
        	hasPackageDTPipeline=0
        	if [ -e "build/DTPipeline.zip" ];then
        	  file_size=$(stat -c%s "build/DTPipeline.zip")
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
        replace_sdk_files_tv
        # 1.0hypium插件，复制source目录
        cd ${PROJECT_PATH}
        mkdir -p build/outputs/HomeVision-SettingsMain-Single/source/product/tv
        cp -r product/tv/src/* build/outputs/HomeVision-SettingsMain-Single/source/product/tv
        hvigorw --mode module -p module=tv_settings -p debuggable=false -p ohos-test-coverage=true -p build_mode=test assembleHap --parallel --incremental --no-daemon
        hvigorw --mode module -p module=tv_settings@ohosTest -p debuggable=false -p ohos-test-coverage=true assembleHap packageTesting --no-daemon
        echo "-----------------tv handle DTPipeline.zip--------------------"
          hasPackageDTPipeline=0
          if [ -e "build/DTPipeline.zip" ];then
            file_size=$(stat -c%s build/DTPipeline.zip)
            if [ $file_size -gt 0 ]; then
            	echo "tv DTPipeline.zip is normal"
            else
            	hasPackageDTPipeline=1
            	rm -rf build/DTPipeline.zip
            	echo "tv DTPipeline.zip size is 0"
            fi
          else
            hasPackageDTPipeline=1
            echo "tv build/DTPipeline.zip is not exist"
          fi
          if [ $hasPackageDTPipeline -eq 1 ];then
        	  pushd build/outputs
        	  if [ $? -ne 0 ];then
          	    echo "tv build/outputs is not exist"
                exit 1
        	  fi
        	  zip -r ../DTPipeline.zip ./*
          	popd
         	fi
        echo "tv After assembleHap packageTesting!"
    fi
    if [ "${DT_TASK_FLAG}" == "wearable" ];then
        cd ${PROJECT_PATH}/product/wearable/
        chmod +x ./watch_build.sh
        ./watch_build.sh
        cd ${PROJECT_PATH}
        #SDK升级补全部分资源文件
        replace_sdk_files
        #手表模块api16代码文件替换
        cp ${PROJECT_PATH}/product/wearable/src/main/ets/common/framework/replace/* ${PROJECT_PATH}/product/wearable/src/main/ets/common/framework/view
        cp ${PROJECT_PATH}/product/wearable/src/main/ets/components/replace/* ${PROJECT_PATH}/product/wearable/src/main/ets/components/view
        cp ${PROJECT_PATH}/product/wearable/src/main/ets/Setting/Password/arcComponents/* ${PROJECT_PATH}/product/wearable/src/main/ets/Setting/Password/components
        cp ${PROJECT_PATH}/product/wearable/src/main/ets/Setting/Battery/arkui/* ${PROJECT_PATH}/product/wearable/src/main/ets/Setting/Battery/page
        #编译命令
        hvigorw --mode module -p module=wearable_settings -p debuggable=false -p build_mode=release assembleHap --parallel --incremental --no-daemon
        hvigorw --mode module -p module=wearable_settings@ohosTest -p debuggable=false -p ohos-test-coverage=true assembleHap packageTesting --no-daemon
        echo "-----------------handle DTPipeline.zip--------------------"
        hasPackageDTPipeline=0
        if [ -e "build/DTPipeline.zip" ];then
            file_size=$(stat -c%s "build/DTPipeline.zip")
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
    if [ "${DT_TASK_FLAG}" == "wearable_lite" ];then
        cd ${PROJECT_PATH}
        #编译命令
        hvigorw --mode module -p module=wearable_lite_settings -p debuggable=false -p build_mode=release assembleHap --parallel --incremental --no-daemon
        hvigorw --mode module -p module=wearable_lite_settings@ohosTest -p debuggable=false -p ohos-test-coverage=true assembleHap packageTesting --no-daemon
        echo "-----------------handle DTPipeline.zip--------------------"
        hasPackageDTPipeline=0
        if [ -e "build/DTPipeline.zip" ];then
            file_size=$(stat -c%s "build/DTPipeline.zip")
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
    if [ "${DT_TASK_FLAG}" == "wearable" ];then
        cd ${PROJECT_PATH}
        cp product/wearable/build/default/outputs/default/wearable_settings-default-signed.hap product/wearable/build/default/outputs/default/Settings.hap
        echo "watch_SDK_ok"
    elif [ "${DT_TASK_FLAG}" == "wearable_lite" ];then
        cd ${PROJECT_PATH}
        cp product/wearable_lite/build/default/outputs/default/wearable_lite_settings-default-signed.hap product/wearable_lite/build/default/outputs/default/Settings.hap
        echo "watch_lite_SDK_ok"
    elif [ "${DT_TASK_FLAG}" == "tv" ];then
        hvigorw --mode module -p debuggable=false -p build_mode=release assembleHap --no-daemon
        replace_sdk_files_tv
        cd ${PROJECT_PATH}
        cp product/tv/build/default/outputs/default/tv_settings-default-signed.hap product/tv/build/default/outputs/default/Settings.hap
    else
        replace_sdk_files
        hvigorw --mode module -p debuggable=false -p build_mode=release assembleHap --no-daemon
        cd ${PROJECT_PATH}
        # 新的流水线2.0不能直接生成归档文件名称（应用名.hap）,使用重命名命令修改名称
        cp product/phone/build/default/outputs/default/phone_settings-default-signed.hap product/phone/build/default/outputs/default/Settings.hap
    fi
}

function main() {
  local start_time=$(date '+%s')
  build
  local end_time=$(date '+%s')
  local elapsed_time=$(expr $end_time - $start_time)
  echo "build success in ${elapsed_time}s..."
}

main