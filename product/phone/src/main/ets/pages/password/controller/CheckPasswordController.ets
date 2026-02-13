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
// import dsmm from '@hms.security.dsmm';
import { PageLifecycleObserverInterface } from '@ohos/settings.common/src/main/ets/core/lifecycle/Lifecycle';
import {
  HiSysEventUtil,
} from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import {
  extraInfoI,
  PasswordUtil, PinSubType, ResultCode } from '@ohos/settings.common/src/main/ets/utils/PasswordUtil';
import SecurityContext from '@ohos/settings.common/src/main/ets/context/SecurityContext';
import { SearchDataController } from '@ohos/settings.search/src/main/ets/controller/SearchController';
import { EVENT_ID_DELETE_PASSWORD } from '@ohos/settings.common/src/main/ets/event/types';
import emitter from '@ohos.events.emitter';
import { PasswordResolveInfoManager } from '@ohos/settings.privacy/src/main/ets/PasswordResolveInfoManager';
import {
  ButtonMenu,
  PasswordCircleMenu,
  PasswordUnderLineTextInputMenu,
  StateMenu,
  UnderLineTextInputContainerStyle,
  UnderLineTextInputStyle,
  UnderLineTextInputMenuStyle,
  PatternPasswordMenu,
} from '@ohos/settings.uikit/src/main/ets/menus/Menu';
import {
  PageLifecycleMenuGroupController
} from '@ohos/settings.common/src/main/ets/core/controller/LifecycleMenuController';
import { Controller } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { Style } from '@ohos/settings.common/src/main/ets/core/model/menu/ComponetStyle';
import {
  ButtonMenuController,
  PasswordCircleController,
  PatternPasswordController,
  TextInputMenuController,
  UnRespondTouchController} from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import {
  CountDownMenuBaseController,
  MIN_COUNT_DOWN_TIME } from '@ohos/settings.privacy/src/main/ets/controller/CountDownMenuBaseController';
