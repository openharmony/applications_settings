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

import deviceInfo from '@ohos.deviceInfo';
import parameter from '@ohos.systemparameter';
import OverdrawController from '../controller/developerOptions/OverdrawController';
import UsbDebuggingController from '../controller/developerOptions/UsbDebuggingController';
import LogUtil from '../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import ConfigData from '../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData';
import HeadComponent from '../../../../../../common/component/src/main/ets/default/headComponent';
import LayoutBoundariesController from '../controller/developerOptions/LayoutBoundariesController';
import SwitchComponent from '../../../../../../common/component/src/main/ets/default/switchComponent';

const deviceTypeInfo = deviceInfo.deviceType;
const MODULE_TAG = ConfigData.TAG + '.developerOptions -> ';
const GRAPHIC_ANIMATION_SCALE_NAME = "persist.sys.graphic.animationscale";
const ARKUI_ANIMATION_SCALE_NAME = "persist.sys.arkui.animationscale";

/**
 * Developer options
 */
@Entry
@Component
struct developerOptions {
  @State columnMargin: string = '24vp';
  @State AnimationText: any = " ";
  @State checked: string = "1";
  @State controllerLayoutBoundariesIsOn: boolean = false;
  @State controllerOverdrawIsOn: boolean = false;
  @State controllerDebugIsOn: boolean = false;
  @State isPhoneOrRK: boolean = false;
  @State getAnimationMultiplier: string =  parameter.getSync(ARKUI_ANIMATION_SCALE_NAME);

  private controller: UsbDebuggingController = new UsbDebuggingController();
  private controllerOverdraw: OverdrawController = new OverdrawController();
  private controllerLayoutBoundaries: LayoutBoundariesController = new LayoutBoundariesController();
  private AnimationMultiplier: any[] = ["0", "0.5", "1", "1.5", "2", "5", "10"];

  private AnimationScalingDialog: CustomDialogController = new CustomDialogController({
    builder: AnimationScalingInformation({
      AnimationMultiplier: this.AnimationMultiplier,
      AnimationText: $AnimationText,
      checked: $checked,
      isPhoneOrRK: $isPhoneOrRK
    }),
    alignment: this.isPhoneOrRK ? DialogAlignment.Bottom : DialogAlignment.Center,
    offset: ({ dx: 0, dy: this.isPhoneOrRK ? '-24dp' : 0 }),
    autoCancel: true,
    customStyle: true
  });

  aboutToAppear() {
    LogUtil.info(MODULE_TAG + "aboutToAppear");

    if (deviceTypeInfo === 'phone' || deviceTypeInfo === 'default') {
      this.isPhoneOrRK = true;
    } else {
      this.isPhoneOrRK = false;
    }

    this.AnimationText = this.getAnimationMultiplier === "" ? $r("app.string.Animation_Zooms") :
      (this.getAnimationMultiplier === "0" ? $r("app.string.Close_Animation") : $r("app.string.Animation_Multiplier", this.getAnimationMultiplier));
    this.checked = this.getAnimationMultiplier === "" ? "1" : this.getAnimationMultiplier;

    if (parameter.getSync("debug.graphic.overdraw") === "false") {
      this.controllerOverdrawIsOn = false;
    } else {
      this.controllerOverdrawIsOn = Boolean(parameter.getSync("debug.graphic.overdraw"));
    }

    if (parameter.getSync("persist.ace.debug.boundary.enabled") === "false") {
      this.controllerLayoutBoundariesIsOn = false;
    } else {
      this.controllerLayoutBoundariesIsOn = Boolean(parameter.getSync("persist.ace.debug.boundary.enabled"));
    }
    LogUtil.info(MODULE_TAG + "aboutToAppear end");
  }

