/**
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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

import { BusinessError } from '@ohos.base';
import common from '@ohos.app.ability.common';
import router from '@ohos.router';
import vpn from '@ohos.net.vpn';
import VpnLine from './vpnLine';
import VpnConfig, { VpnListItem } from '../../model/vpnImpl/VpnConfig';
import { VpnConnectModel } from '../../model/vpnImpl/VpnConnectModel';
import { SwanCtlModel } from '../../model/vpnImpl/SwanCtlModel';
import { VpnConfigModel } from '../../model/vpnImpl/VpnConfigModel';
import { ResourceUtils } from '../../model/accessibilityImpl/resourceUtils';
import ConfigData from '../../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData';
import { BaseData } from '../../../../../../../common/utils/src/main/ets/default/bean/BaseData';
import HeadComponent from '../../../../../../../common/component/src/main/ets/default/headComponent';
import LogUtil from '../../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';

const MODULE_TAG: string = 'setting_vpn:VPNList:';

/**
 * VPN list
 */
@Entry
@Component
struct VPNList {
  @State vpnList: VpnListItem[] = [];
  @State isLoading: boolean = false;

  build() {
    Column() {
      GridContainer({ gutter: ConfigData.GRID_CONTAINER_GUTTER_24, margin: ConfigData.GRID_CONTAINER_MARGIN_24 }) {
        Column() {
          HeadComponent({ headName: $r('app.string.VPN'), isActive: true })
          if (this.isLoading) {
            Column() {
              LoadingProgress()
                .color(Color.White)
                .width(80)
            }.width('100%').height('100%').justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
          } else {
            if (this.vpnList!.length > 0 ) {
              Column() {
                List() {
                  ForEach(this.vpnList, (item: VpnListItem, index: number) => {
                    ListItem() {
                      VpnLine({
                        vpnListItem: item,
                        fontSize: $r('sys.float.ohos_id_text_size_body1'),
                        valueFontSize: $r('sys.float.ohos_id_text_size_body2'),
                      })
                    }.padding(3)
                  }, (item: BaseData) => JSON.stringify(item));
                }
                .margin({ top: $r('app.float.distance_8') })
                .align(Alignment.Top)
                .borderRadius($r('app.float.radius_16'))
                .backgroundColor($r('sys.color.ohos_id_color_foreground_contrary'))
                .divider({
                  strokeWidth: $r('app.float.divider_wh'),
                  color: $r('sys.color.ohos_id_color_list_separator'),
                  startMargin: $r('app.float.wh_value_48'),
                  endMargin: $r('app.float.wh_value_8')
                })
              }
              .width(ConfigData.WH_100_100)
              .height(ConfigData.WH_100_100)
              .layoutWeight(1)

              Column({ space: 5 }) {
                Image($r('app.media.ic_public_add'))
                  .width(20)
                  .height(20)
                Text($r('app.string.vpn_list_add'))
                  .fontColor('#333333')
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
              }
              .margin({ bottom: 25, top: 25 })
              .onClick(() => {
                this.onAddBtnClick();
              })
            } else {
              Column() {
                Image($r('app.media.empty'))
                  .width(200)
                  .height(200)
                Text($r('app.string.vpn_list_empty'))
                  .fontSize(15)
                  .fontColor('#999999')
              }
              .justifyContent(FlexAlign.Center)
              .width(ConfigData.WH_100_100)
              .height(ConfigData.WH_100_100)
              .layoutWeight(1)

              Column({ space: 5 }) {
                Button($r('app.string.vpn_list_add'))
                  .fontColor('#0A59F7')
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .height(45)
                  .padding({ top: 10, left: 60, right: 60, bottom: 10 })
                  .borderRadius($r('app.float.radius_24'))
                  .backgroundColor('#E6E8E9')
                  .onClick(() => {
                    this.onAddBtnClick();
                  })
              }.margin({ bottom: 25, top: 25 })
            }
          }
        }
        .useSizeType({
          sm: { span: 4, offset: 0 },
          md: { span: 6, offset: 1 },
          lg: { span: 8, offset: 2 }
        })
      }
      .width(ConfigData.WH_100_100)
      .height(ConfigData.WH_100_100)
    }
    .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
    .width(ConfigData.WH_100_100)
    .height(ConfigData.WH_100_100)
  }

  onAddBtnClick() {
    router.pushUrl({
      url: 'pages/vpn/vpnEdit',
    });
  }

  async updateVpnList() {
    this.isLoading = true;
    try {
      let data: vpn.SysVpnConfig[] = await vpn.getSysVpnConfigList();
      if (data) {
        let list = data as VpnListItem[];
        let currentVpnId = VpnConnectModel.getInstance().getConnectedVpnId();
        list.sort((item1, item2) => {
          if (currentVpnId! && item1.vpnId === currentVpnId) {
            return -1;
          } else if (currentVpnId! && item2.vpnId === currentVpnId) {
            return 1;
          } else {
            return item1.vpnName.localeCompare(item2.vpnName, 'zh');
          }
        });
        this.vpnList = list;
      } else {
        this.vpnList = [];
      }
    } catch (err) {
      let message = (err as BusinessError).message;
      VpnConfigModel.getInstance().showToast(ResourceUtils.getStringSync($r('app.string.vpn_error_operation_failed')) + ': ' + message);
    }
    this.isLoading = false;
  }

  aboutToAppear(): void {
    LogUtil.info(MODULE_TAG + 'aboutToAppear');
    VpnConfigModel.getInstance().setNeedUpdateVpnList(true);
    VpnConnectModel.getInstance().init(getContext() as common.UIAbilityContext);
    SwanCtlModel.getInstance().init(getContext() as common.UIAbilityContext);
  }

  onPageShow(): void {
    if (VpnConfigModel.getInstance().isUpdateVpnList()) {
      this.updateVpnList();
      VpnConfigModel.getInstance().setNeedUpdateVpnList(false);
    }
  }

  aboutToDisappear(): void {
    LogUtil.info(MODULE_TAG + 'aboutToDisappear');
    VpnConnectModel.getInstance().release();
  }
}