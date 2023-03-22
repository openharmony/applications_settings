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

import Router from '@system.router';
import deviceInfo from '@ohos.deviceInfo';
import parameter from '@ohos.systemparameter';
import FeatureAbility from '@ohos.ability.featureAbility';
import WifiModel from '../model/wifiImpl/WifiModel';
import BluetoothModel from '../model/bluetoothImpl/BluetoothModel';
import SettingListModel from '../model/settingListImpl/SettingListModel';
import LogUtil from '../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import ConfigData from '../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData';
import ResourceUtil from '../../../../../../common/search/src/main/ets/default/common/ResourceUtil';
import {SettingItemComponent} from '../../../../../../common/component/src/main/ets/default/settingItemComponent';
import GlobalResourceManager from '../../../../../../common/utils/src/main/ets/default/baseUtil/GlobalResourceManager';

const deviceTypeInfo = deviceInfo.deviceType;

@Extend(ListItem) function settingListItemFancy() {
  .width(ConfigData.WH_100_100)
  .borderRadius($r("app.float.radius_24"))
  .backgroundColor($r("sys.color.ohos_id_color_foreground_contrary"))
  .padding($r('app.float.distance_4'))
}

@Extend(List) function settingListItemDividerFancy() {
  .divider({
    strokeWidth: $r('app.float.divider_wh'),
    color: $r('sys.color.ohos_id_color_list_separator'),
    startMargin: $r('app.float.wh_value_48'),
    endMargin: $r('app.float.wh_value_8')
  })
}

/**
 * setting home page
 */
@Entry
@Component
struct SettingList {
  @State placeholder: string= ''; // for search
  @State placeholderSize: string = '22';
  @State listSpaces: string = '12vp';
  @State isPhone: boolean = false;
  @StorageLink('bluetoothIsOn') bluetoothIsOn: boolean = false;

  @Builder NavigationTitle() {
    Column() {
      Text($r('app.string.settings'))
        .width(ConfigData.WH_100_100)
        .height($r('app.float.wh_value_56'))
        .fontColor($r("sys.color.ohos_id_color_text_primary"))
        .fontSize($r('app.float.font_30'))
        .fontWeight(FontWeight.Medium)
    }
  }

