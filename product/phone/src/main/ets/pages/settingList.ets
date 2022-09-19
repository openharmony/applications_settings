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
import SettingListModel from '../model/settingListImpl/SettingListModel';
import WifiModel from '../model/wifiImpl/WifiModel';
import BluetoothModel from '../model/bluetoothImpl/BluetoothModel';
import ResourceUtil from '../../../../../../common/search/src/main/ets/default/common/ResourceUtil';
import GlobalResourceManager from '../../../../../../common/utils/src/main/ets/default/baseUtil/GlobalResourceManager';
import Router from '@system.router';
import FeatureAbility from '@ohos.ability.featureAbility';
import { BaseData } from '../../../../../../common/utils/src/main/ets/default/bean/BaseData';
import deviceInfo from '@ohos.deviceInfo';
import parameter from '@ohos.systemparameter';

const PAGE_SEARCH = 'pages/searchPage'; // for search
const deviceTypeInfo = deviceInfo.deviceType;
const SETTINGS_LIST = [
  [
    {
      "settingIcon": "/res/image/wlan.svg",
      "settingTitle": $r('app.string.wifiTab'),
      "settingAlias": 'wlanTab',
      "settingValue": "",
      "settingArrow": "/res/image/ic_settings_arrow.svg",
      "settingSummary": "",
      "settingUri": "pages/wifi"
    },
    {
      "settingIcon": "/res/image/blueTooth.svg",
      "settingTitle": $r('app.string.bluetoothTab'),
      "settingAlias": 'blueToothTab',
      "settingValue": "",
      "settingArrow": "/res/image/ic_settings_arrow.svg",
      "settingSummary": "",
      "settingUri": "pages/bluetooth"
    },
    {
      "settingIcon": "/res/image/mobileData.svg",
      "settingTitle": $r('app.string.mobileData'),
      "settingAlias": "mobileDataTab",
      "settingValue": "",
      "settingArrow": "/res/image/ic_settings_arrow.svg",
      "settingSummary": "",
      "settingUri": ""
    },
    {
      "settingIcon": "/res/image/ic_settings_more_connections.svg",
      "settingTitle": $r('app.string.moreConnectionsTab'),
      "settingAlias": "moreConnectionsTab",
      "settingValue": "",
      "settingArrow": "/res/image/ic_settings_arrow.svg",
      "settingSummary": "",
      "settingUri": "pages/moreConnections"
    }
  ],
  [
    {
      "settingIcon": "/res/image/displayAndBrightness.svg",
      "settingTitle": $r('app.string.brightnessTab'),
      "settingAlias": '',
      "settingValue": "",
      "settingArrow": "/res/image/ic_settings_arrow.svg",
      "settingSummary": "",
      "settingUri": "pages/screenAndBrightness"
    }
  ],
  [
    {
      "settingIcon": "/res/image/volume.svg",
      "settingTitle": $r('app.string.volumeControlTab'),
      "settingAlias": '',
      "settingValue": "",
      "settingArrow": "/res/image/ic_settings_arrow.svg",
      "settingSummary": "",
      "settingUri": "pages/volumeControl"
    }
  ],
  [
    {
      "settingIcon": "/res/image/biometricsAndPassword.svg",
      "settingTitle": $r('app.string.biometricsAndPassword'),
      "settingAlias": '',
      "settingValue": "",
      "settingArrow": "/res/image/ic_settings_arrow.svg",
      "settingSummary": "",
      "settingUri": "pages/passwordSetting"
    },
    {
      "settingIcon": "res/image/application.svg",
      "settingTitle": $r('app.string.applyTab'),
      "settingAlias": '',
      "settingValue": "",
      "settingArrow": "res/image/ic_settings_arrow.svg",
      "settingSummary": "",
      "settingUri": "pages/application"
    },
    {
      "settingIcon": "/res/image/storage.svg",
      "settingTitle": $r('app.string.storageTab'),
      "settingAlias": '',
      "settingValue": "",
      "settingArrow": "/res/image/ic_settings_arrow.svg",
      "settingSummary": "",
      "settingUri": "pages/storage"
    },
    {
      "settingIcon": "/res/image/privacy.svg",
      "settingTitle": $r('app.string.privacy'),
      "settingAlias": '',
      "settingValue": "",
      "settingArrow": "/res/image/ic_settings_arrow.svg",
      "settingSummary": "",
      "settingUri": "pages/privacy"
    }
  ],
  [
    {
      "settingIcon": "/res/image/userAccounts.svg",
      "settingTitle": $r("app.string.usersAccountsTab"),
      "settingAlias": '',
      "settingValue": "",
      "settingArrow": "/res/image/ic_settings_arrow.svg",
      "settingSummary": "",
      "settingUri": "pages/usersAccounts"
    },
    {
      "settingIcon": "/res/image/system.svg",
      "settingTitle": $r('app.string.systemTab'),
      "settingAlias": '',
      "settingValue": "",
      "settingArrow": "/res/image/ic_settings_arrow.svg",
      "settingSummary": "",
      "settingUri": "pages/system/homePage"
    },
    {
      "settingIcon": "/res/image/aboutDevice.svg",
      "settingTitle": $r('app.string.aboutTab'),
      "settingAlias": '',
      "settingValue": "",
      "settingArrow": "/res/image/ic_settings_arrow.svg",
      "settingSummary": "",
      "settingUri": "pages/aboutDevice"
    }
  ]
];

