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

import { SecurityInfo } from '../data/types';
import { LogUtil } from '../utils/LogUtil';
import { PasswordUtil } from '../utils/PasswordUtil';

const TAG: string = 'SecurityContext : ';

/**
 * 安全上下文
 *
 * @since 2023-09-25
 */
export default class SecurityContext {
  private static instance: SecurityContext | null = null;
  private token: Uint8Array | null = null;
  private challenge: Uint8Array | null = null;
  private password: string | null = null;
  private oldPsdCredId: Uint8Array | null = null;

  static getInstance() {
    if (SecurityContext.instance === null) {
      SecurityContext.instance = new SecurityContext();
    }
    return SecurityContext.instance;
  }

  /**
   * 保存token
   *
   * @param token value
   */
  public setToken(token: Uint8Array): void {
    this.token = token;
  }

  /**
   * 获取token
   *
   * @returns value
   */
  public getToken(): Uint8Array {
    return this.token as Uint8Array;
  }

  /**
   * 设置challenge
   *
   * @param challenge value
   */
  public setChallenge(challenge: Uint8Array): void {
    this.challenge = challenge;
  }

  /**
   * 获取challenge
   *
   * @returns value
   */
  public getChallenge(): Uint8Array {
    return this.challenge as Uint8Array;
  }

  /**
   * 设置密码
   *
   * @param password value
   */
  public setPassword(password: string): void {
    this.password = password;
  }

  /**
   * 获取密码
   *
   * @returns value
   */
  public getPassword(): string {
    return this.password as string;
  }

  /**
   * 设置旧密码凭据
   *
   * @param password value
   */
  public setOldPsdCredId(credId: Uint8Array | undefined): void {
    if (credId) {
      this.oldPsdCredId = credId;
    }
  }

  /**
   * 获取旧密码凭据
   *
   * @returns value
   */
  public getOldPsdCredId(): Uint8Array | null {
    return this.oldPsdCredId;
  }

  /**
   * 清空旧密码凭据
   */
  public emptyOldPasswordCred(): void {
    this.oldPsdCredId = null;
  }

  /**
   * 清空密码
   */
  public emptyPassword(): void {
    this.password = '';
  }
}

