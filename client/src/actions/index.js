import axios from 'axios';
import cookie from 'react-cookie';
import _ from 'lodash';
import qs from 'query-string';

import { BALANCE_FETCHED, HOUSE_FETCHED, HOUSES_FETCHED,
  SESSION_CREATED, SESSION_FAILED, SESSION_DESTROYED,
  SESSION_FROM_TOKEN, SESSION_FROM_TOKEN_SUCCESS, SESSION_FROM_TOKEN_FAILURE,
  USER_CREATED, USER_CREATED_FAILURE, ACTIVE_OR_UPCOMING_USERS_FETCHED,
  MESSAGES_FETCHED, USERS_FETCHED,
  MESSAGE_LIKED
} from './types';

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
    try {
      var response = await axios.get(url, { params: { code, redirect_uri } })
      response.data.linkedin_access_token = response.data.token
      const user = await dispatch(createUser(response.data))
      const res = await dispatch(createSession({ email: response.data.email, password: null, linkedin_access_token: response.data.token }));
      return user;
    } catch(e) {
      throw e
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

export function fetchHouses() {
  const url = `${ROOT_URL}/houses`;

  return async (dispatch) => {
      const res = await axios.get(url, { headers: { 'Authorization': localStorage.getItem('token') } })
      .then(({data}) => {
        dispatch({type: HOUSES_FETCHED, payload: data})
      });
  };
}

export function fetchBalance(house_id, user_id, date) {
  const url = `${ROOT_URL}/balances/${house_id}?${qs.stringify({date: date.toISOString()})}`;
  return async (dispatch) => {
    const res = await axios.get(url, { headers: { 'Authorization': localStorage.getItem('token') } })
    dispatch({type: BALANCE_FETCHED, payload: res.data })
  };
}

// refactor this : remove and user fetchUsers with reducer
export function fetchActiveOrUpcomingUsers(house_id) {
  const url = `${ROOT_URL}/users?q[active_or_upcoming]=1&q[house_id]=${house_id}`;

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

export function fetchUsers(params) {
  const query = qs.stringify(params, {arrayFormat: 'bracket'});
  const url = `${ROOT_URL}/users?${query}`;

  return async (dispatch) => {
      const res = await axios.get(url, {
        headers: { 'Authorization': localStorage.getItem('token') } })

      dispatch({type: USERS_FETCHED, payload: res.data})
      return res.data;
  };
}

export function fetchMessages(params) {
  const query = qs.stringify(params, {arrayFormat: 'bracket'});
  const url = `${ROOT_URL}/messages?${query}`;

  return async (dispatch) => {
      const res = await axios.get(url, { headers: { 'Authorization': localStorage.getItem('token') } })
      const messages = _.sortBy(res.data, message => {
        return new Date(message.created_at);
      });

      dispatch({type: MESSAGES_FETCHED, payload: messages})
      return messages;
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

export function likeMessage({id, user_id}) {
  const url = `${ROOT_URL}/messages/${id}/like`;

  return async (dispatch) => {
    const res = await axios.put(url, {like_id: user_id}, { headers: { 'Authorization': localStorage.getItem('token') } })
    dispatch({type: MESSAGE_LIKED, payload: res.data})
  };
}

export function unlikeMessage({id, user_id}) {
  const url = `${ROOT_URL}/messages/${id}/like`;

  return async (dispatch) => {
    const res = await axios.delete(url, { data: { like_id: user_id },
                                          headers: { 'Authorization': localStorage.getItem('token') } })
    dispatch({type: MESSAGE_LIKED, payload: res.data})
  };
}