// import ContextManager from '@hw-hmos/settings-face-auth/src/main/ets/faceauth/Manager/ContextManager';
import { SecurityUtil } from '@ohos/settings.common/src/main/ets/utils/SecurityUtil';
import {
  AccessibilityLevelType,
  AccessibilityUtils
} from '@ohos/settings.common/src/main/ets/utils/AccessibilityUtils';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { CountDownDialogMessageStyle } from '../../biometricsandpassword/model/BiometricsAndPasswordPage';
import { RememberPinWarningMenuStyle } from '../model/CreateSixPinPage';
import {
  CHANGE_PASSWORD_ENTRY_FLAG,
  CHECK_PASSWORD_ENTRY_FLAG,
  CLOSE_PASSWORD_ENTRY_FLAG,
  DISABLE_OLD_PASSWORD_ENTRY_FLAG,
  VERIFY_PASSWORD_ENTRY_FLAG
} from './PasswordEntryController';
import { CheckPsdParams } from '../model/CheckPasswordPage';
import osAccount from '@ohos.account.osAccount';
import { VibratorUtil } from '@ohos/settings.common/src/main/ets/utils/VibratorUtil';
import { HiSysPasswordRelatedEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { AppLockManager } from '@ohos/settings.common/src/main/ets/applock/AppLockManager';
import { PasswordRiskDialogManager } from '../model/PasswordRiskDialogManager';
import { SystemParamUtil } from '@ohos/settings.common/src/main/ets/utils/SystemParamUtil';
import { ToastUtil } from '@ohos/settings.common/src/main/ets/utils/ToastUtil';
import DeveloperModeLock from '@ohos/settings.aboutdevice/src/main/ets/controller/DeveloperModeLock';
import { AccountUtil } from '@ohos/settings.common/src/main/ets/utils/AccountUtil';

let passwordResolveInfoManager: PasswordResolveInfoManager | null = PasswordResolveInfoManager.getInstance();
const CHECK_SIX_PIN_CIRCLE_KEY: string = 'check_six_pin_circle_key';
const CHECK_FOUR_PIN_CIRCLE_KEY: string = 'check_four_pin_circle_key';
const CHECK_COUNT_DOWN_MENU_KEY: string = 'check_count_down_menu_key';
const CHECK_WARNING_TEXT_KEY: string = 'check_warning_text_key';
const CHECK_PASSWORD_INPUT_KEY: string = 'check_password_input_key';
const CHECK_PASSWORD_SUBMIT_BUTTON: string = 'check_password_submit_button';
const CHECK_PATTERN_PASSWORD_KEY: string = 'check_pattern_password_key';

export const PIN_ERROR: string = 'pin_error';

export const PIN_INPUT_FREEZING: string = 'pin_input_freezing';

export const PIN_INPUT_FREEZING_END: string = 'pin_input_freezing_end';

export const PIN_INPUT_EMPTY: string = 'pin_input_empty';

const PIN_TEXT_INPUT_KEY: string = 'phone_create_six_pin';

const PATTERN_ERROR: string = 'pattern_error';

const COMMA_SEPARATOR: RegExp = /,/g;

const CHANGE_CUSTOM_PIN_NEXT_BUTTON: string = 'change_custom_pin_next_button';
const CHANGE_PASSWORD_NEXT_BUTTON: string = 'change_password_next_button';
const CLOSE_CUSTOM_PIN_NEXT_BUTTON: string = 'close_custom_pin_next_button';
const CLOSE_PASSWORD_NEXT_BUTTON: string = 'close_password_next_button';
const MARGIN_TOP_64: number = 64;
const MARGIN_BOTTOM_0: number = 0;
const MARGIN_LEFT_24: number = 24;
const MARGIN_RIGHT_24: number = 24;
const REFRESH_DELAY: number = 50;
const MIXED_PSD_MAX_LENGTH: number = 32;
const DEV_LOCKED: number = 5;
const DELAYED_ANNOUNCE: number = 350;

/**
 * 校验自定义数字密码和混合密码输入框样式
 *
 * @since 2023-01-18
 */

export class CheckPsdInputContainerStyle extends UnderLineTextInputContainerStyle {
  public margin: Margin = {
    top: MARGIN_TOP_64,
    bottom: MARGIN_BOTTOM_0,
    left: MARGIN_LEFT_24,
    right: MARGIN_RIGHT_24,
  };
}

const NUMBER_PSD_MAX_LENGTH_EXT: number = 33;

class NumberPsdInputStyle extends UnderLineTextInputStyle {
  public inputType = InputType.NUMBER_PASSWORD;
  public maxLength = NUMBER_PSD_MAX_LENGTH_EXT;
}

class CheckNumberPsdInputMenuStyle extends UnderLineTextInputMenuStyle {
  public textInputStyle = new NumberPsdInputStyle();
  public rootContainer = new CheckPsdInputContainerStyle();
}

class MixedPsdInputStyle extends UnderLineTextInputStyle {
  public inputType = InputType.Password;
  public maxLength = NUMBER_PSD_MAX_LENGTH_EXT;
}

class CheckMixedPsdInputMenuStyle extends UnderLineTextInputMenuStyle {
  public textInputStyle = new MixedPsdInputStyle();
  public rootContainer = new CheckPsdInputContainerStyle();
}

/**
 * 校验密码页面控制器类
 *
 * @since 2023-01-12
 */
@Observed
export class CheckPasswordPageController extends PageLifecycleMenuGroupController {
  static CreateCheckPasswordPageController(menu: SettingsBaseMenu): Controller {
    return new CheckPasswordPageController(menu);
  }

  public tag: string = 'CheckPasswordPageController : ';

  constructor(menu: SettingsBaseMenu) {
    super(menu);
  }

  aboutToAppear(): void {
    LogUtil.info(`${this.tag} aboutToAppear`);
    super.aboutToAppear();
    this.handleRiskDialogOpen();
    if (!passwordResolveInfoManager) {
      LogUtil.info(`${this.tag} getInstance of passwordResolveInfoManager`);
      passwordResolveInfoManager = PasswordResolveInfoManager.getInstance();
    }
    this.loadMenus();
  }

  aboutToDisappear(): void {
    LogUtil.info(`${this.tag} aboutToDisappear`);
    super.aboutToDisappear();
    let pathName: string[] = this.menu.pathInfos?.getAllPathName() ?? [];
    if (pathName.length > 0 && pathName.indexOf(NavEntryKey.CHECK_PSD_ENTRY) >= 0) {
      LogUtil.info(`${this.tag} in check psd page`);
      return;
    }
    passwordResolveInfoManager?.stopTimer();
    passwordResolveInfoManager?.release();
    passwordResolveInfoManager = null;
  }

  async handleRiskDialogOpen(): Promise<void> {
    // securityStatus === '0'， 意味着没有开启坚盾模式。
    const securityStatus: string = SystemParamUtil.getParam('ohos.boot.advsecmode.state', '0');
    let params = this.menu.navRouterParam?.config;
    let sourceFlag = (params as CheckPsdParams)?.source;
    let isCurrentPrivate: boolean = await AccountUtil.isCurrentPrivate();
    PasswordRiskDialogManager.setNinetySixHoursMode(false);
    // 96小时重置不支持坚盾模式，不支持隐私空间，不支持 模拟器。
    let supportNinetyHoursReset: boolean = securityStatus === '0' && !isCurrentPrivate && !SystemParamUtil.isSimulatorMode;
    if (supportNinetyHoursReset && sourceFlag === CHANGE_PASSWORD_ENTRY_FLAG) {
      PasswordRiskDialogManager.setNinetySixHoursMode(true);
      PasswordRiskDialogManager.setRiskDialogOpen(false);
      LogUtil.info(`${this.tag} setRiskDialogOpen false success.`);
    }
  }

  onPageShow(): void {
    LogUtil.info(`${this.tag} onPageShow`);
  }

  onPageHide(): void {
    LogUtil.info(`${this.tag} onPageHide`);
  }

  loadMenus(): void {
    let menus: SettingsBaseMenu[] = [];
    PasswordUtil.getAuthProperty((data) => {
      if (data?.result === ResultCode.SUCCESS) {
        switch (data?.authSubType.toString()) {
          case PinSubType.PIN_SIX.toString():
            this.loadSixPinMenu(menus);
            break;
          case PinSubType.PIN_NUMBER.toString():
          case PinSubType.PIN_MIXED.toString():
            this.loadNumberOrMixedMenu(menus, data);
            break;
          case PinSubType.PIN_FOUR.toString():
            this.loadFourPinMenu(menus);
            break;
          case PinSubType.PIN_PATTERN.toString():
            this.loadPatternMenu(menus);
            break;
        }
        this.clearChildren();
        this.addChildren(menus);
        this.refreshUi();
        LogUtil.info(`${this.tag} getAuthProperty success`);
      } else {
        LogUtil.info(`${this.tag} getAuthProperty failed`);
      }
    });
  }

  private loadPatternMenu(menus: SettingsBaseMenu[]): void {
    LogUtil.info(`${this.tag} PinSubType.PIN_PATTERN`);
    menus.push(new PatternPasswordMenu(
      {
        key: CHECK_PATTERN_PASSWORD_KEY,
        index: 10,
        controller: {
          createControllerConstructorInter: CheckPatternPasswordController.CreateCheckPatternPasswordController,
        },
        pathInfos: this.menu.pathInfos,
        navRouterParam: this.menu.navRouterParam,
      }
    ));
    this.loadOtherMenus(menus);
  }

  private loadFourPinMenu(menus: SettingsBaseMenu[]): void {
    LogUtil.info(`${this.tag} PinSubType.PIN_FOUR`);
    menus.push(new PasswordCircleMenu(
      {
        key: CHECK_FOUR_PIN_CIRCLE_KEY,
        index: 10,
        controller: {
          createControllerConstructorInter: CheckFourPinCircleController.CreateCheckFourPinCircleController,
        },
        pathInfos: this.menu.pathInfos,
        navRouterParam: this.menu.navRouterParam,
      }
    ));
    this.loadOtherMenus(menus);
  }

  private loadSixPinMenu(menus: SettingsBaseMenu[]): void {
    LogUtil.info(`${this.tag} PinSubType.PIN_SIX`);
    menus.push(new PasswordCircleMenu(
      {
        key: CHECK_SIX_PIN_CIRCLE_KEY,
        index: 10,
        controller: {
          createControllerConstructorInter: CheckSixPinCircleController.CreateCheckSixPinCircleController,
        },
        pathInfos: this.menu.pathInfos,
        navRouterParam: this.menu.navRouterParam,
      }
    ));
    this.loadOtherMenus(menus);
  }

  private loadNumberOrMixedMenu(menus: SettingsBaseMenu[], data: osAccount.ExecutorProperty): void {
    LogUtil.info(`${this.tag} PinSubType.PIN_NUMBER`);
    menus.push(new PasswordUnderLineTextInputMenu(
      {
        key: CHECK_PASSWORD_INPUT_KEY,
        index: 10,
        hint: $r('app.string.wifi_password_input_hint'),
        style: this.getKeyboardStyle(data?.authSubType.toString()),
        controller: {
          createControllerConstructorInter: CheckPasswordInputController.CreateCheckPasswordInputController,
        },
      }
    ));
    this.loadOtherMenus(menus);
    menus.push(new ButtonMenu(
      {
        key: CHECK_PASSWORD_SUBMIT_BUTTON,
        index: 50,
        buttonTittle1: $r('app.string.dialog_cancel'),
        buttonTittle2: $r('app.string.dialog_next'),
        controller: {
          createControllerConstructorInter:
          CheckPasswordSubmitButtonController.CreateCheckPasswordSubmitButtonController,
        },
        pathInfos: this.menu.pathInfos,
        navRouterParam: this.menu.navRouterParam,
      }
    ));
  }

  loadOtherMenus(menus: Array<SettingsBaseMenu>): void {
    menus.push(new StateMenu(
      {
        key: CHECK_COUNT_DOWN_MENU_KEY,
        index: 20,
        focusable: false,
        style: new CountDownDialogMessageStyle() as Style,
        extra: 'passError',
        accessibilityLevel: AccessibilityLevelType.NO,
        controller: {
          createControllerConstructorInter: CheckCountDownMenuController.CreateCheckCountDownMenuController,
        },
      }
    ));
    menus.push(new StateMenu(
      {
        key: CHECK_WARNING_TEXT_KEY,
        index: 30,
        focusable: false,
        style: new RememberPinWarningMenuStyle() as Style,
        accessibilityLevel: AccessibilityLevelType.NO,
        controller: {
          createControllerConstructorInter: CheckWarningMessageController.CreateCheckWarningMessageController,
        },
      }
    ));
  }

  private getKeyboardStyle(pinType: string) : Style {
    if (pinType === PinSubType.PIN_NUMBER.toString()) {
      return new CheckNumberPsdInputMenuStyle() as Style;
    } else {
      return new CheckMixedPsdInputMenuStyle() as Style;
    }
  }
}

/**
 * 校验6位密码圆圈菜单控制器类
 *
 * @since 2023-01-12
 */
@Observed
export class CheckSixPinCircleController extends PasswordCircleController implements PageLifecycleObserverInterface {
  public tag: string = 'CheckSixPinCircleController : ';
  protected password: string = '';
  protected passwordCircle: string[] = ['', '', '', '', '', ''];
  protected pinChallenge: string = '';
  protected pinToken: string = '';
  protected routerParams?: CheckPsdParams;
  protected sourceFlag: string = '';
  protected dynamic: boolean = false;
  protected isChecked: boolean = true;
  protected passwordLength: number = 6;
  protected passwordType: PinSubType = PinSubType.PIN_SIX;

  constructor(menu: SettingsBaseMenu) {
    super(menu);
  }

  static CreateCheckSixPinCircleController(menu: SettingsBaseMenu): Controller {
    return new CheckSixPinCircleController(menu);
  }

  aboutToAppear(): void {
    super.aboutToAppear();
    this.initSourceFlag();
    this.initStatus();
  }

  aboutToDisappear(): void {
    super.aboutToDisappear();
  }

  getTextInputKey(): string {
    return PIN_TEXT_INPUT_KEY;
  }

  onPageShow(): void {
    this.initStatus();
  }

  onPageHide(): void {
  }

  public getObserverKey = (): string => {
    return this.menu?.key as string;
  }

  initSourceFlag(): void {
    let params = this.menu.navRouterParam?.config;
    let sourceFlag = '';
    if (params) {
      this.routerParams = params as CheckPsdParams;
      sourceFlag = (params as CheckPsdParams).source;
      this.dynamic = (params as CheckPsdParams).dynamic as boolean;
    }
    if (!sourceFlag) {
      LogUtil.info(`${this.tag} getSourceFlag Router params invalid `);
      return;
    }
    this.sourceFlag = sourceFlag;
  }

  initStatus(): void {
    PasswordUtil.getAuthProperty((data) => {
      if (data?.result === ResultCode.SUCCESS) {
        const visible: boolean = (data?.freezingTime && data?.freezingTime >= MIN_COUNT_DOWN_TIME) ? false : true;
        this.setRefresherVisible(visible);
        if (visible) {
          // 从dialog跳转到密码界面，无法自动弹出输入法，原因是没有获取到焦点，arkUI给的临时方案，待arkUI修改好后删除此延时
          setTimeout(() => {
            focusControl.requestFocus(PIN_TEXT_INPUT_KEY);
          }, this.sourceFlag === CLOSE_PASSWORD_ENTRY_FLAG ? 300 : 0)
        }
        LogUtil.info(`${this.tag} getAuthProperty success`);
      } else {
        LogUtil.info(`${this.tag} getAuthProperty failed`);
      }
    });
  }

  unsubscribe(): void {
    PasswordUtil.unregisterInputer();
    PasswordUtil.closeSession();
  };

  onTextInputChange(value: string): void {
    this.password = value;
    if (value.length > this.passwordLength) {
      return;
    }
    let length = value.length;
    for (let i = 0; i < this.passwordLength; i++) {
      if (i < length) {
        this.passwordCircle[i] = value[i];
      } else {
        this.passwordCircle[i] = '';
      }
    }
    if (PasswordUtil.isPinNumber6(value)) {
      this.inputFinish();
    }
  }

  inputFinish(): void {
    LogUtil.info(`${this.tag} inputFinish in`);
    if (!this.password) {
      LogUtil.info(`${this.tag} inputFinish return : password is none`);
      return;
    }
    this.checkInputPasswordCorrect();
    LogUtil.info(`${this.tag} inputFinish out`);
  }

  checkInputPasswordCorrect(): void {
    LogUtil.info(`${this.tag} checkInputPasswordCorrect in`);
    this.unsubscribe();
    PasswordUtil.registerInputer(this.passwordType);
    if (this.sourceFlag === VERIFY_PASSWORD_ENTRY_FLAG) {
      let mode: string = 'developer';
      LogUtil.info(`${this.tag} dsmm open session start`);
      // dsmm.openSession(mode).then((challenge: ESObject) => {
      //   this.pinChallenge = PasswordUtil.challengeToPinChallenge(challenge);
      //   PasswordUtil.authPin(this.pinChallenge, this.password, (result, extraInfo) => {
      //     this.authCallback(result, extraInfo);
      //   });
      // }).catch((error: Error) => {
      //   LogUtil.error(`${this.tag} open session failed ${error?.message}`);
      // });
    } else {
      PasswordUtil.openSession((data) => {
        this.pinChallenge = data;
        PasswordUtil.authPin(this.pinChallenge, this.password, (result, extraInfo) => {
          this.authCallback(result, extraInfo);
        });
      });
    }

    LogUtil.info(`${this.tag} checkInputPasswordCorrect out`);
  }

  authCallback(result: number, extraInfo: extraInfoI): void {
    LogUtil.info(`${this.tag} authCallback, ${result}`);
    AppStorage.setOrCreate<number>('pinSubType', this.passwordType);
    if (result === ResultCode.SUCCESS) {
      this.authSuccess(extraInfo);
    } else {
      passwordResolveInfoManager?.setRemainTimes(extraInfo?.remainTimes as number);
      passwordResolveInfoManager?.setFreezingTime(extraInfo?.freezingTime as number >= MIN_COUNT_DOWN_TIME ?
        extraInfo?.freezingTime as number : 0);
      if (passwordResolveInfoManager?.getRemainTimes() as number <= 0) {
        this.setRefresherVisible(false);
        this.publishDataChange(PIN_INPUT_FREEZING);
      } else {
        this.publishDataChange(PIN_ERROR);
      }
      this.clearInput();
      this.unsubscribe();
    }
  }

  authSuccess(extraInfo: extraInfoI): void {
    this.pinToken = extraInfo.token as string;
    if (this.sourceFlag === CHECK_PASSWORD_ENTRY_FLAG || this.sourceFlag === CHANGE_PASSWORD_ENTRY_FLAG) {
      PasswordUtil.unregisterInputer();
      if (PasswordUtil.isBiometricsPasswordEntry()) {
        PasswordUtil.closeSession();
        return;
      }
      this.menu.pathInfos?.pop();
      if (this.dynamic) {
        this.menu.pushPath(this.routerParams?.nextUrl as string, this.menu.navRouterParam);
      } else {
        if (this.routerParams?.nextUrl === NavEntryKey.FACE_AUTH_PREFERENCE_ENTRY ||
          this.routerParams?.nextUrl === NavEntryKey.FACE_AUTH_FEATURE_GUIDE_ENTRY) {
          // ContextManager.get().setAuthToken(SecurityContext.getInstance().getToken());
          // ContextManager.get().setChallenge(SecurityContext.getInstance().getChallenge());
        }
        this.menu.pushPath(this.routerParams?.nextUrl as string, this.menu.navRouterParam);
      }
    } else if (this.sourceFlag === VERIFY_PASSWORD_ENTRY_FLAG) {
      this.setDeveloperMode(this.isChecked, extraInfo.token as string);
    } else if (this.sourceFlag === CLOSE_PASSWORD_ENTRY_FLAG) {
      this.deletePassword();
    } else if (this.sourceFlag === DISABLE_OLD_PASSWORD_ENTRY_FLAG) {
      this.disableOldPassword();
    }
  }

  private async setDeveloperMode(enable: boolean, authToken: string): Promise<void> {
    await SearchDataController.getInstance().updateChildItemSearchStatus('developer_options',
      enable ? true : false, ['debug_outer_app']);
    let ret: number = await SecurityUtil.setDevelopModeNew(enable ? 1 : 0, authToken);
    if (ret === DEV_LOCKED) {
      let developerModeLock: DeveloperModeLock = new DeveloperModeLock();
      developerModeLock.openDeveloperModeLockDialog();
    } else {
      setTimeout(() => {
        SecurityUtil.rebootDevice();
      }, 2000);
    }
  }

  clearInput(): void {
    this.password = '';
    this.passwordCircle = ['', '', '', '', '', ''];
  }

  deletePassword(): void {
    PasswordUtil.deletePassword(this.pinToken, this.password, (result, extraInfo) => {
      if (result === ResultCode.SUCCESS) {
        LogUtil.info(`${this.tag} deletePassword success`);
        emitter.emit({ eventId: EVENT_ID_DELETE_PASSWORD });
        this.menu.pathInfos?.pop();
        SearchDataController.getInstance().updateChildItemSearchStatus('lock_screen_password', false);
        SearchDataController.getInstance().updateSearchItemStatus('lock_screen_password', true);
        AppLockManager.setEnabled(false);
      } else {
        LogUtil.info(`${this.tag} deletePassword failed`);
      }
      this.unsubscribe();
    });
  }

  disableOldPassword(): void {
    LogUtil.info('disableOldPassword start');
    let callback: osAccount.IIdmCallback = {
      onResult: (result, extraInfo) => {
        LogUtil.info(`${this.tag} on disableOldPsd result: ${result}`);
        if (result === ResultCode.SUCCESS) {
          SecurityContext.getInstance().emptyOldPasswordCred();
          this.menu.pathInfos?.pop();
          SearchDataController.getInstance().updateSearchItemStatus('expire_lock_screen_password', false);
        } else if (result === ResultCode.SERVICE_ERROR) {
          ToastUtil.showToast(ResourceUtil.getStringSync($r('app.string.service_error')));
        } else {
          LogUtil.info(`${this.tag} deletePassword failed`);
        }
        this.unsubscribe();
      },
    };
    PasswordUtil.deleteOldPassword(callback);
  }

  registerDataChange(): void {
    LogUtil.info(`${this.tag} registerDataChange`);
    this.registerControllerDataChange(CHECK_COUNT_DOWN_MENU_KEY);
  }

  unRegisterDataChange(): void {
    LogUtil.info(`${this.tag} unRegisterDataChange`);
    this.unRegisterControllerDataChange(CHECK_COUNT_DOWN_MENU_KEY);
  }

  onDataChange(fromKey: string, data: Object): void {
    if (fromKey === CHECK_COUNT_DOWN_MENU_KEY) {
      if (data === PIN_INPUT_FREEZING_END) {
        this.clearInput();
        this.setRefresherVisible(true);
        this.refreshUi();
        focusControl.requestFocus(PIN_TEXT_INPUT_KEY);
      }
    }
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
 * 校验4位密码圆圈菜单控制器类
 *
 * @since 2024-06-26
 */
@Observed
export class CheckFourPinCircleController
  extends CheckSixPinCircleController implements PageLifecycleObserverInterface {
  public tag: string = 'CheckFourPinCircleController : ';
  protected passwordCircle: string[] = ['', '', '', ''];
  protected passwordLength: number = 4;
  protected passwordType: PinSubType = PinSubType.PIN_FOUR;

  constructor(menu: SettingsBaseMenu) {
    super(menu);
  }

  static CreateCheckFourPinCircleController(menu: SettingsBaseMenu): Controller {
    return new CheckFourPinCircleController(menu);
  }

  aboutToAppear(): void {
    super.aboutToAppear();
    this.initSourceFlag();
    this.initStatus();
    this.setMaxLength(this.passwordLength);
  }

  aboutToDisappear(): void {
    super.aboutToDisappear();
  }

  getTextInputKey(): string {
    return PIN_TEXT_INPUT_KEY;
  }

  onPageShow(): void {
    this.initStatus();
  }

  onPageHide(): void {
  }

  public getObserverKey = (): string => {
    return this.menu?.key as string;
  }

  unsubscribe(): void {
    PasswordUtil.unregisterInputer();
    PasswordUtil.closeSession();
  };

  onTextInputChange(value: string): void {
    this.password = value;
    if (value.length > this.passwordLength) {
      return;
    }
    let length = value.length;
    for (let i = 0; i < this.passwordLength; i++) {
      if (i < length) {
        this.passwordCircle[i] = value[i];
      } else {
        this.passwordCircle[i] = '';
      }
    }
    if (PasswordUtil.isPinNumber4(value)) {
      this.inputFinish();
    }
  }

  clearInput(): void {
    this.password = '';
    this.passwordCircle = ['', '', '', ''];
  }
}

/**
 * 校验自定义数字密码和混合密码菜单控制器类
 *
 * @since 2023-01-14
 */
@Observed
export class CheckPasswordInputController extends TextInputMenuController implements PageLifecycleObserverInterface {
  public tag: string = 'CheckPasswordInputController : ';
  public btnController: CheckPasswordSubmitButtonController;
  public input: string = '';

  constructor(menu: SettingsBaseMenu) {
    super(menu);
    this.btnController =
      menu.getControllerFromPage(CHECK_PASSWORD_SUBMIT_BUTTON) as CheckPasswordSubmitButtonController;
  }

  static CreateCheckPasswordInputController(menu: SettingsBaseMenu): Controller {
    return new CheckPasswordInputController(menu);
  }

  aboutToAppear(): void {
    super.aboutToAppear();
    this.initStatus();
  }

  aboutToDisappear(): void {
    super.aboutToDisappear();
  }

  onPageShow(): void {
    this.initStatus();
  }

  onPageHide(): void {
  }

  public getObserverKey = (): string => {
    return this.menu?.key as string;
  }

  initStatus(): void {
    PasswordUtil.getAuthProperty((data) => {
      if (data?.result === ResultCode.SUCCESS) {
        this.setRender((data?.freezingTime && data?.freezingTime >= MIN_COUNT_DOWN_TIME) ? false : true);
        this.menu.enable = true;
        this.requestFocus();
        LogUtil.info(`${this.tag} getAuthProperty success`);
      } else {
        LogUtil.info(`${this.tag} getAuthProperty failed`);
      }
    });
  }

  onTextInputChange(input: string): void {
    this.publishDataChange(input);
    this.input = input;
    if (input?.length > MIXED_PSD_MAX_LENGTH) {
      this.menu.title = input.substring(0, MIXED_PSD_MAX_LENGTH);
      this.refreshUi();
      this.notifyChange();
    }
  }

  registerDataChange(): void {
    LogUtil.info(`${this.tag} registerDataChange`);
    this.registerControllerDataChange(CHECK_PASSWORD_SUBMIT_BUTTON);
    this.registerControllerDataChange(CHECK_COUNT_DOWN_MENU_KEY);
  }

  unRegisterDataChange(): void {
    LogUtil.info(`${this.tag} unRegisterDataChange`);
    this.unRegisterControllerDataChange(CHECK_PASSWORD_SUBMIT_BUTTON);
    this.unRegisterControllerDataChange(CHECK_COUNT_DOWN_MENU_KEY);
  }

  onDataChange(fromKey: string, data: Object): void {
    if (fromKey === CHECK_PASSWORD_SUBMIT_BUTTON) {
      if (data === PIN_ERROR) {
        this.menu.title = '';
        this.refreshUi();
        this.notifyChange();
      } else if (data === PIN_INPUT_FREEZING) {
        this.menu.title = '';
        this.setRender(false);
        this.notifyChange();
      }
      this.publishDataChange(PIN_INPUT_EMPTY);
    } else if (fromKey === CHECK_COUNT_DOWN_MENU_KEY) {
      if (data === PIN_INPUT_FREEZING_END) {
        this.setRender(true);
        this.menu.enable = true;
        this.requestFocus();
      }
    }
  }

  requestFocus(): void {
    setTimeout(() => {
      focusControl.requestFocus(this.menu.key ?? '');
    }, REFRESH_DELAY);
  }

  onSubmit(enterKey: EnterKeyType): void {
    this.btnController =
      this.menu.getControllerFromPage(CHECK_PASSWORD_SUBMIT_BUTTON) as CheckPasswordSubmitButtonController;
    if (enterKey == (EnterKeyType.Done | EnterKeyType.Go) && this.input.length > 0) {
      this.btnController?.onButton2Click();
    }
  }
}


/**
 * 校验自定义数字密码和混合密码提交按钮控制器
 *
 * @since 2023-01-17
 */
@Observed
export class CheckPasswordSubmitButtonController extends ButtonMenuController {
  public readonly tag: string = 'CheckPasswordSubmitButtonController : ';
  private password: string = '';
  private pinChallenge: string = '';
  private pinToken: string = '';
  private pinSubType: number = -1;
  private isButton3Enable: boolean = false;
  private routerParams?: CheckPsdParams;
  private sourceFlag: string = '';
  private dynamic: boolean = false;
  private isCheckedPassword: boolean = true;

  constructor(menu: SettingsBaseMenu) {
    super(menu);
  }

  static CreateCheckPasswordSubmitButtonController(menu: SettingsBaseMenu): Controller {
    return new CheckPasswordSubmitButtonController(menu);
  }

  aboutToAppear(): void {
    super.aboutToAppear();
    this.initSourceFlag();
    this.initPinSubType();
  }

  aboutToDisappear(): void {
    super.aboutToDisappear();
  }

  initSourceFlag(): void {
    let params = this.menu.navRouterParam?.config;
    let sourceFlag = '';
    if (params) {
      this.routerParams = params as CheckPsdParams;
      sourceFlag = (params as CheckPsdParams).source;
      this.dynamic = (params as CheckPsdParams).dynamic as boolean;
    }
    if (!sourceFlag) {
      LogUtil.info(`${this.tag} getSourceFlag Router params invalid `);
      return;
    }
    this.sourceFlag = sourceFlag;
  }

  initPinSubType(): void {
    PasswordUtil.getAuthProperty((data) => {
      if (data?.result === ResultCode.SUCCESS) {
        this.pinSubType = data?.authSubType;
        this.setRefresherVisible((data?.freezingTime && data?.freezingTime >= MIN_COUNT_DOWN_TIME) ? false : true);
        LogUtil.info(`${this.tag} getAuthProperty success`);
      } else {
        LogUtil.info(`${this.tag} getAuthProperty failed`);
      }
    });
  }

  unsubscribe(): void {
    PasswordUtil.unregisterInputer();
    PasswordUtil.closeSession();
  }

  onButton1Click(): void {
    this.menu.pathInfos?.pop();
  }

  onButton2Click(): void {
    if (this.pinSubType === PinSubType.PIN_NUMBER) {
      if (this.sourceFlag === CHANGE_PASSWORD_ENTRY_FLAG) {
        HiSysEventUtil.reportButtonEvent(CHANGE_CUSTOM_PIN_NEXT_BUTTON, '');
      } else if (this.sourceFlag === CLOSE_PASSWORD_ENTRY_FLAG) {
        HiSysEventUtil.reportButtonEvent(CLOSE_CUSTOM_PIN_NEXT_BUTTON, '');
      }
    } else if (this.pinSubType === PinSubType.PIN_MIXED) {
      if (this.sourceFlag === CHANGE_PASSWORD_ENTRY_FLAG) {
        HiSysEventUtil.reportButtonEvent(CHANGE_PASSWORD_NEXT_BUTTON, '');
      } else if (this.sourceFlag === CLOSE_PASSWORD_ENTRY_FLAG) {
        HiSysEventUtil.reportButtonEvent(CLOSE_PASSWORD_NEXT_BUTTON, '');
      }
    }
    this.checkInputPasswordCorrect();
  }

  isButton3Enabled(): boolean {
    return this.isButton3Enable;
  }

  private checkInputPasswordCorrect(): void {
    LogUtil.info(`${this.tag} checkInputPasswordCorrect in`);
    if (!this.password) {
      LogUtil.info(`${this.tag} password is empty`);
      return;
    }
    if (this.pinSubType === -1) {
      LogUtil.info(`${this.tag} pinSubType is empty`);
      return;
    }
    if (!this.isCheckedPassword) {
      LogUtil.info(`${this.tag} isCheckedPassword is false`);
      return;
    }
    this.isCheckedPassword = false;
    this.unsubscribe();
    PasswordUtil.registerInputer(this.pinSubType);
    if (this.sourceFlag === VERIFY_PASSWORD_ENTRY_FLAG) {
      let mode: string = 'developer';
      LogUtil.info(`${this.tag} dsmm open session start`);
      // dsmm.openSession(mode).then((challenge: ESObject) => {
      //   this.pinChallenge = PasswordUtil.challengeToPinChallenge(challenge);
      //   this.checkPassword();
      // }).catch((error: Error) => {
      //   LogUtil.error(`${this.tag} open session failed ${error?.message}`);
      // });
    } else {
      PasswordUtil.openSession((data) => {
        this.pinChallenge = data;
        this.checkPassword();
      });
    }
    LogUtil.info(`${this.tag} checkInputPasswordCorrect out`);
  }

  private checkPassword(): void {
    PasswordUtil.authPin(this.pinChallenge, this.password, (result, extraInfo) => {
      AppStorage.setOrCreate<number>('pinSubType', this.pinSubType);
      if (result === ResultCode.SUCCESS) {
        this.pinToken = extraInfo.token ?? '';
        if (this.sourceFlag === CHECK_PASSWORD_ENTRY_FLAG || this.sourceFlag === CHANGE_PASSWORD_ENTRY_FLAG) {
          PasswordUtil.unregisterInputer();
          if (PasswordUtil.isBiometricsPasswordEntry()) {
            PasswordUtil.closeSession();
            return;
          }
          this.menu.pathInfos?.pop();
          if (this.dynamic) {
            this.menu.pushPath(this.routerParams?.nextUrl as string, this.menu.navRouterParam);
          } else {
            if (this.routerParams?.nextUrl === NavEntryKey.FACE_AUTH_PREFERENCE_ENTRY ||
              this.routerParams?.nextUrl === NavEntryKey.FACE_AUTH_FEATURE_GUIDE_ENTRY) {
              // ContextManager.get().setAuthToken(SecurityContext.getInstance().getToken());
              // ContextManager.get().setChallenge(SecurityContext.getInstance().getChallenge());
            }
            this.menu.pushPath(this.routerParams?.nextUrl as string, this.menu.navRouterParam);
          }
          this.isCheckedPassword = true;
        } else if (this.sourceFlag === VERIFY_PASSWORD_ENTRY_FLAG) {
          this.setDeveloperMode(true, extraInfo.token as string);
          this.isCheckedPassword = true;
        } else if (this.sourceFlag === CLOSE_PASSWORD_ENTRY_FLAG) {
          this.deletePassword();
        } else if (this.sourceFlag === DISABLE_OLD_PASSWORD_ENTRY_FLAG) {
          this.disableOldPassword();
        }
      } else {
        this.isCheckedPassword = true;
        passwordResolveInfoManager?.setRemainTimes(extraInfo.remainTimes as number);
        passwordResolveInfoManager?.setFreezingTime((extraInfo?.freezingTime && extraInfo.freezingTime >=
          MIN_COUNT_DOWN_TIME) ?
        extraInfo.freezingTime : 0);
        if (passwordResolveInfoManager?.getRemainTimes() as number <= 0) {
          this.isButton3Enable = false;
          this.refreshUi();
          this.publishDataChange(PIN_INPUT_FREEZING);
        } else {
          this.publishDataChange(PIN_ERROR);
        }
        this.password = '';
        this.unsubscribe();
      }
    });
  }

  private async setDeveloperMode(enable: boolean, authToken: string): Promise<void> {
    await SearchDataController.getInstance().updateChildItemSearchStatus('developer_options',
      enable ? true : false, ['debug_outer_app']);
    let ret: number = await SecurityUtil.setDevelopModeNew(enable ? 1 : 0, authToken);
    if (ret === DEV_LOCKED) {
      let developerModeLock: DeveloperModeLock = new DeveloperModeLock();
      developerModeLock.openDeveloperModeLockDialog();
    } else {
      setTimeout(() => {
        SecurityUtil.rebootDevice();
      }, 2000);
    }
  }

  private deletePassword(): void {
    PasswordUtil.deletePassword(this.pinToken, this.password, (result, extraInfo) => {
      this.isCheckedPassword = true;
      if (result === ResultCode.SUCCESS) {
        LogUtil.info(`${this.tag} deletePassword success`);
        this.menu.pathInfos?.pop();
        SearchDataController.getInstance().updateChildItemSearchStatus('lock_screen_password', false);
        SearchDataController.getInstance().updateSearchItemStatus('lock_screen_password', true);
        AppLockManager.setEnabled(false);
      } else {
        LogUtil.info(`${this.tag} deletePassword failed`);
      }
      this.unsubscribe();
    });
  }

  disableOldPassword(): void {
    LogUtil.info('disableOldPassword start');
    let callback: osAccount.IIdmCallback = {
      onResult: (result, extraInfo) => {
        LogUtil.info(`${this.tag} on disableOldPsd result: ${result}`);
        if (result === ResultCode.SUCCESS) {
          SecurityContext.getInstance().emptyOldPasswordCred();
          this.menu.pathInfos?.pop();
          SearchDataController.getInstance().updateSearchItemStatus('expire_lock_screen_password', false);
        } else if (result === ResultCode.SERVICE_ERROR) {
          ToastUtil.showToast(ResourceUtil.getStringSync($r('app.string.service_error')));
        } else {
          LogUtil.error(`${this.tag} deletePassword failed`);
        }
        this.unsubscribe();
      },
    };
    PasswordUtil.deleteOldPassword(callback);
  }

  protected registerDataChange(): void {
    this.registerControllerDataChange(CHECK_PASSWORD_INPUT_KEY);
    this.registerControllerDataChange(CHECK_PASSWORD_SUBMIT_BUTTON);
    this.registerControllerDataChange(CHECK_COUNT_DOWN_MENU_KEY);
  }

  protected unRegisterDataChange(): void {
    this.unRegisterControllerDataChange(CHECK_PASSWORD_INPUT_KEY);
    this.unRegisterControllerDataChange(CHECK_PASSWORD_SUBMIT_BUTTON);
    this.unRegisterControllerDataChange(CHECK_COUNT_DOWN_MENU_KEY);
  }

  onDataChange(fromKey: string, data: Object): void {
    if (fromKey === CHECK_PASSWORD_INPUT_KEY && typeof data === 'string') {
      if (data === PIN_INPUT_EMPTY) {
        this.isButton3Enable = false;
      } else {
        this.isButton3Enable = data.length === 0 ? false : true;
        this.password = data;
      }
      this.refreshUi();
    } else if (fromKey === CHECK_PASSWORD_SUBMIT_BUTTON) {
      if (data === PIN_INPUT_FREEZING) {
        this.setRefresherVisible(false);
        this.refreshUi();
      }
    } else if (fromKey === CHECK_COUNT_DOWN_MENU_KEY) {
      if (data === PIN_INPUT_FREEZING_END) {
        this.setRefresherVisible(true);
        this.refreshUi();
      }
    }
  }
}

/**
 * 校验密码警告信息控制器类
 *
 * @since 2023-01-12
 */
@Observed
export class CheckWarningMessageController extends UnRespondTouchController {
  public tag: string = 'CheckWarningMessageController : ';

  constructor(menu: SettingsBaseMenu) {
    super(menu);
  }

  static CreateCheckWarningMessageController(menu: SettingsBaseMenu): Controller {
    return new CheckWarningMessageController(menu);
  }

  aboutToAppear(): void {
    super.aboutToAppear();
  }

  aboutToDisappear(): void {
    super.aboutToDisappear();
  }

  registerDataChange(): void {
    LogUtil.info(`${this.tag} registerDataChange`);
    this.registerControllerDataChange(CHECK_SIX_PIN_CIRCLE_KEY);
    this.registerControllerDataChange(CHECK_PASSWORD_SUBMIT_BUTTON);
    this.registerControllerDataChange(CHECK_FOUR_PIN_CIRCLE_KEY);
    this.registerControllerDataChange(CHECK_PATTERN_PASSWORD_KEY)
  }

  unRegisterDataChange(): void {
    LogUtil.info(`${this.tag} unRegisterDataChange`);
    this.unRegisterControllerDataChange(CHECK_SIX_PIN_CIRCLE_KEY);
    this.unRegisterControllerDataChange(CHECK_PASSWORD_SUBMIT_BUTTON);
    this.unRegisterControllerDataChange(CHECK_FOUR_PIN_CIRCLE_KEY);
    this.unRegisterControllerDataChange(CHECK_PATTERN_PASSWORD_KEY)
  }

  onDataChange(fromKey: string, data: Object): void {
    LogUtil.info(`${this.tag} onDataChange ${fromKey} ${data}`)
    let readText: string = '';
    if (this.isNeedDealDataChange(fromKey)) {
      if (data === PIN_ERROR) {
        if (fromKey === CHECK_PASSWORD_SUBMIT_BUTTON) {
          this.menu.title = $r('app.plural.password_message_incorrect', passwordResolveInfoManager?.getRemainTimes(),
            passwordResolveInfoManager?.getRemainTimes());
          readText = ResourceUtil.getPluralStringValueSync($r('app.plural.password_message_incorrect'),
            passwordResolveInfoManager?.getRemainTimes() ?? 0);
        } else {
          this.menu.title = $r('app.plural.pin_message_incorrect', passwordResolveInfoManager?.getRemainTimes(),
            passwordResolveInfoManager?.getRemainTimes());
          readText = ResourceUtil.getPluralStringValueSync($r('app.plural.pin_message_incorrect'),
            passwordResolveInfoManager?.getRemainTimes() ?? 0);
        }
      } else if (data === PIN_INPUT_FREEZING) {
        this.menu.title = '';
      } else if (data === PATTERN_ERROR) {
        this.menu.title = $r('app.string.pattern_password_error');
      }
    }
    if (this?.menu?.title !== undefined && this?.menu?.title !== '') {
      this.menu.accessibilityLevel = AccessibilityLevelType.YES;
      AccessibilityUtils.delayedAnnounceText(readText, DELAYED_ANNOUNCE);
    } else {
      this.menu.accessibilityLevel = AccessibilityLevelType.NO;
    }
    this.refreshUi();
  }

  private isNeedDealDataChange(fromKey: string): boolean {
    return fromKey === CHECK_SIX_PIN_CIRCLE_KEY || fromKey === CHECK_PASSWORD_SUBMIT_BUTTON ||
      fromKey === CHECK_FOUR_PIN_CIRCLE_KEY || fromKey === CHECK_PATTERN_PASSWORD_KEY;
  }
}

/**
 * 倒计时提示信息文本控制器
 *
 * @since 2023-01-12
 */
@Observed
class CheckCountDownMenuController extends CountDownMenuBaseController implements PageLifecycleObserverInterface {
  public tag: string = 'CheckCountDownMenuController : ';

  constructor(menu: SettingsBaseMenu) {
    super(menu, passwordResolveInfoManager as PasswordResolveInfoManager);
  }

  static CreateCheckCountDownMenuController(menu: SettingsBaseMenu): Controller {
    return new CheckCountDownMenuController(menu);
  }

  aboutToAppear(): void {
    super.aboutToAppear();
    this.isRespondTouchEvent = false;
    this.initStatus();
  }

  aboutToDisappear(): void {
    super.aboutToDisappear();
  }

  onPageShow(): void {
    this.initStatus();
  }

  onPageHide(): void {
  }

  public getObserverKey = (): string => {
    return this.menu?.key as string;
  }

  initStatus(): void {
    PasswordUtil.getAuthProperty((data) => {
      if (data?.result === ResultCode.SUCCESS) {
        LogUtil.info(`${this.tag} data ${data?.freezingTime}`);
        let hasFreezingTime: boolean = (data?.freezingTime && data?.freezingTime >= MIN_COUNT_DOWN_TIME) as boolean;
        this.setVisible(hasFreezingTime);
        this.passwordResolveInfoManager?.setFreezingTime(hasFreezingTime ? data.freezingTime as number : 0);
        LogUtil.info(`${this.tag} other freezing startCountDonwTimer ${hasFreezingTime}`);
        // 开启定时器后，首次执行的时间为1秒后。如无冻结时间，1秒内输入的密码将被清空。无冻结时间不应启动定时器
        if (hasFreezingTime) {
          this.startCountDonwTimer();
        }
        LogUtil.info(`${this.tag} getAuthProperty success`);
      } else {
        LogUtil.info(`${this.tag} getAuthProperty failed`);
      }
    });
  }

  onFreezingEnd(): void {
    LogUtil.info(`${this.tag} onFreezingEnd`);
    this.setVisible(false);
    this.publishDataChange(PIN_INPUT_FREEZING_END);
  }

  protected registerDataChange(): void {
    LogUtil.info(`${this.tag} registerDataChange`);
    this.registerControllerDataChange(CHECK_SIX_PIN_CIRCLE_KEY);
    this.registerControllerDataChange(CHECK_PASSWORD_SUBMIT_BUTTON);
    this.registerControllerDataChange(CHECK_FOUR_PIN_CIRCLE_KEY);
    this.registerControllerDataChange(CHECK_PATTERN_PASSWORD_KEY)
  }

  protected unRegisterDataChange(): void {
    LogUtil.info(`${this.tag} unRegisterDataChange`);
    this.unRegisterControllerDataChange(CHECK_SIX_PIN_CIRCLE_KEY);
    this.unRegisterControllerDataChange(CHECK_PASSWORD_SUBMIT_BUTTON);
    this.unRegisterControllerDataChange(CHECK_FOUR_PIN_CIRCLE_KEY);
    this.unRegisterControllerDataChange(CHECK_PATTERN_PASSWORD_KEY)
  }

  onDataChange(fromKey: string, data: Object): void {
    if (fromKey === CHECK_SIX_PIN_CIRCLE_KEY || fromKey === CHECK_PASSWORD_SUBMIT_BUTTON ||
      fromKey === CHECK_FOUR_PIN_CIRCLE_KEY || fromKey === CHECK_PATTERN_PASSWORD_KEY) {
      if (data === PIN_INPUT_FREEZING) {
        LogUtil.info(`${this.tag} first freezing startCountDonwTimer`);
        this.startCountDonwTimer();
        this.setVisible(true);
      }
    }
  }
}

/**
 * 校验图形密码菜单控制器类
 *
 * @since 2024-06-26
 */
@Observed
export class CheckPatternPasswordController
  extends PatternPasswordController implements PageLifecycleObserverInterface {
  public tag: string = 'CheckPatternPasswordController : ';
  protected password: string = '';
  protected pinChallenge: string = '';
  protected pinToken: string = '';
  protected routerParams?: CheckPsdParams;
  protected sourceFlag: string = '';
  protected dynamic: boolean = false;
  protected isChecked: boolean = true;
  protected passwordType: PinSubType = PinSubType.PIN_PATTERN;

  constructor(menu: SettingsBaseMenu) {
    super(menu);
  }

  static CreateCheckPatternPasswordController(menu: SettingsBaseMenu): Controller {
    return new CheckPatternPasswordController(menu);
  }

  aboutToAppear(): void {
    super.aboutToAppear();
    this.initSourceFlag();
    this.initStatus();
  }

  aboutToDisappear(): void {
    super.aboutToDisappear();
  }

  onPageShow(): void {
    this.initStatus();
  }

  onPageHide(): void {
  }

  public onPatternComplete(input: number[]): void {
    LogUtil.info(`${this.tag} complete`);
    if (input?.toString()) {
      this.password = input.toString().replace(COMMA_SEPARATOR, '');
      this.inputFinish();
    } else {
      LogUtil.error(`${this.tag} complett input error`);
    }
  }

  public onDotConnect(index: number): void {
    LogUtil.info(`${this.tag} onDotConnect`);
    VibratorUtil.startPresetVibration();
  }

  initSourceFlag(): void {
    let params = this.menu.navRouterParam?.config;
    let sourceFlag = '';
    if (params) {
      this.routerParams = params as CheckPsdParams;
      sourceFlag = (params as CheckPsdParams).source;
      this.dynamic = (params as CheckPsdParams).dynamic as boolean;
    }
    if (!sourceFlag) {
      LogUtil.info(`${this.tag} getSourceFlag Router params invalid `);
      return;
    }
    this.sourceFlag = sourceFlag;
  }

  initStatus(): void {
    PasswordUtil.getAuthProperty((data) => {
      if (data?.result === ResultCode.SUCCESS) {
        const visible: boolean = !(data?.freezingTime && data?.freezingTime >= MIN_COUNT_DOWN_TIME);
        this.setVisible(visible);
        LogUtil.info(`${this.tag} getAuthProperty success ${visible}`);
      } else {
        LogUtil.info(`${this.tag} getAuthProperty failed`);
      }
    });
  }

  unsubscribe(): void {
    PasswordUtil.unregisterInputer();
    PasswordUtil.closeSession();
  };

  inputFinish(): void {
    LogUtil.info(`${this.tag} inputFinish in`);
    if (!this.password) {
      LogUtil.info(`${this.tag} inputFinish return : password is none`);
      return;
    }
    this.checkInputPasswordCorrect();
    LogUtil.info(`${this.tag} inputFinish out`);
  }

  doAuthPin(): void {
    PasswordUtil.authPin(this.pinChallenge, this.password, (result, extraInfo) => {
      AppStorage.setOrCreate<number>('pinSubType', this.passwordType);
      if (result === ResultCode.SUCCESS) {
        this.pinToken = extraInfo.token as string;
        if (this.sourceFlag === CHECK_PASSWORD_ENTRY_FLAG || this.sourceFlag === CHANGE_PASSWORD_ENTRY_FLAG) {
          PasswordUtil.unregisterInputer();
          this.menu.pathInfos?.pop();
          if (this.dynamic) {
            this.menu.pushName(this.routerParams?.nextUrl as string, this.menu.navRouterParam);
          } else {
            if (this.routerParams?.nextUrl === NavEntryKey.FACE_AUTH_PREFERENCE_ENTRY ||
              this.routerParams?.nextUrl === NavEntryKey.FACE_AUTH_FEATURE_GUIDE_ENTRY) {
              // ContextManager.get().setAuthToken(SecurityContext.getInstance().getToken());
              // ContextManager.get().setChallenge(SecurityContext.getInstance().getChallenge());
            }
            this.menu.pushName(this.routerParams?.nextUrl as string, this.menu.navRouterParam);
          }
        } else if (this.sourceFlag === VERIFY_PASSWORD_ENTRY_FLAG) {
          this.setDeveloperMode(this.isChecked, extraInfo.token as string);
        } else if (this.sourceFlag === CLOSE_PASSWORD_ENTRY_FLAG) {
          this.deletePassword();
        } else if (this.sourceFlag === DISABLE_OLD_PASSWORD_ENTRY_FLAG) {
          this.disableOldPassword();
        }
      } else {
        passwordResolveInfoManager?.setRemainTimes(extraInfo.remainTimes as number);
        passwordResolveInfoManager?.setFreezingTime(extraInfo.freezingTime as number >= MIN_COUNT_DOWN_TIME ?
          extraInfo.freezingTime as number : 0);
        if (passwordResolveInfoManager?.getRemainTimes() as number <= 0) {
          this.setVisible(false);
          this.publishDataChange(PIN_INPUT_FREEZING);
        } else {
          this.publishDataChange(PATTERN_ERROR);
          this.getPatternLockController().reset();
        }
        this.refreshUi();
        this.unsubscribe();
      }
    });
  }

  checkInputPasswordCorrect(): void {
    LogUtil.info(`${this.tag} checkInputPasswordCorrect in`);
    this.unsubscribe();
    PasswordUtil.registerInputer(this.passwordType);
    if (this.sourceFlag === VERIFY_PASSWORD_ENTRY_FLAG) {
      LogUtil.info(`${this.tag} dsmm open session start`);
      let mode: string = 'developer';
      // dsmm.openSession(mode).then((challenge: ESObject) => {
      //   this.pinChallenge = PasswordUtil.challengeToPinChallenge(challenge);
      //   this.doAuthPin();
      // }).catch((error: Error) => {
      //   LogUtil.info(`${this.tag} open session failed ${error?.message}`);
      // });
    } else {
      PasswordUtil.openSession((data) => {
        this.pinChallenge = data;
        this.doAuthPin();
      });
    }
    LogUtil.info(`${this.tag} checkInputPasswordCorrect out`);
  }

  deletePassword(): void {
    PasswordUtil.deletePassword(this.pinToken, this.password, (result, extraInfo) => {
      if (result === ResultCode.SUCCESS) {
        LogUtil.info(`${this.tag} deletePassword success`);
        emitter.emit({ eventId: EVENT_ID_DELETE_PASSWORD });
        HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysPasswordRelatedEventGroup.SET_BIOLOGY_PASSWORD_OK);
        this.menu.pathInfos?.pop();
        SearchDataController.getInstance().updateChildItemSearchStatus('lock_screen_password', false);
        SearchDataController.getInstance().updateSearchItemStatus('lock_screen_password', true);
        AppLockManager.setEnabled(false);
      } else {
        LogUtil.info(`${this.tag} deletePassword failed`);
      }
      this.unsubscribe();
    });
  }

  async setDeveloperMode(enable: boolean, authToken: string): Promise<void> {
    await SearchDataController.getInstance().updateChildItemSearchStatus('developer_options',
      enable ? true : false, ['debug_outer_app']);
    let ret: number = await SecurityUtil.setDevelopModeNew(enable ? 1 : 0, authToken);
    if (ret === DEV_LOCKED) {
      let developerModeLock: DeveloperModeLock = new DeveloperModeLock();
      developerModeLock.openDeveloperModeLockDialog();
    } else {
      setTimeout(() => {
        SecurityUtil.rebootDevice();
      }, 2000);
    }
  }

  disableOldPassword(): void {
    LogUtil.info('disableOldPassword start');
    let callback: osAccount.IIdmCallback = {
      onResult: (result, extraInfo) => {
        LogUtil.info(`${this.tag} on disableOldPsd result: ${result}`);
        if (result === ResultCode.SUCCESS) {
          SecurityContext.getInstance().emptyOldPasswordCred();
          this.menu.pathInfos?.pop();
          SearchDataController.getInstance().updateSearchItemStatus('expire_lock_screen_password', false);
        } else if (result === ResultCode.SERVICE_ERROR) {
          ToastUtil.showToast(ResourceUtil.getStringSync($r('app.string.service_error')));
        } else {
          LogUtil.info(`${this.tag} deletePassword failed`);
        }
        ;
        this.unsubscribe();
      },
    };
    PasswordUtil.deleteOldPassword(callback);
  }

  registerDataChange(): void {
    LogUtil.info(`${this.tag} registerDataChange`);
    this.registerControllerDataChange(CHECK_COUNT_DOWN_MENU_KEY);
  }

  unRegisterDataChange(): void {
    LogUtil.info(`${this.tag} unRegisterDataChange`);
    this.unRegisterControllerDataChange(CHECK_COUNT_DOWN_MENU_KEY);
  }

  onDataChange(fromKey: string, data: Object): void {
    if (fromKey === CHECK_COUNT_DOWN_MENU_KEY) {
      if (data === PIN_INPUT_FREEZING_END) {
        this.setVisible(true);
        this.getPatternLockController().reset();
        this.refreshUi();
      }
    }
  }
}