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
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { notifyCompStateChange,
  SettingBaseState,
  SettingModalState,
  SettingStateType } from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { SECURITY_NOTIFICATION_MODEL_SHOW_EVENT } from '../../constant/Constants';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { HiSysAuxiliaryEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { PageUrl } from '../../../../pages/PageUrl';

/* instrument ignore file */
const TAG: string = 'ScreenReaderController : ';

export class ScreenReaderController implements ComponentControl {
  private securityNotificationModelShowCallback = (itemInfo: boolean | undefined) => {
    if (!itemInfo) {
      LogUtil.error(`${TAG} itemInfo is undefined.`);
      return;
    }
    this.showModelBegin(itemInfo);
  };
  protected showModelBegin(item: boolean): void {
    LogUtil.info(`${TAG} showModelBegin`);
    // 弹出半模态
    notifyCompStateChange('Setting.AccessibilityScreenReaderSettings.SecurityNotificationGroup.SecurityNotificationModel',
      new Map<SettingStateType, SettingBaseState>([[SettingStateType.STATE_TYPE_ITEM_SHEET,
        {
          state: true,
          sheetHeight: SheetSize.FIT_CONTENT,
        } as SettingModalState]]
      ));
  }

  init(): void {
    LogUtil.info(`${TAG} init`);
    EventBus.getInstance().on(SECURITY_NOTIFICATION_MODEL_SHOW_EVENT, this.securityNotificationModelShowCallback);
    HiSysEventUtil.reportDefaultBehaviorEventByUE(
      HiSysAuxiliaryEventGroup.ENTER_SCREEN_READER_PAGE,
      'pageUrl: ' + PageUrl.ACCESSIBILITY_SCREENREADER_URL);
  }

  destroy(): void {
    LogUtil.info(`${TAG} on destroy`);
    EventBus.getInstance().detach(SECURITY_NOTIFICATION_MODEL_SHOW_EVENT, this.securityNotificationModelShowCallback);
  }

  onPageShow(component: SettingBaseModel): void {
    LogUtil.info(`${TAG} find new services, show SecurityNotification`);
  }

  onPageHide(component: SettingBaseModel): void {
    LogUtil.info(`${TAG} onPageHide`);
  }
}