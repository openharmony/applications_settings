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
import WifiModel from '../model/wifiImpl/WifiModel';
import {WifiScanInfo, ApScanResult, WiFiSummaryMap, WiFiIntensityMap, WiFiEncryptMethodMap} from '../model/wifiImpl/WifiModel';
import HeadComponent from '../../../../../../../common/component/src/main/ets/default/headComponent';
import ImageAnimatorComponent from '../../../../../../../common/component/src/main/ets/default/imageAnimatorComponent';
import ConfigData from '../../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData';
import LogUtil from '../../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import router from '@system.router';
console.log('settings_20220424 wifi page in');
const MODULE_TAG = ConfigData.TAG + 'WifiModel.wifi -> ';

function genWiFiIntensity(intensityEnum: number) {
  if (intensityEnum === WiFiIntensityMap.GOOD) {
    return $r("app.string.wifiSigIntensityStrong");
  }
  if (intensityEnum === WiFiIntensityMap.WELL) {
    return $r("app.string.wifiSigIntensityWell");
  }
  if (intensityEnum === WiFiIntensityMap.NORMAL) {
    return $r("app.string.wifiSigIntensityNormal");
  }
  if (intensityEnum === WiFiIntensityMap.BAD) {
    return $r("app.string.wifiSigIntensityBad");
  }
  return $r("app.string.wifiSigIntensityBad");
}

function genWiFiEncryptMethod(encryptEnum: number) {
  if (encryptEnum === WiFiEncryptMethodMap.OPEN) {
    return $r("app.string.wifiEncryptMethodOpen");
  }
  if (encryptEnum === WiFiEncryptMethodMap.WEP) {
    return $r("app.string.wifiEncryptMethodWEP");
  }
  if (encryptEnum === WiFiEncryptMethodMap.WPA) {
    return $r("app.string.wifiEncryptMethodWPA");
  }
  if (encryptEnum === WiFiEncryptMethodMap.WPA2) {
    return $r("app.string.wifiEncryptMethodWPA2");
  }
  return $r("app.string.wifiEncryptMethodOpen");
}

function genWiFiStatusSummary(statusEnum: number) {
  if (statusEnum === WiFiSummaryMap.CONNECTED) {
    return $r("app.string.wifiSummaryConnected");
  }
  if (statusEnum === WiFiSummaryMap.CONNECTING) {
    return $r("app.string.wifiSummaryConnecting");
  }
  if (statusEnum === WiFiSummaryMap.OBTAINING_IP) {
    return $r("app.string.wifiSummaryObtainingIP");
  }
  if (statusEnum === WiFiSummaryMap.SAVE_ENCRYPTED) {
    return $r("app.string.wifiSummarySaveEncrypted");
  }
  if (statusEnum === WiFiSummaryMap.SAVE_OPEN) {
    return $r("app.string.wifiSummarySaveOpen");
  }
  if (statusEnum === WiFiSummaryMap.ENCRYPTED) {
    return $r("app.string.wifiSummaryEncrypted");
  }
  if (statusEnum === WiFiSummaryMap.OPEN) {
    return $r("app.string.wifiSummaryOpen");
  }
  return $r("app.string.wifiSummaryConnected");
}

@Entry
@Component
struct Index {
  scroller: Scroller = new Scroller()
  @StorageLink('slWiFiLists') scanWiFiResults: [] = [];
  @StorageLink('slConnectedWifi') connectedWiFi: any = [];
  @State isWiFiEnabled: boolean = false;
  @State userSelectedApInfo: WifiScanInfo = {
    ssid:'',
    bssid: '',
    rssi: -100,
    band: 0,
    frequency: 0,
    timestamp: 0,
    securityType: 1,
  };
  @State isScrollBarTouched: boolean = false;
  private switchDebounceFlag = undefined;

  private clickApInfoDialog: CustomDialogController = new CustomDialogController({
    builder: apInfoDialog({
      apInfo: $userSelectedApInfo,
    }),
    autoCancel: true,
    customStyle: true
  });

