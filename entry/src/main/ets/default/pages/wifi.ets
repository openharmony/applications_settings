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
import SubscriberUtils from '../common/baseUtil/SubscriberUtil.ets';
import WifiModel from '../model/wifiImpl/WifiModel.ets';
import HeadComponent from './component/headComponent.ets';
import EntryComponent from './component/entryComponent.ets';
import ImageAnimatorComponent from './component/imageAnimatorComponent.ets';
import ConfigData from '../common/baseUtil/ConfigData.ets';
import LogUtil from '../common/baseUtil/LogUtil.ets';
import Subscriber from '@ohos.commonevent';
import router from '@system.router';


@Entry
@Component
struct Index {
  @StorageLink('WifiList') wifiList: any[] = [];
  @StorageLink('wifiPsd') password: string = '';
  @State isOn: boolean = true;
  @State isShow: boolean = true;
  private connectPsd: string = '';
  private mIndex: number = -1;
  private timeoutFlag;
  private timeoutMark;
  @State connectRssi: number = -1;
  @State connectImage: string = '';
  @State connectName: string = '';
  @State connectBssid: string = '';
  @State connectSecurityType: number = -1;
  private mCommonEventSubscriber = null;
  private mCommonEventSubscribeInfo = {
    events: ["usual.event.wifi.CONN_STATE"]
  };

  build() {
    Column() {
      HeadComponent({ headName: $r('app.string.wifiTab'), isActive: true });
      Row() {
        Text($r('app.string.wifiTab'))
          .fontSize(ConfigData.font_22)
          .fontColor(Color.Black)
          .textAlign(TextAlign.Start)
        Toggle({ type: ToggleType.Switch, isOn: this.isOn })
          .width(390)
          .margin({ left: 280 })
          .height(ConfigData.value_40)
          .onChange((isOn: boolean) => {
          this.isOn = !this.isOn;
          if (this.isOn) {
            this.switchOn();
          } else {
            this.switchOff();
          }
        });
      }
      .width(ConfigData.WH_100_100)
      .height(ConfigData.value_70)
      .margin({ left: ConfigData.value_15, right: ConfigData.value_15 });

      Text($r('app.string.tipsContent'))
        .visibility(this.isOn ? Visibility.None : Visibility.Visible)
        .fontSize(ConfigData.font_20)
        .align(Alignment.Start)
        .margin({ left: ConfigData.value_15, right: ConfigData.value_15 });
      Column() {
        Row() {
          Text($r('app.string.wifiList'))
            .fontSize(ConfigData.font_24)
            .align(Alignment.Start);
          Row() {
            ImageAnimatorComponent({ imageWidth: ConfigData.value_40,
              imageHeight: ConfigData.value_40 })
          }
          .width(280)
          .margin({ left: 230 })
          .visibility(this.isShow ? Visibility.Visible : Visibility.None);
        }
        .width('100%')
        .margin({ left: ConfigData.value_15, right: ConfigData.value_15 });

        List() {
          ForEach(this.wifiList, (item) => {
            ListItem() {
              EntryComponent({
                settingIcon: '',
                settingTitle: item.settingTitle,
                settingSummary: item.settingSummary,
                settingValue: '',
                settingArrow: item.settingArrow,
                settingArrowStyle: 'wifi'
              });
            }.onClick(() => {
              this.connectName = item.settingTitle
              this.connectImage = item.settingArrow
              this.connectBssid = item.bssid
              this.connectSecurityType = item.securityType
              this.connectRssi = item.settingRssi
              this.connectWifi();
            })
            .height(ConfigData.value_60)
          }, item => JSON.stringify(item));
        }
        .divider({
          strokeWidth: ConfigData.value_1,
          color: ConfigData.color_E3E3E3,
          startMargin: ConfigData.value_15,
          endMargin: ConfigData.value_15
        })
        .width(ConfigData.WH_100_100)
        .height(ConfigData.WH_100_100)
        .align(Alignment.Top)
        .margin({ bottom: ConfigData.value_70, top: ConfigData.value_20 });
      }
      .width(ConfigData.WH_100_100)
      .height(ConfigData.WH_100_100)
      .visibility(this.isOn ? Visibility.Visible : Visibility.None);
    }
    .width(ConfigData.WH_100_100)
    .height(ConfigData.WH_100_100);
  }

  private aboutToAppear(): void {
    this.wifiStatusListener();
    this.getSwitchStatus();
    this.clearScanInfo();
    LogUtil.info('init wifi get switch status');
    if (this.isOn) {
      LogUtil.info('init wifi isOn is true');
      let that = this
      this.timeoutFlag = setTimeout(() => {
        if (WifiModel.getScanWifi()) {
          LogUtil.info('init wifi start scan');
          that.timeoutMark = setTimeout(() => {
            WifiModel.getScanInfoCallBack();
            that.isShow = false;
            clearTimeout(this.timeoutFlag);
            clearTimeout(that.timeoutMark);
            LogUtil.info('init wifi wifiList' + this.wifiList);
          }, 3000);
        } else {
          LogUtil.info('init scan wifiList fail');
        }
      }, 3000);
    } else {
      LogUtil.info('init wifi isOn is false');
    }
  }

