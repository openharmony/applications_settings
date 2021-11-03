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
import LogUtil from '../common/baseUtil/LogUtil.ets';
import ConfigData from '../common/baseUtil/ConfigData.ets';
import EntryComponent from './component/entryComponent.ets';
import HeadComponent from './component/headComponent.ets';
import SettingListModel from '../model/settingListImpl/SettingListModel.ets';
import WifiModel from '../model/wifiImpl/WifiModel.ets';
import SubscriberUtils from '../common/baseUtil/SubscriberUtil.ets';
import GlobalResourceManager from '../common/baseUtil/GlobalResourceManager.ets';
import BrightnessSettingModel from '../model/brightnessImpl/BrightnessSettingModel.ets';
import DataRdbService from '../model/dataRdbImpl/DataRdbService.ets';
import DataRdbModel from '../model/dataRdbImpl/DataRdbModel.ets';
import Stable from '../common/baseUtil/Global.ets';
import RdbStoreUtil from '../common/baseUtil/RdbStoreUtil.ets';
import Router from '@system.router';

const SETTING_LIST_INDEX = 0;
const PAGE_WIFI = 'pages/wifi';

@Entry
@Component
struct SettingList {
  @StorageLink('settingsList') settingsList: any[]= [];
  @State wifiStatus: boolean= false;
  @State status: any= '';