  private clickApInfoDetailsDialog: CustomDialogController = new CustomDialogController({
    builder: apInfoDetailsDialog({
      apInfo: $userSelectedApInfo,
      disconnectAction: () => {
        WifiModel.disconnectWiFi();
        WifiModel.refreshApScanResults();
      }
    }),
    autoCancel: true,
    customStyle: true
  });

  build() {
    Column(){
      GridContainer({columns:12, sizeType: SizeType.Auto, gutter: vp2px(1) === 2 ? '12vp' : '0vp', margin: vp2px(1) === 2 ? '24vp' : '0vp'}) {
        Row({}) {
          Column() {
          }
          .width(ConfigData.WH_100_100)
          .height(ConfigData.WH_100_100)
          .useSizeType({
            xs: { span: 0, offset: 0 }, sm: { span: 0, offset: 0 },
            md: { span: 0, offset: 0 }, lg: { span: 2, offset: 0 }
          });

          Column() {
            Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems:ItemAlign.Center }) {
              HeadComponent({ headName: $r('app.string.wifiTab'), isActive: true });
            }
            .margin({left: $r("app.float.wh_value_24"), right: $r("app.float.wh_value_24")});

            Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems:ItemAlign.Center }) {
              Row() {
                Text($r('app.string.wifiTab'))
                  .fontSize($r('sys.float.ohos_id_text_size_body1'))
                  .fontColor($r('sys.color.ohos_id_color_text_primary'))
                  .fontWeight(FontWeight.Medium)
                  .textAlign(TextAlign.Start);
              }
              .alignItems(VerticalAlign.Center)
              .width($r("app.float.wh_value_240"))
              .height($r("app.float.wh_value_48"))
              .margin({top: $r("app.float.wh_value_4"), bottom: $r("app.float.wh_value_4"),
                left: $r("app.float.wh_value_12")})

              Toggle({ type: ToggleType.Switch, isOn: this.isWiFiEnabled })
                .width($r('app.float.switch_toggle_width'))
                .height($r('app.float.switch_toggle_height'))
                .margin({right: $r("app.float.wh_value_12")})
                .onChange((isOn: boolean) => {
                  this.switchWiFiActiveStatus();
                });
            }
            .margin({left: $r("app.float.wh_value_24"), right: $r("app.float.wh_value_24")})
            .height($r('app.float.wh_value_56'))
            .backgroundColor($r("app.color.white_bg_color"))
            .borderRadius($r('app.float.radius_24'))

            Scroll(this.scroller) {
              Column() {
                Column() {
                  Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems:ItemAlign.Center }) {
                    Text($r("app.string.wifiTipConnectedWLAN"))
                      .fontSize($r('sys.float.ohos_id_text_size_body2'))
                      .fontColor($r('sys.color.ohos_id_color_text_secondary'))
                      .fontWeight(FontWeight.Medium)
                      .textAlign(TextAlign.Start);
                  }
                  .height($r("app.float.wh_value_48"))
                  .margin({ left: $r('app.float.wh_value_12'), right: $r('app.float.wh_value_12') });

                  Column() {
                    List() {
                      ListItem() {
                        WiFiEntryComponent({
                          settingIcon: this.connectedWiFi.settingIcon,
                          settingTitle: this.connectedWiFi.settingTitle,
                          settingSummary: genWiFiStatusSummary(this.connectedWiFi.settingSummary),
                          settingValue: this.connectedWiFi.settingValue,
                          settingArrow: this.connectedWiFi.settingArrow,
                          settingUri: this.connectedWiFi.settingUri,
                          titleFontColor: "activated"
                        });
                      }
                      .margin({top: $r("app.float.wh_value_4"), bottom: $r("app.float.wh_value_4")})
                      .onClick(() => {
                        LogUtil.info(MODULE_TAG + 'clicked connected wifi item');
                        this.userSelectedApInfo = this.connectedWiFi.apInfo;
                        this.clickApInfoDetailsDialog.open();
                      });
                    }
                  }
                  .borderRadius($r("app.float.radius_24"))
                  .backgroundColor($r("app.color.white_bg_color"))
                }
                .height($r("app.float.wh_value_120"))
                .visibility(this.isNeedRenderConnectedWiFi() ? Visibility.Visible : Visibility.None);

                Column() {
                  Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems:ItemAlign.Center }) {
                    Text($r("app.string.wifiTipValidWLAN"))
                      .fontSize($r('sys.float.ohos_id_text_size_body2'))
                      .fontColor($r('sys.color.ohos_id_color_text_secondary'))
                      .fontWeight(FontWeight.Medium)
                      .textAlign(TextAlign.Start);
                    Row() {
                      ImageAnimatorComponent({ imageWidth: $r('app.float.wh_value_24'),
                        imageHeight: $r('app.float.wh_value_24') })
                    }
                  }
                  .height($r("app.float.wh_value_48"))
                  .margin({ left: $r('app.float.wh_value_12'), right: $r('app.float.wh_value_12') })

