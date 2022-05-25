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
import ComponentConfig from './ComponentConfig';
import InputMethod from '@ohos.inputmethod';

/**
 * TextInput component
 */
@Component
export default struct textInputComponent {
  private hintText: string= '';
  private contextText: string= '';

  build() {
    TextInput({ placeholder: this.hintText, text: this.contextText })
      .placeholderColor(Color.Blue)
      .placeholderFont({ size: ConfigData.font_20, weight: 2, family: "sans-serif", style: FontStyle.Normal })
      .caretColor(Color.Blue)
      .height($r('app.float.wh_value_70'))
      .backgroundColor(Color.White)
      .type(InputType.Password)
      .width(ComponentConfig.WH_100_100)
      .margin({ left: $r('app.float.wh_value_15'), right: $r('app.float.wh_value_15') })
      .onChange((value: string) => {
        this.contextText = value;
      })
      .onSubmit((enterKey) => {
        InputMethod.getInputMethodController().stopInput().then((ret) => {
          LogUtil.debug(`${ConfigData.TAG}, enterType: ${enterKey}, stopInput: ${ret}`);
        });
      });
  }
}