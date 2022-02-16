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
import {PinSubType} from '../model/passwordImpl/PasswordModel.ets';
import PasswordCheckController from '../controller/password/PasswordCheckController.ets'
import Router from '@system.router';

let param;
const DEFAULT_TIMES = 5;

@Entry
@Component
struct PasswordCheck {
  private TAG_PAGE = ConfigData.TAG + 'PasswordCheck page ';
  private mController: PasswordCheckController = new PasswordCheckController()

// bind Properties
  private pinToken: string = undefined
  @State @Watch("freezeView") private freezingTime: number = 0
  @State @Watch("updateView") private remainTimes: number = -1

// handler
  private passwordOnChangeHandler: (value: string) => void;
  private okOnClickHandler: (event?: ClickEvent) => void;

// private Properties
  private pageRequestCode: number = -1
  private prevPageUri: string = undefined
  private pinChallenge: string = undefined
  @State private passwordType: number = -1
  @State private promptMessage: string | Resource = ''
  @State private buttonVisibility: Visibility = Visibility.Visible
  @State private freezingTimeForView: number = -1;
  @State private password: string = ''
  private timerId: number = -1

  @Log
  aboutToAppear(): void {

    this.getRouterParam();

    // bind event handlers
    this.passwordOnChangeHandler = this.mController.passwordOnChange.bind(this.mController);
    this.okOnClickHandler = this.mController.inputFinish.bind(this.mController);

    // bind component and initialize
    this.mController.bindComponent(this)
      .bindProperties(["freezingTime", "remainTimes", "pinToken"])
      .initData()
      .subscribe();

    this.updateView();
  }

  @Log
  aboutToDisappear(): void {
    this.mController.unsubscribe();
    this.stopCountDown();
  }

/**
   * Get the params from router
   */
  @Log
  getRouterParam() {
    param = Router.getParams()
    LogUtil.info(this.TAG_PAGE + ' getRouterParam : Router param = ' + JSON.stringify(param))
    if (!param) {
      return;
    }
    this.pageRequestCode = param.pageRequestCode;
    this.prevPageUri = param.prevPageUri;
    this.pinChallenge = param.pinChallenge;
    this.passwordType = param.passwordType;
    LogUtil.info(this.TAG_PAGE + ' getRouterParam : from router : pageRequestCode = ' + this.pageRequestCode
    + ', prevPageUri = ' + this.prevPageUri
    + ', pinChallenge = ' + this.pinChallenge)
  }

  build() {
    Column() {
      // head
      HeadComponent({ headName: $r('app.string.password_enter_password'), isActive: true })

      // freeze view
      if (this.freezingTimeForView > 0) {

        Row() {
          // attempt seconds
          Text($r('app.string.password_remain_times', this.freezingTimeForView))
            .fontSize($r('app.float.font_28'))
            .fontColor(Color.Blue)
            .textCase(TextCase.UpperCase)
            .margin({ top: $r('app.float.password_input_message_vertical_margin'), bottom: $r('app.float.password_input_message_vertical_margin') })
            .padding({ left: $r('app.float.item_common_horizontal_margin'), right: $r('app.float.item_common_horizontal_margin') })
            .align(Alignment.Center)
        }
        .backgroundColor(Color.Gray)
        .margin({
          left: $r('app.float.password_count_down_view_vertical_margin'),
          right: $r('app.float.password_count_down_view_vertical_margin')
        })

        // input
      } else {
        Column() {
          // input message
          Text(' ')
            .fontSize($r('app.float.font_20'))
            .fontColor($r('app.color.color_666666_grey'))
            .margin({ top: $r('app.float.password_input_message_vertical_margin'), bottom: $r('app.float.password_input_message_vertical_margin') })
            .align(Alignment.Center)
            .visibility(Visibility.Hidden)

          // input password
          Row() {
            TextInput({ placeholder: '', text: this.password })
              .height($r('app.float.wh_value_70'))
              .layoutWeight(1)
              .backgroundColor(Color.White)
              .type(InputType.Password)
              .enterKeyType(EnterKeyType.Done)
              .onChange(this.passwordOnChangeHandler)
            //TODO  max length : wait ACE
          }

          // prompt message
          Text(this.promptMessage)
            .fontSize($r('app.float.font_18'))
            .width(ConfigData.WH_83_100)
            .fontColor(Color.Red)
            .align(Alignment.Start)
            .textAlign(TextAlign.Start)
            .margin({ top: $r('app.float.password_input_message_vertical_margin') })

          // button
          Flex({ justifyContent: FlexAlign.SpaceAround }) {
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
              Text($r('app.string.next'))
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
          left: $r('app.float.item_common_horizontal_margin'),
          right: $r('app.float.item_common_horizontal_margin'),
        })
      }
    }
  }

// --------------------------- updateView -----------------------
/**
   * Update view
   */
  @Log
  updateView() {
    this.promptMessage = this.getPromptMessage();
    this.buttonVisibility = this.getButtonVisibility();
  }

/**
   * Get prompt message
   *
   * @return : message
   */
  @Log
  getPromptMessage(): string | Resource {
    return (this.remainTimes > 0 && this.remainTimes < DEFAULT_TIMES) ? $r('app.string.password_message_incorrect', this.remainTimes) : '';
  }

/**
   * Get button visibility
   *
   * @return : button visibility
   */
  @Log
  getButtonVisibility(): Visibility {
    return this.passwordType == PinSubType.PIN_SIX ? Visibility.Hidden : Visibility.Visible
  }

/**
   * When freezing time is greater than 0, start count down view.
   *
   * @return : button visibility
   */
  @Log
  freezeView() {
    if (this.freezingTime <= 0) {
      this.stopCountDown()
      return;
    }
    this.freezingTimeForView = this.freezingTime / 1000;
    LogUtil.info(this.TAG_PAGE + `freezeView freezingTimeForView = ${this.freezingTimeForView}`);
    this.timerId = setInterval(() => {
      if (this.freezingTimeForView <= 0) {
        this.stopCountDown()
        this.timerId = -1
        this.freezingTimeForView = 0
        this.freezingTime = 0
        this.updateView()
      } else {
        this.freezingTimeForView -= 1
      }
    }, 1000)
  }

/**
   * Stop count down view.
   */
  @Log
  stopCountDown() {
    // for freezing view
    if (this.timerId > 0) {
      clearTimeout(this.timerId)
      clearInterval(this.freezingTimeForView)
    }
  }

}