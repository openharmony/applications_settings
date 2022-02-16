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
import { BaseData } from '../../../../../../../common/utils/src/main/ets/default/model/BaseData.ets'
import { PinSubType } from '../model/passwordImpl/PasswordModel.ets';
import PasswordInputController from '../controller/password/PasswordInputController.ets'
import RadioListComponent from '../../../../../../../common/component/src/main/ets/default/radioListComponent.ets';
import Router from '@system.router';

let param;

@Entry
@Component
struct PasswordInput {
  private TAG_PAGE = ConfigData.TAG + 'PasswordInput page'
  private mController: PasswordInputController = new PasswordInputController()

// bind Properties
  @State @Watch("clearViewData")private passwordType: number = -1
  @State private checkMessage: string | Resource = ''
  private password: string = ''

// private Properties
  private pageRequestCode: number = -1
  private prevPageUri: string = undefined
  private pinChallenge: string = undefined
  private pinToken: string = undefined
  @State private pageTitle: string | Resource = ''
  @State private inputMessage: string | Resource = ''
  @State private unlockMethodList: BaseData[] = []
  @State private buttonVisibility: Visibility = Visibility.Visible

// handler
  private passwordOnChangeHandler: (value: string) => void;
  private okOnClickHandler: (event?: ClickEvent) => void;
  private unlockMethodChosenHandler: (value: number) => void;

//dialog
  private chooseUnlockMethodDialog: CustomDialogController = new CustomDialogController({
    builder: chooseUnlockMethodDialog({
      dataList: $unlockMethodList,
      checkedValue: $passwordType,
      chosenAction: (value) => {
        this.unlockMethodChosenHandler(value)
      }
    }),
    autoCancel: true
  });

  @Log
  aboutToAppear(): void {
    this.getRouterParam()

    // bind event handlers
    this.passwordOnChangeHandler = this.mController.passwordOnChange.bind(this.mController);
    this.okOnClickHandler = this.mController.inputFinish.bind(this.mController);
    this.unlockMethodChosenHandler = this.mController.changePasswordType.bind(this.mController);

    // bind component and initialize
    this.mController.bindComponent(this)
      .bindProperties(["passwordType", "checkMessage", "password"])
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
    this.passwordType = param.passwordType;
    LogUtil.info(this.TAG_PAGE + 'aboutToAppear : from router : pageRequestCode = ' + this.pageRequestCode
    + ', prevPageUri = ' + this.prevPageUri
    + ', pinChallenge = ' + this.pinChallenge
    + ', pinToken = ' + this.pinToken
    + ', passwordType = ' + this.passwordType)
  }

