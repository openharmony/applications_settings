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
import ConfigData from '../../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData';
import HeadComponent from '../../../../../../../common/component/src/main/ets/default/headComponent.ets';
import Log from '../../../../../../../common/utils/src/main/ets/default/baseUtil/LogDecorator';
import LogUtil from '../../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import { PinSubType } from '../model/passwordImpl/PasswordModel';
import PasswordInputController from '../controller/password/PasswordInputController'
import RadioListComponent from '../../../../../../../common/component/src/main/ets/default/radioListComponent.ets';
import Router from '@system.router';
import { RadioListItem } from '../../../../../../../common/utils/src/main/ets/default/bean/RadioListItem';
import InputMethod from '@ohos.inputmethod';

let param;

@Entry
@Component
struct PasswordInput {
  private TAG_PAGE = ConfigData.TAG + 'PasswordInput page'
  private mController: PasswordInputController = new PasswordInputController()

// bind Properties
  @State @Watch("clearViewData")private passwordType: number = -1
  private password: string = ''

// private Properties
  private pageRequestCode: number = -1
  private prevPageUri: string = undefined
  private pinChallenge: string = undefined
  private pinToken: string = undefined
  @State private pageTitle: string | Resource = ''
  @State private inputMessage: string | Resource = ''
  @State private unlockMethodList: RadioListItem[] = []
  @State private buttonVisibility: Visibility = Visibility.Visible
  @State isTouchedLeft: boolean = false;
  @State isTouchedRight: boolean = false;

// handler
  private passwordOnChangeHandler: (value: string) => void;
  private okOnClickHandler: (event?: ClickEvent) => void;
  private unlockMethodChosenHandler: (value: number) => void;

//dialog
  private chooseUnlockMethodDialog: CustomDialogController = new CustomDialogController({
    builder: chooseUnlockMethodDialog({
      dialogTitle: $r('app.string.password_change_unlock_method'),
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
      .bindProperties(["passwordType", "password"])
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
    Column(){
      GridContainer({columns:12, sizeType: SizeType.Auto, gutter: vp2px(1) === 2 ? '12vp' : '0vp', margin: vp2px(1) === 2 ? '24vp' : '0vp'}) {
        Row({}) {
          Column() {
          }
          .width(ConfigData.WH_100_100)
          .height(ConfigData.WH_100_100)
          .useSizeType({
            xs: { span: 0, offset: 0 }, sm: { span: 0, offset: 0 },
            md: { span: 0, offset: 0 }, lg: { span: 2, offset: 0 }
          });

          Column() {
            // head
            HeadComponent({ headName: this.pageTitle, isActive: true })

            Column() {
              // input message
              Text(this.inputMessage)
                .fontSize($r('sys.float.ohos_id_text_size_sub_title2'))
                .fontWeight(FontWeight.Medium)
                .fontColor($r('sys.color.ohos_id_color_foreground'))
                .margin({ top: $r('app.float.item_common_horizontal_margin') })
                .align(Alignment.Center)

              // input password
              Row() {
                TextInput({ placeholder: '', text: this.password })
                  .placeholderFont({size: $r("app.float.font_18"), weight:FontWeight.Normal, style: FontStyle.Normal})
                  .type(InputType.Password)
                  .enterKeyType(EnterKeyType.Done)
                  .caretColor(Color.Blue)
                  .padding({left: $r('sys.float.ohos_id_card_margin_start'), right: $r('sys.float.ohos_id_card_margin_end')})
                  .margin({ top: $r('app.float.wh_value_50') })
                  .height($r("app.float.wh_value_40"))
                  .layoutWeight(1)
                  .borderRadius(0)
                  .backgroundColor($r('app.color.color_00000000_transparent'))
                  .onChange(this.passwordOnChangeHandler)
                  .onSubmit((enterKey) => {
                    InputMethod.getInputMethodController().stopInput().then((ret) => {
                      LogUtil.debug( `${ConfigData.TAG}, enterType: ${enterKey}, stopInput: ${ret}`);
                    });
                  });

              }
              Divider()
                .padding({left: $r('sys.float.ohos_id_card_margin_start'), right: $r('sys.float.ohos_id_card_margin_end')})

              CheckText();

              // change unlock method
              Text($r('app.string.password_change_unlock_method'))
                .height($r("app.float.wh_value_56"))
                .fontSize($r('sys.float.ohos_id_text_size_button1'))
                .fontColor($r('sys.color.ohos_id_color_text_primary_activated'))
                .fontWeight(FontWeight.Medium)
                .align(Alignment.Center)
                .alignSelf(ItemAlign.Center)
                .textAlign(TextAlign.Center)
                .padding({ left: $r('app.float.distance_30'), right: $r('app.float.distance_30') })
                .onClick(() => {
                  this.chooseUnlockMethodDialog.open()
                })

              // button
              Row() {
                Text($r('app.string.cancel'))
                  .fontSize($r('app.float.application_button_subtitle_size'))
                  .lineHeight($r('app.float.wh_value_22'))
                  .fontColor($r('app.color.font_color_007DFF'))
                  .textAlign(TextAlign.Center)
                  .layoutWeight(1)
                  .height($r('app.float.application_button_height'))
                  .borderRadius($r('app.float.radius_20'))
                  .backgroundColor(!this.isTouchedLeft ? $r("app.color.color_D8D8D8_grey") : $r("sys.color.ohos_id_color_foreground_contrary"))
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

                Text( $r('app.string.continue_'))
                  .fontSize($r('app.float.application_button_subtitle_size'))
                  .lineHeight($r('app.float.wh_value_22'))
                  .fontColor($r('app.color.font_color_007DFF'))
                  .textAlign(TextAlign.Center)
                  .layoutWeight(1)
                  .height($r('app.float.application_button_height'))
                  .borderRadius($r('app.float.radius_20'))
                  .backgroundColor(!this.isTouchedRight ? $r("app.color.color_D8D8D8_grey") : $r("sys.color.ohos_id_color_foreground_contrary"))
                  .onTouch((event: TouchEvent) => {
                    if (event.type === TouchType.Down) {
                      this.isTouchedRight = true;
                    }
                    if (event.type === TouchType.Up) {
                      this.isTouchedRight = false;
                    }
                  })
                  .onClick(this.okOnClickHandler)
              }
              .alignItems(VerticalAlign.Center)
              .width(ConfigData.WH_100_100)
              .padding({
                top: $r('app.float.distance_24'),
                bottom: $r('app.float.distance_36'),
                left: $r('app.float.distance_24'),
                right: $r('app.float.distance_24')
              })
              .margin({ top: $r('app.float.password_input_button_space') })
              .visibility(this.buttonVisibility)

            }
          }
          .padding({left: $r('app.float.distance_24'), right: $r('app.float.distance_24')})
          .height(ConfigData.WH_100_100)
          .width(ConfigData.WH_100_100)
          .useSizeType({
            xs: { span: 12, offset: 0 }, sm: { span: 12, offset: 0 },
            md: { span: 12, offset: 0 }, lg: { span: 8, offset: 2 }
          });

          Column() {
          }
          .width(ConfigData.WH_100_100)
          .height(ConfigData.WH_100_100)
          .useSizeType({
            xs: { span: 0, offset: 12 }, sm: { span: 0, offset: 12 },
            md: { span: 0, offset: 12 }, lg: { span: 2, offset: 10 }
          })
        }
        .width(ConfigData.WH_100_100)
        .height(ConfigData.WH_100_100);
      }
      .width(ConfigData.WH_100_100)
      .height(ConfigData.WH_100_100);
    }
    .backgroundColor($r("sys.color.ohos_id_color_sub_background"))
    .width(ConfigData.WH_100_100)
    .height(ConfigData.WH_100_100);
  }

// --------------------------- updateView -----------------------
/**
   * Update view data
   */
  @Log
  clearViewData() {
    AppStorage.SetOrCreate("checkMessage", '');
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
  getUnlockMethodList(): RadioListItem[] {
    var list : RadioListItem[] = [];
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
   *
   */
  @Log
  getButtonVisibility(): Visibility {
    return this.passwordType == PinSubType.PIN_SIX ? Visibility.Hidden : Visibility.Visible
  }

}
// The check message need to change real time, put it in child component, so parent component does not refresh.
@Component
struct CheckText {
  @StorageLink("checkMessage") private checkMessage: string | Resource = ''

  build() {
    Row() {
      Text(this.checkMessage ? this.checkMessage : $r('app.string.password_set_prompt'))
          .fontSize($r('sys.float.ohos_id_text_size_body2'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.ohos_id_color_warning'))
          .align(Alignment.Center)
          .textAlign(TextAlign.Center)
          .margin({ top: $r('app.float.distance_14'), bottom: $r('app.float.distance_32') })
    }
  }
}

/**
 * Choose Unlock Method Dialog
 */
@CustomDialog
struct chooseUnlockMethodDialog {
  controller: CustomDialogController;
  @Link dataList: RadioListItem[];
  @Link checkedValue: string;
  private dialogTitle: string= "";
  private chosenAction: (value: number) => void;
  @State isTouched :Boolean = false;

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
          onChange: (item: RadioListItem) => {
            if (this.chosenAction != null) {
              LogUtil.info(ConfigData.TAG + 'chooseUnlockMethodDialog : onCheckedAction : call back');
              this.chosenAction(item.settingType);
            }
            this.closeDialog();
          }
        })
      }

      Column() {
        Text($r('app.string.cancel'))
          .fontSize($r('app.float.application_button_subtitle_size'))
          .fontColor($r('sys.color.ohos_id_color_focused_bg'))
          .textAlign(TextAlign.Center)
          .width(ConfigData.WH_100_100)
          .height($r("app.float.wh_value_56"))
          .borderRadius($r('app.float.radius_20'))
          .linearGradient(this.isTouched ? {
             angle: 90,
             direction: GradientDirection.Right,
             colors: [[$r("app.color.DCEAF9"), 0.0], [$r("app.color.FAFAFA"), 1.0]]
             } : {
             angle: 90,
             direction: GradientDirection.Right,
             colors: [[$r("sys.color.ohos_id_color_foreground_contrary"), 1], [$r("sys.color.ohos_id_color_foreground_contrary"), 1]]})
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
          });
      }
      .padding($r('app.float.distance_20'))
      .align(Alignment.Center);
    }
  }
}