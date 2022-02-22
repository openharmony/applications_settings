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
import WifiModel from '../model/wifiImpl/WifiModel.ets';
import HeadComponent from '../../../../../../../common/component/src/main/ets/default/headComponent.ets';
import EntryComponent from '../../../../../../../common/component/src/main/ets/default/entryComponent.ets';
import ImageAnimatorComponent from '../../../../../../../common/component/src/main/ets/default/imageAnimatorComponent.ets';
import ConfigData from '../../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData.ets';
import LogUtil from '../../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil.ets';
import ResourceUtil from '../../../../../../../common/search/src/main/ets/default/common/ResourceUtil.ets';
import Subscriber from '@ohos.commonevent';
import router from '@system.router';

const MODULE_TAG = ConfigData.TAG + '.Wifi -> ';

@Entry
@Component
struct Index {
  @StorageLink('slWiFiLists') scanWiFiResults: [] = [];

  private isWlanEnable: boolean = true;
  @State isWlanListShown: boolean = true;
  @State refreshFlag: boolean = true;
  private intervalStatus : number = -1;

  private wifiEventsSubscriber = null;
  private wifiEvents = {
    events: ["usual.event.wifi.CONN_STATE", "usual.event.wifi.SCAN_FINISHED"],
  };

  build() {
    Column() {
      HeadComponent({ headName: $r('app.string.wifiTab'), isActive: true });
      Flex({ justifyContent: FlexAlign.SpaceBetween }) {
        Row() {
          Text($r('app.string.wifiTab'))
            .fontSize($r('app.float.font_24'))
            .fontColor(Color.Black)
            .textAlign(TextAlign.Start);
        }.alignItems(VerticalAlign.Center);
        Toggle({ type: ToggleType.Switch, isOn: this.isWlanEnable })
          .width($r('app.float.wh_value_50'))
          .height($r('app.float.wh_value_40'))
          .onChange((isOn: boolean) => {
          this.isWlanEnable = !this.isWlanEnable;
          LogUtil.info(MODULE_TAG + 'Toggle onChange for Wlan Enable:' + this.isWlanEnable);
          if (this.isWlanEnable) {
            this.switchOn();
          } else {
            this.switchOff();
          }
        });
      }
      .height($r('app.float.wh_value_70'))
      .margin({ left: $r('app.float.wh_value_15'), right: $r('app.float.wh_value_15') });

      Flex({ alignItems: ItemAlign.Start }) {
        Text($r('app.string.tipsContent'))
          .fontSize($r('app.float.font_20'));
      }
      .visibility(this.isWlanEnable ? Visibility.None : Visibility.Visible)
      .margin({ left: $r('app.float.wh_value_15'), right: $r('app.float.wh_value_15') });

      Column() {
        Flex({ justifyContent: FlexAlign.SpaceBetween }) {
          Text($r('app.string.wifiList'))
            .fontSize($r('app.float.font_24'))
            .align(Alignment.Start);
          Row() {
            ImageAnimatorComponent({ imageWidth: $r('app.float.wh_value_40'),
              imageHeight: $r('app.float.wh_value_40') })
          }
          .width($r('app.float.wh_value_40'))
          .visibility(this.isWlanListShown ? Visibility.Visible : Visibility.None);
        }
        .margin({ left: $r('app.float.wh_value_15'), right: $r('app.float.wh_value_15') });

        List() {
          ForEach(this.scanWiFiResults, (item) => {
            ListItem() {
              EntryComponent({
                settingIcon: item.settingIcon,
                settingTitle: item.settingTitle,
                settingSummary: item.settingSummary,
                settingValue: item.settingValue,
                settingArrow: item.settingArrow,
                settingArrowStyle: item.settingArrowStyle,
                settingUri: item.settingUri
              });
            }
            .onClick(() => {
              this.jumpToApDetails(item.apInfo);
            })
            .height($r('app.float.wh_value_60'))
          }, item => JSON.stringify(item));
        }
        .divider({
          strokeWidth: $r('app.float.wh_value_1'),
          color: $r('app.color.color_E3E3E3_grey'),
          startMargin: $r('app.float.wh_value_15'),
          endMargin: $r('app.float.wh_value_15')
        })
        .margin({top:$r('app.float.wh_value_20')});
      }
      .margin({bottom:$r('app.float.wh_value_20')})
      .layoutWeight(1)
      .visibility(this.isWlanEnable ? Visibility.Visible : Visibility.None);
    }
    .height(ConfigData.WH_100_100)
  }

  jumpToApDetails(apInfo: any) {
    LogUtil.info(MODULE_TAG + 'start to connect WiFi');
    WifiModel.setUserSelectedAp(apInfo);
    let isConnected = false;
    if (WifiModel.getConnectedAp().getApInfo().ssid === apInfo.ssid) {
      isConnected = true;
    }
    let params = {
      apInfo: apInfo,
      isConnected: isConnected
    };
    router.push({
      uri: 'pages/wifiPsd',
      params: params,
    });
  }

