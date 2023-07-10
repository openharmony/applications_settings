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

import prompt from '@system.prompt';
import router from '@system.router';
import deviceInfo from '@ohos.deviceInfo';
import WifiModel from '../model/wifiImpl/WifiModel';
import LogUtil from '../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import ConfigData from '../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData';
import HeadComponent from '../../../../../../common/component/src/main/ets/default/headComponent';
import ResourceUtil from '../../../../../../common/search/src/main/ets/default/common/ResourceUtil';
import ImageAnimatorComponent from '../../../../../../common/component/src/main/ets/default/imageAnimatorComponent';
import { WifiScanInfo, ApScanResult, WiFiSummaryMap, WiFiIntensityMap, WiFiEncryptMethodMap } from '../model/wifiImpl/WifiModel';

const MODULE_TAG = ConfigData.TAG + 'WifiModel.wifi -> ';
const deviceTypeInfo = deviceInfo.deviceType;

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
  scroller: Scroller = new Scroller();
  @StorageLink('slWiFiLists') scanWiFiResults: [] = [];
  @StorageLink('slConnectedWifi') connectedWiFi: any = [];
  @State isWiFiEnabled: boolean = false;
  @State isPhoneOrRK: boolean = false;
  @State userSelectedApInfo: WifiScanInfo = {
    ssid: '',
    bssid: '',
    rssi: -100,
    band: 0,
    frequency: 0,
    timestamp: 0,
    securityType: 1,
  };
  private switchDebounceFlag = undefined;
  private timerId: number = -1;
  private errorMessage: string = "";

  private clickApInfoDialog: CustomDialogController = new CustomDialogController({
    builder: apInfoDialog({
      apInfo: this.userSelectedApInfo,
    }),
    alignment: deviceTypeInfo === 'phone' || deviceTypeInfo === 'default' ? DialogAlignment.Bottom : DialogAlignment.Center,
    offset: ({ dx: 0, dy: deviceTypeInfo === 'phone' || deviceTypeInfo === 'default' ? '-24dp' : 0 }),
    autoCancel: true,
    customStyle: true
  });

  private clickApInfoDetailsDialog: CustomDialogController = new CustomDialogController({
    builder: apInfoDetailsDialog({
      apInfo: this.userSelectedApInfo,
      disconnectAction: () => {
        WifiModel.disconnectWiFi();
        WifiModel.refreshApScanResults();
      }
    }),
    alignment: deviceTypeInfo === 'phone' || deviceTypeInfo === 'default' ? DialogAlignment.Bottom : DialogAlignment.Center,
    offset: ({ dx: 0, dy: deviceTypeInfo === 'phone' || deviceTypeInfo === 'default' ? '-24dp' : 0 }),
    autoCancel: true,
    customStyle: true
  });

  build() {
    Column() {
      GridContainer({ gutter: ConfigData.GRID_CONTAINER_GUTTER_24, margin: ConfigData.GRID_CONTAINER_MARGIN_24 }) {
        Column() {
          HeadComponent({ headName: $r('app.string.wifiTab'), isActive: true });

          Row() {
            Text($r('app.string.wifiTab'))
              .fontSize($r('sys.float.ohos_id_text_size_body1'))
              .fontColor($r('sys.color.ohos_id_color_text_primary'))
              .fontWeight(FontWeight.Medium)
              .textAlign(TextAlign.Start)

            Blank()

            Toggle({ type: ToggleType.Switch, isOn: this.isWiFiEnabled })
              .width('36vp')
              .height('20vp')
              .selectedColor('#007DFF')
              .onChange((isOn: boolean) => {
                this.switchWiFiActiveStatus(isOn);
              });
          }
          .height($r('app.float.wh_value_56'))
          .width(ConfigData.WH_100_100)
          .alignItems(VerticalAlign.Center)
          .margin({ top: $r("app.float.distance_8") })
          .padding({ left: $r("app.float.wh_value_12"), right: $r('app.float.wh_value_6') })
          .backgroundColor($r("app.color.white_bg_color"))
          .borderRadius($r('app.float.radius_24'));

          Scroll(this.scroller) {
            Column() {
              Column() {
                Row() {
                  Text($r("app.string.wifiTipConnectedWLAN"))
                    .fontSize($r('sys.float.ohos_id_text_size_body2'))
                    .fontColor($r('sys.color.ohos_id_color_text_secondary'))
                    .fontWeight(FontWeight.Medium)
                    .textAlign(TextAlign.Start)
                    .height($r('app.float.distance_19'));
                }
                .height($r("app.float.wh_value_48"))
                .width(ConfigData.WH_100_100)
                .padding({
                  left: $r('app.float.wh_value_12'),
                  top: $r('app.float.distance_19_5'),
                  bottom: $r('app.float.distance_9_5')
                })
                .justifyContent(FlexAlign.Start);

                Column() {
                  ConnectedWiFiEntryComponent({
                    connectedWiFi: $connectedWiFi,
                    titleFontColor: "activated"
                  })
                }
                .height($r("app.float.wh_value_64"))
                .borderRadius($r("app.float.radius_24"))
                .backgroundColor($r("app.color.white_bg_color"))
                .margin({ top: $r("app.float.wh_value_4"), bottom: $r("app.float.wh_value_4") })
                .onClick(() => {
                  LogUtil.info(MODULE_TAG + 'clicked connected wifi item');
                  this.userSelectedApInfo = this.connectedWiFi.apInfo;
                  this.clickApInfoDetailsDialog.open();
                  LogUtil.info(MODULE_TAG + 'end!!!');
                });
              }
              .visibility(this.isNeedRenderConnectedWiFi() ? Visibility.Visible : Visibility.None);

              Column() {
                Row() {
                  Text($r("app.string.wifiTipValidWLAN"))
                    .fontSize($r('sys.float.ohos_id_text_size_body2'))
                    .fontColor($r('sys.color.ohos_id_color_text_secondary'))
                    .fontWeight(FontWeight.Medium)
                    .height($r('app.float.wh_value_19'))
                    .margin({ top: $r('app.float.distance_19_5'), bottom: $r('app.float.distance_9_5') });

                  Blank()

                  ImageAnimatorComponent({
                    imageWidth: $r('app.float.wh_value_24'),
                    imageHeight: $r('app.float.wh_value_24')
                  })
                }
                .height($r("app.float.wh_value_48"))
                .width(ConfigData.WH_100_100)
                .padding({ left: $r('app.float.wh_value_12'), right: $r('app.float.wh_value_12') })
                .alignItems(VerticalAlign.Center);

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
                  .margin({ top: $r('app.float.wh_value_4'), bottom: $r('app.float.wh_value_4') })
                  .divider({
                    strokeWidth: $r('app.float.divider_wh'),
                    color: $r('app.color.color_E3E3E3_grey'),
                    startMargin: $r("app.float.wh_value_12"),
                    endMargin: $r("app.float.wh_value_12"),
                  });
                }
                .borderRadius($r("app.float.radius_24"))
                .backgroundColor($r("app.color.white_bg_color"))
                .visibility(this.scanWiFiResults.length !== 0 ? Visibility.Visible : Visibility.None)
              }
              .visibility(this.isWiFiEnabled ? Visibility.Visible : Visibility.None);
            }
          }
          .width(ConfigData.WH_100_100)
          .borderRadius($r("app.float.radius_24"))
          .scrollable(ScrollDirection.Vertical)
          .scrollBar(BarState.Off)
          .layoutWeight(ConfigData.LAYOUT_WEIGHT_1)
          .align(Alignment.Top);
        }
        .useSizeType({
          sm: { span: 4, offset: 0 },
          md: { span: 6, offset: 1 },
          lg: { span: 8, offset: 2 }
        });
      }
      .width(ConfigData.WH_100_100)
      .height(ConfigData.WH_100_100)
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
    let titleSign: boolean = (!!this.connectedWiFi.settingTitle) && (this.connectedWiFi.settingTitle.length > 0);
    let arrowSign: boolean = (!!this.connectedWiFi.settingArrow) && (this.connectedWiFi.settingArrow.length > 0);
    if (titleSign && arrowSign) {
      return true;
    }
    return false;
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

  timeLimits() {
    this.timerId = setTimeout(() => {
      if(this.isWiFiEnabled == WifiModel.isWiFiActive()) {
        this.timerId = -1;
        return;
      }
      this.isWiFiEnabled = WifiModel.isWiFiActive();
      LogUtil.error(MODULE_TAG + 'wifi timeLimits active status : ' + this.isWiFiEnabled);
      this.timerId = -1;
      prompt.showToast({
        message: this.errorMessage,
        duration: 1000,
      });
    }, 5000)
  }

  switchWiFiActiveStatus(isOn: boolean) {
    // make the ui change quickly
    this.isWiFiEnabled = isOn;
    LogUtil.info(MODULE_TAG + 'curr enable status : ' + this.isWiFiEnabled);

    // delay the wifi status change event
    if (this.switchDebounceFlag) {
      clearTimeout(this.switchDebounceFlag);
    }

    if (this.timerId != -1) {
      clearTimeout(this.timerId);
    }

    this.switchDebounceFlag = setTimeout(() => {
      if (this.isWiFiEnabled) {
        LogUtil.info(MODULE_TAG + 'enable wifi');
        WifiModel.enableWiFi();
      } else {
        LogUtil.info(MODULE_TAG + 'disable wifi');
        WifiModel.disableWifi();
      }
      this.switchDebounceFlag = undefined;
      this.timeLimits();
    }, 500);
  }

  aboutToAppear(): void {
    LogUtil.info(MODULE_TAG + 'about to appear wifi page');
    try {
      ResourceUtil.getString($r('app.string.ERROR_WIFI_CHANGE')).then((data) => {
        this.errorMessage = data;
      })
    } catch (error) {
      LogUtil.error(MODULE_TAG + 'get errorMessage String error:' + JSON.stringify(error));
    }
    WifiModel.registerWiFiStatusObserver((code) => {
      LogUtil.info(MODULE_TAG + 'wifi status code : ' + code + ' taskId : ' + this.switchDebounceFlag);
      if ((!this.switchDebounceFlag) && (code == 0 || code == 1)) {
        this.isWiFiEnabled = Boolean(code);
        LogUtil.info(MODULE_TAG + 'wifi active status code : ' + code + " isWiFiEnabled" + this.isWiFiEnabled);
        if (this.timerId != -1) {
          clearTimeout(this.timerId);
          this.timerId = -1;
        }
      }
    });
    // init wifi active status
    this.isWiFiEnabled = WifiModel.isWiFiActive();
    AppStorage.SetOrCreate('slConnectedWifi', (new ApScanResult()).renderToListModel());
  }

  aboutToDisappear(): void {
    LogUtil.info(MODULE_TAG + 'about to disappear');
    if (this.timerId != -1) {
      clearTimeout(this.timerId);
    }
    if (this.switchDebounceFlag) {
      clearTimeout(this.switchDebounceFlag);
    }
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
    LogUtil.info('settings Wifi onBackPress');
  }
}