/**
 * setting home page
 */
@Entry
@Component
struct SettingList {
  @State placeholder: string= ''; // for search
  @State placeholdersize: string = '22';
  @State listSpaces: string = '12vp';
  @State isPhone: boolean = false;

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
      GridContainer({
        columns: 12,
        sizeType: SizeType.Auto,
        gutter: vp2px(1) === 2 ? '12vp' : '0vp',
        margin: vp2px(1) === 2 ? '24vp' : '0vp'
      }) {
        Row({}) {
          Column() {
          }
          .width(ConfigData.WH_100_100)
          .height(ConfigData.WH_100_100)
          .useSizeType({
            xs: { span: 0, offset: 0 }, sm: { span: 0, offset: 0 },
            md: { span: 0, offset: 0 }, lg: { span: 0, offset: 0 }
          })

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
          .backgroundColor($r("sys.color.ohos_id_color_sub_background"))
          .align(Alignment.Start)
          .alignItems(HorizontalAlign.Start)
          .height(ConfigData.WH_100_100)
          .width(ConfigData.WH_100_100)
          .useSizeType({
            xs: { span: 12, offset: 0 }, sm: { span: 12, offset: 0 },
            md: { span: 12, offset: 0 }, lg: { span: 8, offset: 2 }
          })

          Column() {
          }
          .width(ConfigData.WH_100_100)
          .height(ConfigData.WH_100_100)
          .useSizeType({
            xs: { span: 0, offset: 12 }, sm: { span: 0, offset: 12 },
            md: { span: 0, offset: 12 }, lg: { span: 2, offset: 10 }
          })
        }
        .width(ConfigData.WH_100_100)
        .height(ConfigData.WH_100_100);
      }
      .width(ConfigData.WH_100_100)
      .height(ConfigData.WH_100_100);
    }
    .backgroundColor($r("sys.color.ohos_id_color_sub_background"))
    .width(ConfigData.WH_100_100)
    .height(ConfigData.WH_100_100);
  }

  aboutToAppear() {
    LogUtil.info('settings SettingList aboutToAppear enter');
    ResourceUtil.getString($r("app.string.searchHint")).then(value => this.placeholder = value);// for search
    ResourceUtil.getString($r("app.float.search_placeholder_font")).then(value => this.placeholdersize = value);
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
    LogUtil.info('settings SettingList aboutToAppear end');
  }

  onPageShow() {
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
  }
}