  build() {
    Column() {
      GridContainer({ gutter: ConfigData.GRID_CONTAINER_GUTTER_24, margin: ConfigData.GRID_CONTAINER_MARGIN_24 }) {
        Column() {
          if (this.isPhone) {
            Navigation() {
              EntryComponent({ listSpaces: this.listSpaces, isPhone: this.isPhone })
            }
            .title(this.NavigationTitle)
            .titleMode(NavigationTitleMode.Free)
            .hideTitleBar(false)
            .hideBackButton(true)
          } else {
            EntryComponent({ listSpaces: this.listSpaces })
          }
        }
        .useSizeType({
          xs: { span: 2, offset: 0 },
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

  aboutToAppear() {
    LogUtil.info('CCCC settings SettingList aboutToAppear enter');
    ResourceUtil.getString($r("app.string.searchHint")).then(value => this.placeholder = value);// for search
    ResourceUtil.getString($r("app.float.search_placeholder_font")).then(value => this.placeholderSize = value);
    ResourceUtil.getString($r('app.float.distance_12')).then(value => this.listSpaces = value);

    let nYear = GlobalResourceManager.getStringByResource($r('app.string.year'));
    nYear.then(resp => AppStorage.SetOrCreate(ConfigData.DATE_AND_TIME_YEAR, resp));

    let nMonth = GlobalResourceManager.getStringByResource($r('app.string.month'));
    nMonth.then(resp => AppStorage.SetOrCreate(ConfigData.DATE_AND_TIME_MONTH, resp));

    let nDay = GlobalResourceManager.getStringByResource($r('app.string.day'));
    nDay.then(resp => AppStorage.SetOrCreate(ConfigData.DATE_AND_TIME_DAY, resp));

    if (deviceTypeInfo === 'phone') {
      this.isPhone = true;
    } else {
      this.isPhone = false;
    }
    LogUtil.info('CCCC settings SettingList aboutToAppear end');
  }

  onPageShow() {
    LogUtil.info('CCCC settings SettingList onPageShow enter');
    FeatureAbility.getWant().then((want) => {
      if (want.uri === "wifi") {
        Router.replace({ uri: "pages/wifi" });
      } else if (want.uri === "bluetooth") {
        Router.replace({ uri: "pages/bluetooth" });
      } else if (want.uri === "volumeControl") {
        Router.replace({ uri: "pages/volumeControl" });
      } else if (want.uri === "locationServices") {
        Router.replace({ uri: "pages/locationServices" });
      }
    })
    LogUtil.info('CCCC settings SettingList onPageShow end');
  }
}

@Component
struct EntryComponent {
  @StorageLink('wifiStatus') @Watch("wifiStatusChange") wifiStatus: boolean = WifiModel.isWiFiActive();
  @StorageLink('bluetoothIsOn') @Watch("bluetoothIsOnChange") bluetoothIsOn: boolean = false;
  @StorageLink("wifiStatusInfo") wifiStatusInfo: Resource = WifiModel.isWiFiActive() ? $r("app.string.enabled") : $r("app.string.disabled");
  @StorageLink("bluetoothStatusInfo") bluetoothStatusInfo: Resource = $r("app.string.disabled");
  @StorageLink("endTextEmpty") endTextEmpty: any = $r("app.string.endTextEmpty");
  private nfcInfo: boolean;
  private listSpaces: string = '12vp';
  private isPhone: boolean = false;
  private info: string;

  wifiStatusChange() {
    AppStorage.SetOrCreate("wifiStatusInfo", this.wifiStatus ? $r("app.string.enabled") : $r("app.string.disabled"))
  }

  bluetoothIsOnChange() {
    AppStorage.SetOrCreate("bluetoothStatusInfo", this.bluetoothIsOn ? $r("app.string.enabled") : $r("app.string.disabled"))
  }

  aboutToAppear() {
    LogUtil.info('CCCC settings SettingList EntryComponent aboutToAppear in');
    SettingListModel.registerObserver();
    this.bluetoothIsOn = BluetoothModel.isStateOn();
    BluetoothModel.subscribeStateChange((isOn: boolean) => {
      AppStorage.SetOrCreate('bluetoothIsOn', isOn);
    });

    this.info = parameter.getSync("const.SystemCapability.Communication.NFC.Core" ,"false");
    LogUtil.info('CCCC settings SettingList EntryComponent aboutToAppear out');
  }

  build() {
    Column() {
      if (!this.isPhone) {
        Text($r('app.string.settings'))
          .height($r("app.float.wh_value_56"))
          .fontColor($r("sys.color.ohos_id_color_text_primary"))
          .fontSize($r("app.float.font_30"))
          .lineHeight($r("app.float.lineHeight_41"))
          .fontWeight(FontWeight.Bold)
          .fontFamily('HarmonyHeiTi')
          .textAlign(TextAlign.Start)
          .width(ConfigData.WH_100_100)
          .padding({
            left: $r('app.float.distance_12'),
            top: $r('app.float.distance_7'),
            bottom: $r('app.float.distance_8')
          })
      }

      List({ space: this.listSpaces }) {
        // search
        ListItem() {
          Row() {
            Image($r("app.media.ic_search"))
              .width($r('app.float.wh_value_18'))
              .height($r('app.float.wh_value_18'))
              .objectFit(ImageFit.Contain)
              .margin({
                left: $r("app.float.distance_11"),
                top: $r('app.float.distance_11'),
                bottom: $r('app.float.distance_11')
              });

            Text($r("app.string.searchHint"))
              .fontSize($r("app.float.font_16"))
              .lineHeight($r("app.float.lineHeight_21"))
              .fontWeight(FontWeight.Regular)
              .fontFamily('HarmonyHeiTi')
              .fontColor($r("sys.color.ohos_id_color_text_secondary"))
              .align(Alignment.Start)
              .margin({
                left: $r("app.float.distance_6"),
                top: $r('app.float.distance_9'),
                bottom: $r('app.float.distance_9')
              });
          }
          .border({
            width: $r('app.float.wh_value_1_5'),
            color: $r("sys.color.ohos_id_color_fourth"),
            radius: $r('app.float.wh_value_20')
          })
          .height($r("app.float.wh_value_40"))
          .width(ConfigData.WH_100_100)
          .alignItems(VerticalAlign.Center)
          .backgroundColor($r("sys.color.ohos_id_color_foreground_contrary"));
        }
        .height($r("app.float.wh_value_56"))
        .padding({ top: $r("app.float.wh_value_8"), bottom: $r("app.float.wh_value_8") })
        .width(ConfigData.WH_100_100)
        .onClick(() => {
          LogUtil.info('On click the search editText.');
          Router.push({
            uri: 'pages/searchPage'
          })
        })

        ListItem() {
          List() {
            ListItem(){
              // WLAN
              SettingItemComponent({
                targetPage: "pages/wifi",
                settingTitle: $r("app.string.wifiTab"),
                settingEndText: $wifiStatusInfo,
                settingIcon: "/res/image/wlan.svg",
              })
            }

            ListItem(){
              // blueTooth
              SettingItemComponent({
                targetPage: "pages/bluetooth",
                settingTitle: $r("app.string.bluetoothTab"),
                settingEndText: $bluetoothStatusInfo,
                settingIcon: "/res/image/blueTooth.svg",
              })
            }

            ListItem(){
              // mobileData
              SettingItemComponent({
                targetPage: "",
                settingTitle: $r("app.string.mobileData"),
                settingEndText:$endTextEmpty,
                settingIcon: "/res/image/mobileData.svg",
              })
            }

            if (this.info === 'true') {
              ListItem(){
                // moreConnections
                SettingItemComponent({
                  targetPage: "pages/moreConnections",
                  settingTitle: $r("app.string.moreConnectionsTab"),
                  settingEndText:$endTextEmpty,
                  settingIcon: "/res/image/ic_settings_more_connections.svg",
                })
              }
            }
          }
          .settingListItemDividerFancy()
        }
        .settingListItemFancy()

        ListItem() {
          // displayAndBrightness
          SettingItemComponent({
            targetPage: "pages/screenAndBrightness",
            settingTitle: $r("app.string.brightnessTab"),
            settingEndText:$endTextEmpty,
            settingIcon: "/res/image/displayAndBrightness.svg",
          })
        }
        .settingListItemFancy()

        ListItem() {
          // volumeControl
          SettingItemComponent({
            targetPage: "pages/volumeControl",
            settingTitle: $r("app.string.volumeControlTab"),
            settingEndText:$endTextEmpty,
            settingIcon: "/res/image/volume.svg",
          })
        }
        .settingListItemFancy()

        ListItem() {
          List() {
            ListItem(){
              // biometricsAndPassword
              SettingItemComponent({
                targetPage: "pages/passwordSetting",
                settingTitle: $r("app.string.biometricsAndPassword"),
                settingEndText:$endTextEmpty,
                settingIcon: "/res/image/biometricsAndPassword.svg",
              })
            }

            ListItem(){
              // application
              SettingItemComponent({
                targetPage: "pages/application",
                settingTitle: $r("app.string.applyTab"),
                settingEndText:$endTextEmpty,
                settingIcon: "/res/image/application.svg",
              })
            }

            ListItem(){
              // storage
              SettingItemComponent({
                targetPage: "pages/storage",
                settingTitle: $r("app.string.storageTab"),
                settingEndText:$endTextEmpty,
                settingIcon: "/res/image/storage.svg",
              })
            }
            ListItem(){
              // security
              SettingItemComponent({
                targetPage: "security",
                settingTitle: $r("app.string.security"),
                settingEndText:$endTextEmpty,
                settingIcon: "/res/image/security.svg",
              })
            }

            ListItem(){
              // privacy
              SettingItemComponent({
                targetPage: "pages/privacy",
                settingTitle: $r("app.string.privacy"),
                settingEndText:$endTextEmpty,
                settingIcon: "/res/image/privacy.svg",
              })
            }
          }
          .settingListItemDividerFancy()
        }
        .settingListItemFancy()

        ListItem() {
          List() {
            ListItem(){
              // usersAccounts
              SettingItemComponent({
                targetPage: "pages/usersAccounts",
                settingTitle: $r("app.string.usersAccountsTab"),
                settingEndText:$endTextEmpty,
                settingIcon: "/res/image/userAccounts.svg",
              })
            }

            ListItem(){
              // system
              SettingItemComponent({
                targetPage: "pages/system/homePage",
                settingTitle: $r("app.string.systemTab"),
                settingEndText:$endTextEmpty,
                settingIcon: "/res/image/system.svg",
              })
            }

            ListItem(){
              // aboutDevice
              SettingItemComponent({
                targetPage: "pages/aboutDevice",
                settingTitle: $r("app.string.aboutTab"),
                settingEndText:$endTextEmpty,
                settingIcon: "/res/image/aboutDevice.svg",
              })
            }
          }
          .settingListItemDividerFancy()
        }
        .settingListItemFancy()
      }
      .flexShrink(1)
      .width(ConfigData.WH_100_100)
      .alignSelf(ItemAlign.Start);
    }
    .width(ConfigData.WH_100_100)
    .height(ConfigData.WH_100_100)
  }
}