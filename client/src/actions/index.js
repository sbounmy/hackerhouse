import axios from 'axios';
import cookie from 'react-cookie';
import { SESSION_CREATED, SESSION_FAILED, SESSION_DESTROYED } from './types';

const ROOT_URL = `/v1`;


export function createSession({ email, password }, history) {
  const url = `${ROOT_URL}/sessions`;

  return async (dispatch) => {
    try {
      const res = await axios.post(url, { email, password });

      dispatch({ type: SESSION_CREATED, payload: res.data.user });
      localStorage.setItem('token', res.data.token);
      localStorage.setItem('user',  JSON.stringify(res.data.user));
      history.push('/');
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