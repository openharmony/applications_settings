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
import LogUtil from '../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import ApplicationInfoController from '../controller/application/ApplicationInfoController';
import Log from '../../../../../../common/utils/src/main/ets/default/baseUtil/LogDecorator';
import ConfigData from '../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData';
import HeadComponent from '../../../../../../common/component/src/main/ets/default/headComponent';
import EntryComponent from '../../../../../../common/component/src/main/ets/default/entryComponent';
import { DialogButtonLayout } from '../../../../../../common/component/src/main/ets/default/dialogComponent';

const MODULE_TAG = ConfigData.TAG + 'application-> ';
const deviceTypeInfo = deviceInfo.deviceType;
let appInfo;

/**
 * Application Info
 */
@Entry
@Component
struct ApplicationInfo {
  private controller: ApplicationInfoController = new ApplicationInfoController();
  @State isPhoneOrRK: boolean = false;
  @State isRemovableBundle: boolean = true;
  @State isTouchedLeft: boolean = false;
  @State isTouchedRight: boolean = false;
  showDialog: CustomDialogController = new CustomDialogController({
    builder: ShowDialog({
      action: () => {
        this.controller.uninstall(appInfo.settingBundleName);
      }
    }),
    alignment: this.isPhoneOrRK ? DialogAlignment.Bottom : DialogAlignment.Center,
    autoCancel: true,
    offset: ({ dx: 0, dy: this.isPhoneOrRK ? '-24dp' : 0 })
  });

