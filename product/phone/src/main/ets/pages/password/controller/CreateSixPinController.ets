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
// import ContextManager from '@hw-hmos/settings-face-auth/src/main/ets/faceauth/Manager/ContextManager';
import UIExtensionContentSession from '@ohos.app.ability.UIExtensionContentSession';
import { AccountConstants } from '@ohos/settings.common/src/main/ets/constant/AccountConstants';
import { AuthConstant } from '@ohos/settings.common/src/main/ets/constant/AuthConstant';
import { Constants } from '@ohos/settings.common/src/main/ets/constant/PackagesConstant';
import SecurityContext from '@ohos/settings.common/src/main/ets/context/SecurityContext';
import { Controller } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import {
  PageLifecycleMenuGroupController
} from '@ohos/settings.common/src/main/ets/core/controller/LifecycleMenuController';
import {
  ButtonMenuController,
  DialogButtonMenuController,
  MenuController,
  PasswordCircleController,
  UnRespondTouchController
} from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import { DialogLifecycleObserverInterface } from '@ohos/settings.common/src/main/ets/core/lifecycle/Lifecycle';
import { Style } from '@ohos/settings.common/src/main/ets/core/model/menu/ComponetStyle';
import {
  ControllerConstructorInter,
  SettingsBaseMenu
} from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import {
  CREATE_USER_CREDENTIAL,
  EventPool,
  UPDATE_USER_CREDENTIAL
} from '@ohos/settings.common/src/main/ets/event/EventPool';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import {
  HiSysBiometricsPasswordEventGroup,
  HiSysPasswordRelatedEventGroup
} from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { HiSysEventUtil, } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { AbilityUtils } from '@ohos/settings.common/src/main/ets/utils/AbilityUtils';
import { AccessibilityUtils } from '@ohos/settings.common/src/main/ets/utils/AccessibilityUtils';
import { AccountUtil } from '@ohos/settings.common/src/main/ets/utils/AccountUtil';
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';
import { BACK_ENTRY, NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { PasswordUtil, PinSubType, ResultCode } from '@ohos/settings.common/src/main/ets/utils/PasswordUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { ToastUtil } from '@ohos/settings.common/src/main/ets/utils/ToastUtil';
import { WalletManageUtils } from '@ohos/settings.common/src/main/ets/utils/WalletManageUtils';
import { PinAuthUtil } from '@ohos/settings.privacy/src/main/ets/PinAuthUtil';
import { SearchDataController } from '@ohos/settings.search/src/main/ets/controller/SearchController';
import {
  ButtonMenu,
  DialogPage,
  DialogTitleMenu,
  DividerMenuGroup,
  NavigationEntry
} from '@ohos/settings.uikit/src/main/ets/menus/Menu';
import { CheckPsdParams } from '../model/CheckPasswordPage';
import {
  CREATE_PASSWORD_ENTRY_FACE_FLAG,
  CREATE_PASSWORD_ENTRY_FLAG,
  isFaceOrFingerprint,
  PRIVACY_CENTER_CREATE_PASSWORD_ENTRY
} from '../model/CreatePsdPage';
import { SafeTipsDialogPage } from '../model/CreateSafeTipsDialogPage';

import { SIX_PIN_CIRCLE_KEY } from '../model/CreateSixPinPage';
import { PasswordRiskDialogManager } from '../model/PasswordRiskDialogManager';
import { ChangeToFourTypeController } from './ChangeToFourTypeController';
import { CustomButtonMenuStyle } from './CreateNumberPsdController';
import { DialogController } from './DialogController';
import {
  CHANGE_PASSWORD_ENTRY_FLAG,
  ChangePasswordTypeDialogPageStyle,
  ChangePasswordTypeDividerGroupStyle,
  ChangePasswordTypeStyle,
  ChangePasswordTypeTitleStyle
} from './PasswordEntryController';
import { PasswordToastController } from './PasswordToastController';

export const SIX_PIN_LENGTH: number = 6;

const ENTER_THE_PIN_AGAIN: string = 'enter_the_pin_again';
const PIN_REPEAT_ERROR: string = 'pin_repeat_error';
const PIN_REPEAT_WITH_MAIN: string = 'pin_repeat_with_main';
const PIN_REPEAT_WITH_PRIVATE: string = 'pin_repeat_with_private';
const REMEMBER_PIN_TIP: string = 'remember_pin_tip';

export const CHANGE_PASSWORD_TYPE_BUTTON: string = 'change_password_type_button';

export const SIX_DIGIT_PIN_TYPE_ENTRY: string = 'six_digit_pin_type_entry';

export const PASSWORD_INPUT_KEY: string = 'PasswdTextInputKey_six_pin_circle_key';

const INPUT_CHECK_DELAY: number = 50;
// 延迟播报时间
const DELAYED_ANNOUNCE: number = 350;
// 96小时口令重置tip
const EXPIRE_PRE_PIN: string = '96';

/**
 * 创建6位数字密码页面控制器类
 *
 * @since 2023-01-07
 */
@Observed
export class CreateSixPinPageController extends PageLifecycleMenuGroupController {
  public tag: string = 'CreateSixPinPageController : ';

  constructor(menu: SettingsBaseMenu) {
    super(menu);
    this.menu.title = this.isFromCheckPage() ? $r('app.string.set_new_lock_screen_password_title') :
    $r('app.string.set_lock_screen_pin_title');
  }

  static CreateCreateSixPinPageController(menu: SettingsBaseMenu): Controller {
    return new CreateSixPinPageController(menu);
  }

  isFromCheckPage(): boolean {
    return (this.menu.navRouterParam?.config as CheckPsdParams)?.source === CHANGE_PASSWORD_ENTRY_FLAG;
  }

  aboutToAppear(): void {
    super.aboutToAppear();
  }

  aboutToDisappear(): void {
    super.aboutToDisappear();
  }

  onPageShow(): void {
    LogUtil.info(`${this.tag} onPageShow`);
  }

  onPageHide(): void {
    LogUtil.info(`${this.tag} onPageHide`);
  }
}

/**
 * 密码信息控制器类
 *
 * @since 2023-01-10
 */
@Observed
export class SixPinMessageController extends UnRespondTouchController {
  public tag: string = 'SixPinMessageController : ';

  constructor(menu: SettingsBaseMenu) {
    super(menu);
  }

  static CreateSixPinMessageController(menu: SettingsBaseMenu): Controller {
    return new SixPinMessageController(menu);
  }

  aboutToAppear(): void {
    super.aboutToAppear();
  }

  aboutToDisappear(): void {
    super.aboutToDisappear();
  }

  registerDataChange(): void {
    LogUtil.info(`${this.tag} registerDataChange`);
    this.registerControllerDataChange(SIX_PIN_CIRCLE_KEY);
  }

  unRegisterDataChange(): void {
    LogUtil.info(`${this.tag} unRegisterDataChange`);
    this.unRegisterControllerDataChange(SIX_PIN_CIRCLE_KEY);
  }

  onDataChange(fromKey: string, data: string): void {
    if (fromKey !== SIX_PIN_CIRCLE_KEY) {
      LogUtil.info(`${this.tag} onDataChange fromKey not in page`);
      return;
    }
    if (data === ENTER_THE_PIN_AGAIN) {
      this.menu.title = $r('app.string.enter_pin_again_title');
      this.refreshUi();
      AccessibilityUtils.delayedAnnounceText(this.menu.title, DELAYED_ANNOUNCE);
      return;
    }
  }
}

/**
 * 6位密码圆圈菜单控制器类
 *
 * @since 2023-01-10
 */
@Observed
export class SixPinCircleController extends PasswordCircleController implements DialogLifecycleObserverInterface {
  public tag: string = 'SixPinCircleController : ';
  private password: string = '';
  private firstPassword: string = '';
  private passwordCircle: string[] = ['', '', '', '', '', ''];
  private isInputFirstTime: boolean = true;
  private sourceFlag: string = '';
  private challenge: string = '';
  private isHighSecurity: boolean = false;
  private hasSession: boolean = false;

  constructor(menu: SettingsBaseMenu) {
    super(menu);
    if (menu.navRouterParam?.config) {
      this.challenge = (menu.navRouterParam?.config as Record<string, string>)[AuthConstant.CHALLENGE];
      const hasSession = (menu.navRouterParam?.config as Record<string, boolean>)[AuthConstant.HAS_SESSION];
      if (hasSession) {
        this.hasSession = hasSession;
      }
      LogUtil.info(`${this.tag} init push params, ${this.challenge}.`);
    }
    this.isHighSecurity = WalletManageUtils.checkIfHighSecurity();
    LogUtil.info(`${this.tag} isHighSecurity is set to ${this.isHighSecurity}`);
  }

  static CreateSixPinCircleController(menu: SettingsBaseMenu): Controller {
    return new SixPinCircleController(menu);
  }

  onDialogOpen(key?: string, data?: Object): void {
    LogUtil.info(`${this.tag} onDialogOpen`);
  }

  onDialogClose(key?: string, data?: Object): void {
    LogUtil.info(`${this.tag} onDialogClose.`);
    if (data === Constants.continueAnyWay) {
      this.inputFinish();
    } else if (data === Constants.repeatPinInput) {
      this.clearInput();
    }
  }

  onDialogCancel(key?: string, data?: Object): void {
    LogUtil.info(`${this.tag} onDialogCancel`);
    this.clearInput();
  }

  public getObserverKey = (): string => {
    LogUtil.info(`${this.tag} getObserverKey`);
    return this.menu?.key as string;
  }

  aboutToAppear(): void {
    super.aboutToAppear();
    this.initSourceFlag();
    if (this.isFocus()) {
      setTimeout(() => {
        focusControl.requestFocus(PASSWORD_INPUT_KEY);
      }, 300);
    }
  }

  aboutToDisappear(): void {
    super.aboutToDisappear();
    this.challenge = '';
  }

  unsubscribe(): void {
    PasswordUtil.unregisterInputer();
  };

  initSourceFlag(): void {
    let params = this.menu.navRouterParam?.config;
    let sourceFlag = '';
    if (params) {
      sourceFlag = (params as CheckPsdParams).source;
    }
    if (!sourceFlag) {
      LogUtil.info(`${this.tag} getSourceFlag Router params invalid `);
      return;
    }
    this.sourceFlag = sourceFlag;
  }

  onTextInputChange(value: string): void {
    this.password = value;
    if (value.length > SIX_PIN_LENGTH) {
      return;
    }
    let length = value.length;
    for (let i = 0; i < SIX_PIN_LENGTH; i++) {
      if (i < length) {
        this.passwordCircle[i] = value[i];
      } else {
        this.passwordCircle[i] = '';
      }
    }
    if (PasswordUtil.isPinNumber6(this.password)) {
      if (PasswordUtil.isWeakPasswords(this.password) && this.isInputFirstTime) {
        this.openSafeTipsDialog();
      } else {
        this.inputFinish();
      }
    }
  }

  private openSafeTipsDialog(): void {
    SafeTipsDialogPage.createSafeTipsDialog(this, this.isHighSecurity);
  }

  private async inputFinish(): Promise<void> {
    LogUtil.info(`${this.tag} inputFinish in`);
    if (!this.password) {
      LogUtil.info(`${this.tag} inputFinish return : password is none`);
      return;
    }
    if (this.isInputFirstTime) {
      this.firstInputFinish();
    } else {
      if (this.password !== this.firstPassword) {
        setTimeout(() => {
          this.clearInput();
          LogUtil.info(`${this.tag} inputFinish : not match`);
          this.publishDataChange(PIN_REPEAT_ERROR);
        }, INPUT_CHECK_DELAY);
      } else {
        HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysPasswordRelatedEventGroup.SET_IDENTIFY_CLOSURE_TYPE);
        PasswordUtil.hasPinPassword((hasPinPassword) => {
          if (hasPinPassword) {
            this.updatePin();
          } else {
            this.createPin();
          }
        });
      }
    }
    LogUtil.info(`${this.tag} inputFinish out`);
  }

  isFocus(): boolean {
    return !PasswordRiskDialogManager.getRiskDialogOpen();
  }

  clearInput(): void {
    this.password = '';
    this.passwordCircle = ['', '', '', '', '', ''];
  }

  updatePin(): void {
    PasswordUtil.registerInputer(PinSubType.PIN_SIX);
    PasswordUtil.updatePassword(PinSubType.PIN_SIX, this.password, SecurityContext.getInstance().getToken(),
      (result, extraInfo) => {
        if (result == ResultCode.SUCCESS) {
          LogUtil.info(this.tag + 'UPDATE_PSD_SUCCESS');
          EventPool.getInstance().publish({
            name: UPDATE_USER_CREDENTIAL,
            param: String(PinSubType.PIN_SIX),
          }).then(() => {
            this.menu.pathInfos?.popToName(NavEntryKey.BIOMETRICS_PASSWORD_ENTRY);
          });
          PasswordUtil.updatePrivateSpacePsd(this.password);
        } else {
          LogUtil.info(`${this.tag} UPDATE_PSD_FAILED, result=${result}`);
          const tipsString: Resource = result === ResultCode.INVALID_TOKEN ? $r('app.string.fp_timeout_content') :
          $r('app.string.secure_chip_pin_set_fail');
          ResourceUtil.getString(tipsString).then(value => {
            ToastUtil.showToast(value, ToastUtil.SHORT_DURATION);
          }).catch(() => {
            LogUtil.error(`${this.tag} ResourceUtil.getString(tipsString) err`);
          });
          this.menu.pathInfos?.popToName(NavEntryKey.BIOMETRICS_PASSWORD_ENTRY);
        }
        AbilityUtils.closeUiExtension(AppStorage.get<UIExtensionContentSession>('uiExtensionContentSession'), result);
        this.unsubscribe();
        PasswordUtil.closeSession();
        WalletManageUtils.sendAbilityResultToWallet(result);
      });
  }

  createPin(): void {
    LogUtil.info(`${this.tag} createPin start`);
    this.unsubscribe();
    PasswordUtil.registerInputer(PinSubType.PIN_SIX);
    if (!this.hasSession) {
      PasswordUtil.openSession(() => {
        PasswordUtil.createPassword(PinSubType.PIN_SIX, this.password, (result) => {
          this.processResult(result);
          WalletManageUtils.sendAbilityResultToWallet(result);
        });
      });
    } else {
      PasswordUtil.createPassword(PinSubType.PIN_SIX, this.password, (result) => {
        this.processResult(result);
        WalletManageUtils.sendAbilityResultToWallet(result);
      });
    }
  }

  private async firstInputFinish(): Promise<void> {
    LogUtil.info(`${this.tag} firstInputFinish`);
    let privateUserId: number = await AccountUtil.getPrivateSpaceUserId();
    if (privateUserId !== AccountConstants.INVALID_PRIVATE_SPACE_USER_ID) {
      // 存在隐私用户
      let isCurrentPrivate: boolean = await AccountUtil.isCurrentPrivate();
      LogUtil.info(`${this.tag} has private user update`);
      let userId: number = isCurrentPrivate ? AccountConstants.MAIN_USER : privateUserId;
      PasswordUtil.checkUserPassword(PinSubType.PIN_SIX, userId, this.password, (isSuccess: boolean) => {
        LogUtil.info(`${this.tag} same with cross user ${isCurrentPrivate} ${isSuccess}`);
        if (isSuccess) {
          this.crossUserAuthSuccessTip(isCurrentPrivate);
          return;
        }
        LogUtil.info(`${this.tag} not same with cross user`);
        this.doPublishDataChange();
        this.publishDataChange(REMEMBER_PIN_TIP);
      });
      return;
    }
    LogUtil.info(`${this.tag} not exist private user update`);
    this.doPublishDataChange();
  }

  private crossUserAuthSuccessTip(isCurrentPrivate: boolean): void {
    setTimeout(() => {
      this.clearInput();
      this.publishDataChange(isCurrentPrivate ? PIN_REPEAT_WITH_MAIN : PIN_REPEAT_WITH_PRIVATE);
    }, INPUT_CHECK_DELAY);
  }

  private doPublishDataChange(): void {
    this.firstPassword = this.password;
    this.isInputFirstTime = false;
    setTimeout(() => {
      this.clearInput();
      this.publishDataChange(ENTER_THE_PIN_AGAIN);
    }, INPUT_CHECK_DELAY);
  }

  private processResult(result: number): void {
    if (result == ResultCode.SUCCESS) {
      LogUtil.info(`${this.tag} CREATE_PSD_SUCCESS`);
      if (isFaceOrFingerprint(this.sourceFlag) && PasswordUtil.isBiometricsPasswordEntry()) {
        PasswordUtil.closeSession();
        return;
      }
      if (this.sourceFlag === CREATE_PASSWORD_ENTRY_FLAG) {
        LogUtil.info(`${this.tag} fg silent auth begin`);
        PasswordUtil.silenceAuthPin().then(() => {
          LogUtil.info(`${this.tag} fg silent auth success`);
          this.menu.pathInfos?.pop();
          this.menu.pushName(NavEntryKey.FINGERPRINT_SETTING_ENTRY, undefined);
        }).catch(() => {
          LogUtil.error(`${this.tag} fg silent auth failed`);
          if (!this.hasSession) {
            PasswordUtil.closeSession();
          }
        })
      } else if (this.sourceFlag === CREATE_PASSWORD_ENTRY_FACE_FLAG) {
        LogUtil.info(`${this.tag} silent auth begin`);
        PasswordUtil.silenceAuthPin().then(() => {
          LogUtil.info(`${this.tag} silent auth success`);
          // ContextManager.get().setAuthToken(SecurityContext.getInstance().getToken());
          // ContextManager.get().setChallenge(SecurityContext.getInstance().getChallenge());
          this.menu.pathInfos?.pop();
        }).catch(() => {
          LogUtil.error(`${this.tag} silent auth failed`);
          if (!this.hasSession) {
            PasswordUtil.closeSession();
          }
        })
      } else {
        LogUtil.info(`${this.tag} other sourceFlag`);
        if (!CheckEmptyUtils.checkStrIsEmpty(this.challenge)) {
          PinAuthUtil.challenge2Token(this.challenge, result);
          return;
        }
        EventPool.getInstance().publish({
          name: CREATE_USER_CREDENTIAL,
          param: String(PinSubType.PIN_SIX),
        }).then(() => {
          this.menu.pathInfos?.popToName(NavEntryKey.BIOMETRICS_PASSWORD_ENTRY);
        });
      }
      SearchDataController.getInstance().updateChildItemSearchStatus('lock_screen_password', true);
      SearchDataController.getInstance().updateSearchItemStatus('lock_screen_password', false);
    } else {
      LogUtil.info(`${this.tag} CREATE_PSD_FAILED, result=${result}`);
      PasswordToastController.passwordFailToast(result);
      this.menu.pathInfos?.popToName(NavEntryKey.BIOMETRICS_PASSWORD_ENTRY);
    }
    AbilityUtils.closeUiExtension(AppStorage.get<UIExtensionContentSession>('uiExtensionContentSession'), result);
    this.unsubscribe();
  }

  onSubmit(enterKey: EnterKeyType): void {
  }

  getPasswordCircle(): Array<string> {
    return this.passwordCircle;
  }

  getPassword(): string {
    return this.password;
  }
}

