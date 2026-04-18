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
// import appLock from '@hms.security.appLock';
import { Controller, PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { CheckPsdParams } from '../model/CheckPasswordPage';
import {
  DefaultDialogPageStyle,
  DialogTitleMenuStyle,
  DividerGroupStyle,
  GroupDividerStyle,
  NavigationEntryMenuStyle,
  PageTitleContainerStyle,
  RootContainerStyle,
  TransparentButtonMenuStyle,
  ButtonMenuContainerStyle,
  PhoneDialogTitleMenuStyle,
  TransparentButtonMenu,
  DefaultPhoneDialogPageStyle,
  DialogMessageStyle,
  PhoneMsgTextStyle,
  DialogPage,
  DialogMessageMenu,
  DialogTitleMenu,
  PhoneMsgIconStyle,
  ClosePasswordConfirmButtonStyle,
  DialogListMessageMenu
} from '@ohos/settings.uikit/src/main/ets/menus/Menu';
import osAccount from '@ohos.account.osAccount';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { EVENT_ID_DELETE_PASSWORD } from '@ohos/settings.common/src/main/ets/event/types';
import emitter from '@ohos.events.emitter';
import { PasswordUtil, PinSubType, ResultCode, VALIDITY_TIMES_DEFAULT, COUNT_DOWN_ONE_MIN, COUNT_DOWN_ONE_HOUR,
  MILE_SECOND_TO_SECOND, SPACE_PLACE_HOLDER_STRING, oldPasswordInfo }
  from '@ohos/settings.common/src/main/ets/utils/PasswordUtil';
import { ContainerStyle, Style } from '@ohos/settings.common/src/main/ets/core/model/menu/ComponetStyle';
import {
  PageLifecycleMenuController
} from '@ohos/settings.common/src/main/ets/core/controller/LifecycleMenuController';
import {
  SettingsBaseMenu,
  SettingsBaseMenuData
} from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import {
  ButtonMenuController,
  MenuController
} from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { PasswordConstant } from '@ohos/settings.common/src/main/ets/constant/PasswordConstant';
import { WalletManageUtils } from '@ohos/settings.common/src/main/ets/utils/WalletManageUtils';
import { PreferencesUtil } from '@ohos/settings.common/src/main/ets/utils/PreferencesUtil';
import { PasswordManager } from '@ohos/settings.common/src/main/ets/passwordManager/PasswordManager';
import { HiSysPasswordRelatedEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { AccountUtil } from '@ohos/settings.common/src/main/ets/utils/AccountUtil';
import { PasswordResolveInfoManager } from '@ohos/settings.privacy/src/main/ets/PasswordResolveInfoManager';
import { SearchDataController } from '@ohos/settings.search/src/main/ets/controller/SearchController';
import { Timer } from '@ohos/settings.common/src/main/ets/utils/Timer';

/**
 * 锁屏密码卡片 key 值
 */
export const GROUP_LOCK_SCREEN_PASSWORD: string = 'group_lock_screen_password';

/**
 * 修改和关闭锁屏密码卡片 key 值
 */
export const GROUP_CLOSE_AND_CHANGE_LOCK_SCREEN_PASSWORD: string = 'group_close_and_change_lock_screen_password';

/**
 * 立即使旧密码过期卡片 key 值
 */
export const GROUP_DISABLE_OLD_LOCK_SCREEN_PASSWORD: string = 'group_disable_old_lock_screen_password';

/**
 * 立即使旧密码过期卡片footer key 值
 */
export const GROUP_DISABLE_OLD_LOCK_SCREEN_PASSWORD_TIP: string = 'group_disable_old_lock_screen_password_tip';

const CLOSE_PASSWORD_WARNING_DIALOG_URL: string =
  'pages/biometricsandpassword/BiometricsAndPasswordSettings/close_pwd_dialog';
const CLOSE_PASSWORD_WARNING_DIALOG_TITLE: string = 'close_password_warning_dialog_title';
const CLOSE_PASSWORD_WARNING_DIALOG_MESSAGE: string = 'close_password_warning_dialog_message';
const CLOSE_PASSWORD_WARNING_DIALOG_ABILITY_APPLOCK: string = 'close_password_warning_dialog_ability_applock';
const CLOSE_PASSWORD_WARNING_DIALOG_ABILITY_FINGERPRINT: string = 'close_password_warning_dialog_ability_fingerprint';
const CLOSE_PASSWORD_WARNING_DIALOG_ABILITY_FACECHECKER: string = 'close_password_warning_dialog_ability_facechecker';
const CLOSE_PASSWORD_WARNING_DIALOG_ABILITY_HIGHSECURITY: string = 'close_password_warning_dialog_ability_highsecurity';
const CLOSE_PASSWORD_WARNING_DIALOG_BUTTON: string = 'close_password_warning_dialog_button';
const UPDATE_PASSWORD_WARNING_DIALOG_URL: string =
  'pages/biometricsandpassword/BiometricsAndPasswordSettings/update_pwd_dialog';
const DISABLE_OLD_PASSWORD_WARNING_DIALOG_URL: string =
  'pages/biometricsandpassword/BiometricsAndPasswordSettings/disable_old_pwd_dialog';
const DISABLE_OLD_PASSWORD_WARNING_DIALOG_TITLE: string = 'disable_old_password_title';
const DISABLE_OLD_PASSWORD_WARNING_DIALOG_MESSAGE: string = 'disable_old_password_dialog_warning_message';
const DISABLE_OLD_PASSWORD_WARNING_DIALOG_BUTTON: string = 'disable_old_password_warning_dialog_button';

/**
 * 跳转校验密码页面关闭和更改密码的flag
 *
 */
export const CHANGE_PASSWORD_ENTRY_FLAG: string = 'change_password';

export const CHECK_PASSWORD_ENTRY_FLAG: string = 'check_password';

export const CLOSE_PASSWORD_ENTRY_FLAG: string = 'close_password';

export const DISABLE_OLD_PASSWORD_ENTRY_FLAG: string = 'diable_old_password';

export const VERIFY_PASSWORD_ENTRY_FLAG: string = 'verify_password';

export const DELAY_TIME: number = 50;

const TIME_INTERVAL = 1000;

export class PasswordButtonStyle extends ButtonMenuContainerStyle {
  public margin: Margin = { top: '8vp', bottom: '16vp' };
  public gridGutter: Length = '16vp';
  public gridMargin: Length = '0vp';
}

export class ButtonStyle extends TransparentButtonMenuStyle {
  public rootContainer = new PasswordButtonStyle();
}

export class ClosePwdButtonStyle extends ButtonStyle {
  public buttonStyle2: ClosePasswordConfirmButtonStyle = new ClosePasswordConfirmButtonStyle();
}

export class BiometricsDialogStyle extends DefaultPhoneDialogPageStyle {
  public padding: Padding = {
    top: '0',
    bottom: '0',
    left: '0',
    right: '0'
  };
  public margin: Margin = {
    left: '16vp',
    right: '16vp'
  }
}

export class BiometricsDialogMsgStyle extends DialogMessageStyle {
  public rootContainer = new BiometricsDialogMsgContainerStyle();
  public title = new PhoneMsgTextStyle();
}

export class PhoneMsgHeaderTextStyle extends PhoneMsgTextStyle {
  public margin: Margin = {
    bottom: $r('sys.float.padding_level4')
  };
}

export class BiometricsDialogListMsgStyle extends BiometricsDialogMsgStyle {
  public icon = new PhoneMsgIconStyle();
}

export class BiometricsDialogHeaderMsgStyle extends BiometricsDialogMsgStyle {
  public title = new PhoneMsgHeaderTextStyle();
}

export class BiometricsDialogMsgContainerStyle extends ContainerStyle {
  public margin: Margin = {
    top: $r('app.float.margin_0'),
    bottom: $r('app.float.margin_0')
  };
  public size: SizeOptions = {
    width: '100%',
  };
  public padding: Padding = {
    left: '8vp',
    right: '8vp'
  };
}

export class BiometricsPatternDialogMsgStyle extends DialogMessageStyle {
  public rootContainer = new BiometricsPatternDialogMsgContainerStyle();
  public title = new PhoneMsgTextStyle();
}

export class BiometricsPatternDialogMsgContainerStyle extends ContainerStyle {
  public margin: Margin = {
    top: $r('app.float.margin_32'),
    bottom: $r('app.float.margin_0')
  };
  public size: SizeOptions = {
    width: '100%',
  };
  public padding: Padding = {
    left: '8vp',
    right: '8vp'
  };
}

/**
 * “锁屏密码”菜单+“修改锁屏密码”菜单+“关闭锁屏密码”菜单所在 group 菜单的控制器
 *
 * @since 2023-01-12
 */
@Observed
export class PasswordEntryController extends PageLifecycleMenuController {
  public tag: string = 'PasswordEntryController : ';
  private isRefreshed: boolean = false;
  protected isHideRemoveFromUxTree: boolean = false;

  constructor(menu: SettingsBaseMenu) {
    super(menu);
    this.setVisible(false);
  }

  static CreatePasswordEntryController(menu: SettingsBaseMenu): Controller {
    return new PasswordEntryController(menu);
  }

  aboutToAppear(): void {
    super.aboutToAppear();
    this.refreshMenuGroupVisiable();
    this.registerEvent();
  }

  aboutToDisappear(): void {
    super.aboutToDisappear();
    this.unRegisterEvent();
  }

  onPageShow(): void {
    this.refreshMenuGroupVisiable();
  }

  refreshMenuGroupVisiable(): void {
    LogUtil.info(`${this.tag} refreshMenuGroupVisiable`);
    if (this.isRefreshed) {
      LogUtil.info(`${this.tag} already refreshed ui`);
      this.isRefreshed = false;
      return;
    }
    PasswordUtil.hasPinPassword((hasPinPassword) => {
      LogUtil.info(`${this.tag} hasPinPassword ${hasPinPassword} ${this.getKey()}`);
      if (this.getKey() === GROUP_LOCK_SCREEN_PASSWORD) {
        this.setVisible(!hasPinPassword);
        this.refreshUi();
      } else if (this.getKey() == GROUP_CLOSE_AND_CHANGE_LOCK_SCREEN_PASSWORD) {
        this.setVisible(hasPinPassword);
        this.refreshUi();
      }
    });
  }

  private registerEvent(): void {
    LogUtil.info(`${this.tag} registerEvent`);
    emitter.on({ eventId: EVENT_ID_DELETE_PASSWORD }, () => {
      LogUtil.info(`${this.tag} received delete password event`);
      this.isRefreshed = true;
      if (this.getKey() === GROUP_LOCK_SCREEN_PASSWORD) {
        this.setVisible(true);
      } else if (this.getKey() == GROUP_CLOSE_AND_CHANGE_LOCK_SCREEN_PASSWORD) {
        this.setVisible(false);
      }
      this.refreshUi();
      this.isRefreshed = false;
    })
  }

  private unRegisterEvent(): void {
    LogUtil.info(`${this.tag} unRegisterEvent`);
    emitter.off(EVENT_ID_DELETE_PASSWORD);
  }

  isVisibleStatus(): boolean {
    LogUtil.info(`${this.tag} isVisibleStatus ${this.isVisible} ${this.isHideRemoveFromUxTree}`);
    return (this.isVisible || !this.isHideRemoveFromUxTree);
  }
}

/**
 * “立即使旧密码过期”菜单所在 group 菜单的控制器
 *
 * @since 2025-06-10
 */
@Observed
export class DisableOldPasswordEntryController extends PageLifecycleMenuController {
  public tag: string = 'DisabledOldPasswordEntryController : ';
  private isRefreshed: boolean = false;
  protected isHideRemoveFromUxTree: boolean = false;
  public passwordResolveInfoManager: PasswordResolveInfoManager | null = null;
  /**
   * 倒计时定时器
   */
  private timer: Timer | null = null;

  /**
   * 旧密码信息
   */
  private oldPasswordInfo: oldPasswordInfo = {
    hasOldPassword: false,
    validityPeriod: VALIDITY_TIMES_DEFAULT
  };

  constructor(menu: SettingsBaseMenu) {
    super(menu);
    this.setVisible(false);
  }

  static CreateDisableOldPasswordEntryController(menu: SettingsBaseMenu): Controller {
    return new DisableOldPasswordEntryController(menu);
  }

  aboutToAppear(): void {
    LogUtil.info(`${this.tag} aboutToAppear`);
    super.aboutToAppear();
    this.refreshMenuGroupVisiable();
    this.registerEvent();
  }

  aboutToDisappear(): void {
    super.aboutToDisappear();
    this.unRegisterEvent();
    this.stopTimer();
  }

  onPageShow(): void {
    this.refreshMenuGroupVisiable();
  }

  refreshMenuGroupVisiable(): void {
    LogUtil.info(`${this.tag} refreshMenuGroupVisiable`);
    if (this.isRefreshed) {
      LogUtil.info(`${this.tag} already refreshed ui`);
      this.isRefreshed = false;
      return;
    }
    PasswordUtil.hasOldCredential((hasOldPasswordInfo) => {
      const showOldPassword: boolean = hasOldPasswordInfo.hasOldPassword && hasOldPasswordInfo.validityPeriod > 0;
      SearchDataController.getInstance().updateSearchItemStatus('expire_lock_screen_password', showOldPassword);
      this.setVisible(showOldPassword);
      this.refreshUi();
      if (showOldPassword) {
        this.oldPasswordInfo.validityPeriod = hasOldPasswordInfo.validityPeriod as number;
        this.oldPasswordInfo.credentialId = hasOldPasswordInfo.credentialId;
        this.oldPasswordInfo.hasOldPassword = hasOldPasswordInfo.hasOldPassword;
        this.oldPasswordInfo.authSubType = hasOldPasswordInfo.authSubType;
        this.startCountDownTimer();
      }
    });
  }

  private getCountDownWarningTipMessage(millisecondsTime: number): ResourceStr {
    if (!millisecondsTime || millisecondsTime < 0) {
      LogUtil.info(`${this.tag} millisecondsTime is invalid.`);
      return SPACE_PLACE_HOLDER_STRING;
    }

    let secondsTime = millisecondsTime / MILE_SECOND_TO_SECOND;
    let hour: number = Math.floor(secondsTime / COUNT_DOWN_ONE_HOUR);
    let min: number = Math.ceil((secondsTime - hour * COUNT_DOWN_ONE_HOUR) / COUNT_DOWN_ONE_MIN);
    hour = hour + Math.floor(min / 60);
    min = min % 60;
    let minuteStr: string = ResourceUtil.getPluralStringByNameSync('time_minute', min);
    let hourStr: string = ResourceUtil.getPluralStringByNameSync('time_hour', hour);
    let hourMinuteStr: string = ResourceUtil.getAnyStrFormatStringByName('time_hour_minute', hourStr, minuteStr);
    if (hour >= 1) {
      return min !== 0 ? $r('app.string.reset_password_in_ninety_six_hours_detail_tip', hourMinuteStr) :
      $r('app.string.reset_password_in_ninety_six_hours_detail_tip', hourStr);
    }

    if (min >= 1) {
      return $r('app.string.reset_password_in_ninety_six_hours_detail_tip', minuteStr);
    }
    return SPACE_PLACE_HOLDER_STRING;
  }

  startCountDownTimer(): void {
    if (this.menu.key === GROUP_DISABLE_OLD_LOCK_SCREEN_PASSWORD_TIP) {
      this.menu.title = this.getCountDownWarningTipMessage(this.oldPasswordInfo.validityPeriod);
    }
    this.stopTimer();
    this.newTimer((validityPeriod: number) => {
      if (validityPeriod > VALIDITY_TIMES_DEFAULT && this.menu.key === GROUP_DISABLE_OLD_LOCK_SCREEN_PASSWORD_TIP) {
          this.menu.title = this.getCountDownWarningTipMessage(validityPeriod);
      }
      if (validityPeriod <= VALIDITY_TIMES_DEFAULT) {
        this.setVisible(false);
        SearchDataController.getInstance().updateSearchItemStatus('expire_lock_screen_password', false);
      }
    });
    this.startTimer();
  }

  private registerEvent(): void {
    LogUtil.info(`${this.tag} registerEvent`);
    emitter.on({ eventId: EVENT_ID_DELETE_PASSWORD }, () => {
      LogUtil.info(`${this.tag} received delete password event`);
      this.isRefreshed = true;
      if (this.getKey() == GROUP_DISABLE_OLD_LOCK_SCREEN_PASSWORD ||
        this.getKey() == GROUP_DISABLE_OLD_LOCK_SCREEN_PASSWORD_TIP) {
        this.setVisible(false);
        SearchDataController.getInstance().updateSearchItemStatus('expire_lock_screen_password', false);
      }
      this.refreshUi();
    });
  }

  private unRegisterEvent(): void {
    LogUtil.info(`${this.tag} unRegisterEvent`);
    emitter.off(EVENT_ID_DELETE_PASSWORD);
  }

  isVisibleStatus(): boolean {
    LogUtil.info(`${this.tag} isVisibleStatus ${this.isVisible} ${this.isHideRemoveFromUxTree}`);
    return (this.isVisible || !this.isHideRemoveFromUxTree);
  }


  stopTimer(): void {
    this.timer?.stop();
    this.timer = null;
  }

  startTimer(): void {
    this.timer?.start();
  }

  newTimer(onRefresh: (validityPeriod: number) => void): void {
    this.timer = new Timer(TIME_INTERVAL, () => {
      this.oldPasswordInfo.validityPeriod -= TIME_INTERVAL;
      onRefresh(this.oldPasswordInfo.validityPeriod);
      if (this.oldPasswordInfo.validityPeriod <= 0) {
        this.timer?.stop();
      }
    });
  }
}

/**
 * “校验锁屏密码”菜单控制器
 *
 * @since 2023-01-12
 */
@Observed
export class VerifyPasswordEntryController extends MenuController {
  static CreateVerifyPasswordEntryController(menu: SettingsBaseMenu): Controller {
    return new VerifyPasswordEntryController(menu);
  }

  public tag: string = 'VerifyPasswordEntryController : ';

  constructor(menu: SettingsBaseMenu) {
    super(menu);
  }

  onMenuClick(): boolean {
    LogUtil.info(`${this.tag} Router to change password page`);
    let params: CheckPsdParams =
      new CheckPsdParams(VERIFY_PASSWORD_ENTRY_FLAG, NavEntryKey.LOCK_SCREEN_PASSWORD_ENTRY);
    this.menu.pushName(NavEntryKey.CHECK_PSD_ENTRY, new PushParam(params));
    return true;
  }
}

/**
 * 创建锁屏密码控制器
 */
@Observed
export class SetPasswordEntryController extends MenuController {
  static CreateSetPasswordEntryController(menu: SettingsBaseMenu): Controller {
    menu.isGrayed = PreferencesUtil.getSync(NavEntryKey.LOCK_SCREEN_PASSWORD_ENTRY, false) as boolean;
    return new SetPasswordEntryController(menu);
  }

  public tag: string = 'SetPasswordEntryController : ';

  constructor(menu: SettingsBaseMenu) {
    super(menu);
  }

  onMenuClick(): boolean {
    LogUtil.info(`${this.tag} Router to set password page`);
    let params: CheckPsdParams = new CheckPsdParams('', '');
    this.menu.pushName(PasswordManager.getEntryKey(), new PushParam(params));
    return true;
  }
}


/**
 * “更改锁屏密码”菜单控制器
 *
 * @since 2023-01-12
 */
@Observed
export class ChangePasswordEntryController extends MenuController {
  static CreateChangePasswordEntryController(menu: SettingsBaseMenu): Controller {
    menu.isGrayed = PreferencesUtil.getSync(NavEntryKey.CHANGE_LOCK_SCREEN_PASSWORD_ENTRY, false) as boolean;
    return new ChangePasswordEntryController(menu);
  }

  public tag: string = 'ChangePasswordEntryController : ';

  constructor(menu: SettingsBaseMenu) {
    super(menu);
  }

  onMenuClick(): boolean {
    this.changePswMenuClick();
    return true;
  }

  private toCheckPswPage(): void {
    LogUtil.info(`${this.tag} Router to change password page`);
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysPasswordRelatedEventGroup.SET_IDENTIFY_PASSWORD);
    let params: CheckPsdParams = new CheckPsdParams(CHANGE_PASSWORD_ENTRY_FLAG, PasswordManager.getEntryKey());
    this.menu.pushName(NavEntryKey.CHECK_PSD_ENTRY, new PushParam(params));
  }

  private changePswMenuClick(): void {
    PasswordUtil.getAuthProperty((data) => {
      if (data?.result !== ResultCode.SUCCESS) {
        LogUtil.error(`${this.tag} getAuthProperty error`);
        return;
      }
      if (data.authSubType.toString() === PinSubType.PIN_PATTERN.toString()) {
        this.showChangePasswordDialog();
        return;
      }
      this.toCheckPswPage();
    });
  }

  /**
   * 弹窗提示用户关闭密码的后果，确认后才能继续关闭密码
   */
  private showChangePasswordDialog(): void {
    let rootPage = new DialogPage({
      pageUrl: UPDATE_PASSWORD_WARNING_DIALOG_URL,
      scrollable: false,
      style: new BiometricsDialogStyle(),
    });
    this.initChangePatternPasswordWarningDialog(rootPage);
    this.openDialog(rootPage, true);
  }

  /**
   * 初始化“提示用户关闭密码的后果”的弹窗的内部界面
   *
   * @param rootPage 弹窗根布局
   */
  private initChangePatternPasswordWarningDialog(rootPage: DialogPage): void {
    rootPage.addMenus([
      new DialogMessageMenu(
        {
          key: 'change_pattern_password_message',
          index: 20,
          title: ResourceUtil.getAnyNumFormatStringSync($r('app.string.pattern_password_change_warn_message'),
            PasswordConstant.SIX_PIN_LENGTH, PasswordConstant.FOUR_PIN_LENGTH),
          style: new BiometricsPatternDialogMsgStyle() as Style,
        }
      ),
      new TransparentButtonMenu({
        key: 'change_pattern_password_bottom_btns',
        menuType: 'DivideButton',
        timestamp: 2,
        index: 40,
        buttonTittle1: $r('app.string.dialog_cancel'),
        buttonTittle2: $r('app.string.dialog_continue_to_update'),
        controller: {
          createControllerConstructorInter:
          ChangePatternPwdWarningDialogButtonController.CreateChangePatternPwdWarningDialogButtonController,
        },
        pathInfos: this.menu.pathInfos,
        style: new ButtonStyle(),
        navRouterParam: this.menu.navRouterParam,
      })
    ]);
  }
}

/**
 * “关闭锁屏密码”菜单控制器
 *
 * @since 2023-01-12
 */
@Observed
export class ClosePasswordEntryController extends MenuController {
  public tag: string = 'ClosePasswordEntryController : ';

  constructor(menu: SettingsBaseMenu) {
    super(menu);
  }

  static CreateClosePasswordEntryController(menu: SettingsBaseMenu): Controller {
    menu.isGrayed = PreferencesUtil.getSync(NavEntryKey.CLOSE_LOCK_SCREEN_PASSWORD_ENTRY, false) as boolean;
    return new ClosePasswordEntryController(menu);
  }

  onMenuClick(): boolean {
    let highSecurityLevel = WalletManageUtils.checkIfHighSecurity();
    LogUtil.info(`${this.tag} highSecurityLevel is set to ${highSecurityLevel}`)
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysPasswordRelatedEventGroup.SET_BIOLOGY_OFF_PASSWORD);
    this.showCloseLockScreenPasswordDialog();
    return true;
  }

  /**
   * 弹窗提示用户关闭密码的后果，确认后才能继续关闭密码
   */
  private showCloseLockScreenPasswordDialog(): void {
    let rootPage = new DialogPage({
      pageUrl: CLOSE_PASSWORD_WARNING_DIALOG_URL,
      title: $r('app.string.close_lock_screen_password_title'),
      scrollable: false,
      style: new BiometricsDialogStyle(),
    });
    let userIdentityManager = new osAccount.UserIdentityManager();
    userIdentityManager.getAuthInfo().then(async (authInfo) => {
      let isAuthTypeFace: boolean = false;
      let isAuthTypeFingerprint: boolean = false;
      for (let i = 0; i < authInfo?.length; i++) {
        if (authInfo[i]?.authType === osAccount.AuthType.FACE) {
          isAuthTypeFace = true
        }
        if (authInfo[i]?.authType === osAccount.AuthType.FINGERPRINT) {
          isAuthTypeFingerprint = true;
        }
      }
      let highSecurityLevel: boolean = WalletManageUtils.checkIfHighSecurity();
      let isAppLockEnabled: boolean = await this.getAppLockEnabled();
      let dialogMessage: Resource =
        this.initClosePasswordDialogMessage(isAuthTypeFace, isAuthTypeFingerprint, isAppLockEnabled, highSecurityLevel);
      this.initClosePasswordWarnningDialog(rootPage, dialogMessage, isAuthTypeFace, isAuthTypeFingerprint,
        isAppLockEnabled, highSecurityLevel);
      this.openDialog(rootPage, true);
    });
  }

  /**
   * 初始化“提示用户关闭密码的后果”的弹窗提示语
   *
   * @param isAuthTypeFace 是否录入人脸识别
   * @param isAuthTypeFingerprint 是否录入指纹
   * @param isAppLockEnabled 应用锁
   * @param highSecurityLevel 高安全级别
   * @returns 弹窗提示语
   */
  private initClosePasswordDialogMessage(isAuthTypeFace: boolean, isAuthTypeFingerprint: boolean,
    isAppLockEnabled: boolean, highSecurityLevel: boolean): Resource {
    let dialogMessage: Resource | undefined = undefined;
    dialogMessage = (isAppLockEnabled || isAuthTypeFace || isAuthTypeFingerprint || highSecurityLevel) ?
    $r('app.string.close_lock_screen_password_dialog_warning_message_list') :
    $r('app.string.close_lock_screen_password_dialog_warning_message');
    return dialogMessage;
  }

  /**
   * 获取应用锁与密码的关联状态，密码锁可用，且只跟锁屏密码绑定
   *
   * @returns 应用锁是否只跟锁屏密码绑定
   */
  private async getAppLockEnabled(): Promise<boolean> {
    let isAppLockEnabled: boolean = false;
    // try {
    //   // 有应用锁功能
    //   isAppLockEnabled = await appLock.isEnabled();
    //   let uid = await AccountUtil.getCurrentUserId();
    //   let appAuthTypes: appLock.AuthType[] = await appLock.getAllowedAuthTypes(uid);
    //   // 有关联隐私密码
    //   if (appAuthTypes.includes(appLock.AuthType.PRIVACY_PIN)) {
    //     isAppLockEnabled = false;
    //   }
    // } catch (error) {
    //   LogUtil.error(`${this.tag} try to get appLock status failed. ${error?.code} ${error?.message}`);
    // }
    return isAppLockEnabled;
  }

  /**
   * 根据当前已开启的依赖密码的功能项获取展示列表
   *
   * @param isAuthTypeFace 人脸识别
   * @param isAuthTypeFingerprint 指纹
   * @param isAppLockEnabled 应用锁
   * @param highSecurityLevel 高安全级别
   * @returns 已开启的项目列表结构的数据
   */
  private getDotMessageList(isAuthTypeFace: boolean, isAuthTypeFingerprint: boolean, isAppLockEnabled: boolean,
    highSecurityLevel: boolean):
    SettingsBaseMenuData[] {
    let result: SettingsBaseMenuData[] = [];
    // 存在人脸识别
    if (isAuthTypeFace) {
      result.push(new DialogMessageMenu({
        key: CLOSE_PASSWORD_WARNING_DIALOG_ABILITY_FACECHECKER,
        symbolIcon: $r('sys.symbol.dot'),
        title: $r('app.string.close_lock_screen_password_dialog_item_face_checker'),
        style: new BiometricsDialogListMsgStyle() as Style
      }));
    }
    // 存在指纹
    if (isAuthTypeFingerprint) {
      result.push(new DialogMessageMenu({
        key: CLOSE_PASSWORD_WARNING_DIALOG_ABILITY_FINGERPRINT,
        symbolIcon: $r('sys.symbol.dot'),
        title: $r('app.string.close_lock_screen_password_dialog_item_fingerprint_settings'),
        style: new BiometricsDialogListMsgStyle() as Style
      }));
    }
    // 存在应用锁
    if (isAppLockEnabled) {
      result.push(new DialogMessageMenu({
        key: CLOSE_PASSWORD_WARNING_DIALOG_ABILITY_APPLOCK,
        symbolIcon: $r('sys.symbol.dot'),
        title: $r('app.string.close_lock_screen_password_dialog_item_application_lock'),
        style: new BiometricsDialogListMsgStyle() as Style
      }));
    }
    // 高安全级别
    if (highSecurityLevel) {
      result.push(new DialogMessageMenu({
        key: CLOSE_PASSWORD_WARNING_DIALOG_ABILITY_HIGHSECURITY,
        symbolIcon: $r('sys.symbol.dot'),
        title: $r('app.string.close_lock_screen_password_dialog_item_wallet_card'),
        style: new BiometricsDialogListMsgStyle() as Style
      }));
    }
    return result;
  }


  /**
   * 初始化“提示用户关闭密码的后果”的弹窗的内部界面
   *
   * @param rootPage 弹窗根布局
   * @param dialogMessage 描述文案
   * @param isAuthTypeFace 人脸识别
   * @param isAuthTypeFingerprint 指纹
   * @param isAppLockEnabled 应用锁
   * @param highSecurityLevel 高安全级别
   */
  private initClosePasswordWarnningDialog(rootPage: DialogPage, dialogMessage: Resource, isAuthTypeFace: boolean,
    isAuthTypeFingerprint: boolean, isAppLockEnabled: boolean, highSecurityLevel: boolean): void {
    let dotMessageGroup: SettingsBaseMenuData[] =
      this.getDotMessageList(isAuthTypeFace, isAuthTypeFingerprint, isAppLockEnabled, highSecurityLevel);
    rootPage.addMenus([
      new DialogTitleMenu({
        key: CLOSE_PASSWORD_WARNING_DIALOG_TITLE,
        index: 10, // 用于排序
        title: rootPage.title,
        style: new PhoneDialogTitleMenuStyle(),
      }),
      new DialogListMessageMenu(
        {
          key: CLOSE_PASSWORD_WARNING_DIALOG_MESSAGE,
          index: 20,
          title: dialogMessage,
          style: (dotMessageGroup.length ? new BiometricsDialogHeaderMsgStyle() :
            new BiometricsDialogMsgStyle()) as Style,
          textSiblings: dotMessageGroup
        }
      ),
      new TransparentButtonMenu({
        key: CLOSE_PASSWORD_WARNING_DIALOG_BUTTON,
        menuType: 'DivideButton',
        timestamp: 2,
        index: 40,
        buttonTittle1: $r('app.string.dialog_cancel'),
        buttonTittle2: $r('app.string.dialog_disable'),
        controller: {
          createControllerConstructorInter:
          ClosePasswordWarningDialogButtonController.CreateClosePasswordWarningDialogButtonController,
        }, //remind-del-tag:new ClosePasswordWarningDialogButtonController(new SettingsBaseMenu({}))
        pathInfos: this.menu.pathInfos,
        style: new ClosePwdButtonStyle(),
        navRouterParam: this.menu.navRouterParam,
      })
    ]);
  }
}

