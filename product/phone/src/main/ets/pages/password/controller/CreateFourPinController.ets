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
  PasswordCircleController,
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
import { PasswordRiskDialogManager } from '../model/PasswordRiskDialogManager';
import { CustomButtonMenuStyle } from './CreateNumberPsdController';
import {
  CHANGE_PASSWORD_ENTRY_FLAG,
  ChangePasswordTypeDialogPageStyle,
  ChangePasswordTypeDividerGroupStyle,
  ChangePasswordTypeStyle,
  ChangePasswordTypeTitleStyle
} from './PasswordEntryController';
import { PasswordToastController } from './PasswordToastController';

export const FOUR_PIN_LENGTH: number = 4;

const ENTER_THE_PIN_AGAIN: string = 'enter_the_pin_again';
const PIN_REPEAT_ERROR: string = 'pin_repeat_error';
const PIN_REPEAT_WITH_MAIN: string = 'pin_repeat_with_main';
const PIN_REPEAT_WITH_PRIVATE: string = 'pin_repeat_with_private';
const REMEMBER_PIN_TIP: string = 'remember_pin_tip';
const FOUR_PIN_CIRCLE_KEY: string = 'four_pin_circle_key';
const SIX_PIN_LENGTH: number = 6;
// 96小时口令重置
const EXPIRE_PRE_PIN: string = '96';

export const CHANGE_PASSWORD_TYPE_BUTTON: string = 'change_password_type_button';

export const FOUR_DIGIT_PIN_TYPE_ENTRY: string = 'four_digit_pin_type_entry';

export const PASSWORD_INPUT_KEY: string = 'PasswdTextInputKey_four_pin_circle_key';

const INPUT_CHECK_DELAY: number = 50;
const DELAYED_ANNOUNCE: number = 350;


/**
 * 创建4位数字密码页面控制器类
 *
 * @since 2024-06-24
 */
@Observed
export class CreateFourPinPageController extends PageLifecycleMenuGroupController {
  public tag: string = 'CreateFourPinPageController : ';

  constructor(menu: SettingsBaseMenu) {
    super(menu);
    this.menu.title = this.isFromCheckPage() ? $r('app.string.set_new_lock_screen_password_title') :
    $r('app.string.set_lock_screen_pin_title');
  }

