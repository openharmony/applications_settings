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
import LogUtil from '../../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil.ets';
import EntryComponent from '../../../../../../../common/component/src/main/ets/default/entryComponent.ets';
import HeadComponent from '../../../../../../../common/component/src/main/ets/default/headComponent.ets';
import Router from '@system.router'
import ConfigData from '../../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData.ets';
import ApplicationInfoController from '../controller/application/ApplicationInfoController.ets'
import Log from '../../../../../../../common/utils/src/main/ets/default/baseUtil/LogDecorator.ets';

let appInfo;

/**
 * Application Info
 */
@Entry
@Component
struct ApplicationInfo {
  private controller: ApplicationInfoController = new ApplicationInfoController();
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
      HeadComponent({ headName: $r('app.string.applicationInfo'), isActive: true });
      Row() {
          EntryComponent({
            settingIcon: appInfo.settingIcon,
            settingTitle: appInfo.settingTitle,
            settingSummary: appInfo.settingSummary,
            settingValue: '',
            settingArrow: '',
            settingArrowStyle: '',
            settingUri: appInfo.settingUri
          });
      }

      Flex({ direction: FlexDirection.Row }) {
        Button() {
          Text($r("app.string.uninstall"))
            .fontSize($r('app.float.application_button_subtitle_size'))
            .fontColor(Color.Blue)
        }
        .backgroundColor($r('app.color.color_E3E3E3_grey'))
        .width('150')
        .height($r('app.float.application_button_height'))
        .align(Alignment.BottomStart)
        .flexGrow(1)
        .onClick(() => {
          this.showDialog.open();
        })
        Button() {
          Text($r("app.string.forcedStop"))
            .fontSize($r('app.float.application_button_subtitle_size'))
            .fontColor(Color.Blue)
        }
        .backgroundColor($r('app.color.color_E3E3E3_grey'))
        .width($r("app.float.wh_value_160"))
        .height($r('app.float.application_button_height'))
        .align(Alignment.BottomEnd)
        .flexGrow(1)
        .onClick(()=>{
          this.showPromptDialog(this.controller.killProcessesByBundleName.bind(this, appInfo.settingBundleName));
        })
      }
      .width(ConfigData.WH_90_100)
      .margin({ top: $r('app.float.item_common_vertical_margin'), bottom: $r('app.float.item_common_vertical_margin') })

      Row() {
        EntryComponent({
          settingIcon: '',
          settingTitle: $r("app.string.storageTab"),
          settingSummary: '',
          settingValue: '',
          settingArrow: '/res/image/ic_settings_arrow.svg',
          settingArrowStyle: '',
          settingUri: ''
        })
      }
      .width(ConfigData.WH_90_100)
      .onClick(() => {
        Router.push({ uri: 'pages/applicationStorage', params: appInfo });
      })
    }
  }
  @Log
  aboutToAppear(): void{
    appInfo = Router.getParams();
    LogUtil.info('settings ApplicationInfo aboutToAppear this.item:' + JSON.stringify(appInfo));
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
      Flex({ justifyContent: FlexAlign.SpaceEvenly }) {

        Button() {
          Text($r('app.string.cancel'))
            .fontSize($r('app.float.application_button_subtitle_size'))
            .fontColor(Color.Blue)
        }
        .backgroundColor($r('app.color.color_E3E3E3_grey'))
        .width($r("app.float.wh_value_160"))
        .height($r("app.float.wh_value_40"))
        .onClick(() => {
          this.dialogController.close();
        })

        Button() {
          Text($r('app.string.uninstall'))
            .fontSize($r('app.float.application_button_subtitle_size'))
            .fontColor(Color.Blue)
        }
        .backgroundColor($r('app.color.color_E3E3E3_grey'))
        .width($r("app.float.wh_value_160"))
        .height($r("app.float.wh_value_40"))
        .onClick(() => {
          this.action();
          this.dialogController.close();
          Router.back({ uri: this.uirBack });
        })

      }
      .width(ConfigData.WH_100_100)
      .height($r('app.float.wh_value_60'));
    }
    .alignItems(HorizontalAlign.Center)
    .width(ConfigData.WH_100_100);
  }
}