/**
 * 提示用户关闭密码的后果的弹窗的按钮控制器
 *
 * @since 2023-01-12
 */
@Observed
class ClosePasswordWarningDialogButtonController extends ButtonMenuController {
  public tag: string = 'ClosePasswordWarningDialogButtonController : ';
  private isDialogClosedClick: boolean = false;

  constructor(menu: SettingsBaseMenu) {
    super(menu);
  }

  static CreateClosePasswordWarningDialogButtonController(menu: SettingsBaseMenu): Controller {
    return new ClosePasswordWarningDialogButtonController(menu);
  }

  onButton1Click(): void {
    this.closeSelf();
  }

  onButton2Click(): void {
    if (this.isDialogClosedClick) {
      LogUtil.warn(`${this.tag} close dialog clicked, not deal`);
      return;
    }
    this.isDialogClosedClick = true;
    LogUtil.info(`${this.tag} Router to close password page`);
    this.closeSelf();
    let params: CheckPsdParams = new CheckPsdParams(CLOSE_PASSWORD_ENTRY_FLAG);
    this.menu.pushName(NavEntryKey.CHECK_PSD_ENTRY, new PushParam(params));
  }
}

/**
 * 提示用户关闭密码的后果的弹窗的按钮控制器
 *
 * @since 2024-06-24
 */