  private switchOn() {
    LogUtil.info(MODULE_TAG + 'WLAN switch on');
    this.setIntervalTask();
    if (WifiModel.isWiFiActive() === true) {
      LogUtil.info(MODULE_TAG + 'WLAN already is on');
      this.isWlanListShown = true;
      return;
    }
    let ret = WifiModel.enableWiFi();
    LogUtil.info(MODULE_TAG + 'enable wifi ret is : ' + ret);
    if (ret === true) {
      this.isWlanListShown = true;
    }
  }

  private switchOff() {
    LogUtil.info(MODULE_TAG + 'WLAN switch off');
    this.clearIntervalTask();
    if (WifiModel.isWiFiActive() === false) {
      LogUtil.info(MODULE_TAG + 'WLAN already is off');
      this.isWlanListShown = false;
      return;
    }
    // disconnect the connection before wifi disable
    WifiModel.disconnectWiFi();
    let ret = WifiModel.disableWifi();
    LogUtil.info(MODULE_TAG + 'disable wifi ret is : ' + ret);
    if (ret === false) {
      this.isWlanListShown = false;
    }
  }

  wifiConnectStatusCallback(err, data) {
    // connecting
    if (data.code === WifiModel.wiFiStatusEnum.Connecting) {
      LogUtil.info(MODULE_TAG + 'code 1 : connecting');
    }
    // connected
    if (data.code === WifiModel.wiFiStatusEnum.ApConnected) {
      LogUtil.info(MODULE_TAG + 'code 4 : connected');
    }
    // disconnected
    if (data.code === WifiModel.wiFiStatusEnum.Disconnecting ||
        data.code === WifiModel.wiFiStatusEnum.Disconnected) {
      LogUtil.info(MODULE_TAG + 'code 5, 6 : disconnected');
    }
    WifiModel.refreshApScanResults();
    // refresh the page contents
    this.refreshFlag = !this.refreshFlag;
  }

  wifiEventsCallbackCreator(err, data) {
    LogUtil.info(MODULE_TAG + 'create create Subscriber CallBack');
    this.wifiEventsSubscriber = data;
    Subscriber.subscribe(this.wifiEventsSubscriber, this.wifiConnectStatusCallback.bind(this));
  }

  /**
   * WiFi status monitoring
   */
  createWiFiStatusListener() {
    LogUtil.info(MODULE_TAG + 'create wifi status listener');
    Subscriber.createSubscriber(this.wifiEvents, this.wifiEventsCallbackCreator.bind(this));
  }

  /**
   * Cancel WiFi status listening
   */
  destroyWiFiStatusListener() {
    Subscriber.unsubscribe(this.wifiEventsSubscriber, () => {
      LogUtil.info(MODULE_TAG + 'unsubscribe wifi listener');
    });
  }

  aboutToAppear(): void {
    LogUtil.info(MODULE_TAG + 'about to appear wifi page');
    ResourceUtil.getString($r("app.string.connected")).then(value => WifiModel.setConnectedSummary(value));
    this.createWiFiStatusListener();
    if (WifiModel.isWiFiActive()) {
      this.isWlanEnable = true;
      this.isWlanListShown = true;
    } else {
      this.isWlanEnable = false;
      this.isWlanListShown = false;
    }
  }

  aboutToDisappear(): void {
    LogUtil.info(MODULE_TAG + 'about to disappear wifi page');
    this.destroyWiFiStatusListener();
  }

  onPageShow() {
    LogUtil.info(MODULE_TAG + 'on page show wifi');
    this.setIntervalTask();
    WifiModel.setIntervalScanTask();

    let params = router.getParams();
    if (params !== null && typeof params !== 'undefined') {
      LogUtil.info(MODULE_TAG + 'settings wifiPsd page params is : ' + JSON.stringify(params.opType));
      let opType = params.opType;
      if (opType === 'disconnect') {
        WifiModel.disconnectWiFi();
      }
      if (opType === 'connect') {
        let ret = WifiModel.connectWiFi(params.password);
        LogUtil.info(MODULE_TAG + 'ret of confirm connect to is : ' + ret);
      }
    }
  }

  onPageHide(): void {
    LogUtil.info(MODULE_TAG + 'on page hide wifi');
    this.clearIntervalTask();
    WifiModel.clearIntervalScanTask();
  }

  onBackPress() {
    Navigator().active(true);
  }

  clearIntervalTask() {
    if (this.intervalStatus !== -1) {
      LogUtil.info(MODULE_TAG + 'clear interval status');
      clearInterval(this.intervalStatus);
    }
  }

  setIntervalTask() {
    this.clearIntervalTask();
    this.intervalStatus = setInterval(() => {
      this.refreshFlag = !this.refreshFlag;
    }, 3000);
  }
}
