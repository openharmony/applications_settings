// @ts-nocheck
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
import InputMethod from '@ohos.inputmethod';

let SEARCH_INPUT_MAX_LENGTH = 100;

/**
 * Search header component
 */
@Component
export default struct SearchHeader {
  @Link inputKeyword: string
  @State placeholderSize: string = ''
  @State placeholder: string = ''
  @State isTouch: boolean= false;

  build() {
    Row() {
      Image($r("app.media.ic_back"))
        .width($r("app.float.square_click_image_size"))
        .height($r("app.float.square_click_image_size"))
        .padding({
          top: $r("app.float.sys_elements_margin_vertical_l"),
          bottom: $r("app.float.sys_elements_margin_vertical_l"),
          left: $r("app.float.sys_elements_margin_horizontal_l"),
          right: $r("app.float.sys_elements_margin_horizontal_l"),
        })
        .borderRadius($r("app.float.sys_corner_radius_clicked"))
        .backgroundColor(this.isTouch ? $r("app.color.color_E3E3E3_grey") : $r("app.color.color_00000000_transparent"))
        .onClick(()=>{
          Router.back();
        })
        .onTouch((event: TouchEvent) => {
          if (event.type === TouchType.Down) {
            this.isTouch = true;
          }
          if (event.type === TouchType.Up) {
            this.isTouch = false;
          }
        });

      // text input
      TextInput({ placeholder: this.placeholder })
        .placeholderFont({ size: this.placeholderSize, weight: FontWeight.Normal, style: FontStyle.Normal })
        .type(InputType.Normal)
        .enterKeyType(EnterKeyType.Search)
        .caretColor(Color.Blue)
        .maxLength(SEARCH_INPUT_MAX_LENGTH)
        .layoutWeight(1)
        .height($r("app.float.search_input_height"))
        .onChange((value: string) => {
          LogUtil.debug(ConfigData.TAG + 'searchPage SearchHeader : text input on change ：value = ' + JSON.stringify(value));
          this.inputKeyword = value
        })
        .onSubmit((enterKey) => {
          InputMethod.getInputMethodController().stopInput().then((ret) => {
            LogUtil.debug( `${ConfigData.TAG}, enterType: ${enterKey}, stopInput: ${ret}`);
          });
        })

    }
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