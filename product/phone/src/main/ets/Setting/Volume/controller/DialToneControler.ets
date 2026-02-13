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
import settings from '@ohos.settings';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import {
  CompCtrlParam,
  ComponentControl,
  SettingBaseModel
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { ItemResultType } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import {
  notifyCompStateChange,
  SettingBaseState,
  SettingResultState,
  SettingSelectMenuState,
  SettingStateType,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { HiSysVolumeGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { DIAL_TONE_MENU } from '../constant/VolumeConstant';


const DIALPAD_TOUCH_TONE_TYPE: string = 'dialpad_touch_tone_type';
const TAG = 'DialToneControler';

export class DialToneControler implements ComponentControl {
  public currentSelect: string = '1';
  private compId: string = '';
  public onHandlerSelected = (menuState: string) => {
    let context: Context = SettingsDataUtils.getContext();
    LogUtil.info(`${TAG} menuState is ${menuState}`);
    if (!menuState) {
      LogUtil.error(`${TAG} menuState is invalid`);
      return;
    }
    this.currentSelect = menuState;
    LogUtil.info(`${TAG} currentSelect is ${this.currentSelect}`);
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysVolumeGroup.DIAL_TONE_SWITCH, this.currentSelect);
    SettingsDataUtils.setSettingsDataAsyncWithContext(context, DIALPAD_TOUCH_TONE_TYPE, menuState,
      settings.domainName.USER_PROPERTY);
    this.refreshUi();
  };

  init(compParam: CompCtrlParam): void {
    this.compId = compParam?.compId;
    LogUtil.info(`${TAG} init`);
    SettingsDataUtils.getSettingsDataAsync(DIALPAD_TOUCH_TONE_TYPE, '1', settings.domainName.USER_PROPERTY)
      .then(res => {
        this.onHandlerSelected(res);
      })
    EventBus.getInstance().on(`${this.compId}.menu`, this.onHandlerSelected);
  }

  onPageShow(component: SettingBaseModel): void {
    LogUtil.info(`${TAG} onPageShow`);
  }

  onPageHide(component: SettingBaseModel): void {
    LogUtil.info(`${TAG} onPageHide`);
  }

  destroy(): void {
    LogUtil.showInfo(TAG, 'onDestroy eventbus');
    EventBus.getInstance()
      .detach(`${this.compId}.menu`, this.onHandlerSelected);
  }

  protected refreshUi(): void {
    notifyCompStateChange(this.compId,
      new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
        {
          type: ItemResultType.RESULT_TYPE_TEXT, result: { content: DIAL_TONE_MENU[Number(this.currentSelect)] }
        } as SettingResultState]]));

    notifyCompStateChange(this.compId,
      new Map<SettingStateType, SettingBaseState>([[SettingStateType.STATE_TYPE_ITEM_MENU, {
        items: DIAL_TONE_MENU,
        defaultFocus: Number(this.currentSelect),
        selectIcon: $r('app.media.ic_selected'),
        onSelected: (index: number) => {
          this.onHandlerSelected(String(index));
        }
      } as SettingSelectMenuState]]));
  }
}