  build() {
    Column() {
      GridContainer({ gutter: ConfigData.GRID_CONTAINER_GUTTER_24, margin: ConfigData.GRID_CONTAINER_MARGIN_24 }) {
        Column() {
          HeadComponent({ headName: $r('app.string.applicationInfo'), isActive: true });

          Row() {
            Image(appInfo.settingIcon)
              .width($r('app.float.wh_value_64'))
              .height($r('app.float.wh_value_64'))
              .margin({ right: $r('app.float.distance_16'), left: $r('sys.float.ohos_id_card_margin_start') })

            Column() {
              Text(appInfo.settingTitle)
                .fontColor($r('app.color.font_color_182431'))
                .fontSize($r('app.float.font_16'))
                .margin({ top: $r('app.float.wh_value_10'), bottom: $r('app.float.wh_value_5') })

              Text(appInfo.settingSummary)
                .fontColor($r('app.color.font_color_182431'))
                .fontSize($r('app.float.font_14'))
                .maxLines(ConfigData.MAX_LINES_1)
                .margin({ bottom: $r('app.float.distance_11') });
            }
            .alignItems(HorizontalAlign.Start)
            .width(ConfigData.WH_100_100)
            .height($r('app.float.wh_value_64'))
          }
          .width(ConfigData.WH_100_100)
          .margin({ top: $r("app.float.distance_8") })

          Row() {
            Button($r('app.string.uninstall'))
              .fontSize($r('app.float.application_button_subtitle_size'))
              .fontColor($r('app.color.font_color_007DFF'))
              .layoutWeight(ConfigData.LAYOUT_WEIGHT_1)
              .height($r('app.float.application_button_height'))
              .visibility(this.isRemovableBundle ? Visibility.Visible : Visibility.Hidden)
              .borderRadius($r('app.float.radius_20'))
              .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
              .onClick(() => {
                this.showDialog.open();
              })

            Column()
              .width($r('app.float.distance_24'))
              .height($r('app.float.application_button_height'))

            Button($r('app.string.forcedStop'))
              .fontSize($r('app.float.application_button_subtitle_size'))
              .fontColor($r('app.color.font_color_007DFF'))
              .layoutWeight(ConfigData.LAYOUT_WEIGHT_1)
              .height($r('app.float.application_button_height'))
              .borderRadius($r('app.float.radius_20'))
              .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
              .onClick(() => {
                this.showPromptDialog(this.controller.killProcessesByBundleName.bind(this, appInfo.settingBundleName));
              })
          }
          .alignItems(VerticalAlign.Center)
          .width(ConfigData.WH_100_100)
          .padding({
            top: $r('app.float.distance_24'),
            bottom: $r('app.float.distance_36'),
            left: $r('app.float.distance_24'),
            right: $r('app.float.distance_24')
          })

          Row() {
            EntryComponent({
              settingIcon: '',
              settingTitle: $r('app.string.storageTab'),
              settingSummary: $r('app.string.store_description_information', ''),
              settingValue: '',
              settingArrow: '/res/image/ic_settings_arrow.svg',
              settingArrowStyle: '',
              settingUri: '',
              fontSize: $r('app.float.font_16'),
              valueFontSize: $r('app.float.font_14')
            })
          }
          .padding({ top: $r('app.float.distance_4'), bottom: $r('app.float.distance_4') })
          .borderRadius($r('sys.float.ohos_id_corner_radius_default_l'))
          .backgroundColor($r('app.color.white_bg_color'))
          .onClick(() => {
            Router.push({ uri: 'pages/applicationStorage', params: appInfo });
          })
        }
        .padding({
          left: $r('sys.float.ohos_id_card_margin_start'),
          right: $r('sys.float.ohos_id_card_margin_end')
        })
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

  @Log
  aboutToAppear(): void{
    if (deviceTypeInfo === 'phone' || deviceTypeInfo === 'default') {
      this.isPhoneOrRK = true;
    } else {
      this.isPhoneOrRK = false;
    }

    appInfo = Router.getParams();
    LogUtil.info('settings ApplicationInfo aboutToAppear this.item:' + JSON.stringify(appInfo));
    this.updateRemovableStatus(appInfo.settingBundleName);
  }

  @Log
  onBackPress() {
    LogUtil.info('settings ApplicationInfo onBackPress');
  }

  /**
   * Stop exception prompt Dialog
   */
  @Log
  showPromptDialog(callback) {
    AlertDialog.show({
      message: $r("app.string.Stop_exception_prompt"),
      primaryButton: {
        value: $r('app.string.cancel'),
        action: () => {
          LogUtil.info(ConfigData.TAG + 'Closed callbacks');
        }
      },
      secondaryButton: {
        value: $r('app.string.forcedStop'),
        action: () => {
          LogUtil.info(ConfigData.TAG + `AlertDialog success:`);
          callback();
        }
      },
      alignment: this.isPhoneOrRK ? DialogAlignment.Bottom : DialogAlignment.Center,
      offset: ({ dx: 0, dy: this.isPhoneOrRK ? '-24dp' : 0 })
    })
  }

  updateRemovableStatus(bundleName) {
    this.controller.getBundleInfo(bundleName, (err, result) => {
      if (err) {
        LogUtil.info(MODULE_TAG + 'get system bundle info failed');
      }
      LogUtil.info(MODULE_TAG + `${bundleName} is removeable = ${result.appInfo.removable}`);

      if (result.appInfo.removable !== true) {
        this.isRemovableBundle = false;
      }
    });
  }
}

/**
 * Show dialog
 */
@CustomDialog
struct ShowDialog {
  dialogController: CustomDialogController;
  action: () => void;
  private uirBack: string = 'pages/appManagement';

  build() {
    Column() {
      Image(`${appInfo.settingIcon}`)
        .height($r("app.float.application_common_size"))
        .width($r("app.float.application_common_size"))
        .margin({
          top: $r('app.float.item_common_vertical_margin'),
          bottom: $r('app.float.item_common_vertical_margin')
        })

      Text(`${appInfo.settingTitle}`)
        .fontSize($r('app.float.font_18'))
        .align(Alignment.Center)
        .margin({ bottom: $r('app.float.item_common_vertical_margin') })

      Text($r("app.string.uninstall_prompt"))
        .fontSize($r('app.float.font_18'))
        .align(Alignment.Center)
        .margin({ bottom: $r('app.float.item_common_vertical_margin') })

      // button
      DialogButtonLayout({
        secondTitle: $r('app.string.uninstall'),
        firstClickEvent: () => {
          this.dialogController.close();
        },
        secondClickEvent: () => {
          this.action();
          this.dialogController.close();
          Router.back({ uri: this.uirBack });
        }
      })
    }
    .alignItems(HorizontalAlign.Center)
    .width(ConfigData.WH_100_100);
  }
}