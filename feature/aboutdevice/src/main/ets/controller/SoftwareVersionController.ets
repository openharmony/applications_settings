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

import uiAppearance from '@ohos.uiAppearance';
import promptAction from '@ohos.promptAction';
import power from '@ohos.power';
import { SystemParamUtil } from '@ohos/settings.common/src/main/ets/utils/SystemParamUtil';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { HiSysAboutDeviceEventGroup,
  HiSysAboutSystemSettingsEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { AccountUtil } from '@ohos/settings.common/src/main/ets/utils/AccountUtil';
import { CommonUtils } from '@ohos/settings.common/src/main/ets/utils/CommonUtils';
import { PasswordUtil } from '@ohos/settings.common/src/main/ets/utils/PasswordUtil';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { PackagesConstant } from '@ohos/settings.common/src/main/ets/constant/PackagesConstant';
import { DynamicLoader } from '@ohos/settings.common/src/main/ets/utils/DynamicLoader';
import { PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { SecurityUtil } from '@ohos/settings.common/src/main/ets/utils/SecurityUtil';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import {
  CompCtrlParam,
  ComponentControl,
  SettingBaseModel
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import {
  notifyCompStateChange,
  SettingDialogState,
  SettingResultState,
  SettingStateType
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import {
  ItemResultType,
  SettingItemModel
} from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { PADDING_12 } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { DisplayConstant } from '@ohos/settings.common/src/main/ets/constant/DisplayConstant';
import { SearchDataController } from '@ohos/settings.search/src/main/ets/controller/SearchController';
import {
  CheckPasswordManager,
  CHECK_PASSWORD_SUCCESS_EVENT
} from '@ohos/settings.privacy/src/main/ets/CheckPasswordManager';
import { PasswordResolveInfoManager } from '@ohos/settings.privacy/src/main/ets/PasswordResolveInfoManager';
import { EventResultConsts } from '@ohos/settings.common/src/main/ets/systemEvent/EventResultConsts';
import { OpenDevelopModeDialogContent } from '../view/OpenDevelopModeDialogContent';
import { AboutDeviceUtils } from '../utils/AboutDeviceUtils';
import DeveloperModeLock from './DeveloperModeLock';
import { LanguageUtils } from '@ohos/settings.common/src/main/ets/utils/LanguageUtils';

const TAG: string = `SoftwareVersionController`;
const DISALLOW_DEV_MODE_PARAM_KEY: string = 'persist.edm.developer_mode_disallowed';
const START_DEVELOP_MODE: string = 'startDevelopMode';
const DEV_LOCKED: number = 5;
let pwdResolveInfoManager: PasswordResolveInfoManager | null = PasswordResolveInfoManager.getInstance();

interface CheckPsdParams {
  source: string;
  nextUrl: string;
  dynamic?: boolean;
}

@Builder
function dialogBuilder(param: object): void {
  OpenDevelopModeDialogContent();
}

export class SoftwareVersionController implements ComponentControl {
  private compId: string = '';
  private displayVersion: string = '';
  private developerStatus: string = SystemParamUtil.getParam('const.security.developermode.state', '0');
  private securityStatus: string = SystemParamUtil.getParam('ohos.boot.advsecmode.state', '0');
  private clickThrough: number = 1;
  private maximum: number = 7;
  private checkPasswordManager: CheckPasswordManager = new CheckPasswordManager();

  init(compParam: CompCtrlParam): void {
    LogUtil.showInfo(TAG, 'on init');
    this.compId = compParam.compId;
    this.displayVersion = this.getFinalVersion();
    this.refreshUi(this.displayVersion);
    if (DeviceUtil.isDevicePc()) {
      this.checkPasswordManager.init(compParam, START_DEVELOP_MODE);
      EventBus.getInstance().on(CHECK_PASSWORD_SUCCESS_EVENT, this.checkPasswordSuccessEventCallback);
    }
  }

  destroy(): void {
    LogUtil.showInfo(TAG, 'on destroy');
    this.checkPasswordManager.destroy();
  }

  // instrument ignore next
  private checkPasswordSuccessEventCallback = async (data?: string) => {
    LogUtil.showInfo(TAG, `countdownDialogEventCallback, ${data}`);
    if (data === START_DEVELOP_MODE) {
      await this.setDeveloperModeHasPinPassword();
      LogUtil.info(`${TAG} enable developer mode, reboot now`);
      HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysAboutSystemSettingsEventGroup.DEVELOPER_MODE_SWITCH,
        EventResultConsts.SWITCH_ON);
      this.setReboot();
    }
  };

  onClick(component: SettingBaseModel): void {
    HiSysEventUtil.reportDefaultBehaviorEvent(HiSysAboutDeviceEventGroup.CLICK_VERSION);
    LogUtil.info(`${TAG}, clickThrough: ${this.clickThrough} securityStatus:${this.securityStatus}`);
    if (this.clickThrough >= this.maximum) {
      /* instrument ignore if*/
      if (DeviceUtil.isDevicePad() || DeviceUtil.isDevicePhone() || DeviceUtil.isFoldFold()) {
        this.dealClickVersionEvent();
        return;
      }
      this.switchDeveloperMode();
    } else {
      this.clickThrough++;
    }
  }

  private refreshUi(result: string): void {
    notifyCompStateChange(`${this.compId}`,
      new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
        {
          type: ItemResultType.RESULT_TYPE_TEXT,
          result: { content: result }
        } as SettingResultState]]
      )
    );
  }

  private getFinalVersion(): string {
    let version: string = this.getDisplayVersion();
    let newVersion: string = version.replace('(', ' (').replace(')', ') ').trim();
    if (!LanguageUtils.isLtrDirection()) {
      newVersion = '\u202A' + newVersion + '\u202C';
    }
    return newVersion;
  }

  private getDisplayVersion(): string {
    return AboutDeviceUtils.getSoftwareVersion();
  }

  private dealClickVersionEvent(): void {
    LogUtil.info(`${TAG} dealClickVersionEvent developmode:${this.developerStatus}`);
    AccountUtil.isCurrentPrivate().then((isCurrentPrivateUser) => {
      if (isCurrentPrivateUser) {
        LogUtil.info(`${TAG} current private user, not response.`);
        HiSysEventUtil.reportDefaultBehaviorEvent(HiSysAboutDeviceEventGroup.ENTER_PRIVATE_USER_CLICK_VERSION);
        this.clickThrough = 1;
        return;
      }
      this.switchDeveloperMode();
    });
  }

  private switchDeveloperMode(): void {
    LogUtil.info(`${TAG} switchDeveloperMode`);
    if (this.developerStatus !== 'true') {
      const disallowDevMode: string = SystemParamUtil.getParam(DISALLOW_DEV_MODE_PARAM_KEY, 'false');
      if (disallowDevMode === 'true') {
        LogUtil.info(`${TAG} switchDeveloperMode skipped`);
        this.openToast($r('app.string.enterprise_disable_developer_options_toast'));
      } else if (this.securityStatus && this.securityStatus !== '0') {
        this.alertSecurityDialog();
      } else {
        this.openSwitchDialog();
      }
    } else {
      this.openToast($r('app.string.developer_options_enabled_toast'));
    }
    this.clickThrough = 1;
  }

  private alertSecurityDialog(): void {
    AlertDialog.show(
      {
        title: $r('app.string.security_dialog_title'),
        message: $r('app.string.security_dialog_message'),
        autoCancel: false,
        alignment: DialogAlignment.Center,
        isModal: true,
        primaryButton: {
          value: $r('app.string.button_title_ok'),
          fontColor: $r('sys.color.font_emphasize'),
          backgroundColor: Color.Transparent,
          action: () => {
          }
        },
        cancel: () => {
        }
      }
    )
  }

  /**
   * 获取字体大小
   */
  private getFontScale(): number {
    try {
      let fontScale: number = uiAppearance.getFontScale();
      return fontScale;
    } catch (err) {
      LogUtil.error(`${TAG} getFontScale fail ${err?.code} msg:${err?.message}`);
      return DisplayConstant.TEXT_FONT_SIZE_NORMAL;
    }
  }

  // instrument ignore next
  private openSwitchDialog(): void {
    let fontScale: number = this.getFontScale();
    LogUtil.info(`${TAG} openDialog fontScale is ${fontScale}`);
    if (fontScale > DisplayConstant.TEXT_FONT_SIZE_LARGE) {
      notifyCompStateChange('AboutDevice.version_info_group.software_version',
        new Map<SettingStateType, SettingDialogState>([[SettingStateType.STATE_TYPE_ITEM_DIALOG,
          {
            title: $r('app.string.open_developer_mode'),
            contentBuilder: wrapBuilder(dialogBuilder),
            buttons: [
              {
                value: $r('app.string.confirm_on'),
                action: (component: SettingItemModel) => {
                  LogUtil.showInfo(TAG, `developer mode dialog confirm`);
                  if (DeviceUtil.isDevicePc()) {
                    this.resetPcConfirm(component);
                  } else {
                    this.resetPhoneConfirm(component);
                  }
                },
                style: {
                  buttonStyle: ButtonStyleMode.TEXTUAL,
                  fontColor: $r('sys.color.warning'),
                  role: ButtonRole.ERROR
                }
              },
              {
                value: $r('app.string.dialog_cancel'),
                action: () => {
                  LogUtil.showInfo(TAG, 'develop mode dialog close');
                },
                style: {
                  buttonStyle: ButtonStyleMode.TEXTUAL,
                  fontColor: $r('sys.color.font_emphasize'),
                }
              },
            ],
            buttonVertical: false,
            style: {
              autoCancel: false,
              padding: {
                top: PADDING_12,
              }
            }
          } as SettingDialogState]]
        )
      );
    } else {
      notifyCompStateChange('AboutDevice.version_info_group.software_version',
        new Map<SettingStateType, SettingDialogState>([[SettingStateType.STATE_TYPE_ITEM_DIALOG,
          {
            title: $r('app.string.open_developer_mode'),
            contentBuilder: wrapBuilder(dialogBuilder),
            buttons: [
              {
                value: $r('app.string.dialog_cancel'),
                action: () => {
                  LogUtil.showInfo(TAG, 'develop mode dialog close');
                },
                style: {
                  buttonStyle: ButtonStyleMode.TEXTUAL,
                  fontColor: $r('sys.color.font_emphasize'),
                }
              },
              {
                value: $r('app.string.confirm_on'),
                action: (component: SettingItemModel) => {
                  LogUtil.showInfo(TAG, `developer mode dialog confirm`);
                  if (DeviceUtil.isDevicePc()) {
                    this.resetPcConfirm(component);
                  } else {
                    this.resetPhoneConfirm(component);
                  }
                },
                style: {
                  buttonStyle: ButtonStyleMode.TEXTUAL,
                  fontColor: $r('sys.color.warning'),
                  role: ButtonRole.ERROR
                }
              }
            ],
            buttonVertical: true,
            style: {
              autoCancel: false,
              padding: {
                top: PADDING_12,
              }
            }
          } as SettingDialogState]]
        )
      );
    }
  }

  // instrument ignore next
  private resetPcConfirm(param: object): void {
    LogUtil.showInfo(TAG, 'resetPhoneConfirm');
    PasswordUtil.hasPinPassword(async (hasPinPassword) => {
      LogUtil.info(`${TAG} hasPinPassword: ${hasPinPassword}`);
      if (hasPinPassword) {
        this.checkPasswordManager.openCheckLockScreenPasswordDialog();
      } else {
        await this.setDeveloperMode();
        LogUtil.info(`${TAG} enable developer mode, reboot now`);
        HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysAboutSystemSettingsEventGroup.DEVELOPER_MODE_SWITCH,
          EventResultConsts.SWITCH_ON);
        this.setReboot();
      }
    });
  }

  // instrument ignore next
  private resetPhoneConfirm(param: object): void {
    LogUtil.showInfo(TAG, 'resetPhoneConfirm');
    PasswordUtil.hasPinPassword(async (hasPinPassword) => {
      if (hasPinPassword) {
        let params: CheckPsdParams = {
          source: 'verify_password',
          nextUrl: NavEntryKey.ABOUT_DEVICE_ENTRY, dynamic: true
        };
        let pathInfoStack: NavPathStack | undefined =
          AppStorage.get<NavPathStack>(PackagesConstant.SETTINGS_PATH_STACK);
        if (!CommonUtils.isPageExist(NavEntryKey.CHECK_PSD_ENTRY)) {
          DynamicLoader.getInstance().fire(NavEntryKey.CHECK_PSD_ENTRY).then(() => {
            pathInfoStack?.pushPathByName(NavEntryKey.CHECK_PSD_ENTRY, new PushParam(params));
          });
        }
      } else {
        let ret: number = await this.setDeveloperMode();
        if (ret === DEV_LOCKED) {
          let developerModeLock: DeveloperModeLock = new DeveloperModeLock();
          developerModeLock.openDeveloperModeLockDialog();
        } else {
          setTimeout(() => {
            this.setReboot();
          }, 2000);
        }
      }
    })
  }

  // instrument ignore next
  private setReboot(): void {
    LogUtil.info(`${TAG} enable developer mode, reboot now`);
    try {
      power.reboot('reboot_test');
    } catch (err) {
      LogUtil.error(`${TAG} reboot failed, msg: ${err.message}, code: ${err.code}`)
    }
  }

  private async setDeveloperModeHasPinPassword(): Promise<void> {
    await SearchDataController.getInstance().updateChildItemSearchStatus('developer_options', true, ['debug_outer_app']);
    let authToken: string = pwdResolveInfoManager?.getGlobalPinToken() as string;
    await SecurityUtil.setDevelopModeNew(1, authToken);
  }

  private async setDeveloperMode(): Promise<number> {
    await SearchDataController.getInstance().updateChildItemSearchStatus('developer_options', true, ['debug_outer_app']);
    return await SecurityUtil.setDevelopMode(1);
  }

  private openToast(message: ResourceStr): void {
    LogUtil.info(`${TAG} openToast`);
    try {
      promptAction.showToast({
        message: message,
      });
    } catch (err) {
      LogUtil.info(`${TAG} showToast args error code: ${err?.code}, message: ${err?.message}`);
    }
  }
}