/**
 * 警告信息控制器类
 *
 * @since 2023-01-10
 */
@Observed
export class SixPinWarningMessageController extends UnRespondTouchController {
  public tag: string = 'SixPinWarningMessageController : ';

  constructor(menu: SettingsBaseMenu) {
    super(menu);
  }

  static CreateSixPinWarningMessageController(menu: SettingsBaseMenu): Controller {
    return new SixPinWarningMessageController(menu);
  }

  getWarningMessage(): string | Resource {
    let isFromCheckPage: boolean = (this.menu.navRouterParam?.config as CheckPsdParams)?.source ===
      CHANGE_PASSWORD_ENTRY_FLAG;
    let supportNinetySixHoursReset: boolean = PasswordRiskDialogManager.getNinetySixHoursMode();
    return (supportNinetySixHoursReset && isFromCheckPage) ? ResourceUtil.getNumberFormatStringSync(
      $r('app.string.reset_to_pin_in_ninety_six_hours_tip'), EXPIRE_PRE_PIN) :
    $r('app.string.remember_password_warning_title');
  }

  aboutToAppear(): void {
    super.aboutToAppear();
    this.menu.title = this.getWarningMessage();
    this.refreshUi();
  }

  aboutToDisappear(): void {
    super.aboutToDisappear();
  }

