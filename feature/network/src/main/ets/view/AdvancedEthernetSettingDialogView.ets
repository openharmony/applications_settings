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
import { SymbolGlyphModifier } from '@ohos.arkui.modifier';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { FontScaleUtils } from '@ohos/settings.common/src/main/ets/utils/FontScaleUtils';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { HiSysNetworkGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { GlobalContext } from '@ohos/settings.common/src/main/ets/utils/GlobalContext';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import {
  notifyCompStateChange,
  SettingBaseState,
  SettingCompState,
  SettingStateType
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import {
  PADDING_0,
  PADDING_12,
  PADDING_16,
  PADDING_2,
  PADDING_4,
  PADDING_6,
  PADDING_8
} from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { BuildNetIfcListItem } from './BuildNetIfcListItem';
import { Constants } from '../constant/Constants';
import { DialogButton, DialogTitleBar } from './NetworkDialogComponent';
import { EthernetUtil } from '../util/EthernetUtil';
import { IEthernetInterfaceInfo } from '../model/IEthernetInterfaceInfo';
import { IFaceData } from '../model/EthernetInterfaceInfoModel';
import { UserTipConfirmDialogView } from './UserTipConfirmDialogView';

const TAG: string = 'AdvancedEthernetSettingDialogView:';
const DEFAULT_IFC_INFO: IEthernetInterfaceInfo = {
  mode: ethernet.IPSetMode.DHCP,
  ipAddr: '',
  route: '0.0.0.0',
  gateway: '',
  netMask: '',
  dnsServers: '',
  dns0: '',
  dns1: '',
};
const ETHERNET_ADVANCED_DIALOG_ID: string =
  EthernetUtil.useNewNetworkPage() ? 'Setting.Network.pc_ethernet_advanced_group.pc_ethernet_advanced_settings' :
    'Setting.PcNetwork.pc_ethernet_advanced_group.pc_ethernet_advanced_settings';
const ETHERNET_ADVANCED_GROUP_ID: string =
  EthernetUtil.useNewNetworkPage() ? 'Setting.Network.pc_ethernet_advanced_group' :
    'Setting.PcNetwork.pc_ethernet_advanced_group';

interface BeforeIPConfig {
  mode: ethernet.IPSetMode,
  ipAddr: string,
  route: string,
  dnsServers: string,
  gateway: string,
  netMask: string,
  errorInputKeys: Array<string>
}

class IpAddressingMode {
  public key: number;
  public value: Resource;
  public index: number;

  constructor(key: number, value: Resource, index: number) {
    this.key = key;
    this.value = value;
    this.index = index;
  }
}

@Component
struct AdvancedEthernetSettingDialogView {
  @State hoverBackgroundColor: Resource | Color = Color.Transparent;
  @State errorInputKeys: string[] = [];
  @State focused: boolean = false;
  @State
  dhcpInfo: IEthernetInterfaceInfo = DEFAULT_IFC_INFO;
  @State
  currentEthIfcInfo: IEthernetInterfaceInfo = {
    mode: ethernet.IPSetMode.DHCP,
    ipAddr: '',
    route: '0.0.0.0',
    gateway: '',
    netMask: '',
    dnsServers: '',
    dns0: '',
    dns1: '',
  };
  private ifcName: string = '';
  private ifcInfo: IEthernetInterfaceInfo = DEFAULT_IFC_INFO;
  private paramEthIfcInfo: IEthernetInterfaceInfo = DEFAULT_IFC_INFO;
  private endIconModifier: SymbolGlyphModifier =
    new SymbolGlyphModifier($r('sys.symbol.checkmark')).fontSize($r('app.float.width_24'));
  private globalContext: GlobalContext = GlobalContext.getInstance();
  private ipAddressingModeList: Array<IpAddressingMode> = [
    new IpAddressingMode(ethernet.IPSetMode.DHCP, $r('app.string.use_dhcp'), 0),
    new IpAddressingMode(ethernet.IPSetMode.STATIC, $r('app.string.manual'), 1)
  ];
  private isNeedShowTips: boolean = false;
  private onAdvancedSettingsShowCallback = (states: Map<SettingStateType, SettingBaseState>) => {
    if (!states || !states.get(SettingStateType.STATE_TYPE_GROUP_VISIBLE)) {
      LogUtil.error(`${TAG} states is invalid`);
      return;
    }
    let compState: SettingCompState = states.get(SettingStateType.STATE_TYPE_GROUP_VISIBLE) as SettingCompState;
    LogUtil.info(`${TAG} receive compState change: ${compState?.state}`);
    // 关闭半模态
    if (!compState?.state) {
      this.globalContext.set('beforeIPConfig', null);
      this.closeDialog();
    }
  };

  private onDialogDismissCallback = () => {
    LogUtil.info(`${TAG} onDialogDismissCallback`);
    this.globalContext?.set('beforeIPConfig', null);
  };

  aboutToAppear(): void {
    try {
      LogUtil.info(`${TAG} aboutToAppear`);
      this.ifcInfo = AppStorage.get<IEthernetInterfaceInfo>('ifcInfo') as IEthernetInterfaceInfo;
      this.ifcName =
        AppStorage.get<string>('ifcName') as string ?? AppStorage.get<IFaceData>('iFaceData')?.iface as string;
      this.paramEthIfcInfo = this.ifcInfo;
      if (this.paramEthIfcInfo && (this.paramEthIfcInfo.mode === ethernet.IPSetMode.STATIC)) {
        this.initManualEthIfcInfo();
      }

      if (this.globalContext.get('beforeIPConfig') as BeforeIPConfig) {
        const obj: IEthernetInterfaceInfo =
          JSON.parse((this.globalContext.get('beforeIPConfig') as BeforeIPConfig).toString());
        this.currentEthIfcInfo.mode = obj.mode;
        this.currentEthIfcInfo.ipAddr = obj.ipAddr;
        this.currentEthIfcInfo.route = obj.route;
        this.currentEthIfcInfo.gateway = obj.gateway;
        this.currentEthIfcInfo.netMask = obj.netMask;
        this.currentEthIfcInfo.dnsServers = obj.dnsServers;
        this.currentEthIfcInfo.dns0 = (obj.dnsServers as string).split(',')[0];
        this.currentEthIfcInfo.dns1 = (obj.dnsServers as string).split(',')[1];
        this.errorInputKeys = obj.errorInputKeys as string[];
        LogUtil.info(`${TAG} this.errorInputKeys: ${JSON.stringify(this.errorInputKeys)}`);
      }

      LogUtil.info(`${TAG} input param eth ifc info: ${this.ifcName}`);
      this.resetDhcpInfo();
      this.globalContext.set('beforeIPConfig', null);

      EventBus.getInstance().on(ETHERNET_ADVANCED_GROUP_ID, this.onAdvancedSettingsShowCallback);
      EventBus.getInstance().on(Constants.ADVANCED_ETHERNET_DIALOG_DISMISS_EVENT, this.onDialogDismissCallback);
    } catch (err) {
      LogUtil.info(`${TAG} eth setting appear error ${err?.code}`);
    }
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
    this.globalContext.set('beforeIPConfig', null);
    EventBus.getInstance().detach(ETHERNET_ADVANCED_GROUP_ID, this.onAdvancedSettingsShowCallback);
    EventBus.getInstance().detach(Constants.ADVANCED_ETHERNET_DIALOG_DISMISS_EVENT, this.onDialogDismissCallback);
  }

  private showWarningTipDialog(): void {
    let tipCtrl: CustomDialogController = new CustomDialogController({
      builder: UserTipConfirmDialogView({
        tipMessage: $r('app.string.set_iface_error_message'),
        confirm: () => {
          tipCtrl.close();
          this.isNeedShowTips = false;
        }
      }),
      alignment: DialogAlignment.Default,
      autoCancel: false,
      customStyle: false,
      cornerRadius: DeviceUtil.isDevicePc() ? $r('sys.float.corner_radius_level8') :
      $r('sys.float.corner_radius_level16')
    });
    LogUtil.info(`${TAG} showWarningTipDialog!`);

    tipCtrl.open();
  }

  private resetDhcpInfo(): void {
    if (this.dhcpInfo && this.ifcInfo) {
      if (this.ifcInfo.mode === ethernet.IPSetMode.DHCP) {
        this.dhcpInfo.ipAddr = this.ifcInfo.ipAddr;
        this.dhcpInfo.netMask = this.ifcInfo.netMask;
        this.dhcpInfo.dnsServers = this.ifcInfo.dnsServers;
        this.dhcpInfo.dns0 = this.ifcInfo.dns0;
        this.dhcpInfo.dns1 = this.ifcInfo.dns1;
        this.dhcpInfo.route = this.ifcInfo.route;
        this.dhcpInfo.gateway = this.ifcInfo.gateway;
      } else {
        this.dhcpInfo.ipAddr = '';
        this.dhcpInfo.netMask = '';
        this.dhcpInfo.dnsServers = '';
        this.dhcpInfo.dns0 = '';
        this.dhcpInfo.dns1 = '';
        this.dhcpInfo.route = '';
        this.dhcpInfo.gateway = '';
      }
    }
  }

  private backUpInputParameters(): void {
    const dnsArray: string[] = [];
    if (this.currentEthIfcInfo.dns0) {
      dnsArray.push(this.currentEthIfcInfo.dns0);
    }

    if (this.currentEthIfcInfo.dns1) {
      dnsArray.push(this.currentEthIfcInfo.dns1);
    }

    const beforeIPConfig: BeforeIPConfig = {
      mode: this.currentEthIfcInfo.mode,
      ipAddr: this.currentEthIfcInfo.ipAddr,
      route: this.currentEthIfcInfo.route,
      dnsServers: dnsArray.join(','),
      gateway: this.currentEthIfcInfo.gateway as string,
      netMask: this.currentEthIfcInfo.netMask,
      errorInputKeys: this.errorInputKeys
    }
    this.globalContext.set('beforeIPConfig', JSON.stringify(beforeIPConfig))
  }

  private initManualEthIfcInfo(): void {
    this.currentEthIfcInfo.mode = this.paramEthIfcInfo.mode;
    this.currentEthIfcInfo.ipAddr = this.paramEthIfcInfo.ipAddr;
    this.currentEthIfcInfo.route = this.paramEthIfcInfo.route;
    this.currentEthIfcInfo.gateway = this.paramEthIfcInfo.gateway;
    this.currentEthIfcInfo.netMask = this.paramEthIfcInfo.netMask;
    this.currentEthIfcInfo.dnsServers = this.paramEthIfcInfo.dnsServers;
    this.currentEthIfcInfo.dns0 = this.paramEthIfcInfo.dns0;
    this.currentEthIfcInfo.dns1 = this.paramEthIfcInfo.dns1;
  }

  private getSelectedModeIndex(): number {
    return this.ipAddressingModeList.find((item) => item.key === this.currentEthIfcInfo.mode)!.index;
  }

  private saveEthSetting(): void {
    let param: IEthernetInterfaceInfo | null = null;
    LogUtil.info(`${TAG} currentEthIfcInfo.mode ${this.currentEthIfcInfo.mode}`);

    if (this.currentEthIfcInfo.mode === ethernet.IPSetMode.DHCP) {
      param =
        {
          mode: ethernet.IPSetMode.DHCP,
          ipAddr: '',
          route: '',
          netMask: '',
          dnsServers: '',
          gateway: ''
        }
    } else {
      param = this.validateManualInput() as ethernet.InterfaceConfiguration;
      if (!param) {
        this.backUpInputParameters();
        this.isNeedShowTips = true;
        this.showWarningTipDialog();
        return;
      }
    }

    // 下发指令给底层以修改以太网的设置
    LogUtil.info(`${TAG} saveEthSetting -- To update ethernet ifc config`);
    EthernetUtil.updateEthernetIfcConfig(this.ifcName, param, (): void => this.onUpdateSuccess(),
      (errorCode: number): void => this.onUpdateFail(errorCode));
  }

  private onUpdateSuccess(): void {
    this.reportEthernetConfigUpdateEvent(this.currentEthIfcInfo.mode, 1);
    this.globalContext.set('beforeIPConfig', null);
    this.syncInputEthIfcInfo();
    this.closeDialog();
  }

  private onUpdateFail(errorCode: number): void {
    this.reportEthernetConfigUpdateEvent(this.currentEthIfcInfo.mode, 0, errorCode);
    this.showWarningTipDialog();
  }

  private reportEthernetConfigUpdateEvent(ifaceMode: number, result: number, errorCode?: number): void {
    let params: Record<string, Object> = {};
    params.PAGE = 'NetworkSettings';
    params.MODE = ifaceMode;
    params.RESULT = result;
    if (errorCode) {
      params.ERROR = errorCode;
    }
    HiSysEventUtil.reportBehaviorEventByUE(HiSysNetworkGroup.NETWORK_SET_IFACECONFIG, params);
  }

  private syncInputEthIfcInfo(): void {
    if (this.paramEthIfcInfo && (this.currentEthIfcInfo.mode === ethernet.IPSetMode.STATIC)) {
      this.paramEthIfcInfo.mode = this.currentEthIfcInfo.mode;
      this.paramEthIfcInfo.ipAddr = this.currentEthIfcInfo.ipAddr;
      this.paramEthIfcInfo.route = this.currentEthIfcInfo.route;
      this.paramEthIfcInfo.gateway = this.currentEthIfcInfo.gateway;
      this.paramEthIfcInfo.netMask = this.currentEthIfcInfo.netMask;
      this.paramEthIfcInfo.dnsServers = this.currentEthIfcInfo.dnsServers;
      this.paramEthIfcInfo.dns0 = this.currentEthIfcInfo.dns0;
      this.paramEthIfcInfo.dns1 = this.currentEthIfcInfo.dns1;
    }
    if (this.currentEthIfcInfo.mode === ethernet.IPSetMode.DHCP) {
      AppStorage.setOrCreate('isDHCP', true);
    } else if (this.currentEthIfcInfo.mode === ethernet.IPSetMode.STATIC) {
      AppStorage.setOrCreate('isDHCP', false);
    }
  }

  private validateManualInput(): IEthernetInterfaceInfo | null {
    this.errorInputKeys = [];
    if (!Constants.IP_REGEXP.test(this.currentEthIfcInfo.ipAddr)) {
      this.errorInputKeys.push('ipAddr')
    } else {
      let idx: number = this.errorInputKeys.indexOf('ipAddr');
      if (idx > -1) {
        this.errorInputKeys.splice(idx, 1);
      }
    }

    if (!Constants.NETMASK_REGEXP.test(this.currentEthIfcInfo.netMask)) {
      this.errorInputKeys.push('netMask')
    } else {
      let idx: number = this.errorInputKeys.indexOf('netMask');
      if (idx > -1) {
        this.errorInputKeys.splice(idx, 1);
      }
    }

    if (this.currentEthIfcInfo.gateway && !Constants.DNS_REGEXP.test(this.currentEthIfcInfo.gateway)) {
      this.errorInputKeys.push('gateway')
    } else {
      let idx: number = this.errorInputKeys.indexOf('gateway');
      if (idx > -1) {
        this.errorInputKeys.splice(idx, 1);
      }
    }

    if (this.currentEthIfcInfo.dns0 && !Constants.DNS_REGEXP.test(this.currentEthIfcInfo.dns0)) {
      this.errorInputKeys.push('dns0')
    } else {
      let idx: number = this.errorInputKeys.indexOf('dns0');
      if (idx > -1) {
        this.errorInputKeys.splice(idx, 1);
      }
    }

    if (this.currentEthIfcInfo.dns1 && !Constants.DNS_REGEXP.test(this.currentEthIfcInfo.dns1)) {
      this.errorInputKeys.push('dns1')
    } else {
      let idx: number = this.errorInputKeys.indexOf('dns1');
      if (idx > -1) {
        this.errorInputKeys.splice(idx, 1);
      }
    }

    if (this.errorInputKeys.length) {
      LogUtil.debug(`${TAG} error tip: ${this.errorInputKeys}`);
      return null;
    }

    return this.getInfoParam();
  }

  private getInfoParam(): IEthernetInterfaceInfo {
    const dnsArray: string[] = [];
    if (this.currentEthIfcInfo.dns0) {
      dnsArray.push(this.currentEthIfcInfo.dns0);
    }

    if (this.currentEthIfcInfo.dns1) {
      dnsArray.push(this.currentEthIfcInfo.dns1);
    }

    const param: IEthernetInterfaceInfo = {
      mode: this.currentEthIfcInfo.mode,
      ipAddr: this.currentEthIfcInfo.ipAddr,
      route: this.currentEthIfcInfo.route,
      dnsServers: dnsArray.join(','),
      gateway: this.currentEthIfcInfo.gateway,
      netMask: this.currentEthIfcInfo.netMask,
      domain: '',
    };
    return param;
  }

  private closeDialog(): void {
    LogUtil.info(`${TAG} closeDialog`);
    // 操作半模态弹框显示
    notifyCompStateChange(ETHERNET_ADVANCED_DIALOG_ID,
      new Map<SettingStateType, SettingBaseState>([[SettingStateType.STATE_TYPE_ITEM_SHEET,
        {
          state: false,
        } as SettingCompState]]
      ));
  }

  private cancelEthSetting(): void {
    this.globalContext.set('beforeIPConfig', null);
    this.closeDialog();
  }

  build() {
    Column() {
      DialogTitleBar({
        title: $r('app.string.network_title')
      })

      // 高级以太网的配置条目列表
      Column() {
        // 配置IP寻址模式
        Flex({
          justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center,
          wrap: FontScaleUtils.isExtraLargeFontMode() ? FlexWrap.Wrap : FlexWrap.NoWrap
        }) {
          Text($r('app.string.configure_ipv4'))
            .fontWeight(FontWeight.Medium)
            .fontSize($r('sys.float.Body_L'))
            .fontColor($r('sys.color.font_primary'))

          this.ipModeMenu();
        }
        .constraintSize({
          minHeight: DeviceUtil.isDevicePc() ? $r('app.float.height_40') : $r('app.float.height_48')
        })
        .margin({
          start: PADDING_12,
          end: PADDING_0
        })
        .padding({
          top: FontScaleUtils.getCurrentTopPadding(),
          bottom: FontScaleUtils.getCurrentTopPadding()
        })

        Divider().margin({ left: $r('sys.float.padding_level6'), right: $r('sys.float.padding_level6') });

        // IP地址
        BuildNetIfcListItem({
          name: $r('app.string.ip_address'),
          inputHint: $r('app.string.ip_address_hint'),
          customKey: 'ipAddr',
          currentEthIfcInfo: $currentEthIfcInfo,
          paramEthIfcInfo: $dhcpInfo,
          errorInputKeys: $errorInputKeys
        })

        // 子网掩码
        BuildNetIfcListItem({
          name: $r('app.string.subnet_mask'),
          inputHint: $r('app.string.subnet_mask_hint'),
          customKey: 'netMask',
          currentEthIfcInfo: $currentEthIfcInfo,
          paramEthIfcInfo: $dhcpInfo,
          errorInputKeys: $errorInputKeys
        })

        // 网关地址
        BuildNetIfcListItem({
          name: $r('app.string.router'),
          inputHint: $r('app.string.router_hint'),
          customKey: 'gateway',
          currentEthIfcInfo: $currentEthIfcInfo,
          paramEthIfcInfo: $dhcpInfo,
          errorInputKeys: $errorInputKeys
        })

        // DNS服务器
        BuildNetIfcListItem({
          name: $r('app.string.dns_server'),
          inputHint: $r('app.string.dns_server_hint'),
          customKey: 'dns0',
          currentEthIfcInfo: $currentEthIfcInfo,
          paramEthIfcInfo: $dhcpInfo,
          errorInputKeys: $errorInputKeys
        })

        // DNS备用服务器
        BuildNetIfcListItem({
          name: $r('app.string.alternate_dns_server'),
          inputHint: $r('app.string.alternate_dns_server_hint'),
          customKey: 'dns1',
          currentEthIfcInfo: $currentEthIfcInfo,
          paramEthIfcInfo: $dhcpInfo,
          errorInputKeys: $errorInputKeys,
          showDivider: false,
        })
      }
      .constraintSize({
        minHeight: $r('app.float.ethernet_dialog_card_height')
      })
      .padding({
        top: $r('sys.float.padding_level2'),
        bottom: $r('sys.float.padding_level2')
      })
      .backgroundColor($r('sys.color.comp_background_list_card'))
      .borderRadius(DeviceUtil.isDevicePc() ? $r('sys.float.corner_radius_level8') :
      $r('sys.float.corner_radius_level10'))

      // 按钮行
      Flex({
        justifyContent: FlexAlign.SpaceBetween,
        alignItems: ItemAlign.Center,
        space: { main: PADDING_16 }
      }) {
        DialogButton({
          title: $r('app.string.cancel'),
          buttonWidth: Constants.PERCENT_50_WIDTH,
          isActive: false,
          customKey: 'AdvancedEthernetSettingDialogView_Cancel',
          clickMethod: () => {
            this.cancelEthSetting();
          }
        })
        DialogButton({
          title: $r('app.string.save'),
          buttonWidth: Constants.PERCENT_50_WIDTH,
          isActive: true,
          customKey: 'AdvancedEthernetSettingDialogView_Save',
          clickMethod: () => {
            this.saveEthSetting();
          }
        })
      }.margin({
        top: $r('sys.float.padding_level8'),
        bottom: $r('sys.float.padding_level12')
      })
    }
    .borderRadius($r('sys.float.corner_radius_level8'))
    .borderColor($r('sys.color.dialog_inner_border_color'))
    .borderWidth($r('sys.float.border_larger'))
    .padding({
      left: $r('sys.float.padding_level12'),
      right: $r('sys.float.padding_level12')
    })
    .constraintSize({
      minHeight: $r('app.float.ethernet_dialog_height')
    })
    .onFocus(() => {
      this.focused = true;
    })
    .onBlur(() => {
      this.focused = false;
    })
  }

  @Builder
  select() {
    Menu() {
      ForEach(this.ipAddressingModeList, (ipMode: IpAddressingMode, index: number) => {
        MenuItem({
          symbolEndIcon: this.getSelectedModeIndex() === index ? this.endIconModifier : null,
          content: ipMode.value,
        })
          .constraintSize({
            minWidth: DeviceUtil.isDevicePc() ? $r('app.float.width_152') : $r('app.float.width_216')
          })
          .onClick((): void => {
            let selectMode: number = this.ipAddressingModeList.find((item) => item.index === index)!.key;
            LogUtil.info(`${TAG} On select change index : ${index}, selectMode: ${selectMode}, oldMode: ${this.currentEthIfcInfo.mode}`);
            if (this.currentEthIfcInfo.mode !== selectMode) {
              this.currentEthIfcInfo.mode = selectMode;
            }
          })
          .defaultFocus(true)
      }, (ipMode: IpAddressingMode, index: number) => ResourceUtil.getStringSync(ipMode.value))
    }
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .constraintSize({
      minWidth: DeviceUtil.isDevicePc() ? $r('app.float.width_160') : $r('app.float.length_224')
    })
    .radius($r('sys.float.corner_radius_level4'))
  }

  @Builder
  ipModeMenu(): void {
    Button({ type: ButtonType.Normal, stateEffect: false }) {
      Row() {
        Text(this.ipAddressingModeList[this.getSelectedModeIndex()].value)
          .fontWeight(FontWeight.Medium)
          .fontSize($r('sys.float.Body_M'))
          .fontFamily('HarmonyHeiTi')
          .focusable(true)
          .fontColor($r('sys.color.font_primary'))
          .padding({
            start: FontScaleUtils.isExtraLargeFontMode() ? undefined : PADDING_8
          })

        SymbolGlyph($r('sys.symbol.arrowtriangle_down_fill'))
          .alignSelf(ItemAlign.Center)
          .draggable(false)
          .fontSize($r('app.float.size_16'))
          .fontColor([$r('sys.color.font_primary')])
          .margin({
            top: PADDING_4,
            bottom: PADDING_4,
            start: PADDING_6,
            end: PADDING_6,
          })
      }
      .padding({
        top: PADDING_2,
        bottom: PADDING_2
      })
      .borderRadius($r('sys.float.corner_radius_level4'))
      .bindMenu(this.select(), { showInSubWindow: false, placement: Placement.BottomRight })
      .alignItems(VerticalAlign.Center)
    }
    .margin({
      end: PADDING_6
    })
    .borderRadius($r('sys.float.corner_radius_level4'))
    .backgroundColor(this.hoverBackgroundColor)
    .focusable(true)
    .hoverEffect(HoverEffect.None)
    .onHover((isHover: boolean) => {
      if (isHover) {
        this.hoverBackgroundColor = $r('sys.color.interactive_hover');
      } else {
        this.hoverBackgroundColor = Color.Transparent;
      }
    })
    .onTouch((event?: TouchEvent) => {
      if (event && event.type === TouchType.Down) {
        this.hoverBackgroundColor = $r('sys.color.interactive_click')
      } else if (event && event.type === TouchType.Up) {
        this.hoverBackgroundColor = Color.Transparent;
      }
    })
  }
}

export { AdvancedEthernetSettingDialogView };