                  Column() {
                    List() {
                      ForEach(this.scanWiFiResults, (item) => {
                        ListItem() {
                          WiFiEntryComponent({
                            settingIcon: item.settingIcon,
                            settingTitle: item.settingTitle,
                            settingSummary: genWiFiStatusSummary(item.settingSummary),
                            settingValue: item.settingValue,
                            settingArrow: item.settingArrow,
                            settingUri: item.settingUri,
                            titleFontColor: "inactivated"
                          });
                        }
                        .onClick(() => {
                          if (WifiModel.isSavedAp(item.settingTitle)) {
                            this.userSelectedApInfo = item.apInfo;
                            this.clickApInfoDialog.open();
                          } else {
                            this.jumpToConnectApPage(item.apInfo);
                          }
                        })
                      });
                    }
                    .margin({top:$r('app.float.wh_value_4'), bottom: $r('app.float.wh_value_4')})
                    .divider({
                      strokeWidth: $r('app.float.wh_value_1'),
                      color: $r('app.color.color_E3E3E3_grey'),
                      startMargin: $r("app.float.wh_value_12"),
                      endMargin: $r("app.float.wh_value_12"),
                    });
                  }
                  .margin({bottom: $r("app.float.wh_value_56")})
                  .borderRadius($r("app.float.radius_24"))
                  .backgroundColor($r("app.color.white_bg_color"))
                  .visibility(this.scanWiFiResults.length !== 0 ? Visibility.Visible : Visibility.None)
                }
                .visibility(this.isWiFiEnabled ? Visibility.Visible : Visibility.None);
              }
              .width('100%')
              .padding({left: $r("app.float.wh_value_24"), right: $r("app.float.wh_value_24")})
            }
            .margin({top: $r("app.float.wh_value_4"), bottom: $r("app.float.wh_value_72")})
            .width(ConfigData.WH_100_100)
            .scrollable(ScrollDirection.Vertical)
            .scrollBar(BarState.On)
            .scrollBarColor(Color.Gray)
            .scrollBarWidth(this.isScrollBarTouched === true ? 6 : 3)
            .borderRadius($r("app.float.radius_24"))
            .onTouch((event: TouchEvent) => {
              if (event.type === TouchType.Down) {
                this.isScrollBarTouched = true;
              }
              if (event.type === TouchType.Up) {
                this.isScrollBarTouched = false;
              }
            });
          }
          .width(ConfigData.WH_100_100)
          .height(ConfigData.WH_100_100)
          .useSizeType({
            xs: { span: 12, offset: 0 }, sm: { span: 12, offset: 0 },
            md: { span: 12, offset: 0 }, lg: { span: 8, offset: 2 }
          });

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

  isNeedRenderConnectedWiFi() {
    if (this.isWiFiEnabled !== true) {
      return false;
    }
    if (typeof this.connectedWiFi["settingTitle"] === 'undefined') {
      return false;
    }
    // as the ConnectionStateChange event is diff with the getLinkInfo callback,
    // we always get the diff status between them
    if (this.connectedWiFi.settingTitle === '') {
      return false
    }
    return true;
  }

  jumpToConnectApPage(apInfo: WifiScanInfo) {
    WifiModel.setUserSelectedAp(apInfo);
    // direct connect to wifi in security type 1(Open)
    if (apInfo.securityType === 1) {
      WifiModel.connectWiFi('');
      return;
    }
    let params = {
      apInfo: apInfo,
      isConnected: false
    };
    router.push({
      uri: 'pages/wifiPsd',
      params: params,
    });
  }

  switchWiFiActiveStatus() {
    // make the ui change quickly
    this.isWiFiEnabled = !this.isWiFiEnabled;
    LogUtil.info(MODULE_TAG + 'curr enable status : ' + this.isWiFiEnabled);

    // delay the wifi status change event
    if (this.switchDebounceFlag) {
      clearTimeout(this.switchDebounceFlag);
    }
    this.switchDebounceFlag = setTimeout(()=> {
      if (this.isWiFiEnabled) {
        LogUtil.info(MODULE_TAG + 'enable wifi');
        WifiModel.enableWiFi();
      } else {
        LogUtil.info(MODULE_TAG + 'disable wifi');
        WifiModel.disableWifi();
      }
      this.switchDebounceFlag = undefined;
    }, 2000);
  }

  aboutToAppear(): void {
    LogUtil.info(MODULE_TAG + 'about to appear wifi page');
    WifiModel.registerWiFiStatusObserver((code) => {
      LogUtil.info(MODULE_TAG + 'wifi status code : ' + code + ' taskId : ' + this.switchDebounceFlag);
      if (!this.switchDebounceFlag) {
        this.isWiFiEnabled = WifiModel.isWiFiActive();
        LogUtil.info(MODULE_TAG + 'wifi active status : ' + this.isWiFiEnabled);
      }
    });
    // init wifi active status
    this.isWiFiEnabled = WifiModel.isWiFiActive();
  }

  aboutToDisappear(): void {
    LogUtil.info(MODULE_TAG + 'about to disappear');
    WifiModel.destroyWiFiModelData();
  }

  onPageShow() {
    LogUtil.info(MODULE_TAG + 'on page show');
    WifiModel.registerWiFiConnectionObserver((code) => {
      LogUtil.info(MODULE_TAG + 'wifi connection code : ' + code);
      WifiModel.refreshApScanResults();
    });
    WifiModel.startScanTask();
  }

  onPageHide(): void {
    LogUtil.info(MODULE_TAG + 'on page hide');
    WifiModel.unregisterWiFiConnectionObserver();
    WifiModel.stopScanTask();
  }

  onBackPress() {
    Navigator().active(true);
  }
}