  registerDataChange(): void {
    LogUtil.info(`${this.tag} registerDataChange`);
    this.registerControllerDataChange(SIX_PIN_CIRCLE_KEY);
  }

  unRegisterDataChange(): void {
    LogUtil.info(`${this.tag} unRegisterDataChange`);
    this.unRegisterControllerDataChange(SIX_PIN_CIRCLE_KEY);
  }

  onDataChange(fromKey: string, data: string): void {
    if (fromKey !== SIX_PIN_CIRCLE_KEY) {
      LogUtil.warn(`${this.tag} onDataChange not in page`);
      return;
    }
    if (data === PIN_REPEAT_ERROR) {
      this.menu.title = $r('app.string.pin_repeat_error_title');
      this.refreshUi();
      AccessibilityUtils.delayedAnnounceText(this.menu.title, DELAYED_ANNOUNCE);
    }
    if (data === PIN_REPEAT_WITH_MAIN) {
      this.menu.title = $r('app.string.same_with_main_space_pin');
      this.refreshUi();
      return;
    }
    if (data === PIN_REPEAT_WITH_PRIVATE) {
      this.menu.title = $r('app.string.same_with_private_space_pin_tip');
      this.refreshUi();
      return;
    }
    if (data === REMEMBER_PIN_TIP) {
      this.menu.title = this.getWarningMessage();
      this.refreshUi();
      return;
    }
  }
}