@Observed
class ChangePatternPwdWarningDialogButtonController extends ButtonMenuController {
  public tag: string = 'ChangePatternPwdWarningDialogButtonController : ';

  constructor(menu: SettingsBaseMenu) {
    super(menu);
  }

  static CreateChangePatternPwdWarningDialogButtonController(menu: SettingsBaseMenu): Controller {
    return new ChangePatternPwdWarningDialogButtonController(menu);
  }

  onButton1Click(): void {
    this.closeSelf();
  }

  onButton2Click(): void {
    LogUtil.info(`${this.tag} Router to change password page`);
    this.closeSelf();
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysPasswordRelatedEventGroup.SET_IDENTIFY_PASSWORD);
    let params: CheckPsdParams = new CheckPsdParams(CHANGE_PASSWORD_ENTRY_FLAG, PasswordManager.getEntryKey());
    this.menu.pushName(NavEntryKey.CHECK_PSD_ENTRY, new PushParam(params));
  }
}

/**
 * "立即使旧密码过期"菜单控制器
 *
 * @since 2025-06-10
 */
@Observed
export class DisableOldPasswordDialogController extends MenuController {
  public tag: string = 'DisableOldPasswordDialogController : ';
  constructor(menu: SettingsBaseMenu) {
    super(menu);
  }

