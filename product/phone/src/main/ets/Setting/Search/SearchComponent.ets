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

import lazy { AppListLoader } from '@ohos/settings.application/src/main/ets/AppListLoader';
import { SettingBaseModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { FOCUS_BOX_PADDING_METRICS, PADDING_14 } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { HiSysSearchEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';

const TAG = 'SearchComponent';

@Component
export struct SearchComponent {
  item?: SettingBaseModel;
  build() {
    Column() {
      Search({
        placeholder: $r('app.string.set_search_terms')
      })
      .id('homPageSearchInput')
      .geometryTransition('SEARCH_ONE_SHOT_ID')
      .draggable(false)
      .width('100%')
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .placeholderColor($r('sys.color.font_secondary'))
      .placeholderFont({ size: $r('sys.float.Body_L') })
      .margin(0)
      .focusOnTouch(false)
      .focusable(false)
      .enableKeyboardOnFocus(false)
      .onClick(() => {
        LogUtil.info(`${TAG} Click Search`);
        this.getUIContext()?.animateTo({
          duration: 500,
          curve: Curve.FastOutSlowIn
        }, () => {
          AppStorage.setOrCreate('isSearching', true);
          HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysSearchEventGroup.CLICK_SEARCH_BUTTON);
          AppListLoader.getInstance().loadAppList();
        })
      })
    }
    .onClick(() => {
      LogUtil.info(`${TAG} Enter Column`);
      HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysSearchEventGroup.CLICK_SEARCH_BUTTON);
      AppStorage.setOrCreate('isSearching', true);
      AppListLoader.getInstance().loadAppList();
    })
    .id('homPageSearchInputColumn')
    .accessibilityGroup(true)
    .accessibilityText($r('app.string.set_search_terms'))
    .borderRadius($r('sys.float.corner_radius_level10'))
    .focusBox({ margin: FOCUS_BOX_PADDING_METRICS })
    .margin({ top: PADDING_14 })
  }
}