@Component
export default struct ApInfoComponent {
  @State label: string = "";
  @State value: string = "";

  build() {
    Row() {
      Text(this.label)
        .fontSize($r('sys.float.ohos_id_text_size_body1'))
        .fontColor($r('sys.color.ohos_id_color_text_primary'))
        .fontWeight(FontWeight.Medium)
        .textAlign(TextAlign.Start);

      Blank();

      Text(this.value)
        .fontSize($r('sys.float.ohos_id_text_size_body2'))
        .fontColor($r('sys.color.ohos_id_color_text_secondary'))
        .fontWeight(FontWeight.Regular)
        .textAlign(TextAlign.End);
    }
    .height($r('app.float.wh_value_48'))
    .width(ConfigData.WH_100_100)
    .backgroundColor($r("app.color.white_bg_color"))
    .alignItems(VerticalAlign.Center);
  }
}

/**
 * Choose Unlock Method Dialog
 */
@CustomDialog
struct apInfoDialog {
  controller: CustomDialogController;
  private apInfo: WifiScanInfo;
  @State dataList: any[] = [{ key: $r('app.string.wifiInfoTitleIntensity'),
                              value: $r('app.string.wifiSigIntensityBad') },
                            { key: $r('app.string.wifiInfoTitleEncryptMethod'),
                              value: $r('app.string.wifiEncryptMethodOpen') }];