@Component
export default
struct ApInfoComponent {
  @Prop key: string;
  @Prop value: string;

  build() {
    Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems:ItemAlign.Center }) {
      Row() {
        Text(this.key)
          .fontSize($r('sys.float.ohos_id_text_size_body1'))
          .fontColor($r('sys.color.ohos_id_color_text_primary'))
          .fontWeight(FontWeight.Medium)
          .textAlign(TextAlign.Start)
      }
      .alignItems(VerticalAlign.Center);
      Row() {
        Text(this.value)
          .fontSize($r('sys.float.ohos_id_text_size_body2'))
          .fontColor($r('sys.color.ohos_id_color_text_secondary'))
          .fontWeight(FontWeight.Regular)
          .textAlign(TextAlign.End)
      }
      .alignItems(VerticalAlign.Center);
    }
    .height($r('app.float.wh_value_48'))
    .width(ConfigData.WH_100_100)
    .backgroundColor($r("app.color.white_bg_color"))
  }
}

/**
 * Choose Unlock Method Dialog
 */
@CustomDialog
struct apInfoDialog {
  controller: CustomDialogController;
  private apInfo: WifiScanInfo;
  @State dataList: any[] = [{key: $r('app.string.wifiInfoTitleIntensity'),
                               value: $r('app.string.wifiSigIntensityBad')},
                             {key: $r('app.string.wifiInfoTitleEncryptMethod'),
                               value: $r('app.string.wifiEncryptMethodOpen')}];

