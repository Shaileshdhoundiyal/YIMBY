const { default: axios } = require("axios");
const { encrypt } = require("../utils");

const api = axios.create({
  baseURL: "https://api.countrystatecity.in/v1/countries/US/states",
  timeout: 200000,
  headers: {
    Accept: "application/json",
    "Content-Type": "application/json;charset=UTF-8",
    "X-CSCAPI-KEY": "aDJ1MXJycnNiSkpKQnhrMXNEaWpJeFBsNktscjJwTll0TmhoRGF0NA==",
  },
});

const getStates = async (req, res) => {
  try {
    const result = await api.get();
    console.log(JSON.stringify(result?.data));
    result?.data?.sort(function (a, b) {
      return a.name.localeCompare(b.name);
    });
    return res.json(
      encrypt.encryptResponse(
        JSON.stringify({
          status: true,

          data: result?.data?.filter((item) => !item.iso2.includes("-")),
        }),
        req.headers
      )
    );
  } catch (er) {
    console.log(er);
  }
};

const getCities = async (req, res) => {
  try {
    let state = req.body.state;
    const result = await api.get(`/${state}/cities`);
    return res.json(
      encrypt.encryptResponse(
        JSON.stringify({
          status: true,
          data: result?.data,
        }),
        req.headers
      )
    );
  } catch (er) {
    console.log(er);
  }
};
module.exports = {
  getStates,
  getCities,
};