  build() {
    Column() {
      HeadComponent({ icBackIsVisibility: false, headName: $r('app.string.settings'), isActive: false });
      List() {
        ForEach(this.settingsList, (item) => {
          ListItem() {
            Navigator({ target: item.settingUri }) {
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
          }
          .onClick(() => {
            Router.push({
              uri: item.settingUri,
            });
          })
          .height($r('app.float.wh_value_70'));
        });
      }
      .divider({
        strokeWidth: 1,
        color: $r('app.color.color_E3E3E3_grey'),
        startMargin: $r('app.float.wh_value_65'),
        endMargin: $r('app.float.wh_value_15')
      })
      .width(ConfigData.WH_100_100)
      .height(ConfigData.WH_100_100)
      .alignSelf(ItemAlign.Start);
    }
    .width(ConfigData.WH_100_100)
    .height(ConfigData.WH_100_100);
  }

  async aboutToAppear() {
    LogUtil.info('settings SettingList aboutToAppear enter');
    this.initRdb();
    await SettingListModel.setSettingListener();
    SubscriberUtils.registerStatusListener();
    LogUtil.info('settings SettingList aboutToAppear startPage');
    SettingListModel.startPage(this.pageValue);
    let nYear = GlobalResourceManager.getStringByResource($r('app.string.year'));
    nYear.then(resp => BrightnessSettingModel.setStorageValue(ConfigData.DATE_AND_TIME_YEAR, resp));
    let nMonth = GlobalResourceManager.getStringByResource($r('app.string.month'));
    nMonth.then(resp => BrightnessSettingModel.setStorageValue(ConfigData.DATE_AND_TIME_MONTH, resp));
    let nDay = GlobalResourceManager.getStringByResource($r('app.string.day'));
    nDay.then(resp => {
      BrightnessSettingModel.setStorageValue(ConfigData.DATE_AND_TIME_DAY, resp);
      LogUtil.info('SettingList day:' + BrightnessSettingModel.getStorageValue(ConfigData.DATE_AND_TIME_DAY, ''));
    })
    LogUtil.info('settings SettingList aboutToAppear end');
  }

  pageValue(pagePath): void{
    LogUtil.info('settings settingList pageValue pagePath:' + pagePath);
    if (PAGE_WIFI === pagePath) {
      Router.push({
        uri: PAGE_WIFI,
      });
    }
    LogUtil.info('settings settingList pageValue end');
  }

  onPageShow(): void{
    setTimeout(() => {
      LogUtil.info(ConfigData.TAG + 'get data insert start');
      this.insertData();
      LogUtil.info(ConfigData.TAG + 'get data insert end');
    }, 2000);
    setTimeout(() => {
      LogUtil.info(ConfigData.TAG + 'get data delete start');
      let key = ["systemName"];
      DataRdbService.deleteData(key);
      LogUtil.info(ConfigData.TAG + 'get data delete end');
    }, 5000);
    setTimeout(() => {
      LogUtil.info(ConfigData.TAG + 'get data update start');
      let rowValue = { "key": "companyInfo", "value": "OpenHarmony111" };
      let key = ["companyInfo"];
      DataRdbService.updateData(key, rowValue);
      LogUtil.info(ConfigData.TAG + 'get data update end');
    }, 5000);
    setTimeout(() => {
      let key = "model";
      DataRdbService.querySingleData(key, value => {
        console.info(ConfigData.TAG + 'get data query  querySingleData:' + JSON.stringify(value));
      });
    }, 6000);
    setTimeout(() => {
      DataRdbService.queryAllData(values => {
        console.info(ConfigData.TAG + 'get data query values' + JSON.stringify(values));
      });
    }, 7000);

    LogUtil.info('settings SettingList onPageShow in:' + JSON.stringify(this.settingsList));
    this.wifiStatus = WifiModel.getWifiStatus();
    LogUtil.info('settings SettingList onPageShow this.wifiStatus:' + this.wifiStatus);
    for (let key in this.settingsList) {
      let settingAlias = this.settingsList[key].settingAlias;
      if ('wifiTab' === settingAlias) {
        if (this.wifiStatus) {
          this.status = $r('app.string.enabled');
        } else {
          this.status = $r('app.string.disabled');
        }
        LogUtil.info('settings SettingList onPageShow settingValue:' + this.settingsList[key].settingValue);
      }
    }
    this.settingsList.unshift({
      settingSummary: '',
      settingTitle: this.settingsList[SETTING_LIST_INDEX].settingTitle,
      settingValue: this.status,
      settingAlias: this.settingsList[SETTING_LIST_INDEX].settingAlias,
      settingIcon: this.settingsList[SETTING_LIST_INDEX].settingIcon,
      settingArrow: this.settingsList[SETTING_LIST_INDEX].settingArrow,
      settingUri: this.settingsList[SETTING_LIST_INDEX].settingUri,
    });
    this.settingsList.splice(1, 1);
    LogUtil.info('settings SettingList onPageShow out:' + +JSON.stringify(this.settingsList));
  }

  aboutToDisappear(): void{
    LogUtil.info('settings settingList aboutToDisappear in');
    SubscriberUtils.unSubscriberListener();
    LogUtil.info('settings settingList aboutToDisappear out');
  }

  initRdb() {
    RdbStoreUtil.createRdbStore((ret) => {
      if (ret) {
        console.log(ConfigData.TAG + 'get data first done start');
        RdbStoreUtil.createTable(Stable.table.Global);
        console.log(ConfigData.TAG + 'get data createRdbStore first done end');
      } else {
        return;
      }
    });
  }

  insertData() {
    LogUtil.info(ConfigData.TAG + 'get data insertData start');
    let insertValues = DataRdbModel.insertValues;
    insertValues.forEach((insertValue) => {
      LogUtil.info(ConfigData.TAG + 'get data for each:' + insertValue);
      let rowValue = {
        "key": insertValue.settingTitle,
        "value": insertValue.settingValue
      }
      DataRdbService.querySingleData(insertValue.settingTitle, value => {
        console.info(ConfigData.TAG + 'get data insertData querySingleData:' + JSON.stringify(value));
        if ([].toString() === value.toString()) {
          console.info(ConfigData.TAG + 'get data insertData insert:' + JSON.stringify(rowValue));
          DataRdbService.insertDataService(rowValue);
        } else {
          console.info(ConfigData.TAG + 'get data insertData update');
          let key = [insertValue.settingTitle];
          let rowValue = {
            "key": insertValue.settingTitle,
            "value": '12345457878'
          }
          DataRdbService.updateData(key, rowValue);
        }
      });
      LogUtil.info(ConfigData.TAG + 'get data insertData end');
    })
    setTimeout(() => {
      DataRdbService.queryAllData(tableAllData => {
        console.info(ConfigData.TAG + 'get data insertData values：' + JSON.stringify(tableAllData));
      });
    }, 2000);
  }
}