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
import { Controller, PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import {
  PageLifecycleMenuGroupController
} from '@ohos/settings.common/src/main/ets/core/controller/LifecycleMenuController';
import {
  ButtonMenuController,
  DialogButtonMenuController,
  MenuController,
  TextInputMenuController,
  UnRespondTouchController
} from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import { DialogLifecycleObserverInterface } from '@ohos/settings.common/src/main/ets/core/lifecycle/Lifecycle';
import { Style } from '@ohos/settings.common/src/main/ets/core/model/menu/ComponetStyle';
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import {
  CREATE_USER_CREDENTIAL,
  EventPool,
  UPDATE_USER_CREDENTIAL
} from '@ohos/settings.common/src/main/ets/event/EventPool';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
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
  ButtonMenuContainerStyle,
  DialogPage,
  DialogTitleMenu,
  DividerMenuGroup,
  NavigationEntry,
  TransparentButtonMenuStyle,
  TransparentButtonStyle
} from '@ohos/settings.uikit/src/main/ets/menus/Menu';
import { CheckPsdParams } from '../model/CheckPasswordPage';
import { NUMBER_PSD_INPUT_KEY, NUMBER_PSD_SUBMIT_BUTTON, NUMBER_PSD_WARNING_TITLE } from '../model/CreateNumberPsdPage';
import {
  CREATE_PASSWORD_ENTRY_FACE_FLAG,
  CREATE_PASSWORD_ENTRY_FLAG,
  isFaceOrFingerprint,
  PRIVACY_CENTER_CREATE_PASSWORD_ENTRY
} from '../model/CreatePsdPage';
import { SafeTipsDialogPage } from '../model/CreateSafeTipsDialogPage';
import { PasswordRiskDialogManager } from '../model/PasswordRiskDialogManager';
import { ChangeToFourTypeController } from './ChangeToFourTypeController';
import { PASSWORD_TYPE_ENTRY } from './CreateMixedPsdController';
import { CHANGE_PASSWORD_TYPE_BUTTON, SIX_DIGIT_PIN_TYPE_ENTRY } from './CreateSixPinController';
import {
  CHANGE_PASSWORD_ENTRY_FLAG,
  ChangePasswordTypeDialogPageStyle,
  ChangePasswordTypeDividerGroupStyle,
  ChangePasswordTypeStyle,
  ChangePasswordTypeTitleStyle,
  DELAY_TIME
} from './PasswordEntryController';
import { PasswordToastController } from './PasswordToastController';

const ENTER_THE_PIN_AGAIN: string = 'enter_the_pin_again';
const PIN_REPEAT_ERROR: string = 'pin_repeat_error';
export const NUMBER_PSD_MAX_LENGTH: number = 32;
export const NUMBER_PSD_MAX_LENGTH_EXT: number = 33;
const NUMBER_PSD_MIN_LENGTH: number = 6;
export const CUSTOM_PIN_TYPE_ENTRY: string = 'custom_pin_type_entry';
const CUSTOM_PIN_CONTINUE_BUTTON: string = 'custom_pin_continue_button';
const CUSTOM_PIN_SURE_BUTTON: string = 'custom_pin_sure_button';
const MSG_INDEX_6: string = '6';
const MSG_INDEX_32: string = '32';
const MSG_INDEX_33: string = '33';
// 96小时口令重置
const EXPIRE_PRE_PIN: string = '96';
export const PASSWORD_INPUT_KEY: string = 'number_psd_input_key';
const EXIT_THIS_PAGE_TIME: number = 400;
const DELAYED_ANNOUNCE: number = 350;

export class CancelButtonStyle extends TransparentButtonStyle {
  public margin :Margin = {
    top: '8vp',
    bottom: '16vp',
  };
}

export class CancelButtonRootContainerStyle extends ButtonMenuContainerStyle {
  public gridMargin: Length = '0vp';
  public gridGutter: Length = '0vp';
  public size: SizeOptions = {
    width: 'calc(100% - 32vp)'
  }
  public margin: Margin = {
    left: '16vp',
    right: '16vp'
  }
}

