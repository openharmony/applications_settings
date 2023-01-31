/**
 * Copyright (c) 2021-2022 Huawei Device Co., Ltd.
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

import Router from '@system.router';
import deviceInfo from '@ohos.deviceInfo';
import InputMethod from '@ohos.inputMethod';
import { PinSubType } from '../model/passwordImpl/PasswordModel';
import PasswordInputController from '../controller/password/PasswordInputController';
import LogUtil from '../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import Log from '../../../../../../common/utils/src/main/ets/default/baseUtil/LogDecorator';
import ConfigData from '../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData';
import HeadComponent from '../../../../../../common/component/src/main/ets/default/headComponent';
import { RadioListItem } from '../../../../../../common/utils/src/main/ets/default/bean/RadioListItem';
import RadioListComponent from '../../../../../../common/component/src/main/ets/default/radioListComponent';

const deviceTypeInfo = deviceInfo.deviceType;
const TAG = ConfigData.TAG + 'PasswdSetting.PasswdInput -> ';
let param;

@Entry
@Component
struct PasswordInput {
  private TAG_PAGE = ConfigData.TAG + 'PasswordInput page ';
  private mController: PasswordInputController = new PasswordInputController();

  // bind Properties
  @State @Watch("clearViewData")
  private isInputFirstTime: boolean = true;
  @State @Watch("clearViewData")
  private passwordType: number = -1;
  @State password: string = '';
  @State passwordCircle: string[]= ["", "", "", "", "", ""];

  // private Properties
  private pageRequestCode: number = -1;
  private prevPageUri: string = undefined;
  private pinChallenge: string = undefined;
  private pinToken: string = undefined;
  @State private pageTitle: any = '';
  @State private inputMessage: any = '';
  @State private unlockMethodList: RadioListItem[] = [];
  @State private buttonVisibility: Visibility = Visibility.Visible;
  @State isTouchedLeft: boolean = false;
  @State isTouchedRight: boolean = false;
  @State isFocused: boolean = false;

  // handler
  private passwordOnChangeHandler: (value: string) => void;
  private okOnClickHandler: (event?: ClickEvent) => void;
  private unlockMethodChosenHandler: (value: number) => void;

  //dialog
  private chooseUnlockMethodDialog: CustomDialogController = new CustomDialogController({
    builder: chooseUnlockMethodDialog({
      dialogTitle: $r('app.string.password_change_unlock_method'),
      dataList: this.unlockMethodList,
      checkedValue: this.passwordType.toString(),
      chosenAction: (value) => {
        this.unlockMethodChosenHandler(value);
      }
    }),
    autoCancel: true,
    alignment: deviceTypeInfo === 'phone' || deviceTypeInfo === 'default' ? DialogAlignment.Bottom : DialogAlignment.Center,
    offset: ({ dx: 0, dy: deviceTypeInfo === 'phone' || deviceTypeInfo === 'default' ? '-24dp' : 0 })
  });

  @Log
  aboutToAppear(): void {
    this.getRouterParam();

    // bind event handlers
    this.passwordOnChangeHandler = this.mController.passwordOnChange.bind(this.mController);
    this.okOnClickHandler = this.mController.inputFinish.bind(this.mController);
    this.unlockMethodChosenHandler = this.mController.changePasswordType.bind(this.mController);

    // bind component and initialize
    this.mController.bindComponent(this)
      .bindProperties(["passwordType", "isInputFirstTime", "password", "pinToken", "passwordCircle"])
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
    if (!param) {
      return;
    }
    this.pageRequestCode = param.pageRequestCode;
    this.prevPageUri = param.prevPageUri;
    this.pinChallenge = param.pinChallenge;
    this.pinToken = param.pinToken;
    this.passwordType = param.passwordType;
  }

  build() {
    Column() {
      GridContainer({ gutter: ConfigData.GRID_CONTAINER_GUTTER_24, margin: ConfigData.GRID_CONTAINER_MARGIN_24 }) {
        Column() {
          // head
          HeadComponent({ headName: this.pageTitle, isActive: true });

          Column() {
            // input message
            Text(this.inputMessage)
              .fontSize($r('sys.float.ohos_id_text_size_sub_title2'))
              .fontWeight(FontWeight.Medium)
              .fontColor($r("sys.color.ohos_id_color_primary"))
              .margin({ top: $r("sys.float.ohos_id_default_padding_top") })
              .align((this.passwordType == PinSubType.PIN_MIXED) ? Alignment.Start : Alignment.Center)

            // input password
            if (this.passwordType == PinSubType.PIN_SIX) {
              Row() {
                Stack() {
                  TextInput({ placeholder: '', text: this.password })
                    .height($r('app.float.distance_36'))
                    .width($r('app.float.wh_192'))
                    .opacity(1)
                    .fontColor(('rgba(0,0,0,0)'))
                    .backgroundColor(('rgba(0,0,0,0)'))
                    .caretColor(('rgba(0,0,0,0)'))
                    .maxLength(6)
                    .margin({bottom:$r('app.float.wh_value_8')})
                    .onChange((value: string) => {
                      this.password = value;
                      if (value.length > 6) {
                        return;
                      }
                      let length = value.length;
                      for (let i = 0;i < 6; i++) {
                        if (i < length) {
                          this.passwordCircle[i] = value[i];
                        } else {
                          this.passwordCircle[i] = '';
                        }
                      }
                      this.passwordOnChangeHandler(value);
                    })
                    .onSubmit((enterKey) => {
                      InputMethod.getInputMethodController().stopInput()
                        .then((ret) => {
                          LogUtil.debug(`${ConfigData.TAG}, enterType: ${enterKey}, stopInput: ${ret}`);
                        })
                    });

                  List({ space: 24 }) {
                    ForEach(this.passwordCircle, (item) => {
                      ListItem() {
                        Column()
                          .width($r('app.float.wh_value_12'))
                          .height($r('app.float.wh_value_12'))
                          .backgroundColor(item === '' ? 'white' : 'black')
                          .border({ width: 1, color: 'black', radius: 12 })
                          .margin({ top: $r('app.float.wh_value_12') })
                      }
                    })
                  }
                  .hitTestBehavior(HitTestMode.Transparent)
                  .listDirection(Axis.Horizontal)
                }
                .margin({ top: $r('app.float.wh_value_20'),bottom:$r('app.float.wh_value_12') })
                .width(ConfigData.WH_100_100)
                .height($r("app.float.wh_value_32"))
              }
            } else {
              Column() {
                TextInput({ placeholder: '', text: this.password })
                  .width(ConfigData.WH_100_100)
                  .height(ConfigData.WH_100_100)
                  .placeholderFont({
                    size: $r("app.float.font_18"),
                    weight: FontWeight.Normal,
                    style: FontStyle.Normal
                  })
                  .type(InputType.Password)
                  .enterKeyType(EnterKeyType.Done)
                  .caretColor($r('sys.color.ohos_id_color_text_primary_activated'))
                  .borderRadius(0)
                  .layoutWeight(ConfigData.LAYOUT_WEIGHT_1)
                  .backgroundColor($r('app.color.color_00000000_transparent'))
                  .onChange(this.passwordOnChangeHandler)
                  .onSubmit((enterKey) => {
                    InputMethod.getInputMethodController().stopInput()
                      .then((ret) => {
                        LogUtil.debug(`${ConfigData.TAG}, enterType: ${enterKey}, stopInput: ${ret}`);
                      });
                  })
                  .onFocus(() => {
                    LogUtil.info(TAG + "text input is focused");
                    this.isFocused = true;
                  })

                Divider()
              }
              .margin({ top: $r('app.float.wh_value_32') })
              .height($r("app.float.wh_value_48"))
              .padding({
                left: $r('sys.float.ohos_id_card_margin_start'),
                right: $r('sys.float.ohos_id_card_margin_end'),
                top: $r("app.float.distance_8"),
                bottom: $r("app.float.distance_6") })
            }

            CheckText();

            // change unlock method
            Button({ type: ButtonType.Normal, stateEffect: true }) {
              Text($r('app.string.password_change_unlock_method'))
                .fontSize($r('sys.float.ohos_id_text_size_button1'))
                .fontColor($r('sys.color.ohos_id_color_text_primary_activated'))
                .fontWeight(FontWeight.Medium)
                .align(Alignment.Center)
                .alignSelf(ItemAlign.Center)
                .textAlign(TextAlign.Center)
                .visibility(this.isInputFirstTime ? Visibility.Visible : Visibility.Hidden)
            }
            .backgroundColor("rgba(0,0,0,0)")
            .onClick(() => {
              this.chooseUnlockMethodDialog.open();
            })
          }

          // button
          Flex({ justifyContent: FlexAlign.SpaceBetween }) {
            Row() {
              Button({ type: ButtonType.Capsule, stateEffect: true }) {
                Text($r('app.string.cancel'))
                  .fontWeight(FontWeight.Medium)
                  .fontSize($r('app.float.application_button_subtitle_size'))
                  .lineHeight($r('app.float.wh_value_22'))
                  .fontColor($r('app.color.font_color_007DFF'))
                  .height($r('app.float.application_button_height'))
                  .textAlign(TextAlign.Center)
              }
              .layoutWeight(ConfigData.LAYOUT_WEIGHT_1)
              .backgroundColor(!this.isTouchedLeft ? $r("sys.color.ohos_id_color_button_normal") : $r("sys.color.ohos_id_color_foreground_contrary"))
              .onTouch((event: TouchEvent) => {
                if (event.type === TouchType.Down) {
                  this.isTouchedLeft = true;
                }

                if (event.type === TouchType.Up) {
                  this.isTouchedLeft = false;
                }
              })
              .onClick(() => {
                Router.back();
              })

              Column()
                .width( $r('app.float.distance_12'))
                .height($r('app.float.application_button_height'))

              Button({ type: ButtonType.Capsule, stateEffect: true }) {
                Text(this.isInputFirstTime ? $r('app.string.continue_') : $r('app.string.confirm'))
                  .fontWeight(FontWeight.Medium)
                  .fontSize($r('app.float.application_button_subtitle_size'))
                  .lineHeight($r('app.float.wh_value_22'))
                  .fontColor($r('app.color.font_color_007DFF'))
                  .height($r('app.float.application_button_height'))
                  .textAlign(TextAlign.Center)
              }
              .layoutWeight(ConfigData.LAYOUT_WEIGHT_1)
              .backgroundColor(!this.isTouchedRight ? $r("sys.color.ohos_id_color_button_normal") : $r("sys.color.ohos_id_color_foreground_contrary"))
              .onTouch((event: TouchEvent) => {
                if (event.type === TouchType.Down) {
                  this.isTouchedRight = true;
                }

                if (event.type === TouchType.Up) {
                  this.isTouchedRight = false;
                  this.isFocused = false;
                }
              })
              .onClick(this.okOnClickHandler)
            }
            .alignItems(this.isFocused === false ? VerticalAlign.Bottom : VerticalAlign.Top)
            .height(this.passwordType == PinSubType.PIN_MIXED && (deviceTypeInfo === 'phone' || deviceTypeInfo === 'default') ? "58%" : "66%")
            .padding(this.isFocused === false ? { bottom: 24 } : { top: (this.passwordType == PinSubType.PIN_MIXED ? "14%" : "16%") })
          }
          .width(ConfigData.WH_100_100)
          .visibility(this.buttonVisibility)
        }
        .useSizeType({
          sm: { span: 4, offset: 0 },
          md: { span: 6, offset: 1 },
          lg: { span: 8, offset: 2 }
        })
      }
      .width(ConfigData.WH_100_100)
      .height(ConfigData.WH_100_100)
    }
    .backgroundColor($r("sys.color.ohos_id_color_sub_background"))
    .width(ConfigData.WH_100_100)
    .height(ConfigData.WH_100_100)
  }

  // --------------------------- updateView -----------------------
  /**
   * Update view data
   */
  @Log
  clearViewData() {
    AppStorage.SetOrCreate("checkMessage", '');
    this.password = '';
    this.passwordCircle = ["", "", "", "", "", ""];
    this.mController.bindComponent(this).initData();
    this.updateView();
  }

  /**
   * Update view
   */
  @Log
  updateView() {
    this.pageTitle = this.getPageTitle();
    this.inputMessage = this.getInputMessage();
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
    let inputMessage: string | Resource = '';
    if (this.isInputFirstTime) {
      switch (this.passwordType) {
        case PinSubType.PIN_SIX:
          inputMessage = $r('app.string.password_message_number_6');
          break;

        case PinSubType.PIN_NUMBER:
          inputMessage = $r('app.string.password_message_custom');
          break;

        case PinSubType.PIN_MIXED:
          inputMessage = $r('app.string.password_message_character');
          break;
      }
    } else {
      inputMessage = $r('app.string.password_message_repeat');
    }
    return inputMessage;
  }

  /**
   * Get unlock method list.
   *
   * @return : unlock method list
   */
  @Log
  getUnlockMethodList(): RadioListItem[] {
    var list: RadioListItem[] = [];
    if (!this.isInputFirstTime) {
      return list;
    }

    if (this.passwordType != PinSubType.PIN_SIX) {
      list.push({
        settingType: PinSubType.PIN_SIX,
        settingTitle: $r('app.string.password_item_text_number_6')
      })
    }

    if (this.passwordType != PinSubType.PIN_NUMBER) {
      list.push({
        settingType: PinSubType.PIN_NUMBER,
        settingTitle: $r('app.string.password_item_text_custom')
      })
    }

    if (this.passwordType != PinSubType.PIN_MIXED) {
      list.push({
        settingType: PinSubType.PIN_MIXED,
        settingTitle: $r('app.string.password_item_text_character')
      })
    }
    return list;
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

// The check message need to change real time, put it in child component, so parent component does not refresh.
@Component
struct CheckText {
  @StorageLink("checkMessage")
  private checkMessage: string | Resource = '';

  build() {
    Text(this.checkMessage ? this.checkMessage : $r('app.string.password_set_prompt'))
      .fontSize($r('sys.float.ohos_id_text_size_body2'))
      .fontWeight(FontWeight.Medium)
      .fontColor($r('sys.color.ohos_id_color_warning'))
      .align(Alignment.Center)
      .textAlign(TextAlign.Center)
      .margin({ top: $r('app.float.distance_4'), bottom: $r('app.float.distance_24') })
  }
}

/**
 * Choose Unlock Method Dialog
 */
@CustomDialog
struct chooseUnlockMethodDialog {
  controller: CustomDialogController;
  private dataList: RadioListItem[];
  private checkedValue: string;
  private dialogTitle: string | Resource= "";
  private chosenAction: (value: number) => void;
  @State isTouched: Boolean = false;

  @Log
  closeDialog() {
    this.controller.close();
  }

  build() {
    Column() {
      Text(this.dialogTitle)
        .height($r('app.float.wh_value_56'))
        .margin({ left: $r('app.float.wh_value_24') })
        .width(ConfigData.WH_100_100)
        .fontSize($r('app.float.font_20'))
        .fontColor($r("sys.color.ohos_id_color_primary"))
        .fontWeight(500)

      RadioListComponent({
        dataList: this.dataList,
        checkedValue: this.checkedValue,
        showRadio: false,
        onChange: (item: RadioListItem) => {
          if (this.chosenAction != null) {
            LogUtil.info(ConfigData.TAG + 'chooseUnlockMethodDialog : onCheckedAction : call back');
            this.chosenAction(item.settingType);
          }
          this.closeDialog();
        }
      })

      Text($r('app.string.cancel'))
        .fontSize($r('app.float.application_button_subtitle_size'))
        .fontColor($r('sys.color.ohos_id_color_focused_bg'))
        .textAlign(TextAlign.Center)
        .fontWeight(500)
        .width(ConfigData.WH_100_100)
        .height($r("app.float.wh_value_56"))
        .margin({ top: $r("app.float.wh_value_6") })
        .padding({ top: $r("app.float.wh_value_12"), bottom: $r("app.float.wh_value_6") })
        .borderRadius($r('app.float.radius_20'))
        .linearGradient(this.isTouched ? {
                                           angle: 90,
                                           direction: GradientDirection.Right,
                                           colors: [[$r("app.color.DCEAF9"), 0.0], [$r("app.color.FAFAFA"), 1.0]]
                                         } : {
                                               angle: 90,
                                               direction: GradientDirection.Right,
                                               colors: [[$r("sys.color.ohos_id_color_foreground_contrary"), 1], [$r("sys.color.ohos_id_color_foreground_contrary"), 1]]
                                             })
        .onTouch((event: TouchEvent) => {
          if (event.type === TouchType.Down) {
            this.isTouched = true;
          }

          if (event.type === TouchType.Up) {
            this.isTouched = false;
          }
        })
        .onClick(() => {
          this.closeDialog();
        })
        .alignSelf(ItemAlign.Center)
    }
  }
}