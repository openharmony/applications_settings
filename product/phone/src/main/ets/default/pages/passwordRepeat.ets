/**
 * Copyright (c) 2021 Huawei Device Co., Ltd.
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
import ConfigData from '../../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData.ets';
import HeadComponent from '../../../../../../../common/component/src/main/ets/default/headComponent.ets';
import Log from '../../../../../../../common/utils/src/main/ets/default/baseUtil/LogDecorator.ets';
import LogUtil from '../../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil.ets';
import { PinSubType } from '../model/passwordImpl/PasswordModel.ets';
import PasswordRepeatController from '../controller/password/PasswordRepeatController.ets'
import Router from '@system.router';

let param;

@Entry
@Component
struct PasswordRepeat {
  private TAG_PAGE = ConfigData.TAG + 'PasswordRepeat page ';
  mController: PasswordRepeatController = new PasswordRepeatController()

// bind Properties
  private pinToken: string = undefined
  @State private passwordType: number = -1
  @State private inputPassword: string = ''
  @State private checkMessage: string | Resource = ''
  private password: string = ''

// handler
  private pageRequestCode: number = -1
  private prevPageUri: string = undefined
  private pinChallenge: string = undefined
  private passwordOnEditChangedHandler: (isEditing: boolean) => void
  private passwordOnChangeHandler: (value: string) => void;
  private okOnClickHandler: (event?: ClickEvent) => void;
  private continueOnClickHandler: (event?: ClickEvent) => void;

// private Properties
  @State private pageTitle: string | Resource = ''
  @State private buttonVisibility: Visibility = Visibility.Visible

  @Log
  aboutToAppear(): void {

    this.getRouterParam();

    // bind event handlers
    this.passwordOnChangeHandler = this.mController.passwordOnChange.bind(this.mController);
    this.okOnClickHandler = this.mController.inputFinish.bind(this.mController);

    // bind component and initialize
    this.mController.bindComponent(this)
      .bindProperties([
        "pinToken", "passwordType", "inputPassword", "checkMessage", "password"
      ])
      .initData()
      .subscribe();

    this.updateView();
  }

  @Log
  aboutToDisappear(): void {
    this.mController.unsubscribe();
  }

/**
   * Get the params from router
   */
  @Log
  getRouterParam() {
    param = Router.getParams()
    LogUtil.info(this.TAG_PAGE + 'aboutToAppear : Router param = ' + JSON.stringify(param))

    if (!param) {
      return;
    }
    this.pageRequestCode = param.pageRequestCode;
    this.prevPageUri = param.prevPageUri;
    this.pinChallenge = param.pinChallenge;
    this.pinToken = param.pinToken;
    this.inputPassword = param.inputPassword;
    this.passwordType = param.passwordType;
    LogUtil.info(this.TAG_PAGE + 'aboutToAppear : from router : pageRequestCode = ' + this.pageRequestCode
    + ', prevPageUri = ' + this.prevPageUri
    + ', pinChallenge = ' + this.pinChallenge
    + ', pinToken = ' + this.pinToken
    + ', inputPassword = ' + this.inputPassword
    + ', passwordType = ' + this.passwordType)
  }

  build() {
    Column() {
      // head
      HeadComponent({ headName: this.pageTitle, isActive: true })

      Column() {
        // input message
        Text($r('app.string.password_message_repeat'))
          .fontSize($r('app.float.font_20'))
          .fontColor($r('app.color.color_666666_grey'))
          .margin({ top: $r('app.float.password_input_message_vertical_margin'), bottom: $r('app.float.password_input_message_vertical_margin') })
          .align(Alignment.Center)

        // input password
        Row() {
          TextInput({ placeholder: '', text: this.password })
            .height($r('app.float.wh_value_70'))
            .layoutWeight(1)
            .backgroundColor(Color.White)
            .type(InputType.Password)
            .enterKeyType(EnterKeyType.Done)
            .onChange(this.passwordOnChangeHandler);
        }

        // prompt message
        Text(this.checkMessage ? this.checkMessage : $r("app.string.password_set_prompt"))
          .fontSize($r('app.float.font_18'))
          .width(ConfigData.WH_83_100)
          .fontColor(Color.Red)
          .align(Alignment.Start)
          .textAlign(TextAlign.Start)
          .margin({ top: $r('app.float.password_input_message_vertical_margin') })

        // change unlock method (Hidden)
        Text($r('app.string.password_change_unlock_method'))
          .width(ConfigData.WH_100_100)
          .fontSize($r('app.float.font_20'))
          .fontColor(Color.Blue)
          .align(Alignment.Center)
          .textAlign(TextAlign.Center)
          .visibility(Visibility.Hidden)
          .padding({ top: $r('app.float.password_input_message_vertical_margin'), bottom: $r('app.float.password_input_message_vertical_margin') })

        // button
        Flex( { justifyContent: FlexAlign.SpaceAround } ) {
          Button() {
            Text($r('app.string.cancel'))
              .fontSize($r('app.float.application_button_subtitle_size'))
              .fontColor(Color.Blue)
              .textCase(TextCase.UpperCase)
          }
          .backgroundColor($r('app.color.color_E3E3E3_grey'))
          .width($r("app.float.wh_value_210"))
          .height($r("app.float.wh_value_60"))
          .onClick(() => {
            Router.back();
          })

          Button() {
            Text($r('app.string.confirm'))
              .fontSize($r('app.float.application_button_subtitle_size'))
              .fontColor(Color.Blue)
              .textCase(TextCase.UpperCase)
          }
          .backgroundColor($r('app.color.color_E3E3E3_grey'))
          .width($r("app.float.wh_value_210"))
          .height($r("app.float.wh_value_60"))
          .onClick(this.okOnClickHandler);
        }
        .margin({ top: $r('app.float.password_input_button_space') })
        .visibility(this.buttonVisibility)

      }
      .width(ConfigData.WH_100_100)
      .margin({ top: $r('app.float.password_input_button_margin_top') })
      .padding({
        left:$r('app.float.item_common_horizontal_margin'),
        right:$r('app.float.item_common_horizontal_margin'),
      })
    }
  }

// --------------------------- updateView -----------------------
/**
   * Update view
   */
  @Log
  updateView() {
    this.pageTitle = this.getPageTitle();
    this.buttonVisibility = this.getButtonVisibility();
  }

/**
   * Get page title
   *
   * @return : page title
   */
  @Log
  getPageTitle(): string | Resource {
    let title: Resource = $r('app.string.password_enter_password');

    switch (this.passwordType) {
      case PinSubType.PIN_SIX:
      case PinSubType.PIN_NUMBER:
        title = $r('app.string.password_title_number');
        break;
      case PinSubType.PIN_MIXED:
        title = $r('app.string.password_title_character');
        break;
    }
    return title;
  }

/**
   * Get button visibility
   *
   * @return : button visibility
   */
  @Log
  getButtonVisibility(): Visibility {
    return this.passwordType == PinSubType.PIN_SIX ? Visibility.Hidden : Visibility.Visible;
  }

}