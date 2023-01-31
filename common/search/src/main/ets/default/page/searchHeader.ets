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
import ResourceUtil from '../common/ResourceUtil';
import ComponentConfig from '../../../../../../component/src/main/ets/default/ComponentConfig';
import LogUtil from '../../../../../../utils/src/main/ets/default/baseUtil/LogUtil';
import Log from '../../../../../../utils/src/main/ets/default/baseUtil/LogDecorator';
import ConfigData from '../../../../../../utils/src/main/ets/default/baseUtil/ConfigData';
import Router from '@system.router'
import InputMethod from '@ohos.inputMethod';

let SEARCH_INPUT_MAX_LENGTH = 100;

/**
 * Search header component
 */
@Component
export default struct SearchHeader {
  @Link inputKeyword: string
  @State placeholderSize: string = ''
  @State placeholder: string = ''
  @State icBackIsTouch: boolean= false;
  @State cancelIsTouch: boolean= false;

  build() {
    Row() {
      Image($r("app.media.ic_back"))
        .width($r('app.float.wh_value_24'))
        .height($r('app.float.wh_value_24'))
        .fillColor($r("sys.color.ohos_id_color_primary"))
        .margin({ right: $r('app.float.wh_value_16') })
        .borderRadius($r("app.float.sys_corner_radius_clicked"))
        .backgroundColor(this.icBackIsTouch ? $r("app.color.color_E3E3E3_grey") : $r("app.color.color_00000000_transparent"))
        .onClick(() => {
          Router.back();
        })
        .onTouch((event: TouchEvent) => {
          if (event.type === TouchType.Down) {
            this.icBackIsTouch = true;
          }
          if (event.type === TouchType.Up) {
            this.icBackIsTouch = false;
          }
        });
      Stack({ alignContent: Alignment.Start }) {
        TextInput({ placeholder: this.placeholder, text: this.inputKeyword })
          .placeholderColor($r("sys.color.ohos_id_color_text_secondary"))
          .placeholderFont({ size: this.placeholderSize, weight: FontWeight.Normal, style: FontStyle.Normal })
          .type(InputType.Normal)
          .caretColor($r("sys.color.ohos_id_color_text_primary_activated"))
          .enterKeyType(EnterKeyType.Search)
          .backgroundColor($r("app.color.white_bg_color"))
          .padding({left:$r('app.float.wh_padding_35')})
          .border({ width: $r('app.float.wh_value_1_5'), color:$r("sys.color.ohos_id_color_fourth"), radius: $r('app.float.wh_value_20') })
          .maxLength(SEARCH_INPUT_MAX_LENGTH)
          .height($r("app.float.search_input_height"))
          .onChange((value: string) => {
            LogUtil.debug(ConfigData.TAG + 'searchPage SearchHeader : text input on change ：value = ' + JSON.stringify(value));
            this.inputKeyword = value
          })
          .onSubmit((enterKey) => {
            InputMethod.getInputMethodController().stopInput().then((ret) => {
              LogUtil.debug(`${ConfigData.TAG}, enterType: ${enterKey}, stopInput: ${ret}`);
            });
          })
        Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
          Image($r("app.media.ic_search"))
            .width($r('app.float.wh_value_18'))
            .height($r('app.float.wh_value_18'))
            .objectFit(ImageFit.Contain)
            .margin({ left: $r('app.float.distance_11') })
          if(this.inputKeyword != '') {
            Image($r("app.media.ic_public_cancel"))
              .width($r('app.float.wh_value_18'))
              .height($r('app.float.wh_value_18'))
              .objectFit(ImageFit.Contain)
              .fillColor($r("sys.color.ohos_id_color_primary"))
              .opacity(0.6)
              .margin({ right: $r('app.float.distance_11') })
              .align(Alignment.End)
              .backgroundColor(this.cancelIsTouch ? $r("app.color.color_E3E3E3_grey") : $r("app.color.color_00000000_transparent"))
              .onClick(() => {
                this.inputKeyword = ''
              })
              .onTouch((event: TouchEvent) => {
              if (event.type === TouchType.Down) {
                this.cancelIsTouch = true;
              }
              if (event.type === TouchType.Up) {
                this.cancelIsTouch = false;
              }
            });
          }
        }
        .hitTestBehavior(HitTestMode.Transparent)
      }
      .width('100%')
    }
    .padding({ left: $r('app.float.wh_value_12'), right: $r('app.float.wh_value_52') })
    .width(ComponentConfig.WH_100_100)
    .height($r("app.float.page_header_height"))
    .alignItems(VerticalAlign.Center)
    .align(Alignment.Start);
  }

  @Log
  aboutToAppear() {
    ResourceUtil.getString($r("app.string.searchHint")).then(value => this.placeholder = value)
    ResourceUtil.getString($r("app.float.search_placeholder_font")).then(value => this.placeholderSize = value);
  }
}