  build() {
    Column() {
      // head
      HeadComponent({ headName: this.pageTitle, isActive: true })

      Column() {
        // input message
        Text(this.inputMessage)
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
          //todo  max length : wait ACE
        }

        // prompt message
        Text(this.checkMessage ? this.checkMessage : $r('app.string.password_set_prompt'))
          .fontSize($r('app.float.font_18'))
          .width(ConfigData.WH_83_100)
          .fontColor(Color.Red)
          .align(Alignment.Start)
          .textAlign(TextAlign.Start)
          .margin({ top: $r('app.float.password_input_message_vertical_margin') })

        // change unlock method
        Text($r('app.string.password_change_unlock_method'))
          .width(ConfigData.WH_100_100)
          .fontSize($r('app.float.font_20'))
          .fontColor(Color.Blue)
          .align(Alignment.Center)
          .textAlign(TextAlign.Center)
          .visibility(Visibility.Visible)
          .padding({ top: $r('app.float.password_input_message_vertical_margin'), bottom: $r('app.float.password_input_message_vertical_margin') })
          .onClick(() => {
            this.chooseUnlockMethodDialog.open()
          })

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
            Text($r('app.string.continue_'))
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
   * Update view data
   */
  @Log
  clearViewData() {
    this.checkMessage = ''
    this.password = ''
    this.mController.bindComponent(this).initData()
    this.updateView()
  }

/**
   * Update view
   */
  @Log
  updateView() {
    this.pageTitle = this.getPageTitle();
    this.inputMessage =  this.getInputMessage();
    this.unlockMethodList = this.getUnlockMethodList();
    this.buttonVisibility = this.getButtonVisibility();
  }

/**
   * Get page title
   *
   * @return : page title
   */
  @Log
  getPageTitle(): string | Resource {
    LogUtil.info(this.TAG_PAGE + 'getPageTitle : passwordType = ' + this.passwordType)

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
   * Get input message
   *
   * @return : message
   */
  @Log
  getInputMessage(): string | Resource {
    LogUtil.info(this.TAG_PAGE + 'getInputMessage : passwordType = ' + this.passwordType)

    let inputMessage: string | Resource = '';
    switch (this.passwordType) {
      case PinSubType.PIN_SIX:
        inputMessage = $r('app.string.password_message_number_6')
        break;

      case PinSubType.PIN_NUMBER:
        inputMessage = $r('app.string.password_message_custom')
        break;

      case PinSubType.PIN_MIXED:
        inputMessage = $r('app.string.password_message_character')
        break;
    }
    return inputMessage;
  }

/**
   * Get unlock method list.
   *
   * @return : unlock method list
   */
  @Log
  getUnlockMethodList(): any[] {
    LogUtil.info(this.TAG_PAGE + `setUnlockMethodList : passwordType = ${this.passwordType}`)

    var list : any[] = [];
    if (this.passwordType != PinSubType.PIN_SIX) {
      list.push({
        settingValue: PinSubType.PIN_SIX,
        settingTitle: $r('app.string.password_item_text_number_6'),
        settingIcon: '',
        settingAlias: '',
        settingSummary: ''
      })
    }
    if (this.passwordType != PinSubType.PIN_NUMBER) {
      list.push({
        settingValue: PinSubType.PIN_NUMBER,
        settingTitle: $r('app.string.password_item_text_custom'),
        settingIcon: '',
        settingAlias: '',
        settingSummary: ''
      })
    }
    if (this.passwordType != PinSubType.PIN_MIXED) {
      list.push({
        settingValue: PinSubType.PIN_MIXED,
        settingTitle: $r('app.string.password_item_text_character') ,
        settingIcon: '',
        settingAlias: '',
        settingSummary: ''
      })
    }

    LogUtil.info(this.TAG_PAGE + 'setUnlockMethodList : unlockMethodList = ' + JSON.stringify(this.unlockMethodList))
    return list;
  }

/**
   * Get button visibility
   *
   * @return : button visibility
   *
   */
  @Log
  getButtonVisibility(): Visibility {
    return this.passwordType == PinSubType.PIN_SIX ? Visibility.Hidden : Visibility.Visible
  }

}

/**
 * Choose Unlock Method Dialog
 */
@CustomDialog
struct chooseUnlockMethodDialog {
  controller: CustomDialogController;
  @Link dataList: BaseData[];
  @Link checkedValue: string;
  private dialogTitle: string= "";
  private chosenAction: (value: number) => void;

  @Log
  closeDialog() {
    this.controller.close();
  }

  build() {
    Column() {
      Row() {
        Text(this.dialogTitle)
          .height($r('app.float.wh_value_60'))
          .margin({ left: $r('app.float.wh_value_30') })
          .width(ConfigData.WH_100_100)
          .fontSize($r('app.float.font_28'));
      }

      Row() {
        RadioListComponent({
          dataList: this.dataList,
          checkedValue: this.checkedValue,
          showRadio: false,
          onChange: (item) => {
            LogUtil.info(ConfigData.TAG + 'chooseUnlockMethodDialog : onCheckedAction : item = ' + JSON.stringify(item));
            if (this.chosenAction != null) {
              LogUtil.info(ConfigData.TAG + 'chooseUnlockMethodDialog : onCheckedAction : call back');
              this.chosenAction(item.settingValue);
            }
            this.closeDialog();
          }
        })
      }

      Column() {
        Button() {
          Text($r('app.string.cancel'))
            .fontSize($r('app.float.application_button_subtitle_size'))
            .fontColor(Color.Blue)
            .textCase(TextCase.UpperCase)
        }
        .backgroundColor($r('app.color.color_E3E3E3_grey'))
        .width($r("app.float.wh_value_210"))
        .height($r("app.float.wh_value_60"))
        .align(Alignment.Bottom)
        .onClick(() => {
          this.closeDialog();
        });
      }
      .width(ConfigData.WH_100_100)
      .alignItems(HorizontalAlign.Center)
      .margin({ top: $r('app.float.item_common_vertical_margin'), bottom: $r('app.float.item_common_vertical_margin') })
    }
  }
}