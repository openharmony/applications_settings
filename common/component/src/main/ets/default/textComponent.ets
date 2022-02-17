/**
 * Copyright (c) 2021 Huawei Device Co., Ltd.
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
import ComponentConfig from './ComponentConfig.ets';

/**
 * Single title text with round corner.
 */
@Component
export struct TitleText {
  private title: string | Resource;
  private color: Color = Color.Black;
  private visibility: Visibility = Visibility.Visible;
  private clickEvent: (event?: ClickEvent) => void;
  @State isTouched: boolean = false;

  build() {
    Row() {
      Row() {
        Text(this.title)
          .fontSize($r("app.float.font_28"))
          .fontColor(this.color)
          .height($r("app.float.wh_value_60"))
          .textAlign(TextAlign.Start)
      }
      .width(ComponentConfig.WH_100_100)
      .padding({left: $r("app.float.distance_24"), right: $r("app.float.distance_24")})
      .borderRadius($r("app.float.radius_24"))
      .backgroundColor(this.isTouched? $r("app.color.color_D8D8D8_grey"):$r("app.color.white_bg_color"))
      .onClick(event => this.clickEvent(event))
      .onTouch((event: TouchEvent) => {
        if (event.type === TouchType.Down) {
          this.isTouched = true;
        }
        if (event.type === TouchType.Up) {
          this.isTouched = false;
        }
      })
    }
    .width(ComponentConfig.WH_100_100)
    .margin({top: $r("app.float.distance_8"), bottom: $r("app.float.distance_8")})
    .borderRadius($r("app.float.radius_24"))
    .backgroundColor($r("app.color.white_bg_color"))
    .visibility(this.visibility)
    .padding($r('app.float.distance_4'))
  }
}