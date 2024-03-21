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
import Base from '@ohos.base';
import settings from '@ohos.settings';
import CommonEventManager from '@ohos.commonEventManager';
import CommonEvent from '@ohos.commonEvent';
import LogUtil from '../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import { GlobalContext } from '../../../../../../common/utils/src/main/ets/default/baseUtil/GlobalContext';
import ConfigData from '../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData';
import HeadComponent from '../../../../../../common/component/src/main/ets/default/headComponent';
import SwitchComponent from '../../../../../../common/component/src/main/ets/default/switchComponent';
import { SettingItemComponent } from '../../../../../../common/component/src/main/ets/default/settingItemComponent';
import MobileNetworkController from '../controller/mobileNetwork/MobileNetworkController';

const MODULE_TAG = ConfigData.TAG + '.mobileNetwork -> ';

/**
 * mobile Network
 */
@Entry
@Component
struct mobileNetwork {
  @State controllerMobileNetworkIsOn: boolean = false;
  @StorageLink("endTextEmpty") endTextEmpty: String = "";
  private mobileNetworkController: MobileNetworkController = new MobileNetworkController();
  private subscriber: CommonEventManager.CommonEventSubscriber|undefined = undefined;
  private subscribeInfo: CommonEventManager.CommonEventSubscribeInfo = {
    events: [CommonEvent.Support.COMMON_EVENT_AIRPLANE_MODE_CHANGED]
  };

  build() {
    Column() {
      GridContainer({ gutter: ConfigData.GRID_CONTAINER_GUTTER_24, margin: ConfigData.GRID_CONTAINER_MARGIN_24 }) {
        Column() {
          HeadComponent({ headName: $r("app.string.mobileNetwork"), isActive: true });
          Column() {
            List() {
              ListItem() {
                SwitchComponent({
                  title: $r("app.string.flightMode"),
                  summary: "",
                  isOn: $controllerMobileNetworkIsOn,
                  controller: this.mobileNetworkController,
                  switchHeight: $r("app.float.wh_value_56")
                })
              }

              ListItem() {
                // mobileData
                SettingItemComponent({
                  targetPage: "mobileData",
                  settingTitle: $r("app.string.mobileData"),
                  settingEndText: $endTextEmpty,
                  settingIcon: '',
                })
              }
              .padding({ left: $r("app.float.distance_4"), right: $r("app.float.distance_4") })
            }
            .width(ConfigData.WH_100_100)
            .divider({
              strokeWidth: $r('app.float.divider_wh'),
              color: $r('sys.color.ohos_id_color_list_separator'),
              startMargin: $r('app.float.wh_value_15'),
              endMargin: $r('app.float.wh_value_15') })
          }
          .borderRadius($r("app.float.radius_16"))
          .backgroundColor($r("app.color.white_bg_color"))
          .width(ConfigData.WH_100_100)
          .margin({ top: $r("app.float.distance_12") })
          .padding({
            top: $r("app.float.distance_4"),
            bottom: $r("app.float.distance_4")
          })
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

  aboutToAppear() {
    let context = GlobalContext.getContext().getObject(GlobalContext.globalKeySettingsAbilityContext) as Context;
    if (!GlobalContext.getContext().getObject(GlobalContext.globalKeySettingsAbilityContext)) {
      return;
    }
    LogUtil.info(MODULE_TAG + 'settings.getValueSync ' + settings.getValueSync(context, 'settings.telephony.airplanemode', '0'));
    if (settings.getValueSync(context, 'settings.telephony.airplanemode', '0') === '1') {
      this.controllerMobileNetworkIsOn = true;
    } else {
      this.controllerMobileNetworkIsOn = false;
    }

    CommonEventManager.createSubscriber(this.subscribeInfo).then((commonEventSubscriber) => {
      this.subscriber = commonEventSubscriber;
      //订阅公共事件
      CommonEventManager.subscribe(this.subscriber, (err, data) => {
        LogUtil.info(MODULE_TAG + `subscribe data is  ` + JSON.stringify(data));
        if (err) {
          LogUtil.info(MODULE_TAG + `subscribe failed, code is ${err.code}, message is ${err.message}`);
        } else {
          if (data.code === 1) {
            this.controllerMobileNetworkIsOn = true;
          } else {
            this.controllerMobileNetworkIsOn = false;
          }
        }
      });
    }).catch((err: Base.BusinessError) => {
      console.error(`createSubscriber failed, code is ${err?.code}, message is ${err.message}`);
    });
  }

  aboutToDisappear() {
    if (this.subscriber) {
      CommonEventManager.unsubscribe(this.subscriber);
      this.subscriber = undefined;
    }
  }
}
