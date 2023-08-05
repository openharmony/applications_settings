/**
 * Copyright (c) 2023-2023 Huawei Device Co., Ltd.
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
import accessibility from '@ohos.accessibility';
import config from '@ohos.accessibility.config';
import LogUtil from '../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import Log from '../../../../../../common/utils/src/main/ets/default/baseUtil/LogDecorator';
import ConfigData from '../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData';
import LongHeadComponent from '../../../../../../common/component/src/main/ets/default/longHeadComponent';
import ComponentConfig from '../../../../../../common/component/src/main/ets/default/ComponentConfig';

const MODULE_TAG = ConfigData.TAG + 'service-> ';
const DEVICE_TYPE = deviceInfo.deviceType;

class ServiceInfoData {
  serviceIcon: string = '';
  serviceTitle:string = '';
  serviceArrow: string = '';
  serviceSummary: string = '';
  serviceEndText: string = '';
  serviceState: boolean = false;
  serviceId: string = '';
  serviceBundleName: string = '';
  serviceUri:string = '';
}
/**
 * AccessibilityService Info
 */
@Entry
@Component
struct AccessibilityServiceInfo {
  tag: string = 'AccessibilityServiceInfoSettings';
  isPhoneOrRK: boolean = true;
  bundleName: string = '';
  serviceName: string = '';
  capabilities: Array<accessibility.Capability> = ['retrieve', 'keyEventObserver', 'gesture', 'zoom', 'touchGuide'];
  @State serviceIsOn: boolean = false;
  @State pageChanged: boolean = false;
  @StorageLink('accessibilityServiceInfo') serviceInfo: ServiceInfoData = {
    serviceIcon: '',
    serviceTitle: '',
    serviceArrow: '',
    serviceSummary: '',
    serviceEndText: '',
    serviceState: false,
    serviceId: '',
    serviceBundleName: '',
    serviceUri: ''
  };
  showDialog: CustomDialogController = new CustomDialogController({
    builder: ShowDialog({
      firstClickAction: () => {
        this.enableAbility(this.serviceInfo.serviceId);
      },
      secondClickAction: () => {
        this.cancelButton();
      },
    }),
    alignment: this.isPhoneOrRK ? DialogAlignment.Bottom : DialogAlignment.Center,
    autoCancel: false,
    offset: ({ dx: 0, dy: this.isPhoneOrRK ? '-12dp' : 0 })
  });

