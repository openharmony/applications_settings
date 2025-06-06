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
import SwitchController from './controller/SwitchController';

/**
 * Toggle component
 */
@Component
export default struct SwitchComponent {
  @Link isOn: boolean;
  @State isEnabled?: boolean = true;
  private title: string | Resource = '';
  private controller?: SwitchController;
  private summary?: string | Resource = '';
  private switchHeight: string | number | Resource = '';

  build() {
    Row() {
      Column() {
        Text(this.title)
          .fontColor($r('sys.color.ohos_fa_text_primary'))
          .fontSize($r("app.float.font_16"))
          .fontWeight(FontWeight.Medium)

        if (this.summary) {
          Text(this.summary)
            .fontColor($r('sys.color.ohos_fa_text_secondary'))
            .fontSize($r('sys.float.ohos_id_text_size_body2'))
            .fontWeight('sans-serif')
            .textAlign(TextAlign.Start)
            .maxLines(ComponentConfig.MAX_LINES_1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({ top: $r('sys.float.ohos_id_text_margin_vertical') })
        }
      }
      .alignItems(HorizontalAlign.Start)

      Blank()

      Stack({ alignContent: Alignment.Start }) {
        Toggle({ type: ToggleType.Switch, isOn: this.isOn })
          .width('36vp')
          .height('20vp')
          .margin({ left: $r('app.float.wh_value_6') })
          .selectedColor('#007DFF')
          .onChange((isOn: boolean) => {
            if (!this.isEnabled) return;
            this.isOn = new Boolean(isOn).valueOf();
            this.toggleValue(this.isOn);
          });
      }
    }
    .padding({ left: $r('app.float.distance_12'), right: $r('app.float.distance_8') })
    .width(ComponentConfig.WH_100_100)
    .height(this.switchHeight)
    .backgroundColor($r("app.color.white_bg_color"))
    .alignItems(VerticalAlign.Center)
    .borderRadius($r("app.float.radius_16"))
  }

  aboutToAppear() {
    if (this.controller) {
      this.toggleValue = this.controller.onSelfToggleValueBindThis;

      // bind component and initialize
      this.controller.bindComponent(this)
        .bindProperties(["isOn", "isEnabled"])
        .initData()
        .subscribe();
    }
  }

  aboutToDisappear() {
    this.controller?.unsubscribe();
  }

  private toggleValue: (isOn: boolean) => void = () => {
  };
}