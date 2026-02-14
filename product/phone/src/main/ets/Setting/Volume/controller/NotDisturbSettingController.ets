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

/* instrument ignore file */
import dataShare from '@ohos.data.dataShare';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import {
  CompCtrlParam,
  ComponentControl,
  SettingBaseModel
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { GlobalContext } from '@ohos/settings.common/src/main/ets/utils/GlobalContext';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { ContextUtils } from '@ohos/settings.common/src/main/ets/utils/baseutils/ContextUtils';
import { FOCUS_MODE_TIMER } from '@ohos/settings.notDisturb/src/main/ets/NotDisturbTimerManager';
import { StorageEventConstant } from '@ohos/settings.storage/src/main/ets/constant/StorageConstant';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { HiSysNotDisturbEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';

const TAG: string = 'NotDisturbSettingController';

/**
 * 免打扰设置Page控制器
 */
export class NotDisturbSettingController implements ComponentControl {
  private dataHelper: dataShare.DataShareHelper | null = null;
  public dataShareHelper?: Promise<dataShare.DataShareHelper> | dataShare.DataShareHelper;

  init(compParam: CompCtrlParam): void {
    LogUtil.info(`${TAG} init`);
    GlobalContext.getInstance().set('TimerContext', ContextUtils.getContext());
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysNotDisturbEventGroup.EVENT_NOT_DISTURB);
  }

  registerDataChange(): void {
    if (this.dataHelper) {
      SettingsDataUtils.registerUserDataChange(this.dataHelper, 'focus_mode_timer', this.onDataChange);
    } else {
      (SettingsDataUtils.createDataHelper(FOCUS_MODE_TIMER) as Promise<dataShare.DataShareHelper>)
        .then((dataShareHelper?: dataShare.DataShareHelper) => {
          if (dataShareHelper) {
            this.dataHelper = dataShareHelper;
            SettingsDataUtils.registerUserDataChange(this.dataHelper, FOCUS_MODE_TIMER, this.onDataChange);
          }
        })
    }
    LogUtil.info(`${TAG} registerDataChange`);
  }

  private onDataChange = () => {
    EventBus.getInstance().emit(StorageEventConstant.EVENT_NOTDISTURB_GROUP_INIT);
  }

  unRegisterDataChange(): void {
    SettingsDataUtils.unRegisterUserDataChange(this.dataHelper as dataShare.DataShareHelper, FOCUS_MODE_TIMER);
    LogUtil.info(`${TAG} unRegisterDataChange`);
  }

  destroy(): void {
    LogUtil.info(`${TAG} on destroy`);
  }

  onPageShow(component: SettingBaseModel): void {
    LogUtil.info(`${TAG} onPageShow`);
    this.registerDataChange();
  }

  onPageHide(component: SettingBaseModel): void {
    LogUtil.info(`${TAG} onPageHide`);
    this.unRegisterDataChange();
  }
}