  build() {
    Column() {
      GridContainer({ gutter: ConfigData.GRID_CONTAINER_GUTTER_24, margin: ConfigData.GRID_CONTAINER_MARGIN_24 }) {
        Column() {
          LongHeadComponent({ longHeadName: this.serviceInfo.serviceTitle, isActive: true });

          Column() {
            Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
              Row() {
                Text(this.serviceInfo.serviceTitle)
                  .fontSize($r('sys.float.ohos_id_text_size_body1'))
                  .fontColor($r('sys.color.ohos_id_color_text_primary'))
                  .fontWeight(FontWeight.Medium)
                  .maxLines(ComponentConfig.MAX_LINES_3)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .width('90%')
                  .textAlign(TextAlign.Start);

                Blank()

                if (this.pageChanged) {
                  Toggle({ type: ToggleType.Switch, isOn: this.serviceIsOn })
                    .width('36vp')
                    .height('20vp')
                    .selectedColor('#007DFF')
                    .onChange((isOn: boolean) => {
                      this.setExtensionServiceState(isOn);
                    });
                } else {
                  Toggle({ type: ToggleType.Switch, isOn: this.serviceIsOn })
                    .width('36vp')
                    .height('20vp')
                    .selectedColor('#007DFF')
                    .onChange((isOn: boolean) => {
                      this.setExtensionServiceState(isOn);
                    });
                }
              }
              .height($r('app.float.wh_value_56'))
              .width(ConfigData.WH_100_100)
              .alignItems(VerticalAlign.Center)
              .padding({ left: $r('app.float.wh_value_12'), right: $r('app.float.wh_value_6') })
              .backgroundColor($r('app.color.white_bg_color'))
              .borderRadius($r('app.float.radius_24'));
            }

            Blank(4);

            Row() {
              Text($r('app.string.more_settings'))
                .fontSize($r('sys.float.ohos_id_text_size_body1'))
                .fontColor($r('sys.color.ohos_id_color_text_primary'))
                .fontWeight(FontWeight.Medium)
                .textAlign(TextAlign.Start);

              Blank();
              Image('/res/image/ic_settings_arrow.svg')
                .width($r('app.float.wh_value_12'))
                .height($r('app.float.wh_value_24'))
                .margin({ right: $r('app.float.distance_8') })
                .fillColor($r('sys.color.ohos_id_color_primary'))
                .opacity($r('sys.float.ohos_fa_alpha_content_fourth'))
            }
            .height($r('app.float.wh_value_56'))
            .width(ConfigData.WH_100_100)
            .alignItems(VerticalAlign.Center)
            .padding({ left: $r('app.float.wh_value_12'), right: $r('app.float.wh_value_6') })
            .enabled(false)
            .backgroundColor($r('app.color.white_bg_color'))
            .borderRadius($r('app.float.radius_24'));

            Blank(20);

            Text($r('app.string.help'))
              .width(ConfigData.WH_100_100)
              .fontSize($r('app.float.font_14'))
              .fontColor($r('sys.color.ohos_id_color_text_secondary'))
              .height($r('app.float.wh_value_52'))
              .lineHeight($r('app.float.wh_value_20'))
              .padding({
                left: $r('app.float.wh_value_12'),
                top: $r('app.float.distance_4'),
                bottom: $r('app.float.distance_24'),
              });
            Text(this.serviceInfo.serviceSummary)
              .width(ConfigData.WH_100_100)
              .fontSize($r('app.float.font_14'))
              .fontColor($r('sys.color.ohos_id_color_text_secondary'))
              .height($r('app.float.wh_value_52'))
              .lineHeight($r('app.float.wh_value_20'))
              .padding({
                left: $r('app.float.wh_value_12'),
                top: $r('app.float.distance_4'),
                bottom: $r('app.float.distance_24'),
              });
          }
          .useSizeType({
            sm: { span: 4, offset: 0 },
            md: { span: 6, offset: 1 },
            lg: { span: 8, offset: 2 }
          })
        }
      }
      .width(ConfigData.WH_100_100)
      .height(ConfigData.WH_100_100)
    }
    .backgroundColor($r("sys.color.ohos_id_color_sub_background"))
    .width(ConfigData.WH_100_100)
    .height(ConfigData.WH_100_100)
  }

  @Log
  aboutToAppear(): void{
    LogUtil.info(this.tag + ' aboutToAppear start ');
    if (DEVICE_TYPE === 'phone' || DEVICE_TYPE === 'default') {
      this.isPhoneOrRK = true;
    } else {
      this.isPhoneOrRK = false;
    }
    this.getServiceName();
    LogUtil.info(this.tag + " aboutToAppear end ");
  }

  getServiceName(): void {
    let param;
    param = Router.getParams();
    if (param) {
      LogUtil.info(this.tag + 'param is valid');
      this.bundleName = param.serviceBundleName;
      this.serviceInfo = param;
      this.serviceName = param.serviceServiceId;
      this.serviceIsOn = param.serviceState;
      AppStorage.SetOrCreate('ServiceInformation', param);
    }
  }

  setExtensionServiceState(isOn: boolean): void {
    LogUtil.info(this.tag + 'setExtensionServiceState ' + isOn);
    LogUtil.info(this.tag + 'serviceState: ' + JSON.stringify(this.serviceIsOn));
    if (isOn) {
      this.showDialog.open();
    } else {
      this.disableAbility(this.serviceInfo.serviceId);
    }
  }

  enableAbility(abilityName: string): void {
    config.enableAbility(abilityName, this.capabilities).then(() => {
      LogUtil.info(this.tag + 'enable accessibilityService success');
      this.serviceIsOn = true;
    }).catch((err) => {
      this.serviceIsOn = false;
      this.pageChanged = !this.pageChanged;
      LogUtil.error(this.tag + 'failed to enable accessibilityService, because ' + JSON.stringify(err));
    })
  }

  disableAbility(abilityName: string): void {
    config.disableAbility(abilityName).then(() => {
      LogUtil.info(MODULE_TAG + 'disable accessibilityService success');
      this.serviceIsOn = false;
    }).catch((err) => {
      LogUtil.error(MODULE_TAG + 'disable accessibilityService failed, error: ' + JSON.stringify(err));
    });
  }

  cancelButton(): void {
    this.serviceIsOn = false;
    this.pageChanged = !this.pageChanged;
    LogUtil.info(MODULE_TAG + 'cancel: serviceStatus ' + JSON.stringify(this.serviceIsOn));
  }
}

/**
 * Show dialog
 */
@CustomDialog
struct ShowDialog {
  dialogController: CustomDialogController;
  firstClickAction: () => void;
  secondClickAction: () => void;
  @State @Watch("freezeView")
  private countDownTime: number = 10000;
  @State freezingTimeForView: number = -1;
  @State userApproval: boolean = false;
  @State title: Resource = $r('app.string.user_approval_remain_times', 10);
  @State enableState: boolean = false;

