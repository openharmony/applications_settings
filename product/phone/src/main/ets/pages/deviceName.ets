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
import LogUtil from '../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import ConfigData from '../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData';
import HeadComponent from '../../../../../../common/component/src/main/ets/default/headComponent';
import AboutDeviceModel from '../model/aboutDeviceImpl/AboutDeviceModel'
import Router from '@system.router';
import InputMethod from '@ohos.inputmethod';
import prompt from "@ohos.prompt"
import ResourceUtil from '../../../../../../common/search/src/main/ets/default/common/ResourceUtil';
/**
 * about phone
 */
@Entry
@Component
struct DeviceName {
  @State deviceName: string = AboutDeviceModel.getSystemName();
  private deviceInfo: any = '';
  private aboutDeviceList: any[] = [];
  @State isFocused: boolean = false ;
  @State cancelButton : boolean = true;
  @State confirmsButton : boolean = false;

  build() {
    Column() {
      GridContainer({ gutter: 12, margin: 12 }) {
        Column() {
          HeadComponent({ headName: $r('app.string.deviceName'), isActive: true })

          TextInput({ text: this.deviceName })
            .placeholderFont({ size: $r("app.float.font_18"), weight: FontWeight.Normal, style: FontStyle.Normal })
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
              if(value.trim().length != 0){
                this.deviceName = value;
                this.confirmsButton = true
              } else {
                this.deviceName = value.trim();
                this.confirmsButton = false
              }
              if (this.deviceName.length == 30) {
                this.isFocused = false
                ResourceUtil.getString($r("app.string.Input_Reached_Limited")).then(value => {
                  prompt.showToast({
                    message:value,
                    duration: 2000,
                    bottom: 1000
                  })
                })
              }
            })
            .onSubmit((enterKey) => {
              InputMethod.getInputMethodController().stopInput().then((ret) => {
                LogUtil.debug(`${ConfigData.TAG}, enterType: ${enterKey}, stopInput: ${ret}`);
              });
            })
          Divider()
            .strokeWidth(1)
            .padding({ left: $r('app.float.wh_value_12'), right: $r('app.float.wh_value_12') })
            .color($r("sys.color.ohos_id_color_primary"))
            .opacity($r('sys.float.ohos_id_alpha_content_secondary'))
          Row() {
            Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
              Row() {
                ButtonComponent({ text: $r("app.string.cancel"),deviceName : $deviceName ,buttonFlag : $cancelButton, onClickEvent: () => {
                  Router.back();
                } })
              }
              .width($r("app.float.deviceName_button_width"))

              .margin({ right: $r("app.float.distance_12") })

              Row() {
                ButtonComponent({ text: $r("app.string.confirm"),deviceName : $deviceName ,buttonFlag : $confirmsButton,onClickEvent: () => {
                  if(this.deviceName.length >0){
                    AboutDeviceModel.setSystemName(this.deviceName)
                    Router.back();
                  } else {
                    return
                  }

                }})
              }
              .width($r("app.float.deviceName_button_width"))
            }
          }
          .alignItems(this.isFocused ? VerticalAlign.Top : VerticalAlign.Bottom)
          .height('100%')
          .padding(this.isFocused ? { top: $r("app.float.wh_value_212") } : { bottom: $r('app.float.wh_padding_128') })
        }
        .useSizeType({
          sm: { span: 4, offset: 0 },
          md: { span: 6, offset: 1 },
          lg: { span: 8, offset: 2 }
        });
      }
    }
    .backgroundColor($r("sys.color.ohos_id_color_sub_background"))
    .width(ConfigData.WH_100_100)
    .height(ConfigData.WH_100_100);
  }
}


@Component
struct ButtonComponent {
  @State isTouched: boolean = false;
  @Link deviceName: string ;
  @Link buttonFlag : boolean;
  private text;
  private onClickEvent = () => {
  };

  build() {
    Column() {
      Text(this.text)
        .fontSize($r('app.float.font_16'))
        .fontWeight(FontWeight.Medium)
        .lineHeight($r('app.float.wh_value_22'))
        .fontColor($r('app.color.font_color_007DFF'))
        .textAlign(TextAlign.Center)
        .width($r('app.float.deviceName_button_width'))
        .height($r("app.float.wh_value_40"))
        .borderRadius($r('app.float.radius_20'))
        .backgroundColor(!this.isTouched ? $r('sys.color.ohos_id_color_button_normal') : $r("sys.color.ohos_id_color_foreground_contrary"))
        .onTouch((event: TouchEvent) => {
          if(this.deviceName.length === 0 && this.buttonFlag != true){
            return
          } else {
            if (event.type === TouchType.Down) {
              this.isTouched = true;
            }
            if (event.type === TouchType.Up) {
              this.isTouched = false;
            }
          }
        })
        .onClick(() => {
          this.onClickEvent();
        })
    }
    .opacity(this.deviceName.length === 0 && this.buttonFlag != true ? $r('sys.float.ohos_fa_alpha_disabled') : 1)
    .width(ConfigData.WH_100_100)
  }
}
