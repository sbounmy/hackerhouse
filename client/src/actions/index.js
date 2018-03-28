import axios from 'axios';
import cookie from 'react-cookie';
import _ from 'lodash';

import { BALANCE_FETCHED, HOUSE_FETCHED,
  SESSION_CREATED, SESSION_FAILED, SESSION_DESTROYED,
  SESSION_FROM_TOKEN, SESSION_FROM_TOKEN_SUCCESS, SESSION_FROM_TOKEN_FAILURE,
  USER_CREATED, USER_CREATED_FAILURE, ACTIVE_OR_UPCOMING_USERS_FETCHED} from './types';

const ROOT_URL = `${process.env.REACT_APP_API}/v1`;

export function createSession({ email, password, linkedin_access_token }) {
  const url = `${ROOT_URL}/sessions`;

  return async (dispatch) => {
    try {
      const res = await axios.post(url, { email, password, linkedin_access_token });

      dispatch({ type: SESSION_CREATED, payload: res.data.user });
      localStorage.setItem('token', res.data.token);
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
  return async (dispatch) => {
    dispatch({type: SESSION_DESTROYED});
  };
}

export function createUser(data) {
  const url = `${process.env.REACT_APP_API}/v2/users`;
  return async (dispatch) => {
    try {
      const response = await axios.post(url, data)
      dispatch({ type: USER_CREATED, payload: response.data });
      return response;
    } catch (error) {
      dispatch({ type: USER_CREATED_FAILURE, payload: error.response.data });
      return error
    }
  };
}

export function createLinkedInSession({code, redirect_uri}) {
  const url = `${ROOT_URL}/tokens/linkedin`;

  return async (dispatch) => {
    var response = await axios.get(url, { params: { code, redirect_uri } })
    response.data.linkedin_access_token = response.data.token
    try {
      const user = await dispatch(createUser(response.data))
      const res = await dispatch(createSession({ email: response.data.email, password: null, linkedin_access_token: response.data.token }));
      return user;
    } catch(e) {
      // throw error
    }
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

export function fetchActiveOrUpcomingUsers(house_id) {
  const url = `${ROOT_URL}/users?q[active_or_upcoming]=1&q[house_id]=${house_id}`;
  console.log(url);
  return async (dispatch) => {
      const res = await axios.get(url, { headers: { 'Authorization': localStorage.getItem('token') } })
      .then(({data}) => {
        const users = _.sortBy(data, user => {
          const active = new Date(user.check_in) < _.now()
          user.action = `check_${active ? 'out' : 'in'}`
          user.action_date = active ? user.check_out : user.check_in
          return new Date(user.action_date);
        });

        dispatch({type: ACTIVE_OR_UPCOMING_USERS_FETCHED, payload: users})
      });
  };
}
export function sessionFromToken(tokenFromStorage) {
  const url = `${ROOT_URL}/sessions?token=${tokenFromStorage}`
  //check if the token is still valid, if so, get me from the server
  return async (dispatch) => {
    try {
      dispatch({type: SESSION_FROM_TOKEN, payload: response})
      const response = await axios.get(url,
      { headers: { 'Authorization': `Bearer ${tokenFromStorage}` } });
      dispatch({type: SESSION_FROM_TOKEN_SUCCESS, payload: response.data.user})
      return response
    }
    catch(error) {
      dispatch({type: SESSION_FROM_TOKEN_FAILURE, payload: error.response.data})
      return error.response.data
    }
  }
}