  static CreateCreateFourPinPageController(menu: SettingsBaseMenu): Controller {
    return new CreateFourPinPageController(menu);
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
 * @since 2024-06-26
 */
@Observed
export class FourPinMessageController extends UnRespondTouchController {
  public tag: string = 'FourPinMessageController : ';

  constructor(menu: SettingsBaseMenu) {
    super(menu);
  }

  static CreateFourPinMessageController(menu: SettingsBaseMenu): Controller {
    return new FourPinMessageController(menu);
  }

  aboutToAppear(): void {
    super.aboutToAppear();
  }

  aboutToDisappear(): void {
    super.aboutToDisappear();
  }

  registerDataChange(): void {
    LogUtil.info(`${this.tag} registerDataChange`);
    this.registerControllerDataChange(FOUR_PIN_CIRCLE_KEY);
  }

  unRegisterDataChange(): void {
    LogUtil.info(`${this.tag} unRegisterDataChange`);
    this.unRegisterControllerDataChange(FOUR_PIN_CIRCLE_KEY);
  }

  onDataChange(fromKey: string, data: string): void {
    if (fromKey !== FOUR_PIN_CIRCLE_KEY) {
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
 * 4位密码圆圈菜单控制器类
 *
 * @since 2023-06-26
 */
@Observed
export class FourPinCircleController extends PasswordCircleController implements DialogLifecycleObserverInterface {
  public tag: string = 'FourPinCircleController : ';
  private password: string = '';
  private firstPassword: string = '';
  private passwordCircle: string[] = ['', '', '', ''];
  private isInputFirstTime: boolean = true;
  private sourceFlag: string = '';
  private challenge: string = '';
  private hasSession: boolean = false;
  protected maxLength: number = 4;

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
  }

  static CreateFourPinCircleController(menu: SettingsBaseMenu): Controller {
    return new FourPinCircleController(menu);
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
    setTimeout(() => {
      focusControl.requestFocus(PASSWORD_INPUT_KEY);
    }, 300)
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
    if (value.length > FOUR_PIN_LENGTH) {
      LogUtil.info(`${this.tag} value length is invalid`);
      return;
    }
    this.password = value;
    let length = value.length;
    for (let i = 0; i < FOUR_PIN_LENGTH; i++) {
      if (i < length) {
        this.passwordCircle[i] = value[i];
      } else {
        this.passwordCircle[i] = '';
      }
    }
    if (PasswordUtil.isPinNumber4(this.password)) {
      if (PasswordUtil.isWeakPasswords(this.password) && this.isInputFirstTime) {
        this.openSafeTipsDialog();
      } else {
        this.inputFinish();
      }
    }
  }

  private openSafeTipsDialog(): void {
    SafeTipsDialogPage.createSafeTipsDialog(this);
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
      this.doPasswordSubmit();
    }
    LogUtil.info(`${this.tag} inputFinish out`);
  }

  private doPasswordSubmit(): void {
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

  clearInput(): void {
    this.password = '';
    this.passwordCircle = ['', '', '', ''];
  }

  updatePin(): void {
    PasswordUtil.registerInputer(PinSubType.PIN_FOUR);
    PasswordUtil.updatePassword(PinSubType.PIN_FOUR, this.password, SecurityContext.getInstance().getToken(),
      (result, extraInfo) => {
        if (result == ResultCode.SUCCESS) {
          LogUtil.info(this.tag + 'UPDATE_PSD_SUCCESS');
          EventPool.getInstance().publish({
            name: UPDATE_USER_CREDENTIAL,
            param: String(PinSubType.PIN_FOUR),
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
      });
  }

  createPin(): void {
    LogUtil.info(`${this.tag} createPin start`);
    this.unsubscribe();
    PasswordUtil.registerInputer(PinSubType.PIN_FOUR);
    if (!this.hasSession) {
      PasswordUtil.openSession(() => {
        PasswordUtil.createPassword(PinSubType.PIN_FOUR, this.password, (result) => {
          this.processResult(result);
          WalletManageUtils.sendAbilityResultToWallet(result);
        });
      });
    } else {
      PasswordUtil.createPassword(PinSubType.PIN_FOUR, this.password, (result) => {
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
      PasswordUtil.checkUserPassword(PinSubType.PIN_FOUR, userId, this.password, (isSuccess: boolean) => {
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
    this.password = '';
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
        LogUtil.info(`${this.tag} silent auth begin`);
        PasswordUtil.silenceAuthPin().then(() => {
          LogUtil.info(`${this.tag} silent auth success`);
          this.menu.pathInfos?.pop();
          this.menu.pushName(NavEntryKey.FINGERPRINT_SETTING_ENTRY, undefined);
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
          param: String(PinSubType.PIN_FOUR),
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
 * @since 2024-06-26
 */
@Observed
export class FourPinWarningMessageController extends UnRespondTouchController {
  public tag: string = 'FourPinWarningMessageController : ';

  constructor(menu: SettingsBaseMenu) {
    super(menu);
  }

  static CreateFourPinWarningMessageController(menu: SettingsBaseMenu): Controller {
    return new FourPinWarningMessageController(menu);
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
    this.registerControllerDataChange(FOUR_PIN_CIRCLE_KEY);
  }

  unRegisterDataChange(): void {
    LogUtil.info(`${this.tag} unRegisterDataChange`);
    this.unRegisterControllerDataChange(FOUR_PIN_CIRCLE_KEY);
  }

  onDataChange(fromKey: string, data: string): void {
    if (fromKey !== FOUR_PIN_CIRCLE_KEY) {
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

/**
 * 4位密码切6位数字密码控制器
 *
 * @since 2024-06-26
 */
export class ChangeFourToSixTypeController extends MenuController {
  public tag: string = 'ChangeFourToSixTypeController: ';

  static CreateChangeFourToSixTypeController(menu: SettingsBaseMenu): Controller {
    return new ChangeFourToSixTypeController(menu);
  }

  aboutToAppear(): void {
    super.aboutToAppear();
    this.updateTitle();
  }

  private async updateTitle(): Promise<void> {
    let message = await ResourceUtil.getNumberFormatString($r('app.string.pin_type'), SIX_PIN_LENGTH.toString());
    this.menu.title = message;
    this.refreshUi();
  }

  onMenuClick(): boolean {
    PasswordRiskDialogManager.setRiskDialogOpen(false);
    LogUtil.info(`${this.tag} onMenuClick change four to six`);
    HiSysEventUtil.reportEntryEvent(FOUR_DIGIT_PIN_TYPE_ENTRY, '');
    AppStorage.SetOrCreate(BACK_ENTRY, NavEntryKey.BIOMETRICS_PASSWORD_ENTRY);
    this.menu.pathInfos?.pop();
    this.menu.pushPath(NavEntryKey.LOCK_SCREEN_PASSWORD_ENTRY, this.menu.navRouterParam as PushParam);
    this.closeSelf();
    return true;
  }
}

/**
 * 4位数字密码切换按钮控制器
 *
 * @since 2026-06-24
 */
export class FourPinChangeTypeController extends ButtonMenuController {
  public readonly tag: string = 'FourPinChangeTypeController : ';

  onButton1Click(): boolean {
    HiSysEventUtil.reportButtonEvent(CHANGE_PASSWORD_TYPE_BUTTON, '');
    this.openChangeTypeDialog();
    return true;
  }

  static CreateFourPinChangeTypeController(menu: SettingsBaseMenu): Controller {
    return new FourPinChangeTypeController(menu);
  }

  private openChangeTypeDialog(): void {
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
            key: 'change_four_to_other_group',
            index: 10,
            title: $r('app.string.select_unlock_method'),
            style: new ChangePasswordTypeTitleStyle()
          }
        ),
        new DividerMenuGroup(
          {
            key: 'change_four_to_other_dialog_group',
            index: 1,
            style: new ChangePasswordTypeDividerGroupStyle()
          },
          [
            new NavigationEntry(
              {
                key: 'change_four_to_six_entry',
                index: 20,
                controller: {
                  createControllerConstructorInter: ChangeFourToSixTypeController.CreateChangeFourToSixTypeController,
                },
                pathInfos: this.menu.pathInfos,
                navRouterParam: this.menu.navRouterParam,
                style: new ChangePasswordTypeStyle() as Style,
              }
            ),
            new NavigationEntry(
              {
                key: 'change_four_to_number_entry',
                index: 10,
                title: $r('app.string.number_password_type'),
                controller: {
                  createControllerConstructorInter:
                  ChangeFourToNumberTypeController.CreateChangeFourToNumberTypeController,
                },
                pathInfos: this.menu.pathInfos,
                navRouterParam: this.menu.navRouterParam,
                style: new ChangePasswordTypeStyle() as Style,
              }
            )
            // ,
            // new NavigationEntry(
            //   {
            //     key: 'change_four_to_mixed_entry',
            //     index: 20,
            //     title: $r('app.string.mixed_password_type'),
            //     controller: {
            //       createControllerConstructorInter:
            //       ChangeFourToMixedTypeController.CreateChangeFourToMixedTypeController,
            //     },
            //     pathInfos: this.menu.pathInfos,
            //     navRouterParam: this.menu.navRouterParam,
            //     style: new ChangePasswordTypeStyle() as Style,
            //   }
            // ),
          ]
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
    this.registerControllerDataChange(FOUR_PIN_CIRCLE_KEY);
  }

  protected unRegisterDataChange(): void {
    this.unRegisterControllerDataChange(FOUR_PIN_CIRCLE_KEY);
  }

  onDataChange(fromKey: string, data: string) {
    if (fromKey === FOUR_PIN_CIRCLE_KEY) {
      if (data === ENTER_THE_PIN_AGAIN) {
        this.setVisible(false);
      }
    }
  }
}

/**
 * 4位数字密码切自定义数字密码控制器
 *
 * @since 2024-06-24
 */
export class ChangeFourToNumberTypeController extends MenuController {
  public tag: string = 'ChangeFourToNumberTypeController: ';

  static CreateChangeFourToNumberTypeController(menu: SettingsBaseMenu): Controller {
    return new ChangeFourToNumberTypeController(menu);
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
 * 4位数字密码切混合密码控制器
 *
 * @since 2024-06-24
 */
export class ChangeFourToMixedTypeController extends MenuController {
  public tag: string = 'ChangeFourToMixedTypeController: ';

  static CreateChangeFourToMixedTypeController(menu: SettingsBaseMenu): Controller {
    return new ChangeFourToMixedTypeController(menu);
  }

  aboutToAppear(): void {
    super.aboutToAppear();
  }

  onMenuClick(): boolean {
    LogUtil.info(`${this.tag} onMenuClick change four to mixed`);
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysBiometricsPasswordEventGroup.SET_UP_HYBRID_PASSWORD);
    AppStorage.SetOrCreate(BACK_ENTRY, NavEntryKey.BIOMETRICS_PASSWORD_ENTRY);
    this.menu.pathInfos?.pop();
    this.menu.pushPath(NavEntryKey.CREATE_MIX_PSD_ENTRY, this.menu.navRouterParam);
    this.closeSelf();
    return true;
  }
}
