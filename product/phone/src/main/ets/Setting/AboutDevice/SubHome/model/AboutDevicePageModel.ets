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

import { LengthMetrics } from '@kit.ArkUI';
import deviceInfo from '@ohos.deviceInfo';
import {
  PADDING_0,
  PADDING_16,
  PADDING_24,
  PADDING_12
} from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { ContainerStyle, ImageStyle } from '@ohos/settings.common/src/main/ets/core/model/menu/ComponetStyle';
import { PageType, SettingPageModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingPageModel';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { PreferencesUtil } from '@ohos/settings.common/src/main/ets/utils/PreferencesUtil';
import { LanguageUtils } from '@ohos/settings.common/src/main/ets/utils/LanguageUtils';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { GroupType } from '@ohos/settings.common/src/main/ets/framework/model/SettingGroupModel';
import { CapabilitySupportUtils } from '@ohos/settings.common/src/main/ets/utils/CapabilitySupportUtils';
import DeviceNameDisable from '@ohos/settings.common/src/main/ets/utils/DeviceNameDisable';
import {
  ItemDetailType,
  ItemResultType,
  ItemType,
  SettingItemModel
} from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { SimUtils } from '@ohos/settings.common/src/main/ets/utils/SimUtils';
import { DeviceNameItemComponent } from '@ohos/settings.commonUikit/src/main/ets/component/DeviceNameItemComponent';
import {
  KernelVersionController,
  OpenHarmonyVersionController,
  ApiVersionController
} from '@ohos/settings.aboutdevice/src/main/ets/controller/DeviceVersionInfoController';
import { SoftwareVersionController } from '@ohos/settings.aboutdevice/src/main/ets/controller/SoftwareVersionController';
import {
  EIDDetailController,
  RunningMemoryController,
  ScreenResolutionController,
  StorageCapacityController
} from '@ohos/settings.aboutdevice/src/main/ets/controller/DeviceInfoGroupController';
import { SecurityPatchLabelController } from '@ohos/settings.aboutdevice/src/main/ets/controller/SecurityPatchLabelController';
import { AboutDeviceUtils } from '@ohos/settings.aboutdevice/src/main/ets/utils/AboutDeviceUtils';
import { AboutDeviceNameController } from '../controller/AboutDeviceNameController';
import { ImeiController } from '../controller/ImeiController';
import { BaseBandVersionController } from '../controller/BaseBandVersionController';
import { ScreenItemComponent } from '@ohos/settings.aboutdevice';

/**
 * 关于本机页面ouc模拟器卡片背景图片模型
 *
 * @since 2024-06-29
 */
class ImageMenuImageStyle extends ImageStyle {
  public size: SizeOptions = {
    width: '100%',
    height: '100%',
  };
  public imageFit = ImageFit.Cover;
}

/**
 * 关于本机页面ouc模拟器卡片Logo显示模型
 *
 * @since 2024-06-29
 */
class LogoImageStyle extends ImageStyle {
  // Logo大小
  public size: SizeOptions = {
    height: '20%',
  };
  // Logo适配大小范围
  public constraintSize: ConstraintSizeOptions = {
    maxWidth: '290vp',
    minHeight: '53vp',
  }
  public imageFit = ImageFit.Contain;
}

/**
 * 关于本机页面ouc模拟器卡片父容器显示模型
 *
 * @since 2024-06-29
 */
export class LogoImageMenuContainerStyle extends ContainerStyle {
  public size: SizeOptions = {
    height: '50%',
  };
  public clip = true;
  public borderRadius = $r('app.float.length_16');
  public backgroundColor = $r('sys.color.background_secondary');
}


@Builder export function deviceNameItemBuilder(param: object) {
  DeviceNameItemComponent({
    item: param as SettingItemModel,
    maxLength: 100,
    hint: CapabilitySupportUtils.isSupportNearLink() ? $r('app.string.device_name_settings_summary_with_near_link') :
      $r('app.string.device_name_settings_summary_new'),
  });
}
@Builder export function screenItemBuilder(param: object) {
  ScreenItemComponent();
}

/**
 * 拓展安全区参数
 */
export interface SafeAreaParam {
  types?: Array<SafeAreaType>;
  edges?: Array<SafeAreaEdge>;
}

/**
 * 关于本机页面Model
 *
 * @since 2024-06-22
 */
export class AboutDevicePageModel {
  private securityPatchLabelClick: SecurityPatchLabelController = new SecurityPatchLabelController();
  public settingModel: SettingPageModel;
  public aboutDevicePage: SettingPageModel = {
    id: 'AboutDevice',
    url: NavEntryKey.ABOUT_DEVICE_ENTRY,
    type: PageType.PAGE_TYPE_CUSTOM,
    title: '',
    groups: [
      {
        id: 'screen_name_group',
        type: GroupType.GROUP_TYPE_STANDARD,
        items: [
          {
            id: 'screen_name',
            type: ItemType.ITEM_TYPE_CUSTOM,
            builder: wrapBuilder(screenItemBuilder)
          }
        ],
        layout: {
          margin: {
            top: PADDING_0,
            bottom: PADDING_0,
          },
          padding:{top:PADDING_0,bottom:PADDING_0,start:PADDING_0,end:PADDING_0 }
        }
      },
      {
        id: 'device_name_group',
        type: GroupType.GROUP_TYPE_STANDARD,
        items: [
          {
            id: 'device_name',
            type: ItemType.ITEM_TYPE_CUSTOM,
            title: { content: $r('app.string.device_name_settings_title') },
            builder: wrapBuilder(deviceNameItemBuilder),
            compControl: new AboutDeviceNameController(),
            enabled: !DeviceNameDisable.getInstance().getDisable()
          }
        ]
      },
      //关于本机型号名称 型号代码...
      {
        id: 'version_info_group',
        type: GroupType.GROUP_TYPE_STANDARD,
        items: [
          {
            id: 'display_device_name',
            type: ItemType.ITEM_TYPE_STANDARD,
            title: { content: $r('app.string.model_name') },
            result: { type: ItemResultType.RESULT_TYPE_TEXT, result: { content: this.getDeviceModelDisplay() } },
          },
          {
            id: 'product_model',
            type: ItemType.ITEM_TYPE_STANDARD,
            title: { content: $r('app.string.model_code') },
            result: { type: ItemResultType.RESULT_TYPE_TEXT, result: { content: DeviceUtil.productMode } },
          },
          {
            id: 'software_version',
            type: ItemType.ITEM_TYPE_STANDARD,
            title: { content: $r('app.string.software_version') },
            result: { type: ItemResultType.RESULT_TYPE_TEXT, result: { content: '',
              style: {
                direction: LanguageUtils.isLtrDirection() ? Direction.Ltr : Direction.Rtl }
            } },
            compControl: new SoftwareVersionController(),
          },
          {
            id: 'serial_number',
            type: ItemType.ITEM_TYPE_STANDARD,
            title: { content: $r('app.string.serial_number') },
            result: { type: ItemResultType.RESULT_TYPE_TEXT, result: { content: deviceInfo.serial } },
          }
        ]
      },
      //关于本机IMEI 运行内存....
      {
        id: 'device_info_group',
        type: GroupType.GROUP_TYPE_STANDARD,
        items: [
          {
            id: 'imei_id',
            type: ItemType.ITEM_TYPE_STANDARD,
            title: { content: $r('app.string.imei_id') },
            result: { type: ItemResultType.RESULT_TYPE_TEXT, result: { content: '' } },
            needHide: () => !SimUtils.isSupportSim(),
            compControl: new ImeiController(),
          },
          {
            id: 'esim_id',
            type: ItemType.ITEM_TYPE_STANDARD,
            title: { content: $r('app.string.esim_id') },
            result: {
              type: ItemResultType.RESULT_TYPE_TEXT,
              result: { content: '' }
            },
            needHide: () => !DeviceUtil.isSupportEsim(),
            compControl: new EIDDetailController(),
            detail: {
              type: ItemDetailType.DETAIL_TYPE_NAVIGATE,
              icon: $r('sys.symbol.chevron_right'),
              isSymbolIcon: true,
              destination: NavEntryKey.EID_DETAIL_ENTRY,
            },
          },
          {
            id: 'cpu_id',
            type: ItemType.ITEM_TYPE_STANDARD,
            title: { content: $r('app.string.cpu_title') },
            result: {
              type: ItemResultType.RESULT_TYPE_TEXT, result: {
                content: AboutDeviceUtils.getDeviceCPU(),
                style: {
                  direction: LanguageUtils.isLtrDirection() ? Direction.Ltr : Direction.Rtl
                }
              }
            },
            needHide: () => {
              // 如果CCM配置的特性开关为不显示或匿名化参数值为'hide'，就隐藏该项
              return (!AboutDeviceUtils.isShowProcessor() || (AboutDeviceUtils.isAnonymizationData() &&
                AboutDeviceUtils.anonymizationArry.processorVersion === 'hide'));
            }
          },
          {
            id: 'running_memory',
            type: ItemType.ITEM_TYPE_STANDARD,
            title: { content: $r('app.string.running_memory') },
            result: { type: ItemResultType.RESULT_TYPE_TEXT, result: { content: '' } },
            compControl: new RunningMemoryController(),
          },
          {
            id: 'storage_capacity',
            type: ItemType.ITEM_TYPE_STANDARD,
            title: { content: $r('app.string.storage_settings_title') },
            result: { type: ItemResultType.RESULT_TYPE_TEXT, result: { content: '' } },
            compControl: new StorageCapacityController(),
          },
          {
            id: 'screen_resolution',
            type: ItemType.ITEM_TYPE_STANDARD,
            title: { content: $r('app.string.screen_resolution') },
            result: { type: ItemResultType.RESULT_TYPE_TEXT, result: { content: '' } },
            compControl: new ScreenResolutionController(),
          }
        ]
      },
      //关于本机基带版本 内核版本...
      {
        id: 'parameter_upgrade_group',
        type: GroupType.GROUP_TYPE_STANDARD,
        items: [
          {
            id: 'baseband_version',
            type: ItemType.ITEM_TYPE_STANDARD,
            title: { content: $r('app.string.baseband_version') },
            result: { type: ItemResultType.RESULT_TYPE_TEXT, result: { content: '' } },
            needHide: () => !SimUtils.isSupportSim(),
            compControl: new BaseBandVersionController(),
          },
          {
            id: 'kernel_version',
            type: ItemType.ITEM_TYPE_STANDARD,
            title: { content: $r('app.string.kernel_version') },
            result: { type: ItemResultType.RESULT_TYPE_TEXT, result: { content: '',
              style: {
                direction: LanguageUtils.isLtrDirection() ? Direction.Ltr : Direction.Rtl }
            } },
            compControl: new KernelVersionController(),
          },
          {
            id: 'api_version',
            type: ItemType.ITEM_TYPE_STANDARD,
            title: { content: $r('app.string.api_version') },
            result: { type: ItemResultType.RESULT_TYPE_TEXT, result: { content: '', style: { direction: Direction.Ltr } } },
            compControl: new ApiVersionController(),
            needHide: () => {
              // 如果CCM配置的参数值为'hide'，就隐藏该项
              if (AboutDeviceUtils.isAnonymizationData() &&
                AboutDeviceUtils.anonymizationArry.apiVersion === 'hide') {
                return true;
              }
              return false;
            }
          },
          {
            id: 'openHarmony_version',
            type: ItemType.ITEM_TYPE_STANDARD,
            title: { content: $r('app.string.openHarmony_version') },
            result: { type: ItemResultType.RESULT_TYPE_TEXT, result: { content: '' } },
            compControl: new OpenHarmonyVersionController(),
            needHide: () => {
              // 如果CCM配置的参数值为'hide'，就隐藏该项
              if (AboutDeviceUtils.isAnonymizationData() &&
                AboutDeviceUtils.anonymizationArry.openHarmonyVersion === 'hide') {
                return true;
              }
              return false;
            }
          },
          // TODO 参数版本暂时不开源，后续等待版本更新一起开源 暂时隐藏
          // {
          //   id: 'com_hmos_ouc_param_version_settings',
          //   type: ItemType.ITEM_TYPE_STANDARD,
          //   title: { content: $r('app.string.parameter_version_title') },
          //   detail: {
          //     type: ItemDetailType.DETAIL_TYPE_NAVIGATE,
          //     icon: $r('sys.symbol.chevron_right'),
          //     isSymbolIcon: true,
          //     destination: NavEntryKey.OUC_PARAM_VERSION,
          //   },
          //   needHide: () => DeviceUtil.isDeviceEmulator(),
          // },
          {
            id: 'system_service_version',
            type: ItemType.ITEM_TYPE_STANDARD,
            title: { content: $r('app.string.system_service_version') },
            result: { type: ItemResultType.RESULT_TYPE_TEXT, result: {
              content: AboutDeviceUtils.getSystemServiceVersion() } },
            needHide: () => !AboutDeviceUtils.getSystemServiceVersion(),
          },
          {
            id: 'security_patch_label',
            type: ItemType.ITEM_TYPE_STANDARD,
            title: { content: $r('app.string.security_patch_label') },
            result: { type: ItemResultType.RESULT_TYPE_TEXT, result: {
              content: ResourceUtil.getLocalDataFormat(deviceInfo.securityPatchTag) } },
            detail: {
              type: ItemDetailType.DETAIL_TYPE_CUSTOM,
              icon: $r('sys.symbol.chevron_right'),
              isSymbolIcon: true,
              onItemClick: () => {
                this.securityPatchLabelClick.openBrowser();
              }
            },
          }
        ]
      },
      {
        id: 'information_group',
        type: GroupType.GROUP_TYPE_STANDARD,
        items: [
          {
            id: 'status_information_settings',
            type: ItemType.ITEM_TYPE_STANDARD,
            title: { content: $r('app.string.status_information') },
            detail: {
              type: ItemDetailType.DETAIL_TYPE_NAVIGATE,
              icon: $r('sys.symbol.chevron_right'),
              isSymbolIcon: true,
              destination: NavEntryKey.STATUS_INFO_SETTING,
            },
          },
          {
            id: 'legal_information_settings',
            type: ItemType.ITEM_TYPE_STANDARD,
            title: { content: $r('app.string.legal_information') },
            detail: {
              type: ItemDetailType.DETAIL_TYPE_NAVIGATE,
              icon: $r('sys.symbol.chevron_right'),
              isSymbolIcon: true,
              destination: NavEntryKey.LEGAL_INFO_SETTING
            }
          }
        ]
      },
      {
        id: 'enterprise_custom_group',
        type: GroupType.GROUP_TYPE_STANDARD,
        items: [
          {
            id: 'enterprise_custom_information',
            type: ItemType.ITEM_TYPE_STANDARD,
            title: { content: $r('app.string.enterprise_custom_information') },
            detail: {
              type: ItemDetailType.DETAIL_TYPE_NAVIGATE,
              icon: $r('sys.symbol.chevron_right'),
              isSymbolIcon: true,
              destination: NavEntryKey.ENTERPRISE_CUSTOM_INFO_ENTRY,
            },
            needHide: () => !AboutDeviceUtils.isDisplayEnterpriseCustomInfo()
          },
        ]
      }
    ]
  };

  public paddingValue: LengthMetrics = DeviceUtil.isDevicePhone() ? PADDING_16 : PADDING_24;
  public safeAreaParam: SafeAreaParam = {
    types: [SafeAreaType.SYSTEM],
    edges: [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM],
  };

  // 关于界面标题显示控制
  public isAboutDeviceTitleShow: boolean = true;
  public aboutDeviceTitleBackgroundColor: ResourceColor = Color.Transparent;

  // 模拟器关于界面ouc显示图片
  public isEmulator: boolean = DeviceUtil.isDeviceEmulator();

  // 关于界面ouc卡片置灰
  public isGrayed: boolean = false;
  public OPACITY_PERCENT_FULL: number = 1;
  public ALPHA_DISABLED: Resource = $r('sys.float.alpha_tertiary');


  // 关于界面ouc卡片下面菜单项显示控制
  public menuListShow: boolean = true;
  public listMinHeight: number = 0;
  public listColumnMarginTop: number = 0;
  public menuListTransitionEffect?: TransitionEffect;
  public isAboutDeviceBarStateOff: boolean = false;
  public scrollEdgeEffect = EdgeEffect.Spring;
  public onBackPressed?: Function;

  public isScrollEnable: boolean = true;

  constructor(settingModel: SettingPageModel) {
    this.settingModel = settingModel;
  }

  init(): void {
    this.isGrayed = PreferencesUtil.getSync('OucAboutDevice', false) as boolean;
  }

  getTitle(): string {
    return ResourceUtil.getStringSync(this.settingModel.title as Resource);
  }

  isEnterpriseDevice(): boolean {
    return AboutDeviceUtils.isDisplayEnterpriseCustomInfo();
  }

  getDeviceModelDisplay(): string {
    if (this.isEnterpriseDevice()) {
      const enterpriseDevice: string = ResourceUtil.getStringSync($r('app.string.enterprise_device'));
      return `${deviceInfo.marketName}（${enterpriseDevice}）`;
    }
    return deviceInfo.marketName;
  }
}