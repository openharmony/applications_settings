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

import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { AbilityUtils } from '@ohos/settings.common/src/main/ets/utils/AbilityUtils';
import { PADDING_16 } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { getNetworkNavigatorLink } from '../controller/NetworkNavigatorEntryController';
/* instrument ignore file */
const TAG: string = 'WebHintComponent: ';

@Component
export struct WebHintComponent {
  build() {
    Scroll() {
      Text() {
        Span(ResourceUtil.getFormatStringSync($r('app.string.network_navigator_tips'), ''))
          .fontSize($r('sys.float.Body_S'))
          .constraintSize({ minHeight: $r('app.float.wh_value_16') })
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.font_secondary'))

        Span($r('app.string.network_navigator_tips_link'))
          .fontSize($r('sys.float.Body_S'))
          .constraintSize({ minHeight: $r('app.float.wh_value_16') })
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_emphasize'))
          .onClick(() => {
            this.onMenuClick();
          })
      }
      .textAlign(TextAlign.Start)
      .width('100%')
      .wordBreak(WordBreak.BREAK_WORD)
    }
    .scrollBar(BarState.Off)
    .constraintSize({ maxHeight: '25%' })
    .padding({ bottom: PADDING_16 })
  }

  async onMenuClick(): Promise<void> {
    let uriAddress: string = await getNetworkNavigatorLink();
    if (CheckEmptyUtils.checkStrIsEmpty(uriAddress)) {
      LogUtil.showError(TAG, 'on openBrowser uriAddress is empty');
      return;
    }
    let want: Want = {
      'bundleName': 'com.ohos.browser',
      'abilityName': 'MainAbility',
      'action': 'ohos.want.action.viewData',
      'entities': ['entity.system.browsable'],
      'uri': uriAddress,
    }
    AbilityUtils.startAbility(want);
  }
}