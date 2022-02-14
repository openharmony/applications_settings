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
import LogUtil from '../../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil.ets';
import ConfigData from '../../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData.ets';
import EntryComponent from '../../../../../../../common/component/src/main/ets/default/entryComponent.ets';
import HeadComponent from '../../../../../../../common/component/src/main/ets/default/headComponent.ets';
import SettingListModel from '../model/settingListImpl/SettingListModel.ets';
import WifiModel from '../model/wifiImpl/WifiModel.ets';
import ResourceUtil from '../../../../../../../common/search/src/main/ets/default/common/ResourceUtil.ets';
import Router from '@system.router';

const PAGE_SEARCH = 'pages/searchPage'; // for search

/**
 * setting home page
 */
@Entry
@Component
struct SettingList {
  settingsList: any[]= SettingListModel.getSettingList();
  @State wifiStatus: boolean= false;
  @State status: any= '';
  @State placeholder: string= ''; // for search
  @State placeholdersize: string = '22'

  build() {
    Column() {
      HeadComponent({ icBackIsVisibility: false, headName: $r('app.string.settings'), isActive: false });

      // for search
      Navigator({ target: PAGE_SEARCH }) {
        TextInput({ placeholder: this.placeholder, text: '' })
          .placeholderFont({ size:this.placeholdersize, weight:FontWeight.Normal,style:FontStyle.Normal})
          .type(InputType.Normal)
          .enterKeyType(EnterKeyType.Search)
          .caretColor(Color.Green)
          .layoutWeight(1)
          .height($r("app.float.search_input_height"))
          .borderRadius($r("app.float.search_input_border_radius"))
          .backgroundColor(Color.White)
          .enabled(false)
      }
      .margin({bottom:$r('app.float.distance_24') })
      .onClick(() => {
        LogUtil.info('On click the search editText.');
        Router.push({
          uri: PAGE_SEARCH
        })
      })

      List({space: 10, initialIndex: 0}) {
        ForEach(this.settingsList, (moduleBlock) => {
          ListItem() {
            List(){
              ForEach(moduleBlock, (item) => {
                ListItem(){
                  EntryComponent({
                    settingIcon: item.settingIcon,
                    settingTitle: item.settingTitle,
                    settingSummary: item.settingSummary,
                    settingValue: item.settingValue,
                    settingArrow: item.settingArrow,
                    settingArrowStyle: '',
                    settingUri: item.settingUri
                  });
                }
                .onClick(() => {
                  Router.push({
                    uri: item.settingUri,
                  });
                })
              })
            }
            .divider({
              strokeWidth: 1,
              color: $r('app.color.color_E3E3E3_grey'),
              startMargin: $r('app.float.wh_value_65'),
              endMargin: $r('app.float.wh_value_20')
            })
          }
          .borderRadius($r("app.float.radius_24"))
          .backgroundColor($r("app.color.white_bg_color"))
          .padding($r('app.float.distance_4'))
        });
      }
      .width(ConfigData.WH_100_100)
      .height(ConfigData.WH_100_100)
      .alignSelf(ItemAlign.Start);
    }
    .padding({left:$r('app.float.distance_24'), right:$r('app.float.distance_24')})
    .align(Alignment.Start)
    .width(ConfigData.WH_100_100)
    .height(ConfigData.WH_100_100)
    .backgroundColor($r("app.color.color_D8D8D8_grey"));
  }

  aboutToAppear() {
    LogUtil.info('settings SettingList aboutToAppear enter');
    ResourceUtil.getString($r("app.string.searchHint")).then(value => this.placeholder = value) // for search
    ResourceUtil.getString($r("app.float.search_placeholder_font")).then(value => this.placeholdersize = value);
    LogUtil.info('settings SettingList aboutToAppear end');
  }

  onPageShow(): void{
    this.wifiStatus = WifiModel.isWiFiActive();
    if (this.wifiStatus) {
      this.status = $r('app.string.enabled');
    } else {
      this.status = $r('app.string.disabled');
    }
    LogUtil.info('settings SettingList onPageShow this.wifiStatus:' + this.wifiStatus);
    this.settingsList.unshift([{
      "settingIcon": "/res/image/ic_settings_wifi.svg",
      "settingTitle": $r('app.string.wifiTab'),
      "settingAlias": '',
      "settingValue": this.status,
      "settingArrow": "/res/image/ic_settings_arrow.svg",
      "settingSummary": "",
      "settingUri": "pages/wifi"
       },]);
    this.settingsList.splice(1, 1);
    LogUtil.info('settings SettingList onPageShow out:' + +JSON.stringify(this.settingsList));
  }

}