  connectWifi() {
    LogUtil.info('[wifi_js_test] connect to wifi come in');
    let index = WifiModel.getItemPosition(this.wifiList, this.connectName);
    if (this.mIndex !== index) {
      this.connectPsd = '';
      this.mIndex = index;
    }
    let obj = {
      "ssid": this.connectName,
      "bssid": this.connectBssid,
      "preSharedKey": this.connectPsd,
      "isHiddenSsid": false,
      "securityType": this.connectSecurityType
    }
    if (!WifiModel.connectToDevice(obj)) {
      LogUtil.info("[wifi_js_test] connect to wifi failed");
      return;
    }

    LogUtil.info('[wifi_js_test] connectSecurityType' + this.connectSecurityType);
    LogUtil.info('[wifi_js_test] connectPsd' + this.connectPsd);
    LogUtil.info('[wifi_js_test] connectName' + this.connectName);
    if (this.connectSecurityType !== 1 && '' == this.connectPsd) {
      LogUtil.info('click to detail wifiPsd');
      let name = { 'connectName': this.connectName };
      this.mIndex = index;
      router.push({
        uri: 'pages/wifiPsd',
        params: name,
      });
      LogUtil.info('jump to detail end');
    }
    if (WifiModel.connectToDevice(obj)) {
      LogUtil.info('[wifi_js_test] connect to come in');
      LogUtil.info('[wifi_js_test] connect to come in obj' + JSON.stringify(obj));
      LogUtil.info('[wifi_js_test] connect to wifiList ' + JSON.stringify(this.wifiList));
    }
    LogUtil.info('clickToSecret end:');
  }

  getSwitchStatus() {
    if (WifiModel.getWifiStatus()) {
      this.isOn = true;
    } else {
      this.isOn = false;
    }
  }

  private switchOn() {
    LogUtil.info('switchClick wifi start ---->');
    this.clearScanInfo();
    this.isShow = true;
    if (WifiModel.getEnableWifi()) {
      LogUtil.info('switchClick wifi enableWifi enter ---->');
      let that = this;
      this.timeoutFlag = setTimeout(() => {
        if (WifiModel.getScanWifi()) {
          that.timeoutMark = setTimeout(() => {
            WifiModel.getScanInfoCallBack();
            that.isShow = false;
            clearTimeout(this.timeoutFlag);
            clearTimeout(that.timeoutMark);
            LogUtil.info('switchClick wifi wifiList' + JSON.stringify(this.wifiList));
          }, 3000);
        } else {
          LogUtil.info('switchClick wifi fail to scan ---->');
        }
      }, 3000);
    } else {
      LogUtil.info('switchClick wifi fail to enableWifi ---->');
    }
  }

  private switchOff() {
    LogUtil.info('switchClick wifi off start ---->');
    if (WifiModel.disableWifi()) {
      LogUtil.info('switchClick wifi enter to disableWifi ---->');
      this.clearScanInfo();
    } else {
      LogUtil.info('switchClick wifi off end ---->');
    }
  }

  wifiStatusListener() {
    LogUtil.info('wifi status listener');
    Subscriber.createSubscriber(this.mCommonEventSubscribeInfo,
      this.CreateSubscriberCallBack.bind(this));
  }

  CreateSubscriberCallBack(err, data) {
    LogUtil.info('subscriber subscribe');
    this.mCommonEventSubscriber = data;
    Subscriber.subscribe(this.mCommonEventSubscriber, this.SubscriberCallBack.bind(this));
  }

  SubscriberCallBack(err, data) {
    LogUtil.info('subscriber call back');
    LogUtil.info('==========================>SubscriberCallBack  event = ' + data.event);
    LogUtil.info('==========================>SubscriberCallBack  data = ' + JSON.stringify(data));
    LogUtil.info('==========================>SubscriberCallBack  data code = ' + data.code);

    if (data.code === 3) {
      let wifi = { 'name': '', 'rssi': 0 };
      wifi.name = this.connectName;
      wifi.rssi = this.connectRssi;
      SubscriberUtils.sendEvent(JSON.stringify(wifi), ConfigData.SENT_EVENT_WIFI_CONNECT_NAME);
      let index = WifiModel.getItemPosition(this.wifiList, this.connectName);
      this.wifiList.splice(index, 1);
      this.wifiList.unshift({
        settingSummary: '已连接',
        settingTitle: this.connectName,
        settingValue: '',
        settingArrow: this.connectImage,
        settingArrowStyle: 'wifi',
        settingRssi: this.connectRssi,
        bssid: this.connectBssid,
        securityType: this.connectSecurityType,
      });
      this.wifiList[1].settingSummary = '';
      LogUtil.info('subscriber connected' + JSON.stringify(this.wifiList));
    }
    ;
    if (data.code === 9) {
      LogUtil.info("subscriber code nine disconnected");
      this.wifiList.unshift({
        settingSummary: '',
        settingTitle: this.wifiList[0].settingTitle,
        settingValue: '',
        settingArrow: this.wifiList[0].settingArrow,
        settingArrowStyle: 'wifi',
        settingRssi: this.wifiList[0].settingRssi,
        bssid: this.wifiList[0].bssid,
        securityType: this.wifiList[0].securityType,
      });
      this.wifiList.splice(1, 1);
    }
  }

  unSubscriberListener() {
    Subscriber.unsubscribe(this.mCommonEventSubscriber, () => {
      LogUtil.info('wifi unsubscribe');
    });
  }

  clearScanInfo() {
    LogUtil.info('clear scan wifiList start---->');
    this.wifiList = [];
    LogUtil.info('clear scan wifiList end---->');
  }

  private aboutToDisappear(): void {
    this.unSubscriberListener();
    this.connectPsd = '';
  }

  onPageShow() {
    LogUtil.info('wifi onPageShow this.password:' + this.password);
    this.connectPsd = this.password;
    if (this.connectPsd !== '') {
      this.connectWifi();
    }
  }

  onBackPress() {
    Navigator().active(true);
  }
}