  static CreateDisableOldPasswordDialogController(menu: SettingsBaseMenu): Controller {
    menu.isGrayed = PreferencesUtil.getSync(NavEntryKey.DISABLE_OLD_LOCK_SCREEN_PASSWORD_ENTRY, false) as boolean;
    return new DisableOldPasswordDialogController(menu);
  }

  onMenuClick(): boolean {
    let eventParams: Record<string, string> = {};
    eventParams.BUTTON_TYPE = '0';
    HiSysEventUtil.reportBehaviorEventByUE(HiSysPasswordRelatedEventGroup.SET_BIOLOGY_EXPIRE_PRE_PASSWORD, eventParams);
    this.showDisableOldLockScreenPasswordDialog();
    return true;
  }

  /**
   * 弹窗提示用户立即使旧密码过期的后果，确认后才能继续过期旧密码
   */
  private showDisableOldLockScreenPasswordDialog(): void {
    let rootPage = new DialogPage({
      pageUrl: DISABLE_OLD_PASSWORD_WARNING_DIALOG_URL,
      title: $r('app.string.expire_pre_password_or_pin_title'),
      scrollable: false,
      style: new BiometricsDialogStyle(),
    });
    let userIdentityManager = new osAccount.UserIdentityManager();
    userIdentityManager.getAuthInfo().then(async (authInfo) => {
      this.initClosePasswordWarnningDialog(rootPage);
      this.openDialog(rootPage, true);
    });
  }