  // 0 is cancel, 1 is delete, 2 is connect
  private buttons: any[] = [{ summary: $r('app.string.wifiButtonCancel'), opType: 0 },
                            { summary: $r('app.string.wifiButtonDelete'), opType: 1 },
                            { summary: $r('app.string.wifiButtonConnect'), opType: 2 }];

  build() {
    Column() {
      Column() {
        Row() {
          Text(this.apInfo.ssid)
            .fontSize($r('app.float.font_20'))
            .fontColor($r('sys.color.ohos_id_color_text_primary'))
            .fontWeight(FontWeight.Medium)
            .align(Alignment.Start)
        }
        .height($r("app.float.wh_value_56"))
        .width(ConfigData.WH_100_100)
        .padding({ left: $r("app.float.wh_value_24"), right: $r("app.float.wh_value_24") })

        List() {
          ForEach(this.dataList, (item) => {
            ListItem() {
              ApInfoComponent({
                label: item.key,
                value: item.value
              });
            }
            .height($r('app.float.wh_value_48'))
            .onClick(() => {
              LogUtil.info(MODULE_TAG + 'clicked ap info item');
            })
          })
        }
        .margin({ left: $r("app.float.wh_value_24"), right: $r("app.float.wh_value_24") })
        .divider({
          strokeWidth: $r('app.float.divider_wh'),
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
                  .textAlign(TextAlign.Center)
              }
              .width($r("app.float.dialog_118"))
              .height($r("app.float.wh_value_40"))
              .alignItems(VerticalAlign.Center)
            }
            .margin({ left: $r("app.float.wh_value_4"), right: $r("app.float.wh_value_4") })
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
        .margin({
          top: $r('app.float.wh_value_8'),
          left: $r("app.float.wh_value_16"),
          right: $r("app.float.wh_value_16"),
          bottom: $r("app.float.wh_value_16")
        })
        .height($r('app.float.wh_value_40'))
        .listDirection(Axis.Horizontal)
        .divider({
          strokeWidth: $r('app.float.divider_wh'),
          color: $r('app.color.color_E3E3E3_grey'),
          startMargin: $r('app.float.wh_value_8'),
          endMargin: $r('app.float.wh_value_8')
        })
      }
      .height($r("app.float.wh_value_216"))
      .borderRadius($r("app.float.radius_32"))
      .backgroundColor($r("app.color.white_bg_color"))
    }
    .width(deviceTypeInfo === 'phone' || deviceTypeInfo === 'default' ? ConfigData.WH_100_100 : $r("app.float.wh_value_410"))
    .padding(deviceTypeInfo === 'phone' || deviceTypeInfo === 'default' ? { left: $r("app.float.wh_value_12"), right: $r("app.float.wh_value_12") } : {})
  }