export class SixPinChangeTypeSwitchDialogController extends ButtonMenuController {
  public readonly tag: string = 'SixPinChangeTypeSwitchDialogController : ';

  constructor(menu: SettingsBaseMenu) {
    super(menu);
  }

  onButton1Click(): void {
    this.closeSelf();
    LogUtil.info(`${this.tag} button1 click`);
    this.menu.pathInfos?.popToName(NavEntryKey.BIOMETRICS_PASSWORD_ENTRY);
  }

  onButton2Click(): void {
    this.closeSelf();
    LogUtil.info(`${this.tag} button2 click`);
    EventBus.getInstance().emit('open_change_password_dialog_in_six_pin_page');
    DialogController.setIsNeedShowDialog(false);
  }

  static CreateSixPinChangeTypeSwitchDialogController(menu: SettingsBaseMenu): Controller {
    return new SixPinChangeTypeSwitchDialogController(menu);
  }

  aboutToDisappear(): void {
    LogUtil.info(`${this.tag} aboutToDisappear`);
    DialogController.setIsNeedShowDialog(false);
  }
}

export class SixPinPageShowQuickSwitchDialogController extends SixPinChangeTypeSwitchDialogController {
  public readonly tag: string = 'SixPinPageShowQuickSwitchDialogController : ';

