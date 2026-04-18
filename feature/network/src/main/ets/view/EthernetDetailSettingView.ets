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

/* instrument ignore file */
import ethernet from '@ohos.net.ethernet';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { FontScaleUtils } from '@ohos/settings.common/src/main/ets/utils/FontScaleUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { PADDING_12, PADDING_16 } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { StringUtil } from '@ohos/settings.common/src/main/ets/utils/StringUtil';
import { Constants } from '../constant/Constants';
import { EthernetUtil } from '../util/EthernetUtil';
import { IEthernetInfo } from '../model/IEthernetInfo';
import { IEthernetInterfaceInfo } from '../model/IEthernetInterfaceInfo';
import { NetworkEventType } from '../model/IEthernetConnectionManager';
import { WiredNetworkSettingPresenter } from '../controller/WiredNetworkSettingPresenter';

const TAG = 'EthernetDetailSettingView : ';

@Component
struct EthernetDetailSettingView {
  @StorageLink('ethernetList') @Watch('ethChange')
  ethernetList: IEthernetInfo[] = [];
  @State
  ifcName: string = '';
  @State
  isShowDetailView: boolean = false;
  @State
  ifcInfo: IEthernetInterfaceInfo | null = null;
  @State
  dhcpInfo: IEthernetInterfaceInfo | null = null;
  @StorageLink('isDHCP') @Watch('updateIfcInfo')
  isDHCP: boolean = false;

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear ifcName: ${this.ifcName}`);
    this.init();
    this.onPageShow();
  }

  onPageShow(): void {
    LogUtil.info(`${TAG} onPageShow!`);
    this.ethernetPropertiesChangeCallback('onPageShow');
  }

  aboutToDisappear(): void {
    WiredNetworkSettingPresenter.getInstance().unregisterEventCallback(NetworkEventType.PROPERTIES,
      (): void => this.ethernetPropertiesChangeCallback('aboutToAppear'), 'EthernetDetailSettingView');
  }

  updateIfcInfo(): void {
    this.ethernetPropertiesChangeCallback('updateIfcInfo');
  }

  ethChange(): void {
    LogUtil.info(`${TAG} ethChange`);
    this.ethernetList.forEach((item: IEthernetInfo) => {
      let ethName: string = item?.connectionProperties?.interfaceName as string;
      LogUtil.info(`${TAG} ethChange ethName: ${ethName}`);
      if (ethName?.includes('eth')) {
        this.ifcName = ethName;
        AppStorage.setOrCreate<string>('ifcName', this.ifcName);
      }
    });
    this.isShowDetailView = StringUtil.isNotEmpty(this.ifcName) && this.ethernetList.length > 0;
  }

  private init(): void {
    this.ifcInfo = {
      mode: ethernet.IPSetMode.DHCP,
      ipAddr: '',
      route: '',
      gateway: '',
      netMask: '',
      dnsServers: '',
    };
    this.dhcpInfo = {
      mode: ethernet.IPSetMode.DHCP,
      ipAddr: '',
      route: '',
      gateway: '',
      netMask: '',
      dnsServers: '',
    };

    if (WiredNetworkSettingPresenter.getInstance()) {
      LogUtil.info(`${TAG} Ready for eth detail fetch`);
      WiredNetworkSettingPresenter.getInstance().registerEventCallback(NetworkEventType.PROPERTIES,
        (): void => this.ethernetPropertiesChangeCallback('aboutToAppear'), 'EthernetDetailSettingView');
    }
    this.ethernetList = AppStorage.get('ethernetList') as IEthernetInfo[];
    this.ethernetList.forEach((item: IEthernetInfo) => {
      let ethName: string = item?.connectionProperties?.interfaceName as string;
      LogUtil.info(`${TAG} ethName: ${ethName}`);
      if (ethName.includes('eth')) {
        this.ifcName = ethName;
      }
    });
  }

  private ethernetPropertiesChangeCallback(key: string): void {
    LogUtil.info(`${TAG} To fetch eth ifc detail ifcName: ${this.ifcName}`);
    EthernetUtil.getEthernetInterfaceConfig(this.ifcName, (data) => {
      LogUtil.info(`${TAG} eth ifc detail fetched`);

      this.ifcInfo = data as IEthernetInterfaceInfo;
      if (this.ifcInfo.dnsServers) {
        const dnsArray = this.ifcInfo.dnsServers.split(',');
        this.ifcInfo.dns0 = dnsArray?.[0];
        this.ifcInfo.dns1 = dnsArray?.[1];
      }
      AppStorage.setOrCreate<IEthernetInterfaceInfo>('ifcInfo', this.ifcInfo);
      EventBus.getInstance().emit(Constants.ETHERNET_CHANGE_EVENT);
      LogUtil.info(`${TAG} eth fetched end ${key}`);
    });
  }

  build() {
    Column() {
      Text($r('app.string.network_title'))
        .fontFamily('HarmonyHeiTi')
        .fontWeight(FontWeight.Medium)
        .fontSize($r('sys.float.Subtitle_S'))
        .fontColor($r('sys.color.ohos_id_color_text_secondary'))
        .width('100%')
        .margin({ bottom: $r('sys.float.padding_level4') })
        .padding({ start: PADDING_12 })
        .visibility(EthernetUtil.useNewNetworkPage() ? Visibility.None : Visibility.Visible)

      // 以太网详细信息
      List() {
        ListItemGroup() {
          // 配置ipv4
          ListItem() {
            this.buildIPv4();
          }

          // ip 地址
          ListItem() {
            this.buildIfcListItem($r('app.string.ip_address'), 'ipAddr');
          }

          // 子网掩码
          ListItem() {
            this.buildIfcListItem($r('app.string.subnet_mask'), 'netMask');
          }

          // 路由器
          ListItem() {
            this.buildIfcListItem($r('app.string.router'), 'gateway');
          }

          // DNS服务器
          ListItem() {
            this.buildIfcListItem($r('app.string.dns_server'), 'dns0');
          }

          // 备份DNS服务器
          ListItem() {
            this.buildIfcListItem($r('app.string.alternate_dns_server'), 'dns1');
          }
        }
        .divider({
          strokeWidth: px2vp(1),
          color: $r('sys.color.comp_divider')
        })
      }
      .constraintSize({ minHeight: $r('app.float.ethernet_dialog_card_height') })
      .padding({
        top: $r('sys.float.padding_level2'),
        bottom: $r('sys.float.padding_level2'),
        left: $r('sys.float.padding_level6'),
        right: $r('sys.float.padding_level6'),
      })
      .backgroundColor($r('sys.color.comp_background_list_card'))
      .borderRadius(DeviceUtil.isDevicePc() ? $r('sys.float.corner_radius_level8') :
      $r('sys.float.corner_radius_level10'))
    }
    .width('100%')
    .visibility(this.isShowDetailView ? Visibility.Visible : Visibility.None)
    .margin({ top: $r('sys.float.padding_level6') })
    .backgroundColor($r('sys.color.background_secondary'))
    .focusable(false)
  }

  @Builder
  buildIfcListItem(name: ResourceStr, key: string) {
    Flex({
      justifyContent: FlexAlign.SpaceBetween,
      alignItems: ItemAlign.Center,
      wrap: FontScaleUtils.isExtraLargeFontMode() ? FlexWrap.Wrap : FlexWrap.NoWrap
    }) {
      Text(name)
        .fontWeight(FontWeight.Medium)
        .fontSize($r('sys.float.Body_L'))
        .fontColor($r('sys.color.font_primary'))
        .maxLines(FontScaleUtils.isExtraLargeFontMode() ? undefined : 1)
        .flexShrink(0)
        .margin({ end: PADDING_16 })
      Text((this.ifcInfo as IEthernetInterfaceInfo)[key])
        .fontWeight(FontWeight.Regular)
        .fontSize($r('sys.float.Body_M'))
        .fontColor($r('sys.color.font_secondary'))
        .copyOption(1)
        .key(key + '_value')
        .textAlign(FontScaleUtils.isExtraLargeFontMode() ? TextAlign.Start : TextAlign.End)
    }
    .constraintSize({
      minHeight: DeviceUtil.isDevicePc() ? $r('app.float.height_40') : $r('app.float.height_48')
    })
    .padding({
      top: FontScaleUtils.getCurrentTopPadding(),
      bottom: FontScaleUtils.getCurrentTopPadding()
    })
  }

  @Builder
  buildIPv4() {
    Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
      Text($r('app.string.configure_ipv4'))
        .fontWeight(FontWeight.Medium)
        .fontSize($r('sys.float.Body_L'))
        .fontColor($r('sys.color.font_primary'))
      Text((this.ifcInfo as IEthernetInterfaceInfo).mode === ethernet.IPSetMode.DHCP ?
      $r('app.string.use_dhcp') : $r('app.string.manual'))
        .fontWeight(FontWeight.Regular)
        .fontSize($r('sys.float.Body_M'))
        .fontColor($r('sys.color.font_secondary'))
        .copyOption(CopyOptions.InApp)
        .key('configure_ip_mode')
    }
    .constraintSize({
      minHeight: DeviceUtil.isDevicePc() ? $r('app.float.height_40') : $r('app.float.height_48')
    })
    .padding({
      top: FontScaleUtils.getCurrentTopPadding(),
      bottom: FontScaleUtils.getCurrentTopPadding()
    })
  }
}

export { EthernetDetailSettingView };