  aboutToAppear(): void {
    // gen wifi signal level
    let intensity = WifiModel.getSignalIntensity(this.apInfo);
    let encryptType = WifiModel.getEncryptMethod(this.apInfo);
    this.dataList = [
      { key: $r('app.string.wifiInfoTitleIntensity'),
        value: genWiFiIntensity(intensity) },
      { key: $r('app.string.wifiInfoTitleEncryptMethod'),
        value: genWiFiEncryptMethod(encryptType) }
    ];
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
  @State dataList: any[] = [
    { key: $r('app.string.wifiInfoTitleStatus'),
      value: $r('app.string.wifiSummaryConnected') },
    { key: $r('app.string.wifiInfoTitleIntensity'),
      value: $r('app.string.wifiSigIntensityBad') },
    { key: $r('app.string.wifiInfoTitleSpeed'),
      value: this.speed },
    { key: $r('app.string.wifiInfoTitleFrequency'),
      value: this.frequency },
    { key: $r('app.string.wifiInfoTitleEncryptMethod'),
      value: $r("app.string.wifiEncryptMethodOpen") }
  ];

  private buttons: any[] = [
    { summary: $r('app.string.wifiButtonCancel'), opType: 0 },
    { summary: $r('app.string.wifiButtonDelete'), opType: 2 }
  ];

  build() {
    Column() {
      Column() {
        Column() {
          QRCode(this.value)
            .width(160)
            .height(160)
        }
        .width(ConfigData.WH_100_100)
        .margin({ top: $r("app.float.wh_48") })
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
        .margin({ top: $r("app.float.wh_value_28") });

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
        .margin({ top: $r("app.float.wh_value_6") });

        List() {
          ForEach(this.dataList, (item) => {
            ListItem() {
              ApInfoComponent({
                label: item.key,
                value: item.value
              });
            }
            .height($r('app.float.wh_value_48'))
            .onClick(() => {
              LogUtil.info(MODULE_TAG + 'clicked ap detail info item');
            })
          })
        }
        .margin({
          top: $r("app.float.wh_value_16"),
          left: $r("app.float.wh_value_24"),
          right: $r("app.float.wh_value_24")
        })
        .divider({
          strokeWidth: $r('app.float.divider_wh'),
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
                  .textAlign(TextAlign.Center)
              }
              .width($r("app.float.wh_value_160"))
              .height($r("app.float.wh_value_40"))
              .alignItems(VerticalAlign.Center)
            }
            .margin({ left: $r("app.float.wh_value_4"), right: $r("app.float.wh_value_4") })
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
        .margin({
          top: $r('app.float.wh_value_8'),
          bottom: $r('app.float.wh_value_16'),
          left: $r("app.float.wh_value_4"),
          right: $r("app.float.wh_value_4")
        })
        .height($r('app.float.wh_value_40'))
        .listDirection(Axis.Horizontal)
        .divider({
          strokeWidth: $r('app.float.divider_wh'),
          color: $r('app.color.color_E3E3E3_grey'),
          startMargin: $r('app.float.wh_value_8'),
          endMargin: $r('app.float.wh_value_8')
        });
      }
      .alignItems(HorizontalAlign.Center)
      .height($r("app.float.wh_value_620"))
      .padding({ top: $r('app.float.wh_value_6') })
      .borderRadius($r("app.float.radius_32"))
      .backgroundColor($r("app.color.white_bg_color"))
    }
    .width(deviceInfo.deviceType === 'phone' ? ConfigData.WH_100_100 : $r("app.float.wh_value_410"))
    .padding(deviceInfo.deviceType === 'phone' ? { left: $r("app.float.wh_value_12"), right: $r("app.float.wh_value_12") }: {})
  }

  aboutToAppear(): void {
    // gen wifi signal level
    let intensity = WifiModel.getSignalIntensity(this.apInfo);
    let encryptType = WifiModel.getEncryptMethod(this.apInfo);
    let linkInfo = WifiModel.getLinkInfo();
    if (linkInfo != undefined) {
      this.speed = linkInfo.linkSpeed + 'Mbps';
      //5.0GHz limit:[5180MHz,5825MHz],2.4GHz limit:[2412MHz,2484MHz]
      LogUtil.info(MODULE_TAG + 'get frequency: ' + linkInfo.frequency);
      this.frequency = linkInfo.frequency > 3500 ? "5GHz":"2.4GHz";
    }
    this.dataList = [
      { key: $r('app.string.wifiInfoTitleStatus'),
        value: $r('app.string.wifiSummaryConnected') },
      { key: $r('app.string.wifiInfoTitleIntensity'),
        value: genWiFiIntensity(intensity) },
      { key: $r('app.string.wifiInfoTitleSpeed'),
        value: this.speed },
      { key: $r('app.string.wifiInfoTitleFrequency'),
        value: this.frequency },
      { key: $r('app.string.wifiInfoTitleEncryptMethod'),
        value: genWiFiEncryptMethod(encryptType) }
    ];
  }
}

@Component
struct WiFiEntryComponent {
  @State settingIcon: string = "";
  @State settingTitle: string = "";
  @State settingValue: string = "";
  @State settingArrow: string = "";
  @State settingUri: string = "";
  @State titleFontColor: string = "";
  private settingSummary: string | Resource; // 状态描述
  @State isTouched: boolean = false;

