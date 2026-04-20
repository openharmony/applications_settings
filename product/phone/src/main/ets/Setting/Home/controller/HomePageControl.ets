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

import emitter from '@ohos.events.emitter';
import { SettingPageModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingPageModel'
import { CompCtrlParam, ComponentControl } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { SettingGroupModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingGroupModel';
import { SettingItemModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { EnableUtils } from '@ohos/settings.common/src/main/ets/utils/baseutils/EnableUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { DisplayPreferencesUtils } from '../../Display/utils/DisplayPreferencesUtils';
import { SearchItemDynamicUpdateUtil } from '../utils/SearchItemDynamicUpdateUtil';

const TAG: string = 'HomePageControl:';

export class HomePageControl implements ComponentControl {
  private keyboardConnectStatusChangeCallback: (data: emitter.EventData) => void = (eventData: emitter.EventData) => {
  }

  init(compParam: CompCtrlParam): void {
    console.log('zzzzzzzzz HomePageControl init')
    LogUtil.showInfo(TAG, 'onInit');
    let disableMenus: Set<string> = EnableUtils.getHomePageDisableItems();
    if (!compParam || !compParam.component) {
      LogUtil.showInfo(TAG, 'Init failed, component is empty');
      return;
    }

    let pageInfo: SettingPageModel = compParam.component as SettingPageModel;
    if (!pageInfo.groups) {
      LogUtil.showInfo(TAG, 'Init failed, page group is empty');
      return;
    }

    let groupLen: number = pageInfo.groups.length;
    for (let groupIndex: number = 0; groupIndex < groupLen; groupIndex++) {
      const group: SettingGroupModel = pageInfo.groups[groupIndex];
      if (!group.items) {
        continue;
      }
      for (let itemIndex: number = 0; itemIndex < group.items.length; itemIndex++) {
        const item: SettingItemModel = group.items[itemIndex];
        if (disableMenus.has(item.id)) {
          item.enabled = false;
        }
      }
    }
    //显示和亮度页面的设备是否支持自动亮度、护眼模式、色彩色温控制开关状态获取首次加载存入缓存
    DisplayPreferencesUtils.displayPreferences();
    if (DeviceUtil.isDevicePad()) {
      this.initKeyboardConnectStatusChangeCallback();
    }
    if (DeviceUtil.is2In1Device()) {
      SearchItemDynamicUpdateUtil.getInstance().updateSearchItems();
    }
  }

  destroy(): void {
    LogUtil.showInfo(TAG, 'onDestroy');
  }

  private initKeyboardConnectStatusChangeCallback() {
    LogUtil.showInfo(TAG, 'initKeyboardConnectStatusChangeCallback');
  }
}