  // 0 is cancel, 1 is delete, 2 is connect
  private buttons: any[] = [{summary: $r('app.string.wifiButtonCancel'), opType: 0},
                            {summary: $r('app.string.wifiButtonDelete'), opType: 1},
                            {summary: $r('app.string.wifiButtonConnect'), opType: 2}];

  build() {
    Column() {
      Row() {
        Text(this.apInfo.ssid)
          .fontSize($r('app.float.font_20'))
          .fontColor($r('sys.color.ohos_id_color_text_primary'))
          .fontWeight(FontWeight.Medium)
          .align(Alignment.Start)
      }
      .height($r("app.float.wh_value_56"))
      .width($r("app.float.wh_value_362"))
      .margin({left: $r("app.float.wh_value_24"), right: $r("app.float.wh_value_24")})

      List() {
        ForEach(this.dataList, (item) => {
          ListItem() {
            ApInfoComponent({
              key: item.key,
              value: item.value
            });
          }
          .height($r('app.float.wh_value_48'))
          .onClick(() => {
            LogUtil.info(MODULE_TAG + 'clicked ap info item');
          })
        })
      }
      .margin({left: $r("app.float.wh_value_24"), right: $r("app.float.wh_value_24")})
      .divider({
        strokeWidth: $r('app.float.wh_value_1'),
        color: $r('app.color.color_E3E3E3_grey'),
      })

      List() {
        ForEach(this.buttons, (item) => {
          ListItem() {
            Row() {
              Text(item.summary)
                .fontSize($r('sys.float.ohos_id_text_size_body1'))
                .fontColor($r('sys.color.ohos_id_color_text_primary_activated'))
                .fontWeight(FontWeight.Medium)
                .width(ConfigData.WH_100_100)
                .textAlign(TextAlign.Center);
            }
            .width($r("app.float.wh_value_118"))
            .height($r("app.float.wh_value_40"))
            .alignItems(VerticalAlign.Center)
          }
          .margin({left: $r("app.float.wh_value_4"), right: $r("app.float.wh_value_4")})
          .onClick(() => {
            // 0 is cancel, 1 is delete, 2 is connect
            if (item.opType === 0) {
              LogUtil.info(MODULE_TAG + 'clicked ap info cancel');
            }
            if (item.opType === 1) {
              LogUtil.info(MODULE_TAG + 'clicked ap info delete');
              WifiModel.removeDeviceConfig(this.apInfo);
              WifiModel.refreshApScanResults();
            }
            if (item.opType === 2) {
              LogUtil.info(MODULE_TAG + 'clicked ap info connect');
              WifiModel.disconnectWiFi();
              WifiModel.connectByDeviceConfig(this.apInfo);
              WifiModel.refreshApScanResults();
            }
            this.controller.close();
          })
        })
      }
      .margin({top:$r('app.float.wh_value_8'), left: $r("app.float.wh_value_16"), right: $r("app.float.wh_value_16")})
      .height($r('app.float.wh_value_40'))
      .listDirection(Axis.Horizontal)
      .divider({
        strokeWidth: $r('app.float.wh_value_1'),
        color: $r('app.color.color_E3E3E3_grey'),
        startMargin: $r('app.float.wh_value_8'),
        endMargin: $r('app.float.wh_value_8')
      })
    }
    .height($r("app.float.wh_value_216"))
    .width($r("app.float.wh_value_410"))
    .borderRadius($r("app.float.radius_32"))
    .backgroundColor($r("app.color.white_bg_color"))
  }

  aboutToAppear(): void {
    // gen wifi signal level
    let intensity = WifiModel.getSignalIntensity(this.apInfo);
    let encryptType = WifiModel.getEncryptMethod(this.apInfo);
    this.dataList = [{ key: $r('app.string.wifiInfoTitleIntensity'), value: genWiFiIntensity(intensity) },
                     { key: $r('app.string.wifiInfoTitleEncryptMethod'), value: genWiFiEncryptMethod(encryptType) }];
  }
}

