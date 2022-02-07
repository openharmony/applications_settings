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
import SwitchController from './controller/switchController.ets'

/**
 * Toggle component
 */
@Component
export default struct SwitchComponent {
  @Link isOn: boolean;
  @Prop title: string;
  private toggleValue: (isOn: boolean) => void;
  private controller: SwitchController;
  private cssValue: {
    fontSize?: number | string | Resource,
    height?: number | string | Resource,
    width?: number | string | Resource,
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
      Text(this.title)
        .cssSwitchComponentTiTle(this.cssValue?.fontSize)
      Toggle({ type: ToggleType.Switch, isOn: this.isOn })
        .cssSwitchComponentToggle()
        .onChange((isOn: boolean) => {
          this.isOn = new Boolean(isOn).valueOf();
          if (this.toggleValue) {
            this.toggleValue(isOn);
          }
        });
    }
    .cssSwitchComponentFlex(this.cssValue?.margin, this.cssValue?.padding, this.cssValue?.width, this.cssValue?.height);
  }

  aboutToAppear() {
    if (this.controller) {
      // bind event handlers
      this.toggleValue = this.controller.toggleValue.bind(this.controller);

      // bind component and initialize
      this.controller.bindComponent(this)
        .bindProperties(["isOn"])
        .initData();
    }
  }
}

@Extend(Text) function cssSwitchComponentTiTle (fontSize: number | string | Resource=$r('app.float.switch_title_subtitle_size')) {
  .fontColor(Color.Black)
  .fontStyle(FontStyle.Normal)
  .padding({ left: $r('app.float.switch_component_margin') })
  .fontSize(fontSize)
}

@Extend(Toggle) function cssSwitchComponentToggle () {
  .width($r('app.float.switch_toggle_width'))
  .height($r('app.float.switch_toggle_height'))
  .padding({ right: $r('app.float.switch_component_margin') })
}

@Extend(Flex) function cssSwitchComponentFlex (margin: any, padding: any, width: number | string | Resource=ComponentConfig.WH_100_100, height: number | string | Resource=$r('app.float.switch_component_height')) {
  .width(width)
  .height(height)
  .margin(margin)
  .padding(padding)
}