  constructor(menu: SettingsBaseMenu) {
    super(menu);
  }

  onButton1Click(): void {
    super.onButton1Click();
  }

  onButton2Click(): void {
    this.closeSelf();
    LogUtil.info(`${this.tag} button2 click`);
    DialogController.setIsNeedShowDialog(false);
  }

  static CreateSixPinPageShowQuickSwitchDialogController(menu: SettingsBaseMenu): Controller {
    return new SixPinPageShowQuickSwitchDialogController(menu);
  }

  aboutToDisappear(): void {
    super.aboutToDisappear();
  }
}

/**
 * 6位数字密码切换按钮控制器
 *
 * @since 2023-01-14
 */
export class SixPinChangeTypeController extends ButtonMenuController {
  public readonly tag: string = 'SixPinChangeTypeController : ';
  private openChangeTypeDialogCallback = () => {
    this.openChangeTypeDialog();
  };

  aboutToAppear(): void {
    LogUtil.info(`${this.tag} aboutToAppear`);
    super.aboutToAppear();
    AccountUtil.isCurrentPrivate().then(isPrivateUser => {
      if (isPrivateUser) {
        LogUtil.info(`${this.tag} isPrivateUser check password type`);
        PasswordUtil.getUserPasswordInfo(AccountConstants.MAIN_USER).then(userPasswordInfo => {
          if (userPasswordInfo && userPasswordInfo.hasPinPassword &&
            userPasswordInfo.authSubType !== PinSubType.PIN_SIX && DialogController.getIsNeedShowDialog()) {
            this.openQuickSwitchUserDialogTip(true);
          }
        });
      }
    });
    EventBus.getInstance().on('open_change_password_dialog_in_six_pin_page', this.openChangeTypeDialogCallback);
  }

