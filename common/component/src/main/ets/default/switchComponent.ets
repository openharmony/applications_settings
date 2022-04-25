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
import ComponentConfig from './ComponentConfig';
import SwitchController from './controller/SwitchController'
import Log from '../../../../../utils/src/main/ets/default/baseUtil/LogDecorator';

/**
 * Toggle component
 */
@Component
export default struct SwitchComponent {
  @Link isOn: boolean;
  private title: string | Resource;
  private toggleValue: (isOn: boolean) => void;
  private controller: SwitchController;
  private summary?: string | Resource;
  @State enabled?: boolean = true;
  private cssValue: {
    margin?: {
      top?: number | string | Resource,
      right?: number | string | Resource,
      bottom?: number | string | Resource,
      left?: number | string | Resource
    } | number | string | Resource
  };

  build() {
    Row() {//{ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
      Column() {
        Text(this.title)
          .fontColor($r('sys.color.ohos_fa_text_primary'))
          .fontSize($r("app.float.font_16"))
          .fontStyle(FontStyle.Normal)
        if (this.summary) {
          Text(this.summary)
            .fontColor($r('sys.color.ohos_fa_text_secondary'))
            .fontSize($r('sys.float.ohos_id_text_size_body2'))
            .fontWeight('sans-serif')
            .textAlign(TextAlign.Start)
            .maxLines(ComponentConfig.MAX_LINES_1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({ top:$r('sys.float.ohos_id_text_margin_vertical') })
        }
      }
      .alignItems(HorizontalAlign.Start)

      Blank()

      Stack({ alignContent: Alignment.Center }) {
        Toggle({ type: ToggleType.Switch, isOn: this.isOn })
          .width($r('app.float.switch_toggle_width'))
          .height($r('app.float.switch_toggle_height'))
          .onChange((isOn: boolean) => {
            if (!this.enabled) return;
            this.isOn = new Boolean(isOn).valueOf();
            this.toggleValue(this.isOn);
          });
      }
      .width($r('app.float.wh_value_48'))
      .height($r('app.float.wh_value_48'))
    }
    .width(ComponentConfig.WH_100_100)
    .height(this.summary ? $r('app.float.wh_value_64') : $r('app.float.wh_value_56'))
    .backgroundColor($r("app.color.white_bg_color"))
    .margin(this.cssValue?.margin)
    .padding({
      left: $r('sys.float.ohos_id_default_padding_start'),
      right: $r('sys.float.ohos_id_default_padding_end')
    })
    .alignItems(VerticalAlign.Center)
    .borderRadius($r('sys.float.ohos_id_corner_radius_default_xl'))
  }

  @Log
  aboutToAppear() {
    if (this.controller) {
      // bind event handlers
      this.toggleValue = this.controller.toggleValue.bind(this.controller);

      // bind component and initialize
      this.controller.bindComponent(this)
        .bindProperties(["isOn", "enabled"])
        .initData()
        .subscribe();
    }
  }

  @Log
  aboutToDisappear() {
    this.controller.unsubscribe();
  }
}