export class CustomButtonMenuStyle extends TransparentButtonMenuStyle {
  public buttonStyle1 = new CancelButtonStyle();
  public rootContainer = new CancelButtonRootContainerStyle();
}

/**
 * 创建自定义数字密码页面控制器类
 *
 * @since 2023-01-14
 */
@Observed
export class CreateNumberPsdPageController extends PageLifecycleMenuGroupController {
  public tag: string = 'CreateNumberPsdPageController : ';

  constructor(menu: SettingsBaseMenu) {
    super(menu);
    this.menu.title = this.isFromCheckPage() ? $r('app.string.set_new_lock_screen_password_title') :
    $r('app.string.set_lock_screen_pin_title');
  }

  static CreateCreateNumberPsdPageController(menu: SettingsBaseMenu): Controller {
    return new CreateNumberPsdPageController(menu);
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
 * @since 2023-01-14
 */
@Observed
export class NumberPsdMessageController extends UnRespondTouchController {
  public tag: string = 'NumberPsdMessageController : ';
  private sourceFlag: string = '';

  constructor(menu: SettingsBaseMenu) {
    super(menu);
  }

  static CreateNumberPsdMessageController(menu: SettingsBaseMenu): Controller {
    return new NumberPsdMessageController(menu);
  }

  aboutToAppear(): void {
    super.aboutToAppear();
    this.initSourceFlag();
    this.updatePasswordMessage();
  }

  aboutToDisappear(): void {
    super.aboutToDisappear();
  }

  private initSourceFlag(): void {
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

  /**
   * 添加密码信息
   *
   */
  private async updatePasswordMessage(): Promise<void> {
    let message = await ResourceUtil.getAnyStrFormatString($r('app.string.number_password_message'),
      MSG_INDEX_6, MSG_INDEX_32);
    if (this.sourceFlag === CREATE_PASSWORD_ENTRY_FLAG) {
      message = await ResourceUtil.getAnyStrFormatString($r('app.string.fingerprint_new_number_password_message'),
        MSG_INDEX_6, MSG_INDEX_32);
    } else if (this.sourceFlag === CREATE_PASSWORD_ENTRY_FACE_FLAG) {
      message = await ResourceUtil.getAnyStrFormatString($r('app.string.face_new_number_password_message'),
        MSG_INDEX_6, MSG_INDEX_32);
    }
    this.menu.title = message;
    this.refreshUi();
  }

  registerDataChange(): void {
    LogUtil.info(`${this.tag} registerDataChange`);
    this.registerControllerDataChange(NUMBER_PSD_SUBMIT_BUTTON);
  }

  unRegisterDataChange(): void {
    LogUtil.info(`${this.tag} unRegisterDataChange`);
    this.unRegisterControllerDataChange(NUMBER_PSD_SUBMIT_BUTTON);
  }

  onDataChange(fromKey: string, data: string | number): void {
    if (fromKey === NUMBER_PSD_SUBMIT_BUTTON && data === ENTER_THE_PIN_AGAIN) {
      this.menu.title = $r('app.string.enter_pin_again_title');
      this.refreshUi();
      AccessibilityUtils.delayedAnnounceText(this.menu.title, DELAYED_ANNOUNCE);
    }
    if (fromKey === NUMBER_PSD_SUBMIT_BUTTON && data === Constants.repeatPinInput) {
      this.updatePasswordMessage();
    }
  }
}

/**
 * 自定义数字密码菜单控制器类
 *
 * @since 2023-01-14
 */
@Observed
export class NumberPsdInputController extends TextInputMenuController {
  public tag: string = 'NumberPsdInputController : ';
  private btnController: NumberPsdSubmitButtonController;
  private input: string = '';

  constructor(menu: SettingsBaseMenu) {
    super(menu);
    this.btnController =
      menu.getControllerFromPage(NUMBER_PSD_SUBMIT_BUTTON) as NumberPsdSubmitButtonController;
  }

  static CreateNumberPsdInputController(menu: SettingsBaseMenu): Controller {
    return new NumberPsdInputController(menu);
  }

  aboutToAppear(): void {
    super.aboutToAppear();
    setTimeout(() => {
      focusControl.requestFocus(PASSWORD_INPUT_KEY);
    }, 300)
  }

  aboutToDisappear(): void {
    super.aboutToDisappear();
  }

  onTextInputChange(input: string): void {
    this.publishDataChange(input);
    this.input = input;
    if (input?.length > NUMBER_PSD_MAX_LENGTH) {
      this.menu.title = input.substring(0, NUMBER_PSD_MAX_LENGTH);
      this.refreshUi();
      this.notifyChange();
    }
  }

  registerDataChange(): void {
    LogUtil.info(`${this.tag} registerDataChange`);
    this.registerControllerDataChange(NUMBER_PSD_SUBMIT_BUTTON);
  }

  unRegisterDataChange(): void {
    LogUtil.info(`${this.tag} unRegisterDataChange`);
    this.unRegisterControllerDataChange(NUMBER_PSD_SUBMIT_BUTTON);
  }

  onDataChange(fromKey: string, data: string | number): void {
    if (fromKey === NUMBER_PSD_SUBMIT_BUTTON) {
      if (data === ENTER_THE_PIN_AGAIN || data === Constants.repeatPinInput) {
        this.menu.title = '';
        this.refreshUi();
        this.notifyChange();
      }
    }
  }

  onSubmit(enterKey: EnterKeyType): void {
    this.btnController =
      this.menu.getControllerFromPage(NUMBER_PSD_SUBMIT_BUTTON) as NumberPsdSubmitButtonController;
    if (enterKey == (EnterKeyType.Done | EnterKeyType.Go) && this.input.length > 0) {
      this.btnController?.onButton2Click();
    }
  }
}

/**
 * 警告信息控制器类
 *
 * @since 2023-01-14
 */
@Observed
export class NumberPsdWarningMessageController extends UnRespondTouchController {
  public tag: string = 'NumberPsdWarningMessageController : ';
  public textInput: string = '';
  public lastLength: number = 0;

  constructor(menu: SettingsBaseMenu) {
    super(menu);
  }

  static CreateNumberPsdWarningMessageController(menu: SettingsBaseMenu): Controller {
    return new NumberPsdWarningMessageController(menu);
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
    this.registerControllerDataChange(NUMBER_PSD_INPUT_KEY);
    this.registerControllerDataChange(NUMBER_PSD_SUBMIT_BUTTON);
  }

  unRegisterDataChange(): void {
    LogUtil.info(`${this.tag} unRegisterDataChange`);
    this.unRegisterControllerDataChange(NUMBER_PSD_INPUT_KEY);
    this.unRegisterControllerDataChange(NUMBER_PSD_SUBMIT_BUTTON);
  }

  onDataChange(fromKey: string, data: string): void {
    const ninetySixTip = this.getWarningMessage();
    if (fromKey === NUMBER_PSD_INPUT_KEY && typeof data === 'string') {
      this.textInput = data;
      if ((data.length > NUMBER_PSD_MAX_LENGTH) ||
        (this.lastLength === NUMBER_PSD_MAX_LENGTH_EXT && data.length === NUMBER_PSD_MAX_LENGTH)) {
        ResourceUtil.getNumberFormatString($r('app.string.number_password_too_long'), MSG_INDEX_33).then(value => {
          this.menu.title = value;
          this.refreshUi();
        })
      } else if (data.length < NUMBER_PSD_MIN_LENGTH) {
        ResourceUtil.getNumberFormatString($r('app.string.number_password_too_short'), MSG_INDEX_6).then(value => {
          this.menu.title = value;
          this.refreshUi();
        })
      } else if (!PasswordUtil.isOnlyNumber(data)) {
        this.menu.title = $r('app.string.number_password_must_be_number');
        this.refreshUi();
      } else {
        if (this.menu.title != ninetySixTip) {
          setTimeout(() => {
            this.menu.title = ninetySixTip;
            this.refreshUi();
          }, DELAY_TIME);
        }
      }
    } else if (fromKey === NUMBER_PSD_SUBMIT_BUTTON) {
      if (data === PIN_REPEAT_ERROR) {
        this.menu.title = $r('app.string.pin_repeat_error_title');
        this.refreshUi();
        AccessibilityUtils.delayedAnnounceText(this.menu.title, DELAYED_ANNOUNCE);
      } else if (data === ENTER_THE_PIN_AGAIN) {
        this.menu.title = ninetySixTip;
        this.refreshUi();
      }
    }
    this.lastLength = data.length;
  }
}

/**
 * 自定义数字密码提交按钮控制器
 *
 * @since 2023-01-14
 */
@Observed
export class NumberPsdSubmitButtonController extends ButtonMenuController implements DialogLifecycleObserverInterface {
  static CreateNumberPsdSubmitButtonController(menu: SettingsBaseMenu): Controller {
    return new NumberPsdSubmitButtonController(menu);
  }

  public readonly tag: string = 'NumberPsdSubmitButtonController : ';
  private password: string = '';
  private firstPassword: string = '';
  private isInputFirstTime: boolean = true;
  private sourceFlag: string = '';
  private isSubmitting: boolean = false;
  private inputController: NumberPsdInputController;
  private challenge: string = '';
  private hasSession: boolean = false;
  private warnTipController: NumberPsdWarningMessageController;
  private submitTimeId: number | null = null;
  private createTimeId: number | null = null;
  private isHighSecurity: boolean = false;

  constructor(menu: SettingsBaseMenu) {
    super(menu);
    this.inputController =
      menu.getControllerFromPage(NUMBER_PSD_INPUT_KEY) as NumberPsdInputController;
    this.warnTipController =
      menu.getControllerFromPage(NUMBER_PSD_WARNING_TITLE) as NumberPsdWarningMessageController;
    if (menu.navRouterParam?.config) {
      this.challenge = (menu.navRouterParam?.config as Record<string, string>)[AuthConstant.CHALLENGE];
      const hasSession = (menu.navRouterParam?.config as Record<string, boolean>)[AuthConstant.HAS_SESSION];
      if (hasSession) {
        this.hasSession = hasSession;
      }
      LogUtil.info(`${this.tag} init push params, ${this.challenge}.`);
    }
    this.isHighSecurity = WalletManageUtils.checkIfHighSecurity();
    LogUtil.info(`${this.tag} isFromWalletOrHighSecurity is set to ${this.isHighSecurity}`);
  }

  aboutToAppear(): void {
    super.aboutToAppear();
    this.initSourceFlag();
  }

  aboutToDisappear(): void {
    super.aboutToDisappear();
    this.challenge = '';
  }

  onDialogOpen(key?: string, data?: Object): void {
    LogUtil.info(`${this.tag} onDialogOpen`);
  }

  onDialogClose(key?: string, data?: Object): void {
    LogUtil.info(`${this.tag} onDialogClose.`);
    if (data === Constants.continueAnyWay) {
      this.submitNumberPsd();
    } else if (data === Constants.repeatPinInput) {
      this.password = '';
      this.publishDataChange(Constants.repeatPinInput);
    }
  }

  onDialogCancel(key?: string, data?: Object): void {
    LogUtil.info(`${this.tag} onDialogCancel`);
    this.password = '';
    this.publishDataChange(Constants.repeatPinInput);
  }

  public getObserverKey = (): string => {
    LogUtil.info(`${this.tag} getObserverKey`);
    return this.menu?.key as string;
  }

  unsubscribe(): void {
    PasswordUtil.unregisterInputer();
  }

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

  onButton1Click(): void {
    AppStorage.SetOrCreate(BACK_ENTRY, '');
    this.menu.pathInfos?.popToName(NavEntryKey.BIOMETRICS_PASSWORD_ENTRY);
    AbilityUtils.closeUiExtension(AppStorage.get<UIExtensionContentSession>('uiExtensionContentSession'), -1);
    WalletManageUtils.sendAbilityResultToWallet(-1);
  }

  onButton3Click(): void {
    if (this.isInputFirstTime) {
      HiSysEventUtil.reportButtonEvent(CUSTOM_PIN_CONTINUE_BUTTON, '');
    } else {
      HiSysEventUtil.reportButtonEvent(CUSTOM_PIN_SURE_BUTTON, '');
    }
    if (PasswordUtil.isWeakPasswords(this.password) && this.isInputFirstTime &&
      PasswordUtil.isOnlyNumber(this.password) && this.password.length >= NUMBER_PSD_MIN_LENGTH) {
      this.openSafeTipsDialog();
    } else {
      this.submitNumberPsd();
    }
  }

  private openSafeTipsDialog(): void {
    SafeTipsDialogPage.createSafeTipsDialog(this, this.isHighSecurity);
  }

  submitNumberPsd(): void {
    LogUtil.info(`${this.tag} submitNumberPsd in`);
    if (this.isInputFirstTime && this.password.length < NUMBER_PSD_MIN_LENGTH) {
      LogUtil.info(`${this.tag} password below min length`);
      return;
    }
    if (!PasswordUtil.isOnlyNumber(this.password)) {
      LogUtil.info(`${this.tag} password is not a number`);
      return;
    }
    if (this.isInputFirstTime) {
      this.firstInputFinish();
    } else {
      if (this.password != this.firstPassword) {
        this.inputController?.getTextInputController().setTextSelection(0, this.password.length);
        this.password = '';
        LogUtil.info(`${this.tag} number password not match`);
        this.publishDataChange(PIN_REPEAT_ERROR);
      } else {
        if (this.isSubmitting) {
          LogUtil.info(`${this.tag} repeated submit`);
          return;
        }
        PasswordUtil.hasPinPassword((hasPinPassword) => {
          if (hasPinPassword) {
            this.updateNumberPsd();
          } else {
            this.createNumberPsd();
          }
        });
      }
    }
    LogUtil.info(`${this.tag} submitNumberPsd out`);
  }

  private async firstInputFinish(): Promise<void> {
    LogUtil.info(`${this.tag} firstInputFinish`);
    let privateUserId: number = await AccountUtil.getPrivateSpaceUserId();
    if (privateUserId !== AccountConstants.INVALID_PRIVATE_SPACE_USER_ID) {
      // 存在隐私用户
      let isCurrentPrivate: boolean = await AccountUtil.isCurrentPrivate();
      LogUtil.info(`${this.tag} has private user update`);
      let userId: number = isCurrentPrivate ? AccountConstants.MAIN_USER : privateUserId;
      PasswordUtil.checkUserPassword(PinSubType.PIN_NUMBER, userId, this.password, (isSuccess: boolean) => {
        LogUtil.info(`${this.tag} same with cross user ${isCurrentPrivate} ${isSuccess}`);
        let tipMessage: string = isCurrentPrivate ?
        ResourceUtil.getStringSync($r('app.string.same_with_main_space_password')) :
        ResourceUtil.getStringSync($r('app.string.same_with_private_space_password_tip'));
        if (isSuccess) {
          this.inputController.getTextInputController().setTextSelection(0, this.password.length);
          this.warnTipController.menu.title = tipMessage;
          this.password = '';
          this.refreshUi();
          return;
        }
        LogUtil.info(`${this.tag} not same with cross user`);
        this.doPublishDataChange();
      });
    } else {
      this.doPublishDataChange();
    }
  }

  private doPublishDataChange(): void {
    this.firstPassword = this.password;
    this.isInputFirstTime = false;
    this.password = '';
    this.publishDataChange(ENTER_THE_PIN_AGAIN);
    ResourceUtil.getCapitalString($r('app.string.dialog_sure')).then(value => {
      if (!(this.menu instanceof ButtonMenu)) {
        LogUtil.info(`${this.tag} menu is not ButtonMenu`);
        return;
      }
      this.menu.buttonTittle3 = value;
      this.refreshUi();
    });
  }

  updateNumberPsd(): void {
    LogUtil.info(`${this.tag} updateNumberPsd start`);
    this.submitTimeId = null;
    this.isSubmitting = true;
    PasswordUtil.registerInputer(PinSubType.PIN_NUMBER);
    PasswordUtil.updatePassword(PinSubType.PIN_NUMBER, this.password, SecurityContext.getInstance().getToken(),
      (result, extraInfo) => {
        if (result === ResultCode.SUCCESS) {
          LogUtil.info(`${this.tag} UPDATE_PSD_SUCCESS`);
          EventPool.getInstance().publish({
            name: UPDATE_USER_CREDENTIAL,
            param: String(PinSubType.PIN_NUMBER),
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
          }).catch(()=>{
            LogUtil.error(`${this.tag} get string err`);
          });
          this.menu.pathInfos?.popToName(NavEntryKey.BIOMETRICS_PASSWORD_ENTRY);
        }
        AbilityUtils.closeUiExtension(AppStorage.get<UIExtensionContentSession>('uiExtensionContentSession'), result);
        WalletManageUtils.sendAbilityResultToWallet(result);
        this.unsubscribe();
        PasswordUtil.closeSession();
        this.submitTimeId = setTimeout(() => {
          this.isSubmitting = false;
        }, EXIT_THIS_PAGE_TIME);
      });
  }

  createNumberPsd(): void {
    LogUtil.info(`${this.tag} createNumberPsd start`);
    this.createTimeId = null;
    this.isSubmitting = true;
    this.unsubscribe();
    PasswordUtil.registerInputer(PinSubType.PIN_NUMBER);
    if (!this.hasSession) {
      PasswordUtil.openSession(() => {
        this.createPsdInner();
      });
    } else {
      this.createPsdInner();
    }
  }

  private createPsdInner(): void {
    PasswordUtil.createPassword(PinSubType.PIN_NUMBER, this.password, (result) => {
      if (result === ResultCode.SUCCESS) {
        LogUtil.info(`${this.tag} CREATE_PSD_SUCCESS`);
        if (isFaceOrFingerprint(this.sourceFlag) && PasswordUtil.isBiometricsPasswordEntry()) {
          PasswordUtil.closeSession();
          return;
        }
        if (this.sourceFlag === CREATE_PASSWORD_ENTRY_FLAG) {
          this.createNumberPsdEntryFlag();
        } else if (this.sourceFlag === CREATE_PASSWORD_ENTRY_FACE_FLAG) {
          this.createNumberPsdEntryFaceFlag();
        } else {
          LogUtil.info(`${this.tag} other sourceFlag`);
          if (!CheckEmptyUtils.checkStrIsEmpty(this.challenge)) {
            PinAuthUtil.challenge2Token(this.challenge, result);
            return;
          }
          EventPool.getInstance().publish({
            name: CREATE_USER_CREDENTIAL,
            param: String(PinSubType.PIN_NUMBER),
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
      WalletManageUtils.sendAbilityResultToWallet(result);
      this.unsubscribe();
      this.createTimeId = setTimeout(() => {
        this.isSubmitting = false;
      }, EXIT_THIS_PAGE_TIME);
    });
  }

  protected registerDataChange(): void {
    this.registerControllerDataChange(NUMBER_PSD_INPUT_KEY);
  }

  protected unRegisterDataChange(): void {
    this.unRegisterControllerDataChange(NUMBER_PSD_INPUT_KEY);
  }

  private createNumberPsdEntryFlag(): void {
    LogUtil.info(`${this.tag} createNumberPsdEntryFlag silent auth begin`);
    PasswordUtil.silenceAuthPin().then(()=>{
      LogUtil.info(`${this.tag} createNumberPsdEntryFlag silent auth success`);
      this.menu.pathInfos?.pop();
      this.menu.pushName(NavEntryKey.FINGERPRINT_SETTING_ENTRY, undefined);
    }).catch(()=>{
      LogUtil.error(`${this.tag} createNumberPsdEntryFlag silent auth failed`);
      if (!this.hasSession) {
        PasswordUtil.closeSession();
      }
    })
  }

  private createNumberPsdEntryFaceFlag(): void {
    LogUtil.info(`${this.tag} createNumberPsdEntryFaceFlag silent auth begin`);
    PasswordUtil.silenceAuthPin().then(()=>{
      LogUtil.info(`${this.tag} createNumberPsdEntryFaceFlag silent auth success`);
      // ContextManager.get().setAuthToken(SecurityContext.getInstance().getToken());
      // ContextManager.get().setChallenge(SecurityContext.getInstance().getChallenge());
      this.menu.pathInfos?.pop();
    }).catch(()=>{
      LogUtil.error(`${this.tag} createNumberPsdEntryFaceFlag silent auth failed`);
      if (!this.hasSession) {
        PasswordUtil.closeSession();
      }
    })
  }

  onDataChange(fromKey: string, data: string | number) {
    if (fromKey === NUMBER_PSD_INPUT_KEY && typeof data === 'string') {
      this.password = data;
    }
  }
}

/**
 * 自定义数字密码切换按钮控制器
 *
 * @since 2023-01-14
 */
export class NumberPsdChangeTypeController extends ButtonMenuController {
  public readonly tag: string = 'NumberPsdChangeTypeController : ';

  static CreateNumberPsdChangeTypeController(menu: SettingsBaseMenu): Controller {
    return new NumberPsdChangeTypeController(menu);
  }

  onButton1Click(): boolean {
    HiSysEventUtil.reportButtonEvent(CHANGE_PASSWORD_TYPE_BUTTON, '');
    this.openChangeTypeDialog();
    return true;
  }

  private getNewDividerMenuGroupArray(): Array<NavigationEntry> {
    let res: NavigationEntry[] = [];
    let highSecurityFlag = WalletManageUtils.checkIfHighSecurity();
    LogUtil.info(`${this.tag},the high security falg is set to ${highSecurityFlag}}`);
    if (!highSecurityFlag) {
      // res.push(
      //   new NavigationEntry({
      //     key: 'change_number_to_four_entry',
      //     index: 20,
      //     controller: {
      //       createControllerConstructorInter: ChangeToFourTypeController.CreateChangeToFourTypeController,
      //     },
      //     pathInfos: this.menu.pathInfos,
      //     navRouterParam: this.menu.navRouterParam,
      //     style: new ChangePasswordTypeStyle() as Style,
      //   })
      // )
    }
    res.push(
      new NavigationEntry({
          key: 'change_number_to_six_entry',
          index: 10,
          controller: {
            createControllerConstructorInter:
            ChangeNumberToSixTypeController.CreateChangeNumberToSixTypeController,
          },
          pathInfos: this.menu.pathInfos,
          navRouterParam: this.menu.navRouterParam,
          style: new ChangePasswordTypeStyle() as Style,
        })
      // ,
      // new NavigationEntry({
      //     key: 'change_number_to_mixed_entry',
      //     index: 20,
      //     title: $r('app.string.mixed_password_type'),
      //     controller: {
      //       createControllerConstructorInter:
      //       ChangeNumberToMixedTypeController.CreateChangeNumberToMixedTypeController,
      //     },
      //     pathInfos: this.menu.pathInfos,
      //     navRouterParam: this.menu.navRouterParam,
      //     style: new ChangePasswordTypeStyle() as Style,
      //   })
    )
    return res;
  }


  private openChangeTypeDialog(): void {
    LogUtil.info(`${this.tag} openChangeTypeDialog `);
    let detail = new DialogPage({
      pageUrl: 'pages/password/CreateNumberPsdSettings/changeTypeDialog',
      title: $r('app.string.change_unlock_method'),
      scrollable: false,
      pageStyle: new ChangePasswordTypeDialogPageStyle(),
      style: new ChangePasswordTypeDialogPageStyle(),
    });
    detail.addMenus(
      [
        new DialogTitleMenu(
          {
            key: 'change_number_to_other_group',
            index: 10,
            title: $r('app.string.select_unlock_method'),
            style: new ChangePasswordTypeTitleStyle()
          }
        ),
        new DividerMenuGroup(
          {
            key: 'change_number_to_other_dialog_group',
            index: 1,
            style: new ChangePasswordTypeDividerGroupStyle()
          },
          this.getNewDividerMenuGroupArray()
        ),
        new ButtonMenu(
          {
            key: 'number_psd_cancel_button',
            index: 40,
            buttonTittle1: $r('app.string.button_tittle_cancel'),
            controller: {
              createControllerConstructorInter: DialogButtonMenuController.CreateDialogButtonMenuController,
            },
            style: new CustomButtonMenuStyle(),
          }
        )
      ]
    );
    this.openDialog(detail, true);
  }

  protected registerDataChange(): void {
    this.registerControllerDataChange(NUMBER_PSD_SUBMIT_BUTTON);
  }

  protected unRegisterDataChange(): void {
    this.unRegisterControllerDataChange(NUMBER_PSD_SUBMIT_BUTTON);
  }

  onDataChange(fromKey: string, data: string | number): void {
    if (fromKey === NUMBER_PSD_SUBMIT_BUTTON) {
      if (data === ENTER_THE_PIN_AGAIN) {
        this.setVisible(false);
      }
    }
  }
}

/**
 * 自定义数字密码切6位数字密码控制器
 *
 * @since 2023-01-17
 */
export class ChangeNumberToSixTypeController extends MenuController {
  public tag: string = 'ChangeNumberToSixTypeController: ';

  static CreateChangeNumberToSixTypeController(menu: SettingsBaseMenu): Controller {
    return new ChangeNumberToSixTypeController(menu);
  }

  aboutToAppear(): void {
    super.aboutToAppear();
    this.updateTitle();
  }

  private async updateTitle(): Promise<void> {
    let message = await ResourceUtil.getNumberFormatString($r('app.string.pin_type'), MSG_INDEX_6);
    this.menu.title = message;
    this.refreshUi();
  }

  onMenuClick(): boolean {
    PasswordRiskDialogManager.setRiskDialogOpen(false);
    LogUtil.info(`${this.tag} onMenuClick change number to six`);
    HiSysEventUtil.reportEntryEvent(SIX_DIGIT_PIN_TYPE_ENTRY, '');
    AppStorage.SetOrCreate(BACK_ENTRY, NavEntryKey.BIOMETRICS_PASSWORD_ENTRY);
    this.menu.pathInfos?.pop();
    this.menu.pushPath(NavEntryKey.LOCK_SCREEN_PASSWORD_ENTRY, this.menu.navRouterParam as PushParam);
    this.closeSelf();
    return true;
  }
}

/**
 * 自定义数字密码切混合密码控制器
 *
 * @since 2023-01-17
 */
export class ChangeNumberToMixedTypeController extends MenuController {
  public tag: string = 'ChangeNumberToMixedTypeController: ';

  static CreateChangeNumberToMixedTypeController(menu: SettingsBaseMenu): Controller {
    return new ChangeNumberToMixedTypeController(menu);
  }

  aboutToAppear(): void {
    super.aboutToAppear();
  }

  onMenuClick(): boolean {
    LogUtil.info(`${this.tag} onMenuClick change number to mixed`);
    HiSysEventUtil.reportEntryEvent(PASSWORD_TYPE_ENTRY, '');
    AppStorage.SetOrCreate(BACK_ENTRY, NavEntryKey.BIOMETRICS_PASSWORD_ENTRY);
    this.menu.pathInfos?.pop();
    this.menu.pushPath(NavEntryKey.CREATE_MIX_PSD_ENTRY, this.menu.navRouterParam as PushParam);
    this.closeSelf();
    return true;
  }
}