  /**
   * 初始化“提示用户关闭密码的后果”的弹窗的内部界面
   *
   * @param rootPage 弹窗根布局
   */
  private initClosePasswordWarnningDialog(rootPage: DialogPage): void {
    rootPage.addMenus([
      new DialogTitleMenu({
        key: DISABLE_OLD_PASSWORD_WARNING_DIALOG_TITLE,
        index: 10, // 用于排序
        title: rootPage.title,
        style: new PhoneDialogTitleMenuStyle(),
      }),
      new DialogListMessageMenu(
        {
          key: DISABLE_OLD_PASSWORD_WARNING_DIALOG_MESSAGE,
          index: 20,
          title: $r('app.string.disable_old_password_dialog_warning_message'),
          style: new BiometricsDialogMsgStyle(),
        }
      ),
      new TransparentButtonMenu({
        key: DISABLE_OLD_PASSWORD_WARNING_DIALOG_BUTTON,
        menuType: 'DivideButton',
        timestamp: 2,
        index: 40,
        buttonTittle1: $r('app.string.dialog_cancel'),
        buttonTittle2: $r('app.string.expire_immediately_dialog_button'),
        controller: {
          createControllerConstructorInter:
          DisableOldPasswordWarningDialogButtonController.CreateDisableOldPasswordWarningDialogButtonController,
        },
        pathInfos: this.menu.pathInfos,
        style: new ClosePwdButtonStyle(),
        navRouterParam: this.menu.navRouterParam,
        extra: this.menu.extra
      })
    ]);
  }
}

