#!/usr/bin/env node

const getProblemText = async () => {
  if (globalThis.document) {
    return document.body.textContent;
  }
  const process = await import('node:process');
  const fs = await import('node:fs/promises');
  const filename = process.argv[1].replace(/.*(day\d+)[.]js/, '$1-8.txt');
  return fs.readFile(filename, 'utf8');
};

/** @param {string} text */
const splitLines = (text, separator = '\n') => text.split(separator)
  .map((line) => line.trim())
  .filter(Boolean);

const PIPE_TYPES = Object.freeze({
  //     ↑→↓←
  'S': 0b1111,
  'F': 0b0110,
  '-': 0b0101,
  '7': 0b0011,
  '|': 0b1010,
  'J': 0b1001,
  'L': 0b1100,
  '.': 0b0000,
});

const isTopOpened = (n) => (n & 0b1000) > 0;
const isRightOpened = (n) => (n & 0b0100) > 0;
const isBottomOpened = (n) => (n & 0b0010) > 0;
const isLeftOpened = (n) => (n & 0b0001) > 0;

/** @typedef {{id: string; r: number; c: number; t: PIPE_TYPES[keyof PIPE_TYPES]; }} MazeTile */

/**
 * @param {MazeTile | null | undefined} t0
 * @param {MazeTile | null | undefined} t1
 */
const isConnectable = (t0, t1) => {
  if (!t0 || !t1) { return false; }
  if (t0.c === t1.c + 1) {
    return isLeftOpened(t0.t) && isRightOpened(t1.t);
  }
  if (t0.c === t1.c - 1) {
    return isRightOpened(t0.t) && isLeftOpened(t1.t);
  }
  if (t0.r === t1.r + 1) {
    return isTopOpened(t0.t) && isBottomOpened(t1.t);
  }
  if (t0.r === t1.r - 1) {
    return isBottomOpened(t0.t) && isTopOpened(t1.t);
  }
  return false;
};

const lines = splitLines(await getProblemText());
const tiles = lines.map((line) => splitLines(line, ''));
/**
 * @type {Map<string, MazeTile>}
 */
const maze = new Map(tiles.flatMap((pipeRow, r) => {
  return pipeRow.map((p, c) => {
    return [`${r},${c}`, { id: `${r},${c}`, r, c, t: PIPE_TYPES[p] }];
  });
}));

const startPipe = Array.from(maze.values()).find((tile) => tile.t === PIPE_TYPES.S);

const visited = new Set();
const distanceMap = new Map([[startPipe.id, 0]]);

const bfsQueue = [startPipe];

const findNotVisitedNeighbors = (pipe) => {
  const { r, c } = pipe;
  return [
    maze.get(`${r + 1},${c}`),
    maze.get(`${r - 1},${c}`),
    maze.get(`${r},${c + 1}`),
    maze.get(`${r},${c - 1}`),
  ].filter((np) => isConnectable(pipe, np) && !visited.has(np.id));
};

while (bfsQueue.length > 0) {
  const head = bfsQueue.shift();
  visited.add(head.id);
  for (const nvn of findNotVisitedNeighbors(head)) {
    distanceMap.set(nvn.id, (distanceMap.get(head.id) ?? 0) + 1);
    bfsQueue.push(nvn);
  }
}

const lastAddedDistance = Array.from(distanceMap.values()).at(-1);
console.log('answer1', lastAddedDistance);

/** @param {number} length */
const range = (length) => Array.from({ length }, (_, i) => i);

/** @type {<T>(arr: T[], fn: (item: T) => boolean) => [T[], T[]]} */
const partition = (arr, fn = () => true) => {
  const right = [];
  const left = [];
  for (const item of arr) {
    if (fn(item)) {
      right.push(item);
    }
    else {
      left.push(item);
    }
  }
  return [right, left];
};

const id2rc = (id) => id.split(',').map(Number);

const mainLoopPipes = new Set(visited);

const nonPipeTileIds = new Set(maze.keys());
for (const mlp of mainLoopPipes) {
  nonPipeTileIds.delete(mlp);
}

const isHorizontalPipeId = (id) => {
  const pipeType = maze.get(id).t;
  if (!pipeType) { return false; }

  return pipeType !== PIPE_TYPES['|'] && pipeType !== PIPE_TYPES['.'];
};

const isVerticalPipeId = (id) => {
  const pipeType = maze.get(id).t;
  if (!pipeType) { return false; }

  return pipeType !== PIPE_TYPES['-'] && pipeType !== PIPE_TYPES['.'];
};

const isOdd = (n) => (n & 1) > 0;

const LEN_R = lines.length;
const LEN_C = lines[0].length;

const possibles0 = new Set();

for (const ri of range(LEN_R)) {
  let pc = 0;
  for (const ci of range(LEN_C)) {
    const p = `${ri},${ci}`;
    if (mainLoopPipes.has(p)) {
      if (isVerticalPipeId(p)) {
        pc += 1;
      }
    }
    else if (isOdd(pc)) {
      possibles0.add(p);
    }
  }
}

const possibles1 = new Set();

for (const ci of range(LEN_C)) {
  let pc = 0;
  for (const ri of range(LEN_R)) {
    const p = `${ri},${ci}`;
    if (mainLoopPipes.has(p)) {
      if (isHorizontalPipeId(p)) {
        pc += 1;
      }
    }
    else if (isOdd(pc)) {
      possibles1.add(p);
    }
  }
}

const intersect = (s0, s1) => {
  const s = new Set();
  for (const i of s0) {
    if (s1.has(i)) { s.add(i); }
  }
  return s;
};

// for (const nonMlp of nonPipeTileIds) {
//   const [r, c] = id2rc(nonMlp);
//   const sameRowPipes = Array.from(mainLoopPipes).filter((p) => id2rc(p)[0] === r);
//   const sameColPipes = Array.from(mainLoopPipes).filter((p) => id2rc(p)[1] === c);
//   const [leftPipes, rightPipes] = partition(sameRowPipes, (p) => id2rc(p)[1] < c);
//   const [topPipes, bottomPipes] = partition(sameColPipes, (p) => id2rc(p)[0] < r);

//   const isEnclosed = isOdd(leftPipes.filter(isVerticalPipeId).length)
//     && isOdd(rightPipes.filter(isVerticalPipeId).length)
//     && isOdd(topPipes.filter(isHorizontalPipeId).length)
//     && isOdd(bottomPipes.filter(isHorizontalPipeId).length);
//   if (isEnclosed) {
//     enclosedCount += 1;
//   }
// }

// const floodBfsQueue = [`0,0`];
// const floodVisited = new Set();

// while (floodBfsQueue.length > 0) {
//   const headId = floodBfsQueue.shift();
//   if (floodVisited.has(headId)) { continue; }
//   if (mainLoopPipes.has(headId)) { continue; }

//   floodVisited.add(headId);
//   const [r, c] = id2rc(headId);
//   if (r + 1 < NR) {
//     floodBfsQueue.push(`${r + 1},${c}`);
//   }
//   if (r - 1 >= 0) {
//     floodBfsQueue.push(`${r - 1},${c}`);
//   }
//   if (c + 1 < NC) {
//     floodBfsQueue.push(`${r},${c + 1}`);
//   }
//   if (c - 1 >= 0) {
//     floodBfsQueue.push(`${r},${c - 1}`);
//   }
// }

console.log('answer2', intersect(possibles0, possibles1).size);