@Component
struct EntryComponent {
  private settingsList: BaseData[][] = SETTINGS_LIST;
  private nfcInfo: boolean;
  private listSpaces: string = '12vp';
  private isPhone: boolean = false;

  aboutToAppear() {
    let info: string = parameter.getSync("const.SystemCapability.Communication.NFC.Core" ,"false");
    if (info === 'true') {
      this.nfcInfo = true;
    } else {
      this.nfcInfo = false;
    }
    LogUtil.info('settings SettingList nfc canUse' + this.nfcInfo);
    if (!this.nfcInfo) {
      this.settingsList[0].pop();
    }
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
            left: $r('app.float.distance_24'),
            top: $r('app.float.distance_7'),
            bottom: $r('app.float.distance_8')
          })
      }

      List({ space: this.listSpaces }) {
        // for search
        ListItem() {
          Column() {
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
          .padding($r("app.float.wh_value_8"))
        }
        .width(ConfigData.WH_100_100)
        .onClick(() => {
          LogUtil.info('On click the search editText.');
          Router.push({
            uri: PAGE_SEARCH
          })
        })

        ForEach(this.settingsList, (eachBlock) => {
          ListItem() {
            List() {
              ForEach(eachBlock, (eachitem) => {
                ListItem() {
                  if (eachitem.settingAlias === 'wlanTab') {
                    wifiItemComponent({ item: eachitem });
                  } else if (eachitem.settingAlias === 'blueToothTab') {
                    if (BluetoothModel.canUse) {
                      bluetoothItemComponent({ item: eachitem });
                    }
                  } else {
                    ItemComponent({ item: eachitem });
                  }
                }
              })
            }
            .width(ConfigData.WH_100_100)
            .divider({
              strokeWidth: $r('app.float.divider_wh'),
              color: $r('sys.color.ohos_id_color_list_separator'),
              startMargin: $r('app.float.wh_value_48'),
              endMargin: $r('app.float.wh_value_8')
            })
          }
          .width(ConfigData.WH_100_100)
          .borderRadius($r("app.float.radius_24"))
          .backgroundColor($r("sys.color.ohos_id_color_foreground_contrary"))
          .padding($r('app.float.distance_4'))
        });
      }
      .flexShrink(1)
      .width(ConfigData.WH_100_100)
      .alignSelf(ItemAlign.Start);
    }
    .padding({
      left: $r('sys.float.ohos_id_card_margin_start'),
      right: $r('sys.float.ohos_id_card_margin_end')
    })
  }
}

@Component
struct ItemComponent {
  @State isTouched: boolean = false;
  private item;

  build() {
    Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
      Row() {
        Image(this.item.settingIcon)
          .width($r("app.float.wh_value_24"))
          .height($r("app.float.wh_value_24"))
          .margin({
            left: $r("app.float.distance_8"),
            top: $r("app.float.distance_15"),
            bottom: $r("app.float.distance_17")
          })

        Text(this.item.settingTitle)
          .fontSize($r("app.float.font_16"))
          .lineHeight($r("app.float.lineHeight_22"))
          .fontWeight(FontWeight.Medium)
          .fontFamily('HarmonyHeiTi')
          .fontColor($r("sys.color.ohos_id_color_text_primary"))
          .align(Alignment.Start)
          .margin({
            left: $r("app.float.distance_16"),
            top: $r("app.float.distance_17"),
            bottom: $r("app.float.distance_17")
          })
      }
      .align(Alignment.Start)
      .height(ConfigData.WH_100_100)

      Row() {
        Image(this.item.settingArrow)
          .width($r("app.float.wh_value_12"))
          .height($r("app.float.wh_value_24"))
          .margin({
            left: $r("app.float.distance_4"),
            right: $r("app.float.distance_8"),
            top: $r("app.float.distance_16"),
            bottom: $r("app.float.distance_16")
          })
          .fillColor($r("sys.color.ohos_id_color_fourth"))
      }
      .align(Alignment.End)
      .height(ConfigData.WH_100_100);
    }
    .width(ConfigData.WH_100_100)
    .height($r("app.float.wh_value_56"))
    .borderRadius($r("app.float.radius_20"))
    .linearGradient(this.isTouched ? {
                                       angle: 90,
                                       direction: GradientDirection.Right,
                                       colors: [[$r("app.color.DCEAF9"), 0.0], [$r("app.color.FAFAFA"), 1.0]]
                                     } : {
                                           angle: 90,
                                           direction: GradientDirection.Right,
                                           colors: [[$r("sys.color.ohos_id_color_foreground_contrary"), 1], [$r("sys.color.ohos_id_color_foreground_contrary"), 1]]
                                         })
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        this.isTouched = true;
      }
      if (event.type === TouchType.Up) {
        this.isTouched = false;
      }
    })
    .onClick(() => {
      SettingListModel.onClick(this.item);
    })
  }
}


