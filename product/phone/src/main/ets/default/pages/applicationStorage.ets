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
import ConfigData from '../../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData.ets';
import EntryComponent from '../../../../../../../common/component/src/main/ets/default/entryComponent.ets';
import HeadComponent from '../../../../../../../common/component/src/main/ets/default/headComponent.ets';
import LogUtil from '../../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil.ets';
import Router from '@system.router';
import ApplicationStorageController from '../controller/application/ApplicationStorageController.ets'
import Log from '../../../../../../../common/utils/src/main/ets/default/baseUtil/LogDecorator.ets';

let appInfo;
/**
 * Application storage
 */
@Entry
@Component
struct ApplicationStorage {
  @StorageLink('applicationStorageList') storageList: any[]= [];
  private controller: ApplicationStorageController = new ApplicationStorageController();
  
  build() {
    Column() {
      HeadComponent({ headName: $r('app.string.applyTab'), isActive: true });
      // head
      Row() {
        EntryComponent({
          settingIcon: appInfo.settingIcon,
          settingTitle: appInfo.settingTitle,
          settingSummary: appInfo.settingSummary,
          settingValue: '',
          settingArrow: '',
          settingArrowStyle: '',
          settingUri: appInfo.settingUri
        });
      }
      // body
      Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center }) {
        List() {
          ForEach(this.storageList, (item) => {
            if (item.settingButtonFlag) {
              ListItem() {
                EntryComponent({
                  settingIcon: '',
                  settingTitle: item.settingTitle,
                  settingSummary: item.settingSummary,
                  settingValue: item.settingValue,
                  settingArrow: item.settingArrow,
                  settingArrowStyle: '',
                  settingUri: ''
                });
              }
            } else {
              ListItem() {
                Button() {
                  Text(item.settingTitle)
                    .fontSize($r('app.float.application_button_subtitle_size'))
                    .fontColor(Color.Blue)
                }
                .backgroundColor($r('app.color.color_E3E3E3_grey'))
                .height($r('app.float.application_button_height'))
                .align(Alignment.BottomStart)
                .width($r("app.float.wh_value_160"))
                .margin({ top: 10, bottom: 10 })
                .onClick(() => {
                  this.onClickController(item.settingAlias);
                });
              }.width(ConfigData.WH_100_100)
            }
          });
        }
        .divider({
          strokeWidth: 1,
          color: $r('app.color.color_E3E3E3_grey'),
          startMargin: $r('app.float.storage_common_margin'),
          endMargin: $r('app.float.storage_common_margin')
        })
        .width(ConfigData.WH_100_100)
        .alignSelf(ItemAlign.Start);
      }
      .width(ConfigData.WH_100_100)
      .margin({ top: $r('app.float.item_common_vertical_margin'), bottom: $r('app.float.item_common_vertical_margin') })
    }
  }

  @Log
  aboutToAppear() {
    this.controller.getStorageList();
    appInfo = Router.getParams();
    LogUtil.info('settings ApplicationInfo aboutToAppear this.item:' + JSON.stringify(appInfo));
  }

  @Log
  onBackPress() {
    Router.back();
  }

  @Log
  onClickController(settingAlias){
    LogUtil.info(ConfigData.TAG + 'onClickController settingBundleName:' + JSON.stringify(appInfo.settingBundleName));
    if ('deleteDataTab' === settingAlias) {
      this.showDialog(this.controller.clearUpApplicationData.bind(this, appInfo.settingBundleName))
    } else if ('clearCacheTab' === settingAlias) {
      this.controller.cleanBundleCacheFiles(appInfo.settingBundleName);
    }
  }

  /**
   * Disconnect Dialog
   */
  @Log
  showDialog(callback) {
    AlertDialog.show({
      title: $r('app.string.delete_data_prompt_title'),
      message: $r("app.string.delete_data_prompt"),
      primaryButton: {
        value: $r('app.string.cancel'),
        action: () => {
          LogUtil.info(ConfigData.TAG + 'Closed callbacks');
        }
      },
      secondaryButton: {
        value: $r('app.string.confirm'),
        action: () => {
          LogUtil.info(ConfigData.TAG + `AlertDialog success:`);
          callback();
          LogUtil.info(ConfigData.TAG + `callback success:`);
        }
      },
      alignment: DialogAlignment.Bottom
    })
  }
}