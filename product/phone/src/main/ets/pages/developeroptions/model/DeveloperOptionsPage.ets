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

import sim from '@ohos.telephony.sim';
import radio from '@ohos.telephony.radio';
import batteryInfo from '@ohos.batteryInfo';
import {
  SubHeaderSection,
  SwitchMenu,
  CardMenuSection,
  SummarySwitchMenuStyle,
  EntryMenu,
  NavigationEntry,
  DefaultEntryMenuStyle
} from '@ohos/settings.uikit';
import {
  UsbDebugSwitchController,
  RealTimeRefreshFrameRateController,
  ShowTouchActionsController,
  AutomaticSystemUpdateController,
  LayoutBoundariesController,
  RecallUsbDebugApproveController,
  WirelessCommissioningController,
  ForceResizableAppInterfacesController,
  DisplayRedrawAreaController,
  RedrawCacheHitDetectController,
  OverDrawDetectController,
  FreezeDetectController,
  LeakDetectController,
  OuterAppController,
  TraceRecordController,
  ShowTouchTrackController,
} from '@ohos/settings.developeroptions';
import { SystemParamUtil } from '@ohos/settings.common/src/main/ets/utils/SystemParamUtil';
import {
  NATURAL_LIGHT_PREFERENCE_KEY,
} from '@ohos/settings.developeroptions/src/main/ets/utils/DeveloperOptionsConsts';
import { DeveloperOptionUtils } from '@ohos/settings.developeroptions/src/main/ets/utils/DeveloperOptionsUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { PreferencesUtil } from '@ohos/settings.common/src/main/ets/utils/PreferencesUtil';
import { SYSTEM_ROLLBACK_WANT } from '@ohos/settings.uikit/src/main/ets/utils/Consts';
import { ContainerStyle } from '@ohos/settings.common/src/main/ets/core/model/menu/ComponetStyle';
import {
  EmptyInvisibleController,
  JumpServiceExtensionController,
} from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import {
  CardSectionListStyle,
  MultilineSummarySwitchMenuStyle,
  PrivacySingleChoiceMenuStyle,
  SingleChoiceEntryMenu,
  SingleChoiceMenuOnlyStyle,
  SubHeaderSectionStyle,
  SummaryTextStyle,
} from '@ohos/settings.uikit/src/main/ets/menus/Menu';
import { PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { SettingHeaderPage } from '@ohos/settings.uikit/src/main/ets/component/SettingHeaderPage';
import { FontScaleUtils } from '@ohos/settings.common/src/main/ets/utils/FontScaleUtils';
import {
  TextStyle,
} from '@ohos/settings.common/src/main/ets/core/model/menu/ComponetStyle';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { DateTimeUtil } from '@ohos/settings.common/src/main/ets/utils/DateTimeUtil';
import {
} from '@ohos/settings.developeroptions/src/main/ets/controller/BluetoothAudioController';
import DevelopmentPersonnelController from '../controller/DevelopmentPersonnelController';
import { ShowWLANLogsController } from '../controller/ShowWLANLogsController';
import { PageUrl } from '../../PageUrl';
import NrModeController from '../controller/NrModeController';
import TransitionAnimationController from '../controller/TransitionAnimationController';
/* instrument ignore file */
export class NavigationEntryWithLongTextStyle extends DefaultEntryMenuStyle {
  public rootContainer: ContainerStyle = new RootContainerStyleww();
}

export class NavigationBlueTitleTextStyle extends TextStyle {
  public fontColor: ResourceColor = '#0A59F7';
  public font: Font = {
    size: $r('sys.float.ohos_id_text_size_sub_title2'),
    weight: FontWeight.Medium,
  };
  public overflow: TextOverflow = TextOverflow.Ellipsis;
}

class InsightIntentSettingStyle extends DefaultEntryMenuStyle {
  public rootContainer: ContainerStyle = new RootContainerStyleww();
  public summary: SummaryTextStyle = new SummaryTextStyle();

  constructor() {
    super();
    this.summary.maxLines = 5;
  }
}

export class RootContainerStyleww extends ContainerStyle {
  public constraintSize: ConstraintSizeOptions = {
    minHeight: $r('app.float.height_64'),
  };
  public padding: Padding = {
    left: $r('app.float.padding_8'),
    right: $r('app.float.padding_8'),
    top: FontScaleUtils.getCurrentTopPadding(),
    bottom: FontScaleUtils.getCurrentTopPadding(),
  };
}

class VolumeModeCardSectionListStyle extends CardSectionListStyle {
  public padding: Padding = {
    top: '4vp',
    bottom: '4vp',
  };
}

class VolumeModeSubHeaderSectionStyle extends SubHeaderSectionStyle {
  public listStyle = new VolumeModeCardSectionListStyle();
}

export let volumeModeSubHeaderSectionStyle = new VolumeModeSubHeaderSectionStyle();

const TAG: string = 'DeveloperOptionsPage:';

/**
 * 开发者选项页面数据
 *
 * @since 2022-06-27
 */
export class DeveloperOptionsPage extends SettingHeaderPage {
  public status: boolean = false;
  private developerStatus: string = SystemParamUtil.getParam('const.security.developermode.state', '0');

  constructor(pathInfos: NavPathStack, params: PushParam, status: boolean) {
    super({
      pageUrl: PageUrl.DEVELOPER_OPTIONS_PAGE_URL,
      title: $r('app.string.developer_options_settings_title'),
      isNavigation: true,
      showHeader: false,
    });
    this.status = status;
    this.addMenus([
    // index 用于菜单排序
      new CardMenuSection(
        {
          key: 'development_personnel',
          index: 10,
        },
        [
          ...this.getDeveloperSwitchMenu(pathInfos, params),
        ]
      ),
      ...this.getMenu(pathInfos)
    ]
    );
  }

  private getDeveloperSwitchMenu(pathInfos: NavPathStack, params: PushParam): SettingsBaseMenu[] {
    let result: SettingsBaseMenu[] = [];
    if (this.developerStatus === 'true') {
      result.push(
        new SwitchMenu(
          {
            key: 'development_personnel_option',
            index: 20,
            tabIndex: 101,
            title: $r('app.string.developer_options_settings_title'),
            controller: {
              createControllerConstructorInter: DevelopmentPersonnelController.CreateDevelopmentPersonnelController,
            },
            pathInfos: pathInfos,
            navRouterParam: params,
          }
        ),
      )
    }
    return result;
  }

  private getNetWorkModeMenu(): SettingsBaseMenu[] {
    let result: SettingsBaseMenu[] = [];
    if (sim.hasSimCardSync(0) || sim.hasSimCardSync(1)) {
      result.push(
        new SingleChoiceEntryMenu(
          {
            key: 'debug_nr_mode',
            index: 10,
            style: new SingleChoiceMenuOnlyStyle(),
            selectIcon: $r('app.media.ic_selected'),
            stateIcon: $r('app.media.ic_arrow_down'),
            title: $r('app.string.nr_mode_configuration_title'),
            summary: $r('app.string.nr_mode_configuration_summary'),
            controller: {
              createControllerConstructorInter: NrModeController.CreateNrModeController,
            },
            singleChoiceData: [
              { title: $r('app.string.nr_mode_nsa'), isSelect: false, key: radio.NROptionMode.NR_OPTION_NSA_ONLY },
              {
                title: $r('app.string.nr_mode_sa_nsa'),
                isSelect: false,
                key: radio.NROptionMode.NR_OPTION_NSA_AND_SA
              }]
          }
        )
      )
    }
    return result;
  }

  private getMultiline(): SettingsBaseMenu[] {
    let result: SettingsBaseMenu[] = [];
    result.push(
      new SubHeaderSection(
        {
          key: 'debug_networking_group',
          index: 60,
          title: $r('app.string.debug_networking_category'),
          controller: {
            createControllerConstructorInter: EmptyInvisibleController.CreateEmptyInvisibleController,
          },
          style: volumeModeSubHeaderSectionStyle,
        },
        [
          new SwitchMenu(
            {
              key: 'wifi_Open_Logs',
              style: new MultilineSummarySwitchMenuStyle(),
              index: 50,
              tabIndex: 104,
              title: $r('app.string.wifi_Open_Logs'),
              summary: $r('app.string.wifi_Open_Logs__summary'),
              controller: {
                createControllerConstructorInter: ShowWLANLogsController.CreateShowWLANLogsController,
              },
            }
          ),
          ...this.getNetWorkModeMenu(),
        ]
      ),
    )
    return result;
  }

  private getOuterAppMenu(): SettingsBaseMenu[] {
    let result: SettingsBaseMenu[] = [];
    let isShowOuterAppMenu: string = SystemParamUtil.getParam('const.settings.debug_outer_app_show', 'false');
    if (isShowOuterAppMenu === 'false') {
      return result;
    }
    result.push(
      new SwitchMenu(
        {
          key: 'debug_outer_app',
          style: new SummarySwitchMenuStyle(),
          index: 65,
          title: $r('app.string.outer_app_debug'),
          summary: $r('app.string.outer_app_debug_tips'),
          controller: {
            createControllerConstructorInter: OuterAppController.CreateLeakDetectController,
          },
        }
      )
    )
    return result;
  }

  /*
   * 显示刷新率开关
   */
  private getRefreshRateMenu(): SettingsBaseMenu[] {
    let result: SettingsBaseMenu[] = [];
    let isShow: boolean = SystemParamUtil.getParam('const.settings.refresh_rate_seenable', 'true') === 'true';
    if (isShow) {
      result.push(
        new SwitchMenu({
          key: 'real_time_refresh_rate',
          style: new SummarySwitchMenuStyle(),
          index: 50,
          title: $r('app.string.display_refresh_frequency_title'),
          summary: $r('app.string.enable_display_refresh_frequency_summary'),
          controller: {
            createControllerConstructorInter:
            RealTimeRefreshFrameRateController.CreateRealTimeRefreshRateController,
          },
        }),
      )
    }
    return result;
  }

  private getMenu(pathInfos: NavPathStack): SettingsBaseMenu[] {
    let result: SettingsBaseMenu[] = [];
    if (this.status) {
      result.push(
        // 系统高级选项
        this.getSystemAdvancedSection(),
        // 调试
        this.getUsbDebuggedGroup(pathInfos),
        // 网络
        ...this.getMultiline(),
        // 显示
        this.getShowSection(),
        // 绘画
        this.getDrawingSection(),
        // 应用
        this.getApplicationSection(),
      )
    }
    return result;
  }

  private getSystemAdvancedSection(): SettingsBaseMenu {
    return new CardMenuSection(
      {
        key: 'developer_advanced_options',
        index: 10,
      },
      [
        new SwitchMenu(
          {
            key: 'automatic_system_update',
            index: 20,
            tabIndex: 102,
            title: $r('app.string.automatic_system_update'),
            controller: {
              createControllerConstructorInter: AutomaticSystemUpdateController.CreateAutomaticSystemUpdateController,
            },
          }
        ),
      ]
    );
  }

  private getShowSection(): SettingsBaseMenu {
    return new SubHeaderSection(
      {
        key: 'debug_show_group',
        index: 21,
        title: $r('app.string.developer_display'),
        style: volumeModeSubHeaderSectionStyle,
      },
      [
        new SwitchMenu(
          {
            key: 'debug_entering',
            style: new SummarySwitchMenuStyle(),
            index: 50,
            tabIndex: 105,
            title: $r('app.string.show_touch_actions_title'),
            summary: $r('app.string.enable_show_touch_actions_summary'),
            controller: {
              createControllerConstructorInter: ShowTouchActionsController.CreateShowTouchActionController,
            },
          }
        ),
        new SwitchMenu(
          {
            key: 'debug_entering_trace',
            style: new SummarySwitchMenuStyle(),
            index: 50,
            title: $r('app.string.show_touch_actions_trace'),
            summary: $r('app.string.enable_show_touch_trace_summary'),
            controller: {
              createControllerConstructorInter: ShowTouchTrackController.CreateShowTouchTrackController,
            },
          }
        ),
      ]
    );
  }

  private getDrawingSection(): SettingsBaseMenu {
    return new SubHeaderSection(
      {
        key: 'debug_drawing_group',
        index: 22,
        title: $r('app.string.debug_drawing_category'),
        style: volumeModeSubHeaderSectionStyle,
      },
      [
        new SwitchMenu(
          {
            key: 'debug_drawing',
            style: new SummarySwitchMenuStyle(),
            index: 10,
            tabIndex: 106,
            title: $r('app.string.debug_layout'),
            summary: $r('app.string.debug_layout_summary'),
            controller: {
              createControllerConstructorInter: LayoutBoundariesController.CreateLayoutBoundariesController,
            },
          }
        ),
        new SwitchMenu(
          {
            key: 'debug_redrawing_area',
            style: new SummarySwitchMenuStyle(),
            index: 11,
            title: $r('app.string.debug_redraw_area'),
            summary: $r('app.string.debug_redraw_area_summary'),
            controller: {
              createControllerConstructorInter: DisplayRedrawAreaController.CreateDisplayRedrawAreaController,
            },
          }
        ),
        new SwitchMenu(
          {
            key: 'debug_redrawing_cache_hit_detection',
            style: new SummarySwitchMenuStyle(),
            index: 12,
            title: $r('app.string.debug_redraw_cache_hit_detection'),
            summary: $r('app.string.debug_redraw_cache_hit_detection_summary'),
            controller: {
              createControllerConstructorInter: RedrawCacheHitDetectController.CreateRedrawCacheHitDetectController,
            },
          }
        ),
        new SwitchMenu(
          {
            key: 'debug_overdraw',
            style: new SummarySwitchMenuStyle(),
            index: 13,
            title: $r('app.string.debug_overdraw'),
            summary: $r('app.string.debug_overdraw_summary'),
            controller: {
              createControllerConstructorInter: OverDrawDetectController.CreateOverDrawDetectController,
            },
          }
        ),
        new EntryMenu(
          {
            key: 'debug_transition_animation',
            index: 20,
            title: $r('app.string.transition_animation_scale_title'),
            controller: {
              createControllerConstructorInter: TransitionAnimationController.CreateTransitionAnimationController,
            },
            symbolIcon: $r('sys.symbol.chevron_right'),
          }
        )
      ]
    );
  }

  private getUsbDebuggedGroup(pathInfos: NavPathStack): SettingsBaseMenu {
    return new SubHeaderSection(
      {
        key: 'usb_debug_group',
        index: 50,
        title: $r('app.string.debug_settings_title'),
        style: volumeModeSubHeaderSectionStyle,
      },
      [
        new SwitchMenu(
          {
            key: 'usb_debug',
            style: new SummarySwitchMenuStyle(),
            index: 10,
            tabIndex: 103,
            title: $r('app.string.usb_debug_settings_title'),
            summary: $r('app.string.enable_usb_debug_summary'),
            controller: {
              createControllerConstructorInter: UsbDebugSwitchController.CreateUsbDebugSwitchController,
            },
            pathInfos: pathInfos,
          }
        ),
        ...this.getRefreshRateMenu(),
        new NavigationEntry({
          key: 'system_rollback_settings',
          index: 30,
          title: $r('app.string.recall_usb_authorize'),
          extra: {
            want: SYSTEM_ROLLBACK_WANT,
          },
          controller: {
            createControllerConstructorInter: RecallUsbDebugApproveController.CreateRecallUsbDebugApproveController,
          },
        }),
        new NavigationEntry({
          key: 'system_wireless_commissioning',
          style: new NavigationEntryWithLongTextStyle(),
          index: 40,
          title: $r('app.string.wireless_commissioning'),
          summary: $r('app.string.activating_usb_debug'),
          symbolIcon: $r('sys.symbol.chevron_right'),
          targetPageUrl: PageUrl.WIRELESS_COMISSIONING_URL,
          controller: {
            createControllerConstructorInter: WirelessCommissioningController.CreateWirelessCommissioningController,
          },
        }),
        new SwitchMenu(
          {
            key: 'debug_system_trace',
            index: 50,
            title: $r('app.string.debug_system_trace'),
            controller: {
              createControllerConstructorInter: TraceRecordController.CreateTraceRecordController,
            },
          }
        ),
        new SwitchMenu(
          {
            key: 'debug_freeze_detect',
            index: 55,
            title: $r('app.string.debug_freeze_detect'),
            controller: {
              createControllerConstructorInter: FreezeDetectController.CreateFreezeDetectController,
            },
          }
        ),
        new SwitchMenu(
          {
            key: 'debug_leak_detect',
            style: new SummarySwitchMenuStyle(),
            index: 60,
            title: $r('app.string.debug_leak_detect'),
            summary: $r('app.string.debug_leak_detect_summary'),
            controller: {
              createControllerConstructorInter: LeakDetectController.CreateLeakDetectController,
            },
          }
        ),
        ...this.getOuterAppMenu(),
      ]
    );
  }

  private getApplicationSection(): SettingsBaseMenu {
    return new SubHeaderSection(
      {
        key: 'debug_applications_category',
        index: 1000,
        title: $r('app.string.debug_applications_category'),
      },
      [
        new SwitchMenu(
          {
            key: 'force_resizable_app_interfaces',
            style: new MultilineSummarySwitchMenuStyle(),
            index: 10,
            tabIndex: 107,
            title: $r('app.string.force_resizable_app_interfaces'),
            summary: $r('app.string.force_resizable_app_interfaces_summary'),
            controller: {
              createControllerConstructorInter:
              ForceResizableAppInterfacesController.CreateForceResizableAppInterfacesController,
            },
          }
        ),
      ]
    );
  }

}
