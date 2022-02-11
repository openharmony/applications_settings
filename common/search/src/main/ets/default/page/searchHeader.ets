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
import ResourceUtil from '../common/ResourceUtil.ets';
import LogUtil from '../../../../../../utils/src/main/ets/default/baseUtil/LogUtil.ets';
import Log from '../../../../../../utils/src/main/ets/default/baseUtil/LogDecorator.ets';
import ConfigData from '../../../../../../utils/src/main/ets/default/baseUtil/ConfigData.ets';
import Router from '@system.router'

/**
 * Search header component
 */
@Component
export default struct SearchHeader {
  @Link inputKeyword: string
  @State placeholder: string = ''

  build() {
    Row() {

      // back
      Image($r('app.media.ic_back'))
        .width($r('app.float.wh_value_50'))
        .height($r('app.float.wh_value_50'))
        .objectFit(ImageFit.Contain)
        .onClick(() => {
          LogUtil.debug(ConfigData.TAG + 'searchPage SearchHeader : back clicked.');
          Router.back()
        })

      // text input
      Stack({ alignContent: Alignment.End }) {
        TextInput({ placeholder: this.placeholder })
          .margin({
            left: $r('app.float.search_input_horizontal_margin'),
            right: $r('app.float.search_input_horizontal_margin')
          })
          .placeholderFont({size:10,weight:FontWeight.Normal,style:FontStyle.Normal})
          .type(InputType.Normal)
          .enterKeyType(EnterKeyType.Search)
          .layoutWeight(1)
          .height($r("app.float.search_input_height"))
          .borderRadius($r("app.float.search_input_border_radius"))
          .backgroundColor(Color.White)
          .onChange((value: string) => {
            LogUtil.debug(ConfigData.TAG + 'searchPage SearchHeader : text input on change ：value = ' + JSON.stringify(value));
            this.inputKeyword = value
          })

        if (this.inputKeyword) {

          // input text clear
          Text('×')
            .fontSize($r('app.float.font_28'))
            .width($r('app.float.wh_value_60'))
            .height($r('app.float.wh_value_60'))
            .backgroundColor($r('app.color.color_00000000_transparent'))
            .textAlign(TextAlign.Center)
            .onClick(() => {
              LogUtil.debug(ConfigData.TAG + 'searchPage SearchHeader : clear search key clicked.');
              this.inputKeyword = ''
            })
        }
      }
    }
    .height($r('app.float.page_header_height'))
    .padding({ left: $r('app.float.wh_value_15'), right: $r('app.float.wh_value_60') })
  }

  @Log
  aboutToAppear() {
    ResourceUtil.getString($r("app.string.searchHint")).then(value => this.placeholder = value)
  }
}