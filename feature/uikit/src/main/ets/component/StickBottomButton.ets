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

@Component
export struct StickBottomButton {
  params: StickBottomButtonParams = new StickBottomButtonParams();

  build() {
    Column() {
      Button({ type: ButtonType.Normal }) {
        Text(this.params?.text)
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Medium)
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.ohos_id_color_warning'))
          .margin({
            top: $r('sys.float.padding_level5'),
            bottom: $r('sys.float.padding_level5'),
            left: $r('sys.float.padding_level8'),
            right: $r('sys.float.padding_level8'),
          })
          .maxLines(2)
          .ellipsisMode(EllipsisMode.END)
          .textOverflow({overflow: TextOverflow.Ellipsis})
      }
      .onClick(() => {
        this.params.clickFunc?.();
      })
      .borderRadius($r('sys.float.corner_radius_level10'))
      .width('100%')
      .constraintSize({
        minHeight: '21vp',
        maxWidth: '448vp',
      })
      .backgroundColor($r('sys.color.comp_background_tertiary'))
    }
    .justifyContent(FlexAlign.End)
    .padding({
      bottom: $r('sys.float.padding_level8'),
      top: $r('sys.float.padding_level8'),
      left: $r('sys.float.padding_level8'),
      right: $r('sys.float.padding_level8'),
    })
  }
}

export class StickBottomButtonParams {
  /**
   * button文本
   */
  public text?: ResourceStr = '';

  /**
   * 点击事件处理函数
   */
  public clickFunc?: Function;
}