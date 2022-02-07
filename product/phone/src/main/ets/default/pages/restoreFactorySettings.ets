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

import HeadComponent from '../../../../../../../common/component/src/main/ets/default/headComponent.ets';
import RestoreFactorySettingsController from '../controller/restoreFactorySettings/restoreFactorySettingsController.ets'
import LogUtil from '../../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil.ets';
import ConfigData from '../../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData.ets';

/**
 * Developer options
 */
@Entry
@Component
struct restoreFactorySettings {
  private controller: RestoreFactorySettingsController = new RestoreFactorySettingsController();

  build() {
    Column() {
      HeadComponent({ headName: $r("app.string.restoreFactoryTab"), isActive: true });
      Button() {
        Text($r("app.string.restoreFactoryTab"))
          .fontSize($r('app.float.restore_factory_font_size'))
          .fontColor(Color.Blue)
      }
      .backgroundColor($r('app.color.color_E3E3E3_grey'))
      .width($r('app.float.restore_factory_button_width'))
      .height($r('app.float.restore_factory_button_height'))
      .align(Alignment.Bottom)
      .onClick(this.getRestoreFactory);
    }
  }

  /**
   * Get restoreFactory
   */
  private getRestoreFactory = (event) => {
    AlertDialog.show({
      title: $r('app.string.restoreFactoryTab'),
      message: $r("app.string.restoreFactory"),
      primaryButton: {
        value: $r('app.string.confirm'),
        action: () => {
          // TODO need PW
          this.controller.restoreFactorySettings();
          LogUtil.info(ConfigData.TAG + `AlertDialog success:`);
        }
      },
      secondaryButton: {
        value: $r('app.string.cancel'),
        action: () => {
          LogUtil.info(ConfigData.TAG + 'Closed callbacks');
        }
      }
    })
  }
}