@Component
struct wifiItemComponent {
  @StorageLink('wifiStatus') wifiStatus: boolean = WifiModel.isWiFiActive();
  @State isTouched: boolean = false;
  private item;

  build() {
    Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
      Row() {
        Image(this.item.settingIcon)
          .width($r("app.float.wh_value_24"))
          .height($r("app.float.wh_value_24"))
          .margin({
            left: $r("app.float.distance_8"),
            top: $r("app.float.distance_15"),
            bottom: $r("app.float.distance_17")
          })

        Text(this.item.settingTitle)
          .fontSize($r("app.float.font_16"))
          .lineHeight($r("app.float.lineHeight_22"))
          .fontWeight(FontWeight.Medium)
          .fontFamily('HarmonyHeiTi')
          .fontColor($r("sys.color.ohos_id_color_text_primary"))
          .align(Alignment.Start)
          .margin({
            left: $r("app.float.distance_16"),
            top: $r("app.float.distance_17"),
            bottom: $r("app.float.distance_17")
          })
      }
      .align(Alignment.Start)
      .height(ConfigData.WH_100_100)

      Row() {
        Text(this.wifiStatus ? $r("app.string.enabled") : $r("app.string.disabled"))
          .fontSize($r("app.float.font_14"))
          .lineHeight($r("app.float.lineHeight_19"))
          .align(Alignment.End)
          .fontWeight(FontWeight.Regular)
          .fontFamily('HarmonyHeiTi')
          .fontColor($r('sys.color.ohos_id_color_text_secondary'))
          .margin({ top: $r("app.float.distance_19"), bottom: $r("app.float.distance_18") });
        Image(this.item.settingArrow)
          .width($r("app.float.wh_value_12"))
          .height($r("app.float.wh_value_24"))
          .margin({
            left: $r("app.float.distance_4"),
            right: $r("app.float.distance_8"),
            top: $r("app.float.distance_16"),
            bottom: $r("app.float.distance_16")
          })
          .fillColor($r("sys.color.ohos_id_color_fourth"))
      }
      .align(Alignment.End)
      .height(ConfigData.WH_100_100);
    }
    .width(ConfigData.WH_100_100)
    .height($r("app.float.wh_value_56"))
    .borderRadius($r("app.float.radius_20"))
    .linearGradient(this.isTouched ? {
                                       angle: 90,
                                       direction: GradientDirection.Right,
                                       colors: [[$r("app.color.DCEAF9"), 0.0], [$r("app.color.FAFAFA"), 1.0]]
                                     } : {
                                           angle: 90,
                                           direction: GradientDirection.Right,
                                           colors: [[$r("sys.color.ohos_id_color_foreground_contrary"), 1], [$r("sys.color.ohos_id_color_foreground_contrary"), 1]]
                                         })
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        this.isTouched = true;
      }
      if (event.type === TouchType.Up) {
        this.isTouched = false;
      }
    })
    .onClick(() => {
      SettingListModel.onClick(this.item);
    })
  }

  aboutToAppear() {
    LogUtil.info('settings SettingList wifiItem aboutToAppear');
    SettingListModel.registerObserver();
    LogUtil.info('settings SettingList  wifiItem aboutToAppear end');
  }
}

