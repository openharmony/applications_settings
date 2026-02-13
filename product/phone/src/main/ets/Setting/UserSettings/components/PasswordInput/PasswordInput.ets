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

/* instrument ignore file */
import { LogHelper } from '@ohos/settings.common/src/main/ets/framework/common/LogHelper';
import { FOCUS_BOX_PADDING_METRICS } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { parseResource } from '../../common/utils/ValidateUtil';
import { PasswordIconVM } from './PasswordIconVM';

/**
 * 自定义密码图标组件，可配置大小写图标
 */
@Component
export struct PasswordIcon {
  tag: string = 'PasswordIcon';
  @ObjectLink vm: PasswordIconVM;

  aboutToDisappear(): void {
    LogHelper.info(this.tag, 'aboutToDisappear');
    this.vm.clear();
  }

  build() {
    Row() {
      SymbolGlyph($r('sys.symbol.arrowshape_up_frame_fill'))
        .symbolStyle()
        .visibility(this.vm.isCapsIconVisible ? Visibility.Visible : Visibility.None)
        .bindPopup(this.vm.isCapsTipsVisible, {
          message: parseResource($r('app.string.capslock_on')),
          placement: Placement.Bottom,
          messageOptions: {
            font: {
              size: $r('sys.float.Body_M'),
              weight: FontWeight.Regular,
            },
            textColor: $r('sys.color.font_primary'),
          },
        })

      Blank(8)

      SymbolGlyph(this.vm.getPwdIcon())
        .symbolStyle()
        .onClick(() => this.vm.onPwdIconClick())
    }
  }
}

@Extend(SymbolGlyph)
function symbolStyle() {
  .draggable(false)
  .fontSize('24vp') // 单位为 vp，不受 fontScale 影响
  .borderRadius(12)
  .focusBox({ margin: FOCUS_BOX_PADDING_METRICS })
}

/**
 * 将自定义密码图标组件与输入框包裹在一起的容器
 *  ______________________________________
 * |      InputSlot      |  PasswordIcon  |
 *  ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
 */
@Component
export struct PasswordIconWrapper {
  @Prop inputType: InputType;
  @Prop passwordIconVM: PasswordIconVM;
  @Prop wrapperSize: SizeOptions | undefined = undefined;
  @BuilderParam inputSlot: () => void;

  build() {
    Row() {
      this.inputSlot()
      if (this.inputType === InputType.Password) {
        PasswordIcon({ vm: this.passwordIconVM })
      }
    }
    .size(this.wrapperSize)
    .flexShrink(1)
  }
}