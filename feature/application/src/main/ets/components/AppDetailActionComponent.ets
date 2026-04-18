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
import { installer } from '@kit.AbilityKit';
import bundleManager from '@ohos.bundle.bundleManager';
import { AlertDialog, CustomContentDialog, TipsDialog } from '@ohos.arkui.advanced.Dialog';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { DeliverUtil } from '@ohos/settings.common/src/main/ets/utils/DeliverUtil';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { FwUtils } from '@ohos/settings.common/src/main/ets/framework/common/FwUtils';
import { SettingAppGroupModel } from '../model/SettingAppItemModel';
import { PageRouter } from '@ohos/settings.common/src/main/ets/framework/common/PageRouter';
import { SettingIconStyle } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import {
  notifyCompStateChange,
  SettingBaseState,
  SettingCompState,
  SettingStateType
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import {
  BundleStatusChangeListener,
  BundleStatusChangeManager
} from '@ohos/settings.common/src/main/ets/bundle/BundleStatusChangeManager';
import { FOCUS_BOX_PADDING_METRICS } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import {
  HiSysApplicationsAndServicesEventGroup
} from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { FontScaleUtils } from '@ohos/settings.common/src/main/ets/utils/FontScaleUtils';
import { PADDING_0, PADDING_8, PADDING_12 } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { AppManager } from '../util/AppManager';
import { AppEntry, AppType } from '../AppModel';
import { AppCloneBadgeComponent } from './AppCloneBadgeComponent';
import { ERROR_CODE_APP_LOCKED, UninstallResult } from '../model/UninstallResult';
import { AppListLoader } from '../AppListLoader';

const TAG: string = 'AppDetailActionComponent';
const SCROLL_BAR_OFFSET: number = 20;
const LISTENER_KEY: string = 'APP_DETAIL_UNINSTALL';

@Component
export struct AppDetailActionComponent {
  appItem?: SettingAppGroupModel;
  @State bundleType: number | undefined = undefined;
  @State button1Title: ResourceStr | string = '';
  @State isButton1Enable: boolean = true;
  @State isButton2Enable: boolean = true;
  @State isShow: boolean = false;
  private entry: AppEntry | null = null;
  private isRunnable: boolean = false;
  private isRemovable: boolean = true;
  private isAppEnable: boolean = true;
  private stopAppDialogController: CustomDialogController | undefined = undefined;
  private uninstallAppDialogController: CustomDialogController | undefined = undefined;
  private forceStopAppDialogController: CustomDialogController | undefined = undefined;
  private contentScroller: Scroller = new Scroller();
  private isUninstallSuccess: boolean = true;
  private bundleStatusCallback: BundleStatusChangeListener = {
    getListenerName: (): string => LISTENER_KEY,
    onBundleAdd: (bundleName, userId, appIndex) => {
      LogUtil.info(`${TAG} bundleStatusCallback add, bundleName: ${bundleName} userId: ${userId} appIndex: ${appIndex}`);
    },
    onBundleRemove: (bundleName, userId, appIndex) => {
      LogUtil.info(`${TAG} bundleStatusCallback remove, bundleName: ${bundleName} userId: ${userId} appIndex: ${appIndex}`);
      /* instrument ignore if*/
      if (!this.isUninstallSuccess && bundleName === this.entry?.name && appIndex === this.entry?.appIndex) {
        LogUtil.info(`${TAG} app uninstalled, go back`);
        this.reportUninstallResult(this.entry?.name ?? '', true, 0);
        PageRouter.pop('Setting');
      }
    },
    onBundleUpdate: (bundleName, userId, appIndex) => {
      LogUtil.info(`${TAG} bundleStatusCallback update, bundleName: ${bundleName} userId: ${userId} appIndex: ${appIndex}`);
    }
  };

  build() {
    Row() {
      if (this.bundleType === bundleManager.BundleType.APP) {
        this.appActionButtonBuilder()
      } else if (this.bundleType === bundleManager.BundleType.ATOMIC_SERVICE) {
        this.serviceActionButtonBuilder()
      }
    }
    .visibility(this.isShow ? Visibility.Visible : Visibility.Hidden)
    .padding({ end: FwUtils.getLength(8) })
    .onVisibleAreaChange([0.0, 1.0], (isVisible: boolean, currentRatio: number) => {
      this.onVisible(isVisible, currentRatio);
    })
  }

  @Builder
  serviceActionButtonBuilder() {
    Button($r('app.string.remove_atomic_service_text'))
      .width('100%')
      .height('40vp')
      .fontWeight(FontWeight.Medium)
      .borderRadius($r('sys.float.corner_radius_level10'))
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .fontColor($r('sys.color.ohos_id_color_text_primary_activated'))
      .type(ButtonType.Normal)
      .onClick(() => {
        LogUtil.info(`${TAG} button3 click`);
        this.onButton3Click();
      })
  }

  @Builder
  appActionButtonBuilder() {
    Flex({ direction: FontScaleUtils.isExtraLargeFontMode() ? FlexDirection.Column : FlexDirection.Row }) {
      Button(this.button1Title)
        .width(FontScaleUtils.isExtraLargeFontMode() ? '100%' : '50%')
        .height('40vp')
        .fontWeight(FontWeight.Medium)
        .borderRadius(DeviceUtil.isDevicePc() ? $r('sys.float.corner_radius_level4')
          : $r('sys.float.corner_radius_level10'))
        .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
        .fontColor($r('sys.color.ohos_id_color_text_primary_activated'))
        .type(ButtonType.Normal)
        .enabled(this.isButton1Enable)
        .margin({
          end: FontScaleUtils.isExtraLargeFontMode() ? PADDING_0 : PADDING_8,
          bottom: FontScaleUtils.isExtraLargeFontMode() ? PADDING_12 : PADDING_0,
        })
        .onClick(() => {
          LogUtil.info(`${TAG} button1 click`);
          this.onButton1Click();
        })
        .focusBox({ margin: FOCUS_BOX_PADDING_METRICS })

      Button($r('app.string.app_info_force_stop'))
        .width(FontScaleUtils.isExtraLargeFontMode() ? '100%' : '50%')
        .height('40vp')
        .fontWeight(FontWeight.Medium)
        .borderRadius(DeviceUtil.isDevicePc() ? $r('sys.float.corner_radius_level4')
          : $r('sys.float.corner_radius_level10'))
        .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
        .fontColor($r('sys.color.ohos_id_color_text_primary_activated'))
        .type(ButtonType.Normal)
        .enabled(this.isButton2Enable)
        .onClick(() => {
          LogUtil.info(`${TAG} button2 click`);
          this.onButton2Click();
        })
        .focusBox({ margin: FOCUS_BOX_PADDING_METRICS })
    }
  }

  aboutToAppear(): void {
    this.entry = this.appItem?.entry as AppEntry;
    LogUtil.info(`${TAG} aboutToAppear ${this.entry?.name}`);
    this.initSwitchStatus();
    EventBus.getInstance().on('showUninstallUpdateDialog', () => {
      this.openUninstallUpdateAppDialog();
    });
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear ${this.entry?.name}`);
    this.stopAppDialogController?.close();
    this.uninstallAppDialogController?.close();
    BundleStatusChangeManager.getInstance().unRegisterBundleChangedListener(this.bundleStatusCallback);
    EventBus.getInstance().off('showUninstallUpdateDialog');
  }

  private onVisible(isVisible: boolean, currentRatio: number) {
    if (isVisible && currentRatio >= 1.0) {
      LogUtil.info(`${TAG} onVisible ${this.entry?.name}`);
      this.initSwitchStatus();
    }
  }

  /* instrument ignore next */
  private onButton1Click(): void {
    LogUtil.info(`${TAG} onButton1Click ${this.isRemovable} ${this.isAppEnable}`);
    if (this.isRemovable) {
      this.openUninstallAppDialog();
    } else if (!this.isAppEnable) {
      this.enableApp();
    } else {
      this.openDisableAppDialog();
    }
  }

  private onButton2Click(): void {
    this.openForceStopAppDialog();
  }

  private onButton3Click(): void {
    this.openRemoveDialog();
  }

  /* instrument ignore next */
  private enableApp(): void {
    let result =
      AppManager.getInstance().setApplicationEnabled(this.entry?.name ?? '', true, this.entry?.appIndex ?? 0);
    if (!result) {
      return;
    }
    this.isAppEnable = true;
    this.button1Title = this.isAppEnable ? $r('app.string.service_disable_text') : $r('app.string.service_enable_text');
    this.refreshGroupsState(true);
  }

  private async openRemoveDialog(): Promise<void> {
    let message: string = await ResourceUtil.getFormatString($r('app.string.is_delete_form'),
      this.entry?.label as string);
    this.uninstallAppDialogController = new CustomDialogController({
      builder: TipsDialog({
        imageRes: this.entry?.icon,
        content: message,
        primaryButton: {
          value: $r('app.string.dialog_cancel'),
          action: () => {
            this.uninstallAppDialogController?.close();
          }
        },
        secondaryButton: {
          value: $r('app.string.remove'),
          action: () => {
            LogUtil.info(`${TAG} onDialogConfirm`);
            this.uninstallAppDialogController?.close();
            BundleStatusChangeManager.getInstance().registerBundleChangedListener(this.bundleStatusCallback);
            this.uninstallApp();
          },
          fontColor: $r('sys.color.ohos_id_color_warning')
        }
      }),
      autoCancel: false,
      alignment: DialogAlignment.Center,
    });
    this.uninstallAppDialogController.open();
  }

  @Builder
  uniStallDialogContentBuilder() {
    Scroll(this.contentScroller) {
      Column() {
        AppCloneBadgeComponent({
          iconStyle:{
            border: { width: '0px', color: '#00000000', radius: 0 },
            borderRadius: 0,
            width: 64,
            height: 64,
            mirrored: false,
            interpolation: ImageInterpolation.Medium,
            draggable: false
          } as SettingIconStyle,
          entry: this.entry,
          isNeedEndPadding: false,
          iconSize: 64
        })

        Text($r('app.string.app_info_uninstall_confirm'))
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Bold)
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.font_primary'))
          .wordBreak(WordBreak.BREAK_WORD)
          .margin({ top: LengthMetrics.vp(16) })
      }
      .width('100%')
    }
    .scrollBar(BarState.Off)
    .nestedScroll({ scrollForward: NestedScrollMode.PARALLEL, scrollBackward: NestedScrollMode.PARALLEL })
    .width('100%')
  }

  @Builder
  uninstallUpdateDialogContentBuilder() {
    Column() {
      Scroll(this.contentScroller) {
        Column() {
          AppCloneBadgeComponent({
            iconStyle:{
              border: { width: '0px', color: '#00000000', radius: 0 },
              borderRadius: 0,
              width: 64,
              height: 64,
              mirrored: false,
              interpolation: ImageInterpolation.Medium,
              draggable: false
            } as SettingIconStyle,
            entry: this.entry,
            isNeedEndPadding: false,
            iconSize: 64
          })
          Text(ResourceUtil.getFormatStringSync($r('app.string.app_info_uninstall_update_title'),
            this.entry?.label ?? ''))
            .fontFamily('HarmonyHeiTi')
            .fontWeight(FontWeight.Bold)
            .fontSize($r('sys.float.Title_S'))
            .margin({ top: $r('app.float.margin_16') })
            .fontColor($r('sys.color.font_primary'))
            .maxFontScale(2)
            .maxLines(2)
            .minFontSize($r('app.float.font_16'))
            .maxFontSize($r('sys.float.Title_S'))
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          Text($r('app.string.app_info_uninstall_update_confirm'))
            .fontFamily('HarmonyHeiTi')
            .fontWeight(FontWeight.Regular)
            .fontSize($r('sys.float.Body_L'))
            .fontColor($r('sys.color.font_primary'))
            .wordBreak(WordBreak.BREAK_WORD)
            .maxFontScale(3.2)
            .margin({ top: LengthMetrics.vp(8) })
        }
        .margin({ end: LengthMetrics.vp(SCROLL_BAR_OFFSET) })
        .width(`calc(100% - ${SCROLL_BAR_OFFSET}vp)`)
      }
      .nestedScroll({ scrollForward: NestedScrollMode.PARALLEL, scrollBackward: NestedScrollMode.PARALLEL })
      .width('100%')
    }
    .margin({ end: LengthMetrics.vp(-SCROLL_BAR_OFFSET) })
  }

  private openUninstallAppDialog(): void {
    LogUtil.info(`${TAG} onUninstallAppDialog, ${JSON.stringify(this.entry)}`);
    this.uninstallAppDialogController = new CustomDialogController({
      builder: CustomContentDialog({
        contentBuilder: () => {
          this.uniStallDialogContentBuilder()
        },
        buttons: [{
          value: $r('app.string.dialog_cancel'),
          action: () => {
            this.uninstallAppDialogController?.close();
          }
        },
          {
            value: $r('app.string.app_info_uninstall'),
            action: () => {
              LogUtil.info(`${TAG} onDialogConfirm`);
              this.uninstallAppDialogController?.close();
              BundleStatusChangeManager.getInstance().registerBundleChangedListener(this.bundleStatusCallback);
              this.uninstallApp();
            },
            fontColor: $r('sys.color.ohos_id_color_warning')
          }
        ]
      }),
      autoCancel: false,
      alignment: DialogAlignment.Center,
    });
    this.uninstallAppDialogController.open();
  }

  private openUninstallUpdateAppDialog(): void {
    LogUtil.info(`${TAG} openUninstallUpdateAppDialog, ${this.entry?.name}`);
    this.uninstallAppDialogController = new CustomDialogController({
      builder: CustomContentDialog({
        contentBuilder: () => {
          this.uninstallUpdateDialogContentBuilder()
        },
        buttons: [{
          value: $r('app.string.dialog_cancel'),
          action: () => {
            this.uninstallAppDialogController?.close();
          }
        },
          {
            value: $r('app.string.app_info_uninstall_update'),
            action: () => {
              LogUtil.info(`${TAG} openUninstallUpdateAppDialog onDialogConfirm`);
              this.dealUninstallUpdates();
              this.uninstallAppDialogController?.close();
            },
            fontColor: $r('sys.color.ohos_id_color_warning')
          }
        ]
      }),
      autoCancel: false,
      alignment: DialogAlignment.Center,
    });
    this.uninstallAppDialogController.open();
  }

  private openDisableAppDialog(): void {
    let message: string = ResourceUtil.getStringSync($r('app.string.whether_to_disable_descriptions'));
    this.stopAppDialogController = new CustomDialogController({
      builder: AlertDialog({
        primaryTitle: $r('app.string.whether_to_disable_text'),
        content: message,
        primaryButton: {
          value: $r('app.string.dialog_cancel'),
          action: () => {
            this.stopAppDialogController?.close();
          },
        },
        secondaryButton: {
          value: $r('app.string.service_disable_text'),
          action: () => {
            LogUtil.info(`${TAG} onDialogConfirm`);
            this.stopAppDialogController?.close();
            this.disableApp();
          },
          fontColor: $r('sys.color.ohos_id_color_warning')
        }
      }),
      autoCancel: false,
      alignment: DialogAlignment.Center,
    });
    this.stopAppDialogController.open();
  }

  private openForceStopAppDialog(): void {
    let message: string = ResourceUtil.getStringSync($r('app.string.whether_to_forcibly_stop_descriptions'));
    this.forceStopAppDialogController = new CustomDialogController({
      builder: AlertDialog({
        primaryTitle: $r('app.string.whether_to_forcibly_stop_text'),
        content: message,
        primaryButton: {
          value: $r('app.string.dialog_cancel'),
          action: () => {
            this.stopAppDialogController?.close();
          },
        },
        secondaryButton: {
          value: $r('app.string.app_info_force_stop'),
          action: () => {
            LogUtil.info(`${TAG} onDialogConfirm`);
            this.forceStopAppDialogController?.close();
            HiSysEventUtil
              .reportDefaultBehaviorEventByUE(HiSysApplicationsAndServicesEventGroup
                .APP_AND_SERVICE_STOPPING_SWITCH);
            this.forceStopApp();
          },
          fontColor: $r('sys.color.ohos_id_color_warning')
        }
      }),
      autoCancel: false,
      alignment: DialogAlignment.Center,
    });
    this.forceStopAppDialogController.open();
  }

  /* instrument ignore next */
  private async disableApp(): Promise<void> {
    let result = await AppManager.getInstance().setApplicationEnabled(this.entry?.name as string,
      false, this.entry?.appIndex ?? 0);
    if (!result) {
      LogUtil.info(`${TAG} setApplicationEnabled failed`);
    } else {
      this.isAppEnable = false;
      this.button1Title =
        this.isAppEnable ? $r('app.string.service_disable_text') : $r('app.string.service_enable_text');
      this.refreshGroupsState(false);
    }
  }

  private refreshGroupsState(state: boolean): void {
    EventBus.getInstance().emit('EVENT_ID_APP_ENABLE_SWITCH_EVENTS', state);
    this.sendGroupStateEvent('Setting.AppDetail.AppNetworkGroup', state);
    this.sendGroupStateEvent('Setting.AppDetail.DefaultBrowserGroup', state);
    this.sendGroupStateEvent('Setting.AppDetail.DefaultMailGroup', state);
  }

  private sendGroupStateEvent(compId: string, isShow: boolean): void {
    LogUtil.info(`${TAG} showOrHideGroup: ${isShow}`);
    notifyCompStateChange(`${compId}`, new Map<SettingStateType, SettingBaseState>(
      [[SettingStateType.STATE_TYPE_GROUP_VISIBLE, { state: isShow } as SettingCompState]]
    ));
  }

  /* instrument ignore next */
  private async forceStopApp(): Promise<void> {
    LogUtil.info(`${TAG} onDialogConfirm forceStopApp, bundleName: ${this.entry?.name as string}, appIndex: ${this.entry?.appIndex}`);
    if(AppListLoader.getInstance().getAppType(this.entry) === AppType.CONTAINER_APP) {
      await AppManager.getInstance().killProcessesByBundleName(this.entry?.name as string);
    } else {
      await AppManager.getInstance().killProcessWithAccount(this.entry?.name as string, this.entry?.appIndex ?? 0);
    }
    this.isButton2Enable = false;
  }

  /* instrument ignore next */
  private async uninstallApp(): Promise<void> {
    LogUtil.info(`${TAG} onDialogConfirm uninstallApp, bundleName: ${this.entry?.name as string}, appIndex: ${this.entry?.appIndex}`);
    let result: UninstallResult =
      await AppManager.getInstance().uninstallApp(this.entry?.name ?? '', this.entry?.appIndex ?? 0, false);
    this.isUninstallSuccess = result.isSuccess;
    if (result.isSuccess || result.error?.code !== ERROR_CODE_APP_LOCKED) {
      this.reportUninstallResult(this.entry?.name ?? '', result.isSuccess, result.error?.code);
      PageRouter.pop('Setting');
    }
  }

  private reportUninstallResult(bundleName: string, isSuccess: boolean, errorCode: number = 0):void {
    const param: Record<string, Object> = {};
    param.BUNDLE_NAME = bundleName;
    param.IS_SUCCESS = isSuccess;
    param.ERROR_CODE = errorCode;
    HiSysEventUtil.reportBehaviorEventByUE(HiSysApplicationsAndServicesEventGroup.APP_AND_SERVICE_UNINSTALL_SWITCH,
      param);
  }

  /* instrument ignore next */
  private async dealUninstallUpdates(): Promise<void> {
    try {
      LogUtil.showInfo(TAG, `${this.entry?.name ?? ''} uninstallUpdates start`);
      const bundleInstaller: installer.BundleInstaller = installer.getBundleInstallerSync();
      if (!bundleInstaller) {
        LogUtil.showWarn(TAG, 'bundleInstaller invalid');
        return;
      }
      await bundleInstaller.uninstallUpdates(this.entry?.name ?? '');
      PageRouter.pop('Setting');
      LogUtil.showInfo(TAG, `${this.entry?.name ?? ''} uninstallUpdates success`);
    } catch (error) {
      LogUtil.showError(TAG, `uninstallUpdates error ${error}`)
    }
  }

  private async initSwitchStatus(): Promise<void> {
    LogUtil.info(`${TAG} initSwitchStatus ${this.entry?.name}`);
    this.bundleType = this.entry?.appInfo?.bundleType;
    this.isRemovable = this.entry?.removable as boolean;
    this.isRunnable = await AppManager.getInstance()
        .getIsApplicationRunning(this.entry?.name as string, this.entry?.appIndex ?? 0);
    this.isAppEnable = await AppManager.getInstance()
      .getIsApplicationEnabled(this.entry?.name as string, this.entry?.appIndex ?? 0,
        AppListLoader.getInstance().getAppType(this.entry));
    LogUtil.info(`${TAG} initSwitchStatus ${this.isRemovable} ${this.isRunnable} ${this.isAppEnable}`);
    if (this.isRemovable) {
      this.button1Title = $r('app.string.app_info_uninstall');
    } else {
      this.button1Title =
        this.isAppEnable ? $r('app.string.service_disable_text') : $r('app.string.service_enable_text');
    }
    this.isButton1Enable = this.isButton1Enabled();
    this.isButton2Enable = this.isButton2Enabled();
    this.isShow = true;
  }

  private isButton1Enabled(): boolean {
    if (AppListLoader.getInstance().getAppType(this.entry) === AppType.CONTAINER_APP) {
      LogUtil.info(`${TAG} initSwitchStatus fix containerApp`);
      this.button1Title = $r('app.string.app_info_uninstall');
      if (this.isRemovable && (DeliverUtil.getDeliverStartStatus() !== DeliverUtil.DELIVER_START_FINISHED_CODE)) {
        return false;
      }
      return this.isRemovable;
    }
    if (this.isRemovable) {
      return true;
    }
    const bundleName = this.entry?.name || '';
    const moduleName = this.entry?.moduleName || '';
    if (AppManager.getInstance().isAppDisables(bundleName, moduleName)) {
      return false;
    }
    return true;
  }

  private isButton2Enabled(): boolean {
    const bundleName = this.entry?.name || '';
    const moduleName = this.entry?.moduleName || '';
    if (AppManager.getInstance().isAppForceStop(bundleName, moduleName)) {
      return false;
    }
    return this.isRunnable;
  }
}
