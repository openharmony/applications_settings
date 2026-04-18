/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
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

import common from '@ohos.app.ability.common';
import { vpn } from '@kit.NetworkKit';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { CustomPageComponent } from '@ohos/settings.uikit/src/main/ets/component/CustomPageComponent';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { SystemParamUtils } from '@ohos/settings.common/src/main/ets/screenReader/utils/SystemParamUtils';
import { SwanCtlModel } from './model/SwanCtlModel';
import { VpnListItem } from './model/VpnConfig';
import { VpnConfigModel } from './model/VpnConfigModel';
import { VpnConnectModel } from './model/VpnConnectModel';
import ConfigData from './ConfigData';
import VpnLine from './VpnLine';
import { VpnEditView } from './VpnEditView';
import VpnConstant from './model/VpnConstant';
import { PasswordUtil } from '@ohos/settings.common/src/main/ets/utils/PasswordUtil';

/* instrument ignore file */
const MODULE_TAG: string = 'VpnListComponent:';

@Component
export struct VpnListComponent {
  @StorageLink(VpnConstant.STORAGE_KEY_CONNECT_STATE) @Watch('onConnectStateChange') connectState: number =
    VpnConstant.VPN_STATE_NONE;
  @State vpnList: VpnListItem[] = [];
  @State isLoading: boolean = false;
  @State isBindSheetShow: boolean = false;
  @State isAddVpnEnable: boolean = true;
  @Consume('pathInfos') pathInfos: NavPathStack;
  isPc: boolean = DeviceUtil.isDevicePc();
  isDisableVpn: boolean = SystemParamUtils.getSystemParam('persist.edm.vpn_disable', 'false') === 'true';
  async aboutToAppear(): Promise<void> {
    LogUtil.info(`${MODULE_TAG} aboutToAppear`);
    VpnConfigModel.getInstance().setNeedUpdateVpnList(true);
    VpnConnectModel.getInstance().init(getContext() as common.UIAbilityContext);
    SwanCtlModel.getInstance().init(getContext() as common.UIAbilityContext);
  }

  aboutToDisappear(): void {
    LogUtil.info(`${MODULE_TAG} aboutToDisappear`);
    VpnConnectModel.getInstance().release();
    SwanCtlModel.getInstance().release();
  }

  onShow(): void {
    LogUtil.info(`${MODULE_TAG} onShow`);
    if (VpnConfigModel.getInstance().isUpdateVpnList()) {
      this.updateVpnList();
      VpnConfigModel.getInstance().setNeedUpdateVpnList(false);
    }
  }

  async updateVpnList(): Promise<void> {
    LogUtil.debug(`${MODULE_TAG} updateVpnList`);
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
        this.isAddVpnEnable = list.length < VpnConstant.VPN_NUM_MAX;
      } else {
        this.vpnList = [];
      }
    } catch (err) {
      LogUtil.error(`${MODULE_TAG} getSysVpnConfigList failed, err：${err?.message}`);
    }
    this.isLoading = false;
  }

  onConnectStateChange(): void {
    if (this.connectState === VpnConstant.VPN_STATE_CONNECTED) {
      this.updateVpnList();
    }
  }

  build() {
    CustomPageComponent({
      content: () => {
        this.pageContentBuilder()
      },
      title: ResourceUtil.getStringSync($r('app.string.VPN')),
      onPageShow: () => {
        this.onShow();
      }
    })
  }

  @Builder
  pageContentBuilder() {
    Column() {
      Column() {
        Scroll() {
          Column() {
            if (this.isLoading) {
              Column() {
                LoadingProgress()
                  .color($r('sys.color.icon_on_primary'))
                  .width(80)
              }.width('100%').height('100%').justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
            } else {
              if (this.vpnList!.length > 0) {
                Column() {
                  List() {
                    ForEach(this.vpnList, (item: VpnListItem) => {
                      ListItem() {
                        VpnLine({
                          vpnListItem: item
                        })
                      }
                    }, (item: VpnListItem) => JSON.stringify(item));
                  }
                  .margin({ top: $r('app.float.margin_8') })
                  .padding(4)
                  .align(Alignment.Top)
                  .borderRadius(this.isPc ? $r('sys.float.corner_radius_level8') :
                   $r('sys.float.corner_radius_level10'))
                  .backgroundColor($r('sys.color.comp_background_list_card'))
                  .divider({
                    strokeWidth: $r('app.float.divider_stroke_width'),
                    color: $r('sys.color.comp_divider'),
                    startMargin: $r('app.float.margin_48'),
                    endMargin: $r('app.float.margin_8'),
                  })
                }
                .width(ConfigData.WH_100_100)
                .height(ConfigData.WH_100_100)
                .layoutWeight(1)
              } else {
                Column() {
                  Image($r('app.media.empty'))
                    .backgroundColor($r('sys.color.ohos_id_color_background_transparent'))
                    .width(120)
                    .height(120)
                    .draggable(false)
                  Text($r('app.string.vpn_list_empty'))
                    .fontColor($r('sys.color.font_secondary'))
                    .fontSize($r('sys.float.Body_M'))
                    .fontWeight(FontWeight.Medium)
                    .fontFamily('HarmonyHeiTi')
                }
                .justifyContent(FlexAlign.Center)
                .width(ConfigData.WH_100_100)
                .height(ConfigData.WH_100_100)
                .layoutWeight(1)
              }
            }
          }
        }
        .width('100%')
        .edgeEffect(EdgeEffect.Spring)
        .scrollable(ScrollDirection.Vertical)
        .scrollBar(BarState.Auto)
        .layoutWeight(1)
        .align(Alignment.TopStart)

        Button($r('app.string.vpn_list_add'))
          .fontColor($r('sys.color.font_emphasize'))
          .fontSize('sys.float.Body_L')
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Medium)
          .backgroundColor($r('sys.color.gray_02'))
          .type(ButtonType.Normal)
          .borderRadius(this.isPc ? $r('sys.float.corner_radius_level4') :
          $r('sys.float.corner_radius_level10'))
          .width(this.isPc ? '448vp' : '100%')
          .margin({ top: 16, bottom: 16 })
          .enabled(this.isAddVpnEnable)
          .onClick(() => {
            this.isBindSheetShow = true;
          })
          .visibility(this.isDisableVpn ? Visibility.None : Visibility.Visible)
          .bindSheet(this.isBindSheetShow, this.AddBindSheet(), {
            height: SheetSize.LARGE,
            preferType: this.isPc ? SheetType.CENTER : SheetType.BOTTOM,
            showClose: true,
            dragBar: false,
            title: { title: $r('app.string.vpn_list_add') },
            onWillDisappear: () => {
              this.isBindSheetShow = false
              PasswordUtil.setPrivacyMode(false);
            },
            onWillAppear: () => {
              PasswordUtil.setPrivacyMode(true);
            }
          })
      }
    }
    .backgroundColor($r('sys.color.comp_background_gray'))
    .width(ConfigData.WH_100_100)
    .height(ConfigData.WH_100_100)
    .padding({ left: this.isPc ? 24 : 16, right: this.isPc ? 24 : 16 })
  }

  @Builder
  AddBindSheet() {
    Column() {
      VpnEditView({
        onSaveClickFinish: () => {
          this.updateVpnList();
          this.isBindSheetShow = false;
        }
      })
    }
    .padding({ top: 8, bottom: this.isPc ? 0 : 32 })
    .width(ConfigData.WH_100_100)
    .height(ConfigData.WH_100_100)
  }
}
