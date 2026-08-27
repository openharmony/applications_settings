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

import { CompCtrlParam, ComponentControl } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { AccessibilityImageSizeAdjust } from '../utils/AccessibilityImageSizeAdjust';

/* instrument ignore file */
export class AccessibilityPageController implements ComponentControl {
  private accessibilityImageSizeAdjust: AccessibilityImageSizeAdjust = new AccessibilityImageSizeAdjust();
  private tag: string = 'AccessibilityPageController';
  private eventName: string | undefined = '';
  private eventValue: string | undefined = '';

  constructor(tag: string, eventName?: string, eventValue?: string) {
    this.tag = tag;
    this.eventName = eventName;
    this.eventValue = eventValue;
  }

  async init(compParam: CompCtrlParam): Promise<void> {
    LogUtil.info(`${this.tag} init`);
    AppStorage.setOrCreate<number>('AccessibilityImageSize', this.accessibilityImageSizeAdjust.imageResourceRadius);
    if (this.eventName && this.eventValue) {
      HiSysEventUtil.reportDefaultBehaviorEventByUE(this.eventName, this.eventValue);
    }
  }

  destroy(): void {
    LogUtil.info(`${this.tag} on destroy`);
  }

  onPageShow(): void {
    LogUtil.info(`${this.tag} on onPageShow`);
  }
}