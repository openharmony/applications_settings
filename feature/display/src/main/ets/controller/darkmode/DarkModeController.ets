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
import common from '@ohos.app.ability.common';
import { CompCtrlParam } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import {
  notifyCompStateChange,
  SettingResultState,
  SettingStateType
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { ItemResultType } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';
import {
  DARK_MODE_OPEN_ALL_DAY,
  DARK_MODE_TIMED_ON,
  DEFAULT_DARK_MODE_STATE,
} from '../../constant/DarkModeConstant';
import { BaseDarkModeController } from './BaseDarkModeController';

const COLOR_MODE_DARK: number = 0;

export class DarkModeController extends BaseDarkModeController {
  protected tag: string = 'DarkModeController: ';
  protected darkModeChangeCallback = () => {
    let darkMode: string = this.getDarkModeType();
    LogUtil.info(`${this.tag} darkModeTypeChangeCallback ${darkMode}`);
    let state: ResourceStr = '';
    if (darkMode === DARK_MODE_TIMED_ON) {
      state = $r('app.string.eye_timed_on');
    } else if (darkMode === DEFAULT_DARK_MODE_STATE) {
      state = $r('app.string.open_all_day_close');
    } else if (darkMode === DARK_MODE_OPEN_ALL_DAY) {
      state = $r('app.string.open_all_day');
    }
    this.refreshUi(state);
    this.updateDarkTimeSearchItemStatus(darkMode === DARK_MODE_TIMED_ON);
  }

  init(compParam: CompCtrlParam): void {
    LogUtil.debug(`${this.tag} init`);
    let context: common.UIAbilityContext | undefined =
      AppStorage.get<common.UIAbilityContext>('settingsAbilityContext');
    if (CheckEmptyUtils.isEmpty(context)) {
      context = AppStorage.get<Context>('pageContext') as common.UIAbilityContext;
    }

    let isDark: boolean = uiAppearance.getDarkMode() === COLOR_MODE_DARK;
    let state: ResourceStr = isDark ? $r('app.string.open_all_day') : $r('app.string.open_all_day_close');
    LogUtil.info(`${this.tag} init: isDark: ${isDark}`);
    this.getDarkModeTypeAsync().then((darkModeType) => {
      LogUtil.info(`${this.tag} darkMode ${darkModeType}`);
      /* instrument ignore if*/
      if (darkModeType === DARK_MODE_TIMED_ON) {
        state = $r('app.string.eye_timed_on');
      }
      this.refreshUi(state);
    });
    this.registerEvent();
  }

  destroy(): void {
    LogUtil.debug(`${this.tag} on destroy`);
    this.unRegisterEvent();
  }

  private registerEvent(): void {
    LogUtil.info(`${this.tag} registerEvent`);
    this.registerDataHelper();
  }

  private unRegisterEvent(): void {
    LogUtil.info(`${this.tag} unRegisterEvent`);
    this.unRegisterDataHelper();
  }

  private refreshUi(result: ResourceStr): void {
    notifyCompStateChange('Setting.Display.display_setting.dark_mode',
      new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
        { type: ItemResultType.RESULT_TYPE_TEXT, result: { content: result } } as SettingResultState]]));
  }
}