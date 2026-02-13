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

import display from '@ohos.display';
import { TextModifier } from '@kit.ArkUI';
import { AlertDialog, CustomContentDialog } from '@ohos.arkui.advanced.Dialog';
import { BusinessError, commonEventManager as CEM } from '@kit.BasicServicesKit';
import common from '@ohos.app.ability.common';
import { AbilityContextManager } from '@ohos/settings.common/src/main/ets/ability/AbilityContextManager';
import { LengthMetrics } from '@ohos.arkui.node';
import emitter from '@ohos.events.emitter';
import Settings from '@ohos.settings';
import window from '@ohos.window';
import SecurityContext from '@ohos/settings.common/src/main/ets/context/SecurityContext';
import { Controller, Params, PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { ButtonMenuController } from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import { DisplayUtils } from '@ohos/settings.common/src/main/ets/utils/DisplayUtils';
import { PageLifecycleOwner } from '@ohos/settings.common/src/main/ets/core/lifecycle/Lifecycle';
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { PageRoot } from '@ohos/settings.common/src/main/ets/core/viewmodel/PageViewModel';
import {
  CREATE_USER_CREDENTIAL,
  EventPool,
  UPDATE_USER_CREDENTIAL
} from '@ohos/settings.common/src/main/ets/event/EventPool';
import { EVENT_ID_ON_WINDOW_STAGE_CHANGED,
  EVENT_ID_ON_WINDOW_STAGE_CHANGED_FOR_PRIVATE_PIN } from '@ohos/settings.common/src/main/ets/event/types';
import { PasswordManager } from '@ohos/settings.common/src/main/ets/passwordManager/PasswordManager';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { DynamicLoader } from '@ohos/settings.common/src/main/ets/utils/DynamicLoader';
import {
  HiSysEventUtil
} from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { FINGERPRINT_CRED_TYPE, PasswordUtil, PinSubType } from '@ohos/settings.common/src/main/ets/utils/PasswordUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { MenuPageComponent } from '@ohos/settings.uikit/src/main/ets/component/MenuPageComponent';
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';
import { AccountUtil } from '@ohos/settings.common/src/main/ets/utils/AccountUtil';
import { FingerprintInfo } from '@ohos/settings.common/src/main/ets/data/types';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { PageRouter } from '@ohos/settings.common/src/main/ets/framework/common/PageRouter';
import { SearchDataController } from '@ohos/settings.search/src/main/ets/controller/SearchController';
import { BiometricsAndPasswordPage } from './model/BiometricsAndPasswordPage';
import { DialogController } from '../password/controller/DialogController';
import { HiSysBiometricsPasswordEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import BiometricsDisable from '../../Setting/Biometrics/mdm/BiometricsDisable';

/* instrument ignore file */
const TAG: string = 'BiometricsAndPasswordSettings : ';
const RANDOM_NUMBER_MAX_SIZE: number = 1000;

/**
 * 主界面一级菜单-生物识别和密码
 *
 * @since 2023-01-07
 */
@Builder
export function BiometricsAndPasswordSettingsLoader($$: Params): void {
  if (LogUtil.printBuilderLog(`${TAG} bio and password settings loader`)) {
    BiometricsAndPasswordSettings();
  }
}

@Component
export struct BiometricsAndPasswordSettings {
  @Consume('pathInfos') pathInfos: NavPathStack;
  @StorageProp('navigationMode') navigationMode: NavigationMode | undefined = NavigationMode.Stack;
  @State params: PushParam | null = null;
  private compId: string = 'nav_biometrics_and_password';
  pageRoot: PageRoot = new PageRoot(new PageLifecycleOwner());
  title: string = ResourceUtil.getStringSync($r('app.string.biometrics_and_password_settings_title'));
  dialogText: string = '';
  dialogController?: CustomDialogController;
  isFromExternal: boolean = false;
  addFingerprintDialogController: CustomDialogController | undefined = undefined;
  outFingerDialogController: CustomDialogController | undefined = undefined;
  pageNavTitleOptions: NavigationTitleOptions =
    {
      paddingStart: LengthMetrics.vp(DeviceUtil.isDevicePhone() ? 16 : 24),
      mainTitleModifier: new TextModifier().id(this.compId + '.title_id')
        .accessibilityRole(AccessibilityRoleType.TITLE_BAR)
    };
  fgArray: FingerprintInfo[] = [];
  private biometricsAndPasswordPage?: BiometricsAndPasswordPage;
  private context = getContext(this) as common.UIAbilityContext;
  private openFingerprintEventId: number = this.getRandomId();

  private getRandomId(): number {
    return Date.now() + Math.round(Math.random() * RANDOM_NUMBER_MAX_SIZE);
  }
  private accountSubscriber?: CEM.CommonEventSubscriber;

  build() {
    NavDestination() {
      Scroll() {
        MenuPageComponent({ menuPage: this.pageRoot.menuPage });
      }
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
      // .clip(false)
    }
    .id(this.compId)
    .hideTitleBar(false)
    .title(this.title)
    // .titleBar({
    //   enableComponentSafeArea: true,
    //   style: {
    //     scrollEffectOpts: {
    //       enableScrollEffect: true
    //     },
    //     scrollEffectStyle: {
    //       backgroundStyle: {
    //         backgroundBrightnessLevel: BackgroundBrightnessLevel.ENHANCED
    //       }
    //     }
    //   },
    //   content: {
    //     title: {
    //       mainTitle: this.title
    //     },
    //   },
    // })
    .hideBackButton(this.navigationMode === NavigationMode.Split && this.pathInfos.size() === 1)
    .backgroundColor($r('sys.color.comp_background_gray'))
    .onShown(() => {
      this.onPageShow();
    })
    .onHidden(() => {
      this.onPageHide();
    })
    .onBackPressed(() => {
      if (this.isFromExternal) {
        LogUtil.info(`${TAG} onBackPressed`);
        this.termiteAbility();
      }
      return this.isFromExternal;
    })
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
    BiometricsDisable.getInstance().disableItems();
    PasswordManager.updateEdmPolicy();
    DialogController.setIsNeedShowDialog(true);
    // ContextManager.setMainAbilityContext(AbilityContextManager.getMainAbilityContext());
    // RouterManager.setPageRouter(PageRouter);
    this.biometricsAndPasswordPage = new BiometricsAndPasswordPage(this.pathInfos, this.params as PushParam);
    this.pageRoot.aboutToAppear(this.biometricsAndPasswordPage);
    // SearchDataControllerManager.setSearchDataManager(SearchDataController.getInstance());
    this.subscribeEvents();
    this.onAccountLogStatusChange();
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
    this.pageRoot.aboutToDisappear();
    this.dialogController?.close();
    this.dialogController = undefined;
    this.unSubscribeEvents();
    SecurityContext.getInstance().emptyPassword();
    this.offAccountStatusChange();
  }

  onPageShow(): void {
    LogUtil.info(`${TAG} onPageShow`);
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysBiometricsPasswordEventGroup.BIOMETRICS_PASSWORD_ENTER);
    if (BiometricsDisable.getInstance().disableItems() && this.biometricsAndPasswordPage) {
      BiometricsDisable.getInstance().refreshMenuDisable(this.biometricsAndPasswordPage);
    }
    this.pageRoot.onPageShow();

    if (DeviceUtil.isDevicePad()) {
      window.getLastWindow(AppStorage.get<Context>('pageContext') as Context)
        .then((lastWindow) => { lastWindow.setPreferredOrientation(window.Orientation.AUTO_ROTATION_RESTRICTED); })
        .catch(() => { LogUtil.info(`${TAG} set screenOritentation false`); })
    }

    // ContextManager.initParametersAsync();
    LogUtil.info(`${TAG} onPageShow end`);
  }

  onPageHide(): void {
    LogUtil.info(`${TAG} onPageHide`);
    this.pageRoot.onPageHide();
    this.outFingerDialogController?.close();
  }

  private async filterFingerprintList(): Promise<void> {
    if (CheckEmptyUtils.isEmptyArr(this.fgArray)) {
      LogUtil.info(`${TAG} fingerprint list is empty`);
      return;
    }
    let isPrivateUser = await AccountUtil.isCurrentPrivate();
    if (isPrivateUser) {
      let userId: number = await AccountUtil.getPrivateSpaceUserId();
      LogUtil.info(`${TAG} filterFingerprintList isPrivateUser`);
      let credInfos: string[] = await PasswordUtil.getUserCredInfos(FINGERPRINT_CRED_TYPE, userId);
      if (CheckEmptyUtils.isEmptyArr(credInfos)) {
        LogUtil.info(`${TAG} privateUser do not has fingerprint`);
        return;
      }
      this.fgArray = this.fgArray.filter((item) => {
        return credInfos.indexOf(item.credential) >= 0;
      });
      return;
    }

    this.fgArray = this.fgArray.filter((item) => {
      return CheckEmptyUtils.checkStrIsEmpty(item.userid);
    });
  }

  pushName(key: string, params: PushParam | null, animated: boolean) {
    DynamicLoader.getInstance().fire(key).then(() => {
      this.pathInfos?.pushPathByName(key, params, animated);
    });
  }


  private subscribeEvents(): void {
    emitter.on({
      eventId: EVENT_ID_ON_WINDOW_STAGE_CHANGED
    }, (event) => {
      LogUtil.info(`${TAG} receive EVENT_ID_ON_WINDOW_STAGE_CHANGED`);
      if (event?.data?.KEY_ID_FINGERPRINT_DB_UPDATE === window.WindowStageEventType.PAUSED) {
        this.fallback();
        this.addFingerprintDialogController?.close();
        this.outFingerDialogController?.close();
        LogUtil.info(`${TAG} after windowStageChange close custom dialog`);
      }
      emitter.emit({eventId: EVENT_ID_ON_WINDOW_STAGE_CHANGED_FOR_PRIVATE_PIN });
    });
  }

  private onAccountLogStatusChange(): void {
    LogUtil.info('onAccountLogStatusChange start');
    const subscribeInfo: CEM.CommonEventSubscribeInfo = {
      events: [ CEM.Support.COMMON_EVENT_DISTRIBUTED_ACCOUNT_LOGOUT,
        CEM.Support.COMMON_EVENT_DISTRIBUTED_ACCOUNT_LOGIN ]
    };

    try {
      CEM.createSubscriber(subscribeInfo)
        .then((commonEventSubscriber: CEM.CommonEventSubscriber) => {
          this.accountSubscriber = commonEventSubscriber;
          CEM.subscribe(this.accountSubscriber, (error: BusinessError, data: CEM.CommonEventData) => {
            if (error) {
              LogUtil.error(`${TAG} Failed to onAccountLogStatusChange, code is ${error?.code}, message is ${error?.message}`);
              return;
            }

            if (data.event === CEM.Support.COMMON_EVENT_DISTRIBUTED_ACCOUNT_LOGOUT ||
              data.event === CEM.Support.COMMON_EVENT_DISTRIBUTED_ACCOUNT_LOGIN) {
              LogUtil.info(`${TAG} account log status changed`);
            }
          });
        })
        .catch((err: BusinessError) => {
          LogUtil.error(`${TAG} Failed to createSubscriber. Code: ${err?.code}, message: ${err?.message}`);
        });
    } catch (e) {
      LogUtil.error(`${TAG} onAccountLogStatusChange failed`);
    }
  }

  private offAccountStatusChange(): void {
    LogUtil.info('offAccountStatusChange start');
    if (!this.accountSubscriber) {
      LogUtil.info('accountSubscriber is unused, no need off.');
      return;
    }

    try {
      CEM.unsubscribe(this.accountSubscriber, (err: BusinessError) => {
        LogUtil.error(`${TAG} failed to unsubscribe, code is: ${err?.code} message is: ${err?.message}`);
      })
    } catch (err) {
      LogUtil.error(`${TAG} failed to offAccountStatusChange, code is: ${err?.code} message is: ${err?.message}`);
    }
  }

  private dealFoldedStateHide(): void {
    const pathNames: string[] = this.pathInfos?.getAllPathName() ?? [];
    if (pathNames.length === 0) {
      return;
    }
    const topName: string = pathNames[pathNames.length - 1];
    if (topName === NavEntryKey.EXTERNAL_SCREEN_FINGERPRINT_ENROLL_ENTRY) {
      LogUtil.info(`${TAG} terminate self`);
      (AbilityContextManager.getMainAbilityContext() as common.UIAbilityContext)?.terminateSelf();
    }
  }

  private fallback(): void {
    const pathNames: string[] = this.pathInfos?.getAllPathName() ?? [];
    if (pathNames.length === 0) {
      return;
    }
    const topName: string = pathNames[pathNames.length - 1];
    LogUtil.info(`${TAG} topName ${topName}`);
    if (topName === NavEntryKey.BIOMETRICS_PASSWORD_ENTRY) {
      return;
    }
    if (topName === NavEntryKey.EXTERNAL_SCREEN_FINGERPRINT_ENROLL_ENTRY &&
      DisplayUtils.getFoldStatus() === display.FoldStatus.FOLD_STATUS_FOLDED) {
      LogUtil.info(`${TAG} no need pop`);
      return;
    }
    if (pathNames.indexOf(NavEntryKey.BIOMETRICS_PASSWORD_ENTRY) >= 0) {
      this.pathInfos?.popToName(NavEntryKey.BIOMETRICS_PASSWORD_ENTRY, false);
    } else {
      this.pushName(NavEntryKey.BIOMETRICS_PASSWORD_ENTRY, null, false);
    }
  }

  private unSubscribeEvents(): void {
    emitter.off(EVENT_ID_ON_WINDOW_STAGE_CHANGED);
    emitter.off(this.openFingerprintEventId);
  }

  private termiteAbility(): void {
    this.context.terminateSelf();
  }
}
