/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
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
import { AboutDeviceUtils } from "../utils/AboutDeviceUtils"

@Component
export struct ScreenItemComponent {
 @State API:string =  ''
  build() {
    Flex({ wrap:  FlexWrap.Wrap ,
      justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
      Text(this.API)
        .fontFamily('HarmonyHeiTi')
        .fontWeight(FontWeight.Medium)
        .fontSize($r('sys.float.Body_L'))
        .fontColor(Color.White)
        .offset({y:'75%',x:'50%'})
        .markAnchor({x:'50%',y:'50%'})
    }
    .borderRadius($r('sys.float.corner_radius_level8'))
    .backgroundImage($r('app.media.video_bg'))
    .backgroundImageSize(ImageSize.Cover)
    .backgroundImagePosition(Alignment.Center)
    .height(280)
  }
aboutToAppear(): void {
 this.API =  AboutDeviceUtils.getApiVersion()
}

}