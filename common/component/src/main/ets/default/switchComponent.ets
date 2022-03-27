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
import SwitchController from './controller/SwitchController'
import Log from '../../../../../utils/src/main/ets/default/baseUtil/LogDecorator';

/**
 * Toggle component
 */
@Component
export default struct SwitchComponent {
  @Link isOn: boolean;
  @Prop title: string;
  private toggleValue: (isOn: boolean) => void;
  private controller: SwitchController;
  private summary?: string;
  @State enabled?: boolean = true;
  private cssValue: {
    fontSize?: number | string | Resource,
    summaryFontSize?: number | string | Resource,
    height?: number | string | Resource,
    width?: number | string | Resource,
    backgroundColor?: number | string | Resource,
    borderRadius?: number | string | Resource,
    margin?: {
      top?: number | string | Resource,
      right?: number | string | Resource,
      bottom?: number | string | Resource,
      left?: number | string | Resource
    } | number | string | Resource,
    padding: {
      top?: number | string | Resource,
      right?: number | string | Resource,
      bottom?: number | string | Resource,
      left?: number | string | Resource
    } | number | string | Resource,
  };

  build() {
    Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
      Column() {
        Text(this.title)
          .fontColor($r('sys.color.ohos_fa_text_primary'))
          .fontStyle(FontStyle.Normal)
          .fontSize(this.cssValue?.fontSize)
        if (this.summary) {
          Row() {
            Text(this.summary)
              .fontColor($r('app.color.font_color_182431'))
              .fontSize(this.cssValue?.summaryFontSize)
              .textAlign(TextAlign.Start)
          }.padding({ top: $r("app.float.switch_summary_margin") })
        }
      }
      .padding({ left: $r('sys.float.ohos_id_max_padding_start'), })
      .alignItems(HorizontalAlign.Start)

      Toggle({ type: ToggleType.Switch, isOn: this.isOn })
        .width($r('app.float.switch_toggle_width'))
        .height($r('app.float.switch_toggle_height'))
        .padding({ right: $r('app.float.distance_24') })
        .enabled(this.enabled)
        .onChange((isOn: boolean) => {
          if (!this.enabled) return;
          this.isOn = new Boolean(isOn).valueOf();
          if (this.toggleValue) {
            this.toggleValue(isOn);
          }
        });
    }
    .width(this.cssValue?.width)
    .height(this.cssValue?.height)
    .backgroundColor(this.cssValue?.backgroundColor)
    .margin(this.cssValue?.margin)
    .padding(this.cssValue?.padding)
    .borderRadius(this.cssValue?.borderRadius);
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