@CustomDialog
struct apInfoDetailsDialog {
  controller: CustomDialogController;
  private apInfo: WifiScanInfo;
  private disconnectAction: () => void;
  private value: string = '';
  private frequency: string = '2.4GHz';
  private speed: string = '144Mbps';
  @State dataList: any[] = [{key: $r('app.string.wifiInfoTitleStatus'),
                              value: $r('app.string.wifiSummaryConnected')},
                            {key: $r('app.string.wifiInfoTitleIntensity'),
                              value: $r('app.string.wifiSigIntensityBad')},
                            {key: $r('app.string.wifiInfoTitleSpeed'),
                              value: this.speed},
                            {key: $r('app.string.wifiInfoTitleFrequency'),
                              value: this.frequency},
                            {key: $r('app.string.wifiInfoTitleEncryptMethod'),
                              value: $r("app.string.wifiEncryptMethodOpen")}];

  private buttons: any[] = [{summary: $r('app.string.wifiButtonCancel'), opType: 0},
                            {summary: $r('app.string.wifiButtonDelete'), opType: 2}];

  build() {
    Column() {
      Column() {
        QRCode(this.value)
          .width(160)
          .height(160)
      }
      .width(ConfigData.WH_100_100)
      .margin({top: $r("app.float.wh_value_52")})
      .alignItems(HorizontalAlign.Center);

      Row() {
        Text(this.apInfo.ssid)
          .width(ConfigData.WH_100_100)
          .fontSize($r('app.float.font_24'))
          .fontColor($r('sys.color.ohos_id_color_text_primary'))
          .fontWeight(FontWeight.Medium)
          .textAlign(TextAlign.Center);
      }
      .width($r("app.float.wh_value_288"))
      .height($r("app.float.wh_value_32"))
      .margin({top: $r("app.float.wh_value_28")});

      Row() {
        Text($r("app.string.wifiTipsScanInfo"))
          .width(ConfigData.WH_100_100)
          .fontSize($r('sys.float.ohos_id_text_size_body2'))
          .fontColor($r('sys.color.ohos_id_color_text_secondary'))
          .fontWeight(FontWeight.Medium)
          .textAlign(TextAlign.Start);
      }
      .width($r("app.float.wh_value_250"))
      .height($r("app.float.wh_value_19"))
      .margin({top: $r("app.float.wh_value_6")});

      List() {
        ForEach(this.dataList, (item) => {
          ListItem() {
            ApInfoComponent({
              key: item.key,
              value: item.value
            });
          }
          .height($r('app.float.wh_value_48'))
          .onClick(() => {
            LogUtil.info(MODULE_TAG + 'clicked ap detail info item');
          })
        })
      }
      .margin({top:$r("app.float.wh_value_16"), left: $r("app.float.wh_value_24"), right: $r("app.float.wh_value_24")})
      .divider({
        strokeWidth: $r('app.float.wh_value_1'),
        color: $r('app.color.color_E3E3E3_grey'),
      })

      List() {
        ForEach(this.buttons, (item) => {
          ListItem() {
            Row() {
              Text(item.summary)
                .fontSize($r('sys.float.ohos_id_text_size_body1'))
                .fontColor($r('sys.color.ohos_id_color_text_primary_activated'))
                .fontWeight(FontWeight.Medium)
                .width(ConfigData.WH_100_100)
                .textAlign(TextAlign.Center);
            }
            .width($r("app.float.wh_value_160"))
            .height($r("app.float.wh_value_40"))
            .alignItems(VerticalAlign.Center)
          }
          .margin({left: $r("app.float.wh_value_4"), right: $r("app.float.wh_value_4")})
          .onClick(() => {
            if (item.opType === 0) {
              LogUtil.info(MODULE_TAG + 'clicked ap info cancel');
            }
            if (item.opType === 2) {
              LogUtil.info(MODULE_TAG + 'clicked ap info to disconnect');
              WifiModel.disconnectWiFi();
              WifiModel.removeDeviceConfig(this.apInfo);
              WifiModel.refreshApScanResults();
            }
            this.controller.close();
          })
        })
      }
      .margin({top:$r('app.float.wh_value_11'), bottom: $r('app.float.wh_value_16'),
        left: $r("app.float.wh_value_4"), right: $r("app.float.wh_value_4")})
      .height($r('app.float.wh_value_40'))
      .listDirection(Axis.Horizontal)
      .divider({
        strokeWidth: $r('app.float.wh_value_1'),
        color: $r('app.color.color_E3E3E3_grey'),
        startMargin: $r('app.float.wh_value_8'),
        endMargin: $r('app.float.wh_value_8')
      });
    }
    .alignItems(HorizontalAlign.Center)
    .height($r("app.float.wh_value_620"))
    .width($r("app.float.wh_value_336"))
    .borderRadius($r("app.float.radius_32"))
    .backgroundColor($r("app.color.white_bg_color"))
  }

