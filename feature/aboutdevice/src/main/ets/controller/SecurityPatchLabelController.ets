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

import fs from '@ohos.file.fs';
import { util } from '@kit.ArkTS';
import { configPolicy } from '@kit.BasicServicesKit';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';
import { AbilityUtils } from '@ohos/settings.common/src/main/ets/utils/AbilityUtils';
import { LanguageUtils } from '@ohos/settings.common/src/main/ets/utils/LanguageUtils';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { HiSysAboutDeviceEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';

export interface SecurityPatchUrl {
  name: string;
  url: string;
}

export class SecurityPatchLabelController {
  private tag: string = 'SecurityPatchLabelController';
  private language: string = '';
  private region: string = '';
  private languageAndRegion: string = '';
  private ccmPageConfigPath: string = 'etc/settings/hw_hmos_security_patch_url.json';
  private defaultLink: string = '';
  private uriAddress: string = '';
  private defaultLanguage: string = 'en-us';
  private ccmConfigStr: string = '';

  private async getUriAddress(): Promise<string> {
    try {
      // 读取resources目录下的rawfile目录下的json文件，替代原本的ccm配置文件
      let ccmConfigUint8Arr = getContext().resourceManager.getRawFileContentSync('security_patch_url.json')
      this.ccmConfigStr = this.uint8ArrayToString(ccmConfigUint8Arr)
      if (CheckEmptyUtils.checkStrIsEmpty(this.ccmConfigStr)) {
        LogUtil.showError(this.tag, 'ccmConfigStr is empty');
        return this.defaultLink;
      }
    } catch {
      LogUtil.showError(this.tag, 'readTextSync failed');
      return this.defaultLink;
    }
    /* instrument ignore if*/
    if (CheckEmptyUtils.checkStrIsEmpty(this.ccmConfigStr)) {
      LogUtil.showError(this.tag, 'ccm config is empty');
      return this.defaultLink;
    }
    let securityPatchList: SecurityPatchUrl[] = [];
    try {
      securityPatchList = JSON.parse(this.ccmConfigStr);
    } catch {
      LogUtil.showError(this.tag, 'parsed config failed');
      return this.defaultLink;
    }
    /* instrument ignore if*/
    if (CheckEmptyUtils.isEmpty(securityPatchList)) {
      LogUtil.showError(this.tag, 'config parsed is empty');
      return this.defaultLink;
    }

    let uriAddress: SecurityPatchUrl[] = securityPatchList.filter(item => {
      return item.name.toLowerCase() === this.languageAndRegion ||
        item.name.toLowerCase().startsWith(this.language) ||
        item.name.toLowerCase() === this.defaultLanguage;
    })
    if (!CheckEmptyUtils.isEmpty(uriAddress)) {
      return uriAddress[0].url;
    } else {
      LogUtil.showError(this.tag, 'getUriAddress failed');
      return this.defaultLink;
    }
  }

  private uint8ArrayToString(array: Uint8Array) {
    let textDecoderOptions: util.TextDecoderOptions = { fatal: false, ignoreBOM: true }
    let decodeToStringOptions: util.DecodeToStringOptions = { stream: false }
    let textDecoder = util.TextDecoder.create('utf-8', textDecoderOptions);
    let retStr = textDecoder.decodeToString(array, decodeToStringOptions);
    console.info('Byte flow into understandable strings：' + retStr);
    return retStr;
  }

  // instrument ignore next
  async openBrowser(): Promise<void> {
    LogUtil.showInfo(this.tag, 'on openBrowser');
    this.language = LanguageUtils.getLanguage().toLowerCase();
    this.region = LanguageUtils.getRegion().toLowerCase();
    this.languageAndRegion = this.language + '-' + this.region;
    this.uriAddress = await this.getUriAddress();
    if (CheckEmptyUtils.checkStrIsEmpty(this.uriAddress)) {
      LogUtil.showInfo(this.tag, 'getUriAddress again');
      this.uriAddress = await this.getUriAddress();
    }
    if (CheckEmptyUtils.checkStrIsEmpty(this.uriAddress)) {
      LogUtil.showError(this.tag, 'on openBrowser uriAddress is empty');
      return;
    }
    let want: Want = {
      'bundleName': 'com.ohos.browser',
      'abilityName': 'MainAbility',
      'action': 'ohos.want.action.viewData',
      'entities': ['entity.system.browsable'],
      'uri': this.uriAddress,
    }
    AbilityUtils.startAbility(want);
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysAboutDeviceEventGroup.SECURITY_PATCH_LABEL_ENTRY);
  }
}