/**
 * 提示用户立即使旧密码过期的后果的弹窗的按钮控制器
 *
 * @since 2025-06-10
 */
@Observed
class DisableOldPasswordWarningDialogButtonController extends ButtonMenuController {
  public tag: string = 'DisableOldPasswordWarningDialogButtonController : ';
  private isDialogClosedClick: boolean = false;

  constructor(menu: SettingsBaseMenu) {
    super(menu);
  }

  static CreateDisableOldPasswordWarningDialogButtonController(menu: SettingsBaseMenu): Controller {
    return new DisableOldPasswordWarningDialogButtonController(menu);
  }

  onButton1Click(): void {
    let eventParam: Record<string, string> = {};
    eventParam.BEHAVIOR_TYPE = '2';
    HiSysEventUtil.reportBehaviorEventByUE(HiSysPasswordRelatedEventGroup.SET_BIOLOGY_EXPIRE_PRE_PASSWORD, eventParam);
    this.closeSelf();
  }

  onButton2Click(): void {
    if (this.isDialogClosedClick) {
      LogUtil.warn(`${this.tag} close dialog clicked, not deal`);
      return;
    }
    this.isDialogClosedClick = true;
    LogUtil.info(`${this.tag} Router to close password page`);
    this.closeSelf();
    let eventParam: Record<string, string> = {};
    eventParam.BEHAVIOR_TYPE = '1';
    HiSysEventUtil.reportBehaviorEventByUE(HiSysPasswordRelatedEventGroup.SET_BIOLOGY_EXPIRE_PRE_PASSWORD, eventParam);
    let params: CheckPsdParams = new CheckPsdParams(DISABLE_OLD_PASSWORD_ENTRY_FLAG);
    this.menu.pushName(NavEntryKey.CHECK_PSD_ENTRY, new PushParam(params));
  }
}

