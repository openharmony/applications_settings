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
import promptAction from '@ohos.promptAction';
import buffer from '@ohos.buffer';
import { BusinessError } from '@ohos.base';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { PasswordUtil } from '@ohos/settings.common/src/main/ets/utils/PasswordUtil';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { PrivacyConstant } from '@ohos/settings.common/src/main/ets/constant/PrivacyConstant';
import { UserConstraints } from '../constants/UserConstraints'

const UNICODE: buffer.BufferEncoding = 'utf-8';
const tag: string = 'Users common utils:';
/**
 * 密码输入框最大长度，超过该长度无法输入
 */
const PASSWORD_TEXT_INPUT_MAX_LENGTH: number = 32;

/**
 * 密码输入框最小长度，小于该长度无法输入
 */
const PASSWORD_TEXT_INPUT_MIN_LENGTH: number = 6;

/**
 * 校验密码
 * @param password 密码
 * @returns 校验错误信息
 */
export function validatePassword(password: string | undefined): string {
  if (!password) {
    return '';
  }
  const pwdLength: number = getBufferLength(password);
  const lBoundary: number = PASSWORD_TEXT_INPUT_MIN_LENGTH - 1;
  const rBoundary: number = PASSWORD_TEXT_INPUT_MAX_LENGTH + 1;
  const isTooShort: boolean = pwdLength < PASSWORD_TEXT_INPUT_MIN_LENGTH;
  const isTooLong: boolean = pwdLength > PASSWORD_TEXT_INPUT_MAX_LENGTH;
  const includesIllegalChar: boolean = PasswordUtil.isContainIllegalCharacter(password);

  if (isTooShort && includesIllegalChar) {
    return parseResource($r('app.string.password_contain_illegal_character_and_too_short'), lBoundary);
  }
  if (isTooShort && !includesIllegalChar) {
    return parseResource($r('app.string.password_too_short'), lBoundary);
  }
  if (isTooLong && includesIllegalChar) {
    return parseResource($r('app.string.password_contain_illegal_character_and_too_long'), rBoundary);
  }
  if (isTooLong && !includesIllegalChar) {
    return parseResource($r('app.string.password_too_long'), rBoundary);
  }
  if (!isTooShort && !isTooLong && includesIllegalChar) {
    return parseResource($r('app.string.password_contain_illegal_character'));
  }
  return '';
}

/**
 * 将文本资源转换为文本
 * @param resource 文本资源
 * @param subStr 替换文字
 * @returns 转换后的文本
 */
export function parseResource(resource: Resource, ...params: Array<string | number>): string {
  if (Array.isArray(params)) {
    if (!params.find((p => typeof p !== 'number'))) {
      let str: string = ResourceUtil.getAnyNumFormatStringSync(resource, ...params as number[]);
      if (params.length === 1) {
        str = str.replace('%d', params[0].toString());
      }
      return str;
    }
    if (!params.find((p => typeof p !== 'string'))) {
      let str: string = ResourceUtil.getAnyStrFormatStringSync(resource, ...params as string[]);
      if (params.length === 1) {
        str = str.replace('%s', params[0] as string);
      }
      return str;
    }
  }
  return ResourceUtil.getStringSync(resource);
}

export function getBufferLength(str: string, encoding: buffer.BufferEncoding = UNICODE): number {
  return buffer.byteLength(str, encoding);
}

/**
 * 通过用户昵称获得一个合法的账号名称
 * 账号名称规则：不允许出现特殊字符< > | : " * ? / \且不允许独立出现. ..
 * @param nickName 用户昵称
 * @returns 账号名称
 */
export function convertNickNameToAccountName(nickName: string): string {
  const replacedText = nickName.replace(UserConstraints.ACCOUNT_NAME_REPLACE_REG, '');
  // 将nickName替换特殊字符后赋值给accountName，特殊情况下替换后为空字符，因为账号名称不能为空，返回替换前字符串触发错误校验
  if (!replacedText || (replacedText === '.' || replacedText === '..')) {
    return nickName;
  }
  return replacedText;
}

const DEFAULT_TOAST_DURATION: number = 2000; // 文本不超过一行采用2秒短提示

/**
 * 气泡弹窗
 * @param message 弹窗内容
 */
export function toast(message: ResourceStr): void {
  const options: promptAction.ShowToastOptions = {
    message,
    duration: DEFAULT_TOAST_DURATION,
  };
  try {
    promptAction.showToast(options);
  } catch (error) {
    LogUtil.error(`${tag} showToast args error code is ${error?.code}, message is ${error?.message}`);
  }
}

/**
 * 等待指定时间
 * @param time 等待时间,以秒为单位
 */
export async function wait(time: number): Promise<void> {
  return new Promise((resolve) => {
    setTimeout(() => {
      resolve();
    }, time * 1000);
  });
}

/**
 * 提示对话框弹窗
 * @param message 提示信息
 * @param title 提示框标题（可选）
 */
export async function alert(message: ResourceStr, title?: ResourceStr): Promise<boolean> {
  return new Promise((resolve) => {
    AlertDialog.show({
      title: title,
      message: message,
      autoCancel: true,
      backgroundBlurStyle: BlurStyle.COMPONENT_ULTRA_THICK,
      textStyle: {
        wordBreak: WordBreak.NORMAL,
      },
      onWillDismiss: (action: DismissDialogAction) => {
        action.dismiss();
        resolve(false);
      },
      confirm: {
        value: $r('app.string.button_title_ok'),
        fontColor: $r('sys.color.font_emphasize'),
        backgroundColor: $r('sys.color.comp_background_tertiary'),
        action: () => {
          resolve(true);
        },
      },
    });
  });
}

/**
 * 开关隐私模式，可用于涉及密码的界面，禁止截图/录屏
 * @param enable 是否开启隐私模式
 */
export function switchPrivacyMode(enable: boolean) {
  LogUtil.info(`${tag} switchPrivacyMode ${enable}`);
  if (enable) {
    LogUtil.info(`${tag} switchPrivacyMode true`);
    PasswordUtil.setPrivacyMode(true);
  } else {
    setTimeout(() => {
      LogUtil.info(`${tag} switchPrivacyMode false`);
      PasswordUtil.setPrivacyMode(false);
    }, PrivacyConstant.PC_DIALOG_CLOSE_ANIM_TIME);
  }
}

/**
 * 生成 HiSysEvent 上报的错误信息
 * @param code 错误码
 * @param message 错误信息
 * @returns
 */
export function generateFaultEventValue(code: number, message: string): string

/**
 * 生成 HiSysEvent 上报的错误信息
 * @param result 错误码或错误信息对象
 * @returns
 */
export function generateFaultEventValue(result: BusinessError | number): string

export function generateFaultEventValue(...params: Array<string | number | BusinessError>): string {
  let code: number | undefined = undefined;
  let message: string = '';
  if (params.length === 1) {
    const result = params[0] as BusinessError | number;
    if (typeof result === 'number') {
      code = result;
    } else {
      code = result.code;
      message = result.message;
    }
  } else {
    code = params[0] as number;
    message = params[1] as string;
  }
  return `Error ${code}: ${message}`;
}