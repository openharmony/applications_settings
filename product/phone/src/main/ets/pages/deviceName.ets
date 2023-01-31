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

import prompt from "@ohos.prompt";
import Router from '@system.router';
import InputMethod from '@ohos.inputMethod';
import AboutDeviceModel from '../model/aboutDeviceImpl/AboutDeviceModel';
import LogUtil from '../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import ConfigData from '../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData';
import HeadComponent from '../../../../../../common/component/src/main/ets/default/headComponent';
import ResourceUtil from '../../../../../../common/search/src/main/ets/default/common/ResourceUtil';
import bluetooth from '@ohos.bluetooth';

/**
 * about phone
 */
@Entry
@Component
struct DeviceName {
  @State deviceName: string = AboutDeviceModel.getSystemName();
  @State isFocused: boolean = false ;
  @State cancelButton : boolean = true;
  @State confirmsButton : boolean = false;
  private deviceInfo: any = '';
  private aboutDeviceList: any[] = [];

  build() {
    Column() {
      GridContainer({ gutter: ConfigData.GRID_CONTAINER_GUTTER_24, margin: ConfigData.GRID_CONTAINER_MARGIN_24 }) {
        Column() {
          HeadComponent({ headName: $r('app.string.deviceName'), isActive: true })

          TextInput({ text: this.deviceName })
            .placeholderFont({
              size: $r("app.float.font_18"),
              weight: FontWeight.Normal,
              style: FontStyle.Normal
            })
            .type(InputType.Normal)
            .enterKeyType(EnterKeyType.Done)
            .caretColor($r('app.color.font_color_007DFF'))
            .maxLength(30)
            .fontColor($r("sys.color.ohos_id_color_primary"))
            .height($r("app.float.wh_value_40"))
            .borderRadius(0)
            .margin({ top: $r("app.float.distance_8") })
            .backgroundColor($r('app.color.color_00000000_transparent'))
            .onFocus(() => {
              this.isFocused = true;
            })
            .onChange((value: string) => {
              LogUtil.debug(ConfigData.TAG + 'device name changed to: ' + JSON.stringify(value));
              if (value.trim().length != 0) {
                this.deviceName = value;
                this.confirmsButton = true;
              } else {
                this.deviceName = value.trim();
                this.confirmsButton = false;
              }

              if (this.deviceName.length == 30) {
                this.isFocused = false;
                ResourceUtil.getString($r("app.string.Input_Reached_Limited"))
                  .then(value => {
                    prompt.showToast({
                      message: value,
                      duration: 2000,
                      bottom: 100
                    })
                  })
              }
            })
            .onSubmit((enterKey) => {
              InputMethod.getInputMethodController().stopInput()
                .then((ret) => {
                  LogUtil.debug(`${ConfigData.TAG}, enterType: ${enterKey}, stopInput: ${ret}`);
                });
            })

          Divider()
            .strokeWidth(1)
            .padding({ left: $r('app.float.wh_value_12'), right: $r('app.float.wh_value_12') })
            .color($r("sys.color.ohos_id_color_primary"))
            .opacity($r('sys.float.ohos_id_alpha_content_secondary'))

          Flex({ justifyContent: FlexAlign.SpaceBetween }) {
            Row() {
              ButtonComponent({
                text: $r("app.string.cancel"),
                deviceName: $deviceName,
                buttonFlag: $cancelButton,
                onClickEvent: () => {
                  Router.back();
                }
              })
                .layoutWeight(ConfigData.LAYOUT_WEIGHT_1)

              Column()
                .width($r('app.float.distance_12'))
                .height($r('app.float.application_button_height'))

              ButtonComponent({
                text: $r("app.string.confirm"),
                deviceName: $deviceName,
                buttonFlag: $confirmsButton,
                onClickEvent: () => {
                  if (this.deviceName.length > 0) {
                    AboutDeviceModel.setSystemName(this.deviceName);
                    let name = bluetooth.getLocalName();
                    if (name != this.deviceName) {
                      bluetooth.setLocalName(this.deviceName);
                    }
                    Router.back();
                  } else {
                    return;
                  }
                }
              })
                .layoutWeight(ConfigData.LAYOUT_WEIGHT_1)
            }
            .alignItems(this.isFocused ? VerticalAlign.Top : VerticalAlign.Bottom)
            .height(ConfigData.WH_100_100)
            .padding(this.isFocused ? { top: $r("app.float.wh_value_212") } : { bottom: $r('app.float.wh_padding_128') })
          }
          .width(ConfigData.WH_100_100)
        }
        .useSizeType({
          sm: { span: 4, offset: 0 },
          md: { span: 6, offset: 1 },
          lg: { span: 8, offset: 2 }
        })
      }
      .width(ConfigData.WH_100_100)
      .height(ConfigData.WH_100_100)
    }
    .backgroundColor($r("sys.color.ohos_id_color_sub_background"))
    .width(ConfigData.WH_100_100)
    .height(ConfigData.WH_100_100)
  }
}

@Component
struct ButtonComponent {
  @Link deviceName: string ;
  @Link buttonFlag : boolean;
  private text;
  private onClickEvent = () => {};

  build() {
    Button({ type: ButtonType.Capsule, stateEffect: true }) {
      Text(this.text)
        .width(ConfigData.WH_100_100)
        .fontSize($r('app.float.font_16'))
        .fontWeight(FontWeight.Medium)
        .lineHeight($r('app.float.wh_value_22'))
        .fontColor($r('app.color.font_color_007DFF'))
        .textAlign(TextAlign.Center)
        .height($r("app.float.wh_value_40"))
        .borderRadius($r('app.float.radius_20'))
        .onTouch((event: TouchEvent) => {
          if(this.deviceName.length === 0 && this.buttonFlag != true){
            return;
          }
        })
        .onClick(() => {
          this.onClickEvent();
        })
    }
    .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
    .opacity(this.deviceName.length === 0 && this.buttonFlag != true ? $r('sys.float.ohos_fa_alpha_disabled') : 1)
    .width(ConfigData.WH_100_100)
  }
}
