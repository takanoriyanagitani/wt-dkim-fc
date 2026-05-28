//@ts-expect-error
import { readFile } from "node:fs/promises";

(async () => {

  /** @type {string} */
  const wasm = "./fclassify.wasm";

  const pbytes = readFile(wasm);
  const pwasm = pbytes.then(WebAssembly.instantiate);

  const { instance } = await pwasm;
  const { exports } = instance;
  const { find_classify_dkim, memory } = exports;

  const buf = await readFile("/dev/stdin");
  const bsz = buf.length;
  const view = new Uint8Array(memory.buffer, 0, bsz);
  view.set(buf);

  const rslt = find_classify_dkim(
    0,
    bsz-1,
  );

  console.info(rslt);

})();
