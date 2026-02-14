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
export struct TitleIcon {
  @Prop symbolIcon: Resource;
  @Prop accessibilityTextRes: Resource;
  @State iconBackgroundColor: ResourceStr = $r('sys.color.interactive_hover');
  onClickButton: () => void = () => {
  };

  build() {
    Button() {
      SymbolGlyph(this.symbolIcon)
        .fontSize('24vp')
        .fontColor([$r('sys.color.icon_primary')])
        .renderingStrategy(SymbolRenderingStrategy.SINGLE)
        .focusable(true)
        .draggable(false)
    }
    .onClick(() => {
      this.onClickButton();
    })
    .width(40)
    .height(40)
    .borderRadius(20)
    .focusOnTouch(true)
    .align(Alignment.Center)
    .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
    .accessibilityText(this.accessibilityTextRes)
  }
}