  aboutToDisappear(): void {
    LogUtil.info(`${this.tag} aboutToDisappear`);
    super.aboutToDisappear();
    EventBus.getInstance().detach('open_change_password_dialog_in_six_pin_page', this.openChangeTypeDialogCallback);
  }

  onButton1Click(): boolean {
    HiSysEventUtil.reportButtonEvent(CHANGE_PASSWORD_TYPE_BUTTON, '');
    AccountUtil.isCurrentPrivate().then(isPrivateUser => {
      this.doOpenChangeTypeDialog(isPrivateUser);
    });
    return true;
  }

  static CreateSixPinChangeTypeController(menu: SettingsBaseMenu): Controller {
    return new SixPinChangeTypeController(menu);
  }

  private doOpenChangeTypeDialog(isPrivateUser: boolean): void {
    LogUtil.info(`${this.tag} doOpenChangeTypeDialog isPrivateUser ${isPrivateUser}`);
    if (isPrivateUser) {
      PasswordUtil.getUserPasswordInfo(AccountConstants.MAIN_USER).then(userPasswordInfo => {
        if (userPasswordInfo && userPasswordInfo.hasPinPassword &&
          userPasswordInfo.authSubType === PinSubType.PIN_SIX && DialogController.getIsNeedShowDialog()) {
          this.openQuickSwitchUserDialogTip(false);
          return;
        }
        this.openChangeTypeDialog();
      });
      return;
    }
    this.openChangeTypeDialog();
  }