  build() {
    Row() {
      Column() {
        Text(this.settingTitle)
          .fontSize($r('sys.float.ohos_id_text_size_body1'))
          .fontColor(this.titleFontColor === "activated" ?
          $r('sys.color.ohos_id_color_text_primary_activated') : $r('sys.color.ohos_id_color_text_primary'))
          .fontWeight(FontWeight.Medium);

        Text(this.settingSummary)
          .fontSize($r('sys.float.ohos_id_text_size_body2'))
          .fontColor(this.titleFontColor === "activated" ?
          $r('sys.color.ohos_id_color_text_primary') : $r('sys.color.ohos_id_color_text_secondary'))
          .fontWeight(FontWeight.Regular)
          .margin({ top: $r('app.float.wh_value_8')});
      }
      .margin({ left: $r("app.float.wh_value_12") })
      .alignItems(HorizontalAlign.Start)

      Blank()

      Image(this.settingArrow)
        .fillColor($r("sys.color.ohos_id_color_primary"))
        .width($r('app.float.wh_value_24'))
        .height($r('app.float.wh_value_24'))
        .margin({ right: $r("app.float.wh_value_12") });
    }
    .height($r('app.float.wh_value_64'))
    .width(ConfigData.WH_100_100)
    .borderRadius($r("app.float.radius_24"))
    .alignItems(VerticalAlign.Center)
    .backgroundColor(this.isTouched ? $r("app.color.color_D8D8D8_grey") : $r("sys.color.ohos_id_color_foreground_contrary"))
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

@Component
struct ConnectedWiFiEntryComponent {
  @Link connectedWiFi: any;
  @State titleFontColor: string = "";
  @State isTouched: boolean = false;

  build() {
    Row() {
      Column() {
        Text(this.connectedWiFi.settingTitle)
          .fontSize($r('sys.float.ohos_id_text_size_body1'))
          .fontColor(this.titleFontColor === "activated" ?
          $r('sys.color.ohos_id_color_text_primary_activated') : $r('sys.color.ohos_id_color_text_primary'))
          .fontWeight(FontWeight.Medium);

        Text(genWiFiStatusSummary(this.connectedWiFi.settingSummary))
          .fontSize($r('sys.float.ohos_id_text_size_body2'))
          .fontColor(this.titleFontColor === "activated" ?
          $r('sys.color.ohos_id_color_text_primary') : $r('sys.color.ohos_id_color_text_secondary'))
          .fontWeight(FontWeight.Regular)
          .margin({ top: $r('app.float.wh_value_8')});
      }
      .margin({ left: $r("app.float.wh_value_12") })
      .alignItems(HorizontalAlign.Start)

      Blank()

      Image(this.connectedWiFi.settingArrow)
        .fillColor($r("sys.color.ohos_id_color_primary"))
        .width($r('app.float.wh_value_24'))
        .height($r('app.float.wh_value_24'))
        .margin({ right: $r("app.float.wh_value_12") });
    }
    .height($r('app.float.wh_value_64'))
    .width(ConfigData.WH_100_100)
    .borderRadius($r("app.float.radius_24"))
    .alignItems(VerticalAlign.Center)
    .backgroundColor(this.isTouched ? $r("app.color.color_D8D8D8_grey") : $r("sys.color.ohos_id_color_foreground_contrary"))
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
