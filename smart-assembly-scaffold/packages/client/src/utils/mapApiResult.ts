export function mapApiResult(result) {
  if (!Array.isArray(result) || result.length === 0) {
    throw new Error("Invalid result format");
  }

  const [keys, values] = result[0];

  if (!Array.isArray(keys) || !Array.isArray(values)) {
    throw new Error("Keys and values should be arrays");
  }

  // Map keys to values
  const mappedObject = keys.reduce((acc, key, index) => {
    acc[key] = values[index];
    return acc;
  }, {});

  return mappedObject;
}