  build() {
    Column() {

      Blank(2);

      Text($r('app.string.accessibility_security_notification'))
        .width(ConfigData.WH_100_100)
        .fontSize($r('app.float.font_24'))
        .fontColor($r('sys.color.ohos_id_color_text_secondary'))
        .padding({
          left: $r('app.float.wh_value_12'),
          top: $r('app.float.distance_4'),
          bottom: $r('app.float.distance_24'),
        });

      Text($r('app.string.accessibility_notify_content'))
        .width(ConfigData.WH_100_100)
        .fontSize($r('app.float.font_18'))
        .fontColor($r('sys.color.ohos_id_color_text_secondary'))
        .padding({
          left: $r('app.float.wh_value_12'),
          top: $r('app.float.distance_4'),
          bottom: $r('app.float.distance_24'),
        });

      Text($r('app.string.accessibility_risk_detail'))
        .width(ConfigData.WH_100_100)
        .fontSize($r('app.float.font_20'))
        .fontColor($r('sys.color.ohos_id_color_text_secondary'))
        .padding({
          left: $r('app.float.wh_value_12'),
          top: $r('app.float.distance_4'),
          bottom: $r('app.float.distance_24'),
        });

      Text($r('app.string.accessibility_risk_content'))
        .width(ConfigData.WH_100_100)
        .fontSize($r('app.float.font_18'))
        .fontColor($r('sys.color.ohos_id_color_text_secondary'))
        .padding({
          left: $r('app.float.wh_value_12'),
          top: $r('app.float.distance_4'),
          bottom: $r('app.float.distance_24'),
        });

      // checkbox
      Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center}) {
        Checkbox()
          .select(false)
          .selectedColor('#4C89F0')
          .onChange((value: boolean) => {
            this.updateUserApproval(value);
          })
        Text($r('app.string.accessibility_user_approval'))
          .fontSize($r('app.float.font_18'))
          .baselineOffset(-20)
          .margin({ bottom: $r('app.float.item_common_vertical_margin') })
      }
      Button($r('app.string.accessibility_disable'))
        .backgroundColor($r('app.color.font_color_007DFF'))
        .fontSize($r("app.float.font_20"))
        .fontColor(Color.White)
        .fontWeight(FontWeight.Medium)
        .width(ComponentConfig.WH_50_100)
        .onClick((event) => this.cancelEvent())
      Divider()
        .color($r('sys.color.ohos_id_color_list_separator'))
        .vertical(true)
        .height($r('app.float.wh_value_10'))
        .opacity($r('app.float.opacity_0_2'))
      Button(this.title)
        .backgroundColor(Color.White)
        .fontSize($r("app.float.font_20"))
        .fontColor(Color.Red)
        .fontWeight(FontWeight.Medium)
        .width(ComponentConfig.WH_50_100)
        .enabled(this.enableState)
        .opacity(this.enableState ? 1 : 0.5)
        .onClick((event) => this.confirmEvent())
    }
    .alignItems(HorizontalAlign.Center)
    .width(ConfigData.WH_100_100);
  }

  updateUserApproval(value: boolean): void {
    this.userApproval = value;
    this.getEnableButtonState();
  }

  getUserApproval(): boolean {
    return this.userApproval;
  }

  getEnableButtonState(): void {
    if (this.freezingTimeForView <= 0 && this.userApproval) {
      this.enableState = true;
    } else {
      this.enableState = false;
    }
  }

  updateButtonTitle(): void {
    this.getEnableButtonState();
    if (this.freezingTimeForView > 0) {
      this.title = $r('app.string.user_approval_remain_times', this.freezingTimeForView);
    } else {
      this.title = $r('app.string.accessibility_enable');
    }
  }

  cancelEvent(): void {
    LogUtil.info(MODULE_TAG + 'Cancel enable accessibility service');
    this.secondClickAction();
    this.freezingTimeForView = -1;
    this.dialogController.close();
  }

  confirmEvent(): void {
    LogUtil.info(MODULE_TAG + 'Confirm enable accessibility service');
    this.firstClickAction();
    this.dialogController.close();

  }

  @Log
  async freezeView() {
    if (this.countDownTime <= 0) {
      return;
    }
    this.freezingTimeForView = this.countDownTime / 1000;
    while (this.freezingTimeForView > 0) {
      await Sleep(1000);
      LogUtil.info(MODULE_TAG + 'time left: ' + JSON.stringify(this.freezingTimeForView));
      this.freezingTimeForView -= 1;
      this.updateButtonTitle();
    }
  }

  aboutToAppear(): void {
    this.freezeView();
  }

  aboutToDisappear(): void {
    this.freezingTimeForView = -1;
  }
}

export const Sleep = (ms)=> {
  return new Promise(resolve=>setTimeout(resolve, ms))
}