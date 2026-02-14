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

import { LogUtil } from '../utils/LogUtil';
import Stack from '@ohos.util.Stack';
import { Operator } from './Condition';

const IS_DEBUG = false;

const TAG = 'BooleanExpressionParser : ';

const PARSE_BRACKETS_ERROR = 'Expression parse brackets error!';

const EXPRESSION_EMPTY = 'Expression empty error!';

const EXPRESSION_ILLEGAL = 'Expression illegal!';

const INDEX_LABEL = '@';

const OR_OPERATOR = ' OR ';

const AND_OPERATOR = ' AND ';

const REVERSE_OPERATOR = '!';

const ILLEGAL_REVERSE = '!!';

const EQUAL_OPERATOR = Operator.EQUAL_OPERATOR;

const GREATER_OPERATOR = Operator.GREATER_OPERATOR;

const LESS_OPERATOR = Operator.LESS_OPERATOR;

const REVERSE_EQUAL_OPERATOR = Operator.REVERSE_EQUAL_OPERATOR;

const GREATER_OR_EQUAL_OPERATOR = Operator.GREATER_OR_EQUAL_OPERATOR;

const LESS_OR_EQUAL_OPERATOR = Operator.LESS_OR_EQUAL_OPERATOR;

const LINE_SPLIT_MARK = '\r|\n';

const EXPRESSION_MAX_LENGTH = 500;

const SUB_EXPRESSION_MAX_SIZE = 10;

const ILLEGAL_STATE = -1;

const MEET_STATE = 1;

const MISS_STATE = 0;

/**
 * 布尔表达式解析器
 *
 * @since 2020-06-01
 */
export class BooleanExpressionParser {

  /**
   * 括号包裹的子句集合
   */
  protected mBracketsExpressions: Map<string, string> = new Map();

  /**
   * 是否处于检验状态
   */
  protected mIsInCheckState: boolean;
  private mExpression: string;

  constructor(expression: string) {
    this.mExpression = this.getPretreatmentExpression(expression);
  }

  private getPretreatmentExpression(expression: string): string {
    if (this.hasIllegalString(expression)) {
      return '';
    }
    // 去除换行和首尾空格
    let trimExpression = expression.replace(new RegExp(LINE_SPLIT_MARK, 'g'), '').trim();
    LogUtil.info(TAG + 'original expression : ' + trimExpression);
    let bracketsStack: Stack<number> = new Stack<number>();
    let pretreatmentExpression: string = trimExpression;
    let subExpressionIndex: number = 0;
    let pos: number = 0;
    while (pos < pretreatmentExpression.length) {
      if (pretreatmentExpression.charAt(pos) === '(') {
        bracketsStack.push(pos);
        pos++;
        continue;
      }

      // 解析处理一个括号
      if (pretreatmentExpression.charAt(pos) === ')') {
        if (bracketsStack.isEmpty()) {
          LogUtil.error(`${TAG} ${PARSE_BRACKETS_ERROR}`);
          return '';
        }

        let bracketsStart: number = bracketsStack.pop();
        if (pos <= bracketsStart + 1) {
          LogUtil.error(TAG + PARSE_BRACKETS_ERROR);
          return '';
        }
        let subExpression: string = pretreatmentExpression.slice(bracketsStart + 1, pos).trim();
        if (!subExpression) {
          LogUtil.error(TAG + PARSE_BRACKETS_ERROR);
          return '';
        }

        // 把括号中的子串替换成参数索引，如“@1”
        let indexString: string = INDEX_LABEL + subExpressionIndex;
        this.mBracketsExpressions.set(indexString, subExpression);
        pretreatmentExpression = pretreatmentExpression.slice(0, bracketsStart) + indexString + pretreatmentExpression.slice(pos);
        subExpressionIndex++;
        pos = bracketsStart + indexString.length;
        continue;
      }
      pos++;
    }
    if (!bracketsStack.isEmpty()) {
      LogUtil.error(TAG + PARSE_BRACKETS_ERROR);
      return '';
    }
    if (IS_DEBUG) {
      LogUtil.info(TAG + 'pretreatmentExpression : ' + pretreatmentExpression);
    }
    return pretreatmentExpression.toString();
  }

  private hasIllegalString(expression: string): boolean {
    if (!expression) {
      LogUtil.error(TAG + EXPRESSION_EMPTY);
      return true;
    }

    if (expression.length > EXPRESSION_MAX_LENGTH) {
      LogUtil.error(TAG + 'Expression length error');
      return true;
    }
    if (expression.indexOf(INDEX_LABEL) >= 0) {
      LogUtil.error(TAG + 'Expression contains illegal index label!');
      return true;
    }
    if (expression.indexOf(ILLEGAL_REVERSE) >= 0) {
      LogUtil.error(TAG + 'Expression contains illegal reverse operator!');
      return true;
    }
    return false;
  }

