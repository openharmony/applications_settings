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

import {
  ComponentControl,
  SettingBaseModel
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { HiSysAuxiliaryEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { AccessibilityFunctionSelectCacheModel } from '../utils/AccessibilityCommonModel';
import { AccessibilityImageSizeAdjust } from '../utils/AccessibilityImageSizeAdjust'
import { PageUrl } from '../../../pages/PageUrl';

/* instrument ignore file */
const TAG: string = 'OperationSettingController : ';

export class OperationSettingController implements ComponentControl {
  private functionSelectCacheModel: AccessibilityFunctionSelectCacheModel =
    AccessibilityFunctionSelectCacheModel.getInstance();
  private accessibilityImageSizeAdjust: AccessibilityImageSizeAdjust = new AccessibilityImageSizeAdjust();

  /**
   * 清除辅助功能快捷键缓存数据
   *
   * @returns
   */
  removeRecoveryCache(): void {
    if (this.functionSelectCacheModel) {
      this.functionSelectCacheModel.functionSelectScaleOpen = false;
      this.functionSelectCacheModel.securityNotificationOpen = false;
      this.functionSelectCacheModel.shortKeyTargetsIdListCache = [];
    }
  }

  init(): void {
    LogUtil.info(`${TAG} init`);
    this.accessibilityImageSizeAdjust.registerDisplayChangeListener();
    AppStorage.setOrCreate<number>('AccessibilityImageSize', this.accessibilityImageSizeAdjust.imageResourceRadius);
    HiSysEventUtil.reportDefaultBehaviorEventByUE(
      HiSysAuxiliaryEventGroup.ENTER_ACCESSIBILITY_OPERATION, 'pageUrl: ' + PageUrl.ACCESSIBILITY_OPERATION_PAGE_URL);
  }

  destroy(): void {
    LogUtil.info(`${TAG} on destroy`);
    this.accessibilityImageSizeAdjust.unregisterDisplayChangeListener();
    this.removeRecoveryCache();
  }

  onPageShow(): void {
    LogUtil.info(`${TAG} onPageShow`);
  }

  onPageHide(): void {
    LogUtil.info(`${TAG} onPageHide`);
  }
}