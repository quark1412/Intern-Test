const axios = require("axios");

const inputURL = "https://share.shub.edu.vn/api/intern-test/input";
const outputURL = "https://share.shub.edu.vn/api/intern-test/output";

let token = "";
let nums = [];
let queries = [];
let prefixSum = [];
let prefixAlt = [];

const fetchData = async () => {
  try {
    const response = await axios.get(inputURL);
    const res = response.data;

    if (res) {
      token = res.token;
      nums = res.data;
      queries = res.query;
    }
  } catch (error) {
    throw error;
  }
};

const preCompute = () => {
  const n = nums.length;
  prefixSum = new Array(n + 1).fill(0);

  for (let i = 0; i < n; i++) {
    prefixSum[i + 1] = prefixSum[i] + nums[i];
  }

  const prefixEven = new Array(n + 1).fill(0);
  const prefixOdd = new Array(n + 1).fill(0);

  for (let i = 0; i < n; i++) {
    prefixEven[i + 1] = prefixEven[i];
    prefixOdd[i + 1] = prefixOdd[i];

    if (i % 2 === 0) {
      prefixEven[i + 1] += nums[i];
    } else {
      prefixOdd[i + 1] += nums[i];
    }
  }

  prefixAlt = { prefixEven, prefixOdd };
};

const calculate = (query) => {
  const {
    type,
    range: [l, r],
  } = query;

  if (type === "1") {
    return prefixSum[r + 1] - prefixSum[l];
  } else if (type === "2") {
    const { prefixEven, prefixOdd } = prefixAlt;

    if (l % 2 === 0) {
      const evenSum = prefixEven[r + 1] - prefixEven[l];
      const oddSum = prefixOdd[r + 1] - prefixOdd[l];
      return evenSum - oddSum;
    } else {
      const evenSum = prefixEven[r + 1] - prefixEven[l];
      const oddSum = prefixOdd[r + 1] - prefixOdd[l];
      return oddSum - evenSum;
    }
  }

  return 0;
};

const solve = () => {
  preCompute();

  const results = [];
  for (const query of queries) {
    const result = calculate(query);
    results.push(result);
  }

  return results;
};

const submit = async (results) => {
  try {
    const response = await axios.post(outputURL, results, {
      headers: {
        Authorization: `Bearer ${token}`,
      },
    });
    console.log("Submission successful", response.data);
    return response.data;
  } catch (error) {
    throw error;
  }
};

const main = async () => {
  try {
    await fetchData();

    const results = solve();

    await submit(results);
  } catch (error) {
    throw error;
  }
};

main();