@Component
struct bluetoothItemComponent {
  @StorageLink('bluetoothIsOn') bluetoothIsOn: boolean = false;
  @State isTouched: boolean = false;
  private item;

  build() {
    Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
      Row() {
        Image(this.item.settingIcon)
          .width($r("app.float.wh_value_24"))
          .height($r("app.float.wh_value_24"))
          .margin({
            left: $r("app.float.distance_8"),
            top: $r("app.float.distance_15"),
            bottom: $r("app.float.distance_17")
          })

        Text(this.item.settingTitle)
          .fontSize($r("app.float.font_16"))
          .lineHeight($r("app.float.lineHeight_22"))
          .fontWeight(FontWeight.Medium)
          .fontFamily('HarmonyHeiTi')
          .fontColor($r("sys.color.ohos_id_color_text_primary"))
          .align(Alignment.Start)
          .margin({
            left: $r("app.float.distance_16"),
            top: $r("app.float.distance_17"),
            bottom: $r("app.float.distance_17")
          })
      }
      .align(Alignment.Start)
      .height(ConfigData.WH_100_100)

      Row() {
        Text(this.bluetoothIsOn ? $r("app.string.enabled") : $r("app.string.disabled"))
          .fontSize($r("app.float.font_14"))
          .lineHeight($r("app.float.lineHeight_19"))
          .align(Alignment.End)
          .fontWeight(FontWeight.Regular)
          .fontFamily('HarmonyHeiTi')
          .fontColor($r('sys.color.ohos_id_color_text_secondary'))
          .margin({ top: $r("app.float.distance_19"), bottom: $r("app.float.distance_18") });
        Image(this.item.settingArrow)
          .width($r("app.float.wh_value_12"))
          .height($r("app.float.wh_value_24"))
          .margin({
            left: $r("app.float.distance_4"),
            right: $r("app.float.distance_8"),
            top: $r("app.float.distance_16"),
            bottom: $r("app.float.distance_16")
          })
          .fillColor($r("sys.color.ohos_id_color_fourth"))
      }
      .align(Alignment.End)
      .height(ConfigData.WH_100_100);
    }
    .width(ConfigData.WH_100_100)
    .height($r("app.float.wh_value_56"))
    .borderRadius($r("app.float.radius_20"))
    .linearGradient(this.isTouched ? {
                                       angle: 90,
                                       direction: GradientDirection.Right,
                                       colors: [[$r("app.color.DCEAF9"), 0.0], [$r("app.color.FAFAFA"), 1.0]]
                                     } : {
                                           angle: 90,
                                           direction: GradientDirection.Right,
                                           colors: [[$r("sys.color.ohos_id_color_foreground_contrary"), 1], [$r("sys.color.ohos_id_color_foreground_contrary"), 1]]
                                         })
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        this.isTouched = true;
      }
      if (event.type === TouchType.Up) {
        this.isTouched = false;
      }
    })
    .onClick(() => {
      SettingListModel.onClick(this.item);
    })
  }

  aboutToAppear() {
    LogUtil.info('settings SettingList bluetoothItem aboutToAppear in');
    this.bluetoothIsOn = BluetoothModel.isStateOn();
    BluetoothModel.subscribeStateChange((isOn: boolean) => {
      AppStorage.SetOrCreate('bluetoothIsOn', isOn);
    });
    LogUtil.info('settings SettingList bluetoothItem aboutToAppear end');
  }

  aboutToDisappear() {
    LogUtil.info('settings SettingList bluetoothItem aboutToDisappear in');
    BluetoothModel.unsubscribeStateChange();
    LogUtil.info('settings SettingList bluetoothItem aboutToDisappear end');
  }
}