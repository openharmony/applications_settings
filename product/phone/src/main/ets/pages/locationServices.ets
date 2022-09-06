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

import ViewModel from '../model/locationServicesImpl/LocationViewModel';
import LogUtil from '../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import ConfigData from '../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData';
import HeadComponent from '../../../../../../common/component/src/main/ets/default/headComponent';
import { OuterLayoutComponentWithParam } from '../../../../../../common/component/src/main/ets/default/outerLayoutComponent';

/**
 * LocationServices
 */
@Entry
@Component
struct LocationServices {
  @StorageLink('LocationServiceStatus') locationServiceStatus: boolean = false;

  @Builder mLocationServices(locationServiceStatus: boolean) {
    Column() {
      HeadComponent({ headName: $r('app.string.locationServicesTab'), isActive: true });

      Flex({
        direction: FlexDirection.Row,
        justifyContent: FlexAlign.SpaceBetween,
        alignItems: ItemAlign.Center
      }) {
        Text($r('app.string.positionInformation'))
          .fontColor($r("app.color.font_color_182431"))
          .fontStyle(FontStyle.Normal)
          .fontSize($r("app.float.location_font_size"))
          .margin({ left: $r('app.float.distance_12') })

        Toggle({ type: ToggleType.Switch, isOn: locationServiceStatus })
          .margin({ right: $r('app.float.wh_value_6') })
          .width('36vp')
          .height('20vp')
          .selectedColor('#007DFF')
          .onChange((isOn: boolean) => {
            LogUtil.info(ConfigData.TAG + 'location service status is :' + locationServiceStatus);
            if ( locationServiceStatus === true ) {
              ViewModel.disableLocation();
            } else {
              ViewModel.enableLocation();
            }
          });
      }
      .margin({ top: $r("app.float.distance_8") })
      .height($r('app.float.wh_value_56'))
      .backgroundColor($r("app.color.white_bg_color"))
      .borderRadius($r("sys.float.ohos_id_corner_radius_default_l"))
    }
  }

  build() {
    Column(){
      OuterLayoutComponentWithParam({
        mContentComponentWithParam: this.mLocationServices(this.locationServiceStatus)
      })
    }
  }

  aboutToAppear(): void {
    LogUtil.info(ConfigData.TAG + 'location service about to appear');
    ViewModel.initViewModel();
  }

  aboutToDisappear(): void {
    LogUtil.info(ConfigData.TAG + 'location service about to disappear');
  }
}
