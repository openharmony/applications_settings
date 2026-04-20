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

import { TextInputMenuStyle } from '@ohos/settings.common/src/main/ets/core/model/menu/BaseMenu';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { InputComponent } from '@ohos/settings.commonUikit/src/main/ets/component/InputComponent';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { LanguageUtils } from '@ohos/settings.common/src/main/ets/utils/LanguageUtils';
import {
  NewDefaultTextInputMenuStyle,
  NewTextInputStyle,
  TextDividerStyle,
} from '@ohos/settings.commonUikit/src/main/ets/InputStyle';
import { CUSTOM_SCENARIO_NAME_CHANGE_EVENT, scenarioDataOut } from '../controller/NetworkNavigatorCustomController';
/* instrument ignore file */
export const ADD_NAME_MAX_LENGTH: number = 32;

let newDefaultTextInputDividerStyle: TextDividerStyle = new TextDividerStyle();
let inputMenuStyle: NewDefaultTextInputMenuStyle = new NewDefaultTextInputMenuStyle();
let newTextInputStyle: NewTextInputStyle = new NewTextInputStyle();

@Component
export struct CustomScenarioNameInputComponent {
  item ?: object;
  private content: ResourceStr = '';
  @State showInputComponent: boolean = true;
  @State hasReachMaxNum: boolean = false;
  @State dividerBackgroundColor: Resource = $r('sys.color.comp_background_tertiary');

  build() {
    Column() {
      InputComponent({
        hint: ResourceUtil.getStringSync($r('app.string.network_navigator_custom_scene_name')),
        content: this.content,
        onChange: (input: string) => {
          if (input?.length > ADD_NAME_MAX_LENGTH) {
            this.hasReachMaxNum = true;
          } else {
            this.hasReachMaxNum = false;
          }
          EventBus.getInstance().emit(CUSTOM_SCENARIO_NAME_CHANGE_EVENT, input);
        },
        showComponent: this.showInputComponent,
        style: this.getStyle(),
      })

      if (this.hasReachMaxNum) {
        Text($r('app.string.wifi_name_max'))
          .padding({
            left: $r('sys.float.padding_level6')
          })
          .fontSize($r('sys.float.Body_S'))
          .fontColor($r('sys.color.warning'))
          .width('100%')
          .textAlign(TextAlign.Start)
          .margin({
            top: $r('sys.float.padding_level5'),
          })
      }
    }
    .width('100%')
  }

  aboutToAppear(): void {
    this.content = scenarioDataOut.scenarioName;
    this.initStyle();
  }

  initStyle(): void {
    newTextInputStyle.maxLength = ADD_NAME_MAX_LENGTH;
    newTextInputStyle.padding = {
      left: $r('sys.float.padding_level5'),
    }
    newTextInputStyle.textAlign = TextAlign.Start;
    newTextInputStyle.direction = LanguageUtils.isLtrDirection() ? Direction.Ltr : Direction.Rtl;
    newDefaultTextInputDividerStyle.size = {
      width: 'calc(100% - 24vp)',
      height: $r('app.float.length_1'),
    }
    inputMenuStyle.textInputStyle = newTextInputStyle;
    inputMenuStyle.dividerStyle = newDefaultTextInputDividerStyle;
  }

  aboutToDisappear(): void {
  }

  private getStyle(): TextInputMenuStyle {
    return inputMenuStyle;
  }
}