  aboutToAppear(): void {
    // gen wifi signal level
    let intensity = WifiModel.getSignalIntensity(this.apInfo);
    let encryptType = WifiModel.getEncryptMethod(this.apInfo);
    let linkInfo = WifiModel.getLinkInfo();
    this.speed = linkInfo.linkSpeed + 'Mbps';
    this.frequency = (linkInfo.frequency / 1000).toFixed(1).toString() + 'GHz';
    this.dataList = [
      {key: $r('app.string.wifiInfoTitleStatus'),
        value: $r('app.string.wifiSummaryConnected')},
      {key: $r('app.string.wifiInfoTitleIntensity'),
        value: genWiFiIntensity(intensity)},
      {key: $r('app.string.wifiInfoTitleSpeed'),
        value: this.speed},
      {key: $r('app.string.wifiInfoTitleFrequency'),
        value: this.frequency},
      {key: $r('app.string.wifiInfoTitleEncryptMethod'),
        value: genWiFiEncryptMethod(encryptType)}
    ];
  }
}

@Component
struct WiFiEntryComponent {
  @Prop settingIcon: string; // 空白
  @Prop settingTitle: string; // SSID
  private settingSummary: string | Resource; // 状态描述
  @Prop settingValue: string; // 空白
  @Prop settingArrow: string; // WiFi图标
  @Prop settingUri: string; // 空白
  @Prop titleFontColor: string; // 字体颜色

  @State isTouched: boolean = false;

  build() {
    Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems:ItemAlign.Center }) {
      Row() {
        Column() {
          Text(this.settingTitle)
            .fontSize($r('sys.float.ohos_id_text_size_body1'))
            .fontColor(this.titleFontColor === "activated" ?
              $r('sys.color.ohos_id_color_text_primary_activated') :
              $r('sys.color.ohos_id_color_text_primary'))
            .fontWeight(FontWeight.Medium)
            .textAlign(TextAlign.Start);

          Row() {}
          .height($r('app.float.wh_value_8'))

          Text(this.settingSummary)
            .fontSize($r('sys.float.ohos_id_text_size_body2'))
            .fontColor(this.titleFontColor === "activated" ?
              $r('sys.color.ohos_id_color_text_primary') :
              $r('sys.color.ohos_id_color_text_secondary'))
            .fontWeight(FontWeight.Regular)
            .textAlign(TextAlign.Start)
        }
        .alignItems(HorizontalAlign.Start);
      }
      .flexShrink(0)
      .alignItems(VerticalAlign.Center)
      .margin({ left: $r("app.float.wh_value_12")})
      .align(Alignment.Start);

      Row() {
        Image(this.settingArrow)
          .width($r('app.float.wh_value_24'))
          .height($r('app.float.wh_value_24'))
      }
      .margin({ right: $r("app.float.wh_value_12")})
      .align(Alignment.End);

    }
    .height($r('app.float.wh_value_64'))
    .width(ConfigData.WH_100_100)
    .borderRadius($r("app.float.radius_24"))
    .backgroundColor(this.isTouched ? $r("app.color.color_D8D8D8_grey") :
      $r("sys.color.ohos_id_color_foreground_contrary"))
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        this.isTouched = true;
      }
      if (event.type === TouchType.Up) {
        this.isTouched = false;
      }
    })
  }
}