  private openQuickSwitchUserDialogTip(isFromAppear: boolean): void {
    let controller: ControllerConstructorInter = {
      createControllerConstructorInter:
      SixPinChangeTypeSwitchDialogController.CreateSixPinChangeTypeSwitchDialogController
    };
    if (isFromAppear) {
      controller = {
        createControllerConstructorInter:
        SixPinPageShowQuickSwitchDialogController.CreateSixPinPageShowQuickSwitchDialogController
      }
    }
    let rootPage: DialogPage = DialogController.initDialogPage(this.menu.pathInfos,
      $r('app.string.update_password_type_switch_user_title'),
      $r('app.string.update_password_type_switch_user_tip1'),
      $r('app.string.update_password_type_switch_user_tip2'), controller);
    this.openDialog(rootPage);
  }

  private getNewDividerMenuGroupArray(): Array<NavigationEntry> {
    let res: NavigationEntry[] = [];
    let highSecurityFlag: boolean = WalletManageUtils.checkIfHighSecurity();
    LogUtil.info(`${this.tag},the high security falg is set to ${highSecurityFlag}`);
    if (!highSecurityFlag) {
      // res.push(
      //   new NavigationEntry({
      //       key: 'change_six_to_four_entry',
      //       index: 20,
      //       controller: {
      //         createControllerConstructorInter: ChangeToFourTypeController.CreateChangeToFourTypeController,
      //       },
      //       pathInfos: this.menu.pathInfos,
      //       navRouterParam: this.menu.navRouterParam,
      //       style: new ChangePasswordTypeStyle() as Style,
      //     })
      // )
    }
    res.push(
      new NavigationEntry({
          key: 'change_six_to_number_entry',
          index: 10,
          title: $r('app.string.number_password_type'),
          controller: {
            createControllerConstructorInter:
            ChangeSixToNumberTypeController.CreateChangeSixToNumberTypeController,
          },
          pathInfos: this.menu.pathInfos,
          navRouterParam: this.menu.navRouterParam,
          style: new ChangePasswordTypeStyle() as Style,
        })
      // ,
      // new NavigationEntry({
      //     key: 'change_six_to_mixed_entry',
      //     index: 20,
      //     title: $r('app.string.mixed_password_type'),
      //     controller: {
      //       createControllerConstructorInter: ChangeSixToMixedTypeController.CreateChangeSixToMixedTypeController,
      //     },
      //     pathInfos: this.menu.pathInfos,
      //     navRouterParam: this.menu.navRouterParam,
      //     style: new ChangePasswordTypeStyle() as Style,
      //   })
    )
    return res;
  }

