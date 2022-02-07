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
import ViewModel from '../model/locationServicesImpl/LocationViewModel.ets'
import LogUtil from '../../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil.ets';
import ConfigData from '../../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData.ets';

/**
 * LocationServices
 */
@Entry
@Component
struct LocationServices {
  @StorageLink('LocationServiceStatus') locationServiceStatus: boolean = false;

  aboutToAppear(): void {
    LogUtil.info(ConfigData.TAG + 'location service about to appear');
    ViewModel.initViewModel();
  }

  aboutToDisappear(): void {
    LogUtil.info(ConfigData.TAG + 'location service about to disappear');
  }

  build() {
    Column() {
      HeadComponent({ headName: $r('app.string.locationServicesTab'), isActive: true });
      Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
        Text($r('app.string.positionInformation'))
          .fontColor(Color.Black)
          .fontStyle(FontStyle.Normal)
          .padding({ left: $r('app.float.switch_component_margin') })
          .fontSize('20')
        Toggle({ type: ToggleType.Switch, isOn: this.locationServiceStatus })
          .width($r('app.float.switch_toggle_width'))
          .height($r('app.float.switch_toggle_height'))
          .padding({ right: $r('app.float.switch_component_margin') })
          .onChange((isOn: boolean) => {
            LogUtil.info(ConfigData.TAG + 'location service status is :'+ this.locationServiceStatus);
            if(this.locationServiceStatus === true){
              ViewModel.disableLocation();
            }else{
              ViewModel.enableLocation();
            }
          });
      }
      Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Start }) {
        Text() {
          Span($r('app.string.positionContent'))
            .fontSize($r('app.float.location_font_size'));
          Span($r('app.string.statement'))
            .fontColor(Color.Blue)
            .fontSize($r('app.float.location_font_size'))
            .onClick(() => {
            })
        }
      }
      .visibility(this.locationServiceStatus ? Visibility.None : Visibility.Visible)
      .margin({ left: $r('app.float.location_common_margin'), right: $r('app.float.location_common_margin') });
    }
  }
}
