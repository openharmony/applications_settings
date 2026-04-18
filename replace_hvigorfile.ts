/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
// Script for compiling build behavior. It is built in the build plug-in and cannot be modified currently.

import { appTasks } from '@ohos/hvigor-ohos-plugin';
import { hvigor, getHvigorNode} from '@ohos/hvigor';
import { uploadTestCases } from '@ohos/hypium-plugin';
import { onlineSignPlugin, OnlineSignOptions } from '@ohos/hvigor-ohos-online-sign-plugin';

const config = {
  hvigor:hvigor,
  hvigorNode: getHvigorNode(__filename),
  templateEngName: 'SettingsDT_20250312', // CDE架构模板中维护的模板英文名称
  modulesConfig: [
    {
      moduleName: 'phone_settings',
      appName: 'settings',
      subModuleNames: ['settings.common']
    },
    {
      moduleName: 'wearable_settings',
      appName: 'WatchSettings',
      templateEngName: 'DTSettings_watch',
    },
    {
      moduleName: 'tv_settings',
      appName: 'HomeVision-SettingsMain-Single',
      templateEngName: 'DTSettings_tv',
    }
  ]
}

const signOptions: OnlineSignOptions = {
  profile: 'hw_sign/117895release_watch.p7b',
  keyAlias: 'Settings HMOS',
  hapSignToolFile: 'hw_sign/hap-sign-tool.jar', // 签名工具hap-sign-tool.jar的路径
  username: `${process.env.ONLINE_USERNAME}`, // 环境变量中需要配置用户名和密码
  password: `${process.env.ONLINE_PASSWD}`,
  enableOnlineSign: true // 是否启用在线签名
};

uploadTestCases(config);

export default {
  system: appTasks,
  plugins: [onlineSignPlugin(signOptions)]
};