  private async getExpressionState(): Promise<number> {
    if (!this.mExpression) {
      return ILLEGAL_STATE;
    }
    try {
      // 或符号优先级最高，首先处理
      let isMeet = await this.isMeetOrConditions(this.mExpression);
      return isMeet ? MEET_STATE : MISS_STATE;
    } catch (err) {
      LogUtil.error(TAG + EXPRESSION_ILLEGAL);
    }
    return ILLEGAL_STATE;
  }

  /**
   * 检验表达式是否合法
   *
   * @return True if legal
   */
  public async isLegalExpression(): Promise<boolean> {
    this.mIsInCheckState = true;
    let state = await this.getExpressionState();
    return state !== ILLEGAL_STATE;
  }

  /**
   * 表达式是否满足当前条件
   *
   * @return True if meet all conditions.
   */
  public async isMeetConditions(): Promise<boolean> {
    this.mIsInCheckState = false;
    let state = await this.getExpressionState();
    return state === MEET_STATE;
  }

  private async isMeetOrConditions(expression: string): Promise<boolean> {
    let orExpressions = this.getSubExpressions(expression, OR_OPERATOR);
    if (orExpressions === null || orExpressions.length === 0) {
      LogUtil.error(TAG + 'sub orExpressions empty error!');
      throw new Error('invalid');
    }
    if (orExpressions.length > SUB_EXPRESSION_MAX_SIZE) {
      LogUtil.error(TAG + 'Too many sub orExpressions!');
      throw new Error('invalid');
    }
    if (IS_DEBUG) {
      LogUtil.info(TAG + 'isMeetOrConditions expression :' + expression);
    }
    for (let subExpression of orExpressions) {
      // 或运算一个满足即退出，合法校验状态下除外
      let isMeet = await this.isMeetAndConditions(subExpression);
      if (isMeet) {
        if (!this.mIsInCheckState) {
          return true;
        }
      }
    }
    return false;
  }

  private async isMeetAndConditions(expression: string): Promise<boolean> {
    let andExpressions = this.getSubExpressions(expression, AND_OPERATOR);
    if (andExpressions === null || andExpressions.length === 0) {
      LogUtil.error(TAG + 'sub andExpressions empty error!');
      throw new Error('invalid');
    }
    if (andExpressions.length > SUB_EXPRESSION_MAX_SIZE) {
      LogUtil.error(TAG + 'Too many sub andExpressions!');
      throw new Error('invalid');
    }
    if (IS_DEBUG) {
      LogUtil.info(TAG + 'isMeetAndConditions expression : ' + expression);
    }
    for (let subExpression of andExpressions) {
      // 与运算一个不满足即退出，合法校验状态下除外
      let isMeet = await this.isMeetCondition(subExpression);
      if (!isMeet) {
        if (!this.mIsInCheckState) {
          return false;
        }
      }
    }
    return true;
  }

  private getSubExpressions(expression: string, operator: string): Array<string> {
    let expressions: string[] = [];
    if (!expression) {
      LogUtil.error(TAG + EXPRESSION_EMPTY);
      throw new Error('invalid');
    }
    let originalExpressions = expression.split(operator);
    for (let string of originalExpressions) {
      expressions.push(string.trim());
    }
    return expressions;
  }

  private async isMeetCondition(expression: string): Promise<boolean> {
    if (!expression) {
      LogUtil.error(TAG + EXPRESSION_EMPTY);
      throw new Error('invalid');
    }

    if (IS_DEBUG) {
      LogUtil.info(TAG + 'isMeetCondition expression : ' + expression);
    }

    if (expression.startsWith(INDEX_LABEL)) {
      return await this.isMeetOrConditions(this.mBracketsExpressions.get(expression));
    }

    if (expression.startsWith(REVERSE_OPERATOR)) {
      let nextExpression = expression.slice(1).trim();
      if (nextExpression.startsWith(REVERSE_OPERATOR)) {
        LogUtil.error(TAG + 'Too many reverse operator!');
        throw new Error('invalid');
      }
      return !(await this.isMeetCondition(nextExpression));
    }

    if (expression.indexOf(REVERSE_EQUAL_OPERATOR) >= 0) {
      return !(await this.isMeetCondition(expression.replace(REVERSE_EQUAL_OPERATOR, EQUAL_OPERATOR)));
    }

    if (expression.indexOf(GREATER_OR_EQUAL_OPERATOR) >= 0) {
      return !(await this.isMeetCondition(expression.replace(GREATER_OR_EQUAL_OPERATOR, LESS_OPERATOR)));
    }

    if (expression.indexOf(LESS_OR_EQUAL_OPERATOR) >= 0) {
      return !(await this.isMeetCondition(expression.replace(LESS_OR_EQUAL_OPERATOR, GREATER_OPERATOR)));
    }

    return await this.isSingleExpressionMatch(expression);
  }

  /**
   * 单个表达式匹配.
   *
   * @param expression 单个表达式
   * @return True 如果匹配
   */
  protected async isSingleExpressionMatch(expression: string): Promise<boolean> {
    return false;
  }
}

