/**
 * Copyright (c) 2023-2023 Huawei Device Co., Ltd.
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

import router from '@ohos.router';
import ExtensionServiceManagementModel from '../model/accessibilityImpl/ExtensionServiceManagementModel';
import LogUtil from '../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import ConfigData from '../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData';
import HeadComponent from '../../../../../../common/component/src/main/ets/default/headComponent';
import ResourceUtil from '../../../../../../common/search/src/main/ets/default/common/ResourceUtil';
import { ServiceItemComponent } from '../../../../../../common/component/src/main/ets/default/serviceItemComponent';
import ImageAnimatorComponent from '../../../../../../common/component/src/main/ets/default/imageAnimatorComponent';

const MODULE_TAG = ConfigData.TAG + 'serviceManagement-> ';

class serviceListItem {
  serviceUri?: string;
  serviceIcon?: string | Resource;
  serviceTitle?: string | Resource;
  serviceEndText?: string
}

/**
 * application list
 */
@Entry
@Component
struct extensionServiceManagement {
  @StorageLink('extensionServiceManagementList') serviceList: serviceListItem[] = [];
  private whtl: string = '80vp';

  build() {
    Column() {
      GridContainer({ gutter: ConfigData.GRID_CONTAINER_GUTTER_24, margin: ConfigData.GRID_CONTAINER_MARGIN_24 }) {
        Column() {
          HeadComponent({ headName: $r('app.string.installed_service'), isActive: true });

          if (this.serviceList.length <= 0) {
            ImageAnimatorComponent({
              imageWidth: $r('app.float.wh_value_80'),
              imageHeight: $r('app.float.wh_value_80'), whtl: this.whtl
            })
              .margin({ top: $r("app.float.distance_8") })
              .zIndex(1)
              .align(Alignment.Center)
              .padding({ top: ConfigData.WH_35_100 })
              .width(ConfigData.WH_100_100)
              .height(ConfigData.WH_100_100);
          }

          Column() {
            List() {
              ForEach(this.serviceList, (item: serviceListItem) => {
                ListItem() {
                  ServiceItemComponent({
                    targetPage: item.serviceUri,
                    serviceIcon: item.serviceIcon,
                    serviceTitle: item.serviceTitle,
                    serviceEndText: item.serviceEndText,
                  });
                }
                .onClick(() => {
                  router.pushUrl({ url: item.serviceUri as string, params: item });
                })
                .height($r('app.float.wh_value_72'));
              }, (item: serviceListItem) => JSON.stringify(item));
            }
            .borderRadius($r("app.float.radius_24"))
            .divider({
              strokeWidth: 1,
              color: $r('app.color.color_E3E3E3_grey'),
              startMargin: $r('app.float.wh_value_65'),
              endMargin: $r('sys.float.ohos_id_card_margin_end'),
            })
            .visibility(this.serviceList.length > 0 ? Visibility.Visible : Visibility.None)
            .zIndex(0);
          }
          .layoutWeight(ConfigData.LAYOUT_WEIGHT_1)
          .borderRadius($r("app.float.radius_24"))
          .backgroundColor($r("app.color.white_bg_color"))
          .padding($r('app.float.distance_4'));
        }
        .useSizeType({
          sm: { span: 4, offset: 0 },
          md: { span: 6, offset: 1 },
          lg: { span: 8, offset: 2 },
        });
      }
      .width(ConfigData.WH_100_100)
      .height(ConfigData.WH_100_100);
    }
    .backgroundColor($r("sys.color.ohos_id_color_sub_background"))
    .width(ConfigData.WH_100_100)
    .height(ConfigData.WH_100_100);
  }

  aboutToAppear(): void {
    LogUtil.info(`${MODULE_TAG} aboutToAppear in`);
    AppStorage.SetOrCreate('extensionServiceManagementList', []);
    ExtensionServiceManagementModel.setExtensionServiceManagementListener();
    ExtensionServiceManagementModel.openExtensionServiceManagementStatusListener();
    ResourceUtil.getString($r('app.float.wh_value_80')).then(value => this.whtl = value);
    LogUtil.info(`${MODULE_TAG} aboutToAppear  appList: ${JSON.stringify(this.serviceList)}`);
    LogUtil.info(`${MODULE_TAG} aboutToAppear out`);
  }

  onPageShow(): void {
    LogUtil.info(`${MODULE_TAG} onPageShow in`);
    AppStorage.SetOrCreate('extensionServiceManagementList', []);
    ExtensionServiceManagementModel.setExtensionServiceManagementListener();
    ExtensionServiceManagementModel.openExtensionServiceManagementApplicationListener();
    ResourceUtil.getString($r('app.float.wh_value_80')).then(value => this.whtl = value);
    LogUtil.info(`${MODULE_TAG} onPageShow  ServiceList: ${JSON.stringify(this.serviceList)}`);
    LogUtil.info(`${MODULE_TAG} onPageShow out`);
  }

  aboutToDisappear(): void {
    LogUtil.info(`${MODULE_TAG} aboutToDisappear in`);
    ExtensionServiceManagementModel.closeExtensionServiceManagementStatusListener();
    AppStorage.Delete(MODULE_TAG + 'extensionServiceManagementList');
    LogUtil.info(`${MODULE_TAG} aboutToDisappear out`);
  }

  onPageHide(): void {
    LogUtil.info(`${MODULE_TAG} onPageHide in`);
    ExtensionServiceManagementModel.closeExtensionServiceManagementApplicationListener();
  }
}