  public openChangeTypeDialog(): void {
    LogUtil.info(`${this.tag} openChangeTypeDialog `);
    let detail = new DialogPage({
      pageUrl: 'pages/password/CreateSixPinSettings/changeTypeDialog',
      title: $r('app.string.change_unlock_method'),
      scrollable: false,
      pageStyle: new ChangePasswordTypeDialogPageStyle(),
      style: new ChangePasswordTypeDialogPageStyle(),
    });
    detail.addMenus(
      [
        new DialogTitleMenu(
          {
            key: 'change_six_to_other_group',
            index: 10,
            title: $r('app.string.select_unlock_method'),
            style: new ChangePasswordTypeTitleStyle()
          }
        ),
        new DividerMenuGroup(
          {
            key: 'change_six_to_other_dialog_group',
            index: 1,
            style: new ChangePasswordTypeDividerGroupStyle()
          },
          this.getNewDividerMenuGroupArray()
        ),
        new ButtonMenu(
          {
            key: 'six_pin_cancel_button',
            index: 40,
            buttonTittle1: $r('app.string.button_tittle_cancel'),
            controller: {
              createControllerConstructorInter: DialogButtonMenuController.CreateDialogButtonMenuController,
            },
            style: new CustomButtonMenuStyle() as Style,
          }
        )
      ]
    );
    this.openDialog(detail, true);
  }

  protected registerDataChange(): void {
    this.registerControllerDataChange(SIX_PIN_CIRCLE_KEY);
  }

  protected unRegisterDataChange(): void {
    this.unRegisterControllerDataChange(SIX_PIN_CIRCLE_KEY);
  }

  onDataChange(fromKey: string, data: string) {
    if (fromKey === SIX_PIN_CIRCLE_KEY) {
      if (data === ENTER_THE_PIN_AGAIN) {
        this.setVisible(false);
      }
    }
  }
}

/**
 * 6位数字密码切自定义数字密码控制器
 *
 * @since 2023-01-17
 */
export class ChangeSixToNumberTypeController extends MenuController {
  public tag: string = 'ChangeSixToNumberTypeController: ';

  static CreateChangeSixToNumberTypeController(menu: SettingsBaseMenu): Controller {
    return new ChangeSixToNumberTypeController(menu);
  }

  onMenuClick(): boolean {
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysPasswordRelatedEventGroup.CLICK_CUSTOMIZE_NUMBER_PWD);
    AppStorage.SetOrCreate(BACK_ENTRY, NavEntryKey.BIOMETRICS_PASSWORD_ENTRY);
    this.menu.pathInfos?.pop();
    this.menu.pushPath(NavEntryKey.CREATE_NUMBER_PSD_ENTRY, this.menu.navRouterParam);
    this.closeSelf();
    return true;
  }
}

/**
 * 6位数字密码切混合密码控制器
 *
 * @since 2023-01-17
 */
export class ChangeSixToMixedTypeController extends MenuController {
  public tag: string = 'ChangeSixToMixedTypeController: ';

  static CreateChangeSixToMixedTypeController(menu: SettingsBaseMenu): Controller {
    return new ChangeSixToMixedTypeController(menu);
  }

  aboutToAppear(): void {
    super.aboutToAppear();
  }

  onMenuClick(): boolean {
    LogUtil.info(`${this.tag} onMenuClick change six to mixed`);
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysBiometricsPasswordEventGroup.SET_UP_HYBRID_PASSWORD);
    AppStorage.SetOrCreate(BACK_ENTRY, NavEntryKey.BIOMETRICS_PASSWORD_ENTRY);
    this.menu.pathInfos?.pop();
    this.menu.pushPath(NavEntryKey.CREATE_MIX_PSD_ENTRY, this.menu.navRouterParam);
    this.closeSelf();
    return true;
  }
}