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

import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';

/* instrument ignore file */
const TAG: string = 'SearchComponent : ';

@Component
export struct SearchComponent {
  private controller: SearchController = new SearchController();
  @Link changeValue: string;
  onSearchBarChange?: (value: string) => void;
  onSearchClick?: () => void;

  build() {
    Search({ value: this.changeValue, placeholder: $r('app.string.setting_search'), controller: this.controller })
      .margin({
        top: $r('sys.float.padding_level4'),
        bottom: $r('sys.float.padding_level5')
      })
      .constraintSize({ minHeight: 40 })
      .width('calc(100% - 32vp)')
      .placeholderColor($r('sys.color.font_secondary'))
      .fontColor($r('sys.color.font_secondary'))
      .placeholderFont({
        size: ($r('sys.float.Body_L')),
        weight: FontWeight.Regular
      })
      .textFont({ size: $r('sys.float.Body_L'), weight: FontWeight.Regular })
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .enableKeyboardOnFocus(false)
      .onChange((value: string) => {
        if (this.onSearchBarChange) {
          this.onSearchBarChange(value);
        }
      })
      .onClick(() => {
        if (this.onSearchClick) {
          this.onSearchClick();
        }
      })
      .enabled(true)
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
  }
}