import axios from 'axios';
import cookie from 'react-cookie';
import _ from 'lodash';

import { BALANCE_FETCHED, HOUSE_FETCHED, SESSION_CREATED, SESSION_FAILED, SESSION_DESTROYED, USER_CREATED } from './types';

const ROOT_URL = `${process.env.REACT_APP_API}/v1`;

export function createSession({ email, password, linkedin_access_token }, history) {
  const url = `${ROOT_URL}/sessions`;

  return async (dispatch) => {
    try {
      const res = await axios.post(url, { email, password, linkedin_access_token });

      dispatch({ type: SESSION_CREATED, payload: res.data.user });
      localStorage.setItem('token', res.data.token);
      localStorage.setItem('user',  JSON.stringify(res.data.user));
      history.push('/dashboard');
    } catch(error) {
      dispatch({
        type: SESSION_FAILED,
        payload: 'Invalid email or password'
      });
    }
  };
}

export function destroySession() {
  localStorage.clear();
  return {
    type: SESSION_DESTROYED
  };
}

export function createUser(data) {
  const url = `${process.env.REACT_APP_API}/v2/users`;
  return (dispatch) => {
    return axios.post(url, data).then((res) => {
      dispatch({ type: USER_CREATED, payload: res.data });
    })
  };
}

export function createLinkedInSession({code, redirect_uri}, history) {
  const url = `${ROOT_URL}/tokens/linkedin`;

  return async (dispatch) => {
    // try {
      const res = await axios.get(url, { params: { code, redirect_uri } })
      .then(({data}) => {
        data.linkedin_access_token = data.token
        data.password = "blabla1234"
        dispatch(createUser(data)).then(() => {
          dispatch(createSession({ email: data.email, linkedin_access_token: data.token }, history));
        });
      });
  };
}

export function fetchHouse(id) {
  const url = `${ROOT_URL}/houses/${id}`;

  return async (dispatch) => {
      const res = await axios.get(url, { headers: { 'Authorization': localStorage.getItem('token') } })
      .then(({data}) => {
        dispatch({type: HOUSE_FETCHED, payload: data})
      });
  };
}

export function fetchBalance(house_id, user_id) {
  const url = `${ROOT_URL}/balances/${house_id}`;
  console.log(url);
  return async (dispatch) => {
      const res = await axios.get(url, { headers: { 'Authorization': localStorage.getItem('token') } })
      .then(({data}) => {
        // Map balance array to user ids
        // Transforms
        // [ [ {_id: "596cbc5af1805b000401e3ea", active: true, admin: false, avatar_url: "https://media.licdn.com/mpr/mprx/0_xrDWFXkqOLidCle…-PE8mdpVUy6r0kqw-Po8mzPSUyw5XZNOHGi8JkVS0uE7yPdDy", bio_title: "Assistant chef de campagne Digital et CRM chez Natixis  ;          ↵Freelance Web-Marketing/Growth", …},
        // 41], ...
        // ]
        // To :
        // {596cbc5af1805b000401e3ea: {_id: "596cbc5af1805b000401e3ea", active: true, admin: false, avatar_url: "https://media.licdn.com/mpr/mprx/0_xrDWFXkqOLidCle…-PE8mdpVUy6r0kqw-Po8mzPSUyw5XZNOHGi8JkVS0uE7yPdDy", bio_title: "Assistant chef de campagne Digital et CRM chez Natixis  ;          ↵Freelance Web-Marketing/Growth", …},
        // 41] }
        const balances = _.mapKeys(data.users, function(value, key){ return value[0]._id });
        dispatch({type: BALANCE_FETCHED, payload: balances[user_id][1]})
      });
  };
}