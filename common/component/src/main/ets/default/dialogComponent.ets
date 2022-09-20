//@ts-nocheck
/**
 * Copyright (c) 2021-2022 Huawei Device Co., Ltd.
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

import ComponentConfig from './ComponentConfig';

/**
 * Standard dialog button layout, which contains two choice buttons.
 * Click events can be defined by two parameters: firstClickEvent and secondClickEvent.
 */
@Component
export struct DialogButtonLayout {
  @State secondButtonState: boolean = true;
  private firstTitle: string | Resource = $r("app.string.cancel");
  private secondTitle: string | Resource = $r("app.string.confirm");
  private firstClickEvent: (event: ClickEvent) => void;
  private secondClickEvent: (event: ClickEvent) => void;

  build() {
    DialogButtonLayoutWithState({
      firstTitle: this.firstTitle,
      secondTitle: this.secondTitle,
      firstClickEvent: this.firstClickEvent,
      secondClickEvent: this.secondClickEvent,
      secondButtonState: this.secondButtonState,
    })
  }
}

/**
 * Standard dialog button layout, which contains two choices buttons.
 *
 * @secondButtonState the click state of second button.
 */
@Component
export struct DialogButtonLayoutWithState {
  private firstTitle: string | Resource = $r("app.string.cancel");
  private secondTitle: string | Resource = $r("app.string.add");
  private firstClickEvent: (event: ClickEvent) => void;
  private secondClickEvent: (event: ClickEvent) => void;
  @Prop secondButtonState: boolean;

  build() {
    Flex({ direction: FlexDirection.Row, alignItems: Alignment.Center }) {
      Button(this.firstTitle)
        .backgroundColor(Color.White)
        .fontSize($r("app.float.font_16"))
        .fontColor($r("app.color.font_color_007DFF"))
        .fontWeight(FontWeight.Medium)
        .width(ComponentConfig.WH_50_100)
        .onClick((event) => this.firstClickEvent(event))
        .height($r("app.float.wh_value_40"))

      Divider()
        .strokeWidth($r("app.float.wh_value_1"))
        .color($r("sys.color.ohos_id_color_list_separator"))
        .vertical(true)
        .height($r("app.float.wh_value_40"))
        .opacity($r("app.float.opacity_0_2"))

      Button(this.secondTitle)
        .backgroundColor(Color.White)
        .fontSize($r("app.float.font_16"))
        .fontColor($r("app.color.font_color_007DFF"))
        .fontWeight(FontWeight.Medium)
        .width(ComponentConfig.WH_50_100)
        .enabled(this.secondButtonState)
        .opacity(this.secondButtonState ? 1 : 0.5)
        .onClick(event => this.secondClickEvent(event))
        .height($r("app.float.wh_value_40"))
    }
    .margin({ bottom: $r("app.float.wh_value_16") })
  }
}