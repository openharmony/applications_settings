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
    Row() {
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
            .margin({ top: $r('sys.float.ohos_id_text_margin_vertical') })
        }
      }
      .margin({ left: $r('app.float.wh_24') })
      .alignItems(HorizontalAlign.Start)

      Blank()

      Stack({ alignContent: Alignment.Center }) {
        Toggle({ type: ToggleType.Switch, isOn: this.isOn })
          .width('36vp')
          .height('20vp')
          .margin({ left: '6vp' })
          .selectedColor('#007DFF')
          .onChange((isOn: boolean) => {
            if (!this.enabled) return;
            this.isOn = new Boolean(isOn).valueOf();
            this.toggleValue(this.isOn);
          });
      }
      .margin({ right: $r('app.float.wh_24') })
      .width($r('app.float.wh_value_48'))
      .height($r('app.float.wh_value_56'))
    }
    .width(ComponentConfig.WH_100_100)
    .height(this.summary ? $r('app.float.wh_value_72') : $r('app.float.wh_value_56'))
    .backgroundColor($r("app.color.white_bg_color"))
    .padding({ top: $r("app.float.wh_value_4"), bottom: $r("app.float.wh_value_4") })
    .alignItems(VerticalAlign.Center)
    .borderRadius($r("app.float.wh_value_24"))
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