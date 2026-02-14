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
import account_osAccount from '@ohos.account.osAccount';
import common from '@ohos.app.ability.common';
import UIExtensionContentSession from '@ohos.app.ability.UIExtensionContentSession';
import Want from '@ohos.app.ability.Want';
import { BusinessError } from '@ohos.base';
import buffer from '@ohos.buffer';
import { ColumnSystemManager } from '@ohos/settings.common/src/main/ets/window/ColumnSystemManager';
import { HiSysUserEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { HiSysUsersException } from '@ohos/settings.common/src/main/ets/systemEvent/ExceptionEventConsts';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { PasswordUtil, ResultCode } from '@ohos/settings.common/src/main/ets/utils/PasswordUtil';
import { StringUtil } from '@ohos/settings.common/src/main/ets/utils/StringUtil';
import { SearchDataController } from '@ohos/settings.search/src/main/ets/controller/SearchController';
import { CreateLocalUserCustomDialog } from '../components/CreateLocalUserCustomDialog';
import { CardContainerView } from '../../Wlan/view/CardContainerView';
import { UserEventReporter } from '../common/models/EventReporter';
import { generateFaultEventValue, parseResource, validatePassword } from '../common/utils/ValidateUtil';
import { CreateLocalUserCallback, UserUtil } from '../common/utils/UserUtil';
import { PasswordIconVM } from '../components/PasswordInput/PasswordIconVM';
import { PasswordIconWrapper } from '../components/PasswordInput/PasswordInput';
import { PassWordInputSlot } from '../components/PasswordInput/PassWordInputSlot';
import { TextInputItem } from '../components/TextInputItem';
import { ConfirmAlertDialog } from '../components/ConfirmAlertDialog';

/**
 * Ability结束后，传值给OOBE，该值与OOBE相约定
 */
enum AbilityTerminateResult {
  LAST_STEP = 101,
  NEXT_STEP = 100,
}

/**
 * 双空间参数
 */
export enum DoubleSpaceParamEnum {
  DOUBLE_SPACE = 'true',
  NORMAL_VERSION = 'false',
}

/**
 * 用户昵称输入框最大长度，超过该长度无法输入
 */
const USER_NAME_TEXT_INPUT_MAX_LENGTH: number = 255;

/**
 * 密码输入框最大长度，超过该长度无法输入
 */
const PASSWORD_TEXT_INPUT_MAX_LENGTH: number = 32;

/**
 * 密码输入框最小长度，小于该长度无法输入
 */
const PASSWORD_TEXT_INPUT_MIN_LENGTH: number = 6;
const TAG: string = 'OobeLocalUser';
const DELAY_CREATE_USER_TIME: number = 250;
const UNICODE: buffer.BufferEncoding = 'utf-8';
const CARD_CONTENT_WIDTH: number = 560;
const DEFAULT_USER_ID: number = 100;
const CARD_SCROLL: number = 20;

let nickNameReg: RegExp = new RegExp('^(?=.*[/<>\\\\|:*?\"])', 'g');
let nickNameRegReplace: RegExp = new RegExp('[/<>\\\\|:*?\"]', 'g');
let storage: LocalStorage = LocalStorage.GetShared();

export interface IConfirmCrateUserDialogStyles {
  backgroundColor?: ResourceColor,
  shadow?: ShadowOptions | ShadowStyle,
  backgroundBlurStyle?: BlurStyle,
}

@Entry
@Component
struct OobeLocalUser {
  private session: UIExtensionContentSession | undefined = storage?.get<UIExtensionContentSession>('session');
  private dialogController: CustomDialogController | null = null;
  @State @Watch('checkIsAuthBtnEnabled') nickNameInput: string = '';
  @State @Watch('checkAccountInputRealTime') accountInput: string = '';
  @StorageProp('oobeFootBtnWidth') btnWidth: number | Resource = $r('app.float.wh_value_188');
  @StorageProp('oobe_local_user_ability_font_multiplier') fontMultiplier: number = 1;
  @State passwordInput: string = '';
  @State confirmPasswordInput: string = '';
  @State isAuthBtnEnabled: boolean = false;
  @State isDynamicEffect: boolean = false;
  @State isNickNameWarningShow: boolean = false;
  @State isAccountWarningShow: boolean = false;
  @State isPasswordWarningShow: boolean = false;
  @State isConfirmPasswordWarningShow: boolean = false;
  @State nickNameWarnMsg: ResourceStr = '';
  @State accountWarnMsg: ResourceStr = '';
  @State passwordWarnMsg: ResourceStr = '';
  @State confirmPasswordWarnMsg: ResourceStr = '';
  @State pinEnforced: boolean = false;
  @State isFirstSubmit: boolean = true;
  @State isEnterpriseCreateBtnEnable: boolean = false;
  @State isPasswordInputEmpty: boolean = true;
  @State isConfirmPasswordInputEmpty: boolean = true;
  @State passwordIconVM: PasswordIconVM = new PasswordIconVM({
    enableCapsIcon: true,
    onPwdIconClick: () => {
      this.passwordIconVM.isPwdVisible = !this.passwordIconVM.isPwdVisible;
    },
  });
  @State confirmPasswordIconVM: PasswordIconVM = new PasswordIconVM({
    enableCapsIcon: true,
    onPwdIconClick: () => {
      this.confirmPasswordIconVM.isPwdVisible = !this.confirmPasswordIconVM.isPwdVisible;
    },
  });

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear PAD OOBE create local User`);
    // 页面出现时初始化锁屏密码定制参数
    ColumnSystemManager.getInstance().registerMediaQuery();
    this.initPassWordParam();
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
    ColumnSystemManager.getInstance().unregisterMediaQuery();
  }

  @Styles
  normalStyles(): void {
    .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
    .opacity(1)
  }

  @Styles
  pressedStyles(): void {
    .backgroundColor($r('sys.color.ohos_id_color_click_effect'))
    .opacity(1)
  }

  @Builder
  PasswordInputBuilder() {
    Column() {
      Row() {
        Text($r('app.string.lock_screen_password_title'))
          .id('passwordText')
          .fontSize($r('app.float.font_14'))
          .lineHeight($r('app.float.line_height_19_fp'))
          .subTitleStyle()
        Text('*')
          .symbolStyle(this.pinEnforced)
      }

      Row() {
        PasswordIconWrapper({
          inputType: InputType.Password,
          passwordIconVM: this.passwordIconVM,
          wrapperSize: { width: '100%' },
        }) {
          PassWordInputSlot({
            componentId: 'passwordInput',
            passwordInput: this.passwordInput,
            passwordWarnMsg: this.passwordWarnMsg,
            passwordIconVM: this.passwordIconVM,
            placeHolder: $r('app.string.lock_screen_password_title'),
            enterFunc: () => this.enterFunc(),
            isShowPasswordEmptyMsg: () => this.isShowPasswordEmptyMsg(),
            checkPassword: () => this.checkPassword(),
            onPasswordInputChange: () => this.onPasswordInputChange()
          });
        }
      }
      .passwordInputContainerStyle(this.isPasswordWarningShow)

      Text(this.passwordWarnMsg ? this.passwordWarnMsg : '')
        .id('passwordWarnText')
        .fontSize($r('app.float.font_12'))
        .lineHeight($r('app.float.line_height_16_fp'))
        .warnTextStyle()
        .visibility(this.isPasswordWarningShow ? Visibility.Visible : Visibility.None);
    }
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  ConfirmPasswordInputBuilder() {
    Column() {
      Text($r('app.string.password_rule_input_menu_hint', PASSWORD_TEXT_INPUT_MIN_LENGTH.toString(),
        PASSWORD_TEXT_INPUT_MAX_LENGTH.toString()))
        .id('passwordPrompt')
        .fontSize($r('app.float.font_12'))
        .lineHeight($r('app.float.line_height_16_fp'))
        .fontColor($r('sys.color.font_secondary'))
        .fontFamily('HarmonyHeiTi')
        .fontWeight(FontWeight.Regular)
        .width(CARD_CONTENT_WIDTH)
        .margin({
          left: $r('app.float.margin_12'),
          top: this.isPasswordWarningShow ? $r('app.float.margin_prompt_f4') : $r('app.float.margin_8'),
          bottom: this.isPasswordWarningShow ? $r('app.float.margin_8') : $r('app.float.margin_minus_8'),
        })
      Row() {
        PasswordIconWrapper({
          inputType: InputType.Password,
          passwordIconVM: this.confirmPasswordIconVM,
          wrapperSize: { width: '100%' },
        }) {
          PassWordInputSlot({
            componentId: 'confirmPasswordInput',
            passwordInput: this.confirmPasswordInput,
            passwordWarnMsg: this.confirmPasswordWarnMsg,
            passwordIconVM: this.confirmPasswordIconVM,
            needCheckPassWord: !this.isFirstSubmit,
            placeHolder: $r('app.string.user_confirm_password_input_hint'),
            enterFunc: () => this.enterFunc(),
            isShowPasswordEmptyMsg: () => this.isShowPasswordEmptyMsg(),
            checkPassword: () => this.checkConfirmPassword(),
            onPasswordInputChange: () => this.onConfirmPasswordInputChange()
          });
        }
      }
      .passwordInputContainerStyle(this.isConfirmPasswordWarningShow)
      .margin({ top: this.isPasswordWarningShow ? 0 : $r('app.float.margin_16') })

      Text(this.confirmPasswordWarnMsg ? this.confirmPasswordWarnMsg : '')
        .id('confirmPasswordWarnText')
        .fontSize($r('app.float.font_12'))
        .lineHeight($r('app.float.line_height_16_fp'))
        .warnTextStyle()
        .visibility(this.isConfirmPasswordWarningShow ? Visibility.Visible : Visibility.None);
    }
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  contentBuilder(): void {
    Scroll() {
      // 主体
      Column() {
        // 用户昵称
        TextInputItem({
          inputText: this.nickNameInput,
          subTitle: $r('app.string.add_nick_name'),
          subTitleId: 'nickNameText',
          placeHolder: $r('app.string.user_name_input_hint'),
          inputContentId: 'nickNameInput',
          warningMsg: this.nickNameWarnMsg,
          warningMsgId: 'nickNameWarnText',
          isWarningMsgShow: this.isNickNameWarningShow,
          isDefaultFocus: true,
          isFocusInput: true,
          enterFunc: () => this.enterFunc(),
        })
        // 账户名称
        TextInputItem({
          inputText: this.accountInput,
          subTitle: $r('app.string.personal_folder_name'),
          subTitleId: 'accountNameText',
          placeHolder: $r('app.string.personal_folder_name'),
          inputContentId: 'accountNameInput',
          warningMsg: this.accountWarnMsg,
          warningMsgId: 'accountNameWarnText',
          isWarningMsgShow: this.isAccountWarningShow,
          isPromptShow: true,
          enterFunc: () => this.enterFunc(),
          onTextInputFocus: () => this.onAccountInputFocus()
        })
        // 锁屏密码输入框
        this.PasswordInputBuilder()
        // 确认锁屏密码输入框
        this.ConfirmPasswordInputBuilder()
      }
      .width(CARD_CONTENT_WIDTH)
      .alignItems(HorizontalAlign.Start);
    }
    .scrollBar(BarState.Auto)
    .align(Alignment.TopStart)
    .width(CARD_CONTENT_WIDTH + CARD_SCROLL)
    .constraintSize({
      maxHeight: '70%'
    })
  }

  @Builder
  buttonBuilder(): void {
    // 创建按钮
    Column() {
      Column() {
        Button({ type: ButtonType.Normal, stateEffect: true }) {
          Row() {
            LoadingProgress()
              .color($r('sys.color.icon_on_primary'))
              .size({ width: $r('app.float.width_24'), height: $r('app.float.height_24') })
              .margin({ right: this.isDynamicEffect ? $r('app.float.margin_8') : 0 })
              .visibility(this.isDynamicEffect ? Visibility.Visible : Visibility.None);
            Text(this.isDynamicEffect ? $r('app.string.creating_user') : $r('app.string.continue_process'))
              .fontSize($r('app.float.font_16'))
              .lineHeight($r('app.float.line_height_21_fp'))
              .dynamicEffectTextStyle();
          }
          .width('100%')
          .height('100%')
          .alignItems(VerticalAlign.Center)
          .justifyContent(FlexAlign.Center)
        }
        .id('createButton')
        .continueButtonStyle()
        .enabled(this.getIsEnterEnabled())
        .onClick(() => {
          LogUtil.info(`${TAG} the create user button is clicked , will to open the customDialog`);
          // 点击创建电脑用户按钮打点
          UserEventReporter.eventName(HiSysUserEventGroup.ENTER_OOBE_ADD_USER).report('behavior');
          this.enterFunc();
        })
        .width(this.btnWidth)
        .height($r('app.float.height_40'))
        .margin({ bottom: $r('app.float.height_48') })
      }
    }
    .width('100%')
    .margin({ top: $r('app.float.margin_24'), bottom: $r('app.float.margin_16') })
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  pageContainerBuilder(): void {
    Stack() {
      CardContainerView({
        bodyContent: () => this.contentBuilder(),
        mHeadName: $r('app.string.add_computer_account'),
        onButtonClick: () => this.onBackBtnClick(),
      })
      this.buttonBuilder()
    }
    .width('100%')
    .height('100%')
    .align(Alignment.End)
    .alignContent(Alignment.Bottom)
  }

  build() {
    NavDestination() {
      Column() {
        this.pageContainerBuilder()
      }
    }
    .hideTitleBar(true)
    .backgroundColor(Color.Transparent)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }

  /**
   * 初始化锁屏密码定制参数
   * pinEnforced -- 是否强制设置锁屏密码，默认false
   */
  private initPassWordParam(): void {
    this.pinEnforced = UserUtil.getPINEnforced();
  }

  /**
   * 对用户昵称输入框进行校验，须满足用户昵称最长允许输⼊ 255个字符，创建用户按钮才可用
   */
  private checkIsAuthBtnEnabled(): void {
    this.isNickNameWarningShow = false;
    if (buffer.byteLength(this.nickNameInput, UNICODE) === 0) {
      this.isAuthBtnEnabled = false;
    } else if (buffer.byteLength(this.nickNameInput, UNICODE) > USER_NAME_TEXT_INPUT_MAX_LENGTH) {
      this.isAuthBtnEnabled = false;
      this.nickNameWarnMsg = $r('app.string.private_pin_textInput_maxLength');
      this.isNickNameWarningShow = true;
    } else if (this.pinEnforced) {
      this.PINEnforceAuthBtnEnabled();
    } else {
      this.isAuthBtnEnabled = true;
    }
  }

  private PINEnforceAuthBtnEnabled(): void {
    if (StringUtil.isNotEmpty(this.passwordInput) &&
    StringUtil.isNotEmpty(this.confirmPasswordInput) &&
    StringUtil.isNotEmpty(this.nickNameInput)) {
      // 第一次确认，不会校验密码是否一致
      if (this.isFirstSubmit && !this.isPasswordWarningShow) {
        this.isAuthBtnEnabled = true;
        return;
      }
      if (!this.isPasswordWarningShow && !this.isConfirmPasswordWarningShow && !this.isAccountWarningShow) {
        this.isAuthBtnEnabled = true;
        return;
      }
    }
    this.isAuthBtnEnabled = false;
  }

  /**
   * 在输入锁屏密码和确认锁屏密码之间切换焦点时，不提示密码为空
   */
  private isShowPasswordEmptyMsg(): void {
    let passwordWarnMsg = this.passwordWarnMsg as Resource;
    let confirmPasswordWarnMsg = this.confirmPasswordWarnMsg as Resource;
    if (passwordWarnMsg.id === $r('app.string.password_cannot_be_empty').id &&
    this.isPasswordWarningShow) {
      this.isPasswordWarningShow = false;
    }
    if (confirmPasswordWarnMsg.id === $r('app.string.password_cannot_be_empty').id &&
    this.isConfirmPasswordWarningShow) {
      this.isConfirmPasswordWarningShow = false;
    }
  }

  /**
   * 帐户名称校验和未输入时显示
   * 帐户名称最长允许输⼊ 255个字符，不允许出现特殊字符< > | : " * ? / \和独立出现. ..
   */
  private checkAccountInputAll(): boolean {
    // 若帐户名称为空则默认帐户名称值为用户昵称值
    if (!this.accountInput) {
      let replacedText = this.nickNameInput.replace(nickNameRegReplace, '');
      // 将nickName替换特殊字符后赋值给account，特殊情况：//.替换后为.，而account下方得提示//.为特殊字符
      if (replacedText === '.' || replacedText === '..') {
        replacedText = this.nickNameInput;
      }
      if (!replacedText) {
        this.accountInput = this.nickNameInput
        this.accountWarnMsg = $r('app.string.no_special_characters_allowed');
        this.isAccountWarningShow = true;
        return false;
      } else {
        this.accountInput = replacedText;
        if (!this.checkAccountInputIllegal()) {
          return false;
        }
      }
    } else {
      if (!this.checkAccountInputIllegal()) {
        return false;
      }
    }
    return true;
  }

  /**
   * 帐户名称非空时校验
   */
  private checkAccountInputIllegal(): boolean {
    if (nickNameReg.test(this.accountInput) || this.accountInput === '.' || this.accountInput === '..') {
      this.accountWarnMsg = $r('app.string.no_special_characters_allowed');
      this.isAccountWarningShow = true;
      return false;
    }
    if (buffer.byteLength(this.accountInput, UNICODE) > USER_NAME_TEXT_INPUT_MAX_LENGTH) {
      this.accountWarnMsg = $r('app.string.private_pin_textInput_maxLength');
      this.isAccountWarningShow = true;
      return false;
    }
    return true;
  }

  /**
   * 锁屏密码输入框和再次输入框文本须保持一致
   * 再次输入框由6-32位字符组成
   */
  private checkConfirmPasswordInputIllegal(): void {
    // 优先提示密码不一致，确认密码输入框提示提示6-32个字符
    if (this.passwordInput !== this.confirmPasswordInput) {
      this.confirmPasswordWarnMsg = $r('app.string.password_input_warning_message_not_equal');
      this.isConfirmPasswordWarningShow = true;
    }
  }

  /**
   * 校验锁屏密码
   */
  private checkPassword(): void {
    this.isPasswordWarningShow = false;
    this.passwordWarnMsg = '';
    if (this.passwordInput) {
      // 如果不为空，进行其他校验
      this.passwordWarnMsg = validatePassword(this.passwordInput);
    } else if (this.pinEnforced) {
      this.passwordWarnMsg = $r('app.string.password_cannot_be_empty');
    } else if (this.confirmPasswordInput) {
      this.passwordWarnMsg = parseResource($r('app.string.password_too_short')
        , PASSWORD_TEXT_INPUT_MIN_LENGTH - 1);
    }
    this.isPasswordWarningShow = !!this.passwordWarnMsg;
  }

  /**
   * 校验确认锁屏密码
   */
  private checkConfirmPassword(): void {
    this.isConfirmPasswordWarningShow = false;
    this.checkConfirmPasswordInputIllegal();
    // 根据是否强制设置锁屏密码判断确认锁屏密码框是否可以为空
    if (this.pinEnforced && !this.confirmPasswordInput) {
      this.confirmPasswordWarnMsg = $r('app.string.password_cannot_be_empty');
      this.isConfirmPasswordWarningShow = true;
    }
  }

  /**
   * 帐户名称实时校验
   */
  private checkAccountInputRealTime(): void {
    this.isAccountWarningShow = false;
    if (buffer.byteLength(this.accountInput, UNICODE) > USER_NAME_TEXT_INPUT_MAX_LENGTH) {
      this.accountWarnMsg = $r('app.string.private_pin_textInput_maxLength');
      this.isAccountWarningShow = true;
    }
    if (nickNameReg.test(this.accountInput) || this.accountInput === '.' || this.accountInput === '..') {
      this.accountWarnMsg = $r('app.string.no_special_characters_allowed');
      this.isAccountWarningShow = true;
    }
  }

  /**
   * 锁屏密码输入时
   */
  private onPasswordInputChange(): void {
    if (this.isPasswordWarningShow) {
      this.isPasswordWarningShow = false;
    }
    let confirmPasswordWarnMsg = this.confirmPasswordWarnMsg as Resource;
    if (confirmPasswordWarnMsg.id === $r('app.string.password_input_warning_message_not_equal').id &&
    this.isConfirmPasswordWarningShow) {
      this.isConfirmPasswordWarningShow = false;
    }
    if (!this.confirmPasswordInput && !this.passwordInput) {
      this.isConfirmPasswordWarningShow = false;
    }
  }

  /**
   * 确认锁屏密码输入时
   */
  private onConfirmPasswordInputChange(): void {
    this.isConfirmPasswordWarningShow = false;
    if (this.confirmPasswordInput) {
      // 如果不为空，进行其他校验
      this.checkConfirmPasswordInputIllegal();
    } else if (this.pinEnforced) {
      this.confirmPasswordWarnMsg = $r('app.string.password_cannot_be_empty');
      this.isConfirmPasswordWarningShow = true;
    }
    if (!this.passwordInput && !this.confirmPasswordInput) {
      this.isPasswordWarningShow = false;
    }
  }

  /**
   * 帐户名称输入框获焦时
   */
  private onAccountInputFocus(): void {
    // 账号名称输入框获焦时自动填入合法的用户昵称
    if ((this.nickNameInput.length > 0 && buffer.byteLength(this.nickNameInput, UNICODE) <=
      USER_NAME_TEXT_INPUT_MAX_LENGTH) && !this.accountInput) {
      let replacedText = this.nickNameInput.replace(nickNameRegReplace, '');
      // 将nickName替换特殊字符后赋值给account，特殊情况：//.替换后为.，而account下方得提示//.为特殊字符
      if (replacedText === '.' || replacedText === '..') {
        replacedText = this.nickNameInput;
      }
      if (!replacedText) {
        this.accountInput = this.nickNameInput
      } else {
        this.accountInput = replacedText;
      }
    }
  }

  private authTextInputAndCreateUser(nickNameInput: string, accountInput: string,
    passwordInput: string, confirmPasswordInput: string): void {
    LogUtil.info(`${TAG} textInput auth succeed , will to create local user`);
    let func: () => void = () => {
      if (!this.isDynamicEffect) {
        this.addLocalAccountNotSetPwd(nickNameInput, accountInput);
        this.isDynamicEffect = true;
      }
    };
    if (passwordInput && confirmPasswordInput) {
      // 创建用户并设置锁屏密码
      LogUtil.info(`${TAG} the create user button is clicked , confirm to create user local user with password`);
      if (!this.isDynamicEffect) {
        this.addLocalAccountWithPwd(nickNameInput, accountInput, confirmPasswordInput);
        this.isDynamicEffect = true;
      }
    } else {
      // 创建用户不带锁屏密码
      this.dialogController = new CustomDialogController({
        builder: CreateLocalUserCustomDialog({
          confirm: func,
          fontSize: $r('app.float.font_16'),
          titleFontSize: $r('app.float.font_20'),
          lineHeight: $r('app.float.line_height_21_fp'),
        }),
        autoCancel: true,
      });
      LogUtil.info(`${TAG} open the confirm create local user without password customDialog`);
      this.dialogController.open();
    }
  }

  /**
   * 创建成功跳转到下一页
   */
  private jumpToNextPage(): void {
    LogUtil.info(`${TAG} start to jumpToNextPage isDynamicEffect:${this.isDynamicEffect}`);
    if (this.isDynamicEffect) {
      setTimeout(() => {
        this.isDynamicEffect = false;
        this.termiteAbility(AbilityTerminateResult.NEXT_STEP);
      }, DELAY_CREATE_USER_TIME);
    } else {
      this.termiteAbility(AbilityTerminateResult.NEXT_STEP);
    }
  }

  /**
   * 给当前用户设置名称
   */
  private async addLocalAccountNotSetPwd(nickNameInput: string, accountInput: string): Promise<void> {
    LogUtil.info(`${TAG} will to create local user short name`);
    // 去除首尾空格，避免混淆
    const localId: number = DEFAULT_USER_ID;
    const nickName: string = nickNameInput.trim();
    const accountName: string = accountInput.trim();
    // 设置短名称
    let accountManager = account_osAccount.getAccountManager();
    try {
      accountManager.setOsAccountName(localId, nickName)
        .then(() => {
          LogUtil.info(`${TAG} setOsAccountName successfully`);
          this.jumpToNextPage();
        })
        .catch((err: BusinessError) => {
          LogUtil.error(`${TAG} createOsAccount for local user create err: ${err?.code} message: ${err?.message}`);
          this.cancelDynamicEffect();
          this.addAccountErrResultHandler(err.code);
        })
    } catch (e) {
      const error = e as BusinessError;
      UserEventReporter.eventName(HiSysUsersException.EVENT_NAME_OOBE_ADD_USER)
        .name(HiSysUsersException.CREATE_ACCOUNT_FAILED)
        .value(generateFaultEventValue(error))
        .report('fault');
      LogUtil.error(` ${TAG} createOsAccount  exception Code ${error.code}, message: ${error.message}`);
      this.cancelDynamicEffect();
      new ConfirmAlertDialog($r('app.string.enterprise_system_exception_warning'),
        $r('app.string.button_title_ok')).show();
    }
  }

  /**
   * 取消创建用户按钮动效
   */
  private cancelDynamicEffect(): void {
    LogUtil.info(`${TAG} this.isDynamicEffect = ${this.isDynamicEffect}`);
    if (this.isDynamicEffect) {
      setTimeout(() => {
        this.isDynamicEffect = false;
      }, DELAY_CREATE_USER_TIME);
    }
  }

  /**
   * 设置锁屏密码结果处理
   */
  private async dealSetPassordResult(nickNameInput: string, accountInput: string, result: number): Promise<void> {
    LogUtil.info(`${TAG} dealSetPassordResult result ${result}`);
    switch (result) {
      case ResultCode.SUCCESS:
        LogUtil.info(`${TAG} addCredential set lock screen password successfully`);
        SearchDataController.getInstance().updateChildItemSearchStatus('lock_screen_password', true);
        SearchDataController.getInstance().updateSearchItemStatus('lock_screen_password', false);
        this.addLocalAccountNotSetPwd(nickNameInput, accountInput);
        break;
      case CreateLocalUserCallback.INVALID_TYPE:
        new ConfirmAlertDialog($r('app.string.password_format_illegal'), $r('app.string.button_title_ok')).show();
        this.cancelDynamicEffect();
        break;
      case CreateLocalUserCallback.TOKEN_INVALID_TOKEN:
        new ConfirmAlertDialog($r('app.string.fp_timeout_content'), $r('app.string.button_title_ok')).show();
        this.cancelDynamicEffect();
        break;
      default:
        new ConfirmAlertDialog($r('app.string.secure_chip_pw_set_fail'), $r('app.string.button_title_ok')).show();
        this.cancelDynamicEffect();
        break;
    }
  }

  /**
   * 创建本地账号并设置锁屏密码
   */
  private addLocalAccountWithPwd(nickNameInput: string, accountInput: string, confirmPassword: string): void {
    // 设置锁屏密码
    let password: Uint8Array = PasswordUtil.stringToUint8Array(confirmPassword);
    let pinAuth: account_osAccount.PINAuth = new account_osAccount.PINAuth();
    try {
      pinAuth.registerInputer({
        onGetData: (authSubType: account_osAccount.AuthSubType, callback: account_osAccount.IInputData) => {
          callback.onSetData(account_osAccount.AuthSubType.PIN_MIXED, password);
        }
      });
    } catch (e) {
      const error = e as BusinessError;
      UserEventReporter.eventName(HiSysUsersException.EVENT_NAME_OOBE_ADD_USER)
        .name(HiSysUsersException.ADD_PIN_CRED_FAILED)
        .value(generateFaultEventValue(error))
        .report('fault');
      LogUtil.error(`${TAG} pinAuth registerInputer exception Code ${error.code}, message: ${error.message}`);
    }
    let credentialInfo: account_osAccount.CredentialInfo = {
      credType: account_osAccount.AuthType.PIN,
      credSubType: account_osAccount.AuthSubType.PIN_MIXED,
      token: new Uint8Array([]),
    };
    let userIDM = new account_osAccount.UserIdentityManager();
    userIDM.openSession((err: BusinessError, challenge: Uint8Array) => {
      this.userIdmOpenSessionCallBack(userIDM, credentialInfo, nickNameInput, accountInput);
    });
  };

  private userIdmOpenSessionCallBack(userIDM: account_osAccount.UserIdentityManager,
    credentialInfo: account_osAccount.CredentialInfo, nickNameInput: string, accountInput: string): void {
    try {
      userIDM.addCredential(credentialInfo, {
        onResult: (result: number, extraInfo: account_osAccount.RequestResult) => {
          LogUtil.info(`${TAG} addCredential result : ${result}`);
          this.dealSetPassordResult(nickNameInput, accountInput, result);
        }
      });
    } catch (e) {
      const error = e as BusinessError;
      UserEventReporter.eventName(HiSysUsersException.EVENT_NAME_OOBE_ADD_USER)
        .name(HiSysUsersException.ADD_PIN_CRED_FAILED)
        .value(generateFaultEventValue(error))
        .report('fault');
      LogUtil.error(`${TAG} catch createPassword exception Code ${error.code}, message: ${error.message}`);
      this.cancelDynamicEffect();
      new ConfirmAlertDialog($r('app.string.enterprise_system_exception_warning'),
        $r('app.string.button_title_ok')).show();
    }
  }

  private addAccountErrResultHandler(errCode: number): void {
    switch (errCode) {
      case CreateLocalUserCallback.SYSTEM_EXCEPTION:
        new ConfirmAlertDialog($r('app.string.account_osaccount_system_exception_warning'),
          $r('app.string.button_title_ok')).show();
        break;
      case CreateLocalUserCallback.LOCAL_NAME_EXIST:
        new ConfirmAlertDialog($r('app.string.local_name_has_exist_warning'),
          $r('app.string.button_title_ok')).show();
        break;
      case CreateLocalUserCallback.UNSUPPORTED_ACCOUNT_TYPE:
        new ConfirmAlertDialog($r('app.string.unsupported_account_type_warning'),
          $r('app.string.button_title_ok')).show();
        break;
      default:
        new ConfirmAlertDialog($r('app.string.create_user_failed'), $r('app.string.button_title_ok')).show();
        break;
    }
  }

  /**
   * 点击上一步按钮触发功能
   */
  private onBackBtnClick(): void {
    LogUtil.info(`${TAG} the cancel create user button is clicked , back to last page`);
    this.termiteAbility(AbilityTerminateResult.LAST_STEP);
  }

  private async termiteAbility(flag: number): Promise<void> {
    let want: Want = {
      bundleName: 'com.ohos.settings',
      abilityName: 'OobeLocalUserAbility',
    };
    let abilityResult: common.AbilityResult = {
      want,
      resultCode: flag,
    };
    this.session?.terminateSelfWithResult(abilityResult);
    storage?.clear();
  }

  /**
   * 下一步按钮是否可用
   */
  private getIsEnterEnabled(): boolean {
    const enabled: boolean = this.isAuthBtnEnabled && !this.isDynamicEffect;
    LogUtil.debug(`${TAG} getIsEnterEnabled enabled ${enabled}`);
    return enabled;
  }

  /**
   * 点击确认按钮和回车键时触发功能
   */
  private enterFunc(): void {
    if (!this.getIsEnterEnabled()) {
      return;
    }
    this.isFirstSubmit = false;
    // 帐户名称校验
    let checkAccount: boolean = true;
    if (!this.checkAccountInputAll()) {
      checkAccount = false;
    }
    // 两个密码输入框任何一个有输入需作校验，设置密码规格：锁屏密码为非必填项，两输入框可以同时为空
    this.checkPassword();
    this.checkConfirmPassword();
    if (this.pinEnforced) {
      this.PINEnforceAuthBtnEnabled();
    }
    if (!this.isPasswordWarningShow && !this.isConfirmPasswordWarningShow && checkAccount) {
      this.authTextInputAndCreateUser(this.nickNameInput, this.accountInput,
        this.passwordInput, this.confirmPasswordInput);
    }
  }
}

/* oobe界面添加本地用户副标题样式 */
@Extend(Text)
function subTitleStyle() {
  .fontFamily('HarmonyHeiTi')
  .fontWeight(FontWeight.Medium)
  .fontColor($r('sys.color.font_secondary'))
  .margin({
    left: 14
  })
  .padding({ top: 12, bottom: 8 })
}

/* oobe输入框容器样式 */
@Extend(Row)
function passwordInputContainerStyle(isShow: boolean) {
  .width(CARD_CONTENT_WIDTH)
  .height(40)
  .backgroundColor($r('app.color.oobe_textinput_bg_color'))
  .borderColor(isShow ? $r('app.color.font_color_error') : $r('app.color.oobe_textinput_bg_color'))
  .borderWidth(1)
  .borderRadius(32)
}

/* oobe动效按钮文本样式 */
@Extend(Text)
function dynamicEffectTextStyle() {
  .fontColor($r('sys.color.ohos_id_color_text_primary_contrary'))
  .fontWeight(FontWeight.Medium)
  .fontFamily('HarmonyHeiTi')
}

/* oobe输入框告警样式 */
@Extend(Text)
function warnTextStyle() {
  .fontColor($r('app.color.font_color_red'))
  .fontFamily('HarmonyHeiTi')
  .fontWeight(FontWeight.Medium)
  .width(CARD_CONTENT_WIDTH)
  .margin({ left: 12, top: 8, bottom: 8 })
}


/* oobe继续按钮样式 */
@Extend(Button)
function continueButtonStyle() {
  .width('100%')
  .alignSelf(ItemAlign.Center)
  .backgroundColor($r('sys.color.ohos_id_color_emphasize'))
  .borderRadius($r('sys.float.corner_radius_level10'))
}

@Extend(Text)
function symbolStyle(visible: boolean) {
  .fontColor($r('sys.color.multi_color_08'))
  .height(40)
  .margin({ left: 8 })
  .padding({ top: 10 })
  .visibility(visible ? Visibility.Visible : Visibility.Hidden)
}