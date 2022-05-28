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
import LogUtil from '../../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import EntryComponent from '../../../../../../../common/component/src/main/ets/default/entryComponent';
import HeadComponent from '../../../../../../../common/component/src/main/ets/default/headComponent';
import { DialogButtonLayout } from '../../../../../../../common/component/src/main/ets/default/dialogComponent';
import Router from '@system.router'
import ConfigData from '../../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData';
import ApplicationInfoController from '../controller/application/ApplicationInfoController'
import Log from '../../../../../../../common/utils/src/main/ets/default/baseUtil/LogDecorator';

const MODULE_TAG = ConfigData.TAG + 'application-> ';

let appInfo;

/**
 * Application Info
 */
@Entry
@Component
struct ApplicationInfo {
  private controller: ApplicationInfoController = new ApplicationInfoController();
  @State isRemovableBundle: boolean = true;
  @State isTouchedLeft: boolean = false;
  @State isTouchedRight: boolean = false;
  showDialog: CustomDialogController = new CustomDialogController({
    builder: ShowDialog({
      action: () => {
        this.controller.uninstall(appInfo.settingBundleName)
      }
    }),
    alignment: DialogAlignment.Bottom,
    autoCancel: true
  });

  build() {
    Column() {
      GridContainer({
        columns: 12,
        sizeType: SizeType.Auto,
        gutter: vp2px(1) === 2 ? '12vp' : '0vp',
        margin: vp2px(1) === 2 ? '24vp' : '0vp'
      }) {
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
            HeadComponent({ headName: $r('app.string.applicationInfo'), isActive: true });
            Row() {
              Image(appInfo.settingIcon)
                .width($r('app.float.wh_value_64'))
                .height($r('app.float.wh_value_64'))
                .margin({ right: $r('app.float.distance_16'), left: $r('app.float.distance_24') })

              Column() {
                Text(appInfo.settingTitle)
                  .fontColor($r('app.color.font_color_182431'))
                  .fontSize($r('app.float.font_16'))
                  .alignSelf(ItemAlign.Start)
                  .margin({ top: $r('app.float.wh_value_10'), bottom: $r('app.float.wh_value_5') })
                Row() {
                  Text(appInfo.settingSummary)
                    .fontColor($r('app.color.font_color_182431'))
                    .fontSize($r('app.float.font_14'))
                    .maxLines(ConfigData.MAX_LINES_1)
                    .margin({ bottom: $r('app.float.distance_11') });
                }
                .alignSelf(ItemAlign.Start)
              }
              .width(ConfigData.WH_100_100)
              .height($r('app.float.wh_value_64'))
            }.width(ConfigData.WH_100_100)
            .margin({ top: $r("app.float.distance_8") })

            Row() {
              Text($r('app.string.uninstall'))
                .fontSize($r('app.float.application_button_subtitle_size'))
                .lineHeight($r('app.float.wh_value_22'))
                .fontColor($r('app.color.font_color_007DFF'))
                .textAlign(TextAlign.Center)
                .layoutWeight(1)
                .height($r('app.float.application_button_height'))
                .visibility(this.isRemovableBundle ? Visibility.Visible : Visibility.Hidden)
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
                  this.showDialog.open();
                })

              Column()
                .width($r('app.float.distance_24'))
                .height($r('app.float.application_button_height'))

              Text($r('app.string.forcedStop'))
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
            .padding($r('app.float.distance_4'))
            .borderRadius($r('sys.float.ohos_id_corner_radius_default_l'))
            .backgroundColor($r('app.color.white_bg_color'))
            .onClick(() => {
              Router.push({ uri: 'pages/applicationStorage', params: appInfo });
            })
          }
          .backgroundColor($r("sys.color.ohos_id_color_sub_background"))
          .padding({ left: $r('sys.float.ohos_id_card_margin_start'), right: $r('sys.float.ohos_id_card_margin_end') })
          .width(ConfigData.WH_100_100)
          .height(ConfigData.WH_100_100)
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
          });
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

  @Log
  aboutToAppear(): void{
    appInfo = Router.getParams();
    LogUtil.info('settings ApplicationInfo aboutToAppear this.item:' + JSON.stringify(appInfo));
    this.updateRemovableStatus(appInfo.settingBundleName);
  }

  @Log
  onBackPress() {
    Router.back();
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
      alignment: DialogAlignment.Bottom
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
  private uirBack: string = 'pages/appManagement'

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