  build() {
    Column() {
      GridContainer({ gutter: ConfigData.GRID_CONTAINER_GUTTER_24, margin: ConfigData.GRID_CONTAINER_MARGIN_24 }) {
        Column() {
          HeadComponent({ headName: $r("app.string.developerOptionsTab"), isActive: true });

          SwitchComponent({
            title: $r("app.string.usbDebugging"),
            summary: $r("app.string.locationServicesPromptInfo"),
            isOn: $controllerDebugIsOn,
            controller: this.controller,
            switchHeight: $r("app.float.wh_value_72")
          })
            .margin({ top: $r("app.float.distance_8") })

          Column() {
            List() {
              ListItem() {
                SwitchComponent({
                  title: $r("app.string.Show_Layout_Boundaries"),
                  summary: $r("app.string.Show_boundaries_Margin"),
                  isOn: $controllerLayoutBoundariesIsOn,
                  controller: this.controllerLayoutBoundaries,
                  switchHeight:$r("app.float.wh_value_64")
                })
              }

              ListItem() {
                Row() {
                  Column() {
                    Text($r("app.string.Global_Animation"))
                      .fontColor($r('sys.color.ohos_fa_text_primary'))
                      .fontFamily("HarmonyHeiTi")
                      .fontWeight(FontWeight.Medium)
                      .fontSize($r("sys.float.ohos_id_text_size_body1"))
                  }
                  .alignItems(HorizontalAlign.Start)

                  Blank()

                  Row() {
                    Text(this.AnimationText)
                      .margin({ right: $r("app.float.distance_4") })
                      .fontSize($r("sys.float.ohos_id_text_size_body2"))
                      .fontColor($r('sys.color.ohos_fa_text_secondary'))

                    Image('/res/image/ic_settings_arrow.svg')
                      .width($r('app.float.wh_value_12'))
                      .height($r('app.float.wh_value_24'))
                      .fillColor($r("sys.color.ohos_id_color_primary"))
                      .opacity($r("app.float.opacity_0_2"))
                  }
                  .onClick(() => {
                    this.AnimationScalingDialog.open();
                  })
                }
                .padding({ left: $r('sys.float.ohos_id_card_margin_start'), right: $r('app.float.distance_8') })
                .alignItems(VerticalAlign.Center)
                .width(ConfigData.WH_100_100)
                .height($r("app.float.wh_value_48"))
              }
            }
            .width(ConfigData.WH_100_100)
            .divider({
              strokeWidth: $r('app.float.divider_wh'),
              color: $r('sys.color.ohos_id_color_list_separator'),
              startMargin: $r('app.float.wh_value_15'),
              endMargin: $r('app.float.wh_value_15') })
          }
          .borderRadius($r("app.float.wh_value_24"))
          .backgroundColor($r("app.color.white_bg_color"))
          .width(ConfigData.WH_100_100)
          .margin({ top: $r("app.float.distance_12") })
          .padding({
            top:$r("app.float.distance_4"),
            bottom:$r("app.float.distance_4")
          })

          SwitchComponent({
            title: $r("app.string.Debug_GPU_OverDraw"),
            summary: "",
            isOn: $controllerOverdrawIsOn,
            controller: this.controllerOverdraw,
            switchHeight: $r("app.float.wh_value_56")
          })
            .margin({ top: $r("app.float.distance_12") })
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
}

@CustomDialog
struct AnimationScalingInformation {
  controller: CustomDialogController;
  private AnimationMultiplier;
  @Link isPhoneOrRK : boolean ;
  @Link AnimationText: any;
  @Link checked: string;

  aboutToAppear() {
    LogUtil.info(MODULE_TAG + "aboutToAppear  deviceTypeInfo" + JSON.stringify(deviceTypeInfo));
  }

  build() {
    Column(){
      Column() {
        Text($r("app.string.Excessive_animation_scaling"))
          .fontFamily("HarmonyHeiTi")
          .fontSize($r("sys.float.ohos_id_text_size_headline8"))
          .fontWeight(FontWeight.Medium)
          .height($r("app.float.wh_value_56"))
          .alignSelf(ItemAlign.Start)

        List() {
          ForEach(this.AnimationMultiplier, (item, index) => {
            ListItem() {
              Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
                Text(item === "0" ? $r("app.string.Close_Animation") : $r("app.string.Animation_Multiplier", item))
                  .fontFamily("HarmonyHeiTi")
                  .fontSize($r("sys.float.ohos_id_text_size_body1"))
                  .fontWeight(FontWeight.Medium)

                Radio({ value: "", group: 'radioGroup' })
                  .checked(this.checked === item ? true : false)
                  .height($r("app.float.wh_value_24"))
                  .width($r("app.float.wh_value_24"))
                  .onChange((value: boolean) => {
                    if(value) {
                      this.controller.close();
                      if (item === "0") {
                        this.AnimationText = $r("app.string.Close_Animation");
                        parameter.set(GRAPHIC_ANIMATION_SCALE_NAME, "0");
                        parameter.set(ARKUI_ANIMATION_SCALE_NAME, "0");
                        LogUtil.info(MODULE_TAG + "close animation success");
                      } else {
                        this.AnimationText = $r("app.string.Animation_Multiplier", item);
                        parameter.set(GRAPHIC_ANIMATION_SCALE_NAME, item)
                          .then(() => {
                            LogUtil.info(MODULE_TAG + "set graphic parameter success");
                          })
                          .catch((err) => {
                            LogUtil.info(MODULE_TAG + "catch graphic parameter error" + JSON.stringify(err));
                          })

                        parameter.set(ARKUI_ANIMATION_SCALE_NAME, item)
                          .then(() => {
                            LogUtil.info(MODULE_TAG + "set arkui parameter success");
                          })
                          .catch((err) => {
                            LogUtil.info(MODULE_TAG + "catch arkui parameter error" + JSON.stringify(err));
                          })
                      }
                      this.checked = item;
                    }
                  })
              }
              .height($r("app.float.wh_value_48"))
            }
            .height($r("app.float.wh_value_48"))
          })
        }

        Text($r("app.string.Cancel_Animation"))
          .fontSize($r("sys.float.ohos_id_text_size_button1"))
          .fontColor($r("sys.color.ohos_id_color_text_primary_activated"))
          .alignSelf(ItemAlign.Center)
          .width($r("app.float.cancel_animation_button_w_value"))
          .height($r("app.float.wh_value_40"))
          .margin({ top: $r("app.float.distance_8") })
          .onClick(() => {
            this.controller.close();
          })
      }
      .padding({
        left: $r("app.float.padding_24"),
        right: $r("app.float.padding_24")
      })
      .height($r("app.float.animationScalingInformation_h_value"))
      .alignItems(HorizontalAlign.Center)
      .backgroundColor($r("app.color.white_bg_color"))
      .borderRadius($r("app.float.radius_24"))
    }
    .width(this.isPhoneOrRK ? ConfigData.WH_100_100 : $r("app.float.wh_value_410"))
    .padding(this.isPhoneOrRK ? { left: $r("app.float.distance_12"), right: $r("app.float.distance_12")} : {})
  }
}