/**
 * 自定义切换密码类型文本样式
 *
 * @since 2023-08-31
 */
class ChangePasswordTypeRootContainer extends RootContainerStyle {
  public padding: Padding = {
    left: $r('app.float.margin_8'),
    right: $r('app.float.margin_8'),
    top: $r('app.float.margin_0'),
    bottom: $r('app.float.margin_0'),
  };
  public margin: Margin = {
    left: $r('app.float.length_12'),
    right: $r('app.float.length_12'),
  }
  public size: SizeOptions = {
    width: 'calc(100% - 24vp)'
  }
  public gridMargin: Length = '0vp';
  public gridGutter: Length = '0vp';
}

export class ChangePasswordTypeDividerGroupStyle extends DividerGroupStyle {
  public divider = new ChangePasswordTypeDividerStyle();
}

export class ChangePasswordTypeDividerStyle extends GroupDividerStyle {
  public startMargin: Length = $r('app.float.padding_24');
  public endMargin: Length = $r('app.float.padding_24');
}

export class ChangePasswordTypeTitleStyle extends DialogTitleMenuStyle {
  public rootContainer?: ContainerStyle = new ChangePasswordTypeTitleContainerStyle();
}

class ChangePasswordTypeTitleContainerStyle extends PageTitleContainerStyle {
  public padding: Padding = {
    left: $r('app.float.padding_24'),
    right: $r('app.float.padding_24'),
    top: $r('app.float.margin_0'),
    bottom: $r('app.float.margin_0'),
  };
  public margin: Margin = {
    top: '0',
  };
}

/**
 * 自定义切换密码类型样式
 *
 * @since 2023-08-31
 */
export class ChangePasswordTypeStyle extends NavigationEntryMenuStyle {
  public rootContainer = new ChangePasswordTypeRootContainer();
}

export class ChangePasswordTypeDialogPageStyle extends DefaultDialogPageStyle {
  public rootContainer = new PwdDialogContainerStyle();
  public padding: Padding = {
    top: $r('app.float.length_0'),
    bottom: $r('app.float.length_0'),
    left: $r('app.float.length_0'),
    right: $r('app.float.length_0'),
  };
}

class PwdDialogContainerStyle extends ContainerStyle {
  public borderRadius: Resource = $r('sys.float.ohos_id_corner_radius_dialog');
  public gridGutter: Length = 0;
  public gridMargin: Length = 0;
  public margin: Margin = {
    left: $r('app.float.length_0'),
    right: $r('app.float.length_0'),
  };
  public padding: Padding = {
    left: $r('app.float.length_4'),
    right: $r('app.float.length_4'),
  };
}