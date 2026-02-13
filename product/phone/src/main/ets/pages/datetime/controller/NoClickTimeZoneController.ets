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

import systemDateTime from '@ohos.systemDateTime';
import i18n from '@ohos.i18n';
import intl from '@ohos.intl';
import commonEventManager from '@ohos.commonEventManager';
import { Controller } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { CommonEventHelper } from '@ohos/settings.common/src/main/ets/utils/CommonEventHelper';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import {
  PageLifecycleMenuController
} from '@ohos/settings.common/src/main/ets/core/controller/LifecycleMenuController';
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { HiSysSystemAndUpdatesEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { TimeZoneUtil } from '@ohos/settings.datetime/src/main/ets/utils/TimeZoneUtil';

/* instrument ignore file */
const TAG: string = 'NoClickTimeZoneController : ';

/**
 * 打开时区自动设置开关时区菜单控制器
 *
 * @since 2025-08-05
 */
export default class NoClickTimeZoneController extends PageLifecycleMenuController {
  // 夏令时变化时会触发时区变化
  private subscribeInfo: commonEventManager.CommonEventSubscribeInfo = {
    events: [
      commonEventManager.Support.COMMON_EVENT_TIMEZONE_CHANGED
    ]
  };
  private timeCommonEvent = new CommonEventHelper(this.subscribeInfo, (err, data) => {
    LogUtil.info(`${TAG} receive event:${data?.event}, code:${err.code}`);
    if (!err.code) {
      this.changeValue();
    }
  });

  static CreateTimeZoneController(menu: SettingsBaseMenu): Controller {
    return new NoClickTimeZoneController(menu);
  }

  aboutToAppear(): void {
    super.aboutToAppear();
    this.timeCommonEvent.registerCommonEvent();
  }

  aboutToDisappear(): void {
    super.aboutToDisappear();
    this.timeCommonEvent.unRegisterCommonEvent();
  }

  updateStatus(): void {
    super.updateStatus();
    this.changeValue();
  }

  onPageShow(): void {
    this.updateStatus();
  }

  private changeValue(): void {
    systemDateTime.getTimezone().then((timeZoneId) => {
      let timeZone = i18n.getTimeZone(timeZoneId);
      let stateStr = `${TimeZoneUtil.getRawOffsetSummary(timeZone, true)} ${
      timeZone.getDisplayName(new intl.Locale(i18n.System.getSystemLanguage())?.toString())}`;
      HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysSystemAndUpdatesEventGroup
        .TIME_ZONE_POP_FRAME_CONFIRM, stateStr);
      LogUtil.info(`${TAG} getTimezone, timeZoneId: ${timeZoneId}, stateStr: ${stateStr}`);
      this.menu.state = stateStr;
      this.refreshUi();
    }).catch((error: Error) => {
      LogUtil.error(`${TAG} Failed to get system time zone. Cause: ${error?.message}`);
    });
  }
}