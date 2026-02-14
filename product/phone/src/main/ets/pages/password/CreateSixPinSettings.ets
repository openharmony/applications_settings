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

import { AlertDialog } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { Params, PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { CreateSixPinPage } from './model/CreateSixPinPage';
import { PinAuthUtil } from '@ohos/settings.privacy/src/main/ets/PinAuthUtil';
import window from '@ohos.window';
import UIExtensionContentSession from '@ohos.app.ability.UIExtensionContentSession';
import { PageRoot } from '@ohos/settings.common/src/main/ets/core/viewmodel/PageViewModel';
import { PageLifecycleOwner } from '@ohos/settings.common/src/main/ets/core/lifecycle/Lifecycle';
import { MenuPageComponent } from '@ohos/settings.uikit/src/main/ets/component/MenuPageComponent';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { AccessibilityLevelType } from '@ohos/settings.common/src/main/ets/utils/AccessibilityUtils';
import { AbilityUtils } from '@ohos/settings.common/src/main/ets/utils/AbilityUtils';
import { PasswordUtil } from '@ohos/settings.common/src/main/ets/utils/PasswordUtil';
import { WindowManager } from '@ohos/settings.common/src/main/ets/window/WindowManager';
import { AbilityContextManager } from '@ohos/settings.common/src/main/ets/ability/AbilityContextManager';
import { KeyboardAvoidMode } from '@ohos.arkui.UIContext';
import { WalletManageUtils } from '@ohos/settings.common/src/main/ets/utils/WalletManageUtils';
import { PasswordRiskDialogManager } from './model/PasswordRiskDialogManager';
import BiometricsDisable from '../../Setting/Biometrics/mdm/BiometricsDisable';
import { CHANGE_PASSWORD_ENTRY_FLAG } from './controller/PasswordEntryController';
import PageOperation from '../../Setting/Biometrics/utils/PageOperation';
import PageData from '../../Setting/Biometrics/utils/PageData';
/* instrument ignore file */

/**
 * 创建6位数字锁屏密码
 *
 * @since 2023-01-10
 */
@Builder
export function CreateSixPinSettingsLoader($$: Params): void {
  CreateSixPinSettings({ params: $$ as Object as PushParam });
}

const PASSWORD_INPUT_KEY: string = 'PasswdTextInputKey_six_pin_circle_key';
const RESULT_CODE: number = -1;

@Component
export struct CreateSixPinSettings {
  private TAG: string = 'CreateSixPinSettings : ';
  pageRoot: PageRoot = new PageRoot(new PageLifecycleOwner);
  @Consume('pathInfos') pathInfos: NavPathStack;
  @State params: PushParam | null = null;
  @State isDisableAccessibility: boolean = false;
  @State pageData: PageData = new PageData(
    PageOperation.firstEntryPage ? NavigationSystemTransitionType.TITLE : NavigationSystemTransitionType.DEFAULT);
  private riskCustomDialog: CustomDialogController | undefined = undefined;
  private isDialogShowInSubWindow: boolean = true;

  build() {
    NavDestination() {
      Column() {
        MenuPageComponent({ menuPage: this.pageRoot.menuPage, isDialogShowInSubWindow: this.isDialogShowInSubWindow });
      }
      .size({ width: '100%', height: '100%' })
    }
    .accessibilityLevel(
      this.isDisableAccessibility ? AccessibilityLevelType.NO_HIDE_DESCENDANTS : AccessibilityLevelType.YES)
    .title(this.pageData.getTitle())
    // .titleBar(this.pageData.getTitleBarData())
    .systemTransition(this.pageData.transitionType)
    .backgroundColor($r('sys.color.ohos_id_color_titlebar_sub_bg'))
    .onShown(() => {
      this.pageData.setTransitionType(NavigationSystemTransitionType.DEFAULT);
      this.onPageShow();
    })
    .onHidden(() => {
      this.onPageHide();
    })
    .onBackPressed(() => {
      this.pageData.setTransitionType(NavigationSystemTransitionType.TITLE);
      return PageOperation.back(this.params, this.pathInfos);
    })
    // .titleMode(this.pageData.titleMode)
  }

  private getTitle(): Resource {
    let title = $r('app.string.set_lock_screen_pin_title');
    if ((this.params?.config as Record<string, string>)?.source === CHANGE_PASSWORD_ENTRY_FLAG) {
      title = $r('app.string.set_new_lock_screen_password_title');
    }
    return title;
  }

  aboutToAppear(): void {
    if (BiometricsDisable.getInstance().getDisable()) {
      const context = AbilityContextManager.getMainAbilityContext();
      if (context) {
        BiometricsDisable.getInstance().disableToastHandler(context as common.UIAbilityContext, undefined, true);
        this.back();
      }
      LogUtil.warn(`${this.TAG} password disable`);
      return;
    }
    LogUtil.info(`${this.TAG} aboutToAppear`);
    this.pageData.initData(this.params, this.getTitle());
    PasswordUtil.setWindowPrivacyMode((AppStorage.get<window.WindowStage>('windowStage') as
    window.WindowStage), true);
    this.pageRoot.aboutToAppear(new CreateSixPinPage(this.pathInfos, this.params as PushParam));
    LogUtil.info(`${this.TAG} isDialogShowInSubWindow value is ${this.isDialogShowInSubWindow}`);
    this.isDialogShowInSubWindow = PinAuthUtil.isDialogShowInSubWindow(this.params);
    if (PasswordRiskDialogManager.getRiskDialogOpen()) {
      this.isDisableAccessibility = true;
      this.openRiskDialog();
    }
  }

  aboutToDisappear(): void {
    LogUtil.info(`${this.TAG} aboutToDisappear`);
    this.pageRoot.aboutToDisappear();
    PasswordUtil.setWindowNonPrivacyModeIfNeed((AppStorage.get<window.WindowStage>('windowStage') as
    window.WindowStage), this.pathInfos);
    this.riskCustomDialog?.close();
    PasswordRiskDialogManager.setRiskDialogOpen(true);
  }

  private focus = (): void => {
    try {
      this.isDisableAccessibility = false;
      focusControl.requestFocus(PASSWORD_INPUT_KEY);
    } catch (e) {
      LogUtil.error(`${this.TAG} Focus error.`);
    }
  }

  back(): void {
    WalletManageUtils.sendAbilityResultToWallet(RESULT_CODE);
    this.pathInfos?.pop();
    AbilityUtils.closeUiExtension(AppStorage.get<UIExtensionContentSession>('uiExtensionContentSession'), RESULT_CODE);
  }

  openRiskDialog(): void {
    this.riskCustomDialog = new CustomDialogController({
      builder: AlertDialog({
        primaryTitle: $r('app.string.pw_not_retrieve'),
        content: $r('app.string.pw_remember'),
        primaryButton: {
          value: $r('app.string.not_set_temporarily'),
          action: () => {
            this.back();
          }
        },
        secondaryButton: {
          value: $r('app.string.got_it'),
          action: this.focus
        }
      }),
      cancel: this.focus,
      showInSubWindow: PasswordRiskDialogManager.getExternalRiskDialogOpen()
    });
    this.riskCustomDialog.open();
  }

  onPageShow(): void {
    LogUtil.info(`${this.TAG} onPageShow`);
    this.pageRoot.onPageShow();
    WindowManager.getInstance().setKeyboardAvoidMode(KeyboardAvoidMode.RESIZE);
  }

  onPageHide(): void {
    LogUtil.info(`${this.TAG} onPageHide`);
    this.pageRoot.onPageHide();
    WindowManager.getInstance().setKeyboardAvoidMode(KeyboardAvoidMode.OFFSET);
    PageOperation.firstEntryPage = false;
  }
}