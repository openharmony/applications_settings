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

import i18n from '@ohos.i18n';
import Want from '@ohos.application.Want';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { AbilityUtils } from '@ohos/settings.common/src/main/ets/utils/AbilityUtils';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import {
  CompCtrlParam,
  ComponentControl,
  SettingBaseModel,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { HiSysAboutDeviceEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';

export class ConsumerBusinessPrivacyController implements ComponentControl {
  private tag: string = 'ConsumerBusinessPrivacyController';
  public compId: string = '';
  init(compParam: CompCtrlParam): void {
    this.compId = compParam?.compId;
    LogUtil.info(`${this.tag} init, id: ${compParam.compId}`);
  }

  destroy(): void {
    LogUtil.showDebug(this.tag, 'on destroy');
  }

  onClick(component: SettingBaseModel): void {
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysAboutDeviceEventGroup.ENTER_PRIVACY_STATEMENT_ENTRY);
    LogUtil.info(`${this.tag} onEntryClick`);
    let language: string = i18n.System.getSystemLocale();
    let region: string = i18n.System.getSystemRegion();
    let uri = ResourceUtil.getStringSync('');
    LogUtil.info(`${this.tag} current language: ${language}, region: ${region}`);
    let uriAddress: string = uri + region + '&language=' + language;
    let want: Want = {
      'bundleName': 'com.ohos.browser',
      'abilityName': 'MainAbility',
      'action': 'ohos.want.action.viewData',
      'entities': ['entity.system.browsable'],
      'uri': uriAddress,
    };
    AbilityUtils.startAbility(want);
  }
}