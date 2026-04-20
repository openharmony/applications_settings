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
import {
  ContainerStyle,
  PageHeaderStyle,
  TextStyle
} from '@ohos/settings.common/src/main/ets/core/model/menu/ComponetStyle';
import {
  ButtonMenuContainerStyle,
  DialogMessageStyle,
  PageTitleTextStyle,
  PhoneMsgTextStyle,
  TransparentButtonMenuStyle
} from '../../menus/Menu';

export class BiometricsPatternDialogMsgStyle extends DialogMessageStyle {
  public rootContainer = new BiometricsPatternDialogMsgContainerStyle();
  public title = new PhoneMsgTextStyle();
}

export class BiometricsPatternDialogMsgContainerStyle extends ContainerStyle {
  public margin: Margin = {
    top: $r('app.float.margin_32'),
    bottom: $r('app.float.margin_0')
  };
  public size: SizeOptions = {
    width: '100%',
  };
  public padding: Padding = {
    left: '8vp',
    right: '8vp'
  };
}

export class PasswordButtonStyle extends ButtonMenuContainerStyle {
  public margin: Margin = { top: '8vp', bottom: '16vp' };
  public gridGutter: Length = '0vp';
  public gridMargin: Length = '0vp';
}

export class ButtonStyle extends TransparentButtonMenuStyle {
  public rootContainer = new PasswordButtonStyle();
}

export class BiometricsDialogMsgContainerStyle extends ContainerStyle {
  public margin: Margin = {
    top: $r('app.float.margin_0'),
    bottom: $r('app.float.margin_0')
  };
  public size: SizeOptions = {
    width: '100%',
  };
  public padding: Padding = {
    left: '16vp',
    right: '16vp'
  };
}

export class BaseMsgTextStyle extends TextStyle {
  public fontColor: ResourceColor = $r('sys.color.ohos_id_color_text_primary');
  public font: Font = {
    size: $r('app.float.font_16'),
    family: 'HarmonyHeiTi',
    weight: FontWeight.Medium,
  };
  public lineHeight = 'app.float.lineHeight_19';
  public textAlign = TextAlign.Start;
}

export class MsgTextStyle extends BaseMsgTextStyle {
  public size: SizeOptions = {
    width: '100%',
  };
}

export class BiometricsDialogMsgStyle extends DialogMessageStyle {
  public rootContainer = new BiometricsDialogMsgContainerStyle();
  public title = new MsgTextStyle();
}

export class MsgIconStyle extends TextStyle {
  public fontColor: ResourceColor = $r('sys.color.icon_secondary');
  public margin?: Margin = {
    right: $r('app.float.gridMargin_4')
  };
}

export class BiometricsDialogListMsgStyle extends BiometricsDialogMsgStyle {
  public icon = new MsgIconStyle();
}

export class MsgHeaderTextStyle extends MsgTextStyle {
  public margin: Margin = {
    bottom: $r('sys.float.padding_level4')
  };
}

export class BiometricsDialogHeaderMsgStyle extends BiometricsDialogMsgStyle {
  public title = new MsgHeaderTextStyle();
}

class DialogTitleTextStyle extends PageTitleTextStyle {
  public font: Font = {
    size: $r('sys.float.ohos_id_text_size_dialog_tittle'),
    weight: FontWeight.Bold,
    family: 'HarmonyHeiTi',
  };
  public margin: Margin = {
    top: $r('app.float.length_16'),
    bottom: $r('app.float.length_16'),
  };
  public justifyContent: FlexAlign = FlexAlign.Center;
  public constraintSize: ConstraintSizeOptions = {
    minHeight: '27vp',
  }
  public maxLines = 4;
  public overflow: TextOverflow = TextOverflow.Ellipsis;
}

export class DialogTitleMenuStyle extends PageHeaderStyle {
  public title?: TextStyle = new DialogTitleTextStyle();
}