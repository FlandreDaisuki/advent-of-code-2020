#!/usr/bin/env bun

const getProblemText = async() => {
  if (globalThis.document) {
    return document.body.textContent;
  }
  const filename = process.argv[1].replace(/.*(day\d+)[.]js/, '$1.txt');
  const file = Bun.file(filename);
  return file.text();
};

const mul = (...args) => args.flat(Infinity).reduce((a, b) => a * b, 1);
const sum = (...args) => args.flat(Infinity).reduce((a, b) => a + b, 0);
const execMulExpr = (mulExpr) => mul(mulExpr.match(/\d+/g).map(Number));

const oneLine = (await getProblemText())
  .trim()
  .split('\n')
  .join('\0');

const answer1 = sum(
  oneLine
    .match(/mul\(\d+,\d+\)/g)
    .map(execMulExpr)
);

// eslint-disable-next-line no-console
console.log('answer1', answer1);

const exprList = oneLine.match(/(?:do\(\)|don't\(\)|mul\(\d+,\d+\))/g);
const mulExprList = [];
let flag = 1;
for (const expr of exprList) {
  if(expr === 'do()') {
    flag = 1; continue;
  }
  if(expr === 'don\'t()') {
    flag = 0; continue;
  }
  if(flag === 1) {
    mulExprList.push(expr);
  }
}
const answer2 = sum(mulExprList.map(execMulExpr));

// eslint-disable-next-line no-console
console.log('answer2', answer2);
