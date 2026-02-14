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

import uiAppearance from '@ohos.uiAppearance';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import Settings from '@ohos.settings';
import {
  CompCtrlParam,
  ComponentControl,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { GroupType, SettingGroupModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingGroupModel';
import { ItemResultType, ItemType } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { SettingPageModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingPageModel';
import {
  HiSysEventUtil
} from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { COLOR_MODE_DARK,
  DARK_MODE_OPEN_ALL_DAY,
  DEFAULT_DARK_MODE_STATE,
  SETTINGS_UI_APPEARANCE_DARK_MODE } from '../../constant/DarkModeConstant';
import { DarkModeOpenAllDayController } from './DarkModeOpenAllDayController';
import { DarkModeTimedOnController } from './DarkModeTimedOnController';
import { HiSysDisplayEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';

const TAG: string = 'DarkModePageController: ';

export class DarkModePageController implements ComponentControl {
  private compId: string = '';
  private settingPageModel?: SettingPageModel;
  private isDarkModeOpen: boolean = false;
  private darkModeType: string = '';

  init(compParam: CompCtrlParam): void {
    if (!compParam || !compParam.compId) {
      LogUtil.error(`${TAG} init fail, compParam is invalid`);
      return;
    }
    this.compId = compParam.compId;
    LogUtil.info(`${TAG} init ${this.compId}`);
    this.settingPageModel = compParam.component as SettingPageModel;
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysDisplayEventGroup.CLICK_DARK_COLOR_MODE_BUTTON);
    this.initStatus();
    this.addTimedOnGroup();
    this.addDarkModeOpenAllDayGroup();
  }

  private initStatus(): void {
    this.isDarkModeOpen = uiAppearance.getDarkMode() === COLOR_MODE_DARK;
    LogUtil.info(`${TAG} isDarkModeOpen ${this.isDarkModeOpen}`);
    this.darkModeType = SettingsDataUtils
      .getSettingsData(SETTINGS_UI_APPEARANCE_DARK_MODE, DEFAULT_DARK_MODE_STATE, Settings.domainName.USER_PROPERTY);
    LogUtil.info(`${TAG} darkModeType ${this.darkModeType}`);
  }

  private addDarkModeOpenAllDayGroup(): void {
    let item: SettingGroupModel = {
      id: 'open_all_day',
      type: GroupType.GROUP_TYPE_STANDARD,
      items: [
        {
          id: 'switch',
          type: ItemType.ITEM_TYPE_STANDARD,
          title: { content: $r('app.string.open_all_day_switch') },
          compControl: new DarkModeOpenAllDayController(),
          result: {
            type: ItemResultType.RESULT_TYPE_TOGGLE,
            result: { state: this.initOpenAllDayState()},
          },
        }
      ]
    };
    this.settingPageModel?.groups?.push(item);
  }

  private initOpenAllDayState(): boolean {
    return this.isDarkModeOpen &&
      (this.darkModeType === DARK_MODE_OPEN_ALL_DAY || this.darkModeType === DEFAULT_DARK_MODE_STATE);
  }

  private addTimedOnGroup(): void {
    let item: SettingGroupModel = {
      id: 'timed_on',
      type: GroupType.GROUP_TYPE_DYNAMIC_LAZY,
      compControl: new DarkModeTimedOnController(),
    };
    this.settingPageModel?.groups?.push(item);
  }

  destroy(): void {
    LogUtil.showInfo(TAG, 'onDestroy eventbus');
  }
}